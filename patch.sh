#!/usr/bin/env bash

set -euo pipefail

# ====================== CONFIG ======================
SHELL_SRC="https://github.com/AdiAmbassador/caelestia-shell-aw"
CLI_SRC="https://github.com/AdiAmbassador/caelestia-cli-aw"

SHELL_DEST="/etc/xdg/quickshell/caelestia"
CLI_DEST="$(python3 -c 'import site; print(site.getsitepackages()[0])')/caelestia"

# ====================== COLORS & STYLING ======================
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
RED="\033[1;31m"
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

# Fancy borders
BORDER="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ====================== HELPER FUNCTIONS ======================
spinner() {
    local pid=$1
    local delay=0.1
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 $pid 2>/dev/null; do
        for i in 0 1 2 3 4 5 6 7 8 9; do
            printf "\r${CYAN}[${spin:$i:1}]${RESET} $2"
            sleep $delay
        done
    done
    printf "\r${GREEN}[✓]${RESET} $2${RESET}  \n"
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
    echo -e "${DIM}                                           Version: 1.0${RESET}"
    echo
    echo -e "${CYAN}$BORDER${RESET}"
    echo
}

cleanup() {
    rm -rf /tmp/caelestia-shell-fork
    rm -rf /tmp/caelestia-cli-fork
}

trap cleanup EXIT

# ====================== START ======================
header

echo -e "${MAGENTA}Starting installation of Caelestia Animated Wallpaper patches...${RESET}"
echo

# Clone repositories
log "Cloning shell fork..."
git clone --depth 1 "$SHELL_SRC" /tmp/caelestia-shell-fork >/dev/null 2>&1 &
spinner $! "Cloning shell modules"
echo

log "Cloning CLI fork..."
git clone --depth 1 "$CLI_SRC" /tmp/caelestia-cli-fork >/dev/null 2>&1 &
spinner $! "Cloning CLI components"
echo

# Patching
log "Patching shell modules..."
sudo cp -r /tmp/caelestia-shell-fork/modules/* "$SHELL_DEST/modules/" 2>/dev/null || true
success "Shell modules patched"
echo

log "Patching shell services..."
sudo cp -r /tmp/caelestia-shell-fork/services/* "$SHELL_DEST/services/" 2>/dev/null || true
success "Shell services patched"
echo

log "Patching CLI..."
sudo cp -r /tmp/caelestia-cli-fork/src/caelestia/* "$CLI_DEST/" 2>/dev/null || true
success "CLI patched successfully"
echo

# Dependencies
log "Installing system dependencies..."
sudo pacman -S --needed --noconfirm \
    qt6-multimedia \
    ffmpeg \
    python-pillow 2>/dev/null || true
success "Dependencies installed"
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
    caelestia shell -k >/dev/null 2>&1 || true
    sleep 1.2
    caelestia shell -d >/dev/null 2>&1 || true
) &

spinner $! "Restarting Caelestia"
echo
success "Caelestia restarted"
echo
echo -e "${GREEN}$BORDER${RESET}"
echo -e "${BOLD}${GREEN}                                      Installation Complete! ${RESET}"
echo -e "${GREEN}$BORDER${RESET}"
echo
echo -e "📁 ${CYAN}Add your videos to:${RESET} ${BOLD}~/Pictures/Wallpapers/Animated${RESET}"
echo -e "🔄 Open the launcher and ${YELLOW}refresh thumbnails${RESET} to see your videos."
echo
echo
