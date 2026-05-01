<!-- markdownlint-disable MD033 MD041 -->

```text
       ▄▄  ▄▄  ▄▄  ▄▄
      ┌──────────────┐            █████ █████ █████ █     ████  █████ █   █
      │  ◎        ◎  │              █   █   █ █   █ █     █   █ █   █  █ █
      │              │              █   █   █ █   █ █     ████  █   █   █
      └──┬────────┬──┘              █   █   █ █   █ █     █   █ █   █  █ █
      ┌──┴────────┴──┐              █   █████ █████ █████ ████  █████ █   █
   ⬤──┤ ↞  ✦   ✧  ↠ ├──⬤
      │ ↝  ✦   ✧  ↜  │            ━━━━━━━━ DEVTOOLS BOOTSTRAP ━━━━━━━━
      │ ↞  ✦   ✧  ↠  │            Homebrew · iTerm2 · VS Code · Oh My Zsh
      └──────────────┘            · plus the rest. one script, one menu,
                                  one report. MIT · macOS · No telemetry.
```

<p align="center">
  <img alt="platform"  src="https://img.shields.io/badge/platform-macOS-00cc66.svg?style=flat-square&labelColor=0a0a0a">
  <img alt="shell"     src="https://img.shields.io/badge/shell-bash-00cc66.svg?style=flat-square&labelColor=0a0a0a">
  <img alt="license"   src="https://img.shields.io/badge/license-MIT-00cc66.svg?style=flat-square&labelColor=0a0a0a">
  <img alt="idempotent" src="https://img.shields.io/badge/idempotent-yes-00cc66.svg?style=flat-square&labelColor=0a0a0a">
  <img alt="telemetry" src="https://img.shields.io/badge/telemetry-none-00cc66.svg?style=flat-square&labelColor=0a0a0a">
</p>

> **ToolBox** is a tiny guided bootstrap for a fresh macOS dev machine. Installs **iTerm2, VS Code, Oh My Zsh, Homebrew**, and a curated set of CLI / language / cloud / DB / productivity tools. One script. One interactive menu. One summary report. No account. No telemetry. Local only.

> **Status:** v1 — two flavors shipped (clean + retro DOS).

---

## ░▒▓█ TL;DR

```bash
bash install-devtools.sh
```

Pick from the menu. Re-runs are safe — already-installed tools are skipped.

---

## ░▒▓█ What it does

ToolBox wraps Homebrew + a few official curl-installers (Oh My Zsh, nvm, rustup) behind one interactive menu. It produces:

- **One install run** — preflight (Xcode CLT, Homebrew), then the categories you pick
- **One status line per tool** — `[ OK ]` installed / `[SKIP]` already present / `[FAIL]` failed
- **One summary at the end** — installed / skipped / failed counts + post-boot todos
- **Exit `0` clean, `1` if any tool failed**

ToolBox does not ship its own package manager. Every install delegates to `brew`, `curl|sh`, or the tool's official installer. The value is **curation, idempotency, and a single guided flow.**

---

## ░▒▓█ What gets installed

| Category              | Tools                                                                          |
|-----------------------|--------------------------------------------------------------------------------|
| **Required**          | iTerm2, Visual Studio Code, Oh My Zsh                                          |
| **Shell + prompt**    | starship, zsh-autosuggestions, zsh-syntax-highlighting, powerlevel10k          |
| **Core CLI**          | git, gh, jq, ripgrep, fd, fzf, bat, eza, tree, wget, htop, tmux                |
| **Languages**         | nvm (node), pyenv (python), go, rustup                                         |
| **Containers / cloud**| Docker Desktop, kubectl, awscli, terraform                                     |
| **Database clients**  | TablePlus, DBeaver, redis, postgresql@16                                       |
| **API / HTTP**        | httpie, Postman, Insomnia                                                      |
| **Productivity**      | Rectangle, Raycast, 1Password, 1Password CLI, Slack, Notion                    |
| **Editors / extras**  | neovim, Cursor                                                                 |

