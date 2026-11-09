# Integración Flutter

1. Enviar JSON a `POST /api/login` con `email`, `password` y opcional `device_name`.
2. Conservar el token solo en almacenamiento seguro del dispositivo.
3. Enviar `Authorization: Bearer <token>` a `/api/me`, `/api/logout` y recursos privados.
4. Al recibir 401, eliminar el token y volver al acceso; ante 403 mostrar falta de permiso; ante 429 esperar antes de reintentar.
5. No registrar ni mostrar el token. El campo `user.permissions` permite adaptar la interfaz, pero la API sigue siendo la autoridad final.
