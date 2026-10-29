[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$repositoryRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$runtimeRoot = Join-Path $repositoryRoot 'web\.runtime'
$phpRoot = Join-Path $runtimeRoot 'php'
$phpExecutable = Join-Path $phpRoot 'php.exe'
$archivePath = Join-Path $runtimeRoot 'php-8.5.12-nts-win64.zip'
$downloadUri = 'https://downloads.php.net/~windows/releases/archives/php-8.5.12-1-nts-Win32-vs17-x64.zip'
$expectedHash = '2a36a2edcb7a5b9252f638fd5e4cf84d7f6e066092654220dc0b63e5cf4e9723'

if (Test-Path -LiteralPath $phpExecutable) {
    $modules = & $phpExecutable -m
    if ($modules -contains 'pdo_pgsql') {
        Write-Host "PHP local ya está preparado en $phpRoot"
        exit 0
    }

    throw "Existe un runtime incompleto en $phpRoot. Revíselo antes de reinstalar."
}

New-Item -ItemType Directory -Path $runtimeRoot -Force | Out-Null
Write-Host 'Descargando PHP 8.5.12 oficial...'
Invoke-WebRequest -Uri $downloadUri -OutFile $archivePath

$actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $archivePath).Hash.ToLowerInvariant()
if ($actualHash -ne $expectedHash) {
    throw "La suma SHA-256 no coincide. Esperada: $expectedHash; obtenida: $actualHash"
}

Expand-Archive -LiteralPath $archivePath -DestinationPath $phpRoot

$phpIniLines = @(
    '[PHP]',
    'extension_dir = "ext"',
    'date.timezone = "America/La_Paz"',
    'memory_limit = 512M',
    'expose_php = Off',
    '',
    'extension = curl',
    'extension = fileinfo',
    'extension = mbstring',
    'extension = openssl',
    'extension = pdo_pgsql',
    'extension = pgsql',
    'extension = zip'
)
[IO.File]::WriteAllLines(
    (Join-Path $phpRoot 'php.ini'),
    $phpIniLines,
    [Text.UTF8Encoding]::new($false)
)

$installedModules = & $phpExecutable -m
if ($installedModules -notcontains 'pdo_pgsql') {
    throw 'PHP se descargó, pero pdo_pgsql no pudo habilitarse.'
}

& $phpExecutable -v
Write-Host 'Runtime PHP local preparado correctamente.'