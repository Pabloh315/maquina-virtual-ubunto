# AutoCare móvil

Base Flutter Android de la issue #17 (EDT 3.2): doce pantallas base, navegación y consumo de una API simulada. La aplicación arranca en modo demostración y no necesita un servidor.

## Instalación y ejecución

Requisitos: Flutter 3.38.4 con Dart 3.10.3 o una versión compatible con `pubspec.yaml`, Android SDK y un emulador o dispositivo Android. Abrir `movil/` en Android Studio con los plugins de Flutter y Dart.

Desde la raíz del repositorio:

```powershell
cd movil
flutter pub get
flutter doctor -v
flutter devices
flutter run -d emulator-5554
```

Reemplazar el dispositivo por el que muestre `flutter devices`. Si el emulador está apagado, ejecutar `flutter emulators` y `flutter emulators --launch Pixel_7` con el identificador disponible en el equipo.

Si Flutter informa `Could not determine java version`, seleccionar un JDK válido de Android Studio. En el equipo de desarrollo se encontró válido el de Android Studio2. Para una sesión de PowerShell:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio2\jbr'
flutter run -d emulator-5554
```

La ruta depende de la instalación de cada equipo. No se requiere guardar una ruta personal en el proyecto ni cambiar la configuración global de Git.

## Cuenta de demostración

- Correo: `demo@ejemplo.test`
- Contraseña: `clave_demo`

El botón **Usar cuenta de demostración** completa los campos. Las demás credenciales producen un error de acceso. Todos los datos son ficticios. Los cambios se conservan en memoria y se reinician al cerrar completamente el proceso; no existe sincronización offline.

## Pantallas y recorridos

Acceso → Inicio. La barra principal conecta Inicio, Vehículos, Talleres e Historial.

- Inicio permite abrir alertas, citas, ficha del vehículo y registro de antecedentes.
- Vehículos → ficha → actualización de kilometraje, mantenimientos o historial.
- Mantenimiento → registro de antecedente conocido o desconocido.
- Talleres → detalle → agendar cita → mis citas. Las citas confirmadas permiten cancelación con confirmación.
- Alertas → mantenimientos. Historial permite seleccionar vehículo y copiar los servicios confirmados.
- El menú de cuenta en Inicio permite cerrar sesión.

Las doce pantallas base corresponden a los mockups de M01. La base visual usa el azul y los componentes comunes de la referencia. Debe realizarse una revisión visual conjunta posterior para confirmar fidelidad, dado que la cuota de Figma impidió consultar nuevamente todos los detalles. Se utiliza la tipografía del sistema.

El alta real de usuarios, recuperación de contraseña y alta de vehículos se señalan como próximas etapas desde la interfaz; no se simula que esas operaciones se hayan ejecutado. Los recorridos de la base usan los dos vehículos de prueba existentes. Reportes con fotografías, seguimiento de órdenes y reprogramación transaccional pertenecen a entregas posteriores.

## Estructura

```text
lib/
  app/                 # Estado compartido, rutas y composición de la aplicación
  core/api/            # Cliente, errores y transporte HTTP intercambiable
  core/config/         # Configuración por dart-define
  core/theme/          # Colores y estilos comunes
  data/models/         # Modelos tipados desde JSON
  data/mock/           # Transporte simulado con latencia y reglas
  data/repositories/   # Consultas utilizadas por las pantallas
  features/            # Pantallas agrupadas por funcionalidad
  shared/              # Componentes y formatos compartidos
assets/mock/api.json    # Datos ficticios alineados al contrato propuesto
test/                   # Pruebas de navegación y reglas del simulador
integration_test/       # Recorrido reproducible en Android
```

## Contrato y conexión futura

La base sigue el documento suministrado **AutoCare EDT 2.4 Contrato API y Revisión Web Móvil FINAL**. Es una propuesta que E1 y E2 deben validar con el modelo de datos real. `https://api.example.invalid/api/v1` es un marcador no operativo.

El cliente usa JSON con sobres `{data, meta?}`, IDs string opacos, `page/page_size`, cabecera Bearer y errores `ApiException` con estado, `code`, `message`, `details` y `requestId`. Los repositorios convierten `snake_case` a modelos Dart y recorren todas las páginas informadas por `meta.total`.

La implementación simulada cubre acceso y cierre de sesión; consultas de vehículos, planes, alertas, talleres, citas e historial; actualización de odómetro; registro de antecedentes; reserva y cancelación de citas. Usa las rutas propuestas en el documento. Los horarios incluyen `-04:00` y se muestran en America/La_Paz independientemente de la zona del dispositivo.

El transporte HTTP nativo está preparado para Android y Windows. Cuando E2 confirme un servidor HTTPS y el contrato, se puede probar explícitamente con:

```powershell
flutter run --dart-define=API_MODE=http --dart-define=API_BASE_URL=https://SERVIDOR_REAL/api/v1
```

El adaptador envía las mismas consultas que el simulador. No se probó con un servidor real. Antes de habilitar autenticación real faltan renovación de tokens, almacenamiento seguro, validación de roles y permisos del servidor y acuerdo definitivo de los campos. El token de esta base vive solo en memoria.

Los campos de presentación no definidos expresamente por los ejemplos del contrato —nombre del usuario, combustible, dirección, horario, detalles de historial y observaciones del antecedente— son extensiones locales del fixture que deberán confirmarse con E2. `verified_brands` describe una verificación de marca, no una especialidad declarada; en el fixture toda esa información es ficticia.

## Reglas verificables

- Una lectura menor de odómetro devuelve `409 ODOMETER_REVIEW_REQUIRED` y conserva la lectura anterior.
- Un plan vence cuando se alcanza el primero de sus límites, fecha o kilómetros.
- Registrar un antecedente no modifica historial confirmado ni reinicia intervalos.
- Una reserva usa `Idempotency-Key`. Repetir una reserva confirmada con la misma clave devuelve el resultado previo; otra reserva en el mismo cupo devuelve `409 SLOT_UNAVAILABLE`.
- Cancelar una cita confirmada libera el horario en el simulador. El backend real deberá garantizar transacciones y permisos.
- Los antecedentes desconocidos envían `known: false` y `date: null`.

## Comprobaciones y evidencia

```powershell
flutter analyze
flutter test
flutter build apk --debug
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5554
```

La prueba de integración recorre las pantallas y guarda capturas de acceso, inicio e historial en `docs/evidence/`. Las pruebas automatizadas no sustituyen la revisión del compañero.

## Entrega en GitHub

Trabajar en `feature/17-movil-inicializacion-navegacion-datos-simulados`. Revisar los archivos con `git status` antes de registrar la entrega y crear un Pull Request hacia `develop` con `Refs #17`, los resultados reales de comprobación y las capturas disponibles. Solicitar revisión al compañero. La issue no está aprobada hasta obtener esa revisión.

Mantener `pubspec.lock` versionado y excluir archivos generados, credenciales, `local.properties` y claves de firma. Los commits deben usar la identidad Git del contribuyente, sin coautores automáticos.
