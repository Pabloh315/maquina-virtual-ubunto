Título: feat(movil): conectar API real y generar APK técnico (#19)

Refs #19

La app ahora consulta la API Laravel real de EDT 3.3 y permite registrar y volver a consultar vehículos persistidos en PostgreSQL. Se incorpora una entrada técnica sin login porque esos endpoints aún no tienen autenticación; los demás recorridos conservan el modo simulado separado.

Cambios:

- Adaptación del recurso de vehículos y la paginación de Laravel.
- Comprobación de API y base de datos, listado, detalle y registro real.
- Manejo de validaciones por campo, errores HTTP, desconexiones, timeout y respuestas inválidas.
- HTTP debug restringido a direcciones locales de emulador/USB; HTTPS mantiene la validación de certificados.
- Entorno reproducible con un cluster PostgreSQL propio y datos ficticios, sin credenciales versionadas.
- APK técnico debug 1.0.0+19, documentación y evidencia bajo `movil/docs/edt34/`.

Validación:

- Pruebas Flutter de transporte, contrato Laravel, widgets y regresión del simulador.
- Recorrido Android real con GET 200, POST 422, POST 201 y GET 404 registrados en `evidence/android-integration.json`.
- El vehículo creado desde Android se confirmó directamente en PostgreSQL y mediante la API después de reiniciar ambos servicios, según `evidence/postgresql-persistence.json`.
- Capturas Android de conexión, validación, registro y detalle.
- APK y huella SHA-256 identificados en `evidence/apk.json`.

La API y PostgreSQL deben estar encendidos para revisar el APK. El artefacto técnico está configurado para `http://10.0.2.2:8000/api` en emulador. No se han implementado endpoints de autenticación ni de módulos de negocio que todavía no existen en el backend.

Destino del PR: `develop`. Pendiente de revisión y aprobación cruzada del compañero.
