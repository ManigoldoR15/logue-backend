package com.logue

import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.plugins.cors.routing.*

// CORS: permite que el frontend web (otro puerto) llame al backend. Solo para desarrollo.
fun Application.configureHTTP() {
    install(CORS) {
        anyHost()
        allowMethod(HttpMethod.Post)
        allowMethod(HttpMethod.Options)
        allowHeader(HttpHeaders.ContentType)
    }
}
