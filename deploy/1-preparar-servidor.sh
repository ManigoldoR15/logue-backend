#!/usr/bin/env bash
# PASO 1 — Se corre EN EL SERVIDOR (ThinkPad con Kali):  sudo ./1-preparar-servidor.sh
# Instala lo necesario, enciende SSH, configura el firewall, el servicio y el backup diario.
set -euo pipefail

if [[ $EUID -ne 0 ]]; then echo "Córrelo con sudo: sudo $0"; exit 1; fi
USUARIO="${SUDO_USER:?Córrelo con sudo desde tu usuario normal, no como root directo}"
CASA="$(getent passwd "$USUARIO" | cut -d: -f6)"
DIR="$(cd "$(dirname "$0")" && pwd)"
HOME="$CASA" source "$DIR/config.env"

echo "==> Instalando paquetes (SSH, firewall, git, Java)"
apt-get update
apt-get install -y openssh-server ufw git curl
apt-get install -y openjdk-21-jdk-headless || apt-get install -y default-jdk-headless

echo "==> Encendiendo el servidor SSH (Kali lo trae apagado)"
systemctl enable --now ssh

echo "==> Firewall: se bloquea todo lo que entra excepto SSH (22) y la app (${PUERTO_APP})"
ufw default deny incoming
ufw default allow outgoing
ufw limit 22/tcp comment 'SSH (limit = frena ataques de fuerza bruta)'
ufw allow ${PUERTO_APP}/tcp comment 'Logue backend'
ufw --force enable
ufw status verbose

echo "==> SSH: se prohíbe entrar como root (la contraseña se apaga en el paso 4)"
cat > /etc/ssh/sshd_config.d/10-logue.conf <<CONF
PermitRootLogin no
PubkeyAuthentication yes
MaxAuthTries 3
CONF
sshd -t && systemctl reload ssh

echo "==> Servicio systemd: el backend arranca solo y se reinicia si se cae"
mkdir -p "$RUTA_APP" "$RUTA_BACKUPS"
chown "$USUARIO:$USUARIO" "$RUTA_APP" "$RUTA_BACKUPS"
cat > /etc/systemd/system/${SERVICIO}.service <<UNIT
[Unit]
Description=Logue backend (Ktor)
After=network.target

[Service]
User=${USUARIO}
WorkingDirectory=${RUTA_APP}
ExecStart=/usr/bin/java -jar ${RUTA_APP}/backend.jar
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable ${SERVICIO}

echo "==> Permiso para que el deploy reinicie SOLO este servicio sin pedir contraseña"
SYSTEMCTL="$(command -v systemctl)"
cat > /etc/sudoers.d/logue-deploy <<SUDO
${USUARIO} ALL=(root) NOPASSWD: ${SYSTEMCTL} restart ${SERVICIO}, ${SYSTEMCTL} is-active ${SERVICIO}
SUDO
chmod 440 /etc/sudoers.d/logue-deploy
visudo -cf /etc/sudoers.d/logue-deploy

echo "==> Backup automático todos los días a las 2:00 am"
echo "0 2 * * * ${USUARIO} ${RUTA_REPO}/deploy/backup.sh >> ${RUTA_BACKUPS}/backup.log 2>&1" > /etc/cron.d/logue-backup

echo
echo "Listo. IP de este servidor:"; ip -4 -o addr show scope global | awk '{print "   " $4}'
echo "Siguiente: ./2-llave-github.sh (sin sudo)"
