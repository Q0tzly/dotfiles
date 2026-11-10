# dotfiles

macOS (zsh / Ghostty / helix / starship / mise) の設定。

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

## 構成

| path | リンク先 |
| --- | --- |
| `zsh/zshrc` | `~/.zshrc` |
| `git/config` | `~/.config/git/config` |
| `ghostty/config.ghostty` | `~/Library/Application Support/com.mitchellh.ghostty/` |
| `helix/` | `~/.config/helix/` |
| `starship/starship.toml` | `~/.config/starship.toml` |
| `cargo/config.toml` | `~/.cargo/config.toml` |
| `mise/` | `~/.config/mise/` |
| `launchd/` | 手動で有効化（下記） |

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
- `config.plus.toml`: 追加分。`MISE_ENV=plus mise install` で最小構成に重ねて入る

## Rust の target/ が重いとき

- `cargo/config.toml` で dev ビルドのデバッグ情報を行番号のみに減らしている（サイズの大半を占めるため）。
- 古いビルド成果物は `cargo sweep --recursive --time 30 ~/dev` で消せる（plus に `cargo-sweep` あり）。
- sccache は外した。キャッシュが別に数 GB 増えるうえ、incremental ビルドと相性が悪く、target/ のサイズも減らないため。

## 自動アップデート (launchd)

毎日 12:00 に `mise upgrade`（plus 込み。prune はしない）が走る。

```sh
ln -sf "$PWD/launchd/dev.q0tzly.mise-upgrade.plist" ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.q0tzly.mise-upgrade.plist
launchctl kickstart gui/$(id -u)/dev.q0tzly.mise-upgrade   # 手動実行
```

ログ: `~/Library/Logs/mise-upgrade.log`

秘密情報（トークン等）は置かない。
