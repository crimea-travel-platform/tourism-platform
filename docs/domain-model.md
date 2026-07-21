# Доменная модель

## Общие правила

- Идентификаторы имеют тип UUID, время хранится в UTC, координаты — в WGS 84.
- Публичные entities используют `status`, `createdAt`, `updatedAt`.
- Редакционные данные содержат `sourceName`, `sourceUrl`, `sourceCheckedAt`,
  `freshnessStatus` и при необходимости `expiresAt`.
- Значения `freshnessStatus`: `fresh`, `review_due`, `stale`, `unknown`.
- Удаление опубликованных данных предпочтительно заменяется архивацией.
- Связи между modules передаются через IDs и application contracts. Прямые
  cross-domain ORM imports запрещены.

## Geography

### Country

Назначение: верхний уровень географии, позволяющий платформе быть multi-country
и multi-region.

Поля:

- `id`, `code` ISO 3166-1 alpha-2, `name`, `slug`;
- `defaultLocale`, `timezone`, `status`;
- `sourceName`, `sourceUrl`, `sourceCheckedAt`, `freshnessStatus`;
- `createdAt`, `updatedAt`.

Связи: `Country` имеет много `Region`.

Module owner: `geography`.

Invariants:

- `code` и `slug` уникальны;
- timezone должна быть валидным IANA identifier;
- нельзя публиковать `Region` для архивной страны.

### Region

Назначение: административный или продуктовый регион внутри страны; первым
регионом является Республика Крым.

Поля:

- `id`, `countryId`, `name`, `slug`, `administrativeCode`;
- `timezone`, `centerPoint`, `boundary`;
- `status`, source и freshness fields, timestamps.

Связи: принадлежит `Country`, имеет много `Locality` и `Place`.

Module owner: `geography`.

Invariants:

- уникальный `slug` в пределах `Country`;
- `centerPoint` должен находиться в `boundary`, если boundary задана;
- опубликованный регион принадлежит опубликованной стране.

### Locality

Назначение: населённый пункт или именованная территория внутри региона.

Поля:

- `id`, `regionId`, опциональный `parentLocalityId`;
- `name`, `slug`, `type`, `postalCode`;
- `centerPoint`, опциональная `boundary`;
- `status`, source и freshness fields, timestamps.

Связи: принадлежит `Region`, может образовывать иерархию и иметь много `Place`.

Module owner: `geography`.

Invariants:

- родительская locality находится в том же регионе;
- циклы в иерархии запрещены;
- `slug` уникален в пределах региона;
- координаты должны попадать в region boundary, если она известна.

## Places

### Category

Назначение: управляемая классификация мест.

Поля:

- `id`, опциональный `parentCategoryId`;
- `code`, `name`, `slug`, `description`, `iconKey`;
- `sortOrder`, `status`, timestamps.

Связи: имеет иерархию и many-to-many связь с `Place`.

Module owner: `places`.

Invariants:

- `code` и `slug` уникальны;
- циклы категорий запрещены;
- архивную категорию нельзя назначить новому месту.

### Place

Назначение: туристический объект, природная локация, музей, сервисная точка или
другая цель посещения.

Поля:

- `id`, `regionId`, опциональный `localityId`;
- `name`, `slug`, `shortDescription`, `description`;
- `location`, `address`, `contactPhone`, `websiteUrl`;
- `accessibility`, `recommendedEquipment`, `seasonality`, `difficulty`;
- `isPaid`, `priceNotes`, `isSuitableForChildren`;
- `safetyWarnings`, `temporaryClosureStatus`, `temporaryClosureReason`;
- `closedFrom`, `closedUntil`, `publicationStatus`;
- source и freshness fields, timestamps.

Связи: принадлежит `Region`, опционально `Locality`, имеет категории,
`PlaceEntrance`, `PlaceSchedule`, `PlaceImage`; используется остановками,
избранным и генератором.

Module owner: `places`.

Invariants:

- locality, если задана, принадлежит тому же region;
- опубликованное место имеет имя, координаты, минимум одну категорию и источник;
- `closedUntil` не раньше `closedFrom`;
- закрытое место не предлагается route builder без явного override;
- safety warnings и equipment не заменяются маркетинговым описанием;
- stale критичные данные помечаются пользователю и могут исключать генерацию.

### PlaceEntrance

Назначение: конкретная точка входа, подъезда или начала посещения, необходимая
для корректной навигации вместо маршрута к геометрическому центру места.

Поля:

