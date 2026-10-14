package com.logue

import kotlinx.serialization.Serializable

// Roles posibles. Al serializarse se escriben como texto: "CIUDADANO", etc.
@Serializable
enum class Rol { CIUDADANO, PARAMEDICO, ADMINISTRADOR }

// Un usuario tal como está guardado en users.json.
@Serializable
data class Usuario(
    val usuario: String,
    val password: String,
    val nombre: String,
    val rol: Rol,
)

// Cuerpo JSON que manda el cliente a POST /login.
@Serializable
data class LoginRequest(
    val usuario: String,
    val password: String,
)

// Respuesta JSON de POST /login. nombre y rol son null cuando el login falla.
@Serializable
data class LoginResponse(
    val ok: Boolean,
    val nombre: String?,
    val rol: Rol?,
    val mensaje: String,
)
