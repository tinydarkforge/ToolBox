#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║  TINYDARKFORGE  ::  DEVTOOLS.EXE  v1.0                           ║
# ║  (C) 1987 TINYDARKFORGE SYSTEMS  ::  ALL RIGHTS RESERVED         ║
# ║  REQUIRES: MS-DARWIN 10.x+  ::  640K RAM  ::  HOMEBREW.SYS       ║
# ╚══════════════════════════════════════════════════════════════════╝

set -uo pipefail

# ─── CGA palette ──────────────────────────────────────────────────
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  BLACK=$(tput setaf 0); RED=$(tput setaf 1); GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3); BLUE=$(tput setaf 4); MAGENTA=$(tput setaf 5)
  CYAN=$(tput setaf 6); WHITE=$(tput setaf 7)
  BG_BLUE=$(tput setab 4)
else
  BOLD=""; DIM=""; RESET=""
  BLACK=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; MAGENTA=""; CYAN=""; WHITE=""
  BG_BLUE=""
fi

INSTALLED=()
SKIPPED=()
FAILED=()

# ─── boot sequence ────────────────────────────────────────────────
boot_screen() {
  clear
  printf "${CYAN}"
  cat <<'BANNER'

       ████████╗██████╗ ███████╗    ██████╗ ███████╗██╗   ██╗
       ╚══██╔══╝██╔══██╗██╔════╝    ██╔══██╗██╔════╝██║   ██║
          ██║   ██║  ██║█████╗      ██║  ██║█████╗  ██║   ██║
          ██║   ██║  ██║██╔══╝      ██║  ██║██╔══╝  ╚██╗ ██╔╝
          ██║   ██████╔╝██║         ██████╔╝███████╗ ╚████╔╝
          ╚═╝   ╚═════╝ ╚═╝         ╚═════╝ ╚══════╝  ╚═══╝

BANNER
  printf "${YELLOW}     ╔══════════════════════════════════════════════════════╗\n"
  printf "     ║  T I N Y   D A R K   F O R G E   ::   D E V T O O L S  ║\n"
  printf "     ║          v1.00  ::  (C) 1987   ::   FORGE/CO          ║\n"
  printf "     ╚══════════════════════════════════════════════════════╝${RESET}\n\n"

  printf "${GREEN}> POST CHECK..."
  for i in 1 2 3; do sleep 0.15; printf "."; done
  printf " ${BOLD}OK${RESET}\n"

  printf "${GREEN}> LOADING HOMEBREW.SYS"
  for i in 1 2 3 4 5; do sleep 0.1; printf "."; done
  printf " ${BOLD}OK${RESET}\n"

  printf "${GREEN}> KERNEL READY${RESET}\n\n"
  sleep 0.3
}

# ─── DOS-style helpers ────────────────────────────────────────────
prompt() { printf "${CYAN}C:\\\\TDF\\\\DEVTOOLS>${RESET} "; }

box_top()    { printf "${MAGENTA}╔══════════════════════════════════════════════════════════════════╗${RESET}\n"; }
box_mid()    { printf "${MAGENTA}║${RESET} %-64s ${MAGENTA}║${RESET}\n" "$1"; }
box_sep()    { printf "${MAGENTA}╠══════════════════════════════════════════════════════════════════╣${RESET}\n"; }
box_bot()    { printf "${MAGENTA}╚══════════════════════════════════════════════════════════════════╝${RESET}\n"; }

ok()    { printf "  ${GREEN}[ OK ]${RESET}    %s\n" "$1"; }
skip()  { printf "  ${YELLOW}[SKIP]${RESET}    %s ${DIM}(already loaded)${RESET}\n" "$1"; }
fail()  { printf "  ${RED}[FAIL]${RESET}    %s\n" "$1"; }
work()  { printf "  ${CYAN}[....]${RESET}    %s ${DIM}...${RESET}" "$1"; }
done_w() { printf "\r  ${GREEN}[ OK ]${RESET}    %s            \n" "$1"; }
fail_w() { printf "\r  ${RED}[FAIL]${RESET}    %s            \n" "$1"; }

beep() { printf "\a"; }

press_key() {
  printf "\n${YELLOW}-- Press any key to continue --${RESET} "
  read -r -n 1 -s
  printf "\n"
}

progress_bar() {
  local label="$1"
  printf "  ${CYAN}%s${RESET} [" "$label"
  for i in $(seq 1 20); do printf "${GREEN}█${RESET}"; sleep 0.02; done
  printf "] ${GREEN}100%%${RESET}\n"
}

section() {
  printf "\n${BG_BLUE}${WHITE}${BOLD}  >> %-60s  ${RESET}\n\n" "$1"
}

