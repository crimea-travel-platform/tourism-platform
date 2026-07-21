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
source. Локально repositories размещаются как independent sibling directories
в общей non-Git папке:

- `mobile_travel_app/tourism-platform`;
- `mobile_travel_app/tourism-mobile`;
- `mobile_travel_app/tourism-backend`;
- `mobile_travel_app/tourism-infrastructure`;
- `mobile_travel_app/tourism-documentation`.

Remote repositories пока не существуют. Sibling repositories будут
клонированы специальным script после создания remotes. До этого placeholder
repositories и фиктивные URLs не создаются.

## Последствия

Положительные:

- независимые histories, permissions и release cycles;
- границы между application code и deployment assets;
- repositories имеют полностью независимые histories и working trees;
- изменения API проходят через явный contract.

Отрицательные:

- atomic change между repositories состоит из нескольких pull requests;
- совместимые версии нужно фиксировать contracts и release metadata;
- локальный workspace не имеет собственной Git history.

## Правила

- Общий source code не копируется между repositories.
- Secrets не хранятся ни в одном repository.
- Clone script не перезаписывает существующие каталоги и
  завершается с ошибкой при недоступном remote.
- API compatibility проверяется до выпуска зависимых repositories.
