[TOC]

# PostgREST Messenger

Проект содержит пример реализации мессенджера, построенного на системе СУБД **Postgres** + HTTP-сервер **PostgREST**. Также включает пример реализации простого клиента на языке программирования Python (оконный PyQt5).

Используются версии **Postgres** (v18.6 от 13 августа 2026) и **PostgREST** (v16.5 от 20 октября 2026).

## Структура БД

В модели данных предполагается, что каждое сообщение имеет атрибут "текст" даже если текст отсутствует.

Рассматривается псевдонимный вариант чата. БД не хранит личную информацию пользователей такую как: номер телефона, адрес почтового ящика, дату рождения и т.д.

### ERD

```mermaid
erDiagram
    %% таблица пользователей, пароль хранится как bcrypt-хэш
    users {
        serial user_id PK
        text username UK
        text password "bcrypt-хэш"
    }

    %% таблица контактов, то как пользователи называют
    %% друг друга, кто с кем знаком и т.д.
    contacts {
        serial user_1 PK, FK
        serial user_2 PK, FK
        varchar(255) nickname
    }

    %% таблица чатов и их типы
    chats {
        serial chat_id PK
        varchar(255) title
        chat_type_enum chat_type "Private, Group, Channel"
    }

    participants {
        serial chat_id PK, FK
        serial user_id PK, FK
    }

    roles {
        serial chat_id PK, FK
        serial user_id PK, FK
        role_type_enum role_type "Owner, Administrator, Participant"
    }

    messages {
        serial message_id PK
        serial chat_id FK
        timestamp created_at
        timestamp modified_at "выставляется триггером"
        text message_text
    }

    voices {
        serial voice_id PK
        serial message_id FK
        text media_url
        varchar(255) waveform "csv значения, формируется триггером"
    }

    images {
        serial image_id PK
        serial message_id FK
        text media_url
        text thumbnail "base64 картинка для предпросмотра"
    }

    files {
        serial file_id PK
        serial message_id FK
        text media_url
    }

    users ||--o{ contacts : "user_1"
    users ||--o{ contacts : "user_2"
    users ||--o{ participants : "user_id"
    chats ||--o{ participants : "chat_id"
    users ||--o{ roles : "user_id"
    chats ||--o{ roles : "chat_id"
    chats ||--o{ messages : "chat_id"
    messages ||--o{ voices : "message_id"
    messages ||--o{ images : "message_id"
    messages ||--o{ files : "message_id"
```

### Таблицы

`Users` таблица пользователей. Может хранить имя пользователя, возможно аватар и др. данные.

`Chats` таблица чатов.

`Participants` хранит участников чатов.

`Messages` таблица сообщений. У сообщения всегда есть текст даже если он пустой. Предполагается, что сообщений, где отсутствует текст (например, голосовое или только картинка) будет сильно меньше, чем с текстом.

`Voices` таблица голосовых сообщений. Может содержать вейвформы, длительность и пр.

`Images` таблица изображений. Может содержать картинки с предпросмотром, чтобы не скачивать, например, тяжёлые изображения.

`Files` таблица прикреплённых файлов.

Таблицы `Voices`, `Images` и `Files` хранятся как отдельные таблицы, потому что содержат дополнительные атрибуты. Например, `Voices` могут хранить вейвформу и длительность, `Images` изображения с предпросмотром, а файлы только размер.

`Contacts` todo...

`Roles` роли пользователей в чатах (`Owner`, `Administrator`, `Participant`). Сейчас используется только `Owner`: функция `rpc/create_chat` назначает создателя чата владельцем.

## Настройка окружения (Windows)

Перед началом работы необходимо установить Postgres (запускается как служба Windows) и PostgREST.

### Установка и запуск Postgres