# ─── preflight ────────────────────────────────────────────────────
preflight() {
  section "PHASE 1 :: SYSTEM CHECK"

  if [[ "$(uname)" != "Darwin" ]]; then
    fail "MS-DARWIN NOT DETECTED. ABORT, RETRY, FAIL?"
    beep
    exit 1
  fi
  ok "MS-DARWIN $(sw_vers -productVersion) DETECTED"

  if ! xcode-select -p >/dev/null 2>&1; then
    fail "XCODE.SYS MISSING"
    work "Loading XCODE.SYS"
    xcode-select --install || true
    fail_w "XCODE.SYS — RUN AGAIN AFTER INSTALL FINISHES"
    exit 1
  fi
  ok "XCODE.SYS LOADED"

  if ! command -v brew >/dev/null 2>&1; then
    work "Bootstrapping HOMEBREW.SYS"
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >/dev/null 2>&1; then
      [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
      [[ -x /usr/local/bin/brew ]]    && eval "$(/usr/local/bin/brew shellenv)"
      done_w "HOMEBREW.SYS LOADED"
    else
      fail_w "HOMEBREW.SYS LOAD ERROR"
      beep
      exit 1
    fi
  else
    ok "HOMEBREW.SYS PRESENT"
  fi

  work "Refreshing package index"
  brew update >/dev/null 2>&1 || true
  done_w "PACKAGE INDEX SYNCED"
}

# ─── install primitives ───────────────────────────────────────────
brew_install() {
  local pkg="$1"
  if brew list --formula --versions "$pkg" >/dev/null 2>&1; then
    skip "$pkg"; SKIPPED+=("$pkg"); return 0
  fi
  work "$pkg"
  if brew install "$pkg" >/dev/null 2>&1; then
    done_w "$pkg"; INSTALLED+=("$pkg")
  else
    fail_w "$pkg"; FAILED+=("$pkg"); beep
  fi
}

brew_cask_install() {
  local pkg="$1"
  if brew list --cask --versions "$pkg" >/dev/null 2>&1; then
    skip "$pkg.app"; SKIPPED+=("$pkg"); return 0
  fi
  work "$pkg.app"
  if brew install --cask "$pkg" >/dev/null 2>&1; then
    done_w "$pkg.app"; INSTALLED+=("$pkg")
  else
    fail_w "$pkg.app"; FAILED+=("$pkg"); beep
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    skip "OHMYZSH.SH"; SKIPPED+=("oh-my-zsh"); return 0
  fi
  work "OHMYZSH.SH"
  if RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >/dev/null 2>&1; then
    done_w "OHMYZSH.SH"; INSTALLED+=("oh-my-zsh")
  else
    fail_w "OHMYZSH.SH"; FAILED+=("oh-my-zsh"); beep
  fi
}

install_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    skip "NVM.COM"; SKIPPED+=("nvm"); return 0
  fi
  work "NVM.COM"
  if curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null 2>&1; then
    done_w "NVM.COM"; INSTALLED+=("nvm")
  else
    fail_w "NVM.COM"; FAILED+=("nvm"); beep
  fi
}

install_rustup() {
  if command -v rustup >/dev/null 2>&1; then
    skip "RUSTUP.EXE"; SKIPPED+=("rustup"); return 0
  fi
  work "RUSTUP.EXE"
  if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path >/dev/null 2>&1; then
    done_w "RUSTUP.EXE"; INSTALLED+=("rustup")
  else
    fail_w "RUSTUP.EXE"; FAILED+=("rustup"); beep
  fi
}

# ─── category installers ──────────────────────────────────────────
install_required() {
  section "PHASE 2 :: REQUIRED PACKAGES"
  brew_cask_install iterm2
  brew_cask_install visual-studio-code
  install_oh_my_zsh
}

install_shell_prompt() {
  section "MODULE :: SHELL PROMPT"
  brew_install starship
  brew_install zsh-autosuggestions
  brew_install zsh-syntax-highlighting
  brew_install romkatv/powerlevel10k/powerlevel10k
}

install_core_cli() {
  section "MODULE :: CORE CLI"
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
  section "MODULE :: LANGUAGES"
  install_nvm
  brew_install pyenv
  brew_install go
  install_rustup
}

install_containers_cloud() {
  section "MODULE :: CONTAINERS / CLOUD"
  brew_cask_install docker
  brew_install kubectl
  brew_install awscli
  brew_install terraform
}

install_db_clients() {
  section "MODULE :: DATABASE CLIENTS"
  brew_cask_install tableplus
  brew_cask_install dbeaver-community
  brew_install redis
  brew_install postgresql@16
}

install_api_http() {
  section "MODULE :: API / HTTP"
  brew_install httpie
  brew_cask_install postman
  brew_cask_install insomnia
}

install_productivity() {
  section "MODULE :: PRODUCTIVITY"
  brew_cask_install rectangle
  brew_cask_install raycast
  brew_cask_install 1password
  brew_install 1password-cli
  brew_cask_install slack
  brew_cask_install notion
}

