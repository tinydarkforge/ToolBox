#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║  TINYDARKFORGE  ::  DEVTOOLS.EXE  v1.0                           ║
# ║  (C) 1987 TINYDARKFORGE SYSTEMS  ::  ALL RIGHTS RESERVED         ║
# ║  REQUIRES: MS-DARWIN 10.x+  ::  640K RAM  ::  HOMEBREW.SYS       ║
# ╚══════════════════════════════════════════════════════════════════╝

set -uo pipefail
set +m  # silence background job notifications (sound playback)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── re-exec under bash 4+ for arrow-key menu ─────────────────────
# macOS ships bash 3.2. If brew bash 4+ is on disk, re-run script with it.
if (( BASH_VERSINFO[0] < 4 )) && [[ -z "${TDF_REEXEC:-}" ]]; then
  for _candidate in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    if [[ -x "$_candidate" ]]; then
      _ver=$("$_candidate" -c 'echo "$BASH_VERSINFO"' 2>/dev/null || echo 0)
      if (( _ver >= 4 )); then
        export TDF_REEXEC=1
        exec "$_candidate" "$0" "$@"
      fi
    fi
  done
  unset _candidate _ver
fi

# ─── sound system ─────────────────────────────────────────────────
SOUND_ENABLED="${TDF_SOUND:-1}"
SOUND_VOL="${TDF_SOUND_VOL:-0.5}"
SOUND_DIR="$SCRIPT_DIR/assets/sounds"

# Map: logical event → custom WAV name → macOS system sound fallback
play_sound() {
  [[ "$SOUND_ENABLED" != "1" ]] && return 0
  command -v afplay >/dev/null 2>&1 || return 0
  local custom="$1" sysfallback="$2"
  if [[ -f "$SOUND_DIR/$custom.wav" ]]; then
    ( afplay -v "$SOUND_VOL" "$SOUND_DIR/$custom.wav" >/dev/null 2>&1 ) &
  elif [[ -n "$sysfallback" && -f "/System/Library/Sounds/$sysfallback.aiff" ]]; then
    ( afplay -v "$SOUND_VOL" "/System/Library/Sounds/$sysfallback.aiff" >/dev/null 2>&1 ) &
  fi
  disown 2>/dev/null || true
}
snd_boot()   { play_sound boot    Hero; }
snd_nav()    { play_sound nav     Tink; }
snd_select() { play_sound select  Pop; }
snd_ok()     { play_sound ok      Morse; }
snd_fail()   { play_sound fail    Funk; }
snd_done()   { play_sound done    Glass; }

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
  printf "${YELLOW}     ╔════════════════════════════════════════════════════════╗\n"
  printf "     ║  T I N Y   D A R K   F O R G E   ::   D E V T O O L S  ║\n"
  printf "     ║           v1.00  ::  (C) 1987   ::   FORGE/CO          ║\n"
  printf "     ╚════════════════════════════════════════════════════════╝${RESET}\n\n"

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

box_top()    { printf "${MAGENTA}╔════════════════════════════════════════════════════════════════════╗${RESET}\n"; }
box_mid()    { printf "${MAGENTA}║${RESET} %-64s ${MAGENTA}  ║${RESET}\n" "$1"; }
box_sep()    { printf "${MAGENTA}╠════════════════════════════════════════════════════════════════════╣${RESET}\n"; }
box_bot()    { printf "${MAGENTA}╚════════════════════════════════════════════════════════════════════╝${RESET}\n"; }

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
    work "Loading CLT.SYS (accept the GUI dialog when it appears)"
    xcode-select --install >/dev/null 2>&1 || true
    printf "\n  ${YELLOW}!${RESET} Waiting for Command Line Tools install to finish...\n"
    printf "  ${DIM}    (this can take 5-15 min depending on connection)${RESET}\n"
    local _waited=0
    while ! xcode-select -p >/dev/null 2>&1; do
      sleep 5
      _waited=$((_waited + 5))
      if (( _waited % 60 == 0 )); then
        printf "  ${DIM}    ...still waiting (%dm elapsed)${RESET}\n" "$((_waited / 60))"
      fi
      if (( _waited >= 1800 )); then
        fail_w "CLT.SYS — timed out after 30 min. Install manually then re-run."
        beep
        exit 1
      fi
    done
    done_w "CLT.SYS LOADED"
  else
    ok "CLT.SYS LOADED"
  fi

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
    done_w "$pkg"; INSTALLED+=("$pkg"); snd_ok
  else
    fail_w "$pkg"; FAILED+=("$pkg"); beep; snd_fail
  fi
}