1. Загрузить установочный пакет с официального сайта [Postgres](https://www.postgresql.org/download/) (v18.6 от 13 августа 2026);
2. установить.

### Установка и запуск PostgREST

1. Загрузить исполняемый файл с официального репозитория Github [PostgREST](https://github.com/PostgREST/postgrest/releases/tag/v16.5) (v16.5 от 20 октября 2026);
2. распаковать и прописать путь в системной переменной `Path` для текущего пользователя или системы;
3. если возникает ошибка отсутствия библиотеки `libpq.dll`, необходимо прописать путь к этой библиотеке в системную переменную `Path` (по умолчанию `C:\Program Files\PostgreSQL\18\bin`);
4. (необязательно) полный конфигурационный файл со всеми параметрами можно сгенерировать командой `postgrest -e > postgrest_default.conf` (в проекте уже есть в `server\postgrest_default.conf`); для запуска используется сокращённый `server\postgrest.conf`;

## Запуск

Запуск всей системы от и до заключается в (1) создании и настройке БД на стороне Postgres, (2) запуске HTTP-сервера PostgREST и (3) запуске клиентского приложения.

### Настройка БД

1. Создать БД с именем Messenger `createdb -h localhost -U postgres -E UTF8 -T template0 Messenger`.

   Указывать флаги `-E UTF8 -T template0` необходимо, чтобы БД была в формате UTF8 независимо от локали Windows, а также была поддержка иероглифов, эмодзи и пр. символов;

2. последовательно запустить скрипты для создания схемы:

   ```cmd
   psql -h localhost -U postgres -d Messenger -f .\server\sql\02_create_schema.sql
   psql -h localhost -U postgres -d Messenger -f .\server\sql\03_create_indices.sql
   psql -h localhost -U postgres -d Messenger -f .\server\sql\04_create_triggers.sql
   psql -h localhost -U postgres -d Messenger -f .\server\sql\05_create_views.sql
   psql -h localhost -U postgres -d Messenger -f .\server\sql\06_create_roles.sql
   ```

Запуск последнего скрипта `06_create_roles.sql` особенно важен, т.к. без настройки ролей PostgREST не сможет связаться с БД. Скрипт создаёт роли `authenticator`, `web_anon` и `web_user` (см. [Роли и права](#роли-и-права)), выдаёт им права и задаёт ключ подписи JWT-токенов в настройке БД `app.jwt_secret`. Пароль роли `authenticator` используется в `server\postgrest.conf` в ключе `db-uri`, роль `web_anon` указана в ключе `db-anon-role`. Скрипт можно запускать повторно, после этого PostgREST нужно перезапустить.

`01_drop_schema.sql` можно использовать для быстрого сброса схемы или для повторного развёртывания. **Внимание! Этот скрипт уничтожает все данные относящиеся к БД Messenger.**

### Запуск PostgREST

1. Запустить PostgREST, указав файл конфигурации `postgrest .\server\postgrest.conf`.

Этой командой PostgREST запустит HTTP-сервер. Если запуск прошёл успешно, в консоли можно наблюдать следующие строки:

```text
24/Oct/2026:04:47:59 +0300: Starting PostgREST 16.5...
24/Oct/2026:04:47:59 +0300: Successfully connected to PostgreSQL 18.6 on x86_64-windows, compiled by msvc-19.44.35229, 64-bit
24/Oct/2026:04:47:59 +0300: Config reloaded
24/Oct/2026:04:47:59 +0300: API server listening on 0.0.0.0:3000
```

Сообщение `Cannot decode byte '\xc2'` при запуске PostgREST означает, что Postgres отклонил подключение (неверный пароль в `db-uri` или не создана роль `authenticator`).

### Запуск клиентского приложения (Python)

1. Установить необходимые зависимости:

```cmd
pip install PyQt5
pip install requests
```

2. запустить приложение `python .\client_py\main.py`

### Регистрация и вход

Анонимный пользователь (роль `web_anon`) может только зарегистрироваться (`rpc/register`) и войти (`rpc/login`). Функция `LOGIN` проверяет пароль и возвращает JWT-токен с ролью `web_user`, идентификатором и именем пользователя, токен действует сутки. Клиент передаёт токен в заголовке `Authorization: Bearer <токен>`, PostgREST проверяет подпись и выполняет запрос от роли `web_user`, которой доступны чаты и сообщения.

После входа клиент ищет канал `Test channel` и пишет в него, если канала ещё нет, клиент создаёт его функцией `rpc/create_chat`. Функция создаёт чат, добавляет участников и назначает создателя (`user_id` из токена) владельцем (`Owner`).

## Роли и права

PostgREST подключается к БД под ролью `authenticator` и для каждого запроса переключается (`SET ROLE`) на роль из JWT-токена, а для запросов без токена на роль `web_anon`. Права ролей задаёт скрипт `06_create_roles.sql`.

| Роль | Назначение | Права |
|---|---|---|
| `authenticator` | подключение PostgREST к БД (`LOGIN`, `NOINHERIT`) | собственных прав на данные нет, может только переключаться на `web_anon` и `web_user` |
| `web_anon` | анонимный пользователь, запрос без токена | чтение `users_public`, вызов `rpc/register` и `rpc/login` |
| `web_user` | пользователь вошедший через `rpc/login` | чтение `users_public` и `chats`, чтение и отправка сообщений через `messages_public`, вызов `rpc/create_chat` |

Таблицы напрямую ролям `web_anon` и `web_user` недоступны (кроме чтения `chats`), работа с данными идёт через представления (`*_public`) и функции. Функции `register`, `login` и `create_chat` объявлены как `SECURITY DEFINER` и выполняются с правами владельца, поэтому могут, например, записать пользователя в таблицу `users`, к которой у вызывающей роли доступа нет. Право вызова всех остальных функций схемы, включая функции расширения `pgcrypto`, отозвано, иначе PostgREST открыл бы их как `rpc/...`.

## API

PostgREST автоматически создаёт HTTP API по объектам схемы `public`: представления и таблицы доступны по адресу `/<имя>`, функции по адресу `/rpc/<имя>`. Ниже запросы которые использует клиент (сервер по умолчанию `http://localhost:3000`).

| Запрос | Роль | Описание |
|---|---|---|
| `POST /rpc/register` | `web_anon` | регистрация, тело `{"username": "...", "password": "..."}`, пароль не короче 8 символов |
| `POST /rpc/login` | `web_anon` | вход, тело как у `register`, ответ `{"token": "<JWT>"}`, при неверном имени или пароле HTTP 403 |
| `GET /users_public` | `web_anon`, `web_user` | список имён пользователей |
| `GET /chats?title=eq.<название>&chat_type=eq.Channel` | `web_user` | поиск чата по названию и типу |
| `POST /rpc/create_chat` | `web_user` | создание чата, тело `{"title": "...", "chat_type": "Channel", "usernames": []}`, ответ идентификатор чата |
| `GET /messages_public?chat_id=eq.<id>&order=created_at.asc` | `web_user` | сообщения чата, отсортированные по времени |
| `POST /messages_public` | `web_user` | отправка сообщения, тело `{"chat_id": <id>, "message_text": "..."}` |

Запросы от имени `web_user` передают токен в заголовке `Authorization: Bearer <токен>`.

## Секреты

Проект содержит несколько «секретов», которые используются только в демонстрационных целях. В реальной системе их необходимо заменить.

- Пароль `mysecretpassword` используется в `06_create_roles.sql` при создании роли `AUTHENTICATOR` и в `server\postgrest.conf` в ключе `db-uri`. При замене пароль нужно поменять в обоих местах.
- Ключ подписи JWT-токенов `secretsecretsecretsecretsecretsecret` используется в `06_create_roles.sql` в настройке БД `app.jwt_secret` (им подписывает токены функция `LOGIN`) и в `server\postgrest.conf` в ключе `jwt-secret` (им PostgREST проверяет токены). При замене ключ (не короче 32 символов) нужно поменять в обоих местах и перезапустить PostgREST.

## Возможные улучшения

1. Разделить таблицу `Chats` на три таблицы по типу чата `PrivateChats`, `GroupChats` и `Channels`. Кажется, что оптимальнее будет хранить раздельно? Поиск по одной из категорий быстрее, тем более вряд ли понадобится поиск по всем категориям одновременно.

   Таблица личных чатов. Хранит такую информацию как название, время создания и пр. В личном чате всегда только два участника, поэтому эта таблица содержит два атрибута с идентификаторами двух пользователей.

   В таблице групповых чатов нужен атрибут создателя чата, чтобы он мог добавлять или удалять участников.

   Таблица каналов возможно могла бы быть частью таблицы `GroupChats`, но только без прав писать у её участников.

2. Таблица многие-ко-многим `UsersChats`, которая применима только для таблиц `GroupChats` и `Channels`. У личных чатов всегда два участника, они хранятся в таблице `PrivateChats`.

3. Таблица `Requests` принятых заявок на вступление в чат. Возможно таблицу можно использовать в качестве ограничения на отправку сообщений? Нет приглашения - нельзя добавить сообщения в базу.

## Лицензия

Проект распространяется под лицензией MIT, см. файл [LICENSE](LICENSE).
