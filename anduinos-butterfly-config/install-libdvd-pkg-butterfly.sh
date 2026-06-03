#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026 Joyce MARKOLL <contact@orditux.fr>
#
# install-libdvd-pkg-butterfly.sh
#
# Installs libdvd-pkg and builds libdvdcss2 to enable commercial DVD playback
# on Linux distributions and starts the `reconfigure` whenever needed.

REAL_HOME=$(getent passwd $PKEXEC_UID | cut -d: -f6)
REAL_LANG=$(cat "$REAL_HOME/.config/user-dirs.locale" 2>/dev/null)
SYS_LANG=$(grep "^LANG=" /etc/default/locale | cut -d= -f2 | tr -d '"')

export LANG="${SYS_LANG:-${REAL_LANG}.UTF-8}"
export LANGUAGE="${REAL_LANG%%_*}"

export TEXTDOMAIN="install-libdvd-pkg-butterfly"
export TEXTDOMAINDIR="/usr/share/locale"

# Check if libdvdcss2 is already installed
if [ -L /usr/lib/x86_64-linux-gnu/libdvdcss.so ]; then
    zenity --info \
        --title="AnduinOS Butterfly" \
        --width=400 \
        --ok-label="$(gettext "Close")" \
        --text="$(gettext "libdvdcss2 is already installed. Nothing to do.")"
    exit 0
fi

# Inform the user and ask for confirmation
title=$(gettext "libdvd-pkg installation")
body1=$(gettext "This program will install the libdvdcss2 library.")
body2=$(gettext "An active internet connection is required.")
body3=$(gettext "Do you want to continue?")
question_text="<b>${title}</b>\n\n${body1}\n${body2}\n\n${body3}"

zenity --question \
    --title="AnduinOS Butterfly" \
    --width=450 \
    --text="$question_text" \
    --ok-label="$(gettext "Install")" \
    --cancel-label="$(gettext "Later")" || exit 0

# Network connectivity test
if ! ping -c 4 eu.org &>/dev/null; then
    zenity --error \
        --title="AnduinOS Butterfly" \
        --width=400 \
        --text="$(gettext "No internet connection detected. Please check your network and try again.")"
    exit 1
fi

# Check libdvd-pkg dependencies
missing=""
for pkg in build-essential wget devscripts debhelper; do
    if ! dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
        missing="$missing $pkg"
    fi
done

if [ -n "$missing" ]; then
    body1=$(gettext "The following required packages are missing:")
    body2=$(gettext "Do you want to install them now?")

    zenity --question \
        --title="AnduinOS Butterfly" \
        --width=400 \
        --text="${body1} ${missing}\n\n${body2}" \
        --ok-label="$(gettext "Install")" \
        --cancel-label="$(gettext "Cancel")" || exit 0

    apt install -y $missing &
    DEP_PID=$!

    (
        while kill -0 "$DEP_PID" 2>/dev/null; do
            echo "# $(gettext "Installing missing dependencies, please wait...")"
            sleep 1
        done
        echo 100
    ) | zenity --progress \
        --title="AnduinOS Butterfly" \
        --width=450 \
        --text="$(gettext "Installing missing dependencies, please wait...")" \
        --pulsate \
        --auto-close

    wait $DEP_PID
fi

# Launch installation in background
(
    apt update &&
    apt install -y libdvd-pkg
) &
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
    result_title=$(gettext "Installation complete")
    result_body1=$(gettext "libdvdcss2 has been successfully installed.")
    result_body2=$(gettext "You can now play more DVD videos on your PC.")
    result_text="<b>${result_title}</b>\n\n${result_body1}\n${result_body2}"
    zenity --info \
        --title="AnduinOS Butterfly" \
        --width=400 \
        --ok-label="$(gettext "Close")" \
        --text="$result_text"
else
    error_title=$(gettext "Installation failed")
    error_body1=$(gettext "An error occurred during installation.")
    error_body2=$(gettext "Please try again.")
    error_text="<b>${error_title}</b>\n\n${error_body1}\n${error_body2}"
    zenity --error \
        --title="AnduinOS Butterfly" \
        --width=400 \
        --text="$error_text"
fi

