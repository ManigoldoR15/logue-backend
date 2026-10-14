# Logue · Backend (Ktor Server)

Demo de app de emergencias para la **Cruz Roja Mexicana**. Este repositorio es el **servidor**; la app está en
[logue-frontend](https://github.com/ManigoldoR15/logue-frontend).

Generado con el [Ktor Project Generator](https://start.ktor.io).

## Arquitectura

Arquitectura local con backend y frontend **separados**, comunicados por HTTP + JSON:

```
┌──────────────────────────────┐   POST /login (JSON)   ┌──────────────────────────────┐
│ logue-frontend (KMP/Compose) │ ─────────────────────▶ │ logue-backend (Ktor, :8080)  │
│ Android · Desktop · Web      │ ◀───────────────────── │ valida contra users.json     │
│ Ktor Client + serialization  │  {ok,nombre,rol,msg}   │ (sin base de datos)          │
└──────────────────────────────┘                        └──────────────────────────────┘
```

Plugins de Ktor instalados:

| Plugin | Para qué |
|---|---|
| Routing | Define las rutas (`GET /`, `POST /login`) |
| ContentNegotiation + kotlinx.serialization JSON | Convierte JSON ⇄ data classes `@Serializable` |
| CORS (`anyHost`, solo desarrollo) | Permite que la versión web del frontend llame al servidor |

## Estructura

```
backend/
├── build.gradle.kts              # Dependencias y plugin de serialización
├── gradle/libs.versions.toml     # Catálogo de versiones
└── src/
    ├── main/
    │   ├── kotlin/
    │   │   ├── main.kt           # Punto de entrada (arranca Netty con application.yaml)
    │   │   ├── HTTP.kt           # Plugin CORS
    │   │   ├── Serialization.kt  # Plugin ContentNegotiation (JSON)
    │   │   ├── Routing.kt        # Rutas: GET / y POST /login
    │   │   ├── Models.kt         # Data classes @Serializable: Rol, Usuario, LoginRequest, LoginResponse
    │   │   └── UserRepository.kt # Lee users.json y valida credenciales
    │   └── resources/
    │       ├── application.yaml  # Puerto 8080 y módulos que se cargan
    │       ├── users.json        # Usuarios predefinidos (sustituye a la base de datos)
    │       └── logback.xml       # Configuración de logs
    └── test/kotlin/
        ├── ServerTest.kt         # Prueba de GET /
        └── LoginTest.kt          # Pruebas de POST /login (200 y 401)
```

## Usuarios de prueba (`src/main/resources/users.json`)

| Usuario | Contraseña | Nombre | Rol |
|---|---|---|---|
| `ciudadano1` | `1234` | Juan Pérez | `CIUDADANO` |
| `paramedico1` | `1234` | María López | `PARAMEDICO` |
| `admin1` | `1234` | Carlos Ramírez | `ADMINISTRADOR` |

## Endpoints

### `GET /`
Responde `Hello, World!`; sirve para comprobar que el servidor está arriba.

### `POST /login`

Petición (`Content-Type: application/json`):
```json
{ "usuario": "paramedico1", "password": "1234" }
```

| Caso | Código | Cuerpo |
|---|---|---|
| Credenciales correctas | `200 OK` | `{"ok":true,"nombre":"María López","rol":"PARAMEDICO","mensaje":"Bienvenido, María López"}` |
| Credenciales incorrectas | `401 Unauthorized` | `{"ok":false,"nombre":null,"rol":null,"mensaje":"Usuario o contraseña incorrectos"}` |
| JSON inválido | `400 Bad Request` | `{"ok":false,"nombre":null,"rol":null,"mensaje":"Solicitud inválida"}` |

La contraseña **nunca** se envía de regreso al cliente.

Prueba rápida con curl:
```bash
curl -X POST http://localhost:8080/login \
  -H 'Content-Type: application/json' \
  -d '{"usuario":"paramedico1","password":"1234"}'
```

## Cómo correr

Requiere JDK 21. Si tu `java` por defecto es otra versión, indica JDK 21 solo para el comando:

```bash
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 ./gradlew run    # servidor en http://localhost:8080
JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64 ./gradlew test   # pruebas
```

Al arrancar verás `Responding at http://0.0.0.0:8080`. Arranca el backend **antes** que el frontend.
