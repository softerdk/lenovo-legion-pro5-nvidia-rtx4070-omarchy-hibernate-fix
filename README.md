# harmony-boot-states

Named snapshots of harmony's boot setup (initramfs drop-ins, modprobe options,
kernel cmdline, UKI) so an experiment can be rolled back.

- `pre-nvidia-fix/` — 2026-10-26: NVIDIA kept out of the initramfs, LUKS prompt
  on the internal panel only, hibernate resume working. `restore.sh` returns to it.
  The UKI copy is kept locally (gitignored).
- `nvidia-hibernate-working/` — 2026-10-26, CURRENT: early NVIDIA in the initramfs
  with the `nvidia-handoff` hook before `resume`; hibernate resume works, LUKS prompt
  internal only. See `NOTES.md` there for what made it work. `restore.sh` returns to it.
- `nvidia-probe/`, `plymouth-debug-flag/` — parked diagnostics from the HDMI-prompt
  attempt (abandoned), not installed.
- `check.sh` — after a boot or hibernate resume, shows whether the
  early-NVIDIA handoff did its job.
