#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.org>
#
# build.sh
#
# Builds the anduinos-butterfly-config Debian package.
# Run from the directory containing this script.
#
# Dependencies: dpkg-deb, gzip

set -euo pipefail

umask 0022

PACKAGE="anduinos-butterfly-config"
BUILD_DIR="${PACKAGE}-build"
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)"
VERSION=$(head -1 "${SOURCE_DIR}/changelog" | grep -oP '\(\K[^)]+')

# Cleanup previous build
echo "[build] Cleaning up previous build..."
rm -rf "$BUILD_DIR"

# Create directory structure
echo "[build] Creating directory structure..."
mkdir -p "$BUILD_DIR/DEBIAN"
mkdir -p "$BUILD_DIR/etc/xdg/autostart"
mkdir -p "$BUILD_DIR/usr/local/bin"
mkdir -p "$BUILD_DIR/usr/share/applications"
mkdir -p "$BUILD_DIR/usr/share/doc/butterfly-config"
mkdir -p "$BUILD_DIR/usr/share/locale/fr/LC_MESSAGES"
mkdir -p "$BUILD_DIR/usr/share/polkit-1/actions"

# DEBIAN
echo "[build] Copying DEBIAN files..."
cp "$SOURCE_DIR/DEBIAN/control"  "$BUILD_DIR/DEBIAN/"
cp "$SOURCE_DIR/DEBIAN/postinst" "$BUILD_DIR/DEBIAN/"
chmod 755 "$BUILD_DIR/DEBIAN/postinst"

# etc/xdg/autostart
echo "[build] Copying autostart desktop files..."
cp "$SOURCE_DIR/fix-power-butterfly.desktop"           "$BUILD_DIR/etc/xdg/autostart/"
cp "$SOURCE_DIR/fix-keyboard-butterfly-fr_FR.desktop"  "$BUILD_DIR/etc/xdg/autostart/"
cp "$SOURCE_DIR/wake-touchpad-butterfly.desktop"        "$BUILD_DIR/etc/xdg/autostart/"
cp "$SOURCE_DIR/welcome-butterfly.desktop"              "$BUILD_DIR/etc/xdg/autostart/"

# usr/local/bin
echo "[build] Copying scripts..."
cp "$SOURCE_DIR/fix-power-butterfly.sh"            "$BUILD_DIR/usr/local/bin/"
cp "$SOURCE_DIR/fix-keyboard-butterfly-fr_FR.sh"   "$BUILD_DIR/usr/local/bin/"
cp "$SOURCE_DIR/install-libdvd-pkg-butterfly.sh"   "$BUILD_DIR/usr/local/bin/"
cp "$SOURCE_DIR/wake-touchpad-butterfly.sh"         "$BUILD_DIR/usr/local/bin/"
cp "$SOURCE_DIR/setup-media-handling-butterfly.sh"  "$BUILD_DIR/usr/local/bin/"
cp "$SOURCE_DIR/welcome-butterfly.sh"               "$BUILD_DIR/usr/local/bin/"
cp "$SOURCE_DIR/toggle-power-butterfly.sh"          "$BUILD_DIR/usr/local/bin/"
cp "$SOURCE_DIR/general-cleaning-butterfly.sh"      "$BUILD_DIR/usr/local/bin/"
cp "$SOURCE_DIR/install-kelebek333-butterfly.sh"    "$BUILD_DIR/usr/local/bin/"
chmod 755 "$BUILD_DIR/usr/local/bin/"*.sh

# usr/share/applications
echo "[build] Copying applications desktop files..."
cp "$SOURCE_DIR/install-libdvd-pkg-butterfly.desktop"    "$BUILD_DIR/usr/share/applications/"
cp "$SOURCE_DIR/wake-touchpad-butterfly-manual.desktop"   "$BUILD_DIR/usr/share/applications/"
cp "$SOURCE_DIR/welcome-butterfly-prefs.desktop"          "$BUILD_DIR/usr/share/applications/"
cp "$SOURCE_DIR/toggle-power-butterfly.desktop"           "$BUILD_DIR/usr/share/applications/"

# usr/share/doc/butterfly-config
echo "[build] Copying documentation..."
cp "$SOURCE_DIR/README"    "$BUILD_DIR/usr/share/doc/butterfly-config/"
cp "$SOURCE_DIR/copyright" "$BUILD_DIR/usr/share/doc/butterfly-config/"
gzip -9 --no-name -c "$SOURCE_DIR/changelog" > "$BUILD_DIR/usr/share/doc/butterfly-config/changelog.gz"

#usr/share/locale/fr/LC_MESSAGES
cp "$SOURCE_DIR/welcome-butterfly_fr.mo" "$BUILD_DIR/usr/share/locale/fr/LC_MESSAGES/welcome-butterfly.mo"
cp "$SOURCE_DIR/install-libdvd-pkg-butterfly_fr.mo" "$BUILD_DIR/usr/share/locale/fr/LC_MESSAGES/install-libdvd-pkg-butterfly.mo"

# usr/share/polkit-1/actions
echo "[build] Copying polkit policy..."
cp "$SOURCE_DIR/butterfly.toggle-power.policy" "$BUILD_DIR/usr/share/polkit-1/actions/"
cp "$SOURCE_DIR/butterfly.install-libdvd-pkg.policy" "$BUILD_DIR/usr/share/polkit-1/actions/"

# md5sums
echo "[build] Generating md5sums..."
cd "$BUILD_DIR"
find . -type f ! -path './DEBIAN/*' | sort | xargs md5sum | sed 's|\./||' > DEBIAN/md5sums
cd "$SOURCE_DIR"

# Build package
echo "[build] Building package..."
chown -R root:root "$BUILD_DIR"
find "$BUILD_DIR" -type f -exec chmod 644 {} \;
find "$BUILD_DIR" -type d -exec chmod 755 {} \;
find "$BUILD_DIR" -name "*.sh" -exec chmod 755 {} \;
chmod 755 "$BUILD_DIR/DEBIAN/postinst"

dpkg-deb --build "$BUILD_DIR" "${PACKAGE}_${VERSION}.deb"

echo "[build] Done: ${PACKAGE}.deb
"
