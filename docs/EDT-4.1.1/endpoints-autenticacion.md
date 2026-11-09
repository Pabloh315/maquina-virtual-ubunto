# Endpoints de autenticación

| Método | Ruta | Autenticación | Resultado |
|---|---|---|---|
| POST | `/api/login` | No | Recibe `email`, `password`, `device_name?`; 200 con usuario público y token. |
| GET | `/api/me` | Bearer | Usuario, roles y permisos. |
| POST | `/api/logout` | Bearer | Revoca el token actual. |
| GET | `/api/access-check` | Bearer + `vehicles.view` | Comprobación técnica protegida. |

`GET/POST /api/v1/vehicles` requieren respectivamente `vehicles.view` y `vehicles.create`. Estados: 401 sin token, 403 sin permiso, 422 validación, 429 límite.

Ejemplo seguro: `Authorization: Bearer <token-obtenido-en-login>`.
