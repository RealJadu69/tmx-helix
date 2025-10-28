#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../core/utils.sh"

ensure_dirs
info "ui-tweaks: installing optional UI packages..."

# Install zsh if available; skip on failure
pkg install -y zsh || warn "zsh install failed or unavailable"

# starship is nice but we avoid piping unknown remote scripts.
# Provide safe instructions if starship isn't installed.
if command -v starship >/dev/null 2>&1; then
  info "starship prompt already installed."
else
  info "starship not found. To install on Termux, run:"
  cat <<'EOS'
# Option A: Use the official install script but inspect it first:
curl -fsSL https://starship.rs/install.sh -o /tmp/starship-install.sh
less /tmp/starship-install.sh   # inspect before running
bash /tmp/starship-install.sh --yes

# Option B: If you prefer not to run remote scripts, install via cargo (if you have Rust):
# pkg install rust
# cargo install starship
EOS
fi

info "ui-tweaks: installing banner & aliases..."
mkdir -p "${HOME}/.config" "${BIN_DIR}"
cp -n "${PROJECT_ROOT}/config/banner.txt" "${HOME}/.helix_banner" || warn "Failed to copy banner"
cp -n "${PROJECT_ROOT}/config/aliases" "${HOME}/.helix_aliases" || warn "Failed to copy aliases"

info "ui-tweaks: done."
