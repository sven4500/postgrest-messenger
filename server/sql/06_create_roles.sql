-- https://docs.postgrest.org/en/v12/tutorials/tut0.html#step-4-run-postgrest
-- https://docs.postgrest.org/en/v12/tutorials/tut1.html
--
-- удалить роли при повторном запуске скрипта, DROP OWNED BY сперва отзывает
-- выданные ролям права, иначе DROP ROLE завершится ошибкой
DO $$
declare
	var_role text;
begin
	foreach var_role in array array['web_anon', 'web_user', 'authenticator'] loop
		if exists (select from pg_roles where rolname = var_role) then
			execute format('DROP OWNED BY %I', var_role);
			execute format('DROP ROLE %I', var_role);
		end if;
	end loop;
end;
$$;

-- анонимный пользователь, может только зарегистрироваться и войти
CREATE ROLE WEB_ANON NOLOGIN;

-- пользователь вошедший через rpc/login (роль указана в JWT-токене)
CREATE ROLE WEB_USER NOLOGIN;

-- должен совпадать с паролем в postgrest.conf
CREATE ROLE AUTHENTICATOR NOINHERIT LOGIN PASSWORD 'mysecretpassword';

GRANT WEB_ANON TO AUTHENTICATOR;

GRANT WEB_USER TO AUTHENTICATOR;

-- ключ подписи JWT-токенов для функции LOGIN, должен совпадать с jwt-secret в postgrest.conf
-- (вступает в силу для новых подключений, PostgREST нужно перезапустить);
-- задаётся для текущей БД, т.е. той, что указана в psql -d
DO $$
begin
	execute format('ALTER DATABASE %I SET APP.JWT_SECRET = %L', current_database(), 'secretsecretsecretsecretsecretsecret');
end;
$$;

-- выдать права
GRANT USAGE ON SCHEMA PUBLIC TO WEB_ANON, WEB_USER;

-- нужно выдать ползователю права на последовательности иначе при вставке значения
-- нужно будет явно указывать идентификаторы
GRANT USAGE,
SELECT
	ON ALL SEQUENCES IN SCHEMA PUBLIC TO WEB_USER;

GRANT
SELECT
	ON PUBLIC.USERS_PUBLIC TO WEB_ANON, WEB_USER;

-- by default EXECUTE on functions is granted to everyone, so take it back first
REVOKE
EXECUTE ON ALL FUNCTIONS IN SCHEMA PUBLIC
FROM
	PUBLIC;

GRANT
EXECUTE ON FUNCTION PUBLIC.REGISTER (TEXT, TEXT) TO WEB_ANON;

GRANT
EXECUTE ON FUNCTION PUBLIC.LOGIN (TEXT, TEXT) TO WEB_ANON;

GRANT
EXECUTE ON FUNCTION PUBLIC.CREATE_CHAT (TEXT, CHAT_TYPE_ENUM, TEXT[]) TO WEB_USER;

GRANT
SELECT
	ON PUBLIC.CHATS TO WEB_USER;

GRANT
SELECT
,
	INSERT ON PUBLIC.MESSAGES_PUBLIC TO WEB_USER;
