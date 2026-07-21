# Стратегия репозиториев

## Управляющий репозиторий

`tourism-platform` является workspace и точкой входа для документации,
локальной разработки и orchestration. Прикладной код не смешивается в одном
Git history.

Планируемая структура:

```text
tourism-platform/
├── docs/
├── scripts/
├── compose.yaml
└── workspace/
    ├── tourism-mobile/
    ├── tourism-backend/
    ├── tourism-infrastructure/
    └── tourism-documentation/
```

Каталоги внутри `workspace/` предназначены для будущих Git submodules:

- `workspace/tourism-mobile` — Flutter mobile application;
- `workspace/tourism-backend` — modular monolith и API;
- `workspace/tourism-infrastructure` — Kubernetes, Helm и environments;
- `workspace/tourism-documentation` — расширенная документация.

Remote repositories пока не существуют. Пустые submodules и фиктивный
`.gitmodules` сейчас не создаются. После появления private remotes
`scripts/clone-repositories.sh` или его PowerShell-аналог предварительно
проверит доступность всех repositories и добавит отсутствующие submodules.
Существующие каталоги скрипт не перезаписывает.

Local Compose остаётся в `tourism-platform`, поскольку обеспечивает общий
developer workspace. Production deployment assets принадлежат только
`tourism-infrastructure`.

## Правила зависимостей

- Mobile зависит от опубликованного API contract, а не от backend source.
- Backend не зависит от mobile repository.
- Infrastructure получает versioned artifacts и configuration contracts, но
  не копирует application source.
- Workspace хранит совместимые версии через submodule commits.
- Изменение API сначала описывается контрактом, затем реализуется и только
  после этого потребляется mobile.

## Рабочий процесс

1. Разработка и review выполняются в соответствующем дочернем repository.
2. После merge управляющий repository обновляет submodule pointer.
3. Интеграционная проверка запускается на зафиксированной комбинации commits.
4. Несовместимые обновления не объединяются в workspace до готовности всех
   потребителей.

## Что не следует хранить в управляющем репозитории

- application code mobile или backend;
- production secrets и локальные `.env`;
- vendor binaries и пользовательские данные;
- копии содержимого submodules;
- legacy code или resources без лицензии.
