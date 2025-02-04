import requests


class Dao:
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IndlYl9hbm9uIiwiaWF0IjoxNTE2MjM5MDIyfQ.xhFiZIcrzvpp8-KEBt__YwVwkt7H3ypt_rgOQx38Bxk"
    url = "http://localhost:3000/users"

    def __init__(self):
        super().__init__()

    def register(self, username, password):
        headers = {"Content-Type": "application/json",
                   "Authorization": "Bearer " + self.token}
        # https://stackoverflow.com/questions/61269993/getting-a-key-error-while-formatting-a-stringified-dictionary-in-python
        # {{ экранирование от {}
        data = '{{"username": "{0}", "password": "{1}"}}'.format(username, password)
        print(data)
        try:
            response = requests.post(self.url, headers=headers, data=data)
            print(response.json())
        except Exception as e:
            print(e)
