# Анализ legacy-проекта

## Назначение и метод анализа

Legacy repository
[`xotabeach/Diploma-project-Mobile-application-for-the-Department-of-Tourism-of-Tatarstan`](https://github.com/xotabeach/Diploma-project-Mobile-application-for-the-Department-of-Tourism-of-Tatarstan)
содержит учебный Android-прототип туристического приложения BeTour 2023–2024
годов. Его контент фактически сосредоточен на Казани.

Анализ выполнен статически по ветке `main`: изучены `AndroidManifest.xml`,
navigation graph, Java/Kotlin sources, XML layouts, local SQLite schema и
network DTO. Сборка и запуск приложения не выполнялись. Поэтому наличие
экрана, обработчика или заявления в README не считается доказательством
полностью работающей функции.

Новая Crimea Travel Platform является независимой greenfield-разработкой.
Legacy используется только для понимания исходной идеи, сценариев и
терминологии.

## Подтверждённые пользовательские сценарии

По коду можно подтвердить наличие попыток реализовать следующие сценарии:

1. Splash screen с переходом к login:
   `ui/splash_screen/SplashScreenActivity.java`.
2. Локальная регистрация и login по email и password:
   `ui/login/LoginActivity.java`, `DataBaseHelper.java`.
3. Просмотр карусели мест и категорий при наличии данных в SQLite:
   `ui/home/HomeFragment.java`.
4. Открытие dialog карточки места с описанием и локальным изображением:
   `ui/home/ClickedLocationDialog.java`.
5. Фильтрация мест по выбранной категории:
   `ui/right_bar/RightBarFragment.java`.
6. Добавление места в локальный список выбранных и удаление из него:
   `ui/create_route/Create_routeFragment.java`.
7. Просмотр и редактирование локального профиля, включая имя, фамилию, город
   и avatar URI: `ui/profile/ProfileFragment.java`.
8. Просмотр FAQ accordion: `ui/question/QuestionFragment.java`.
9. Ввод части параметров генерации: диапазон количества мест, категория,
   платность и transport flags: `ui/CreateRouteParamsFragment.java`.
10. Формирование случайной последовательности мест и отображение её как списка
    остановок: `ui/RouteFragment.java`.

Это подтверждает наличие прототипов сценариев, но не production-качество,
сохранность данных между сессиями и корректность результата маршрутизации.

## Найденные screens

- `splash_screen_activity.xml` — splash screen;
- `activity_login.xml` — login и registration;
- `activity_main.xml` — основной container и bottom navigation;
- `fragment_home.xml` — карусели places и categories;
- `clicked_location_dialog.xml` — упрощённая карточка place;
- `fragment_right_bar.xml` — места выбранной category;
- `fragment_create_route.xml` — выбранные места и варианты создания;
- `fragment_create_route_params.xml` — параметры собственного маршрута;
- `fragment_route.xml` — список остановок предполагаемого маршрута;
- `fragment_profile.xml` — profile;
- `fragment_question.xml` — FAQ;
- `custom_clock_widget.xml` — демонстрационный widget без туристической логики.

Отдельного подтверждённого каталога готовых редакционных маршрутов и
полноценной route card в текущем коде не найдено. Некоторые кнопки результата
маршрута присутствуют только в layout и не имеют рабочей логики.

## Найденные entities и storage

`DataBaseHelper.java` создаёт local SQLite tables:

- `landmarks`: title, category, description, address-like location,
  coordinates, paid flag и rating;
- `categories`: name и local image resource;
- `clickedLandmarks`: локально выбранные places;
- `users`: email, name, surname, plaintext password, avatar URI, city и
  route counter.

Java-модели включают:

- `TravelLocation` и `Landmark` — два пересекающихся представления place;
- `TravelCategory` — category;
- `ClickedTravelData` — выбранное место;
- `LoggedInUser` — локальный user;
- `RouteRequest` и `RouteResponse` — минимальные network DTO.

Устойчивого domain layer нет. Модели дублируются, а UI напрямую обращается к
SQLite и сетевому client.

## Неподтверждённые и незавершённые возможности

- README заявляет работу основных компонентов, но одновременно признаёт
  отсутствие готового API создания маршрута. Это намерение автора, а не
  результат независимой проверки.
- На fresh install каталог, вероятно, остаётся пустым: bundled database нет,
  а заполнение списка `TravelLocation` в `MainActivity.java` закомментировано.
- Список выбранных landmarks очищается при старте отдельных screens, поэтому
  устойчивое сохранение между сессиями не подтверждено.
- Карточка случайной генерации и search имеют заглушки.
- `CategoriesFragment` и соответствующий `ViewModel` практически пусты.
- Все FAQ могут показывать одинаковый ответ.
- Registration и login полностью локальные; session restoration, logout,
  backend identity и синхронизация отсутствуют.
- Автоматические tests являются стандартными Android templates и не проверяют
  продуктовые сценарии.

## Состояние routing integration

В `network/OpenRouteServiceAPI.java` объявлен walking endpoint, а
`ui/RouteFragment.java` выполняет Retrofit request. Полноценную интеграцию
считать работающей нельзя:

- API key жёстко записан в source;
- успешный response не обновляет UI;
- geometry не моделируется и map отсутствует;
- DTO ответа содержит только часть duration data;
- порядок координат выглядит сомнительным для provider contract;
- значения времени между stops захардкожены;
- transport и часть pricing flags только логируются;
- commit history и README также указывают на незавершённость API.

Старый key считается скомпрометированным и не должен использоваться.

## Ограничения реализации

- один Android module, преимущественно Java и XML Views;
- Android 10+ без iOS client;
- backend и server-side authorization отсутствуют;
- plaintext passwords хранятся и могут попадать в logs;
- UI, persistence и network logic тесно связаны;
- schema migration практически отсутствует;
- hardcoded content, images, texts, dimensions и city lists;
- отсутствуют CI, meaningful tests, observability и deployment pipeline;
- отсутствует multi-region hierarchy;
- нет нормальных schedules, entrances, temporary closures, seasonality,
  accessibility, safety, equipment, source attribution и freshness;
- provider abstraction отсутствует;
- offline data не имеет формального sync protocol.

## Что переносится концептуально

- сценарий `catalog -> place card -> favorite or route`;
- категории туристических объектов;
- профиль путешественника;
- последовательность route stops;
- форма параметров персонального маршрута;
- различие платных и бесплатных places;
- FAQ и помощь;
- идея подготовки к offline use.

Эти идеи должны быть заново описаны требованиями и независимо реализованы.

## Что не переносится технически

- Java/Kotlin source, XML layouts и package structure;
- SQLite schema, `DataBaseHelper` и local authentication;
- hardcoded routing logic и OpenRouteService key;
- images, fonts, icons, texts и другие Android resources;
- screen dimensions, navigation graph и UI implementation;
- DTO, classes и имена внутренних методов.

В repository отсутствует LICENSE. Без отдельного разрешения правообладателя
копирование source и resources юридически небезопасно.

## Отличия новой платформы

| Legacy prototype | Crimea Travel Platform |
| --- | --- |
| Казань и частично Татарстан | Крым как первый регион, multi-region model |
| Только Android | Flutter для Android и iOS |
| Local SQLite как основное хранилище | Backend API и PostgreSQL/PostGIS |
| Локальная plaintext authentication | Server-side identity и secure tokens |
| UI напрямую управляет data | Domain boundaries и application contracts |
| Один OpenRouteService call | Provider-neutral `RoutingProvider` |
| Нет полноценной геометрии и map | Geometry, distance, duration и map-ready API |
| Hardcoded content | Sources, freshness и editorial lifecycle |
| Нет эксплуатационного контура | Containers, CI и дальнейший Kubernetes path |
| Неясное offline state | Планируемый offline-first sync contract |

## Вывод

Legacy repository полезен как исторический product prototype. Он не является
архитектурной основой, библиотекой или эталоном работоспособности новой
платформы.
