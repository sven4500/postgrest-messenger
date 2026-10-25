-- запретить пользователю задавать значения самостоятельно (сделать столбец только на чтение)
-- например, пользовтелю запрещено самостоятельно генерировать миниатюры или вейвформы
-- postgres вызывает триггеры в алфаыитном порядке
-- https://dba.stackexchange.com/questions/12581/how-to-specify-trigger-execution-order-under-postgresql
-- https://stackoverflow.com/questions/15411735/postgresql-restrict-update-on-specific-columns-read-only
CREATE EXTENSION IF NOT EXISTS PGCRYPTO;

CREATE OR REPLACE FUNCTION A_RESTRICT_VOICES () RETURNS TRIGGER AS $$
begin
	if old.waveform is distinct from new.waveform then
		raise exception 'Waveforms are formed automatically';
	end if;
	return new;
end;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER A_RESTRICT_VOICES_TRIGGER
BEFORE INSERT OR UPDATE ON VOICES FOR EACH ROW
EXECUTE FUNCTION A_RESTRICT_VOICES ();

-- триггер "вычисляет" и добавляет вейвформу к записи голосового сообщения
-- (в текущем варианте случайные значения)
CREATE OR REPLACE FUNCTION B_MAKE_WAVEFORM () RETURNS TRIGGER AS $$
declare
	var_waveform varchar(255) default ''; -- default иначе NULL
begin
	-- https://dba.stackexchange.com/questions/49510/assign-values-with-the-operator
	-- до 9.4 оператор присовоения только :=
 	-- быстрее ли сперва положить в переменную?
	for i in 1..62 loop
	    var_waveform = var_waveform || (random() * 255)::int || ',';
	end loop;
	new.waveform = var_waveform;
	return new;
end;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER B_MAKE_WAVEFORM_TRIGGER
BEFORE INSERT ON VOICES FOR EACH ROW
EXECUTE FUNCTION B_MAKE_WAVEFORM ();

-- запретить пользователю менять миниматюры
CREATE OR REPLACE FUNCTION A_RESTRICT_IMAGES () RETURNS TRIGGER AS $$
begin
	if old.thumbnail is distinct from new.thumbnail then
		raise exception 'Thumbnails are formed automatically';
	end if;
	return new;
end;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER A_RESTRICT_IMAGES_TRIGGER
BEFORE INSERT OR UPDATE ON IMAGES FOR EACH ROW
EXECUTE FUNCTION A_RESTRICT_IMAGES ();

-- триггер добавляет картинку для предпросмотра изображения
-- в данном варианте заглушка
-- на этапи всавки строки, файл уже должен быть загружен на файловый сервер
-- https://gist.github.com/ondrek/7413434
CREATE OR REPLACE FUNCTION B_MAKE_THUMBNAIL () RETURNS TRIGGER AS $$
declare
	var_image text default 'data:image/gif;base64,R0lGODlhAQABAAAAACw=';
begin
	new.thumbnail = var_image;
	return new;
end;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER B_MAKE_THUMBNAIL_TRIGGER
BEFORE INSERT ON IMAGES FOR EACH ROW
EXECUTE FUNCTION B_MAKE_THUMBNAIL ();

-- триггеры для сообщений
CREATE OR REPLACE FUNCTION A_UPDATE_MODIFIED_AT () RETURNS TRIGGER AS $$
begin
	if old.modified_at is distinct from new.modified_at then
		raise exception 'Modified time is assigned automatically';
	end if;
	new.modified_at = now();
	return new;
end;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE TRIGGER A_UPDATE_MODIFIED_AT_TRIGGER
BEFORE INSERT OR UPDATE ON MESSAGES FOR EACH ROW
EXECUTE FUNCTION A_UPDATE_MODIFIED_AT ();

-- registration goes only through rpc/register; web_anon has no direct access to USERS
CREATE OR REPLACE FUNCTION REGISTER (USERNAME TEXT, PASSWORD TEXT) RETURNS VOID LANGUAGE PLPGSQL SECURITY DEFINER
SET
	SEARCH_PATH = PUBLIC,
	PG_TEMP AS $$
begin
	if length(register.password) < 8 then
		raise exception 'Password must be at least 8 characters';
	end if;
	insert into users (username, password)
	values (register.username, crypt(register.password, gen_salt('bf', 12)));
end;
$$;

-- кодирование в base64url (base64 без '=' и переносов строк, '+/' заменены на '-_'),
-- используется для формирования JWT-токена
CREATE OR REPLACE FUNCTION BASE64URL_ENCODE (DATA BYTEA) RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$
	select translate(encode(data, 'base64'), E'+/=\n', '-_');
$$;

-- JWT-токен подписанный HMAC SHA-256 (алгоритм HS256), который проверяет PostgREST
-- https://datatracker.ietf.org/doc/html/rfc7519
CREATE OR REPLACE FUNCTION SIGN_JWT (PAYLOAD JSON, SECRET TEXT) RETURNS TEXT LANGUAGE SQL IMMUTABLE
SET
	SEARCH_PATH = PUBLIC,
	PG_TEMP AS $$
	with parts as (
		select base64url_encode(convert_to('{"alg":"HS256","typ":"JWT"}', 'utf8')) || '.' ||
			base64url_encode(convert_to(payload::text, 'utf8')) as unsigned
	)
	select unsigned || '.' || base64url_encode(hmac(unsigned, secret, 'sha256')) from parts;
$$;

-- вход через rpc/login: проверяет пароль и возвращает JWT-токен с ролью WEB_USER,
-- токен действует сутки, ключ подписи хранится в настройке БД app.jwt_secret
CREATE OR REPLACE FUNCTION LOGIN (USERNAME TEXT, PASSWORD TEXT) RETURNS JSON LANGUAGE PLPGSQL SECURITY DEFINER
SET
	SEARCH_PATH = PUBLIC,
	PG_TEMP AS $$
declare
	var_user users;
begin
	select * into var_user from users where users.username = login.username;
	-- одинаковая ошибка для неизвестного пользователя и неверного пароля,
	-- код 28P01 (invalid_password) PostgREST возвращает как HTTP 403
	if not found or var_user.password <> crypt(login.password, var_user.password) then
		raise exception 'Invalid username or password' using errcode = 'invalid_password';
	end if;
	return json_build_object('token', sign_jwt(json_build_object(
		'role', 'web_user',
		'user_id', var_user.user_id,
		'username', var_user.username,
		'exp', extract(epoch from now() + interval '1 day')::bigint
	), current_setting('app.jwt_secret')));
end;
$$;
