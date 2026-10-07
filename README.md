# Secure REST API — Lab 1

Защищённое REST API на Java/Spring Boot с интеграцией статического анализа (SAST) и анализа зависимостей (SCA) в CI/CD.

## Стек

- **Язык:** Java 17
- **Фреймворк:** Spring Boot 3.2.5
- **Сборка:** Gradle 8.7 (Kotlin DSL)
- **БД:** PostgreSQL 16 (через Docker)
- **Аутентификация:** JWT + BCrypt

## API Endpoints

| Метод | Путь | Аутентификация | Описание |
|-------|------|----------------|----------|
| POST | `/auth/login` | Нет | Вход, получение JWT |
| GET | `/api/data` | Bearer Token | Защищённые данные |
| GET | `/api/profile` | Bearer Token | Профиль пользователя |
| PUT | `/api/profile` | Bearer Token | Обновление профиля |

## Меры защиты

- **SQLi:** JPA/Hibernate (параметризованные запросы)
- **XSS:** JSON API с `application/json`, CSP-заголовки, запрет HTML-тегов во вводе профиля
- **Passwords:** BCrypt (Spring Security)
- **JWT:** HMAC-SHA256, middleware-фильтр, stateless-сессии
- **CORS:** Разрешены только локальные origins `localhost:3000` и `localhost:8080`

Пароли и JWT-секрет передаются через переменные окружения в production:
`SPRING_DATASOURCE_PASSWORD` и `APP_JWT_SECRET`. Значения по умолчанию предназначены только для локального запуска лабораторной работы.

## Проверка

```bash
./gradlew test
```

Автотесты проверяют выдачу JWT, отказ без токена, отказ с неверным паролем и отклонение HTML-ввода в профиле.

## Быстрый старт

```bash
# 1. Запустить PostgreSQL
docker compose up -d

# 2. Собрать и запустить
./gradlew bootRun

# 3. Получить токен
curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# 4. Использовать API
TOKEN="<token>"
curl -s http://localhost:8080/api/data \
  -H "Authorization: Bearer $TOKEN"
```

## CI/CD

В `.github/workflows/ci.yml`:
- **SAST:** SpotBugs
- **SCA:** OWASP Dependency-Check
- Автоматический запуск на push и pull request

## Отчёты SAST/SCA

После CI-прогона отчёты доступны как артефакты Actions:
- `dependency-check-report.html`
- `spotbugs-report/`
