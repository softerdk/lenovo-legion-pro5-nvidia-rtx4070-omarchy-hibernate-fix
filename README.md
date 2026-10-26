# lenovo-legion-pro5-nvidia-rtx4070-omarchy-hibernate-fix

Working **suspend → hibernate → resume** with the NVIDIA open driver on a hybrid
laptop running [Omarchy](https://omarchy.org) (Arch, Hyprland), with LUKS
full-disk encryption, a btrfs swapfile and a Limine-booted UKI.

**Hardware:** Lenovo Legion Pro 5 16IRX8 (82WK), Intel Raptor Lake UHD (i915,
internal eDP) + NVIDIA GeForce RTX 4070 Mobile (AD106M, nvidia-open, drives
the HDMI port).

## Symptoms this fixes
- Hibernate "works" but resume fails: `nv_pmops_freeze ... -5`,
  `PM: resume failed (-5)` → the laptop cold-boots and the session is lost.
- Moving nvidia out of the initramfs fixes resume but swaps DRM probe order
  (panel renamed eDP-2 → eDP-1) and leaves only i915 early.
- Running nvidia in the initramfs and unloading it *after* resume → Xid 31
  (MMU fault restoring VRAM), black screens.

## The fix in short
1. Load nvidia early in the initramfs with **initramfs-only** options:
   `NVreg_PreserveVideoMemoryAllocations=0`, `nvidia_drm fbdev=0`.
2. A small `nvidia-handoff` initcpio hook, placed after `encrypt` and
   **before `resume`**, quits plymouth and unloads nvidia, so the GPU is free
   when the hibernation image takes over.
3. The real root keeps `PreserveVideoMemoryAllocations=1` (needed for ordinary
   sleep) with the nvidia-suspend/hibernate/resume units enabled.

The full explanation is in
[`nvidia-hibernate-working/NOTES.md`](nvidia-hibernate-working/NOTES.md).

## Layout
- `nvidia-hibernate-working/` — the current, verified setup and its
  `restore.sh` (installs the files and rebuilds the UKI with `limine-update`).
- `pre-nvidia-fix/` — the earlier state (nvidia kept out of the initramfs),
  with its own `restore.sh`, for rollback.
- `nvidia-probe/`, `plymouth-debug-flag/` — parked diagnostics from an
  abandoned attempt to show the LUKS prompt on HDMI. Not installed.
- `check.sh` — run after a boot or a hibernate resume to see whether the
  handoff did its job.
- `nvidia-hibernate-working/hibernate-after-sleep` — optional
  `/usr/lib/systemd/system-sleep/` hook: any sleep → 30 min → hibernate
  (works around logind refusing hibernate while Bitwarden holds
  `memfd_secret` memory). Its shell-restart line calls a local script; adapt
  or drop it.

## Using it on your machine
These are snapshots of one machine's config, not an installer. Read
`NOTES.md`, compare the files with your own (`/etc/mkinitcpio.conf.d/`,
`/etc/modprobe.d/`, your kernel cmdline with `resume=` / `resume_offset=`),
and adapt before running any `restore.sh`. `cmdline.txt` is for reference;
its PARTUUID is a placeholder.

Known limitation: the LUKS password prompt shows on the internal screen only.

Tested 2026-10-26: kernel 7.2 (Omarchy), nvidia-open 615.78, Limine UKI.
