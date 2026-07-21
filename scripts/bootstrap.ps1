$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ProjectRoot = Split-Path -Parent $PSScriptRoot

function Assert-Command {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [string]$InstallHint
    )

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Команда '$Name' не найдена. $InstallHint"
    }
}

Assert-Command -Name "git" -InstallHint "Установите Git."
Assert-Command -Name "docker" -InstallHint "Установите Docker Desktop или Docker Engine."

& docker compose version *> $null
if ($LASTEXITCODE -ne 0) {
    throw "Требуется Docker Compose v2 (команда 'docker compose')."
}

$EnvFile = Join-Path $ProjectRoot ".env"
$EnvExample = Join-Path $ProjectRoot ".env.example"

if (-not (Test-Path -LiteralPath $EnvFile)) {
    Copy-Item -LiteralPath $EnvExample -Destination $EnvFile
    Write-Host "Создан локальный файл .env из .env.example."
}
else {
    Write-Host "Файл .env уже существует и оставлен без изменений."
}

Write-Host "Локальное окружение подготовлено. Для запуска выполните: make up"
