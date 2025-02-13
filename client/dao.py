import requests
import hashlib


class Dao:
    token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IndlYl9hbm9uIiwiaWF0IjoxNTE2MjM5MDIyfQ.xhFiZIcrzvpp8-KEBt__YwVwkt7H3ypt_rgOQx38Bxk'

    def __init__(self):
        super().__init__()

    def register(self, username, password):
        headers = {"Content-Type": "application/json",
                   "Authorization": "Bearer " + self.token}
        # https://stackoverflow.com/questions/61269993/getting-a-key-error-while-formatting-a-stringified-dictionary-in-python
        # {{ экранирование от {}
        data = '{{"username": "{0}", "password": "{1}"}}'.format(username, hashlib.md5(password.encode()).hexdigest())
        print(data)
        try:
            response = requests.post("http://localhost:3000/users_public", headers=headers, data=data)
            print(response.json())
            return 1
        except Exception as e:
            print(e)
            return 0

    def list_users(self):
        headers = {"Content-Type": "application/json",
                   "Authorization": "Bearer " + self.token}
        try:
            response = requests.get("http://localhost:3000/users_public", headers=headers)
            print(response.json())
            return response.json()
        except Exception as e:
            print(e)
            return []

    def login(self, username, password):
        # пока не используется
        users_list = self.list_users()
        for user in users_list:
            if username == user['username']:
                return 1
        return 0
