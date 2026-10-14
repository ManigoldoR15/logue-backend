package com.logue

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*

fun Application.configureRouting() {
    routing {
        get("/") {
            call.respondText("Hello, World!")
        }

        post("/login") {
            val request = runCatching { call.receive<LoginRequest>() }.getOrNull()
            if (request == null) {
                call.respond(
                    HttpStatusCode.BadRequest,
                    LoginResponse(ok = false, nombre = null, rol = null, mensaje = "Solicitud inválida"),
                )
                return@post
            }

            val usuario = UserRepository.validar(request.usuario, request.password)
            if (usuario == null) {
                call.respond(
                    HttpStatusCode.Unauthorized,
                    LoginResponse(ok = false, nombre = null, rol = null, mensaje = "Usuario o contraseña incorrectos"),
                )
            } else {
                call.respond(
                    LoginResponse(ok = true, nombre = usuario.nombre, rol = usuario.rol, mensaje = "Bienvenido, ${usuario.nombre}"),
                )
            }
        }
    }
}
