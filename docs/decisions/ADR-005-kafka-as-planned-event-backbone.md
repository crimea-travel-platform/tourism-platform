# ADR-005: Kafka как планируемый event backbone

- Статус: proposed
- Дата: 2026-07-21

## Контекст

Целевая архитектура допускает выделение modules `identity`, `users`,
`geography`, `places`, `routes`, `route_builder` и `media` в independently
deployable services. Часть будущих сценариев не требует немедленного ответа:

- распространение изменений places и prepared routes;
- уведомления об изменениях или временных закрытиях;
- обработка media;
- публикация результата длительной route generation;
- независимые audit, analytics и search projections.

Synchronous HTTP остаётся правильным выбором для login, чтения каталога,
валидации commands и операций, результат которых пользователь ожидает в том же
request. Broker не должен заменять ясный request/response contract.

На foundation-этапе существует один modular monolith и нет подтверждённого
producer/consumer flow. Немедленный запуск Kafka увеличит стоимость local
development, CI, deployment, security и observability без продуктовой пользы.

## Решение

Apache Kafka принимается как планируемый, но условный event backbone целевой
distributed architecture. Решение остаётся `proposed`, пока не выполнены
критерии активации.

Kafka не добавляется в текущий `compose.yaml`, Kubernetes manifests или Helm
charts. До появления broker domain events могут обрабатываться in-process через
application contracts. Их payload не должен зависеть от transport-specific
Kafka types.

## Критерии активации

Kafka внедряется отдельным ADR, если одновременно подтверждены:

1. Существует минимум один independently deployable producer.
2. Существует реальный asynchronous business flow, а не только техническое
   желание связать services.
3. Событие требуется двум или более независимым consumers либо необходим
   replay для восстановления projection.
4. Eventual consistency приемлема и описана пользователю или оператору.
5. Команда готова эксплуатировать broker, schema compatibility, consumer lag,
   retries, dead-letter handling и security controls.

Дополнительными основаниями могут быть измеримые требования к ordering,
throughput, retention или независимому масштабированию consumers.

## Обязательные правила реализации

### Publication

- Business transaction и запись события связываются через Transactional
  Outbox в database владельца aggregate.
- Отдельный relay публикует outbox record в Kafka и безопасно повторяет
  transient failures.
- Dual write в database и Kafka без outbox запрещён.
- Event содержит `eventId`, `eventType`, `eventVersion`, `occurredAt`,
  `producer`, `correlationId`, `causationId` и payload.

### Delivery semantics

- Базовая гарантия — at-least-once delivery.
- Consumers обязаны быть idempotent и хранить обработанные `eventId` либо
  использовать эквивалентную deduplication strategy.
- Exactly-once marketing claims не используются как замена idempotency.
- Aggregate ID применяется как partition key, когда необходим порядок событий
  одного aggregate.
- Глобальный порядок событий не предполагается.

### Contracts

- Event names описывают свершившийся факт: `PlaceTemporarilyClosed`, а не
  command `ClosePlace`.
- Schema имеет явную version и backward compatibility policy.
- Выбор JSON Schema, Avro или Protobuf выполняется отдельным решением после
  первого реального consumer.
- Consumer не зависит от internal ORM model producer.
- Breaking schema change публикуется как новая event version или новый topic.

### Failures

- Retry выполняется с ограничением числа попыток и backoff.
- Non-retryable events направляются в dead-letter flow с причиной ошибки.
- Replay является управляемой операцией с audit trail и rate limits.
- Poison message не должен бесконечно блокировать partition.

### Security и privacy

- Kafka traffic использует encryption in transit и authenticated clients.
- ACL выдаются отдельно producer и consumer principals.
- Event payload содержит минимум персональных данных.
- Passwords, tokens, точные пользовательские координаты и provider secrets в
  событиях запрещены.
- Retention согласуется с data classification и правом на удаление.

### Observability

- Обязательны metrics broker health, publish failures, consumer lag, retry и
  dead-letter volume.
- Logs и traces связываются через correlation ID без использования PII как
  labels.
- Alerting создаётся до подключения production consumer.

## Topic strategy

Topic naming, partition count, replication factor и retention задаются
infrastructure configuration, а не hardcoded application values. Предварительный
формат имени:

```text
<environment>.<domain>.<event-family>.v<major>
```

Например:

```text
staging.places.lifecycle.v1
```

Topic не является database table. Kafka хранит integration events и может
обеспечивать replay, но authoritative state остаётся в database domain owner.

## Deployment direction

При активации используется Kafka в KRaft mode без ZooKeeper. Конкретный
managed provider, Kubernetes operator или Helm chart сейчас не выбирается.
Infrastructure design должен учитывать multi-zone availability, storage,
backup of configuration, upgrades, quotas и cost.

## Рассмотренные альтернативы

### Только synchronous HTTP

Подходит текущему modular monolith и простым queries, но создаёт temporal
coupling при fan-out и не предоставляет replay.

### RabbitMQ

Сильный кандидат для task queues и сложной message routing. Может оказаться
проще Kafka при отсутствии требований к retention и replay.

### NATS JetStream

Имеет простой operational footprint и подходит low-latency messaging, но выбор
требует проверки ecosystem, retention и команды эксплуатации.

### Redis Streams

Удобен для раннего prototype при уже существующем Redis, но не должен
автоматически становиться долговременным event backbone.

Альтернативы повторно оцениваются в activation ADR по фактической нагрузке и
use cases. Этот ADR не запрещает выбрать другой broker, если Kafka не пройдёт
проверку критериев.

## Последствия

Положительные:

- event-driven boundaries проектируются заранее без преждевременного runtime;
- producer и consumers не связываются ORM-моделями;
- определены reliability и security expectations;
- Kafka можно внедрить по измеримой необходимости.

Отрицательные:

- часть contracts придётся поддерживать до появления transport;
- eventual consistency усложнит UX и debugging после активации;
- Kafka потребует отдельной эксплуатационной компетенции и ресурсов.
