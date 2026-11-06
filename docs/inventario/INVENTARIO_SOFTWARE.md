# Inventario de software — Logue

> Generado el 2026-10-28 leyendo los archivos reales de `~/logue` (solo lectura). Las versiones salen de
> `build.gradle.kts`, `gradle/libs.versions.toml`, `settings.gradle.kts`, `gradle-wrapper.properties` y del catálogo
> `ktor-version-catalog-3.6.0.toml` que está en la caché de Gradle. No se incluyen contraseñas ni contenido de `users.json`.
> Detalle de librerías en formato tabla: [`inventario_librerias.csv`](inventario_librerias.csv).

---

## 1. Datos generales

| Campo | Valor |
|---|---|
| Nombre | **Logue** — demo de app de emergencias para la Cruz Roja Mexicana |
| Proyectos | `backend/` (rootProject `backend`) y `frontend/` (rootProject `LogueFrontend`) |
| Repositorio backend | https://github.com/ManigoldoR15/logue-backend |
| Repositorio frontend | https://github.com/ManigoldoR15/logue-frontend |
| Fecha de creación | 2026-10-14 (KMP Wizard: `2026-10-14T15:55:32Z` en `.idea/receipt.json`; primer commit 09:47 -0600) |
| Último commit | 2026-10-14 10:16 -0600 en ambos repos ("Fase 3: README con arquitectura, endpoints y cómo correr") |
| Group / versión backend | `com.logue` / `1.0.0-SNAPSHOT` |
| Versión app | Android `versionName 1.0` (`versionCode 1`); Desktop `packageVersion 1.0.0` |
| Generadores | Backend: Ktor Project Generator (start.ktor.io). Frontend: Kotlin Multiplatform Wizard (kmp.jetbrains.com) |

**Propósito.** Login por rol contra un servidor local. El usuario inicia sesión y, según su rol, ve una pantalla distinta:
- **Ciudadano:** botón SOS (mantener 5 s) y luego elegir el tipo de emergencia (disparos, accidente vial, persona inconsciente, múltiples heridos).
- **Paramédico:** lista de incidentes de ejemplo con ubicación, prioridad y ETA.
- **Administrador:** resumen de incidentes activos y unidades disponibles (datos de ejemplo).

**Arquitectura.** Backend y frontend van separados y se comunican por HTTP + JSON (`POST /login`). No hay base de datos: los usuarios se leen de `users.json`.

Historial de commits:

| Repo | Commit | Fecha | Mensaje |
|---|---|---|---|
| backend | `ded9412` | 2026-10-14 09:56 | Proyecto base Ktor del wizard |
| backend | `324c3c2` | 2026-10-14 10:00 | Fase 1: login con usuarios desde users.json |
| backend | `9ab6209` | 2026-10-14 10:16 | Fase 3: README con arquitectura, endpoints y cómo correr |
| frontend | `d616cfb` | 2026-10-14 09:47 | Proyecto base KMP del wizard |
| frontend | `28b27c2` | 2026-10-14 09:56 | Proyecto base KMP del wizard |
| frontend | `998fee1` | 2026-10-14 10:09 | Fase 2: login con Ktor Client y navegación por rol |
| frontend | `9999c00` | 2026-10-14 10:16 | Fase 3: README con arquitectura, endpoints y cómo correr |

---

## 2. Entorno

| Herramienta | Backend | Frontend | Fuente |
|---|---|---|---|
| Gradle (wrapper) | **9.5.1** | **9.5.1** | `gradle/wrapper/gradle-wrapper.properties` |
| JDK requerido | **21** (`kotlin { jvmToolchain(21) }`) | **21** (daemon JVM: Azul, `toolchainVersion=21`) | `build.gradle.kts` / `gradle/gradle-daemon-jvm.properties` |
| Bytecode objetivo | 21 (toolchain) | **JVM 11** en Android (`jvmTarget = JVM_11`, `sourceCompatibility 11`) | `shared` y `androidApp/build.gradle.kts` |
| Kotlin | **2.4.0** | **2.4.20** | `gradle/libs.versions.toml` |
| Ktor | **3.6.0** (catálogo `io.ktor:ktor-version-catalog:3.6.0`) | **3.6.0** | `settings.gradle.kts` / `libs.versions.toml` |
| Android Gradle Plugin | — | **9.1.1** | `libs.versions.toml` (`agp`) |
| Android SDK | — | compileSdk **37**, targetSdk **37**, minSdk **24** | `libs.versions.toml` |
| Compose Multiplatform | — | **1.12.1** (Material3 **1.12.0-alpha03**) | `libs.versions.toml` |
| Code style | `kotlin.code.style=official` | `official` | `gradle.properties` |
| Opciones Gradle | — | `-Xmx3072M`, configuration-cache y build cache activados, `android.useAndroidX=true`, `android.nonTransitiveRClass=true` | `frontend/gradle.properties` |

