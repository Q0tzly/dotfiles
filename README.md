# dotfiles

macOS (zsh / Ghostty / helix / starship / mise) の設定。

| path | 配置先 |
| --- | --- |
| `zsh/zshrc` | `~/.zshrc` |
| `git/gitconfig` | `~/.gitconfig` |
| `ghostty/config.ghostty` | `~/Library/Application Support/com.mitchellh.ghostty/` |
| `helix/` | `~/.config/helix/` |
| `starship.toml` | `~/.config/starship.toml` |
| `zed/settings.json` | `~/.config/zed/settings.json` |
| `mise/` | `~/.config/mise/` |

## mise

- `config.toml`: 最小構成
- `config.plus.toml`: 追加分。`MISE_ENV=plus mise install` で最小構成に重ねて入る

秘密情報（トークン等）は置かない。
