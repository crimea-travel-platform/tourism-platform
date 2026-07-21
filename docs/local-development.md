# Локальная разработка

## Область применения

Локальный контур предназначен для разработки и интеграционных проверок на
macOS. Он не является production environment и не задаёт production topology,
security hardening, backup или scaling policy.

## Предварительные требования

- macOS или Linux;
- Git и Make;
- Docker Desktop с Compose v2;
- GitHub CLI для будущего подключения private submodules;
- PowerShell 7 только для запуска `.ps1` scripts.

## Base services

`compose.yaml` поднимает только локальные infrastructure dependencies:

- `postgres` — PostgreSQL database `tourism` с доступным PostGIS;
- `redis` — cache и краткоживущее состояние;
- `minio` — S3-compatible local storage;
- `minio-init` — one-shot создание bucket `tourism-media`;
- `mailpit` — SMTP catcher и web UI.

Сервисы используют healthchecks, named volumes и отдельную bridge network.
Backend и Flutter в этот Compose не входят: они будут находиться в отдельных
repositories.

## Environment

Команда `make init` проверяет Docker Compose и копирует `.env.example` в `.env`
только при отсутствии `.env`. Существующий файл не перезаписывается.

Файл `.env.example` содержит image tags, local ports, имя database, имя MinIO
bucket и безопасные только для developer machine credentials. `.env` исключён
из Git. Эти значения нельзя использовать в staging или production.

Foundation не требует credentials внешнего routing provider.

## Make commands

```text
make help
make init
make up
make down
make restart
make ps
make logs
make validate
make clone-repositories
make clean CONFIRM=yes
```

Команды должны быть повторяемыми, завершаться с ненулевым code при ошибке и не
зависеть от production credentials.

`make clean` удаляет named volumes и локальные данные. Без точного
`CONFIRM=yes` команда обязана завершиться с ошибкой до вызова Docker.

## Первый запуск

1. Выполнить `make init`.
2. При необходимости изменить только local ports в `.env`.
3. Выполнить `make up`.
4. Проверить состояние через `make ps`.
5. Открыть MinIO Console на `http://localhost:9001`.
6. Открыть Mailpit на `http://localhost:8025`.
7. Выполнить `make validate` перед pull request.

## Future submodules

После создания private remote repositories команда `make clone-repositories`
проверит `git`, `gh`, authorization и доступность всех remotes, затем добавит
их в `workspace/` как Git submodules. Сейчас эту команду запускать не следует:
remotes ещё не созданы. Скрипт не перезаписывает существующие каталоги.

## Ограничения

- Demo data не должны содержать реальные персональные данные.
- Local object storage и database считаются расходными.
- Compose credentials допустимы только для local environment.
- `minio-init` является one-shot container и после успешного создания bucket
  завершается с code `0`.
- Production deployment, certificates, secret management и backups описываются
  отдельно в infrastructure repository.