- `id`, `placeId`, `name`, `location`, `addressHint`;
- `entranceType`, `isPrimary`, `accessibility`;
- `vehicleRestrictions`, `openingNotes`, `status`;
- source и freshness fields, timestamps.

Связи: принадлежит одному `Place`; может выбираться route stop.

Module owner: `places`.

Invariants:

- у опубликованного place не более одного primary entrance;
- активный entrance имеет координаты;
- ограничения транспорта не должны противоречить accessibility metadata.

### PlaceSchedule

Назначение: регулярные часы работы, сезонные интервалы и исключения.

Поля:

- `id`, `placeId`, опциональный `placeEntranceId`;
- `scheduleType`, `validFrom`, `validUntil`, `timezone`;
- `weekdays`, `opensAt`, `closesAt`, `isClosed`;
- `exceptionDate`, `note`, `status`;
- source и freshness fields, timestamps.

Связи: принадлежит `Place` и опционально конкретному `PlaceEntrance`.

Module owner: `places`.

Invariants:

- интервал validity корректен и timezone совпадает с географией места;
- exception имеет приоритет над регулярным расписанием;
- пересекающиеся правила одинакового приоритета запрещены;
- `isClosed` не содержит часы открытия;
- временное закрытие place имеет приоритет над schedule.

### PlaceImage

Назначение: метаданные лицензированного изображения места.

Поля:

- `id`, `placeId`, `mediaAssetId`, `kind`, `altText`;
- `author`, `license`, `sourceUrl`, `capturedAt`;
- `sortOrder`, `isCover`, `status`, timestamps.

Связи: принадлежит `Place`, ссылается на asset в module `media`.

Module owner: `places`; бинарный asset принадлежит `media`.

Invariants:

- опубликованное изображение имеет `altText`, автора или источник и лицензию;
- у места не более одной cover image;
- нельзя публиковать media с неподтверждёнными правами использования.

## Routes

### PreparedRoute

Назначение: редакционный, заранее проверенный маршрут.

Поля:

- `id`, `regionId`, `name`, `slug`, `description`;
- `estimatedDurationMinutes`, `distanceMeters`, `difficulty`;
- `routeScope`, `transportMode`, `isRoundTrip`, `geometry`;
- `recommendedEquipment`, `seasonality`, `safetyWarnings`;
- `publicationStatus`, source и freshness fields, timestamps.

Связи: принадлежит `Region`, содержит `PreparedRouteStop`.

Module owner: `routes`.

Invariants:

- опубликованный маршрут имеет минимум две активные остановки;
- все остановки относятся к совместимой географии;
- агрегированные safety, equipment и seasonality не скрывают более строгие
  требования остановок;
- stale маршрут отмечается или снимается с генерации.

### PreparedRouteStop

Назначение: упорядоченная остановка редакционного маршрута.

Поля:

- `id`, `preparedRouteId`, `placeId`, опциональный `placeEntranceId`;
- `position`, `plannedArrivalOffsetMinutes`, `visitDurationMinutes`;
- `note`, `isOptional`, timestamps.

Связи: принадлежит `PreparedRoute`, ссылается на `Place` и entrance по ID.

Module owner: `routes`.

Invariants:

- `position` уникальна и непрерывна в маршруте;
- entrance принадлежит выбранному place;
- duration положительна;
- закрытая обязательная остановка блокирует публикацию без редакционного решения.

### GeneratedRoute

Назначение: снимок результата route builder для конкретного запроса.

Поля:

- `id`, опциональный `userId`, `requestId`;
- `regionId`, `status`, `transportMode`, `providerCode`, `providerRequestId`;
- `startedAt`, `finishedAt`, `totalDurationMinutes`, `distanceMeters`;
- `geometry`, `warnings`, `failureCode`;
- `algorithmVersion`, `dataSnapshotAt`, timestamps.

Связи: создаётся из `RouteGenerationRequest`, содержит `GeneratedRouteStop`,
может быть сохранён как `SavedRoute`.

Module owner: `route_builder`.

Invariants:

- успешный маршрут содержит остановки и не содержит `failureCode`;
- результат неизменяем после завершения;
- сохраняются версия алгоритма и время data snapshot;
- пользователь видит provider и предупреждения, влияющие на поездку.

### GeneratedRouteStop

Назначение: вычисленная остановка с расписанием и routing metadata.

Поля:

