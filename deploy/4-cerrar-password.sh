#!/usr/bin/env bash
# PASO 4 — Se corre EN EL SERVIDOR:  sudo ./4-cerrar-password.sh
# Apaga el acceso SSH con contraseña: desde aquí solo entra quien tenga una llave autorizada.
set -euo pipefail
if [[ $EUID -ne 0 ]]; then echo "Córrelo con sudo: sudo $0"; exit 1; fi
CASA="$(getent passwd "${SUDO_USER:?}" | cut -d: -f6)"

# Seguro: si no hay ninguna llave autorizada nos quedaríamos fuera, así que no seguimos.
if [[ ! -s $CASA/.ssh/authorized_keys ]]; then
  echo "No hay llaves en $CASA/.ssh/authorized_keys. Corre primero el paso 3."; exit 1
fi

cat > /etc/ssh/sshd_config.d/20-logue-sin-password.conf <<CONF
PasswordAuthentication no
KbdInteractiveAuthentication no
CONF
sshd -t && systemctl reload ssh
echo "Listo: SSH ya no acepta contraseñas."
