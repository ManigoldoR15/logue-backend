package com.logue

import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.plugins.contentnegotiation.*

// ContentNegotiation: convierte JSON <-> data classes @Serializable automáticamente.
fun Application.configureSerialization() {
    install(ContentNegotiation) {
        json()
    }
}
