#!/bin/bash
# Restore harmony's "pre-nvidia-fix" boot state (2026-10-26): NVIDIA kept out of
# the initramfs, LUKS prompt on the internal panel only, hibernate resume working.
# Removes the early-NVIDIA handoff and rebuilds the boot image.
set -e
S=$(dirname "$(readlink -f "$0")")
sudo rm -f /etc/mkinitcpio.conf.d/zz-early-nvidia-handoff.conf \
           /etc/initcpio/install/nvidia-handoff /etc/initcpio/hooks/nvidia-handoff \
           /etc/initcpio/nvidia-initrd.conf \
           /etc/mkinitcpio.conf.d/zz-nvidia-probe.conf \
           /etc/initcpio/install/nvidia-probe /etc/initcpio/hooks/nvidia-probe
sudo cp "$S/etc/mkinitcpio.conf.d/zz-no-early-nvidia.conf" /etc/mkinitcpio.conf.d/
sudo limine-mkinitcpio
echo "Restored pre-nvidia-fix. Reboot to use it."
