# Endpoints e interfaz
`GET/POST /api/users`, `GET/PUT /api/users/{user}`, `PATCH /api/users/{user}/role`; catálogos con GET/POST/PUT. 401 sin token, 403 sin permiso, 409 duplicado y 422 validación. `/admin` es una vista Blade protegida que muestra usuarios, roles y catálogos; usa middleware de servidor y CSRF del stack web.
