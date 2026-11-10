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
| `mise/` | `~/.config/mise/` |
| `launchd/` | 手動で有効化（下記） |

`~/.gitconfig` は触らない。マシン固有の設定（仕事用の `includeIf` など）はそちらに置く。

## mise

- `config.toml`: 最小構成
- `config.plus.toml`: 追加分。`MISE_ENV=plus mise install` で最小構成に重ねて入る

## 自動アップデート (launchd)

毎日 12:00 に `mise upgrade`（plus 込み。prune はしない）が走る。

```sh
ln -sf "$PWD/launchd/dev.q0tzly.mise-upgrade.plist" ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.q0tzly.mise-upgrade.plist
launchctl kickstart gui/$(id -u)/dev.q0tzly.mise-upgrade   # 手動実行
```

ログ: `~/Library/Logs/mise-upgrade.log`

秘密情報（トークン等）は置かない。
