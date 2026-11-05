# AutoCare móvil

Aplicación Flutter Android del Sistema de Gestión de Mantenimiento de Vehículos. La EDT 3.4 (issue #19) conecta con la API Laravel real de la EDT 3.3 y PostgreSQL. Conserva los doce recorridos simulados de EDT 3.2 como modo separado.

## Ejecutar la integración real

Requisitos: Flutter 3.38.4 / Dart 3.10.3 o versiones compatibles con `pubspec.yaml`, Android SDK y un emulador Android. La API debe estar encendida en el equipo anfitrión.

Desde la raíz del repositorio, después de preparar el backend según [la guía EDT 3.4](docs/edt34/README.md):

```powershell
cd movil
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Por defecto se usa `API_MODE=http` y `http://10.0.2.2:8000/api`. El botón **Conectar con API** comprueba el servicio, la conexión PostgreSQL y obtiene los vehículos. Cada ficha se consulta nuevamente por su ID. El formulario registra un vehículo real; requiere IDs existentes de propietario, categoría y modelo y muestra los errores de validación del servidor.

Esta es una entrada técnica sin login porque la API actual todavía no ofrece autenticación. Usa exclusivamente datos ficticios y un servidor de desarrollo. No se llama a endpoints inexistentes ni se sustituyen errores reales por datos simulados.

La base de la URL termina en `/api`; el cliente agrega `/v1/vehicles` para los vehículos. Para otro servidor HTTPS:

```powershell
flutter run --dart-define=API_MODE=http --dart-define=API_BASE_URL=https://SERVIDOR_REAL/api
```

El HTTP local se permite en compilaciones debug únicamente para `10.0.2.2`, `127.0.0.1` y `localhost`. No se deshabilita la verificación de certificados HTTPS. Los APK release requieren HTTPS; la entrega técnica es un APK debug.

Si el Java de Android Studio no funciona, en el equipo de desarrollo se verificó esta ruta. Ajustarla a la instalación de cada equipo:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio2\jbr'
flutter run -d emulator-5554
```

## Ejecutar la demostración simulada de EDT 3.2

```powershell
flutter run --dart-define=API_MODE=mock
```

Cuenta ficticia: `demo@ejemplo.test` / `clave_demo`. El botón **Usar cuenta de demostración** completa los campos. Esta modalidad mantiene inicio, vehículos, mantenimiento, antecedentes, alertas, talleres, citas e historial. Los cambios son locales en memoria y se reinician con el proceso. No se mezclan estos registros con PostgreSQL.

## Estructura

```text
lib/app/                   Estado y rutas del modo simulado, selección de modalidad
lib/core/api/              Transporte HTTP, cliente y errores
lib/core/config/           URL, modalidad y política de HTTP local
lib/core/theme/            Estilos comunes
lib/data/models/           Modelos Dart y adaptación del recurso Laravel
lib/data/repositories/     Repositorios independientes para API real y simulador
lib/data/mock/             Datos y reglas simuladas de EDT 3.2
lib/features/integration/  Conexión, listado, detalle y alta reales
lib/features/              Pantallas de EDT 3.2
test/                      Pruebas de contratos, transporte y widgets
integration_test/          Recorridos Android simulados y contra API real
```

La adaptación real consume IDs numéricos como strings opacos en Flutter, `license_plate`, `current_mileage`, relaciones `category/model/make` y paginación Laravel `current_page/last_page`. Los errores aceptan el sobre propuesto de EDT 2.4 y el formato efectivo Laravel `message/errors`.

La autenticación, permisos por recurso, mantenimiento, talleres, citas y demás endpoints reales se incorporarán cuando el backend los implemente. El contrato inicial de EDT 2.4 era una propuesta; esta entrega documenta las diferencias efectivas sin modificar las rutas del equipo.

## Comprobaciones y entrega

```powershell
flutter analyze
flutter test
flutter drive --driver=test_driver/real_api_driver.dart --target=integration_test/real_api_test.dart -d emulator-5554
flutter build apk --debug
```

- [Configuración, pruebas, APK y evidencia de EDT 3.4](docs/edt34/README.md).
- [Validación histórica de EDT 3.2](docs/VALIDACION_17.md).
- [Capturas de EDT 3.2](docs/evidence/).

Trabajar en `feature/19-movil-api-real-apk-pruebas` y entregar mediante PR hacia `develop`. La revisión y aprobación del compañero siguen siendo un paso humano. Mantener `pubspec.lock` versionado; los secretos, bases locales, dependencias y artefactos de compilación quedan ignorados por Git. Usar la identidad Git del contribuyente, sin coautores automáticos.
