-- запретить пользователю задавать значения самостоятельно (сделать столбец только на чтение)
-- например, пользовтелю запрещено самостоятельно генерировать миниатюры или вейвформы
-- postgres вызывает триггеры в алфаыитном порядке
-- https://dba.stackexchange.com/questions/12581/how-to-specify-trigger-execution-order-under-postgresql
-- https://stackoverflow.com/questions/15411735/postgresql-restrict-update-on-specific-columns-read-only
CREATE
OR REPLACE FUNCTION A_RESTRICT_VOICES () RETURNS TRIGGER AS $$
begin
	if old.waveform is distinct from new.waveform then
		raise exception 'Waveforms are formed automatically';
	end if;
	return new;
end;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE TRIGGER A_RESTRICT_VOICES_TRIGGER BEFORE INSERT
OR
UPDATE ON VOICES FOR EACH ROW
EXECUTE FUNCTION A_RESTRICT_VOICES ();

-- запретить пользователю менять миниматюры
CREATE
OR REPLACE FUNCTION A_RESTRICT_IMAGES () RETURNS TRIGGER AS $$
begin
	if old.thumbnail is distinct from new.thumbnail then
		raise exception 'Thumbnails are formed automatically';
	end if;
	return new;
end;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE TRIGGER A_RESTRICT_IMAGES_TRIGGER BEFORE INSERT
OR
UPDATE ON IMAGES FOR EACH ROW
EXECUTE FUNCTION A_RESTRICT_IMAGES ();

-- триггер "вычисляет" и добавляет вейвформу к записи голосового сообщения
-- (в текущем варианте случайные значения)
CREATE
OR REPLACE FUNCTION B_MAKE_WAVEFORM () RETURNS TRIGGER AS $$
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

CREATE
OR REPLACE TRIGGER B_MAKE_WAVEFORM_TRIGGER BEFORE INSERT ON VOICES FOR EACH ROW
EXECUTE FUNCTION B_MAKE_WAVEFORM ();

-- триггер добавляет картинку для предпросмотра изображения
-- в данном варианте заглушка
-- на этапи всавки строки, файл уже должен быть загружен на файловый сервер
-- https://gist.github.com/ondrek/7413434
CREATE
OR REPLACE FUNCTION B_MAKE_THUMBNAIL () RETURNS TRIGGER AS $$
declare
	var_image text default 'data:image/gif;base64,R0lGODlhAQABAAAAACw=';
begin
	new.thumbnail = var_image;
	return new;
end;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE TRIGGER B_MAKE_THUMBNAIL_TRIGGER BEFORE INSERT ON IMAGES FOR EACH ROW
EXECUTE FUNCTION B_MAKE_THUMBNAIL ();