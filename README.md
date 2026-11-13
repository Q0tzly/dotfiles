# dotfiles

English | [日本語](README.ja.md)

Configuration for macOS / Linux (zsh / Ghostty / helix / starship / mise).

## Setup

One command, as long as you have network access: clone → symlink → install tools with mise.

```sh
curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash
# Also enable tool groups
curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash -s -- --groups lang,ai
# All groups
curl -fsSL https://raw.githubusercontent.com/Q0tzly/dotfiles/main/install.sh | bash -s -- --all
```

- Clone destination: `~/dev/github.com/q0tzly/dotfiles` (override with `DOTFILES=`)
- Existing files are moved aside to `*.bak.<timestamp>` before symlinking
- `--link-only`: only create the symlinks, do not install mise
- `--subcon`: also clone [subcon](https://github.com/Q0tzly/subcon) (override with `SUBCON=`) and run its `install.sh`, which puts `subcon` on PATH and, if Muse is present, installs its skill
- Ghostty itself is not installed
- Prerequisites: `curl` and `git` (on macOS: `xcode-select --install`), and `zsh`. On Linux, a C compiler (e.g. `build-essential`) is also needed for `cargo:`-based tools (the `rust-tools` and `hw` groups)
- Linux is verified on Ubuntu 24.04 (aarch64) containers for `install.sh` and `system/mise-upgrade.sh`. The systemd timer is not yet verified

## Layout

Only five top-level entries: `config/` (configuration linked into `~/.config` and similar), `shell/` (the shell), `ai/` (agent instructions), `system/` (OS service definitions and their scripts), and `.githooks/` (hooks for this repository itself).

| path | linked to |
| --- | --- |
| `shell/zshrc` | `~/.zshrc` (loader only; the real content is in the same `shell/`) |
| `shell/bashrc` | `~/.bashrc` (loader only; the real content is in the same `shell/`) |
| `shell/base.sh` | Not linked. The shared base both loaders read (PATH, mise, tokens; no decoration) |
| `shell/human.sh` | Not linked. Read by both loaders only in the human profile (aliases etc.) |
| `shell/secrets.sh` | Not linked. The API-key loader that base reads. The values themselves live outside the repo, in `~/.config/secrets/` (see below) |
| `config/git/config` | `~/.config/git/config` |
| `config/git/ignore` | `~/.config/git/ignore`. A global ignore that applies to every repo (keeps `.env` files and key files from being added by accident) |
| `config/git/hooks/` | `~/.config/git/hooks`. Applies to every repo via `core.hooksPath` in `config/git/config` (enforces the attribution trailer) |
| `config/ghostty/config.ghostty` | macOS: `~/Library/Application Support/com.mitchellh.ghostty/`, Linux: `~/.config/ghostty/` |
| `config/helix/` | `~/.config/helix/` |
| `config/starship/starship.toml` | `~/.config/starship.toml` |
| `config/cargo/config.toml` | `~/.cargo/config.toml` |
| `ai/AGENTS.md` | `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/AGENTS.md` (Muse) |
| `config/mise/config.toml` | `~/.config/mise/conf.d/base.toml` (the base; `~/.config/mise/config.toml` is machine-local and untracked) |
| `.githooks/` | Not linked. Hooks for this repo itself, enabled via `core.hooksPath`. Guards base files against accidental commits |
| `config/mise/groups/` | `~/.config/mise/groups` (where group definitions live). Enabling is done by `mise-group`, a separate repo, which links definitions into `~/.config/mise/conf.d/` |
| `system/launchd/` `system/systemd/` `system/mise-upgrade.sh` | Enabled manually (see below) |

## The dotfiles command

install.sh links the `dotfiles` script at the repo root into `~/.local/bin/dotfiles`. It reports and updates the state of this repo itself.

```sh
dotfiles status   # commit, upstream state, local changes, dangling links
dotfiles check    # exit 0 when up to date, exit 1 when an update exists (for scripts)
dotfiles update   # pull (fast-forward only) → re-link → mise upgrade
dotfiles update --no-upgrade   # pull and re-link only
dotfiles update -f   # --force: ignore mise's minimum_release_age (the 24h post-release hold) for this run only
dotfiles update --auto         # for timers: quietly give up when it cannot proceed safely
```

Safety rules for `update`:

- Anything other than a fast-forward (a diverge) is reported, never touched
- If a locally modified file also changed upstream, it stops and names the file (unrelated local changes are left as they are)
- Re-linking goes through `install.sh --link-only`, so anything replaced is backed up to `.bak`

## Shell profiles

Both loaders (`zsh` / `bash`) read the shared base (`shell/base.sh`) first, then decide by profile whether to add the human layer.

- Default (human): base + starship, zoxide, completions, and the aliases in `shell/human.sh`
- `DOTFILES_PROFILE=ai`: base only. No prompt decoration and no meaning-changing aliases, so agents and scripts get the same minimal, deterministic environment

## Work and machine-specific settings

These do not go in the repository; put them in the following files (absent files are ignored).

| file | purpose |
| --- | --- |
| `~/.config/git/work` | Name and email used under `grus-systems/` (read via `includeIf` in `config/git/config`) |
| `~/.zshrc.local` / `~/.bashrc.local` | Machine-specific settings (environment variables etc.; for API keys, use the store below) |
| `<dir>/mise.toml` | Tools used only in that directory |

`~/.gitconfig` is never touched.

## API keys and secrets

Secret values are never stored in this (public) repository. They are aggregated in one directory outside the repo, under a convention shared by every machine.

- Location: `~/.config/secrets/` (directory mode 700, override with `SECRETS_DIR`). install.sh creates it empty
- Format: one key per file (mode 600, the raw value and nothing else), named after the service (`sakura`, `gemini`, ...)
- Reading: base sources `shell/secrets.sh`; `secret <name>` prints a value. To expose a key as an environment variable, write `secret_export SAKURA_API_KEY sakura` in `~/.config/secrets/env.sh` (mode 600) — env.sh holds no copy of the value itself
- Adding: just `umask 077; cat > ~/.config/secrets/<name>` and paste. Effective from the next shell
- Not here: credentials that tools manage themselves (gh / claude / agy OAuth, `~/.kaggle/access_token`, SSH keys, ...) stay where their tool puts them. This store is only for loose API keys
- Three layers against leaks: (1) the values live outside the repo, so even `git add -A` cannot pick them up; (2) this repo's `.gitignore` and the global ignore (`config/git/ignore`) ignore accidental drops; (3) `.githooks/pre-commit` refuses to commit secret-looking files, with no bypass

## Coding agents

The global instructions for Claude Code, Codex, and Muse are a single file, `ai/AGENTS.md` (formerly the for-AI repository), linked to each tool's location (`~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and Muse's `~/AGENTS.md`).

