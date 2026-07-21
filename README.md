# Crimea Travel Platform

Crimea Travel Platform — рабочее название новой мобильной туристической
платформы. Первый контентный контур посвящён Республике Крым, но доменная модель
проектируется для нескольких стран, регионов и населённых пунктов.

Проект не является официальным государственным приложением и не заявляет об
официальном партнёрстве с государственными организациями.

## Текущий статус

Репозиторий находится на стадии foundation. Здесь размещены верхнеуровневая
документация, решения об архитектуре, локальная инфраструктура и инструменты
управления будущими репозиториями. Backend и Flutter-приложение ещё не
реализуются.

## Архитектурное направление

- Flutter-клиент с feature-first architecture.
- Python 3.13, FastAPI и modular monolith на первом этапе.
- PostgreSQL с PostGIS для географических данных.
- Чёткие границы `identity`, `users`, `geography`, `places`, `routes`,
  `route_builder` и `media`.
- Независимая от поставщика абстракция `RoutingProvider`.
- Возможность последующего выделения модулей в микросервисы.

Ключевые решения описаны в [docs/decisions](docs/decisions).

## Репозитории

| Repository | Назначение |
| --- | --- |
| `tourism-platform` | Управление workspace, документация и локальный запуск |
| `tourism-mobile` | Flutter-приложение для Android и iOS |
| `tourism-backend` | Модульный Python backend |
| `tourism-infrastructure` | Kubernetes, Helm и конфигурации окружений |
| `tourism-documentation` | Расширенная продуктовая и архитектурная документация |

После создания private remotes остальные repositories клонируются рядом с
`tourism-platform` в общей локальной папке workspace. Они остаются полностью
независимыми Git repositories и не являются submodules.

## Требования

- macOS или Linux;
- Git;
- GitHub CLI (`gh`) для будущего клонирования sibling repositories;
- Docker Desktop или Docker Engine с Compose v2;
- GNU Make;
- PowerShell 7 — только для запуска PowerShell-вариантов скриптов.

## Быстрый локальный запуск

```bash
make init
make up
make ps
```

Локально запускаются только PostgreSQL/PostGIS, Redis, MinIO и Mailpit. Backend
и Flutter намеренно отсутствуют в Compose.

После запуска:

- PostgreSQL: `localhost:5432`;
- Redis: `localhost:6379`;
- MinIO API: `http://localhost:9000`;
- MinIO Console: `http://localhost:9001`;
- Mailpit: `http://localhost:8025`.

Все порты настраиваются через `.env`.

## Команды Makefile

| Команда | Назначение |
| --- | --- |
| `make help` | Показать справку |
| `make init` | Проверить зависимости и создать локальный `.env` |
| `make up` | Запустить инфраструктуру |
| `make down` | Остановить инфраструктуру |
| `make restart` | Перезапустить инфраструктуру |
| `make ps` | Показать состояние контейнеров |
| `make logs` | Следить за логами |
| `make clean CONFIRM=yes` | Удалить контейнеры и локальные volumes |
| `make validate` | Выполнить безопасные локальные проверки |
| `make clone-repositories` | Клонировать sibling repositories |

`make clean` без `CONFIRM=yes` никогда не удаляет volumes.

## Структура

```text
.
├── .github/          # Issue forms, PR template и CI validation
├── docs/             # Видение, модель, ADR, диаграммы и паспорта
├── scripts/          # Bootstrap, validation и управление workspace
├── compose.yaml      # Только локальные инфраструктурные зависимости
├── Makefile
└── README.md
```

Ожидаемая локальная структура уровнем выше:

```text
mobile_travel_app/
├── tourism-platform/
├── tourism-mobile/
├── tourism-backend/
├── tourism-infrastructure/
└── tourism-documentation/
```

Корневая папка `mobile_travel_app` не является Git repository.

## Legacy reference

Исходная продуктовая идея изучена по
[дипломному Android-проекту](https://github.com/xotabeach/Diploma-project-Mobile-application-for-the-Department-of-Tourism-of-Tatarstan).
Он используется только как источник сценариев и терминологии.

Старые Java-классы, Android UI, ресурсы, изображения, тексты, API-ключи,
структура и технические решения не переносятся. Новая система создаётся с нуля.
Подробности доступны в
[legacy-project-analysis.md](docs/legacy-project-analysis.md).

## Документация

- [Product vision](docs/product-vision.md)
- [System context](docs/system-context.md)
- [Preliminary domain model](docs/domain-model.md)
- [Repository strategy](docs/repository-strategy.md)
- [Local development](docs/local-development.md)
- [Repository profiles](docs/repositories)
- [Domain service profiles](docs/services)

## Дальнейшие шаги

1. Создать приватные remote-репозитории.
2. Клонировать repositories рядом с `tourism-platform`.
3. Сформировать skeleton модульного backend.
4. Сформировать foundation Flutter-приложения.
5. Подготовить инфраструктурный репозиторий и окружение `dev`.
6. Уточнить MVP-контент, источники данных и правила актуализации.
