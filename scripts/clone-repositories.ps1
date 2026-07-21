$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$WorkspaceDir = Join-Path $ProjectRoot "workspace"
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
    $Target = Join-Path $WorkspaceDir $Repository
    if (Test-Path -LiteralPath $Target) {
        Write-Host "Пропуск $Target`: каталог уже существует и не будет перезаписан."
        continue
    }

    & gh repo view "$GitHubOrg/$Repository" *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "Репозиторий $GitHubOrg/$Repository недоступен или ещё не создан."
    }
}

New-Item -ItemType Directory -Path $WorkspaceDir -Force | Out-Null

foreach ($Repository in $Repositories) {
    $Target = Join-Path $WorkspaceDir $Repository
    if (Test-Path -LiteralPath $Target) {
        continue
    }

    Write-Host "Добавление submodule $Repository..."
    & git -C $ProjectRoot submodule add `
        "https://github.com/$GitHubOrg/$Repository.git" `
        "workspace/$Repository"
    if ($LASTEXITCODE -ne 0) {
        throw "Не удалось добавить submodule $Repository."
    }
}

Write-Host "Готово. Проверьте изменения .gitmodules и gitlinks перед commit."
