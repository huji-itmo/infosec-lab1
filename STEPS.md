# Лабораторная работа 1: Разработка защищенного REST API с интеграцией в CI/CD

## Шаг 1: Инициализация проекта

**Стек:** Java 17 + Spring Boot 3.2.5 + Gradle 8.7 (Kotlin DSL) + PostgreSQL 16

**Созданы файлы:**
- `settings.gradle.kts` — имя проекта `infosec-lab1`
- `build.gradle.kts` — зависимости: Spring Web, Data JPA, Security, Validation, JJWT 0.12.5, PostgreSQL
- Подключены плагины: Spring Boot, Dependency Management, OWASP Dependency-Check (SCA), SpotBugs (SAST)

**Команда сборки:**
```bash
./gradlew build
```

---

## Шаг 2: Docker-окружение для PostgreSQL

**Файл:** `docker-compose.yml`
- PostgreSQL 16 Alpine
- База: `infosec_lab1`, пользователь: `appuser`, пароль: `appsecret123`
- Порт: `5432`
- Healthcheck на `pg_isready`

**Запуск:**
```bash
docker compose up -d
```

---

## Шаг 3: Модель данных и DTO

**Созданы классы:**
- `User` (JPA-сущность) — id, username, passwordHash, displayName, email, role
- `Role` — enum { USER, ADMIN }
- `UserRepository` — JPA-репозиторий с методами `findByUsername()` и `existsByUsername()`
- `LoginRequest`, `LoginResponse`, `DataItem`, `UpdateProfileRequest`, `ErrorResponse` — DTO

**Защита от SQLi:** Используется Spring Data JPA (Hibernate) с параметризованными запросами. Конкатенация строк для SQL отсутствует.

---

## Шаг 4: Сервисы и безопасность

### JwtService
- Генерация JWT-токенов (алгоритм HMAC-SHA256)
- Извлечение username и role из токена
- Валидация подписи и срока действия

### AuthService
- Аутентификация по username/password
- Пароли хэшируются через **BCrypt** (Spring Security `BCryptPasswordEncoder`)
- При успехе возвращается JWT-токен

### JwtAuthFilter (middleware)
- Перехватывает HTTP-запросы
- Извлекает JWT из заголовка `Authorization: Bearer <token>`
- Устанавливает `SecurityContext` для аутентифицированных запросов

---

## Шаг 5: Security-конфигурация

**Файл:** `SecurityConfig.java`

Настройки:
- **Stateless-сессии** (JWT, не куки)
- **BCryptPasswordEncoder** для хэширования паролей
- **CORS** — разрешены только `http://localhost:3000` и `http://localhost:8080`
- **Заголовки безопасности:**
  - `X-XSS-Protection: 1; mode=block`
  - `Content-Security-Policy: default-src 'self'; script-src 'none'`
  - `X-Frame-Options: DENY`
- **Доступ:**
  - `POST /auth/login` — разрешён всем
  - `GET /api/data`, `GET /api/profile`, `PUT /api/profile` — только аутентифицированным

**Защита от XSS:**
- API возвращает данные в контексте `application/json`, который браузер не исполняет как HTML
- Добавлены CSP-заголовки и `X-Frame-Options: DENY`
- Валидация входных данных через `@Valid`, `@Email`, `@Size`; HTML-теги в displayName запрещены

---

## Шаг 6: Контроллеры (3 эндпоинта)

### 1. `POST /auth/login` — Аутентификация
**Тело запроса:**
```json
{ "username": "admin", "password": "admin123" }
```
**Ответ:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "username": "admin",
  "displayName": "Administrator",
  "role": "ADMIN"
}
```

### 2. `GET /api/data` — Защищённые данные
Требует заголовок `Authorization: Bearer <token>`.
Возвращает список защищённых документов.

### 3. `PUT /api/profile` — Обновление профиля (3-й эндпоинт)
Требует `Authorization: Bearer <token>`.
Позволяет изменить `displayName` и `email`.
**Тело:**
```json
{ "displayName": "New Name", "email": "new@email.com" }
```

### Дополнительно: `GET /api/profile` — Получение профиля

---

## Шаг 7: CI/CD Pipeline (GitHub Actions)

**Файл:** `.github/workflows/ci.yml`

Pipeline запускается на `push` и `pull_request` в `main/master`.

**Этапы:**
1. Checkout кода
2. JDK 17 (Temurin)
3. Build проекта (`./gradlew build -x test`)
4. **SAST:** SpotBugs (`./gradlew spotbugsMain`)
5. **SCA:** OWASP Dependency-Check (`./gradlew dependencyCheckAnalyze`)
6. Тесты
7. Артефакты: отчёты Dependency-Check и SpotBugs

**Инфраструктура:** PostgreSQL 16 запускается как `service` в CI.

---

## Шаг 8: Тестирование API

### Запуск окружения
```bash
# Терминал 1: Postgres
docker compose up -d

# Терминал 2: Приложение
./gradlew bootRun
```

### curl-тесты

**1. Аутентификация:**
```bash
curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

**2. Получение данных (с токеном):**
```bash
TOKEN="<token_from_login>"
curl -s http://localhost:8080/api/data \
  -H "Authorization: Bearer $TOKEN"
```

**3. Без токена (должно вернуть 401):**
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/api/data
```

**4. Обновление профиля:**
```bash
curl -s -X PUT http://localhost:8080/api/profile \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"displayName":"Admin User","email":"admin@example.com"}'
```

---

## Реализованные меры защиты

| Угроза | Защита |
|--------|--------|
| SQL-инъекции (SQLi) | JPA/Hibernate — параметризованные запросы, конкатенация SQL отсутствует |
| Межсайтовый скриптинг (XSS) | JSON-контекст, CSP-заголовки, запрет HTML-тегов во вводе профиля |
| Broken Authentication | JWT + BCrypt для хэширования паролей, middleware-проверка токенов |
| Доступ без аутентификации | Spring Security — все `/api/**` требуют JWT |
| Глобальная обработка ошибок | `@RestControllerAdvice` — единый формат ошибок |

## Начальные пользователи (seed)

| Логин | Пароль | Роль |
|-------|--------|------|
| admin | admin123 | ADMIN |
| user1 | password1 | USER |
