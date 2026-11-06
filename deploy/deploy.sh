#!/usr/bin/env bash
# Se corre EN LA COMPUTADORA DE DESARROLLO:  ./deploy/deploy.sh
# Sube tus commits a la rama main de GitHub y le pide al servidor (por SSH, con la llave) que se actualice.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/config.env"

RAMA_ACTUAL="$(git rev-parse --abbrev-ref HEAD)"
if [[ $RAMA_ACTUAL != "$RAMA" ]]; then
  echo "Estás en '$RAMA_ACTUAL'. Solo se despliega desde '$RAMA'."; exit 1
fi
if [[ -n $(git status --porcelain) ]]; then
  echo "Tienes cambios sin commit. Haz commit antes de desplegar."; exit 1
fi

echo "==> Subiendo $RAMA a GitHub"
git push origin "$RAMA"

echo "==> Entrando al servidor $SERVIDOR_USUARIO@$SERVIDOR_IP con la llave"
ssh -i "$LLAVE_SERVIDOR" -o PasswordAuthentication=no "$SERVIDOR_USUARIO@$SERVIDOR_IP" \
  "bash ~/logue-backend/deploy/actualizar.sh"
