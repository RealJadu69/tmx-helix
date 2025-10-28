#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

# Defaults
NONINTERACTIVE=false
INSTALL_MODULES=()
PROMPT=yes
DRY_RUN=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --non-interactive|-n) NONINTERACTIVE=true; shift ;;
    --modules) shift; IFS=, read -r -a INSTALL_MODULES <<< "$1"; shift ;;
    --dry-run) DRY_RUN=true; PROMPT=no; shift ;;
    *) shift ;;
  esac
done

require_termux
ensure_dirs

info "Project Helix installer starting..."
info "Project root: ${PROJECT_ROOT}"
info "Bin dir: ${BIN_DIR}"
info "Dry run: ${DRY_RUN}"

run_or_echo() {
  # If DRY_RUN: just echo the command; else execute
  if $DRY_RUN; then
    printf '[DRY] %s\n' "$*"
  else
    eval "$@"
  fi
}

# Module runner: if dry-run, don't actually run module script; just show
install_module() {
  local module="$1"
  local path="${PROJECT_ROOT}/modules/${module}.sh"
  if [[ -f "$path" ]]; then
    info "Installing module: $module"
    if $DRY_RUN; then
      printf '[DRY] Would run: bash %s\n' "$path"
    else
      bash "$path" || warn "Module $module failed (continuing)"
    fi
  else
    warn "Module $module not found"
  fi
}

# Default modules if none specified
if [[ ${#INSTALL_MODULES[@]} -eq 0 ]]; then
  INSTALL_MODULES=(dev-tools api-tools performance ui-tweaks automation network)
fi

# Create bin if it doesn't exist
mkdir -p "${BIN_DIR}"
chmod 0755 "${BIN_DIR}" || true

for m in "${INSTALL_MODULES[@]}"; do
  if $NONINTERACTIVE; then
    install_module "$m"
    continue
  fi
  if [[ "$PROMPT" == "no" ]]; then
    install_module "$m"
    continue
  fi
  if confirm "Run module $m?"; then
    install_module "$m"
  else
    info "Skipping $m"
  fi
done

info "Creating config files..."
mkdir -p "${PROJECT_ROOT}/config" "${PROJECT_ROOT}/data/logs" "${PROJECT_ROOT}/data/backups"

# Copy templates only if target doesn't already exist
if [[ ! -f "${HOME}/.helix_aliases" ]]; then
  cp -n "${PROJECT_ROOT}/config/aliases" "${HOME}/.helix_aliases" || warn "Failed to copy aliases"
fi
if [[ ! -f "${HOME}/.helix_banner" ]]; then
  cp -n "${PROJECT_ROOT}/config/banner.txt" "${HOME}/.helix_banner" || warn "Failed to copy banner"
fi

info "Installation complete."
if ! $DRY_RUN; then
  info "To activate aliases: source ~/.helix_aliases"
else
  info "Dry run complete — nothing was changed."
fi

if detect_shizuku; then
  info "Shizuku CLI detected — optional hooks available in ${BIN_DIR} (user must opt-in)."
fi
