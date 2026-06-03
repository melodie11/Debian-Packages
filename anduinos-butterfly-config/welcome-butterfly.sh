#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.fr>
#
# welcome-butterfly.sh
#
# Displays a welcome message at first login, providing useful information
# about the system and installed applications.
#
# The message is displayed at each login until the user chooses to
# disable it. It remains accessible from the Preferences menu.
#
# Dependencies: zenity, gettext

export TEXTDOMAIN="welcome-butterfly"
export TEXTDOMAINDIR="/usr/share/locale"

# Create the anduinos config directory if it doesn't exist
mkdir -p "$HOME/.config/anduinos"

# Flag file : if it exists, the message is not shown at startup
FLAG="$HOME/.config/anduinos/welcome.skip"

# If launched from autostart and flag exists, exit silently
if [ "$1" = "--autostart" ] && [ -f "$FLAG" ]; then
    exit 0
fi

# Display the welcome message

legal1=$(gettext "We invite you to verify the legality")
legal2=$(gettext "of using libdvdcss2 in your country.")

zenity --info \
    --title="$(gettext "Welcome to AnduinOS Butterfly")" \
    --width=600 \
    --ok-label="$(gettext "Close")" \
    --text="$(gettext "This system includes the PPA provided and maintained by kelebek333, which makes the following applications available :")\n\n\
<b>Warpinator</b> : $(gettext "share files over a local network.")\n\
<b>Webapp-manager</b> : $(gettext "create a shortcut on the desktop to a website of your choice.")\n\
<b>Hypnotix</b> : $(gettext "IPTV player, to watch television channels.")\n\n\
<b>$(gettext "Installing additional applications")</b>\n\
$(gettext "You can install additional applications from") <b>Synaptic</b> $(gettext "or from the") <b>$(gettext "Software Center")</b>.\n\n\
<b>$(gettext "Playing commercial DVDs")</b>\n\
$(gettext "Commercial DVDs are often encrypted with DRM (Digital Rights Management). To enable their playback, click the three stacked rectangles icon of the panel, then search for") <b>$(gettext "Install DVD Support")</b>.\n\
\n${legal1} ${legal2}"

# Ask the user if they want to stop showing the message at startup
zenity --question \
    --title="AnduinOS Butterfly" \
    --width=400 \
    --text="$(gettext "Do you want to show this message at startup?")" \
	--ok-label="$(gettext "No, don't show again")" \
	--cancel-label="$(gettext "Yes, show again")"

# If the user chose to stop showing the message, create the flag file
if [ $? = 0 ]; then
    touch "$FLAG"
fi

