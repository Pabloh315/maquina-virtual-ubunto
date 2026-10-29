[CmdletBinding()]
param([ValidateSet('start', 'check', 'stop')][string] $Action = 'check')

$ErrorActionPreference = 'Stop'
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$webRoot = Join-Path $projectRoot 'web'
$runtimeRoot = Join-Path $webRoot '.runtime'
$clusterRoot = [IO.Path]::GetFullPath((Join-Path $runtimeRoot 'edt34-postgres'))
$phpExecutable = Join-Path $runtimeRoot 'php\php.exe'
$postgresBin = if ($env:EDT34_POSTGRES_BIN) { $env:EDT34_POSTGRES_BIN } else { 'C:\Program Files\PostgreSQL\18\bin' }
$databaseName = 'mantenimiento_vehiculos_edt34'
$databaseUser = 'autocare_edt34'
$databasePort = 55434
$envFile = Join-Path $webRoot '.env'
$pgControl = Join-Path $postgresBin 'pg_ctl.exe'

if (-not $clusterRoot.StartsWith($runtimeRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Ruta del cluster fuera del runtime local.'
}

if ($Action -eq 'stop') {
    & (Join-Path $PSScriptRoot 'Edt33-Demo.ps1') -Action stop
    if (Test-Path -LiteralPath (Join-Path $clusterRoot 'PG_VERSION')) {
        & $pgControl -D $clusterRoot status *> $null
        if ($LASTEXITCODE -eq 0) { & $pgControl -D $clusterRoot -m fast -w stop }
    }
    exit 0
}
if ($Action -eq 'check') {
    & (Join-Path $PSScriptRoot 'Edt33-Demo.ps1') -Action check
    exit 0
}
if (-not (Test-Path -LiteralPath $phpExecutable) -or -not (Test-Path -LiteralPath (Join-Path $webRoot 'vendor\autoload.php'))) {
    throw 'Instale primero el PHP local y las dependencias de Composer siguiendo la documentacion EDT 3.4.'
}
if (-not (Test-Path -LiteralPath $pgControl)) { throw 'Falta PostgreSQL. Configure EDT34_POSTGRES_BIN con su carpeta bin.' }

$listeners = @(Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue)
if ($listeners.Count -gt 0) {
    $serverPidFile = Join-Path $webRoot 'storage\framework\edt33-server.pid'
    if (-not (Test-Path -LiteralPath $serverPidFile)) { throw 'El puerto 8000 pertenece a otro servidor. Detenga o configure ese entorno antes de iniciar esta demo.' }
    $serverId = [int](Get-Content -LiteralPath $serverPidFile -Raw)
    $serverProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $serverId" -ErrorAction SilentlyContinue
    if ($null -eq $serverProcess -or $serverProcess.ExecutablePath -ne $phpExecutable -or $serverProcess.CommandLine -notmatch 'artisan\s+serve') {
        throw 'El puerto 8000 no pertenece al servidor local registrado.'
    }
    foreach ($listener in $listeners) {
        $ownerId = [int]$listener.OwningProcess
        $belongsToDemo = $false
        for ($depth = 0; $depth -lt 12 -and $ownerId -gt 0; $depth++) {
            if ($ownerId -eq $serverId) { $belongsToDemo = $true; break }
            $ownerProcess = Get-CimInstance Win32_Process -Filter "ProcessId = $ownerId" -ErrorAction SilentlyContinue
            if ($null -eq $ownerProcess) { break }
            $ownerId = [int]$ownerProcess.ParentProcessId
        }
        if (-not $belongsToDemo) {
            throw 'El puerto 8000 esta ocupado por un proceso ajeno a esta demo.'
        }
    }
}

if (Test-Path -LiteralPath $envFile) {
    $localConfig = [IO.File]::ReadAllText($envFile)
    if ($localConfig -notmatch "(?m)^DB_DATABASE=$databaseName\r?$" -or $localConfig -notmatch "(?m)^DB_PORT=$databasePort\r?$") {
        throw 'Existe un .env de otro entorno. Se conserva: configure su API manualmente o use otro checkout para esta demo.'
    }
    $databasePassword = [regex]::Match($localConfig, '(?m)^DB_PASSWORD=([^\r\n]+)').Groups[1].Value
} else {
    $randomBytes = [byte[]]::new(24)
    $randomGenerator = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $randomGenerator.GetBytes($randomBytes) } finally { $randomGenerator.Dispose() }
    $databasePassword = [BitConverter]::ToString($randomBytes).Replace('-', '')
}

New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
if (-not (Test-Path -LiteralPath (Join-Path $clusterRoot 'PG_VERSION'))) {
    $passwordFile = Join-Path $runtimeRoot 'edt34-init-password.tmp'
    try {
        [IO.File]::WriteAllText($passwordFile, $databasePassword, [Text.UTF8Encoding]::new($false))
        & (Join-Path $postgresBin 'initdb.exe') -D $clusterRoot -U $databaseUser -A scram-sha-256 --pwfile=$passwordFile --encoding=UTF8 --locale=C
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo inicializar el cluster de demostracion.' }
    } finally {
        Remove-Item -LiteralPath $passwordFile -ErrorAction SilentlyContinue
    }
}
& $pgControl -D $clusterRoot status *> $null
if ($LASTEXITCODE -ne 0) {
    & $pgControl -D $clusterRoot -l (Join-Path $runtimeRoot 'edt34-postgres.log') -o "-h 127.0.0.1 -p $databasePort" -w start
    if ($LASTEXITCODE -ne 0) { throw 'PostgreSQL no pudo iniciar; revise si el puerto esta ocupado.' }
}

$previousPassword = $env:PGPASSWORD
try {
    $env:PGPASSWORD = $databasePassword
    $existingDatabase = & (Join-Path $postgresBin 'psql.exe') -h 127.0.0.1 -p $databasePort -U $databaseUser -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$databaseName'"
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar el cluster local.' }
    if ($existingDatabase -ne '1') {
        & (Join-Path $postgresBin 'createdb.exe') -h 127.0.0.1 -p $databasePort -U $databaseUser $databaseName
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo crear la base de demostracion.' }
    }
} finally { $env:PGPASSWORD = $previousPassword }

if (-not (Test-Path -LiteralPath $envFile)) {
    $content = [IO.File]::ReadAllText((Join-Path $webRoot '.env.example'))
    $values = @{ DB_DATABASE = $databaseName; DB_PORT = "$databasePort"; DB_USERNAME = $databaseUser; DB_PASSWORD = $databasePassword; APP_DEBUG = 'false' }
    foreach ($entry in $values.GetEnumerator()) { $content = [regex]::Replace($content, "(?m)^$($entry.Key)=[^\r\n]*", "$($entry.Key)=$($entry.Value)") }
    [IO.File]::WriteAllText($envFile, $content, [Text.UTF8Encoding]::new($false))
}
Push-Location $webRoot
try {
    if ([IO.File]::ReadAllText($envFile) -match '(?m)^APP_KEY=\r?$') {
        & $phpExecutable artisan key:generate --no-interaction
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo generar la clave local.' }
    }
    & $phpExecutable artisan migrate --seed --no-interaction
    if ($LASTEXITCODE -ne 0) { throw 'Fallo la preparacion de las migraciones o los datos demo.' }
} finally { Pop-Location }
& (Join-Path $PSScriptRoot 'Edt33-Demo.ps1') -Action start
