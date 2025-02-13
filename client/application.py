from PyQt5.QtWidgets import (QMainWindow, QPushButton, QGridLayout, QHBoxLayout, QLabel, QLineEdit)
from dao import Dao
from login_widget import LoginWidget


class Application(QMainWindow):
    dao = Dao()

    def __init__(self):
        super().__init__()

        self.login_widget = LoginWidget()
        self.setCentralWidget(self.login_widget)

        self.setGeometry(300, 300, 300, 200)
        self.setWindowTitle('Postgres Messenger')
        self.show()
