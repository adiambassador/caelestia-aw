#!/usr/bin/env bash

set -euo pipefail

#  COLORS & STYLING
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
RED="\033[1;31m"
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"

BORDER="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# HELPERS
spinner() {
    local pid=$1
    local delay=0.1
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while kill -0 "$pid" 2>/dev/null; do
        for i in 0 1 2 3 4 5 6 7 8 9; do
            printf "\r${CYAN}[${spin:$i:1}]${RESET} $2"
            sleep "$delay"
        done
    done
    printf "\r${GREEN}[✓]${RESET} $2  \n"
}

log()     { echo -e "${BLUE}[INFO]${RESET} $1"; }
success() { echo -e "${GREEN}[✓]${RESET} $1"; }
warn()    { echo -e "${YELLOW}[⚠]${RESET} $1"; }
error()   { echo -e "${RED}[✗]${RESET} $1"; exit 1; }

header() {
    clear
    echo -e "${RED}"
    cat << "EOF"
		                ┏━╸┏━┓┏━╸╻  ┏━╸┏━┓╺┳╸╻┏━┓   ┏━┓╻ ╻
                        	┃  ┣━┫┣╸ ┃  ┣╸ ┗━┓ ┃ ┃┣━┫╺━╸┣━┫┃╻┃
            		        ┗━╸╹ ╹┗━╸┗━╸┗━╸┗━┛ ╹ ╹╹ ╹   ╹ ╹┗┻┛
EOF
    echo -e "${RESET}${BOLD}		                  Caelestia Animated Wallpaper Uninstaller${RESET}"
    echo -e "${DIM}                              This will restore vanilla Caelestia${RESET}"
    echo
    echo -e "${RED}$BORDER${RESET}"
    echo
}

detect_aur_helper() {
    if command -v paru >/dev/null 2>&1; then
        echo "paru"
    elif command -v yay >/dev/null 2>&1; then
        echo "yay"
    else
        echo ""
    fi
}

# main
header

echo -e "${YELLOW}This will restore Caelestia to vanilla upstream.${RESET}"
echo -e "${DIM}Your wallpaper library and Hyprland config will remain intact.${RESET}"
echo -e "${DIM}Only the Caelestia shell and CLI patches will be reverted.${RESET}"
echo
read -rp "$(echo -e "${BOLD}Continue? [y/N]: ${RESET}")" confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { warn "Aborted."; exit 0; }
echo


AUR_HELPER=$(detect_aur_helper)
if [[ -z "$AUR_HELPER" ]]; then
    error "No AUR helper found (yay/paru). Cannot reinstall upstream packages."
fi
log "Using AUR helper: $AUR_HELPER"
echo


log "Reinstalling upstream caelestia-shell from AUR..."
(
    "$AUR_HELPER" -S --noconfirm caelestia-shell >/dev/null 2>&1 || true
) &
spinner $! "Restoring vanilla shell. This may take a while."
echo
success "Shell restored to upstream"
echo

log "Reinstalling upstream caelestia-cli from AUR..."
(
    "$AUR_HELPER" -S --noconfirm caelestia-cli >/dev/null 2>&1 || true
) &
spinner $! "Restoring vanilla CLI"
echo
success "CLI restored to upstream"
echo

# REMOVE ENV VAR
HYPRCONF="$HOME/.config/hypr/hyprland.conf"
if grep -q "QT_FFMPEG_DECODING_HW_DEVICE_TYPES" "$HYPRCONF" 2>/dev/null; then
    log "Removing hardware decoding env var from Hyprland config..."
    sed -i '/QT_FFMPEG_DECODING_HW_DEVICE_TYPES/d' "$HYPRCONF"
    success "Hyprland config cleaned"
else
    warn "No hardware decoding env var found — skipping"
fi
echo

THUMB_CACHE="$HOME/.cache/caelestia/videothumbs"
if [[ -d "$THUMB_CACHE" ]]; then
    read -rp "$(echo -e "${BOLD}Remove video thumbnail cache? [y/N]: ${RESET}")" clear_cache
    if [[ "$clear_cache" =~ ^[Yy]$ ]]; then
        rm -rf "$THUMB_CACHE"
        success "Thumbnail cache cleared"
    else
        warn "Thumbnail cache kept at $THUMB_CACHE"
    fi
    echo
fi

# RESTART SHELL
log "Restarting Caelestia..."
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
echo -e "${BOLD}${GREEN}                              Uninstall Complete — Vanilla Caelestia restored.${RESET}"
echo -e "${GREEN}$BORDER${RESET}"
echo
