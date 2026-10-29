[CmdletBinding()]
param(
    [ValidateSet('start', 'check', 'stop')]
    [string] $Action = 'check',

    [ValidateSet('127.0.0.1', '0.0.0.0')]
    [string] $HostAddress = '127.0.0.1',

    [ValidateRange(1024, 65535)]
    [int] $Port = 8000
)

$ErrorActionPreference = 'Stop'

$repositoryRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$webRoot = Join-Path $repositoryRoot 'web'
$phpExecutable = Join-Path $webRoot '.runtime\php\php.exe'
$pidFile = Join-Path $webRoot 'storage\framework\edt33-server.pid'
$stdoutLog = Join-Path $webRoot 'storage\logs\edt33-server.log'
$stderrLog = Join-Path $webRoot 'storage\logs\edt33-server-error.log'
$baseUrl = "http://127.0.0.1:$Port"

function Get-DemoProcess {
    if (-not (Test-Path -LiteralPath $pidFile)) {
        return $null
    }

    $storedPid = [int](Get-Content -LiteralPath $pidFile -Raw)
    $process = Get-CimInstance Win32_Process -Filter "ProcessId = $storedPid" -ErrorAction SilentlyContinue

    if ($null -eq $process) {
        return $null
    }

    $expectedExecutable = (Resolve-Path $phpExecutable).Path
    if ($process.ExecutablePath -ne $expectedExecutable -or $process.CommandLine -notmatch 'artisan\s+serve') {
        throw "El PID $storedPid ya no pertenece al servidor de la EDT 3.3."
    }

    return $process
}

function Get-DemoDescendantProcesses {
    param([int] $ParentProcessId)

    $allProcesses = @(Get-CimInstance Win32_Process)
    $pendingProcessIds = [Collections.Generic.Queue[int]]::new()
    $descendants = [Collections.Generic.List[object]]::new()
    $pendingProcessIds.Enqueue($ParentProcessId)

    while ($pendingProcessIds.Count -gt 0) {
        $currentParentId = $pendingProcessIds.Dequeue()
        $children = $allProcesses | Where-Object { $_.ParentProcessId -eq $currentParentId }

        foreach ($childProcess in $children) {
            $descendants.Add($childProcess)
            $pendingProcessIds.Enqueue([int] $childProcess.ProcessId)
        }
    }

    return $descendants
}

function Invoke-DemoCheck {
    $health = Invoke-RestMethod -Uri "$baseUrl/api/health" -Headers @{ Accept = 'application/json' }
    $database = Invoke-RestMethod -Uri "$baseUrl/api/database" -Headers @{ Accept = 'application/json' }
    $vehicles = Invoke-RestMethod -Uri "$baseUrl/api/v1/vehicles" -Headers @{ Accept = 'application/json' }

    [pscustomobject]@{
        Web = $baseUrl
        Api = $health.status
        Service = $health.service
        PostgreSQL = $database.status
        Driver = $database.driver
        Vehicles = $vehicles.meta.total
    } | Format-List
}

if (-not (Test-Path -LiteralPath $phpExecutable)) {
    throw 'Falta el runtime local. Ejecute primero: powershell -ExecutionPolicy Bypass -File scripts\Install-LocalPhp.ps1'
}

switch ($Action) {
    'start' {
        $existingProcess = Get-DemoProcess
        if ($null -ne $existingProcess) {
            Write-Host "El servidor ya está iniciado con PID $($existingProcess.ProcessId)."
            Invoke-DemoCheck
            break
        }

        Push-Location $webRoot
        try {
            & $phpExecutable artisan migrate:status --no-ansi | Out-Host
            if ($LASTEXITCODE -ne 0) {
                throw 'PostgreSQL no está disponible o las migraciones no pueden consultarse.'
            }

            $startParameters = @{
                FilePath = $phpExecutable
                ArgumentList = @('artisan', 'serve', "--host=$HostAddress", "--port=$Port")
                WorkingDirectory = $webRoot
                WindowStyle = 'Hidden'
                RedirectStandardOutput = $stdoutLog
                RedirectStandardError = $stderrLog
                PassThru = $true
            }
            $process = Start-Process @startParameters
            [IO.File]::WriteAllText($pidFile, $process.Id.ToString(), [Text.UTF8Encoding]::new($false))
        } finally {
            Pop-Location
        }

        $ready = $false
        for ($attempt = 0; $attempt -lt 20; $attempt++) {
            Start-Sleep -Milliseconds 500
            try {
                $response = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/api/health" -Headers @{ Accept = 'application/json' }
                if ($response.StatusCode -eq 200) {
                    $ready = $true
                    break
                }
            } catch {
                # El servidor todavía está iniciando.
            }
        }

        if (-not $ready) {
            throw "El servidor no respondió. Revise $stderrLog"
        }

        Write-Host "Demostración iniciada en $baseUrl"
        if ($HostAddress -eq '0.0.0.0') {
            Write-Warning 'El servidor escucha en la red local. Úselo solo en una red de confianza y deténgalo al finalizar.'
        }
        Invoke-DemoCheck
    }

    'check' {
        Invoke-DemoCheck
    }

    'stop' {
        $process = Get-DemoProcess
        if ($null -eq $process) {
            if (Test-Path -LiteralPath $pidFile) {
                Remove-Item -LiteralPath $pidFile
            }
            Write-Host 'No hay un servidor de demostración activo.'
            break
        }

        $descendants = @(Get-DemoDescendantProcesses -ParentProcessId $process.ProcessId)
        Stop-Process -Id $process.ProcessId
        foreach ($descendantProcess in $descendants) {
            Stop-Process -Id $descendantProcess.ProcessId -Force -ErrorAction SilentlyContinue
        }
        Wait-Process -Id $process.ProcessId -Timeout 10 -ErrorAction SilentlyContinue

        if (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue) {
            throw "El puerto $Port continúa ocupado; no se detuvo ningún proceso ajeno a la demo."
        }

        Remove-Item -LiteralPath $pidFile -ErrorAction SilentlyContinue
        Write-Host 'Servidor de demostración detenido correctamente.'
    }
}