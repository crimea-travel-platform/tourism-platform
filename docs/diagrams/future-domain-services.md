# Карта возможных domain services

Диаграмма показывает возможное будущее выделение services, а не текущую
deployment topology. На первом этапе все области находятся в modular monolith.

```mermaid
flowchart LR
    Mobile[Mobile application]
    EntryPoint["Ingress / API entry point"]

    Identity[Identity service]
    Users[Users service]
    Geography[Geography service]
    Places[Places service]
    Routes[Routes service]
    Builder[Route Builder service]
    Media[Media service]
    Notifications["Notifications service (future)"]
    Kafka["Kafka event backbone (conditional)"]
    Provider[External Routing Provider]

    Mobile --> EntryPoint
    EntryPoint --> Identity
    EntryPoint --> Users
    EntryPoint --> Geography
    EntryPoint --> Places
    EntryPoint --> Routes
    EntryPoint --> Builder
    EntryPoint --> Media

    Users --> Identity
    Users --> Places
    Users --> Routes
    Geography --> Places
    Places --> Media
    Routes --> Places
    Builder --> Geography
    Builder --> Places
    Builder --> Routes
    Builder --> Provider

    Identity -.->|integration events| Kafka
    Users -.->|integration events| Kafka
    Places -.->|integration events| Kafka
    Routes -.->|integration events| Kafka
    Builder -.->|integration events| Kafka
    Media -.->|integration events| Kafka
    Kafka -.->|event subscriptions| Notifications
```

Стрелки обозначают logical contracts. Они не разрешают совместное владение
tables или cross-service ORM relations. Выделение любого service требует
измеримой эксплуатационной причины согласно ADR-001.

`Ingress / API entry point` не является отдельным domain service или
обязательным API gateway. На первом этапе запросы направляются в единый backend.

Пунктирные связи обозначают возможный asynchronous flow после выполнения
критериев ADR-005. Kafka не заменяет synchronous APIs и отсутствует в текущей
deployment topology.
