#!/bin/bash
# Check the early-NVIDIA handoff after a boot or a hibernate resume.
echo "== handoff (cold boot only):"; journalctl -k -b --no-pager | grep nvidia-handoff || echo "   (no handoff line: resumed from hibernate, or hook did not run)"
echo "== nvidia params in this session (want Preserve 1):"; grep -E 'PreserveVideo|TemporaryFile' /proc/driver/nvidia/params
echo "== resume / freeze errors:"; journalctl -k -b --no-pager | grep -E 'resume failed|nv_pmops|hibernation exit' || echo "   none"
[[ -x ~/fumast3r/quickshell-watch/tpm-check.sh ]] && { echo "== TPM:"; ~/fumast3r/quickshell-watch/tpm-check.sh; }
