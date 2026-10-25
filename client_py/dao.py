import requests
from urllib.parse import urlencode, quote


class Dao:
    url = 'http://localhost:3000'

    def __init__(self):
        super().__init__()
        # JWT-токен выдаётся функцией rpc/login, без токена запросы выполняются от роли web_anon
        self.token = None
        self.username = ''

    def headers(self):
        if self.token is None:
            return {}
        return {"Authorization": "Bearer " + self.token}

    def register(self, username, password):
        try:
            response = requests.post(self.url + "/rpc/register",
                                     json={"username": username, "password": password})
            if not response.ok:
                print(response.text)
                return False
            return True
        except Exception as e:
            print(e)
            return False

    def list_users(self):
        try:
            response = requests.get(self.url + "/users_public", headers=self.headers())
            print(response.json())
            return response.json()
        except Exception as e:
            print(e)
            return []

    def login(self, username, password):
        try:
            response = requests.post(self.url + "/rpc/login",
                                     json={"username": username, "password": password})
            if not response.ok:
                print(response.text)
                return False
            self.token = response.json()['token']
            self.username = username
            return True
        except Exception as e:
            print(e)
            return False

    def find_chat(self, title, chat_type):
        # первый чат с таким названием и типом, quote кодирует пробел как %20
        params = urlencode({"title": "eq." + title, "chat_type": "eq." + chat_type,
                            "order": "chat_id.asc", "limit": 1}, quote_via=quote)
        try:
            response = requests.get(self.url + "/chats", headers=self.headers(), params=params)
            if not response.ok:
                print(response.text)
                return None
            chats = response.json()
            return chats[0]['chat_id'] if chats else None
        except Exception as e:
            print(e)
            return None

    def create_chat(self, title, chat_type, usernames=()):
        # возвращает идентификатор нового чата
        try:
            response = requests.post(self.url + "/rpc/create_chat", headers=self.headers(),
                                     json={"title": title, "chat_type": chat_type, "usernames": list(usernames)})
            if not response.ok:
                print(response.text)
                return None
            return response.json()
        except Exception as e:
            print(e)
            return None

    def send_message(self, chat_id, text):
        try:
            response = requests.post(self.url + "/messages_public", headers=self.headers(),
                                     json={"chat_id": chat_id, "message_text": text})
            if not response.ok:
                print(response.text)
                return False
            return True
        except Exception as e:
            print(e)
            return False

    def list_messages(self, chat_id):
        try:
            params = {"chat_id": "eq." + str(chat_id), "order": "created_at.asc"}
            response = requests.get(self.url + "/messages_public", headers=self.headers(), params=params)
            if not response.ok:
                print(response.text)
                return []
            return response.json()
        except Exception as e:
            print(e)
            return []
