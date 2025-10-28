#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/utils.sh"

info "Updating project-helix modules..."

# Only run git pull if this is a git repo
if [[ -d "${PROJECT_ROOT}/.git" ]]; then
  pushd "${PROJECT_ROOT}" >/dev/null || true
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    info "Pulling latest from git..."
    git pull --ff-only || warn "git pull failed (you may need to update manually)"
  fi
  popd >/dev/null || true
else
  warn "Not a git clone — skipping git pull."
fi

info "Running module update hooks (if supported)..."
for f in "${PROJECT_ROOT}/modules/"*.sh; do
  # allow modules to handle --update
  if [[ -f "$f" ]]; then
    info "Trying update for $(basename "$f")"
    bash "$f" --update || warn "Module update hook failed: $f"
  fi
done
info "Update complete."
