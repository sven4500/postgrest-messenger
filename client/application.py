from PyQt5.QtWidgets import (QWidget, QPushButton, QGridLayout, QHBoxLayout, QLabel, QLineEdit)
from dao import Dao


class Application(QWidget):
    dao = Dao()

    def __init__(self):
        super().__init__()

        username_label = QLabel('Username', self)
        self.username_edit = QLineEdit(self)

        password_label = QLabel('Password', self)
        self.password_edit = QLineEdit(self)
        self.password_edit.setEchoMode(QLineEdit.Password)

        register_button = QPushButton('Register', self)
        register_button.resize(register_button.sizeHint())
        register_button.clicked.connect(self.register)

        login_button = QPushButton('Login', self)
        login_button.resize(login_button.sizeHint())
        login_button.clicked.connect(self.login)

        hbox_layout = QHBoxLayout()
        hbox_layout.addWidget(login_button)
        hbox_layout.addWidget(register_button)

        layout = QGridLayout(self)
        layout.addWidget(username_label, 0, 0)
        layout.addWidget(self.username_edit, 0, 1)
        layout.addWidget(password_label, 1, 0)
        layout.addWidget(self.password_edit, 1, 1)
        layout.addLayout(hbox_layout, 2, 0, 1, 2)

        self.setLayout(layout)
        self.setGeometry(300, 300, 300, 200)
        self.setWindowTitle('Postgres Messenger')
        self.show()

    def register(self):
        username = self.username_edit.text()
        password = self.password_edit.text()
        self.dao.register(username, password)

    def login(self):
        username = self.username_edit.text()
        password = self.password_edit.text()
        self.dao.login(username, password)