### Plugins de Gradle

| Proyecto | Plugin | Versión |
|---|---|---|
| ambos | `org.gradle.toolchains.foojay-resolver-convention` (settings) | 1.0.0 |
| backend | `org.jetbrains.kotlin.jvm` | 2.4.0 |
| backend | `io.ktor.plugin` (vía `ktorLibs.plugins.ktor`) | 3.6.0 |
| backend | `org.jetbrains.kotlin.plugin.serialization` | 2.4.0 |
| backend | `org.jetbrains.kotlin.multiplatform` | 2.4.0 *(está en el catálogo, pero no se aplica)* |
| frontend | `com.android.application` | 9.1.1 |
| frontend | `com.android.kotlin.multiplatform.library` | 9.1.1 |
| frontend | `org.jetbrains.compose` | 1.12.1 |
| frontend | `org.jetbrains.kotlin.plugin.compose` | 2.4.20 |
| frontend | `org.jetbrains.kotlin.jvm` | 2.4.20 |
| frontend | `org.jetbrains.kotlin.multiplatform` | 2.4.20 |
| frontend | `org.jetbrains.kotlin.plugin.serialization` | 2.4.20 |

**Repositorios Maven.** Backend: `gradlePluginPortal()` para plugins y `mavenCentral()` para dependencias. Frontend: `google()` (solo para los grupos `androidx`, `com.android` y `com.google`), `mavenCentral()` y `gradlePluginPortal()`.

**JDKs instalados en la máquina.** `java` por defecto = OpenJDK **25.0.4.1**. En `/usr/lib/jvm` también están 17, **21 (21.0.12.1)** y 25. En `~/.gradle/jdks` están Azul Zulu 21.0.11 y Temurin 21.0.12.1. Los README piden usar `JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64`.

---

## 3. Backend — dependencias

| Configuración | Dependencia | Versión | Para qué se usa |
|---|---|---|---|
| implementation | `io.ktor:ktor-server-core` | 3.6.0 | Núcleo del servidor: `Application` y `routing` |
| implementation | `io.ktor:ktor-server-netty` | 3.6.0 | Motor HTTP Netty (`EngineMain`) |
| implementation | `io.ktor:ktor-server-config-yaml` | 3.6.0 | Leer `application.yaml` (puerto y módulos) |
| implementation | `io.ktor:ktor-server-content-negotiation` | 3.6.0 | Plugin ContentNegotiation |
| implementation | `io.ktor:ktor-serialization-kotlinx-json` | 3.6.0 | Convertir JSON a data classes `@Serializable` y viceversa |
| implementation | `io.ktor:ktor-server-cors` | 3.6.0 | CORS `anyHost()` para el frontend web (solo para desarrollo) |
| implementation | `ch.qos.logback:logback-classic` | 1.5.37 | Logs a consola (`logback.xml`) |
| testImplementation | `org.jetbrains.kotlin:kotlin-test` | 2.4.0 | `@Test` y aserciones |
| testImplementation | `io.ktor:ktor-server-test-host` | 3.6.0 | `testApplication {}` (servidor en memoria) |
| testImplementation | `io.ktor:ktor-client-content-negotiation` | 3.6.0 | Cliente de prueba con JSON |

`application.mainClass = io.ktor.server.netty.EngineMain`. El archivo `main.kt` también delega en `EngineMain.main(args)`.

---

## 4. Frontend — dependencias por módulo

### `shared` (Kotlin Multiplatform: jvm, js, wasmJs, android)

