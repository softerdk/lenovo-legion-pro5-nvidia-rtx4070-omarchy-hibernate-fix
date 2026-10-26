# harmony-boot-states

Named snapshots of harmony's boot setup (initramfs drop-ins, modprobe options,
kernel cmdline, UKI) so an experiment can be rolled back.

- `pre-nvidia-fix/` — 2026-10-26: NVIDIA kept out of the initramfs, LUKS prompt
  on the internal panel only, hibernate resume working. `restore.sh` returns to it.
  The UKI copy is kept locally (gitignored).
- `check.sh` — after a boot or hibernate resume, shows whether the
  early-NVIDIA handoff did its job.
