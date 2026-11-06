#!/usr/bin/env bash
# Respaldo del backend: guarda el jar que corre, los usuarios y la configuración en un .tar.gz con fecha.
# Lo usa actualizar.sh antes de cada despliegue y cron todos los días a las 2:00 am.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/config.env"

mkdir -p "$RUTA_BACKUPS"
ARCHIVO="$RUTA_BACKUPS/logue-$(date +%Y%m%d-%H%M%S).tar.gz"
ARCHIVOS=()
[[ -f $RUTA_APP/backend.jar ]] && ARCHIVOS+=("$RUTA_APP/backend.jar")
ARCHIVOS+=("$RUTA_REPO/src/main/resources/users.json" "$RUTA_REPO/src/main/resources/application.yaml")

tar -czPf "$ARCHIVO" "${ARCHIVOS[@]}"
echo "Backup creado: $ARCHIVO"

# Solo se guardan los últimos N respaldos
ls -1t "$RUTA_BACKUPS"/logue-*.tar.gz | tail -n +$((BACKUPS_A_GUARDAR + 1)) | xargs -r rm --
