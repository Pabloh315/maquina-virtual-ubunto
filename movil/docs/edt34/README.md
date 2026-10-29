# EDT 3.4 Conexión real Android API y PostgreSQL

Issue #19, milestone M02. Fecha de validación: 29 de octubre de 2026. Rama: `feature/19-movil-api-real-apk-pruebas`.

## Alcance

Se consumen los endpoints que existen en EDT 3.3: `GET /api/health`, `GET /api/database`, `GET /api/v1/vehicles`, `GET /api/v1/vehicles/{id}` y `POST /api/v1/vehicles`. La comprobación de base de datos se restringe a `local/testing` en el backend. Si está deshabilitada, se informa esa condición y el listado se consulta de forma independiente.

La entrada técnica no solicita credenciales: el backend actual no tiene login. Mantenimiento, alertas, talleres, citas e historial permanecen en el modo simulado de EDT 3.2 y no se presentan como operaciones reales. El alta utiliza datos ficticios y referencias numéricas existentes; no hay endpoint de catálogos para seleccionar esas referencias por nombre.

## Preparar el backend local en Windows

El código PHP usa la versión y las dependencias fijadas por EDT 3.3. Para no depender del PHP global:

```powershell
# Desde la raíz del repositorio
./scripts/Install-LocalPhp.ps1
cd web
$env:PATH = (Resolve-Path .runtime/php).Path + ';' + $env:PATH
composer install --no-interaction --prefer-dist
cd ..
./scripts/Edt34-LocalDemo.ps1 -Action start
```

Se necesita PostgreSQL instalado. El helper usa por defecto `C:\Program Files\PostgreSQL\18\bin`; para otra instalación, definir `EDT34_POSTGRES_BIN` con su carpeta `bin` antes de iniciarlo.

El helper crea un cluster propio bajo `web/.runtime/edt34-postgres`, con escucha únicamente en `127.0.0.1:55434`, usuario local `autocare_edt34` y base `mantenimiento_vehiculos_edt34`. Genera una contraseña aleatoria, ejecuta las migraciones y seeders existentes y arranca el servidor de EDT 3.3 en `127.0.0.1:8000`. No borra bases existentes. Si encuentra un `.env` de otro entorno, se detiene para conservarlo: en ese caso usar la API ya configurada o preparar otro checkout para la demo.

La contraseña, clave de aplicación, cluster, logs y dependencias están en rutas ignoradas por Git. No adjuntar `.env` ni el directorio `.runtime` como evidencia.

Comprobar y detener la demo cuando termine su uso:

```powershell
./scripts/Edt34-LocalDemo.ps1 -Action check
./scripts/Edt34-LocalDemo.ps1 -Action stop
```

`start` reutiliza el cluster propio y las migraciones existentes. El seeder idempotente de EDT 3.3 actualiza únicamente su vehículo ficticio `DEMO-001`. El servidor y PostgreSQL deben permanecer encendidos mientras se revise la app conectada.

## Ejecutar en Android

```powershell
cd movil
flutter pub get
flutter emulators --launch Pixel_7
$env:JAVA_HOME = 'C:\Program Files\Android\Android Studio2\jbr'
flutter run -d emulator-5554
```

Los identificadores del emulador y la ruta de Java dependen del equipo. `10.0.2.2` permite llegar al anfitrión desde el emulador Android. La URL de esta entrega es `http://10.0.2.2:8000/api`.

Para un dispositivo físico por USB, activar depuración USB y usar el túnel ADB y una compilación con loopback:

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe" reverse tcp:8000 tcp:8000
flutter run -d ID_DEL_DISPOSITIVO --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

La instalación en dispositivo físico queda pendiente de disponer de ese equipo. El APK técnico de esta entrega se verifica en emulador. Para un despliegue externo se requiere un servidor HTTPS; los certificados se validan normalmente y HTTP local solo se habilita en debug.

## Recorrido reproducible

