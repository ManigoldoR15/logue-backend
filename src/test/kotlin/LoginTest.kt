package com.logue

import io.ktor.client.call.body
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.testing.testApplication
import kotlin.test.*

class LoginTest {

    @Test
    fun `login correcto devuelve nombre y rol`() = testApplication {
        configure()
        val client = createClient { install(ContentNegotiation) { json() } }
        val response = client.post("/login") {
            contentType(ContentType.Application.Json)
            setBody(LoginRequest("paramedico1", "1234"))
        }
        assertEquals(HttpStatusCode.OK, response.status)
        val body = response.body<LoginResponse>()
        assertTrue(body.ok)
        assertEquals(Rol.PARAMEDICO, body.rol)
    }

    @Test
    fun `login incorrecto devuelve 401`() = testApplication {
        configure()
        val client = createClient { install(ContentNegotiation) { json() } }
        val response = client.post("/login") {
            contentType(ContentType.Application.Json)
            setBody(LoginRequest("admin1", "mal"))
        }
        assertEquals(HttpStatusCode.Unauthorized, response.status)
        assertFalse(response.body<LoginResponse>().ok)
    }
}