| Source set | Dependencia | Versión | Para qué se usa |
|---|---|---|---|
| commonMain | `org.jetbrains.compose.runtime:runtime` | 1.12.1 | Estado y recomposición |
| commonMain | `org.jetbrains.compose.foundation:foundation` | 1.12.1 | Layouts, gestos (botón SOS) y `LazyColumn` |
| commonMain | `org.jetbrains.compose.material3:material3` | 1.12.0-alpha03 | Scaffold, TopAppBar, Card, Button, TextField |
| commonMain | `org.jetbrains.compose.ui:ui` | 1.12.1 | UI base |
| commonMain | `org.jetbrains.compose.components:components-resources` | 1.12.1 | `composeResources` (drawable) |
| commonMain | `org.jetbrains.compose.ui:ui-tooling-preview` | 1.12.1 | `@Preview` |
| commonMain | `org.jetbrains.androidx.lifecycle:lifecycle-viewmodel-compose` | 2.11.0 | `LoginViewModel` y `viewModel {}` |
| commonMain | `org.jetbrains.androidx.lifecycle:lifecycle-runtime-compose` | 2.11.0 | `collectAsStateWithLifecycle` |
| commonMain | `org.jetbrains.androidx.navigation:navigation-compose` | 2.9.2 | `NavHost` con rutas type-safe por rol |
| commonMain | `io.ktor:ktor-client-core` | 3.6.0 | `HttpClient` para `POST /login` |
| commonMain | `io.ktor:ktor-client-content-negotiation` | 3.6.0 | JSON automático en el cliente |
| commonMain | `io.ktor:ktor-serialization-kotlinx-json` | 3.6.0 | Conversor JSON de Ktor |
| commonMain | `org.jetbrains.kotlinx:kotlinx-serialization-json` | 1.11.0 | `Json { ignoreUnknownKeys = true }` y modelos |
| androidMain | `org.jetbrains.compose.ui:ui-tooling` | 1.12.1 | Herramientas de preview (también en `androidRuntimeClasspath`) |
| androidMain | `io.ktor:ktor-client-okhttp` | 3.6.0 | Engine HTTP en Android |
| jvmMain | `io.ktor:ktor-client-cio` | 3.6.0 | Engine HTTP en escritorio |
| webMain (js + wasmJs) | `io.ktor:ktor-client-js` | 3.6.0 | Engine HTTP con `fetch` del navegador |
| jsMain | `org.jetbrains.kotlin-wrappers:kotlin-browser` | 2026.9.3 | `navigator.userAgent` (`Platform.js.kt`) |
| commonTest | `org.jetbrains.kotlin:kotlin-test` | 2.4.20 | Pruebas |
| jvmTest | `io.ktor:ktor-client-mock` | 3.6.0 | `MockEngine` para `LoginRepositoryTest` |

Configuración Android de `shared`: namespace `com.logue.frontend.shared`, compileSdk 37, minSdk 24, `androidResources` activado, host tests y device tests (`AndroidJUnitRunner`).

### `androidApp`

| Configuración | Dependencia | Versión | Para qué se usa |
|---|---|---|---|
| implementation | `project(":shared")` | — | `App()` |
| implementation | `androidx.activity:activity-compose` | 1.13.0 | `setContent { App() }` y `enableEdgeToEdge()` |
| implementation | `org.jetbrains.compose.ui:ui-tooling-preview` | 1.12.1 | `@Preview` |
| debugImplementation | `org.jetbrains.compose.ui:ui-tooling` | 1.12.1 | Preview e inspector en debug |

Datos de la app: `applicationId com.logue.frontend`, minSdk 24, targetSdk 37, release sin minify (con proguard-rules.pro). En el manifest: permiso `INTERNET` y `usesCleartextTraffic="true"`.

### `desktopApp`

| Configuración | Dependencia | Versión | Para qué se usa |
|---|---|---|---|
| implementation | `project(":shared")` | — | `App()` |
| implementation | `compose.desktop.currentOs` | 1.12.1 (versión del plugin Compose; en caché: `desktop-jvm-linux-x64` 1.12.1) | Runtime de Compose Desktop |
| implementation | `org.jetbrains.kotlinx:kotlinx-coroutines-swing` | 1.11.0 | Dispatcher Main sobre Swing |
| implementation | `org.jetbrains.compose.ui:ui-tooling-preview` | 1.12.1 | `@Preview` |

`mainClass = com.logue.frontend.MainKt`. Formatos nativos configurados: Dmg, Msi y Deb (`packageName com.logue.frontend`, `1.0.0`).

### `webApp` (js + wasmJs, browser, executable)

| Source set | Dependencia | Versión | Para qué se usa |
|---|---|---|---|
| commonMain | `project(":shared")` | — | `App()` |
| commonMain | `org.jetbrains.compose.ui:ui` | 1.12.1 | `ComposeViewport { App() }` |

