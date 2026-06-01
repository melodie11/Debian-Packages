#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.fr>
#
# toggle-power-butterfly.sh
#
# Toggles the Butterfly power management fix on or off.
# - OFF: disables fix-power-butterfly.desktop from autostart and restores
#        GNOME default power settings via dconf reset.
# - ON:  re-enables fix-power-butterfly.desktop in autostart and applies
#        Butterfly power settings immediately.
#
# Dependencies: dconf, gsettings, yad

DESKTOP_FILE="/etc/xdg/autostart/fix-power-butterfly.desktop"
FIX_SCRIPT="/usr/local/bin/fix-power-butterfly.sh"

# ── Detect current state ───────────────────────────────────────────────────
if grep -q "^Hidden=true" "$DESKTOP_FILE" 2>/dev/null; then
    CURRENT_STATE="off"
else
    CURRENT_STATE="on"
fi

# ── Toggle ─────────────────────────────────────────────────────────────────
if [ "$CURRENT_STATE" = "on" ]; then

    # Disable autostart
    sed -i '/^Hidden=true/d' "$DESKTOP_FILE"
    echo "Hidden=true" >> "$DESKTOP_FILE"

    # Restore GNOME defaults
    dconf reset -f /org/gnome/settings-daemon/plugins/power/
	gsettings reset org.gnome.desktop.session idle-delay
	gsettings reset org.gnome.desktop.screensaver lock-enabled
	gsettings reset org.gnome.desktop.screensaver idle-activation-enabled

    MESSAGE="Power management fix disabled. GNOME defaults restored."

else

    # Re-enable autostart
    sed -i '/^Hidden=true/d' "$DESKTOP_FILE"

    # Apply Butterfly settings immediately
    bash "$FIX_SCRIPT"

    MESSAGE="Power management fix enabled."

fi

# ── Notify user ────────────────────────────────────────────────────────────
zenity --info \
    --title="Butterfly – Power Management" \
    --text="$MESSAGE" \
	--ok-label="OK"

