#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.fr>
#
# fix-power-butterfly.sh
#
# Configures power management settings to prevent sleep and
# screen lock to be triggered automatically on AnduinOS Butterfly.
# Runs at each login - only applies changes if needed (idempotent).
#
# Dependencies: dconf, gsettings

# Power and sleep management (gnome-settings-daemon)

expected_ac_type="'nothing'"
current_ac_type=$(dconf read /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type)

if [ "$current_ac_type" != "$expected_ac_type" ]; then
    dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout 0
    dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-timeout 0
    dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'nothing'"
    dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-battery-type "'nothing'"
    dconf write /org/gnome/settings-daemon/plugins/power/idle-dim false
    dconf write /org/gnome/settings-daemon/plugins/power/power-button-action "'interactive'"

    # Session lock and idle delay (gnome-desktop)
    gsettings set org.gnome.desktop.session idle-delay 0
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
fi