brew_cask_install() {
  local pkg="$1"
  if brew list --cask --versions "$pkg" >/dev/null 2>&1; then
    skip "$pkg.app"; SKIPPED+=("$pkg"); return 0
  fi
  work "$pkg.app"
  if brew install --cask "$pkg" >/dev/null 2>&1; then
    done_w "$pkg.app"; INSTALLED+=("$pkg"); snd_ok
  else
    fail_w "$pkg.app"; FAILED+=("$pkg"); beep; snd_fail
  fi
}

install_npm_global() {
  local pkg="$1" binname="$2" label="${3:-$binname}"
  if ! command -v npm >/dev/null 2>&1; then
    fail "$label — npm missing (load LANGUAGES module first, then 'nvm install --lts')"
    FAILED+=("$pkg"); snd_fail
    return 1
  fi
  if command -v "$binname" >/dev/null 2>&1; then
    skip "$label"; SKIPPED+=("$pkg"); return 0
  fi
  work "$label"
  if npm install -g "$pkg" >/dev/null 2>&1; then
    done_w "$label"; INSTALLED+=("$pkg"); snd_ok
  else
    fail_w "$label"; FAILED+=("$pkg"); beep; snd_fail
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    skip "OHMYZSH.SH"; SKIPPED+=("oh-my-zsh"); return 0
  fi
  work "OHMYZSH.SH"
  if RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >/dev/null 2>&1; then
    done_w "OHMYZSH.SH"; INSTALLED+=("oh-my-zsh"); snd_ok
  else
    fail_w "OHMYZSH.SH"; FAILED+=("oh-my-zsh"); beep; snd_fail
  fi
}

install_nvm() {
  if [[ -d "$HOME/.nvm" ]]; then
    skip "NVM.COM"; SKIPPED+=("nvm"); return 0
  fi
  work "NVM.COM"
  if curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash >/dev/null 2>&1; then
    done_w "NVM.COM"; INSTALLED+=("nvm"); snd_ok
  else
    fail_w "NVM.COM"; FAILED+=("nvm"); beep; snd_fail
  fi
}