- Codex cannot expand `@path` imports, so this file must be self-contained and read nothing else
- `~/.claude/settings.json` and `~/.claude/skills/` are not linked: the settings contain machine state, and plugins write into skills on their own
- Delegating implementation to Gemini Flash is a separate repository, [subcon](https://github.com/Q0tzly/subcon). Run `subcon guide` for its workflow

## mise

- `config/mise/config.toml`: core, the minimal set that is always installed. Linked to `conf.d/base.toml`. The file `mise use -g` writes to, `~/.config/mise/config.toml`, is machine-local (untracked), so adding a tool never dirties the base
- Base files (`shell/base.sh`, `config/mise/config.toml`, the rc loaders) are guarded by `.githooks/pre-commit` against accidental commits. Intentional edits go through with `ALLOW_BASE=1 git commit ...`
- `config/mise/groups/<name>.toml`: extra tools by genre, enabled and disabled with `mise-group`
- `mise-group` itself is a separate project, [mise-group](https://github.com/Q0tzly/mise-group) (split out on 2026-11-13, a Go binary). This repository keeps only the group definitions; the tool itself is installed by mise as one of the base tools (`"github:Q0tzly/mise-group"`). Only for the first bootstrap does install.sh borrow it via `mise exec` (`--no-mise-group` disables that borrowing)

```sh
mise-group list                  # list groups ([x] = enabled)
mise-group enable lang ai        # enable and install
mise-group disable lang          # disable, and remove only that group's tools
```

- Which groups are enabled is determined by the symlinks in `~/.config/mise/conf.d/<name>.toml` (pointing at the group definitions), so each machine can choose its own combination
- `disable` never removes a tool that another enabled configuration also lists. `mise prune` is not used
- Groups: `lang` `rust-tools` `ai` `cloud` `container` (colima/lima are mac-only) `hw` `wasm` `media` `misc` `compute` (access to borrowed compute, e.g. the Colab CLI)
- `hw` is for GrusArch. Versions are pinned to verified ones and do not move on automatic upgrades (bump them by hand). Things mise cannot reproduce or that are too large (oss-cad-suite, the xPack RISC-V GCC, LibreLane, the fusesoc venv, sky130, KLayout.app) are installed manually under `~/.local/opt` etc.; their versions are noted at the top of `hw.toml`

## When Rust target/ gets heavy

- `config/cargo/config.toml` reduces dev-build debug info to line numbers only (it accounts for most of the size)
- Old build artifacts can be removed with `cargo sweep --recursive --time 30 <path>` (omit the path for the current directory; `cargo-sweep` is in the `rust-tools` group). Examples: `cargo sweep -r -t 30 .` / `cargo sweep -r -t 30 ~/dev`
- sccache was dropped: it adds several GB of cache of its own, interacts badly with incremental builds, and does not shrink target/ either

## Automatic updates

Every day at 12:00, `dotfiles update --auto` runs (pull + re-link + `mise upgrade`, never prune). The templates (`system/launchd/` and `system/systemd/`; the unit names keep "mise-upgrade" for compatibility) point here from the start. When it cannot proceed safely (a conflicting local change, a diverge, offline), it leaves everything untouched. Logs: on macOS, `~/Library/Logs/dotfiles-update.log`; on Linux, `journalctl --user -u mise-upgrade`.

To upgrade only the tools, run `system/mise-upgrade.sh` directly (it still works standalone, as before).

macOS (launchd):

```sh
ln -sf "$PWD/system/launchd/dev.q0tzly.mise-upgrade.plist" ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/dev.q0tzly.mise-upgrade.plist
launchctl kickstart gui/$(id -u)/dev.q0tzly.mise-upgrade   # run manually
```

Linux (systemd user):

```sh
mkdir -p ~/.config/systemd/user
ln -sf "$PWD"/system/systemd/mise-upgrade.{service,timer} ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now mise-upgrade.timer
systemctl --user start mise-upgrade.service   # run manually
```

No secrets (tokens etc.) are stored in this repository.

## License

Apache License 2.0 (see [LICENSE](LICENSE)).
