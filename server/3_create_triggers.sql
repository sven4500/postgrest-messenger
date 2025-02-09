-- триггер "вычисляет" и добавляет вейвформу к записи голосового сообщения
-- (в текущем варианте случайные значения)
CREATE
OR REPLACE FUNCTION MAKE_WAVEFORM () RETURNS TRIGGER AS $$
declare
	var_waveform varchar(255) default ''; -- default иначе NULL
begin
	-- https://dba.stackexchange.com/questions/49510/assign-values-with-the-operator
	-- до 9.4 оператор присовоения только :=
 	-- быстрее ли сперва положить в переменную?
	for i in 1..62 loop
	    var_waveform = var_waveform || (random() * 255)::int || ',';
	end loop;
	update voices set waveform = var_waveform where voice_id = new.voice_id;
	return new; -- зачем возвращать new если он ничего не меняет?
end;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE TRIGGER MAKE_WAVEFORM_TRIGGER
AFTER INSERT ON VOICES FOR EACH ROW
EXECUTE FUNCTION MAKE_WAVEFORM ();

-- триггер добавляет картинку для предпросмотра изображения
-- https://gist.github.com/ondrek/7413434
CREATE
OR REPLACE FUNCTION MAKE_THUMBNAIL () RETURNS TRIGGER AS $$
declare
	var_image text default 'data:image/gif;base64,R0lGODlhAQABAAAAACw=';
begin
	update images set thumbnail = var_image where image_id = new.image_id;
	return new;
end;
$$ LANGUAGE PLPGSQL;

CREATE
OR REPLACE TRIGGER MAKE_THUMBNAIL_TRIGGER
AFTER INSERT ON IMAGES FOR EACH ROW
EXECUTE FUNCTION MAKE_THUMBNAIL ();