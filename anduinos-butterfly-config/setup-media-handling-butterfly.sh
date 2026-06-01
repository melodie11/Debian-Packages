#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.fr>
#
# setup-media-handling-butterfly.sh
#
# Configures GNOME to automatically open DVDs and audio CDs on insertion.
# Sets up a system-wide dconf policy for media handling.
# Safe to run multiple times (idempotent).
#
# Documentation:
# https://xwiki.linuxvillage.org/xwiki/bin/view/Trucs%20et%20astuces/DVD%20Vid%C3%A9o%20auto%20dans%20Gnome/

# Create the system dconf profile
cat > /etc/dconf/profile/user << 'PROFILE'
user-db:user
system-db:local
PROFILE

# Create the local database
mkdir -p /etc/dconf/db/local.d
cat > /etc/dconf/db/local.d/01-media-handling << 'DCONF'
[org/gnome/desktop/media-handling]
autorun-never=false
autorun-x-content-ignore=@as []
autorun-x-content-open-folder=@as []
autorun-x-content-start-app=['x-content/unix-software', 'x-content/ostree-repository', 'x-content/audio-cdda', 'x-content/video-dvd', 'x-content/image-dcf', 'x-content/audio-dvd']
DCONF

# Rebuild the dconf database
dconf update

echo "Done!"

