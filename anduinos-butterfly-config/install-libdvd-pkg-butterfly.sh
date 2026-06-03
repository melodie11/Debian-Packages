#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Joyce MARKOLL <contact@orditux.fr>
#
# install-libdvd-pkg-butterfly.sh
#
# Installs libdvd-pkg and builds libdvdcss2 to enable commercial DVD playback
# on Linux distributions and starts the `reconfigure` whenever needed.

export TEXTDOMAIN="install-libdvd-pkg-butterfly"
export TEXTDOMAINDIR="/usr/share/locale"

# Check if libdvdcss2 is already installed
if [ -L /usr/lib/x86_64-linux-gnu/libdvdcss.so ]; then
    exit 0
fi

# Inform the user and ask for confirmation
zenity --question \
    --title="AnduinOS Butterfly" \
    --width=450 \
    --text="$(gettext "<b>libdvd-pkg installation</b>\n\nThis program will install the libdvdcss2 library to decrypt DRM-protected commercial DVD videos.\n\nAn active internet connection is required.\n\nDo you want to continue?")" \
    --ok-label="$(gettext "Install")" \
    --cancel-label="$(gettext "Later")"

if [ $? -ne 0 ]; then
    exit 0
fi

# Launch installation in background
apt update -y && apt install -y libdvd-pkg &
INSTALL_PID=$!

# Pulsating progress bar fed while apt is running
(
    while kill -0 "$INSTALL_PID" 2>/dev/null; do
        echo "# $(gettext "Installation in progress, please wait...")"
        sleep 1
    done
    echo 100
) | zenity --progress \
    --title="AnduinOS Butterfly" \
    --width=450 \
    --text="$(gettext "Installation in progress, please wait...")" \
    --pulsate \
    --auto-close

wait $INSTALL_PID

# If libdvdcss2 was not built automatically, reconfigure
if [ ! -L /usr/lib/x86_64-linux-gnu/libdvdcss.so ]; then
    dpkg-reconfigure libdvd-pkg &
    RECONF_PID=$!

    (
        while kill -0 "$RECONF_PID" 2>/dev/null; do
            echo "# $(gettext "Configuring libdvdcss2, please wait...")"
            sleep 1
        done
        echo 100
    ) | zenity --progress \
        --title="AnduinOS Butterfly" \
        --width=450 \
        --text="$(gettext "Configuring libdvdcss2, please wait...")" \
        --pulsate \
        --auto-close

    wait $RECONF_PID
fi

# Result dialog
if [ -L /usr/lib/x86_64-linux-gnu/libdvdcss.so ]; then
    zenity --info \
        --title="AnduinOS Butterfly" \
        --width=400 \
        --ok-label="$(gettext "Close")" \
        --text="$(gettext "<b>Installation complete</b>\n\nlibdvdcss2 has been successfully installed.\nYou can now play DVD videos on your PC.")"
else
    zenity --error \
        --title="AnduinOS Butterfly" \
        --width=400 \
        --text="$(gettext "<b>Installation failed</b>\n\nAn error occurred during installation.\nPlease try again.")"
fi

