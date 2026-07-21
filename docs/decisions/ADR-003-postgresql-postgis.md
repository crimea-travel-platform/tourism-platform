# ADR-003: PostgreSQL и PostGIS

- Статус: принято
- Дата: 2026-07-21

## Контекст

Платформа хранит административные границы, точки мест и входов, route geometry
и выполняет географические запросы. Рассматривалась MariaDB, но пространственные
возможности, ecosystem и доступные spatial operators должны быть основой
модели, а не дополнительным ограниченным слоем.

## Решение

Основной database — PostgreSQL с расширением PostGIS. Геометрия хранится с
явным SRID; публичные координаты используют WGS 84 (`EPSG:4326`). Для distance
и containment queries применяются подходящие типы `geography` или `geometry`,
spatial indexes и проверяемые migrations.

MariaDB не используется.

## Последствия

Положительные:

- зрелые spatial types, indexes и operators;
- корректные proximity, containment и boundary queries;
- возможность хранить точки, полигоны и route geometry единообразно;
- сильная transactional model и развитый tooling.

Отрицательные:

- разработчикам нужны знания PostgreSQL и PostGIS;
- неправильный SRID или выбор типа приводит к ошибкам расстояния;
- local и test environments должны устанавливать совместимое расширение.

## Правила реализации

- Migrations включают создание PostGIS и spatial indexes.
- SRID не определяется неявно.
- Географические расчёты покрываются integration tests на реальном PostgreSQL.
- ORM abstractions не должны скрывать дорогие spatial queries.
- Backup и restore обязаны учитывать extension и schema migrations.
