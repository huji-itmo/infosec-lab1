// Отчёт по лабораторной работе №1.
// Оформление подключается из общего шаблона ~/dev/report-template.

#import "template-style.typ": report
#import "title-page-template.typ": title-page

#show: report

#title-page(
  subject: "Информационная безопасность",
  work-type: "Лабораторная работа",
  work-number: "1",
  student-name: "Григорьев Давид Владимирович",
  student-group: "Р3415",
  reviewer-name: "Маркина Татьяна Анатольевна",
  city: "Санкт-Петербург",
  year: "2026",
)

#pagebreak()
#outline(title: [Содержание])
#pagebreak()

= Цель работы

Разработать защищённое REST API на Java/Spring Boot, реализовать JWT-аутентификацию,
базовые меры защиты веб-приложения и интегрировать статический анализ кода и анализ
зависимостей в CI/CD pipeline.

= Описание проекта и API

== Стек технологий

- Язык программирования: Java 17.
- Фреймворк: Spring Boot 3.2.5.
- Система сборки: Gradle 8.7 (Kotlin DSL).
- База данных: PostgreSQL 16, запуск через Docker Compose.
- Аутентификация: JWT с HMAC-SHA256 и BCrypt.

== Endpoints

#table(
  columns: (auto, auto, auto, 1fr),
  align: (left, left, center, left),
  table.hline(stroke: 1pt),
  [*Метод*], [*Путь*], [*Аутентификация*], [*Описание*],
  table.hline(stroke: 0.5pt),
  [POST], [/auth/login], [Нет], [Аутентификация и получение JWT],
  [GET], [/api/data], [Bearer], [Получение защищённых данных],
  [GET], [/api/profile], [Bearer], [Получение профиля пользователя],
  [PUT], [/api/profile], [Bearer], [Обновление профиля],
  table.hline(stroke: 1pt),
)

== Примеры запросов

Аутентификация:

```json
POST /auth/login
Content-Type: application/json

{ "username": "admin", "password": "admin123" }

=> 200 OK
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "username": "admin",
  "role": "ADMIN"
}
```

Получение защищённых данных:

```http
GET /api/data
Authorization: Bearer <token>

=> 200 OK
[
  {"id": 1, "title": "Security Report Q1"},
  {"id": 2, "title": "Vulnerability Scan"},
  {"id": 3, "title": "Access Logs"}
]
```

Запрос без токена к `/api/data` возвращает `401 Unauthorized`.

= Реализованные меры защиты

== Защита от SQL-инъекций

Для взаимодействия с базой данных используется Spring Data JPA (Hibernate).
Запрос к репозиторию параметризован, а конкатенация строк для формирования SQL
в проекте не используется.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
}
```

== Защита от XSS

API возвращает данные в формате `application/json`, поэтому значения полей не
интерпретируются браузером как HTML или JavaScript. В Spring Security настроены
CSP-заголовок и `X-Frame-Options: DENY`. Входные данные профиля проверяются через
`@Valid`, `@Email` и `@Size`; HTML-теги в `displayName` запрещены.

Секрет JWT и пароль базы данных в production передаются через переменные окружения.

== Защита аутентификации

Пароли хэшируются с помощью `BCryptPasswordEncoder`. После успешной аутентификации
выдаётся JWT-токен с подписью HMAC-SHA256. Фильтр `JwtAuthFilter` проверяет токен
в заголовке `Authorization` и устанавливает контекст безопасности для защищённых
endpoint'ов. Сессии приложения работают в stateless-режиме.

= Ход работы и тестирование

== Реализация API

Реализованы контроллеры аутентификации, данных и профиля, DTO для запросов и
ответов, JPA-модель пользователя, репозиторий и глобальный обработчик ошибок.
Начальные пользователи создаются при запуске приложения.

== Автоматические тесты

Команда `./gradlew test` запускает интеграционные тесты на встроенной H2-базе.
Тестами проверяются успешный вход с выдачей JWT, отказ в доступе к `/api/data`
без токена, отказ с неверным паролем и отклонение HTML-ввода в профиле.

= SAST, SCA и CI/CD

== SAST: SpotBugs

Статический анализ исходного кода выполняется задачей `spotbugsMain`. Критических
предупреждений не выявлено; исправлены замечания анализа байт-кода и уточнена
структура сервиса JWT.

== SCA: OWASP Dependency-Check

Анализ зависимостей выполняется задачей `dependencyCheckAnalyze`. Сборка настроена
на контроль критичных уязвимостей с порогом CVSS 7.0.

== Pipeline

В `.github/workflows/ci.yml` на каждый push и pull request запускаются сборка,
SpotBugs, Dependency-Check и тесты. Отчёты SAST и SCA сохраняются как артефакты
GitHub Actions.

#figure(
  image("img.png", width: 100%),
  caption: [Результат выполнения CI/CD pipeline в GitHub Actions.],
)



= Выводы

Разработано защищённое REST API на Java/Spring Boot с JWT-аутентификацией,
хэшированием паролей BCrypt, защитой от SQL-инъекций и XSS. Реализованы
автоматические тесты и CI/CD pipeline с SAST- и SCA-проверками.

Репозиторий: `https://github.com/username/infosec-lab1`.
