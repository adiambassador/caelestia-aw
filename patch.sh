#!/usr/bin/env bash

set -euo pipefail

# CONFIG
SHELL_REPO="https://github.com/AdiAmbassador/caelestia-shell-aw.git"
CLI_REPO="https://github.com/AdiAmbassador/caelestia-cli-aw.git"
# The AW shell's main branch now targets Caelestia 2.3. Pin the final 2.2-era
# revision so this installer remains compatible with caelestia-shell 2.2.0.
SHELL_REF="ecb72651321657cfa14571489f161e7bf7fc8422"
SUPPORTED_SHELL_VERSION="2.2.0"

SHELL_DEST="/etc/xdg/quickshell/caelestia"
CLI_DEST="$(python3 -c 'import site; print(site.getsitepackages()[0])')/caelestia"

LOG_FILE="/tmp/caelestia_patch_error.log"
> "$LOG_FILE" # Clear old logs

# COLORS & STYLING
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
RED="\033[1;31m"
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# borders
BORDER="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# HELPER FUNCTIONS
spinner() {
    local pid=$1
    local msg=$2
    local delay=0.1
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while kill -0 $pid 2>/dev/null; do
        for i in 0 1 2 3 4 5 6 7 8 9; do
            printf "\r${CYAN}[${spin:$i:1}]${RESET} $msg"
            sleep $delay
            if ! kill -0 $pid 2>/dev/null; then break; fi
        done
    done
    
    # Safely wait for background process under set -e
    local exit_code=0
    wait $pid || exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        printf "\r${GREEN}[✓]${RESET} $msg${RESET}  \n"
    else
        printf "\n\r${RED}[✗]${RESET} $msg${RESET}  \n"
        echo -e "${RED}An error occurred. Please check the log file for details: ${BOLD}$LOG_FILE${RESET}"
        exit $exit_code
    fi
}

log() {
    echo -e "${BLUE}[INFO]${RESET} $1"
}

success() {
    echo -e "${GREEN}[✓]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[⚠]${RESET} $1"
}

error() {
    echo -e "${RED}[✗]${RESET} $1"
}

verify_shell_version() {
    if ! pacman -Q caelestia-shell >/dev/null 2>&1; then
        error "caelestia-shell is not installed. Install Caelestia before applying this patch."
        exit 1
    fi

    local installed_version
    installed_version="$(pacman -Q caelestia-shell | awk '{print $2}' | sed -E 's/-[0-9]+$//')"

    if [[ "$installed_version" != "$SUPPORTED_SHELL_VERSION" ]]; then
        error "This patch supports caelestia-shell ${SUPPORTED_SHELL_VERSION}; found ${installed_version}."
        echo -e "${YELLOW}Install the supported Caelestia version before applying this patch.${RESET}"
        exit 1
    fi
}

run_step() {
    local msg=$1
    shift
    
    # Run the command, append stderr to our central log file
    if "$@" >/dev/null 2>>"$LOG_FILE"; then
        success "$msg"
    else
        error "Failed to patch: $msg"
        echo -e "${RED}An error occurred. Please check the log file for details: ${BOLD}$LOG_FILE${RESET}"
        exit 1
    fi
}

header() {
    clear
    echo -e "${MAGENTA}"
    cat << "EOF"
		                ┏━╸┏━┓┏━╸╻  ┏━╸┏━┓╺┳╸╻┏━┓   ┏━┓╻ ╻
                        	┃  ┣━┫┣╸ ┃  ┣╸ ┗━┓ ┃ ┃┣━┫╺━╸┣━┫┃╻┃
            		        ┗━╸╹ ╹┗━╸┗━╸┗━╸┗━┛ ╹ ╹╹ ╹   ╹ ╹┗┻┛
EOF
    echo -e "${RESET}${BOLD}		            Caelestia Animated Wallpaper Patch Installer${RESET}"
    echo -e "${DIM}                                A feature addition fork of Caelestia${RESET}"
    echo -e "${DIM}                                           Version: 1.1.3${RESET}"
    echo -e "${DIM}                                      Patches: Caelestia 2.2.0${RESET}"
    echo
    echo -e "${CYAN}$BORDER${RESET}"
    echo
}

cleanup() {
    rm -rf /tmp/caelestia-shell-fork
    rm -rf /tmp/caelestia-cli-fork
}

trap cleanup EXIT

# main
header

echo -e "${MAGENTA}Starting installation of Caelestia Animated Wallpaper patches...${RESET}"
echo

verify_shell_version

# Clone repo
log "Cloning online shell fork..."
git clone "$SHELL_REPO" /tmp/caelestia-shell-fork >/dev/null 2>>"$LOG_FILE" &
spinner $! "Cloning shell repo"
echo

run_step "Checked out Caelestia 2.2-compatible shell revision" git -C /tmp/caelestia-shell-fork checkout --detach "$SHELL_REF"
echo

log "Cloning online CLI fork..."
git clone --depth 1 "$CLI_REPO" /tmp/caelestia-cli-fork >/dev/null 2>>"$LOG_FILE" &
spinner $! "Cloning CLI repo"
echo

# Clean up C++ build files and git artifacts before copying
log "Cleaning up build artifacts..."
run_step "Cleaned up" bash -c "rm -rf /tmp/caelestia-shell-fork/.git /tmp/caelestia-shell-fork/flake.nix /tmp/caelestia-shell-fork/flake.lock /tmp/caelestia-shell-fork/CMakeLists.txt /tmp/caelestia-shell-fork/plugin /tmp/caelestia-cli-fork/.git"
echo

# Patching
log "Patching shell modules and services..."
run_step "Shell files patched" bash -c "sudo cp -a /tmp/caelestia-shell-fork/. \"$SHELL_DEST/\""
echo

log "Patching CLI files..."
run_step "CLI patched successfully" bash -c "sudo cp -a /tmp/caelestia-cli-fork/src/caelestia/. \"$CLI_DEST/\""
echo

# Dependencies
log "Installing system dependencies..."
run_step "Dependencies checked" bash -c "sudo pacman -S --needed --noconfirm --overwrite '*' ffmpeg qt6-multimedia qt6-multimedia-ffmpeg"
echo

# Hyprland compatibility
if ! grep -q "QT_FFMPEG_DECODING_HW_DEVICE_TYPES" ~/.config/hypr/hyprland.conf 2>/dev/null; then
    log "Adding Hyprland hardware decoding fix..."
    echo 'env = QT_FFMPEG_DECODING_HW_DEVICE_TYPES,none' >> ~/.config/hypr/hyprland.conf
    success "Hyprland compatibility setting added"
else
    warn "Hyprland compatibility setting already present"
fi
echo

# Restart
log "Restarting Caelestia service..."
(
    caelestia shell -k || true
    sleep 1.5
) >/dev/null 2>>"$LOG_FILE" &
spinner $! "Stopping Caelestia"

nohup caelestia shell -d >/dev/null 2>&1 &
success "Caelestia restarted in background"
echo
echo -e "${GREEN}$BORDER${RESET}"
echo -e "${BOLD}${GREEN}                                      Installation Complete! ${RESET}"
echo -e "${GREEN}$BORDER${RESET}"
echo
echo -e " ${CYAN}Add your videos to:${RESET} ${BOLD}~/Pictures/Wallpapers/Animated${RESET}"
echo -e " Open the launcher and ${YELLOW}refresh thumbnails${RESET} to see your videos."
echo
echo
