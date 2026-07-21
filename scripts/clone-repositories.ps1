$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$WorkspaceRoot = Split-Path -Parent $ProjectRoot
$GitHubOrg = if ($env:GITHUB_ORG) { $env:GITHUB_ORG } else { "crimea-travel-platform" }
$Repositories = @(
    "tourism-mobile",
    "tourism-backend",
    "tourism-infrastructure",
    "tourism-documentation"
)

function Assert-Command {
    param([Parameter(Mandatory = $true)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Обязательная команда '$Name' не найдена."
    }
}

Assert-Command -Name "git"
Assert-Command -Name "gh"

& git -C $ProjectRoot rev-parse --show-toplevel *> $null
if ($LASTEXITCODE -ne 0) {
    throw "'$ProjectRoot' не является Git-репозиторием."
}

& gh auth status *> $null
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI не авторизован. Выполните 'gh auth login'."
}

Write-Host "Проверка репозиториев организации $GitHubOrg..."
foreach ($Repository in $Repositories) {
    $Target = Join-Path $WorkspaceRoot $Repository
    if (Test-Path -LiteralPath $Target) {
        Write-Host "Пропуск $Target`: каталог уже существует и не будет перезаписан."
        continue
    }

    & gh repo view "$GitHubOrg/$Repository" *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Репозиторий $GitHubOrg/$Repository недоступен или ещё не создан."
    }
}

foreach ($Repository in $Repositories) {
    $Target = Join-Path $WorkspaceRoot $Repository
    if (Test-Path -LiteralPath $Target) {
        continue
    }

    Write-Host "Клонирование sibling repository $Repository..."
    & gh repo clone "$GitHubOrg/$Repository" $Target
    if ($LASTEXITCODE -ne 0) {
        throw "Не удалось клонировать $GitHubOrg/$Repository."
    }
}

Write-Host "Готово. Репозитории размещены рядом с tourism-platform в $WorkspaceRoot."
