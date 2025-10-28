#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../core/utils.sh"

info "automation: installing job scheduler support..."
pkg install -y termux-job-scheduler || true

cat > "${PROJECT_ROOT}/bin/helix-macro-runner" <<'BASH'
#!/usr/bin/env bash

Simple macro runner example (runs checks and sends notification)

if command -v termux-notification >/dev/null 2>&1; then
batt=$(termux-battery-status | jq -r '.percentage')
if [[ -n "$batt" && "$batt" -lt 20 ]]; then
termux-notification --title "Helix" --content "Battery low: ${batt}%"
fi
fi
BASH
chmod +x "${PROJECT_ROOT}/bin/helix-macro-runner" || true
