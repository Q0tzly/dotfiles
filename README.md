# dotfiles

macOS / Linux (zsh / Ghostty / helix / starship / mise) の設定。

## セットアップ

ネットがあれば 1 コマンド。clone → symlink → mise でツール導入まで行う。

```sh
curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash
# ツールのグループも有効にする
curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash -s -- --groups lang,ai
# 全グループ
curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash -s -- --all
```

- clone 先: `~/dev/github.com/q0tzly/dotfiles`（`DOTFILES=` で変更可）
- 既存ファイルは `*.bak.<日時>` に退避してから symlink する
- `--link-only`: symlink だけ張り、mise は入れない
- Ghostty 本体は入れない
- 前提: `curl` と `git`（macOS は `xcode-select --install`）、`zsh`。Linux で `cargo:` 系（`rust-tools` や `hw` グループ）を入れるなら C コンパイラ（例: `build-essential`）も要る
- Linux は Ubuntu 24.04 (aarch64) のコンテナで `install.sh` と `scripts/mise-upgrade.sh` を確認済み。systemd の timer は未確認

## 構成

| path | リンク先 |
| --- | --- |
| `zsh/zshrc` | `~/.zshrc` |
| `git/config` | `~/.config/git/config` |
| `ghostty/config.ghostty` | macOS: `~/Library/Application Support/com.mitchellh.ghostty/`、Linux: `~/.config/ghostty/` |
| `helix/` | `~/.config/helix/` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `cargo/config.toml` | `~/.cargo/config.toml` |
| `ai/AGENTS.md` | `~/.claude/CLAUDE.md` と `~/.codex/AGENTS.md` |
| `mise/config.toml` | `~/.config/mise/config.toml` |
| `mise/groups/` | `mise-group enable` で `~/.config/mise/conf.d/` にリンク |
| `scripts/mise-group` | `~/.local/bin/mise-group` |
| `launchd/` `systemd/` | 手動で有効化（下記） |

## 仕事用・マシン固有の設定

リポジトリに入れず、次のファイルに置く（無ければ無視される）。

| ファイル | 用途 |
| --- | --- |
| `~/.config/git/work` | `grus-systems/` 配下で使う名前・メール（`git/config` の `includeIf` で読む） |
| `~/.zshrc.local` | トークンなどの環境変数 |
| `<dir>/mise.toml` | そのディレクトリだけで使うツール |

`~/.gitconfig` は触らない。

## コーディングエージェント

Claude Code と Codex のグローバル指示は `ai/AGENTS.md` の 1 ファイルで共通（旧 for-AI リポジトリ）。

- Codex は `@パス` の読み込みに対応していないので、このファイルは他を読み込まずに完結させる
- `~/.claude/settings.json` と `~/.claude/skills/` はリンクしない。設定はマシンの状態を含み、skills にはプラグインが自動で書き込むため
- 実装を Gemini Flash に委任する仕組みは別リポジトリの [subcon](https://github.com/Q0tzly/subcon)。手順は `subcon guide` で読む

## mise

- `mise/config.toml`: core。常に入る最小構成
- `mise/groups/<名前>.toml`: ジャンルごとの追加ツール。`mise-group` で入れたり消したりする

```sh
mise-group list                  # 一覧（[x] が有効）
mise-group enable lang ai        # 有効化してインストール
mise-group disable lang          # 無効化して、そのグループのツールだけ削除
```

- 有効なグループは `~/.config/mise/conf.d/<名前>.toml`（グループ定義への symlink）の有無で決まる。マシンごとに組み合わせを変えられる。
- `disable` は、他の有効な設定にも載っているツールは消さない。`mise prune` は使わない。
- グループ: `lang` `rust-tools` `ai` `cloud` `container`（colima/lima は mac 限定） `hw` `wasm` `media` `misc`
- `hw` は GrusArch 向け。動作確認済みの版に固定してあり、自動アップデートでは変わらない（上げるときは手で）。mise で再現できない・大きすぎるもの（oss-cad-suite、xPack の RISC-V GCC、LibreLane、fusesoc の venv、sky130、KLayout.app）は `~/.local/opt` などに手動で入れたままで、版は `hw.toml` の冒頭に書いてある。

## Rust の target/ が重いとき

- `cargo/config.toml` で dev ビルドのデバッグ情報を行番号のみに減らしている（サイズの大半を占めるため）。
- 古いビルド成果物は `cargo sweep --recursive --time 30 <path>` で消せる（path 省略で今のディレクトリ。`rust-tools` グループの `cargo-sweep`）。例: `cargo sweep -r -t 30 .` / `cargo sweep -r -t 30 ~/dev`
- sccache は外した。キャッシュが別に数 GB 増えるうえ、incremental ビルドと相性が悪く、target/ のサイズも減らないため。

## 自動アップデート

毎日 12:00 に `scripts/mise-upgrade.sh`（core と有効なグループを `mise upgrade`、prune はしない）が走る。ログは mac が `~/Library/Logs/mise-upgrade.log`、Linux は `journalctl --user -u mise-upgrade`。

macOS (launchd):

```sh
ln -sf "$PWD/launchd/dev.q0tzly.mise-upgrade.plist" ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.q0tzly.mise-upgrade.plist
launchctl kickstart gui/$(id -u)/dev.q0tzly.mise-upgrade   # 手動実行
```

Linux (systemd user):

```sh
mkdir -p ~/.config/systemd/user
ln -sf "$PWD"/systemd/mise-upgrade.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now mise-upgrade.timer
systemctl --user start mise-upgrade.service   # 手動実行
```

秘密情報（トークン等）は置かない。
