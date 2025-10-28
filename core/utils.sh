#!/usr/bin/env bash
set -euo pipefail

# Basic utils used across scripts

info()  { printf "\e[34m[INFO]\e[0m %s\n" "$*"; }
warn()  { printf "\e[33m[WARN]\e[0m %s\n" "$*"; }
error() { printf "\e[31m[ERROR]\e[0m %s\n" "$*"; exit 1; }

# PROJECT_ROOT is repo root (one level up from core/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN_DIR="${PROJECT_ROOT}/bin"

# Ensure common dirs exist
ensure_dirs() {
  mkdir -p "${PROJECT_ROOT}/config" "${PROJECT_ROOT}/data/logs" "${PROJECT_ROOT}/data/backups" "${BIN_DIR}"
}

is_termux() {
  # Check typical Termux environment markers
  [[ -n "${TERMUX_VERSION:-}" ]] || grep -q "com.termux" /proc/1/cmdline 2>/dev/null || return 1
}

require_termux() {
  if ! is_termux; then
    error "This script is intended to run inside Termux."
  fi
}

backup_dir() {
  ensure_dirs
  mkdir -p "${PROJECT_ROOT}/data/backups"
  printf '%s\n' "${PROJECT_ROOT}/data/backups"
}

# Shizuku detection: command existence is a safe check
detect_shizuku() {
  command -v shizuku >/dev/null 2>&1
}

# Simple confirm helper
confirm() {
  local prompt="${1:-Continue?}"
  local default_yes="${2:-false}"  # set true to default to yes in non-interactive env
  # If non-interactive environment (CI or TERM not interactive), return default
  if [[ ! -t 0 ]]; then
    $default_yes && return 0 || return 1
  fi
  read -rp "${prompt} [y/N]: " ans
  [[ "${ans}" =~ ^[Yy] ]] || return 1
}

# Export top-level vars for modules that source utils.sh
export PROJECT_ROOT BIN_DIR
