# ADR-002: Отдельные repositories компонентов платформы

- Статус: принято
- Дата: 2026-07-21

## Контекст

Mobile, backend, infrastructure и расширенная документация используют разные
toolchains, release cycles и права доступа. При этом для интеграционной
разработки нужна воспроизводимая комбинация их версий и единая точка входа.

## Решение

Создаются отдельные repositories `tourism-mobile`, `tourism-backend`,
`tourism-infrastructure` и `tourism-documentation`. Главный
`tourism-platform` остаётся управляющим workspace repository без application
source. Локально repositories размещаются как Git submodules общего
superproject:

- `mobile_travel_app/tourism-platform`;
- `mobile_travel_app/tourism-mobile`;
- `mobile_travel_app/tourism-backend`;
- `mobile_travel_app/tourism-infrastructure`;
- `mobile_travel_app/tourism-documentation`.

Отсутствующие repositories будут добавлены специальным script после создания
remotes. До этого placeholder repositories и фиктивные URLs не создаются.

## Последствия

Положительные:

- независимые histories, permissions и release cycles;
- границы между application code и deployment assets;
- repositories имеют независимые histories;
- superproject фиксирует проверенную комбинацию commits;
- изменения API проходят через явный contract.

Отрицательные:

- atomic change между repositories состоит из нескольких pull requests;
- submodule pointers требуют явного обновления;
- onboarding требует `git clone --recurse-submodules`.

## Правила

- Общий source code не копируется между repositories.
- Secrets не хранятся ни в одном repository.
- Submodule script не перезаписывает существующие каталоги и
  завершается с ошибкой при недоступном remote.
- API compatibility проверяется до выпуска зависимых repositories.
