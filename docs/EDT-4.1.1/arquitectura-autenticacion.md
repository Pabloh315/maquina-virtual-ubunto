# Arquitectura de autenticación

El login valida correo y contraseña, comprueba el hash de Laravel y genera un token Sanctum con las capacidades derivadas de los permisos del rol. Solo el token plano se entrega una vez; la base almacena su hash en `personal_access_tokens`.

`auth:sanctum` identifica al usuario. Después, el middleware `permission:<nombre>` consulta las relaciones de rol y permiso y devuelve 403 si no está autorizado. Los endpoints sin token devuelven 401. La migración nueva es aditiva y compatible con PostgreSQL.

La contraseña está oculta en el modelo y usa el cast `hashed`. Login limita cinco intentos por minuto por correo+IP; el resto de la API tiene límite de 60 por usuario o IP. No se registran contraseñas ni tokens.
