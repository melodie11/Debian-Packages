#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Joyce MARKOLL <contact@orditux.fr>
#
# wake-touchpad-butterfly.sh
#
# Fix touchpad not responding after resume from suspend,
# for devices using the Synaptics RMI4 SMBus driver (rmi_smbus).
# Tested on HP EliteBook 840 G1 running AnduinOS Butterfly.
#
# This script creates and enables a systemd service that reloads
# the rmi_smbus kernel module after each resume from suspend.
#
# Only runs on laptops, detected via DMI chassis type.
# Chassis types considered as laptops: 8 (Portable), 9 (Laptop),
# 10 (Notebook), 11 (Sub Notebook).

# Detect chassis type
CHASSIS=$(cat /sys/class/dmi/id/chassis_type)

# Only proceed if we are on a laptop
if [[ "$CHASSIS" =~ ^(8|9|10|11)$ ]]; then

    # Check if service is already installed and enabled
    if systemctl is-enabled touchpad-resume.service &>/dev/null; then
        echo "touchpad-resume.service is already installed and enabled."
        exit 0
    fi

    # Create the systemd service file
    cat > /etc/systemd/system/touchpad-resume.service << EOF
[Unit]
Description=Restart touchpad after resume
After=suspend.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c "rmmod rmi_smbus && modprobe rmi_smbus"

[Install]
WantedBy=suspend.target
EOF

    # Reload systemd, enable and start the service
    systemctl daemon-reload
    systemctl enable --now touchpad-resume.service
    echo "touchpad-resume.service installed and enabled."

else
    echo "Not a laptop (chassis type: $CHASSIS), skipping touchpad fix."
    exit 0
fi

