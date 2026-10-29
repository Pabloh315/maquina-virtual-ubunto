# Entorno de demostración local

## PHP reproducible

El PHP global no tenía `pdo_pgsql`. `scripts/Install-LocalPhp.ps1` instala bajo `web/.runtime` PHP 8.5.12 NTS x64 desde el archivo oficial, verifica su SHA-256 y habilita `curl`, `fileinfo`, `mbstring`, `openssl`, `pdo_pgsql`, `pgsql` y `zip`. La carpeta queda ignorada por Git.

```powershell
powershell -ExecutionPolicy Bypass -File scripts\Install-LocalPhp.ps1
```

El hash esperado del archivo es `2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723`.

## Datos demo

`Edt33DemoSeeder` crea o actualiza datos ficticios:

- propietario `propietario.demo@example.test`;
- categoría Automóvil;
- marca Toyota y modelo Corolla Demo;
- vehículo `DEMO-001` con VIN ficticio de formato válido.

La operación es idempotente y no borra información existente.

```powershell
cd web
.\.runtime\php\php.exe artisan migrate --seed
```

## Servidor controlado

```powershell
# Inicio local
powershell -ExecutionPolicy Bypass -File scripts\Edt33-Demo.ps1 -Action start

# Comprobación
powershell -ExecutionPolicy Bypass -File scripts\Edt33-Demo.ps1 -Action check

# Apagado
powershell -ExecutionPolicy Bypass -File scripts\Edt33-Demo.ps1 -Action stop
```

El script valida el PID y la línea de comando, inicia la ventana oculta, conserva logs, comprueba API/DB/vehículos y al detener cierra el proceso padre y sus hijos. No detiene procesos ajenos si el puerto está ocupado.

## Android

- Emulador: `10.0.2.2` apunta al equipo anfitrión.
- Dispositivo físico: iniciar con `-HostAddress 0.0.0.0`, consultar la IP con `ipconfig` y usar `http://IP_LAN:8000/api`.
- Usar únicamente una red confiable, permitir el puerto en el firewall solo si es necesario y detener la demo al terminar.