install_rustup() {
  if command -v rustup >/dev/null 2>&1; then
    skip "RUSTUP.EXE"; SKIPPED+=("rustup"); return 0
  fi
  work "RUSTUP.EXE"
  if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path >/dev/null 2>&1; then
    done_w "RUSTUP.EXE"; INSTALLED+=("rustup"); snd_ok
  else
    fail_w "RUSTUP.EXE"; FAILED+=("rustup"); beep; snd_fail
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

install_secgate() {
  install_npm_global "@tinydarkforge/secgate" "secgate" "SECGATE.JS"
}

install_intake() {
  if command -v intake >/dev/null 2>&1; then
    skip "INTAKE.EXE"; SKIPPED+=("intake")
    return 0
  fi
  printf "  ${YELLOW}!${RESET} INTAKE.EXE installer pulls Ollama + ~5GB model + prompts gh login.\n"
  if ask_yn "  Run INTAKE.EXE installer now?" n; then
    work "INTAKE.EXE"
    if curl -fsSL https://raw.githubusercontent.com/tinydarkforge/Intake/main/scripts/install.sh | bash; then
      done_w "INTAKE.EXE"; INSTALLED+=("intake"); snd_ok
    else
      fail_w "INTAKE.EXE"; FAILED+=("intake"); beep; snd_fail
    fi
  else
    skip "INTAKE.EXE (declined)"; SKIPPED+=("intake (declined)")
  fi
}

install_tdf_tools() {
  section "MODULE :: TINYDARKFORGE FORGE"
  install_secgate
  install_intake
}

install_secgate_only() {
  section "MODULE :: SECGATE"
  install_secgate
}

install_intake_only() {
  section "MODULE :: INTAKE"
  install_intake
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
  install_tdf_tools
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
  ask_yn "Load TINYDARKFORGE FORGE module (SecGate + Intake)?" y && install_tdf_tools
}

MENU_OPTIONS=(
  "[1]  FULL INSTALL          (everything, recommended for new HD)"
  "[2]  MINIMAL INSTALL       (iTerm2 + VS Code + Oh My Zsh)"
  "[3]  CUSTOM INSTALL        (pick modules one by one)"
  "[4]  SECGATE               (npm i -g @tinydarkforge/secgate)"
  "[5]  INTAKE                (Ollama + intake + ~5GB AI model)"
)

abort_to_dos() {
  arrow_menu_cleanup 2>/dev/null || true
  printf "\n${YELLOW}Returning to DOS...${RESET}\n"
  exit 0
}

# Arrow-nav menu. Returns index in MENU_RESULT.
# Falls back to numbered prompt when stdin is not a TTY or bash <4 (no fractional read timeouts).
MENU_RESULT=0

numbered_menu() {
  local n=${#MENU_OPTIONS[@]}
  box_top
  box_mid "                    ::  M A I N   M E N U  ::"
  box_sep
  for opt in "${MENU_OPTIONS[@]}"; do box_mid "$opt"; done
  box_bot
  if (( BASH_VERSINFO[0] < 4 )); then
    printf "\n  ${DIM}(bash %s — arrow nav needs bash 4+. brew install bash.)${RESET}\n" "$BASH_VERSION"
  fi
  printf "  ${DIM}Type 1-5 + ENTER, or Q to quit (Ctrl+C also works).${RESET}\n\n"
  prompt
  local choice
  read -r choice
  case "$choice" in
    [1-9])
      if (( choice >= 1 && choice <= n )); then
        MENU_RESULT=$((choice - 1))
        snd_select
      else
        printf "\n${RED}Bad command or file name${RESET}\n"; beep; exit 1
      fi
      ;;
    q|Q) abort_to_dos ;;
    *) printf "\n${RED}Bad command or file name${RESET}\n"; beep; exit 1 ;;
  esac
}

arrow_menu_cleanup() { tput cnorm 2>/dev/null || true; stty echo 2>/dev/null || true; }

arrow_menu() {
  if [[ ! -t 0 ]] || (( BASH_VERSINFO[0] < 4 )); then
    numbered_menu
    return
  fi

  local n=${#MENU_OPTIONS[@]}
  local sel=0
  local first=1
  local key key2

  tput civis 2>/dev/null || true
  trap 'arrow_menu_cleanup; printf "\n${YELLOW}Aborted by user${RESET}\n"; exit 130' INT TERM
  trap 'arrow_menu_cleanup' EXIT

  while true; do
    if [[ $first -eq 0 ]]; then
      local up=$((n + 6))
      local i
      for ((i=0; i<up; i++)); do tput cuu1; tput el; done
    fi
    first=0

    box_top
    box_mid "              ::  M A I N   M E N U  —  ↑↓ ENTER  ::"
    box_sep
    local idx
    for idx in "${!MENU_OPTIONS[@]}"; do
      if [[ $idx -eq $sel ]]; then
        printf "${MAGENTA}║${RESET} ${YELLOW}▶${RESET} ${BOLD}%-63s${RESET}  ${MAGENTA}║${RESET}\n" "${MENU_OPTIONS[$idx]}"
      else
        printf "${MAGENTA}║${RESET}   %-63s  ${MAGENTA}║${RESET}\n" "${MENU_OPTIONS[$idx]}"
      fi
    done
    box_bot
    printf "\n  ${DIM}Use ↑/↓ to move, ENTER to select, 1-5 for direct, Q to quit, Ctrl+C to abort.${RESET}\n"

    key=""
    IFS= read -rsn1 key || key=""
    case "$key" in
      $'\x1b')
        key2=""
        IFS= read -rsn2 -t 0.05 key2 || key2=""
        case "$key2" in
          '[A'|'OA') ((sel--)); ((sel<0)) && sel=$((n-1)); snd_nav ;;
          '[B'|'OB') ((sel++)); ((sel>=n)) && sel=0; snd_nav ;;
          '[H'|'OH') sel=0; snd_nav ;;
          '[F'|'OF') sel=$((n-1)); snd_nav ;;
          '') ;;  # bare ESC: ignore
        esac
        ;;
      '')  # Enter
        snd_select
        break
        ;;
      [1-9])
        if (( key >= 1 && key <= n )); then
          sel=$((key - 1))
          snd_select
          break
        fi
        ;;
      q|Q)
        snd_select
        abort_to_dos
        ;;
      $'\x03')  # Ctrl-C (raw, if signal trap missed)
        arrow_menu_cleanup
        printf "\n${YELLOW}Aborted by user${RESET}\n"
        exit 130
        ;;
    esac
  done

  arrow_menu_cleanup
  trap - INT TERM EXIT
  MENU_RESULT=$sel
}

