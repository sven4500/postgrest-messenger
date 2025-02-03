from PyQt5.QtWidgets import (QWidget, QToolTip, QPushButton)
from PyQt5.QtGui import QFont
import requests


class Application(QWidget):
    token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IndlYl9hbm9uIiwiaWF0IjoxNTE2MjM5MDIyfQ.xhFiZIcrzvpp8-KEBt__YwVwkt7H3ypt_rgOQx38Bxk"
    url = "http://localhost:3000/users"

    def __init__(self):
        super().__init__()
        self.init_ui()

    def register_user(self):
        headers = {"Content-Type": "application/json",
                   "Authorization": "Bearer " + self.token}
        data = '{"username": "noname5", "password": "password"}'
        response = requests.post(self.url, headers=headers, data=data)
        # print(response.json())

    def init_ui(self):
        QToolTip.setFont(QFont('SansSerif', 10))

        self.setToolTip('This is a <b>QWidget</b> widget')

        btn = QPushButton('Button', self)
        btn.setToolTip('This is a <b>QPushButton</b> widget')
        btn.resize(btn.sizeHint())
        btn.move(50, 50)
        btn.clicked.connect(self.register_user)

        self.setGeometry(300, 300, 300, 200)
        self.setWindowTitle('Tooltips')
        self.show()
