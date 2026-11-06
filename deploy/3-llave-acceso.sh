#!/usr/bin/env bash
# PASO 3 — Se corre EN LA COMPUTADORA DE DESARROLLO:  ./3-llave-acceso.sh
# Crea tu llave para entrar al servidor y copia la parte pública a ~/.ssh/authorized_keys del servidor.
# Es la última vez que se escribe la contraseña del servidor; después se entra solo con la llave.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/config.env"

if [[ ! -f $LLAVE_SERVIDOR ]]; then
  ssh-keygen -t ed25519 -f "$LLAVE_SERVIDOR" -C "logue-dev@$(hostname)"
fi
ssh-copy-id -i "$LLAVE_SERVIDOR.pub" "$SERVIDOR_USUARIO@$SERVIDOR_IP"

echo "Probando entrar con la llave (no debe pedir la contraseña del servidor):"
ssh -i "$LLAVE_SERVIDOR" -o PasswordAuthentication=no "$SERVIDOR_USUARIO@$SERVIDOR_IP" 'echo "OK, entré a $(hostname) con la llave"'
echo "Siguiente: en el servidor, sudo ./4-cerrar-password.sh"
