#!/bin/bash
# Put back the working NVIDIA + hibernate boot setup (2026-10-26) and rebuild the UKI.
set -euo pipefail
cd "$(dirname "$0")"
sudo install -m 644 hook-nvidia-handoff     /etc/initcpio/hooks/nvidia-handoff
sudo install -m 644 install-nvidia-handoff  /etc/initcpio/install/nvidia-handoff
sudo install -m 644 nvidia-initrd.conf      /etc/initcpio/nvidia-initrd.conf
sudo install -m 644 zz-early-nvidia-handoff.conf /etc/mkinitcpio.conf.d/zz-early-nvidia-handoff.conf
sudo install -m 644 modprobe-nvidia.conf    /etc/modprobe.d/nvidia.conf
sudo rm -f /etc/mkinitcpio.conf.d/zz-no-early-nvidia.conf /etc/mkinitcpio.conf.d/zz-nvidia-probe.conf \
           /etc/initcpio/hooks/nvidia-probe /etc/initcpio/install/nvidia-probe \
           /etc/limine-entry-tool.d/zz-plymouth-debug.conf
sudo limine-update
echo "Restored. Reboot, then run ../check.sh"