Missing prerequisites (Xcode CLT, Homebrew) are **installed automatically** during preflight. Single-tool failures don't abort the run; they're collected and listed in the final summary.

---

## ░▒▓█ Two flavors

| Script                     | Vibe                                                                |
|----------------------------|---------------------------------------------------------------------|
| `install-devtools.sh`      | Clean. Modern terminal. Colored bullets, simple sections.           |
| `install-devtools-dos.sh`  | Retro 1987 DOS. ASCII banner, `C:\TDF\DEVTOOLS>` prompt, beeps, box-drawing menus. Same install logic. |

Both scripts share install logic — pick whichever vibe fits the day.

---

## ░▒▓█ Menu

```
╔══════════════════════════════════════════════════════════════════╗
║                    ::  M A I N   M E N U  ::                    ║
╠══════════════════════════════════════════════════════════════════╣
║  [1]  FULL INSTALL         (everything, recommended for new HD) ║
║  [2]  MINIMAL INSTALL       (iTerm2 + VS Code + Oh My Zsh)      ║
║  [3]  CUSTOM INSTALL        (pick modules one by one)           ║
║  [4]  ABORT                 (exit to DOS)                       ║
╚══════════════════════════════════════════════════════════════════╝
```

| Choice | Behavior                                                           |
|:------:|--------------------------------------------------------------------|
| `1`    | Install everything from every category                             |
| `2`    | Install required only (iTerm2 + VS Code + Oh My Zsh)               |
| `3`    | Install required, then prompt y/N for each remaining category      |
| `4`    | Quit                                                               |

---

## ░▒▓█ Install

### One-shot

```bash
git clone https://github.com/tinydarkforge/ToolBox.git
cd ToolBox
bash install-devtools.sh           # clean
bash install-devtools-dos.sh       # retro DOS
```

### Curl-pipe (after publishing)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/tinydarkforge/ToolBox/main/install-devtools.sh)
```

---

## ░▒▓█ Usage

```bash
# Run, pick from menu
bash install-devtools.sh

# Re-run later — every previously installed tool is skipped
bash install-devtools.sh

# Add a single category to an existing setup → menu option 3, only say Y to that category
```

**Exit codes**

| Code | Meaning                                            |
|:----:|----------------------------------------------------|
| `0`  | All requested tools installed or already present   |
| `1`  | One or more tools failed (listed in the summary)   |

---

## ░▒▓█ Idempotency

Re-running is the **expected** workflow.

- `brew_install` checks `brew list --formula --versions` before installing.
- `brew_cask_install` checks `brew list --cask --versions`.
- Oh My Zsh skips if `~/.oh-my-zsh` exists.
- nvm skips if `~/.nvm` exists.
- rustup skips if `rustup` is on `$PATH`.

Every check prints `[SKIP]` and moves on. No tool is ever reinstalled.

---

## ░▒▓█ Design notes

- **Bash, not zsh** — Oh My Zsh installer is `sh`-compatible, no reason to require zsh at install time.
- **Homebrew over MAS / direct downloads** — one package manager, real uninstall path, version pinning later.
- **No `--force` reinstalls** — idempotent skip beats silent overwrite.
- **Docker Desktop = cask** — "just works" for solo founders. Note: commercial license applies for orgs >250 employees or >$10M revenue.
- **nvm via official installer, not brew** — Homebrew's nvm formula is not officially supported by nvm maintainers.
- **No `chsh`** — macOS defaults to zsh since Catalina. Oh My Zsh detects.

---

## ░▒▓█ Out of scope

ToolBox installs binaries. It does **not**:

- Manage dotfiles (use `chezmoi`, `stow`, or your repo)
- Tweak macOS defaults (`defaults write ...`)
- Generate SSH / GPG keys
- Authenticate with GitHub (`gh auth login` is post-install)
- Install fonts, themes, or VS Code extensions

Each of those belongs in a separate, focused script.

---

## ░▒▓█ License

MIT. See `LICENSE`.

---

## ░▒▓█ Forge

Part of the [TinyDarkForge](https://github.com/tinydarkforge) toolset. Small, sharp, no telemetry, no account.
