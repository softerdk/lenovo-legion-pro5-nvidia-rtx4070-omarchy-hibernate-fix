# NVIDIA + hibernate on harmony — what made it work (2026-10-26)

Hybrid laptop: Intel i915 drives the internal eDP, NVIDIA (open 610-series
module, GSP) drives the external HDMI. Hibernate = any sleep → 30 min →
hibernate (`hibernate-after-sleep` system-sleep hook).

## The problem
Root needs `NVreg_PreserveVideoMemoryAllocations=1` (ordinary S3/s2idle sleep
garbles HDMI without it). But nvidia was also loaded early in the initramfs
with the same option. On a hibernate resume the *boot* kernel has to freeze
its nvidia before jumping into the image, and with Preserve=1 and no
`/proc/driver/nvidia/suspend` that fails:
`nv_pmops_freeze -5` → resume aborted → cold boot (Oct 23).

## The fix (three parts)
1. **Initramfs-only nvidia options** — `nvidia-initrd.conf`, copied into the
   initramfs as `/etc/modprobe.d/zz-nvidia-initrd.conf`:
   `PreserveVideoMemoryAllocations=0`, `nvidia_drm fbdev=0`. The boot kernel
   has no video memory worth keeping; no fbdev so only plymouth holds the driver.
2. **`nvidia-handoff` hook, placed after `encrypt` and BEFORE `resume`**
   (`zz-early-nvidia-handoff.conf` inserts it). It quits plymouth and rmmods
   nvidia_drm/uvm/modeset/nvidia, retrying up to 25× 0.2 s (plymouth can hold
   nvidia-drm briefly after quit — the 13:14 boot failed without the retry).
   - Resume path: GPU is free when the image takes over → the restored kernel's
     own nvidia resumes cleanly.
   - Cold boot: udev in the real root reloads nvidia with Preserve=1.
   - Variant 1 ran the hook *after* resume → restored nvidia hit Xid 31 (MMU
     fault restoring VRAM), black screens. Order matters.
3. **Root keeps** `/etc/modprobe.d/nvidia.conf`: Preserve=1,
   `TemporaryFilePath=/var/tmp`; nvidia-suspend/hibernate/resume units enabled.

## Verified
- 12:46 suspend → hibernate → resume: desktop back on HDMI, no Xid, Preserve=1.
- 13:28 final re-test after a clean reboot (13:25, 0 retries): suspend → 30 s →
  hibernate → resume, all smooth; shell restarted, delay back to 1800 s.
- Cold boots: handoff logs `nvidia unloaded before resume (N retries)`, Preserve=1.
- Check any time with `../check.sh`.

## Accepted limitation
LUKS prompt shows on the internal screen only. Tried: plymouth debug, a
connector-probe hook (got HDMI detected in initramfs) — plymouth then built
an HDMI head but nvidia-drm flips timed out (black HDMI) and the omarchy
logo got clipped on eDP. Not worth chasing; probe and debug flag removed.

## Gotchas
- If the handoff log says "could not unload", that boot runs Preserve=0 →
  do NOT sleep/hibernate, reboot first.
- `plymouth.debug=stream:/dev/kmsg` makes root plymouthd abort on quit → 20 s
  black screen before SDDM. Use plain `plymouth.debug` if debugging again.
- After a forced power-off, Bluetooth may come up rfkill soft-blocked:
  `rfkill unblock bluetooth`.

Rollback: `restore.sh` here (this state) or `../pre-nvidia-fix/restore.sh`
(nvidia kept out of initramfs entirely). UKI copy here is gitignored.
