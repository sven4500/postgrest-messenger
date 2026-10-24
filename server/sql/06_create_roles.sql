-- https://docs.postgrest.org/en/v12/tutorials/tut0.html#step-4-run-postgrest
DROP ROLE WEB_ANON;

DROP ROLE AUTHENTICATOR;

CREATE ROLE WEB_ANON NOLOGIN;

-- должен совпадать с паролем в postgrest.conf
CREATE ROLE AUTHENTICATOR NOINHERIT LOGIN PASSWORD 'mysecretpassword';

GRANT WEB_ANON TO AUTHENTICATOR;

-- выдать права
GRANT USAGE ON SCHEMA PUBLIC TO WEB_ANON;

-- нужно выдать ползователю права на последовательности иначе при вставке значения
-- нужно будет явно указывать идентификаторы
GRANT USAGE,
SELECT
	ON ALL SEQUENCES IN SCHEMA PUBLIC TO WEB_ANON;

GRANT
SELECT
	ON PUBLIC.USERS_PUBLIC TO WEB_ANON;

-- by default EXECUTE on functions is granted to everyone, so take it back first
REVOKE
EXECUTE ON FUNCTION PUBLIC.REGISTER (TEXT, TEXT)
FROM
	PUBLIC;

GRANT
EXECUTE ON FUNCTION PUBLIC.REGISTER (TEXT, TEXT) TO WEB_ANON;

GRANT
SELECT
	ON PUBLIC.CHATS TO WEB_ANON;

GRANT
SELECT
,
	INSERT ON PUBLIC.MESSAGES_PUBLIC TO WEB_ANON;