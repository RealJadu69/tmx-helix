#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../core/utils.sh"

info "performance: Installing compression & parallel tools..."
pkg install -y zstd pigz coreutils || true

info "performance: setting recommended environment variables (non-persistent)"
export HELIX_MAKEFLAGS="-j$(nproc 2>/dev/null || echo 2)"
info "Suggested: export MAKEFLAGS=${HELIX_MAKEFLAGS}"

info "performance: Creating health-check script..."
cat > "${PROJECT_ROOT}/bin/helix-health-check" <<'BASH'
#!/usr/bin/env bash
df -h /
free -m || true
top -b -n1 | head -n 20 || true
BASH
chmod +x "${PROJECT_ROOT}/bin/helix-health-check" || true
