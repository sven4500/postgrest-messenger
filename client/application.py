from PyQt5.QtWidgets import (QMainWindow)
from dao import Dao
from login_widget import LoginWidget
from thread_widget import ThreadWidget


# https://www.pythonguis.com/tutorials/pyqt-signals-slots-events/
# https://gist.github.com/MalloyDelacroix/2c509d6bcad35c7e35b1851dfc32d161
class Application(QMainWindow):
    dao = Dao()

    def __init__(self):
        super().__init__()

        self.login_widget = LoginWidget(self)
        self.login_widget.login_success.connect(self.goto_thread)
        self.login_widget.register_success.connect(self.goto_thread)
        self.setCentralWidget(self.login_widget)

        self.thread_widget = ThreadWidget(None)

        self.setGeometry(300, 300, 300, 200)
        self.setWindowTitle('Postgres Messenger')
        self.show()

    def goto_thread(self):
        # self.login_widget.hide()
        # self.setCentralWidget(self.thread_widget)
        self.thread_widget.show()