### Entradas del catálogo que ningún módulo usa
`kotlin-test-junit` 2.4.20, `junit` 4.13.2, `androidx.core:core-ktx` 1.19.1, `androidx.test.ext:junit` 1.3.0, `espresso-core` 3.7.0 y `androidx.appcompat` 1.8.0. Vienen del wizard y no se referencian en ningún `build.gradle.kts`.

---

## 5. Estructura

### Backend (`backend/`)

| Ruta | Descripción |
|---|---|
| `build.gradle.kts` | Plugins (Kotlin JVM, Ktor, serialization), toolchain 21 y dependencias |
| `settings.gradle.kts` | Repositorios, foojay y catálogo `ktorLibs` (Ktor 3.6.0) |
| `gradle/libs.versions.toml` | Versiones de Kotlin y logback, y alias de plugins |
| `gradle.properties` | Estilo de código oficial |
| `gradlew`, `gradlew.bat`, `gradle/wrapper/` | Wrapper de Gradle 9.5.1 |
| `README.md` | Arquitectura, endpoints y cómo correr |
| `src/main/kotlin/main.kt` | Punto de entrada: arranca Netty con `application.yaml` |
| `src/main/kotlin/HTTP.kt` | `configureHTTP()`: plugin CORS |
| `src/main/kotlin/Serialization.kt` | `configureSerialization()`: ContentNegotiation JSON |
| `src/main/kotlin/Routing.kt` | `configureRouting()`: `GET /` y `POST /login` |
| `src/main/kotlin/Models.kt` | `Rol`, `Usuario`, `LoginRequest`, `LoginResponse` (`@Serializable`) |
| `src/main/kotlin/UserRepository.kt` | Carga `users.json` (lazy) y valida credenciales |
| `src/main/resources/application.yaml` | Puerto 8080 y los 3 módulos que se cargan |
| `src/main/resources/logback.xml` | Logs a consola, nivel INFO |
| `src/main/resources/users.json` | Usuarios predefinidos (se describe en la sección 6) |
| `src/test/kotlin/ServerTest.kt` | Prueba de `GET /` |
| `src/test/kotlin/LoginTest.kt` | Pruebas de `POST /login` (200 y 401) |
| `build/` | Salida de compilación: `libs/backend-1.0.0-SNAPSHOT.jar`, reportes de pruebas |

### Frontend (`frontend/`)

| Ruta | Descripción |
|---|---|
| `build.gradle.kts` | Declara todos los plugins con `apply false` |
| `settings.gradle.kts` | Repositorios, foojay e `include` de los 4 módulos |
| `gradle/libs.versions.toml` | Catálogo de versiones, librerías y plugins |
| `gradle/gradle-daemon-jvm.properties` | Daemon de Gradle con JDK 21 Azul (URLs de foojay) |
| `gradle.properties` | Memoria de JVM, caché, configuración de Android |
| `local.properties` | `sdk.dir` del Android SDK (local, ignorado por git) |
| `.idea/receipt.json` | Recibo del KMP Wizard (targets y fecha) |
| `README.md` | Arquitectura, engines por plataforma y cómo correr |

**`shared/`**

