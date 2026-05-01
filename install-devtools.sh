#!/usr/bin/env bash
# install-devtools.sh — guided macOS dev environment bootstrap
# Idempotent. Safe to re-run.

set -uo pipefail

# ───────────────────────── colors ─────────────────────────
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  RED=$(tput setaf 1); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); BLUE=$(tput setaf 4); CYAN=$(tput setaf 6)
else
  BOLD=""; DIM=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; CYAN=""
fi

say()  { printf "%s\n" "$*"; }
info() { printf "${BLUE}ℹ${RESET}  %s\n" "$*"; }
ok()   { printf "${GREEN}✓${RESET}  %s\n" "$*"; }
skip() { printf "${DIM}↻  %s (already present)${RESET}\n" "$*"; }
warn() { printf "${YELLOW}!${RESET}  %s\n" "$*"; }
err()  { printf "${RED}✗${RESET}  %s\n" "$*" >&2; }
hdr()  { printf "\n${BOLD}${CYAN}== %s ==${RESET}\n" "$*"; }

# ──────────────────────── result tracking ─────────────────────
INSTALLED=()
SKIPPED=()
FAILED=()

record_installed() { INSTALLED+=("$1"); }
record_skipped()   { SKIPPED+=("$1"); }
record_failed()    { FAILED+=("$1"); }

# ─────────────────────────── preflight ────────────────────────
preflight() {
  hdr "Preflight"

  if [[ "$(uname)" != "Darwin" ]]; then
    err "macOS only. Detected: $(uname)"
    exit 1
  fi
  ok "macOS detected ($(sw_vers -productVersion))"

  if ! xcode-select -p >/dev/null 2>&1; then
    warn "Xcode Command Line Tools missing. Launching installer..."
    xcode-select --install || true
    say "Re-run this script after Xcode CLT finishes installing."
    exit 1
  fi
  ok "Xcode Command Line Tools present"

  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
      # Add brew to PATH for current session (Apple Silicon vs Intel)
      if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
      fi
      ok "Homebrew installed"
    else
      err "Homebrew install failed"
      exit 1
    fi
  else
    ok "Homebrew present ($(brew --version | head -n1))"
  fi

  info "Updating Homebrew..."
  brew update >/dev/null 2>&1 || warn "brew update had issues — continuing"
  ok "Homebrew up to date"
}

# ─────────────────────── install helpers ──────────────────────
brew_install() {
  local pkg="$1"
  if brew list --formula --versions "$pkg" >/dev/null 2>&1; then
    skip "$pkg"
    record_skipped "$pkg"
    return 0
  fi
  if brew install "$pkg" >/dev/null 2>&1; then
    ok "$pkg"
    record_installed "$pkg"
  else
    err "$pkg failed"
    record_failed "$pkg"
  fi
}

brew_cask_install() {
  local pkg="$1"
  if brew list --cask --versions "$pkg" >/dev/null 2>&1; then
    skip "$pkg (cask)"
    record_skipped "$pkg"
    return 0
  fi
  if brew install --cask "$pkg" >/dev/null 2>&1; then
    ok "$pkg (cask)"
    record_installed "$pkg"
  else
    err "$pkg (cask) failed"
    record_failed "$pkg"
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    skip "oh-my-zsh"
    record_skipped "oh-my-zsh"
    return 0
  fi
  info "Installing Oh My Zsh (unattended)..."
  if RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >/dev/null 2>&1; then
    ok "oh-my-zsh"
    record_installed "oh-my-zsh"
  else
    err "oh-my-zsh failed"
    record_failed "oh-my-zsh"
  fi
}

install_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    skip "nvm"
    record_skipped "nvm"
    return 0
  fi
  info "Installing nvm (official installer)..."
  if curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null 2>&1; then
    ok "nvm"
    record_installed "nvm"
  else
    err "nvm failed"
    record_failed "nvm"
  fi
}

install_rustup() {
  if command -v rustup >/dev/null 2>&1; then
    skip "rustup"
    record_skipped "rustup"
    return 0
  fi
  info "Installing rustup..."
  if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path >/dev/null 2>&1; then
    ok "rustup"
    record_installed "rustup"
  else
    err "rustup failed"
    record_failed "rustup"
  fi
}

# ─────────────────────── category installers ──────────────────
install_required() {
  hdr "Required: iTerm2, VS Code, Oh My Zsh"
  brew_cask_install iterm2
  brew_cask_install visual-studio-code
  install_oh_my_zsh
}

install_shell_prompt() {
  hdr "Shell + prompt"
  brew_install starship
  brew_install zsh-autosuggestions
  brew_install zsh-syntax-highlighting
  brew_install romkatv/powerlevel10k/powerlevel10k
}

install_core_cli() {
  hdr "Core CLI"
  brew_install git
  brew_install gh
  brew_install jq
  brew_install ripgrep
  brew_install fd
  brew_install fzf
  brew_install bat
  brew_install eza
  brew_install tree
  brew_install wget
  brew_install htop
  brew_install tmux
}

