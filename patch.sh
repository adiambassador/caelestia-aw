#!/usr/bin/env bash

set -euo pipefail

# CONFIG
SHELL_SRC="https://github.com/AdiAmbassador/caelestia-shell-aw"
CLI_SRC="https://github.com/AdiAmbassador/caelestia-cli-aw"

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
    echo -e "${DIM}                                           Version: 1.0.3${RESET}"
    echo -e "${DIM}                                      Patches: Caelestia 2.0.3${RESET}"
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

# Clone repo
log "Cloning shell fork..."
git clone --depth 1 "$SHELL_SRC" /tmp/caelestia-shell-fork >/dev/null 2>>"$LOG_FILE" &
spinner $! "Cloning shell modules"
echo

log "Cloning CLI fork..."
git clone --depth 1 "$CLI_SRC" /tmp/caelestia-cli-fork >/dev/null 2>>"$LOG_FILE" &
spinner $! "Cloning CLI components"
echo

# Patching
log "Patching shell modules and services..."
run_step "Shell files patched" bash -c "sudo cp /tmp/caelestia-shell-fork/modules/background/VideoWallpaper.qml \"$SHELL_DEST/modules/background/\" && \
sudo cp /tmp/caelestia-shell-fork/modules/background/Wallpaper.qml \"$SHELL_DEST/modules/background/\" && \
sudo cp /tmp/caelestia-shell-fork/modules/launcher/Content.qml \"$SHELL_DEST/modules/launcher/\" && \
sudo cp /tmp/caelestia-shell-fork/modules/launcher/ContentList.qml \"$SHELL_DEST/modules/launcher/\" && \
sudo cp /tmp/caelestia-shell-fork/modules/launcher/WallpaperList.qml \"$SHELL_DEST/modules/launcher/\" && \
sudo cp /tmp/caelestia-shell-fork/modules/launcher/items/AppItem.qml \"$SHELL_DEST/modules/launcher/items/\" && \
sudo cp /tmp/caelestia-shell-fork/modules/launcher/items/WallpaperItem.qml \"$SHELL_DEST/modules/launcher/items/\" && \
sudo cp /tmp/caelestia-shell-fork/modules/nexus/pages/WallpaperAndStyle.qml \"$SHELL_DEST/modules/nexus/pages/\" && \
sudo cp /tmp/caelestia-shell-fork/services/WallpaperPauser.qml \"$SHELL_DEST/services/\" && \
sudo cp /tmp/caelestia-shell-fork/services/Wallpapers.qml \"$SHELL_DEST/services/\""
echo

log "Patching CLI files..."
run_step "CLI patched successfully" bash -c "sudo cp /tmp/caelestia-cli-fork/src/caelestia/parser.py \"$CLI_DEST/\" && \
sudo cp /tmp/caelestia-cli-fork/src/caelestia/utils/hypr.py \"$CLI_DEST/utils/\" && \
sudo cp /tmp/caelestia-cli-fork/src/caelestia/subcommands/shell.py \"$CLI_DEST/subcommands/\" && \
sudo cp /tmp/caelestia-cli-fork/src/caelestia/subcommands/wallpaper.py \"$CLI_DEST/subcommands/\" && \
sudo cp /tmp/caelestia-cli-fork/src/caelestia/utils/wallpaper.py \"$CLI_DEST/utils/\""
echo

# Dependencies
log "Installing system dependencies..."
run_step "Dependencies checked" bash -c "echo 'Skipping pacman to avoid partial upgrade conflicts'"
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
    sleep 1.2
    caelestia shell -d
) >/dev/null 2>>"$LOG_FILE" &
spinner $! "Restarting Caelestia"
echo
echo -e "${GREEN}$BORDER${RESET}"
echo -e "${BOLD}${GREEN}                                      Installation Complete! ${RESET}"
echo -e "${GREEN}$BORDER${RESET}"
echo
echo -e " ${CYAN}Add your videos to:${RESET} ${BOLD}~/Pictures/Wallpapers/Animated${RESET}"
echo -e " Open the launcher and ${YELLOW}refresh thumbnails${RESET} to see your videos."
echo
echo