| Ruta | Descripción |
|---|---|
| `build.gradle.kts` | Targets jvm, js, wasmJs y android, y dependencias por source set |
| `commonMain/.../App.kt` | Punto de entrada común: `LogueTheme { AppNavigation() }` |
| `commonMain/.../data/Models.kt` | `Rol`, `LoginRequest`, `LoginResponse`, `Sesion` |
| `commonMain/.../data/HttpEngine.kt` | `expect` de `httpEngine()` y `BASE_URL` |
| `commonMain/.../data/ApiClient.kt` | `createHttpClient()` con ContentNegotiation JSON |
| `commonMain/.../data/LoginRepository.kt` | `POST {BASE_URL}/login`; si falla la red devuelve un error controlado |
| `commonMain/.../data/DatosEjemplo.kt` | Incidentes (5) y unidades (7) fijos de ejemplo |
| `commonMain/.../viewmodel/LoginViewModel.kt` | `StateFlow<LoginUiState>`, login y logout |
| `commonMain/.../ui/navigation/Rutas.kt` | Rutas `@Serializable` y `rutaPorRol()` |
| `commonMain/.../ui/navigation/AppNavigation.kt` | `NavHost`: Login, Ciudadano, Emergencia, Paramédico, Administrador |
| `commonMain/.../ui/screens/LoginScreen.kt` | Formulario de login con logo de la cruz |
| `commonMain/.../ui/screens/CiudadanoScreen.kt` | Botón SOS (mantener 5 s) con barra de progreso |
| `commonMain/.../ui/screens/EmergenciaScreen.kt` | Elegir el tipo de emergencia y confirmar el envío |
| `commonMain/.../ui/screens/ParamedicoScreen.kt` | Lista de incidentes con prioridad y ETA |
| `commonMain/.../ui/screens/AdministradorScreen.kt` | Resumen de incidentes y unidades |
| `commonMain/.../ui/screens/LogueTopBar.kt` | Barra superior con nombre y "Cerrar sesión" |
| `commonMain/.../ui/theme/Theme.kt` | Colores Cruz Roja (`#C8102E`) |
| `commonMain/.../Greeting.kt`, `GreetingUtil.kt`, `Platform.kt` | Código de ejemplo del wizard (`expect getPlatform()`) |
| `commonMain/composeResources/drawable/compose-multiplatform.xml` | Logo de ejemplo del wizard |
| `jvmMain/.../HttpEngine.jvm.kt` | `actual`: CIO + `http://localhost:8080` |
| `androidMain/.../HttpEngine.android.kt` | `actual`: OkHttp + `http://10.0.2.2:8080` (emulador) |
| `webMain/.../HttpEngine.web.kt` | `actual`: Js + `http://localhost:8080` |
| `jvmMain`, `androidMain`, `jsMain`, `wasmJsMain` `/Platform.*.kt` | `actual getPlatform()` de cada plataforma |
| `commonTest`, `jvmTest`, `webTest`, `androidHostTest` | Pruebas (sección 7) |

**`androidApp/`**

| Ruta | Descripción |
|---|---|
| `build.gradle.kts` | App Android: applicationId, SDKs, Java 11, Compose |
| `src/main/AndroidManifest.xml` | Permiso INTERNET, cleartext activado, `MainActivity` como launcher |
| `src/main/kotlin/.../MainActivity.kt` | `setContent { App() }` y preview |
| `src/main/res/` | Íconos del launcher (mipmap/drawable) y `strings.xml` (`app_name = LogueFrontend`) |
| `proguard-rules.pro` | Reglas de ProGuard (release sin minify) |

**`desktopApp/`**

| Ruta | Descripción |
|---|---|
| `build.gradle.kts` | Compose Desktop, mainClass y formatos Dmg/Msi/Deb |
| `src/main/kotlin/.../main.kt` | Ventana "Logue · Cruz Roja Mexicana" que muestra `App()` |

**`webApp/`**

| Ruta | Descripción |
|---|---|
| `build.gradle.kts` | Targets js y wasmJs (browser, ejecutable) |
| `src/webMain/kotlin/.../main.kt` | `ComposeViewport { App() }` |
| `src/webMain/resources/index.html` | Página con spinner que carga `webApp.js` |
| `src/webMain/resources/styles.css` | Pantalla completa, sin márgenes |

---

## 6. Endpoints de la API y archivos de datos

Servidor Ktor/Netty en el **puerto 8080** (`application.yaml`). Módulos cargados: `configureHTTP`, `configureSerialization` y `configureRouting`.

| Método | Ruta | Cuerpo de la petición | Respuestas |
|---|---|---|---|
| GET | `/` | — | `200` texto `Hello, World!` (para comprobar que el servidor está arriba) |
| POST | `/login` | JSON `LoginRequest { usuario, password }` | `200` `LoginResponse{ok:true, nombre, rol, mensaje}` · `401` credenciales incorrectas (`ok:false`) · `400` JSON inválido (`ok:false`, "Solicitud inválida") |

- `LoginResponse` nunca incluye la contraseña. `rol` puede ser `CIUDADANO`, `PARAMEDICO` o `ADMINISTRADOR`.
- CORS: `anyHost()`, métodos POST y OPTIONS, header `Content-Type`.

URLs base del cliente: Desktop y Web usan `http://localhost:8080`; Android usa `http://10.0.2.2:8080`.

**Archivos de datos**