confirm_action() {
  local title="$1" detail="$2"
  printf "\n${CYAN}::${RESET} ${BOLD}%s${RESET}\n" "$title"
  printf "   ${DIM}%s${RESET}\n\n" "$detail"
  ask_yn "  Proceed?" n
}

cancelled() {
  printf "\n${YELLOW}Cancelled. Returning to menu...${RESET}\n"
  return 0
}

main_menu() {
  printf "\n"
  trap 'abort_to_dos' INT TERM
  arrow_menu
  trap - INT TERM
  case "$MENU_RESULT" in
    0)
      confirm_action "FULL INSTALL" \
        "Installs every category. Pulls 40+ Homebrew packages + casks (Docker, Postman, Slack, Cursor, Notion, ...). Several GB download. Re-run safe — already-installed tools skip." \
        && run_all || cancelled
      ;;
    1)
      confirm_action "MINIMAL INSTALL" \
        "Installs iTerm2, VS Code, Oh My Zsh. ~500 MB if fresh." \
        && install_required || cancelled
      ;;
    2)
      confirm_action "CUSTOM INSTALL" \
        "Installs required (iTerm2 + VS Code + Oh My Zsh), then prompts y/N per category." \
        && run_pick_categories || cancelled
      ;;
    3)
      confirm_action "SECGATE" \
        "Runs: npm install -g @tinydarkforge/secgate. Requires npm on PATH (load LANGUAGES module first if missing)." \
        && install_secgate_only || cancelled
      ;;
    4)
      confirm_action "INTAKE" \
        "Runs Intake's curl-pipe installer. Pulls Ollama + ~5GB AI model. Prompts gh login." \
        && install_intake_only || cancelled
      ;;
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
  if (( ${#INSTALLED[@]} > 0 )); then
    for x in "${INSTALLED[@]}"; do printf "    ${GREEN}+${RESET} %s\n" "$x"; done
  fi
  printf "\n"

  printf "  ${YELLOW}SKIPPED${RESET}    %d package(s) ${DIM}(already resident)${RESET}\n" "${#SKIPPED[@]}"
  if (( ${#SKIPPED[@]} > 0 )); then
    for x in "${SKIPPED[@]}"; do printf "    ${YELLOW}~${RESET} %s\n" "$x"; done
  fi
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
    LAST_EXIT=1
    beep; snd_fail
  else
    printf "${GREEN}${BOLD}  *** SYSTEM READY ***${RESET}\n"
    printf "${DIM}  Press CTRL+ALT+DEL to reboot${RESET} ${YELLOW}(just kidding — 'exec zsh' will do)${RESET}\n\n"
    LAST_EXIT=0
    beep; snd_done
  fi
}

reset_run_state() {
  INSTALLED=()
  SKIPPED=()
  FAILED=()
}

return_or_quit() {
  printf "\n${YELLOW}-- Press ENTER to return to menu, Q to quit --${RESET} "
  local k
  IFS= read -r k
  case "$k" in
    q|Q) abort_to_dos ;;
  esac
}

# ─── main ─────────────────────────────────────────────────────────
LAST_EXIT=0
snd_boot
boot_screen
preflight
while true; do
  reset_run_state
  main_menu
  print_summary
  return_or_quit
done
