-- представления используются в качестве открытой части api
-- например пользователю не надо давать доступ к идентификаторам
-- поэтому вью включает только те столбцы которые разрешены пользователю
-- при этом те столбцы которые пользователю не разрешено задавать
-- самостоятельно (например время сообщения, или вейвформу)
-- отслеживаются триггерами
CREATE OR REPLACE VIEW FILES_PUBLIC AS
SELECT
	MESSAGE_ID,
	MEDIA_URL
FROM
	FILES;

CREATE OR REPLACE VIEW IMAGES_PUBLIC AS
SELECT
	IMAGE_ID,
	MESSAGE_ID,
	MEDIA_URL
FROM
	IMAGES;

CREATE OR REPLACE VIEW IMAGES_PUBLIC AS
SELECT
	IMAGE_ID,
	MESSAGE_ID,
	MEDIA_URL
FROM
	IMAGES;

CREATE OR REPLACE VIEW VOICES_PUBLIC AS
SELECT
	MESSAGE_ID,
	MEDIA_URL,
	WAVEFORM
FROM
	VOICES;