#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../core/utils.sh"

info "network: installing ssh and simple server tools..."
pkg install -y openssh python || true

cat > "${PROJECT_ROOT}/bin/helix-serve" <<'BASH'
#!/usr/bin/env bash
port="${1:-8000}"
python -m http.server "${port}"
BASH
chmod +x "${PROJECT_ROOT}/bin/helix-serve" || true

cat > "${PROJECT_ROOT}/bin/helix-ssh-setup" <<'BASH'
#!/usr/bin/env bash

Easy sshd setup

if [[ ! -f "${HOME}/.ssh/id_rsa" ]]; then
ssh-keygen -t rsa -f "${HOME}/.ssh/id_rsa" -N ""
echo "SSH key generated at ~/.ssh/id_rsa"
fi
sshd
echo "sshd started (check: ss -ltnp)"
BASH
chmod +x "${PROJECT_ROOT}/bin/helix-ssh-setup" || true
