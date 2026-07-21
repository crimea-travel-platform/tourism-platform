# Системный контекст

Crimea Travel Platform состоит из mobile application, backend API и
инфраструктурных сервисов. На первом этапе backend реализуется как modular
monolith. Внешние поставщики маршрутизации скрыты за `RoutingProvider`.

```mermaid
flowchart LR
    Traveler["Путешественник"]
    Editor["Контент-редактор (future Admin Application)"]
    Platform["Crimea Travel Platform"]
    Routing["Routing Provider"]
    Sources["Внешние источники данных"]

    Traveler -->|Ищет места и планирует поездки| Platform
    Editor -->|Проверяет туристические данные| Platform
    Platform -->|Distance duration geometry| Routing
    Platform -->|Импорт или ручная сверка| Sources
```

## Границы ответственности

Платформа отвечает за:

- учётные записи и пользовательские данные;
- административную географию и каталог мест;
- подготовленные и сгенерированные маршруты;
- происхождение, freshness и публикационный статус контента;
- orchestration построения маршрута и нормализацию ответа provider.

Платформа не гарантирует безошибочность сторонней маршрутизации, не заменяет
официальные предупреждения экстренных служб и не является государственным
источником информации.
