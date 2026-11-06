# Logue: cómo funciona la app de auxilios

**Logue** es una app de emergencias para la **Cruz Roja Mexicana**. Funciona en celular (Android), en computadora y en el navegador web. Se divide en dos partes que se comunican entre sí: la **app**, que es lo que ve el usuario, y el **servidor**, que revisa quién entra.

## Módulos y qué hace cada uno

| Módulo | Qué hace |
|---|---|
| **Servidor (backend)** | Recibe el usuario y la contraseña, los compara con la lista de usuarios registrados y responde quién es la persona y qué rol tiene. |
| **Núcleo compartido (shared)** | Contiene casi toda la app: las pantallas, los colores de la Cruz Roja, la lógica del inicio de sesión y la conexión con el servidor. Se escribe una sola vez y lo usan todas las versiones. |
| **App de celular (androidApp)** | Abre el núcleo compartido en un teléfono Android. |
| **App de computadora (desktopApp)** | Abre el núcleo compartido en una ventana de escritorio. |
| **App web (webApp)** | Abre el núcleo compartido en el navegador. |

## Qué pasa en cada acción y qué modelo utiliza

Un **modelo** es la "ficha" con los datos que viajan o se guardan en cada acción.

**1. Iniciar sesión**
La persona escribe su usuario y contraseña en la *pantalla de inicio*. Un **controlador** (`LoginViewModel`) revisa que los campos no estén vacíos y pasa los datos a un **mensajero** (`LoginRepository`), que los envía al servidor. El servidor busca a la persona en su lista y contesta.
- *Modelos:* **Solicitud de acceso** (usuario y contraseña), **Respuesta de acceso** (si entró, nombre, rol y mensaje), **Usuario** (cómo está guardado cada usuario en el servidor) y **Sesión** (nombre y rol que la app recuerda mientras la persona está dentro).

**2. Llevar a cada persona a su pantalla**
Según el rol que mandó el servidor, el **navegador de pantallas** abre la vista que le toca a esa persona.
- *Modelo:* **Rol**, que puede ser Ciudadano, Paramédico o Administrador.

**3. Mandar la señal de auxilio (Ciudadano)**
En la *pantalla del ciudadano* hay un botón rojo **SOS**. La persona lo mantiene presionado **5 segundos** mientras se llena una barra de progreso; esto evita activarlo por accidente. Si lo suelta antes, se cancela. Luego, en la *pantalla de emergencia*, elige el tipo: **disparos, accidente vial, persona inconsciente o múltiples heridos**. Al final aparece el aviso "Alerta enviada, una unidad va en camino".
- *Modelo:* por ahora el tipo de emergencia se guarda solo como texto.
- *Nota:* en esta versión de demostración la alerta **no llega todavía al servidor**; solo se muestra la confirmación en pantalla. El siguiente paso es crear un modelo de **Alerta** (tipo, ubicación y hora) y enviarlo al servidor.

**4. Ver incidentes (Paramédico)**
La *pantalla del paramédico* muestra la lista de emergencias asignadas. De cada una se ve el tipo, la dirección, la prioridad y los minutos estimados de llegada.
- *Modelo:* **Incidente** (tipo, ubicación, tiempo de llegada y prioridad). Por ahora son datos de ejemplo.

**5. Supervisar (Administrador)**
La *pantalla del administrador* muestra un resumen con los incidentes activos, las ambulancias disponibles y el estado de cada unidad: disponible, en servicio o en taller.
- *Modelos:* **Incidente** y **Unidad** (clave de la ambulancia y su estado). También son datos de ejemplo.

**6. Cerrar sesión**
Todas las pantallas tienen el botón **Cerrar sesión**. Al presionarlo se borra la **Sesión** y la app regresa a la pantalla de inicio.

## Resumen del recorrido

**Pantalla → Controlador → Mensajero → Servidor → respuesta → pantalla según el rol**

## Despliegue: cómo llega el servidor a la ThinkPad

El backend se instala en una computadora servidor (ThinkPad T430 con Kali Linux) y se actualiza por **SSH**. Los scripts y la guía completa están en `backend/deploy/README.md`.

1. **Seguridad, backup y firewall.** El firewall (`ufw`) bloquea todo lo que entra excepto SSH (puerto 22, con límite de intentos) y la app (puerto 8080). SSH no deja entrar como root. El backend corre como servicio y se respalda todos los días.
2. **Despliegue por SSH.** La computadora de desarrollo entra al servidor con una llave, no con contraseña.
3. **Configurar la rama main y preparar la conexión SSH.** Solo se despliega lo que está en `main`.
4. **Crear la llave de despliegue y vincularla al repositorio de GitHub.** El servidor tiene una *deploy key* de solo lectura para bajar el código del repositorio.
5. **Acceder con la llave en cada despliegue.** Después de copiar la llave, se desactiva el acceso por contraseña.
6. **Subir al repositorio de GitHub en la rama principal.** `deploy.sh` hace `git push origin main` y el servidor hace backup, baja `main`, compila y reinicia el servicio.

**Recorrido:** commit → push a `main` → SSH con llave → backup → descargar con la deploy key → compilar → reiniciar → comprobar que responde.
