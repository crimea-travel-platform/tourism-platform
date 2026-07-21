#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
SUPERPROJECT_ROOT="$(cd -- "${PROJECT_ROOT}/.." && pwd)"
GITHUB_ORG="${GITHUB_ORG:-crimea-travel-platform}"
REPOSITORIES=(
  tourism-mobile
  tourism-backend
  tourism-infrastructure
  tourism-documentation
)

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    printf 'Ошибка: обязательная команда "%s" не найдена.\n' "${command_name}" >&2
    exit 1
  fi
}

require_command git
require_command gh

if ! git -C "${PROJECT_ROOT}" rev-parse --show-toplevel >/dev/null 2>&1; then
  printf 'Ошибка: %s не является Git-репозиторием.\n' "${PROJECT_ROOT}" >&2
  exit 1
fi

if [[ "$(git -C "${SUPERPROJECT_ROOT}" rev-parse --show-toplevel 2>/dev/null)" != \
  "${SUPERPROJECT_ROOT}" ]]; then
  printf 'Ошибка: %s не является Git superproject.\n' "${SUPERPROJECT_ROOT}" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  printf 'Ошибка: GitHub CLI не авторизован. Выполните "gh auth login".\n' >&2
  exit 1
fi

printf 'Проверка репозиториев организации %s...\n' "${GITHUB_ORG}"
for repository in "${REPOSITORIES[@]}"; do
  target="${SUPERPROJECT_ROOT}/${repository}"
  if [[ -e "${target}" ]]; then
    printf 'Пропуск %s: каталог уже существует и не будет перезаписан.\n' "${target}"
    continue
  fi

  if ! gh repo view "${GITHUB_ORG}/${repository}" >/dev/null 2>&1; then
    printf 'Ошибка: репозиторий %s/%s недоступен или ещё не создан.\n' \
      "${GITHUB_ORG}" "${repository}" >&2
    exit 1
  fi
done

for repository in "${REPOSITORIES[@]}"; do
  target="${SUPERPROJECT_ROOT}/${repository}"
  if [[ -e "${target}" ]]; then
    continue
  fi

  printf 'Добавление submodule %s...\n' "${repository}"
  if ! git -C "${SUPERPROJECT_ROOT}" submodule add \
    "https://github.com/${GITHUB_ORG}/${repository}.git" \
    "${repository}"; then
    printf 'Ошибка: не удалось добавить submodule %s/%s.\n' \
      "${GITHUB_ORG}" "${repository}" >&2
    exit 1
  fi
done

printf 'Готово. Проверьте .gitmodules и submodule pointers в %s.\n' \
  "${SUPERPROJECT_ROOT}"
