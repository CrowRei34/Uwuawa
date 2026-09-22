#!/usr/bin/env bash
set -Eeuo pipefail

APP_ROOT=/opt/cspenguin
export CSPENGUIN_CPAK=1
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/cspenguin-cpak"
WINE_VERSION=11.4
WINE_URL="https://github.com/Kron4ek/Wine-Builds/releases/download/${WINE_VERSION}/wine-${WINE_VERSION}-amd64.tar.xz"
WINE_SHA256=b98761339edb5cf9a3f622fa08de2d4b453ab96e2b5d8a612aa3687ea6ec523
WINE_ARCHIVE="$DATA_DIR/wine-${WINE_VERSION}-amd64.tar.xz"
WINE_DIR="$DATA_DIR/wine-${WINE_VERSION}"
PREFIX="${WINEPREFIX:-$HOME/.wine-csp}"
PAINT_EXE="$PREFIX/drive_c/Program Files/CELSYS/CLIP STUDIO 1.5/CLIP STUDIO PAINT/CLIPStudioPaint.exe"
PAINT_LAUNCHER="$HOME/.local/share/cspenguin/csp-launch.sh"
STUDIO_LAUNCHER="$HOME/.local/share/cspenguin/clipstudio-launch.sh"
_launcher="$PAINT_LAUNCHER"
[[ "$(basename "$0")" == "cspenguin-studio-cpak" ]] && _launcher="$STUDIO_LAUNCHER"

if [[ -x "$_launcher" && -f "$PAINT_EXE" ]]; then
    exec "$_launcher" "$@"
fi

_find_wine() {
    local _candidate
    if [[ -n "${CSPENGUIN_WINE:-}" ]]; then
        _candidate="$CSPENGUIN_WINE"
        [[ -x "$_candidate" ]] && { printf '%s\n' "$_candidate"; return; }
    fi
    for _candidate in \
        "$HOME/.local/share/cspenguin"/wine-*/bin/wine \
        "$DATA_DIR"/wine-*/bin/wine; do
        [[ -x "$_candidate" ]] && { printf '%s\n' "$_candidate"; return; }
    done
    command -v wine 2>/dev/null || true
}

_wine_dir() {
    local _wine_bin="$1"
    if [[ "$_wine_bin" == */bin/wine ]]; then
        dirname "$(dirname "$_wine_bin")"
    else
        dirname "$_wine_bin"
    fi
}

_download_wine() {
    local _tmp="${WINE_ARCHIVE}.part" _candidate
    mkdir -p "$DATA_DIR"
    if [[ ! -s "$WINE_ARCHIVE" ]] || \
       ! printf '%s  %s\n' "$WINE_SHA256" "$WINE_ARCHIVE" | sha256sum -c - >/dev/null 2>&1; then
        curl -fL --retry 3 --connect-timeout 30 -o "$_tmp" "$WINE_URL"
        printf '%s  %s\n' "$WINE_SHA256" "$_tmp" | sha256sum -c -
        mv "$_tmp" "$WINE_ARCHIVE"
    fi
    if [[ ! -x "$WINE_DIR/bin/wine" ]]; then
        rm -rf "$WINE_DIR"
        tar -xJf "$WINE_ARCHIVE" -C "$DATA_DIR"
        for _candidate in \
            "$DATA_DIR/wine-${WINE_VERSION}-amd64" \
            "$DATA_DIR/wine-${WINE_VERSION}-staging-amd64" \
            "$DATA_DIR/wine-${WINE_VERSION}-plain-amd64"; do
            if [[ -d "$_candidate" ]]; then
                mv "$_candidate" "$WINE_DIR"
                break
            fi
        done
    fi
    [[ -x "$WINE_DIR/bin/wine" ]] || { printf '%s\n' "Wine extraction failed" >&2; exit 1; }
}

_wine_bin="$(_find_wine)"
if [[ -n "$_wine_bin" ]]; then
    export CSPENGUIN_WINE_DIR="$(_wine_dir "$_wine_bin")"
else
    _download_wine
    export CSPENGUIN_WINE_DIR="$WINE_DIR"
fi

if [[ -t 0 && -t 1 ]]; then
    "$APP_ROOT/install.sh" "$@"
else
    command -v xterm >/dev/null 2>&1 || {
        printf '%s\n' "A terminal is required for the first launch." >&2
        exit 1
    }
    xterm -T "CSPenguin Setup" -e "$APP_ROOT/install.sh" "$@"
fi
[[ -x "$_launcher" ]] || { printf '%s\n' "Clip Studio Paint is not installed" >&2; exit 1; }
exec "$_launcher" "$@"
