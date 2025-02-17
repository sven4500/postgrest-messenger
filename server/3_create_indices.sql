CREATE INDEX IF NOT EXISTS USERS_INDEX ON USERS (USERNAME);

-- таблица contacts хранит записную книжку того как user_1 назвал user_2
-- user_2 в индекс не включаем потому что важно быстро получить набор user_2
-- в рамках которого индексироваться уже не очень выгодно
CREATE INDEX IF NOT EXISTS CONTACTS_INDEX ON CONTACTS (USER_1);

-- можно было бы добавить дополнительный индекс для названия чата
-- но собираемся ли мы когда-либо искачть чат по названию? возможно
CREATE INDEX IF NOT EXISTS CHAT_INDEX ON CHATS (CHAT_ID);

-- интересно вычитывать участников по чатам, поэтому индекс по chat_id
CREATE INDEX IF NOT EXISTS PARTICIPANTS_INDEX ON PARTICIPANTS (CHAT_ID);

-- важно ускорить получение сообщений по чатам + ускорить получение сообщений
-- по времени создания, т.к. (1) сообщения должны быть отсортированы по дате создания
-- (2) выгрузка сообщений происходит последовательными блоками 
CREATE INDEX IF NOT EXISTS MESSAGES_INDEX ON MESSAGES (CHAT_ID, CREATED_AT);

CREATE INDEX IF NOT EXISTS VOICES_INDEX ON VOICES (MESSAGE_ID);

CREATE INDEX IF NOT EXISTS IMAGES_INDEX ON IMAGES (MESSAGE_ID);

CREATE INDEX IF NOT EXISTS FILES_INDEX ON FILES (MESSAGE_ID);