1. Pulsar **Conectar con API**. Verificar servicio disponible y `Conectada · pgsql`.
2. Revisar los vehículos devueltos por Laravel, incluida la placa ficticia `DEMO-001`.
3. Abrir una ficha: se ejecuta un nuevo GET por ID, sin datos del fixture simulado.
4. Abrir **Registrar vehículo en la API**. Las referencias iniciales se toman de un registro existente; pueden ajustarse a IDs válidos del servidor.
5. Probar una placa repetida para recibir HTTP 422 y revisar el mensaje por campo.
6. Registrar una placa ficticia nueva, año y kilometraje válidos. Confirmar que aparece al volver a consultar el listado y el detalle.

La app obtiene todas las páginas declaradas por `meta.last_page`; no confunde `page_size` del contrato propuesto con la paginación efectiva de Laravel. Los datos anidados de marca, modelo y categoría se adaptan al modelo móvil sin modificar el backend.

## Pruebas y evidencia

```powershell
cd movil
flutter analyze
flutter test
flutter drive --driver=test_driver/real_api_driver.dart --target=integration_test/real_api_test.dart -d emulator-5554
```

Las pruebas unitarias usan servidores HTTP loopback controlados para errores de red, timeout, formato, 401, 403, 404, 422, 429, 500 y 503. Esas pruebas son independientes del recorrido de Android contra Laravel y PostgreSQL reales. También se verifica que los doce recorridos del simulador sigan funcionando.

Resultado registrado el 29/10/2026: análisis sin observaciones, 26 pruebas Flutter aprobadas y recorrido Android real aprobado. El registro creado desde Android se recuperó directamente de PostgreSQL y por GET después de reiniciar la API y el cluster. El APK normal se instaló como versión `1.0.0+19` y su proceso se verificó en `emulator-5554`.

- [Resumen de validación](evidence/validation.json).
- [Solicitudes HTTP reales de Android](evidence/android-integration.json).
- [Persistencia SQL después del reinicio](evidence/postgresql-persistence.json).
- [Conexión real](evidence/01_conexion_real.png), [validación 422](evidence/02_validacion_422.png), [vehículo guardado](evidence/03_vehiculo_guardado.png) y [detalle](evidence/04_detalle_postgresql.png).

La prueba Android genera capturas y un registro saneado en `evidence/`: solo métodos, rutas, estados HTTP y datos ficticios del vehículo creado. No guarda cabeceras de autenticación, contraseñas ni cuerpos privados. El archivo `android-integration.json` y el resultado de la comprobación SQL documentan la ejecución real cuando están presentes.

## APK técnico

```powershell
cd movil
flutter build apk --debug --dart-define=API_MODE=http --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

Salida estándar: `build/app/outputs/flutter-apk/app-debug.apk`. La copia de entrega será `build/edt34/autocare-edt34-tecnico.apk`, con su SHA-256 en `evidence/apk.json`. Versión `1.0.0+19`, firma debug. El APK requiere la API local encendida y está configurado para el emulador; para USB debe recompilarse con `127.0.0.1` como se indicó arriba.

El tamaño y la huella SHA-256 de la compilación entregada están en [apk.json](evidence/apk.json). Una compilación nueva debe verificarse de nuevo. Las capturas de validación conservan el aspecto de la ejecución original; posteriormente se retiraron de la pantalla principal los avisos técnicos y la referencia a la EDT.

El APK y el cluster no se incluyen en Git. El código, documentación y evidencia saneada sí forman parte de la entrega.

## GitHub y revisión cruzada

Revisar el diff de esta rama, registrar el commit con la identidad del contribuyente y crear el PR hacia `develop`, enlazando `Refs #19`. La aprobación del compañero debe registrarse en GitHub; no se considera cumplida automáticamente por las pruebas técnicas. La publicación del código y la revisión cruzada quedan pendientes hasta completar ese flujo.
