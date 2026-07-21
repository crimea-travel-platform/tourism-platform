#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

require_command() {
  local command_name="$1"
  local install_hint="$2"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Ошибка: команда "%s" не найдена. %s\n' "${command_name}" "${install_hint}" >&2
    return 1
  fi
}

require_command git "Установите Git."
require_command docker "Установите Docker Desktop или Docker Engine."

if ! docker compose version >/dev/null 2>&1; then
  printf 'Ошибка: требуется Docker Compose v2 (команда "docker compose").\n' >&2
  exit 1
fi

if [[ ! -f "${PROJECT_ROOT}/.env" ]]; then
  cp "${PROJECT_ROOT}/.env.example" "${PROJECT_ROOT}/.env"
  printf 'Создан локальный файл .env из .env.example.\n'
else
  printf 'Файл .env уже существует и оставлен без изменений.\n'
fi

printf 'Локальное окружение подготовлено. Для запуска выполните: make up\n'
