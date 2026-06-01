#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.fr>
#
# install-libdvd-pkg-butterfly.sh
#
# Installs libdvd-pkg and builds libdvdcss2 to enable commercial DVD playback
# on AnduinOS Butterfly.

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
    --text="$(gettext "<b>Installation de libdvd-pkg</b>\n\nCe programme installera la bibliothèque libdvdcss2 pour déchiffrer les DVD vidéos dotés de DRM (Digital Rights Management).\n\nUne connexion internet fonctionnelle est nécessaire.\n\nVoulez-vous continuer ?")" \
    --ok-label="$(gettext "Installer")" \
    --cancel-label="$(gettext "Plus tard")"

if [ $? -ne 0 ]; then
    exit 0
fi

# Show pulsating progress bar during installation
zenity --progress \
    --title="AnduinOS Butterfly" \
    --width=450 \
    --text="$(gettext "Installation en cours, veuillez patienter...")" \
    --pulsate \
    --auto-close &
ZENITY_PID=$!

# Install libdvd-pkg
apt update -y && apt install -y libdvd-pkg

# Check if libdvdcss2 was built automatically
if [ ! -L /usr/lib/x86_64-linux-gnu/libdvdcss.so ]; then
    dpkg-reconfigure libdvd-pkg
fi

# Close progress bar
kill $ZENITY_PID 2>/dev/null

# Result dialog
if [ -L /usr/lib/x86_64-linux-gnu/libdvdcss.so ]; then
    zenity --info \
        --title="AnduinOS Butterfly" \
        --width=400 \
        --ok-label="$(gettext "Fermer")" \
        --text="$(gettext "<b>Installation terminée</b>\n\nlibdvdcss2 a été installé avec succès.\nVous pouvez maintenant lire les DVD vidéo sur votre PC.")"
else
    zenity --error \
        --title="AnduinOS Butterfly" \
        --width=400 \
        --text="$(gettext "<b>Échec de l'installation</b>\n\nUne erreur est survenue pendant l'installation.\nVeuillez réessayer.")"
fi

