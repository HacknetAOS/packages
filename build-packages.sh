#!/bin/bash
# Build all HacknetAOS Arch Linux packages and generate the pacman repository database.
# Run as a non-root user (uses fakeroot via makepkg).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export HACKNET_SRC="${HACKNET_SRC:-$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)}"
PKG_DIR="${PKG_DIR:-$SCRIPT_DIR/pkg-out}"
GPG_KEY="${GPG_KEY_ID:-6D9D481F4ACB997F919BCA90D9069C156B0C606C}"

mkdir -p "$PKG_DIR"

echo "=== Building HacknetAOS packages ==="
echo "Source root: $HACKNET_SRC"
echo "Output dir:  $PKG_DIR"

for pkg in hacknet-keyring yay hacknet-proto hacknet-theme hacknetd hacknetctl hacknet-shell hacknet-os; do
    echo ""
    echo "--- Building $pkg ---"
    cd "$SCRIPT_DIR/$pkg"

    rm -rf src pkg *.pkg.tar.zst *.log

    MAKEPKG_ARGS=("-f" "-d" "--noconfirm" "--skippgpcheck")

    if makepkg "${MAKEPKG_ARGS[@]}" 2>&1 | tee "$PKG_DIR/$pkg.log"; then
        rm -f *-debug-*.pkg.tar.zst
        rm -f "$PKG_DIR/${pkg}"-[0-9]*.pkg.tar.zst "$PKG_DIR/${pkg}-debug"-[0-9]*.pkg.tar.zst
        mv *.pkg.tar.zst "$PKG_DIR/" 2>/dev/null || true
        echo "OK: $pkg"
    else
        echo "FAILED: $pkg" >&2
        exit 1
    fi
done

if gpg --list-secret-keys "$GPG_KEY" >/dev/null 2>&1; then
    echo ""
    echo "=== Signing packages with GPG key $GPG_KEY ==="
    cd "$PKG_DIR"
    for p in *.pkg.tar.zst; do
        rm -f "${p}.sig"
        gpg --batch --yes --detach-sign --no-armor -u "$GPG_KEY" "$p"
    done
fi

echo ""
echo "=== Generating pacman repository database ==="
cd "$PKG_DIR"
rm -f hacknetos.db* hacknetos.files*
if gpg --list-secret-keys "$GPG_KEY" >/dev/null 2>&1; then
    repo-add --sign --key "$GPG_KEY" hacknetos.db.tar.gz *.pkg.tar.zst
else
    repo-add hacknetos.db.tar.gz *.pkg.tar.zst
fi

# Replace symlinks created by repo-add with regular files so static web hosts (GitHub Pages) serve them properly
rm -f hacknetos.db hacknetos.files hacknetos.db.sig hacknetos.files.sig
cp -f hacknetos.db.tar.gz hacknetos.db
cp -f hacknetos.files.tar.gz hacknetos.files
if [ -f hacknetos.db.tar.gz.sig ]; then
    cp -f hacknetos.db.tar.gz.sig hacknetos.db.sig
    cp -f hacknetos.files.tar.gz.sig hacknetos.files.sig
fi

echo ""
echo "=== Build complete ==="
ls -la "$PKG_DIR"/*.pkg.tar.zst
