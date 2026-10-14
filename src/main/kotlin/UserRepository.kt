package com.logue

import kotlinx.serialization.json.Json

// Lee users.json (dentro de resources) una sola vez y valida credenciales.
object UserRepository {
    private val usuarios: List<Usuario> by lazy {
        val texto = javaClass.getResource("/users.json")?.readText()
            ?: error("No se encontró users.json en resources")
        Json.decodeFromString<List<Usuario>>(texto)
    }

    fun validar(usuario: String, password: String): Usuario? =
        usuarios.find { it.usuario == usuario && it.password == password }
}
