# dotfiles

[English](README.md) | 日本語

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
- `--subcon`: [subcon](https://github.com/Q0tzly/subcon) も clone（`SUBCON=` で変更可）して、その `install.sh` を実行する。`subcon` を PATH に、Muse が入っていればそのスキルも入れる
- Ghostty 本体は入れない
- 前提: `curl` と `git`（macOS は `xcode-select --install`）、`zsh`。Linux で `cargo:` 系（`rust-tools` や `hw` グループ）を入れるなら C コンパイラ（例: `build-essential`）も要る
- Linux は Ubuntu 24.04 (aarch64) のコンテナで `install.sh` と `system/mise-upgrade.sh` を確認済み。systemd の timer は未確認

## 構成

トップレベルは5つだけ：`config/`（`~/.config` 等へリンクする設定）、`shell/`（シェル）、`ai/`（エージェント指示）、`system/`（OS のサービス定義とそのスクリプト）、`.githooks/`（このリポジトリ自身のフック）。

| path | リンク先 |
| --- | --- |
| `shell/zshrc` | `~/.zshrc`（ローダーのみ。本体は同じ `shell/`） |
| `shell/bashrc` | `~/.bashrc`（ローダーのみ。本体は同じ `shell/`） |
| `shell/base.sh` | リンクしない。両ローダーが読む共通 base（PATH・mise・トークン。装飾なし） |
| `shell/human.sh` | リンクしない。人間用プロファイルのときだけ両ローダーが読む（alias 等） |
| `shell/secrets.sh` | リンクしない。base が読む API キーのローダー。本体（値）は repo 外の `~/.config/secrets/`（下記） |
| `config/git/config` | `~/.config/git/config` |
| `config/git/ignore` | `~/.config/git/ignore`。全 repo に効くグローバル ignore（`.env` や鍵ファイルの誤混入防止） |
| `config/git/hooks/` | `~/.config/git/hooks`。`config/git/config` の `core.hooksPath` で全 repo に効く（帰属トレーラの強制） |
| `config/ghostty/config.ghostty` | macOS: `~/Library/Application Support/com.mitchellh.ghostty/`、Linux: `~/.config/ghostty/` |
| `config/helix/` | `~/.config/helix/` |
| `config/starship/starship.toml` | `~/.config/starship.toml` |
| `config/cargo/config.toml` | `~/.cargo/config.toml` |
| `ai/AGENTS.md` | `~/.claude/CLAUDE.md`、`~/.codex/AGENTS.md`、`~/AGENTS.md`（Muse） |
| `config/mise/config.toml` | `~/.config/mise/conf.d/base.toml`（base。`~/.config/mise/config.toml` はマシンローカルで追跡しない） |
| `.githooks/` | リンクしない。この repo 自身のフック。`core.hooksPath` で有効化。base ファイルの誤コミット防止 |
| `config/mise/groups/` | `~/.config/mise/groups`（定義置き場）。有効化は別 repo の `mise-group` が `~/.config/mise/conf.d/` へリンク |
| `system/launchd/` `system/systemd/` `system/mise-upgrade.sh` | 手動で有効化（下記） |

## dotfiles コマンド

install.sh が repo 直下の `dotfiles` を `~/.local/bin/dotfiles` にリンクする。この repo 自身の状態確認と更新用コマンド。

```sh
dotfiles status   # コミット、上流との差分、ローカル変更、ぶら下がりリンクの有無
dotfiles check    # 最新なら exit 0、更新があれば exit 1（スクリプト用）
dotfiles update   # pull（fast-forward のみ）→ 再リンク → mise upgrade
dotfiles update --no-upgrade   # pull と再リンクだけ
dotfiles update -f   # --force。今回だけ mise の minimum_release_age（リリース後24時間の保留）を無視して最新を取る
dotfiles update --auto         # タイマー用。安全に進められないときは静かに諦める
```

`update` の安全規則：

- fast-forward 以外（diverge）は手出しせず報告だけ
- ローカルで変更中のファイルが上流でも変わっていたら、止めてファイル名を出す（関係ない変更はそのまま残して進む）
- 再リンクは `install.sh --link-only` 経由なので、置き換わるものは `.bak` に退避される

## シェルのプロファイル

`zsh` / `bash` どちらのローダーも、共通 base（`shell/base.sh`）を読んでから、プロファイルで人間用レイヤーを足すかどうかを決める。

- 既定（human）: base + starship・zoxide・補完・`shell/human.sh` の alias
- `DOTFILES_PROFILE=ai`: base のみ。プロンプト装飾や意味の変わる alias を入れず、エージェントやスクリプトでも決定的に動く最小構成にする

## 仕事用・マシン固有の設定

リポジトリに入れず、次のファイルに置く（無ければ無視される）。

| ファイル | 用途 |
| --- | --- |
| `~/.config/git/work` | `grus-systems/` 配下で使う名前・メール（`config/git/config` の `includeIf` で読む） |
| `~/.zshrc.local` / `~/.bashrc.local` | マシン固有の設定（環境変数など。API キーは下記の集約先へ） |
| `<dir>/mise.toml` | そのディレクトリだけで使うツール |

`~/.gitconfig` は触らない。

## API キー・秘密情報の集約

値はこの repo（public）の中には絶対に置かない。集約先は repo の外の 1 ディレクトリで、全マシン共通の規約にする。

- 置き場: `~/.config/secrets/`（ディレクトリ 700、`SECRETS_DIR` で変更可）。`install.sh` が空で作る
- 形式: 1 キー = 1 ファイル（600、値は生の文字列だけ）。ファイル名はサービス名（`sakura`、`gemini` など）
- 読み方: `shell/secrets.sh` を base が読み、`secret <名前>` で値が取れる。環境変数にしたいものは `~/.config/secrets/env.sh`（600）に `secret_export SAKURA_API_KEY sakura` のように書く（値のコピーは env.sh に持たない）
- 追加: `umask 077; cat > ~/.config/secrets/<名前>` で貼って保存するだけ。新しいシェルから有効
- 入れないもの: ツール自身が管理する認証情報（gh / claude / agy の OAuth、`~/.kaggle/access_token`、SSH 鍵など）は各ツールの置き場のままにする。ここはバラの API キー専用
- 漏洩防止は三重: ①値が repo の外にある（`git add -A` でも入らない）②repo の `.gitignore` とグローバル ignore（`config/git/ignore`）で誤混入を無視 ③`.githooks/pre-commit` が秘密らしきファイルのコミットを（バイパスなしで）拒否

## コーディングエージェント

Claude Code・Codex・Muse のグローバル指示は `ai/AGENTS.md` の 1 ファイルで共通（旧 for-AI リポジトリ）。各ツールの読む場所（`~/.claude/CLAUDE.md`、`~/.codex/AGENTS.md`、Muse の `~/AGENTS.md`）へリンクする。

- Codex は `@パス` の読み込みに対応していないので、このファイルは他を読み込まずに完結させる
- `~/.claude/settings.json` と `~/.claude/skills/` はリンクしない。設定はマシンの状態を含み、skills にはプラグインが自動で書き込むため
- 実装を Gemini Flash に委任する仕組みは別リポジトリの [subcon](https://github.com/Q0tzly/subcon)。手順は `subcon guide` で読む

## mise

- `config/mise/config.toml`: core。常に入る最小構成。`conf.d/base.toml` にリンクされる。`mise use -g` の書き込み先 `~/.config/mise/config.toml` はマシンローカル（追跡しない）ので、ツールを足しても base は汚れない
- base ファイル（`shell/base.sh`、`config/mise/config.toml`、rc ローダー）は `.githooks/pre-commit` が誤コミットを止める。意図的な編集は `ALLOW_BASE=1 git commit ...` で通す
- `config/mise/groups/<名前>.toml`: ジャンルごとの追加ツール。`mise-group` で入れたり消したりする
- `mise-group` 本体は別プロジェクト [mise-group](https://github.com/Q0tzly/mise-group)（2026-11-13 に分離、Go 製バイナリ）。このリポジトリにはグループ定義だけを置き、本体は base ツールとして mise 自身が入れる（`"github:Q0tzly/mise-group"`）。初回構築時だけ、install.sh が `mise exec` で先行して借りてくる（`--no-mise-group` でその借用を無効化）

```sh
mise-group list                  # 一覧（[x] が有効）
mise-group enable lang ai        # 有効化してインストール
mise-group disable lang          # 無効化して、そのグループのツールだけ削除
```

- 有効なグループは `~/.config/mise/conf.d/<名前>.toml`（グループ定義への symlink）の有無で決まる。マシンごとに組み合わせを変えられる。
- `disable` は、他の有効な設定にも載っているツールは消さない。`mise prune` は使わない。
- グループ: `lang` `rust-tools` `ai` `cloud` `container`（colima/lima は mac 限定） `hw` `wasm` `media` `misc` `compute`（Colab CLI など、借り物の計算資源へのアクセス用）
- `hw` は GrusArch 向け。動作確認済みの版に固定してあり、自動アップデートでは変わらない（上げるときは手で）。mise で再現できない・大きすぎるもの（oss-cad-suite、xPack の RISC-V GCC、LibreLane、fusesoc の venv、sky130、KLayout.app）は `~/.local/opt` などに手動で入れたままで、版は `hw.toml` の冒頭に書いてある。

## Rust の target/ が重いとき

- `config/cargo/config.toml` で dev ビルドのデバッグ情報を行番号のみに減らしている（サイズの大半を占めるため）。
- 古いビルド成果物は `cargo sweep --recursive --time 30 <path>` で消せる（path 省略で今のディレクトリ。`rust-tools` グループの `cargo-sweep`）。例: `cargo sweep -r -t 30 .` / `cargo sweep -r -t 30 ~/dev`
- sccache は外した。キャッシュが別に数 GB 増えるうえ、incremental ビルドと相性が悪く、target/ のサイズも減らないため。

## 自動アップデート

毎日 12:00 に `dotfiles update --auto`（pull + 再リンク + `mise upgrade`、prune はしない）が走る。テンプレート（`system/launchd/` と `system/systemd/`、ユニット名は互換のため mise-upgrade のまま）は最初からこちらを指している。安全に進められない状態（ローカル変更と競合、diverge、オフライン）では何も触らずに終わる。ログは mac が `~/Library/Logs/dotfiles-update.log`、Linux は `journalctl --user -u mise-upgrade`。

ツールだけ上げたいときは `system/mise-upgrade.sh` を直接叩く（従来どおり単体でも動く）。

macOS (launchd):

```sh
ln -sf "$PWD/system/launchd/dev.q0tzly.mise-upgrade.plist" ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.q0tzly.mise-upgrade.plist
launchctl kickstart gui/$(id -u)/dev.q0tzly.mise-upgrade   # 手動実行
```

Linux (systemd user):

```sh
mkdir -p ~/.config/systemd/user
ln -sf "$PWD"/system/systemd/mise-upgrade.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now mise-upgrade.timer
systemctl --user start mise-upgrade.service   # 手動実行
```

秘密情報（トークン等）は置かない。

## ライセンス

Apache License 2.0（[LICENSE](LICENSE) 参照）。
