# Despliegue de Logue por SSH (seguridad, backup y firewall)

Esta carpeta pone el backend de Logue en un **servidor** (la ThinkPad T430 con Kali Linux) y lo actualiza desde la
**computadora de desarrollo** usando SSH con llaves, sin contraseñas.

## Las dos computadoras

| Computadora | Papel | Qué tiene |
|---|---|---|
| Desarrollo (donde programas) | Hace commits, los sube a GitHub y ordena el despliegue | Llave `~/.ssh/logue_servidor` para entrar al servidor |
| Servidor (ThinkPad con Kali) | Corre el backend en el puerto 8080 | Firewall, servicio `logue-backend`, backups, y la llave `~/.ssh/logue_github` (deploy key) para bajar el código |

Si solo llevas la ThinkPad, puede ser las dos cosas a la vez: en `config.env` pon `SERVIDOR_IP=localhost`.

## Diagrama

```
 Computadora de desarrollo                GitHub                       Servidor (ThinkPad Kali)
 ─────────────────────────          ─────────────────           ──────────────────────────────────
 git commit                                                      firewall (ufw): solo 22 y 8080
 ./deploy/deploy.sh
   1. git push origin main ───────▶  rama main
   2. ssh -i logue_servidor ─────────────────────────────────▶  actualizar.sh
                                                                  a. backup.sh  → ~/logue-backups
                                     rama main ◀── deploy key ──  b. git fetch / reset a main
                                                                  c. ./gradlew buildFatJar
                                                                  d. systemctl restart logue-backend
                                                                  e. curl localhost:8080 → OK
```

## Paso a paso (lo que pide la práctica)

### 1. Seguridad: firewall, SSH y backup — `sudo ./1-preparar-servidor.sh` (en el servidor)
- **Instala** `openssh-server`, `ufw` (firewall), `git`, `curl` y Java 21.
- **Enciende SSH**: Kali lo trae apagado (`systemctl enable --now ssh`).
- **Firewall (ufw)**: bloquea todo lo que entra (`default deny incoming`) y solo abre:
  - `22/tcp` (SSH) con `limit`: si una IP intenta conectarse más de 6 veces en 30 segundos, se bloquea. Frena ataques de fuerza bruta.
  - `8080/tcp`: el backend de Logue.
- **SSH más seguro**: `PermitRootLogin no` (nadie entra como root) y `MaxAuthTries 3`.
- **Servicio systemd** `logue-backend`: el backend arranca solo al prender la máquina y se reinicia si se cae.
- **sudo limitado**: el usuario puede reiniciar *solo* ese servicio sin contraseña, para que el deploy funcione sin pedirla.
- **Backup diario** con cron a las 2:00 am.

### 2. Configurar la rama main y crear la deploy key — `./2-llave-github.sh` (en el servidor)
- Crea una llave SSH `ed25519` (`~/.ssh/logue_github`).
- La **llave pública** se pega en GitHub → *Settings → Deploy keys*, **sin** permiso de escritura.
  Una *deploy key* sirve para un solo repositorio y solo para leer: si alguien la roba, no puede tocar tu cuenta ni modificar el código.
- Agrega el alias `github-logue` en `~/.ssh/config` para que git use esa llave.
- Clona el repositorio en `~/logue-backend` siguiendo la rama **main** (la rama principal es la única que se despliega).

### 3. Preparar la conexión SSH con llave — `./3-llave-acceso.sh` (en la computadora de desarrollo)
- Crea tu llave `~/.ssh/logue_servidor`.
- `ssh-copy-id` copia la parte **pública** al archivo `~/.ssh/authorized_keys` del servidor. Es la última vez que se escribe la contraseña.
- Prueba la entrada con `PasswordAuthentication=no`, o sea, solo con la llave.

### 4. Quitar las contraseñas — `sudo ./4-cerrar-password.sh` (en el servidor)
- `PasswordAuthentication no`: desde ahora **solo entra quien tenga una llave autorizada**.
- Antes revisa que exista una llave en `authorized_keys`, para no dejarte fuera.

### 5. Desplegar — `./deploy/deploy.sh` (en la computadora de desarrollo)
1. Revisa que estés en `main` y sin cambios pendientes.
2. `git push origin main`: **sube el código a la rama principal de GitHub**.
3. Entra al servidor **con la llave** (cada despliegue usa la llave, nunca contraseña) y corre `actualizar.sh`:
   1. **Backup** de la versión actual.
   2. Baja `main` de GitHub con la deploy key.
   3. Compila el jar (`./gradlew buildFatJar`).
   4. Reinicia el servicio y verifica que `GET /` responda.

## Backup

`backup.sh` guarda en `~/logue-backups/logue-AAAAMMDD-HHMMSS.tar.gz`:
- `backend.jar` (la versión que estaba corriendo),
- `users.json` (los usuarios),
- `application.yaml` (la configuración).

Se ejecuta **antes de cada despliegue** y **diario a las 2:00 am**. Solo se guardan los últimos 7.

**Restaurar** (volver a la versión anterior):
```bash
tar -tzf ~/logue-backups/logue-20261106-020000.tar.gz       # ver qué contiene
tar -xzPf ~/logue-backups/logue-20261106-020000.tar.gz      # regresa los archivos a su lugar
sudo systemctl restart logue-backend
```

## Primera vez en la ThinkPad

```bash
git clone https://github.com/ManigoldoR15/logue-backend.git ~/logue-backend   # si es privado, te pide token
cd ~/logue-backend/deploy
nano config.env                 # usuario (kali) e IP del servidor
sudo ./1-preparar-servidor.sh
./2-llave-github.sh             # cambia el repo a SSH con la deploy key
```
Luego, en la computadora de desarrollo: `./deploy/3-llave-acceso.sh`; otra vez en el servidor: `sudo ./4-cerrar-password.sh`.
De ahí en adelante solo se usa `./deploy/deploy.sh`.

## Comandos para revisar en el examen

| Qué mostrar | Comando |
|---|---|
| Reglas del firewall | `sudo ufw status verbose` |
| SSH sin contraseña ni root | `sudo sshd -T \| grep -E 'passwordauth\|permitroot'` |
| Que el password se rechaza | `ssh -o PubkeyAuthentication=no kali@IP` → `Permission denied (publickey)` |
| Estado del backend | `systemctl status logue-backend` |
| Logs del backend | `journalctl -u logue-backend -f` |
| Backups | `ls -lh ~/logue-backups` |
| Llaves autorizadas | `cat ~/.ssh/authorized_keys` |
| Qué versión está desplegada | `git -C ~/logue-backend log -1 --oneline` |
| El backend responde | `curl http://IP:8080/` |

## Cómo explicarlo en una frase por tema

- **Firewall**: todo está cerrado menos SSH (22, con límite de intentos) y la app (8080).
- **SSH con llaves**: la llave privada se queda en tu máquina y el servidor solo guarda la pública. Sin la privada no se entra, y la contraseña está deshabilitada.
- **Deploy key**: el servidor baja el código de GitHub con una llave de solo lectura de ese repo, no con tu cuenta.
- **Rama main**: lo que está en `main` es lo que corre en el servidor; el deploy no deja desplegar desde otra rama ni con cambios sin commit.
- **Backup**: antes de cada cambio se respalda la versión anterior, así que si algo falla se restaura en un minuto.
