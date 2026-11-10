# dotfiles

macOS / Linux (zsh / Ghostty / helix / starship / mise) の設定。

## セットアップ

ネットがあれば 1 コマンド。clone → symlink → mise でツール導入まで行う。

```sh
curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash
# plus (開発用の追加ツール込み)
curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash -s -- --plus
```

- clone 先: `~/dev/github.com/q0tzly/dotfiles`（`DOTFILES=` で変更可）
- 既存ファイルは `*.bak.<日時>` に退避してから symlink する
- `--link-only`: symlink だけ張り、mise は入れない
- Ghostty 本体は入れない
- 前提: `curl` と `git`（macOS は `xcode-select --install`）、`zsh`。Linux で plus（`cargo:` 系）を入れるなら C コンパイラ（例: `build-essential`）も要る
- Linux でも動くが、まだ実機では試していない

## 構成

| path | リンク先 |
| --- | --- |
| `zsh/zshrc` | `~/.zshrc` |
| `git/config` | `~/.config/git/config` |
| `ghostty/config.ghostty` | macOS: `~/Library/Application Support/com.mitchellh.ghostty/`、Linux: `~/.config/ghostty/` |
| `helix/` | `~/.config/helix/` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `cargo/config.toml` | `~/.cargo/config.toml` |
| `mise/` | `~/.config/mise/` |
| `launchd/` `systemd/` | 手動で有効化（下記） |

## 仕事用・マシン固有の設定

リポジトリに入れず、次のファイルに置く（無ければ無視される）。

| ファイル | 用途 |
| --- | --- |
| `~/.config/git/work` | `grus-systems/` 配下で使う名前・メール（`git/config` の `includeIf` で読む） |
| `~/.zshrc.local` | トークンなどの環境変数 |
| `<dir>/mise.toml` | そのディレクトリだけで使うツール |

`~/.gitconfig` は触らない。

## mise

- `config.toml`: 最小構成
- `config.plus.toml`: 追加分。`MISE_ENV=plus mise install` で最小構成に重ねて入る。`colima` / `lima` は `os = ["macos"]` で mac 限定

## Rust の target/ が重いとき

- `cargo/config.toml` で dev ビルドのデバッグ情報を行番号のみに減らしている（サイズの大半を占めるため）。
- 古いビルド成果物は `cargo sweep --recursive --time 30 <path>` で消せる（path 省略で今のディレクトリ。plus の `cargo-sweep`）。例: `cargo sweep -r -t 30 .` / `cargo sweep -r -t 30 ~/dev`
- sccache は外した。キャッシュが別に数 GB 増えるうえ、incremental ビルドと相性が悪く、target/ のサイズも減らないため。

## 自動アップデート

毎日 12:00 に `scripts/mise-upgrade.sh`（`mise upgrade`、plus 込み、prune はしない）が走る。ログは mac が `~/Library/Logs/mise-upgrade.log`、Linux は `journalctl --user -u mise-upgrade`。

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
