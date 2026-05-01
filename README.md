# ToolBox

Personal macOS dev-machine bootstrap.

## install-devtools.sh

Guided installer for a fresh macOS dev environment. Idempotent — safe to re-run.

### Usage

```bash
bash install-devtools.sh
```

You'll get a menu:

1. **Install everything** — full kitchen-sink setup
2. **Required only** — iTerm2, VS Code, Oh My Zsh
3. **Pick categories** — required + interactive y/N per category
4. **Quit**

### What it installs (by category)

| Category | Tools |
|---|---|
| Required | iTerm2, Visual Studio Code, Oh My Zsh |
| Shell + prompt | starship, zsh-autosuggestions, zsh-syntax-highlighting, powerlevel10k |
| Core CLI | git, gh, jq, ripgrep, fd, fzf, bat, eza, tree, wget, htop, tmux |
| Languages | nvm (node), pyenv, go, rustup |
| Containers / cloud | Docker Desktop, kubectl, awscli, terraform |
| DB clients | TablePlus, DBeaver, redis, postgresql@16 |
| API / HTTP | httpie, Postman, Insomnia |
| Productivity | Rectangle, Raycast, 1Password, 1Password CLI, Slack, Notion |
| Editors / extras | neovim, Cursor |

### Notes

- Requires macOS. Installs Xcode CLT and Homebrew if missing.
- Single-tool failures don't abort the run — summary at the end lists installed / skipped / failed.
- Docker Desktop is the cask version. Commercial license rules apply for larger orgs.
- `nvm` uses the official curl installer (Homebrew's nvm formula is not officially supported by nvm maintainers).
