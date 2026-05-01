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

> **Status:** v1 — single retro DOS-vibe installer with arrow-key menu, 8-bit sound feedback, and TinyDarkForge Forge integration (SecGate + Intake).

---

## ░▒▓█ TL;DR

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/tinydarkforge/ToolBox/main/install-devtools.sh)
```

Or clone first:

```bash
git clone https://github.com/tinydarkforge/ToolBox.git && cd ToolBox && bash install-devtools.sh
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
| **TDF Forge**         | [SecGate](https://github.com/tinydarkforge/SecGate) (`@tinydarkforge/secgate`), [Intake](https://github.com/tinydarkforge/Intake) (curl-pipe installer) |

Missing prerequisites (Xcode CLT, Homebrew) are **installed automatically** during preflight. Single-tool failures don't abort the run; they're collected and listed in the final summary.

> **Note on TDF Forge:** SecGate requires `npm` (load the **Languages** module first if starting fresh). Intake's installer pulls Ollama + a ~5GB AI model and prompts you to log in to GitHub — the script asks before running it.

---

## ░▒▓█ Menu

Arrow-key driven (↑/↓ + Enter). Number keys `1`-`5` work as direct shortcuts. **Q** or **Ctrl+C** exits.

```
╔══════════════════════════════════════════════════════════════════╗
║              ::  M A I N   M E N U  —  ↑↓ ENTER  ::             ║
╠══════════════════════════════════════════════════════════════════╣
║ ▶ [1]  FULL INSTALL          (everything, recommended for new HD)║
║   [2]  MINIMAL INSTALL       (iTerm2 + VS Code + Oh My Zsh)      ║
║   [3]  CUSTOM INSTALL        (pick modules one by one)           ║
║   [4]  SECGATE               (npm i -g @tinydarkforge/secgate)   ║
║   [5]  INTAKE                (Ollama + intake + ~5GB AI model)   ║
╚══════════════════════════════════════════════════════════════════╝
   Use ↑/↓ to move, ENTER to select, 1-5 for direct, Q to quit, Ctrl+C to abort.
```

| Choice | Behavior                                                           |
|:------:|--------------------------------------------------------------------|
| `1`    | Install everything (every category + SecGate + Intake)             |
| `2`    | Install required only (iTerm2 + VS Code + Oh My Zsh)               |
| `3`    | Install required, then prompt y/N for each remaining category      |
| `4`    | Install **SecGate** only (`@tinydarkforge/secgate` via npm)        |
| `5`    | Install **Intake** only (Ollama + binary + AI model, ~5GB)         |
| `Q` / `Ctrl+C` | Exit                                                       |

### Arrow nav vs numbered menu

The numbered menu is the default and works on any macOS out of the box. Arrow nav requires bash 4+. macOS ships bash 3.2, so on a fresh machine you'll see the numbered prompt — that's expected and fine.

If you happen to already have a newer bash at `/opt/homebrew/bin/bash` or `/usr/local/bin/bash` (Apple Silicon / Intel), the script detects it and re-execs itself under that bash so arrow nav lights up. Passive — no install, no PATH changes, no surprises.

Non-TTY stdin (CI, piped input) also routes to the numbered fallback.

---

## ░▒▓█ Sounds

8-bit-ish sound feedback at 50% volume. macOS only (uses `afplay`).

| Event       | Default sound (system)                       | Override        |
|-------------|----------------------------------------------|-----------------|
| Boot        | `Hero.aiff`                                  | `assets/sounds/boot.wav` |
| Menu nav    | `Tink.aiff`                                  | `assets/sounds/nav.wav` |
| Select      | `Pop.aiff`                                   | `assets/sounds/select.wav` |
| Tool OK     | `Morse.aiff`                                 | `assets/sounds/ok.wav` |
| Tool FAIL   | `Funk.aiff`                                  | `assets/sounds/fail.wav` |
| All done    | `Glass.aiff`                                 | `assets/sounds/done.wav` |

Drop real chiptune `.wav` files in `assets/sounds/` (matching the names above) to override.

```bash
TDF_SOUND=0    bash install-devtools.sh   # disable sounds
TDF_SOUND_VOL=0.25 bash install-devtools.sh   # quieter (default 0.5)
TDF_SOUND_VOL=1.0  bash install-devtools.sh   # full volume
```

See `assets/sounds/README.md` for sources of free 8-bit WAVs.

---

## ░▒▓█ Install

Three ways to get it. Pick one. All three end with `bash install-devtools.sh`.

### 1. Curl-pipe (no clone, one-liner)

Fastest path on a fresh machine. Downloads + runs the script in one shot. Nothing left on disk afterward.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/tinydarkforge/ToolBox/main/install-devtools.sh)
```

> Audit it first if you don't trust random pipe-to-bash:
> ```bash
> curl -fsSL https://raw.githubusercontent.com/tinydarkforge/ToolBox/main/install-devtools.sh | less
> ```

### 2. Clone with git

Best if you want to re-run later, tweak, or pin a commit.

```bash
git clone https://github.com/tinydarkforge/ToolBox.git
cd ToolBox
bash install-devtools.sh
```

Update later:

```bash
cd ToolBox && git pull && bash install-devtools.sh
```

### 3. Download zip (no git required)

For a brand-new Mac without `git` yet (Xcode CLT not installed). The script auto-installs Xcode CLT on first run anyway, but the zip path lets you start before that.

```bash
curl -fsSL -o ToolBox.zip https://github.com/tinydarkforge/ToolBox/archive/refs/heads/main.zip
unzip ToolBox.zip
cd ToolBox-main
bash install-devtools.sh
```

Or grab the zip from the **Code → Download ZIP** button on [the GitHub repo](https://github.com/tinydarkforge/ToolBox).

### Requirements

- macOS (Apple Silicon or Intel)
- Internet connection
- Admin password (for Xcode CLT + Homebrew install during preflight)
- ~2-5 GB free disk (more if you pick Intake — pulls a ~5 GB AI model)

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
