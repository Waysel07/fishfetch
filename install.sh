#!/usr/bin/env sh
# Install fishfetch for the current user (or system-wide with PREFIX=/usr/local).
#   ./install.sh               -> ~/.local/bin/fishfetch, ~/.local/share/fishfetch/frames
#   sudo PREFIX=/usr/local ./install.sh
#   ./install.sh --uninstall
set -eu
cd "$(dirname "$0")"
PREFIX=${PREFIX:-$HOME/.local}
BIN=$PREFIX/bin
SHARE=$PREFIX/share/fishfetch

if [ "${1:-}" = "--uninstall" ]; then
    rm -f "$BIN/fishfetch"
    rm -rf "$SHARE"
    echo "removed fishfetch from $PREFIX"
    exit 0
fi

command -v fastfetch >/dev/null || echo "note: fastfetch is not installed; fishfetch needs it" >&2
install -Dm755 fishfetch "$BIN/fishfetch"
mkdir -p "$SHARE/frames"
install -m644 frames/frame-*.txt "$SHARE/frames/"
echo "installed: $BIN/fishfetch"
case ":$PATH:" in *":$BIN:"*) ;; *) echo "note: add $BIN to your PATH" >&2 ;; esac
