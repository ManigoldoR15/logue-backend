#!/usr/bin/env bash
# PASO 2 — Se corre EN EL SERVIDOR, sin sudo:  ./2-llave-github.sh
# Crea la "deploy key": una llave SSH que solo sirve para LEER este repositorio de GitHub.
# Así el servidor puede descargar el código sin tener tu usuario ni tu contraseña de GitHub.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/config.env"
LLAVE="$HOME/.ssh/logue_github"

mkdir -p ~/.ssh && chmod 700 ~/.ssh
if [[ ! -f $LLAVE ]]; then
  ssh-keygen -t ed25519 -f "$LLAVE" -N "" -C "deploy-logue@$(hostname)"
fi

# Alias "github-logue": cuando git use ese host, SSH usará esta llave.
if ! grep -q "Host github-logue" ~/.ssh/config 2>/dev/null; then
  cat >> ~/.ssh/config <<CONF

Host github-logue
    HostName github.com
    User git
    IdentityFile $LLAVE
    IdentitiesOnly yes
CONF
  chmod 600 ~/.ssh/config
fi

echo
echo "Copia esta llave PÚBLICA en GitHub:"
echo "  github.com/ManigoldoR15/logue-backend → Settings → Deploy keys → Add deploy key"
echo "  (deja SIN marcar 'Allow write access': el servidor solo necesita leer)"
echo
cat "$LLAVE.pub"
echo
read -rp "Presiona Enter cuando la hayas agregado en GitHub... "

ssh-keyscan github.com >> ~/.ssh/known_hosts 2>/dev/null
ssh -T github-logue || true   # GitHub responde "successfully authenticated" y cierra; es normal

if [[ -d $RUTA_REPO/.git ]]; then
  git -C "$RUTA_REPO" remote set-url origin "$REPO_GITHUB"
else
  git clone -b "$RAMA" "$REPO_GITHUB" "$RUTA_REPO"
fi
echo "Repositorio listo en $RUTA_REPO"
