#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$(date +%Y%m%d)_helix_backup.tar.zst"
mkdir -p "${ROOT}/data/backups"
tar -C "${HOME}" -c .bashrc .profile .helix_aliases | zstd -o "${ROOT}/data/backups/${OUT}"
echo "Backup saved to ${ROOT}/data/backups/${OUT}"
