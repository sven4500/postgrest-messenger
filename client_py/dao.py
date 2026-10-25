import requests


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
            response = requests.get(self.url + "/messages_public", headers=self.headers())
            if not response.ok:
                print(response.text)
                return []
            return response.json()
        except Exception as e:
            print(e)
            return []