- `id`, `generatedRouteId`, `placeId`, опциональный `placeEntranceId`;
- `position`, `arrivalAt`, `departureAt`, `visitDurationMinutes`;
- `legDistanceMeters`, `legDurationSeconds`, `legGeometry`;
- `selectionReason`, `warnings`, timestamps.

Связи: принадлежит `GeneratedRoute`, ссылается на place и entrance по ID.

Module owner: `route_builder`.

Invariants:

- позиции уникальны и непрерывны;
- arrival не позже departure;
- выбранный entrance принадлежит place;
- остановка не пересекает подтверждённое закрытие или недоступное расписание;
- route leg после первой остановки имеет duration и distance.

### RouteGenerationRequest

Назначение: нормализованный набор пользовательских условий генерации.

Поля:

- `id`, опциональный `userId`, `regionId`, `localityIds`;
- `origin`, опциональный `destination`, `returnToOrigin`;
- `startsAt`, `minDurationMinutes`, `maxDurationMinutes`;
- `maxDistanceMeters`, `minPlaceCount`, `maxPlaceCount`, `transportMode`;
- `categoryIds`, `requiredPlaceIds`, `excludedPlaceIds`, `priorityPlaceIds`;
- `pricePreference`, `withChildren`, `accessibilityNeeds`;
- `equipmentAvailable`, `difficulty`, `season`, `preferences`;
- `status`, timestamps.

Связи: инициируется пользователем и порождает ноль или несколько попыток
`GeneratedRoute`.

Module owner: `route_builder`.

Invariants:

- minimum values не превышают соответствующие maximum values;
- duration, distance и place count положительны;
- required и excluded sets не пересекаются;
- locality IDs принадлежат выбранному region;
- при `returnToOrigin=true` отдельный destination не задаётся;
- origin и destination валидны для поддерживаемой географии;
- запрос не ослабляет safety restrictions;
- повторная обработка идемпотентна по request ID.

## Identity и users

### User

Назначение: учётная запись и состояние идентификации.

Поля:

- `id`, `emailNormalized`, `passwordHash` или внешний identity reference;
- `status`, `emailVerifiedAt`, `lastLoginAt`;
- `createdAt`, `updatedAt`, `deletedAt`.

Связи: имеет один `UserProfile`, избранное и сохранённые маршруты.

Module owner: `identity`.

Invariants:

- normalized email уникален среди активных accounts;
- plaintext password никогда не сохраняется;
- заблокированный или удалённый user не получает новые sessions;
- identity module не раскрывает credential fields другим modules.

### UserProfile

Назначение: персональные настройки без credential data.

Поля:

- `id`, `userId`, `displayName`, `preferredLocale`;
- `homeRegionId`, `accessibilityNeeds`, `travelPreferences`;
- `createdAt`, `updatedAt`.

Связи: принадлежит `User`, ссылается на home region по ID.

Module owner: `users`.

Invariants:

- у user ровно один профиль;
- locale поддерживается приложением;
- profile не хранит password, tokens или provider credentials.

### FavoritePlace

Назначение: пользовательская закладка на место.

Поля:

- `id`, `userId`, `placeId`, опциональный `note`, `createdAt`.

Связи: связывает `User` и `Place` по IDs.

Module owner: `users`.

Invariants:

- пара `userId + placeId` уникальна;
- ссылка на архивное место сохраняется для истории, но явно помечается;
- доступ к записи имеет только владелец.

### SavedRoute

Назначение: пользовательское сохранение подготовленного или сгенерированного
маршрута с названием и snapshot важных данных.

Поля:

- `id`, `userId`, `routeType`, `routeId`;
- `name`, `snapshot`, `savedAt`, `updatedAt`.

Связи: принадлежит `User`; ссылается либо на `PreparedRoute`, либо на
`GeneratedRoute`.

Module owner: `users`.

Invariants:

- задан ровно один допустимый route reference согласно `routeType`;
- snapshot неизменяем и не содержит credentials;
- изменения исходного маршрута не переписывают пользовательскую историю;
- доступ имеет только владелец.

## Границы modules

- `identity`: credentials, sessions и account lifecycle.
- `users`: profile, favorites и saved routes.
- `geography`: country, region и locality.
- `places`: category, place, entrance, schedule и image metadata.
- `routes`: editorial prepared routes.
- `route_builder`: generation requests, generated routes и provider orchestration.
- `media`: binary assets, storage и transformations.

Каждый module владеет своей persistence model и публикует application API,
domain events или read contracts. Join между modules выполняется по IDs на
application layer, а не через ORM navigation properties.
