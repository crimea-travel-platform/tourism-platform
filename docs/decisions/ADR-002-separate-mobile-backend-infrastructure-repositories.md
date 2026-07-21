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
source. Дочерние repositories будут подключены как Git submodules в:

- `workspace/tourism-mobile`;
- `workspace/tourism-backend`;
- `workspace/tourism-infrastructure`;
- `workspace/tourism-documentation`.

Remote repositories пока не существуют. Submodules будут добавлены позже
специальным script после создания remotes. До этого placeholder repositories и
фиктивные URLs не создаются.

## Последствия

Положительные:

- независимые histories, permissions и release cycles;
- границы между application code и deployment assets;
- workspace фиксирует проверенную комбинацию commits;
- изменения API проходят через явный contract.

Отрицательные:

- обновление submodule pointers требует дисциплины;
- atomic change между repositories состоит из нескольких pull requests;
- onboarding требует корректной инициализации submodules.

## Правила

- Общий source code не копируется между repositories.
- Secrets не хранятся ни в управляющем repository, ни в submodules.
- Скрипт подключения submodules не перезаписывает существующие каталоги и
  завершается с ошибкой при недоступном remote.
- API compatibility проверяется до обновления workspace pointers.
