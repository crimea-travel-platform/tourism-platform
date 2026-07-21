# Стратегия репозиториев

## Управляющий репозиторий

`tourism-platform` является управляющим repository и точкой входа для
документации, локальной разработки и orchestration. Он находится внутри
локальной папки workspace рядом с другими независимыми repositories.
Прикладной код не смешивается в одном Git history.

Планируемая структура:

```text
mobile_travel_app/
├── tourism-platform/
│   ├── docs/
│   ├── scripts/
│   └── compose.yaml
├── tourism-mobile/
├── tourism-backend/
├── tourism-infrastructure/
└── tourism-documentation/
```

`mobile_travel_app` — обычная локальная directory, а не Git repository. Каждый
дочерний каталог является самостоятельным repository:

- `tourism-platform` — управление workspace;
- `tourism-mobile` — Flutter mobile application;
- `tourism-backend` — modular monolith и API;
- `tourism-infrastructure` — Kubernetes, Helm и environments;
- `tourism-documentation` — расширенная документация.

Remote repositories пока не существуют. Пустые repositories сейчас не
создаются. После появления private remotes
`scripts/clone-repositories.sh` или его PowerShell-аналог предварительно
проверит доступность всех repositories и клонирует их рядом с
`tourism-platform`. Существующие каталоги скрипт не перезаписывает.

Local Compose остаётся в `tourism-platform`, поскольку обеспечивает общий
developer workspace. Production deployment assets принадлежат только
`tourism-infrastructure`.

## Правила зависимостей

- Mobile зависит от опубликованного API contract, а не от backend source.
- Backend не зависит от mobile repository.
- Infrastructure получает versioned artifacts и configuration contracts, но
  не копирует application source.
- Совместимость фиксируется версиями API contracts и release metadata.
- Изменение API сначала описывается контрактом, затем реализуется и только
  после этого потребляется mobile.

## Рабочий процесс

1. Разработка и review выполняются в соответствующем дочернем repository.
2. Каждый repository независимо проходит CI и выпускает versioned artifacts.
3. Интеграционная проверка использует явно заданные версии contracts и images.
4. Несовместимые изменения не выпускаются до готовности потребителей.

## Что не следует хранить в управляющем репозитории

- application code mobile или backend;
- production secrets и локальные `.env`;
- vendor binaries и пользовательские данные;
- копии содержимого sibling repositories;
- legacy code или resources без лицензии.