install_languages() {
  hdr "Languages / runtimes"
  install_nvm
  brew_install pyenv
  brew_install go
  install_rustup
}

install_containers_cloud() {
  hdr "Containers / cloud"
  brew_cask_install docker
  brew_install kubectl
  brew_install awscli
  brew_install terraform
}

install_db_clients() {
  hdr "Database clients"
  brew_cask_install tableplus
  brew_cask_install dbeaver-community
  brew_install redis
  brew_install postgresql@16
}

install_api_http() {
  hdr "API / HTTP"
  brew_install httpie
  brew_cask_install postman
  brew_cask_install insomnia
}

install_productivity() {
  hdr "Productivity"
  brew_cask_install rectangle
  brew_cask_install raycast
  brew_cask_install 1password
  brew_install 1password-cli
  brew_cask_install slack
  brew_cask_install notion
}

install_editors_extras() {
  hdr "Editors / extras"
  brew_install neovim
  brew_cask_install cursor
}

# ──────────────────────────── menu ────────────────────────────
ask_yn() {
  local prompt="$1"
  local default="${2:-n}"
  local reply
  if [[ "$default" == "y" ]]; then
    read -r -p "$prompt [Y/n] " reply
    reply="${reply:-y}"
  else
    read -r -p "$prompt [y/N] " reply
    reply="${reply:-n}"
  fi
  [[ "$reply" =~ ^[Yy]$ ]]
}

run_all() {
  install_required
  install_shell_prompt
  install_core_cli
  install_languages
  install_containers_cloud
  install_db_clients
  install_api_http
  install_productivity
  install_editors_extras
}

run_pick_categories() {
  install_required  # always
  ask_yn "Shell + prompt (starship, p10k, zsh plugins)?"        y && install_shell_prompt
  ask_yn "Core CLI (git, gh, jq, ripgrep, fzf, bat, eza, ...)?" y && install_core_cli
  ask_yn "Languages (nvm, pyenv, go, rust)?"                    y && install_languages
  ask_yn "Containers / cloud (Docker, kubectl, aws, terraform)?" n && install_containers_cloud
  ask_yn "Database clients (TablePlus, DBeaver, redis, pg)?"    n && install_db_clients
  ask_yn "API / HTTP (httpie, Postman, Insomnia)?"              n && install_api_http
  ask_yn "Productivity (Rectangle, Raycast, 1Password, Slack)?" n && install_productivity
  ask_yn "Editors / extras (neovim, Cursor)?"                   n && install_editors_extras
}

main_menu() {
  hdr "Devtools install — pick a path"
  cat <<EOF
  ${BOLD}1)${RESET} Install everything (recommended for new machine)
  ${BOLD}2)${RESET} Required only (iTerm2, VS Code, Oh My Zsh)
  ${BOLD}3)${RESET} Pick categories (required + ask per category)
  ${BOLD}4)${RESET} Quit
EOF
  local choice
  read -r -p "Choice [1-4]: " choice
  case "$choice" in
    1) run_all ;;
    2) install_required ;;
    3) run_pick_categories ;;
    4) say "Bye."; exit 0 ;;
    *) err "Invalid choice"; exit 1 ;;
  esac
}

# ──────────────────────────── summary ─────────────────────────
print_summary() {
  hdr "Summary"
  printf "${GREEN}Installed${RESET}: %d\n" "${#INSTALLED[@]}"
  for x in "${INSTALLED[@]}"; do printf "  + %s\n" "$x"; done
  printf "${DIM}Already present${RESET}: %d\n" "${#SKIPPED[@]}"
  for x in "${SKIPPED[@]}"; do printf "  ↻ %s\n" "$x"; done
  if (( ${#FAILED[@]} > 0 )); then
    printf "${RED}Failed${RESET}: %d\n" "${#FAILED[@]}"
    for x in "${FAILED[@]}"; do printf "  ✗ %s\n" "$x"; done
  fi

  hdr "Next steps"
  cat <<EOF
  • Open iTerm2 once and set it as your default terminal (iTerm2 → Make Default Term).
  • VS Code: install the 'code' shell command — Cmd+Shift+P → "Shell Command: Install 'code' command in PATH".
  • Restart your shell (or 'exec zsh') to pick up Oh My Zsh + plugin sourcing.
  • If nvm installed: append the nvm snippet from ~/.nvm/install output to ~/.zshrc, then 'nvm install --lts'.
  • If powerlevel10k installed: set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc, then run 'p10k configure'.
  • gh: run 'gh auth login' to authenticate with GitHub.
  • Docker Desktop: ${YELLOW}commercial use license required for orgs >250 employees or >\$10M revenue${RESET} — check before deploying to a team.
EOF

  if (( ${#FAILED[@]} > 0 )); then
    exit 1
  fi
}

# ─────────────────────────────── go ───────────────────────────
preflight
main_menu
print_summary