install_editors_extras() {
  section "MODULE :: EDITORS / EXTRAS"
  brew_install neovim
  brew_cask_install cursor
}

# ─── menu ─────────────────────────────────────────────────────────
ask_yn() {
  local prompt_txt="$1"
  local default="${2:-n}"
  local reply
  if [[ "$default" == "y" ]]; then
    printf "${CYAN}?${RESET} %s ${DIM}[Y/n]${RESET} " "$prompt_txt"
  else
    printf "${CYAN}?${RESET} %s ${DIM}[y/N]${RESET} " "$prompt_txt"
  fi
  read -r reply
  reply="${reply:-$default}"
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
  install_required
  ask_yn "Load SHELL PROMPT module?" y && install_shell_prompt
  ask_yn "Load CORE CLI module?" y && install_core_cli
  ask_yn "Load LANGUAGES module?" y && install_languages
  ask_yn "Load CONTAINERS/CLOUD module?" n && install_containers_cloud
  ask_yn "Load DATABASE module?" n && install_db_clients
  ask_yn "Load API/HTTP module?" n && install_api_http
  ask_yn "Load PRODUCTIVITY module?" n && install_productivity
  ask_yn "Load EDITORS/EXTRAS module?" n && install_editors_extras
}

main_menu() {
  printf "\n"
  box_top
  box_mid "                    ::  M A I N   M E N U  ::"
  box_sep
  box_mid "  [1]  FULL INSTALL          (everything, recommended for new HD)"
  box_mid "  [2]  MINIMAL INSTALL       (iTerm2 + VS Code + Oh My Zsh)"
  box_mid "  [3]  CUSTOM INSTALL        (pick modules one by one)"
  box_mid "  [4]  ABORT                 (exit to DOS)"
  box_bot
  printf "\n"
  prompt
  read -r choice
  case "$choice" in
    1) run_all ;;
    2) install_required ;;
    3) run_pick_categories ;;
    4) printf "\n${YELLOW}Returning to DOS...${RESET}\n"; exit 0 ;;
    *) printf "\n${RED}Bad command or file name${RESET}\n"; beep; exit 1 ;;
  esac
}

# ─── final report ─────────────────────────────────────────────────
print_summary() {
  printf "\n"
  box_top
  box_mid "             ::  I N S T A L L   R E P O R T  ::"
  box_bot
  printf "\n"

  printf "  ${GREEN}LOADED${RESET}     %d package(s)\n" "${#INSTALLED[@]}"
  for x in "${INSTALLED[@]}"; do printf "    ${GREEN}+${RESET} %s\n" "$x"; done
  printf "\n"

  printf "  ${YELLOW}SKIPPED${RESET}    %d package(s) ${DIM}(already resident)${RESET}\n" "${#SKIPPED[@]}"
  for x in "${SKIPPED[@]}"; do printf "    ${YELLOW}~${RESET} %s\n" "$x"; done
  printf "\n"

  if (( ${#FAILED[@]} > 0 )); then
    printf "  ${RED}FAILED${RESET}     %d package(s)\n" "${#FAILED[@]}"
    for x in "${FAILED[@]}"; do printf "    ${RED}!${RESET} %s\n" "$x"; done
    printf "\n"
  fi

  box_top
  box_mid "                ::  P O S T - B O O T   T O D O  ::"
  box_bot
  cat <<EOF

  ${CYAN}>${RESET} Open iTerm2.app — set as default terminal.
  ${CYAN}>${RESET} VS Code — Cmd+Shift+P → "Shell Command: Install 'code' command in PATH".
  ${CYAN}>${RESET} 'exec zsh' to reload shell with Oh My Zsh.
  ${CYAN}>${RESET} If NVM.COM loaded — append snippet to ~/.zshrc, then 'nvm install --lts'.
  ${CYAN}>${RESET} If P10K loaded — set ZSH_THEME="powerlevel10k/powerlevel10k", run 'p10k configure'.
  ${CYAN}>${RESET} Run 'gh auth login' to link GitHub.

EOF

  if (( ${#FAILED[@]} > 0 )); then
    printf "${RED}${BOLD}  *** %d ERROR(S) — CHECK LOG ABOVE ***${RESET}\n\n" "${#FAILED[@]}"
    beep
    exit 1
  else
    printf "${GREEN}${BOLD}  *** SYSTEM READY ***${RESET}\n"
    printf "${DIM}  Press CTRL+ALT+DEL to reboot${RESET} ${YELLOW}(just kidding — 'exec zsh' will do)${RESET}\n\n"
    beep
  fi
}

# ─── main ─────────────────────────────────────────────────────────
boot_screen
preflight
main_menu
print_summary
