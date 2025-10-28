#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../core/utils.sh"

ensure_dirs
info "api-tools: Installing termux-api and helpers (best-effort)..."

# termux-api is the module that provides termux-* commands.
# termux-api-root is not a standard package; avoid installing it blindly.
pkg install -y termux-api termux-tools dialog || warn "Some packages failed to install"

info "api-tools: configuring termux permissions helper..."
mkdir -p "${BIN_DIR}"
cat > "${BIN_DIR}/helix-termux-perms" <<'BASH'
#!/usr/bin/env bash
echo "Run: termux-setup-storage and grant permissions as prompted."
echo "You can also grant individual permissions via Android Settings -> Termux -> Permissions."
BASH
chmod +x "${BIN_DIR}/helix-termux-perms" || warn "Failed to chmod helix-termux-perms"

if detect_shizuku; then
  info "Shizuku detected — installing optional shizuku helper (no automatic permission changes)."
  cat > "${BIN_DIR}/helix-shizuku-check" <<'BASH'
#!/usr/bin/env bash
if command -v shizuku >/dev/null 2>&1; then
  echo "Shizuku available. Use it carefully to grant permissions if you understand the risks."
  echo "Example: shizuku pm grant com.termux android.permission.<PERMISSION>"
else
  echo "Shizuku not found."
fi
BASH
  chmod +x "${BIN_DIR}/helix-shizuku-check" || warn "Failed to chmod helix-shizuku-check"
fi

info "api-tools: done."
