# Validación de la base móvil de la issue 17

Fecha de comprobación: 28 de octubre de 2026. Rama de trabajo: `feature/17-movil-inicializacion-navegacion-datos-simulados`.

## Comprobación automatizada

- `flutter analyze`: sin observaciones.
- `flutter test`: 9 pruebas aprobadas. Cubren acceso, modelos, filtrado por vehículo, paginación, odómetro, antecedentes, límites de planes, reservas y coherencia entre plan e historial; además incluyen un recorrido de las doce pantallas en una superficie de 390 × 844.
- Recorrido Android con `flutter drive`, ejecutado en Pixel 7, Android 16/API 36, `emulator-5554`: acceso demo, las cuatro pestañas y las pantallas auxiliares sin excepciones Flutter.

## Evidencia Android

- [Acceso y modo demostración](evidence/01_acceso.png).
- [Inicio con información simulada](evidence/02_inicio.png).
- [Historial del vehículo](evidence/03_historial.png).

Las imágenes son capturas de la aplicación ejecutada en el emulador. Se regeneran con el comando de integración documentado en el README.

## Revisión pendiente del equipo

- Revisar las pantallas y recorridos con los mockups completos de M01. La cuota de Figma impidió una nueva consulta de todos los detalles visuales; la base se construyó con las referencias previamente disponibles.
- Confirmar con E2 los campos de presentación y rutas propuestas para EDT 3.4, la autenticación real y los permisos por rol/recurso.
- Registrar commits, subir la rama y abrir el Pull Request hacia `develop` cuando se revise la entrega local.
- Obtener la revisión y aprobación del compañero. Esta documentación no certifica una aprobación cruzada.

## Alcance de la demostración

La cuenta y los datos son ficticios. Los cambios se reinician con el proceso. El registro de usuarios, recuperación de contraseña y alta de vehículos están señalados como funcionalidades futuras en las pantallas base; fotografías, seguimiento, cierre de órdenes y reprogramación requieren sus siguientes entregas.

El registro de mantenimiento guarda antecedentes y conserva el historial confirmado. El fixture de aceite usa la última atención del historial, 77.900 km del 12/07/2026, para calcular el siguiente límite de 87.900 km o 12/01/2027. Los números ilustrativos de M01 y del documento se armonizaron para mantener esa regla.
