-- https://stackoverflow.com/questions/3327312/how-can-i-drop-all-the-tables-in-a-postgresql-database
DROP SCHEMA PUBLIC CASCADE;

CREATE SCHEMA PUBLIC;

-- восстановить права на схему PUBLIC по умолчанию, как в новой БД (Postgres 15+):
-- владелец pg_database_owner, всем ролям только USAGE без CREATE
ALTER SCHEMA PUBLIC OWNER TO PG_DATABASE_OWNER;

GRANT USAGE ON SCHEMA PUBLIC TO PUBLIC;

-- в ответе по ссылке выше права восстанавливаются как до Postgres 15, где всем
-- ролям было разрешено создавать объекты в схеме PUBLIC; с версии 15 это убрано
-- из соображений безопасности
-- GRANT ALL ON SCHEMA PUBLIC TO POSTGRES;
-- GRANT ALL ON SCHEMA PUBLIC TO PUBLIC;