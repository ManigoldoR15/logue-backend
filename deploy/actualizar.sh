#!/usr/bin/env bash
# Se corre EN EL SERVIDOR (lo llama deploy.sh por SSH). Backup → bajar main de GitHub → compilar → reiniciar.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
source "$DIR/config.env"
cd "$RUTA_REPO"

echo "==> 1/4 Backup de la versión actual"
"$RUTA_REPO/deploy/backup.sh"

echo "==> 2/4 Descargando la rama $RAMA de GitHub (con la deploy key)"
git fetch origin "$RAMA"
git reset --hard "origin/$RAMA"
git log -1 --oneline

echo "==> 3/4 Compilando el jar"
./gradlew --no-daemon buildFatJar
cp build/libs/*-all.jar "$RUTA_APP/backend.jar"

echo "==> 4/4 Reiniciando el servicio"
sudo systemctl restart "$SERVICIO"
for _ in $(seq 1 20); do
  if curl -fs "http://localhost:$PUERTO_APP/" >/dev/null; then
    echo "Backend arriba en el puerto $PUERTO_APP"; exit 0
  fi
  sleep 1
done
echo "El backend no respondió. Revisa: journalctl -u $SERVICIO -n 50"; exit 1