| Archivo | Contenido |
|---|---|
| `backend/src/main/resources/users.json` | Existe. Es un arreglo JSON con **3 usuarios**, uno por cada rol (modelo `Usuario`: usuario, password, nombre, rol). Su contenido no se reproduce aquí. |
| `frontend/shared/.../data/DatosEjemplo.kt` | Datos fijos en código: 5 incidentes y 7 unidades de ambulancia (4 disponibles) |
| `backend/src/main/resources/application.yaml` | Configuración del puerto y los módulos |

---

## 7. Pruebas existentes

| Proyecto | Archivo | Pruebas | Qué verifica | Último resultado (`build/test-results`) |
|---|---|---|---|---|
| backend | `ServerTest.kt` | 1 | `GET /` devuelve 200 | ✅ 1/1 (2026-10-14) |
| backend | `LoginTest.kt` | 2 | Login correcto → 200 con rol `PARAMEDICO`; login incorrecto → 401 | ✅ 2/2 (2026-10-14) |
| frontend/shared | `jvmTest/.../LoginRepositoryTest.kt` | 2 | Con MockEngine: se deserializa el rol (200) y se recibe el mensaje del servidor (401) | ✅ 2/2 (2026-10-14) |
| frontend/shared | `jvmTest/.../SharedLogicDesktopTest.kt` | 1 | Ejemplo del wizard (`1+2==3`) | ✅ 1/1 |
| frontend/shared | `commonTest/.../SharedCommonTest.kt` | 1 | Ejemplo del wizard | ✅ 1/1 (ejecutada en jvm) |
| frontend/shared | `webTest/.../SharedLogicWebTest.kt` | 1 | Ejemplo del wizard | ⚪ no hay resultados (no se ejecutó) |
| frontend/shared | `androidHostTest/.../SharedLogicAndroidHostTest.kt` | 1 | Ejemplo del wizard | ⚪ no hay resultados (no se ejecutó) |

Total: **9 pruebas**. **7 se ejecutaron y pasaron**, 2 no se han ejecutado. De las 9, solo 5 prueban lógica real; las otras 4 son ejemplos del wizard.

---

## 8. Plataformas objetivo y estado de compilación

Esto se dedujo de lo que hay en las carpetas `build/`. No se compiló nada nuevo para este inventario.

| Plataforma | Módulo(s) | ¿Compilado? | Evidencia |
|---|---|---|---|
| Servidor JVM (backend) | `backend` | ✅ Sí | `build/libs/backend-1.0.0-SNAPSHOT.jar` y pruebas en verde |
| Desktop (JVM) | `shared` (jvm) + `desktopApp` | ✅ Sí | `shared/build/libs/shared-jvm.jar` y `desktopApp/build/libs/desktopApp.jar`. El README dice que es "la plataforma probada" |
| Web JS | `shared` (js) + `webApp` | ⚠️ Parcial | Se compiló el klib de `shared` (`build/classes/kotlin/js/main`), pero `webApp/` no tiene carpeta `build`: la app web no se generó |
| Web Wasm | `shared` (wasmJs) + `webApp` | ⚠️ Parcial | Igual que JS: `shared/build/classes/kotlin/wasmJs/main` existe y `webApp` no se compiló |
| Android | `shared` (android) + `androidApp` | ❌ No | No hay `androidApp/build`. La ruta `sdk.dir` de `local.properties` **no existe** en esta máquina, así que no se puede compilar Android sin instalar el SDK |
| iOS | — | No es objetivo | El wizard no se configuró con iOS |

---

## Observaciones

- **Kotlin no coincide entre proyectos:** el backend usa 2.4.0 y el frontend 2.4.20. Funciona porque son proyectos separados, pero conviene alinearlos.
- **Material3 1.12.0-alpha03** es una versión alfa, mientras que el resto de Compose está en la versión estable 1.12.1.
- **Seguridad (es una demo):** `users.json` guarda contraseñas en texto plano y la pantalla de login muestra las credenciales de demo. Además, CORS está con `anyHost()` y Android tiene `usesCleartextTraffic=true`. Todo esto es aceptable para desarrollo local, no para producción.
- Quedan restos del wizard sin usar: `Greeting.kt`, `GreetingUtil.kt`, `compose-multiplatform.xml`, 4 pruebas de ejemplo y 6 librerías del catálogo.
- El `java` por defecto del sistema es 25. Para compilar hay que usar JDK 21, como indican los README.
- Hay una carpeta `frontend/.gradle/9.6.0` que indica que en algún momento se ejecutó Gradle 9.6.0, aunque el wrapper fija 9.5.1.
