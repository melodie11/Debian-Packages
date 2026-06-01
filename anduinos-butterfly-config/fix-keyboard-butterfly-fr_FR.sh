#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.fr>
#
# fix-keyboard-butterfly.sh
#
# Configures the keyboard layout to French AZERTY on AnduinOS Butterfly.
# The default AnduinOS skel dconf profile hardcodes 'us' as primary layout.
# Runs at each login - only applies changes if needed (idempotent).

# Check current keyboard layout
expected_sources="[('xkb', 'fr')]"
current_sources=$(dconf read /org/gnome/desktop/input-sources/sources)

if [ "$current_sources" != "$expected_sources" ]; then
    dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'fr')]"
    dconf write /org/gnome/desktop/input-sources/mru-sources "[('xkb', 'fr')]"
fi

