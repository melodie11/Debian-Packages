#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.fr>
#
# install-kelebek-butterfly.sh
#
# Adds the kelebek333 PPA and installs Warpinator, Hypnotix and Webapp-Manager.
# Run manually after installing the anduinos-butterfly-config package,
# or from within the Cubic chroot before rebuilding the ISO.
#
# Dependencies: software-properties-common
 
set -euo pipefail
 
echo "Adding kelebek333 PPA..."
add-apt-repository -y ppa:kelebek333/mint-tools
 
echo "Updating package lists..."
apt update
 
echo "Installing packages..."
apt install -y warpinator hypnotix webapp-manager
 
echo ""
echo "Done. Warpinator, Hypnotix and Webapp-Manager are installed."
echo ""

