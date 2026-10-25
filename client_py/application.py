from PyQt5.QtWidgets import (QMainWindow)
from dao import Dao
from login_widget import LoginWidget
from thread_widget import ThreadWidget


# https://www.pythonguis.com/tutorials/pyqt-signals-slots-events/
# https://gist.github.com/MalloyDelacroix/2c509d6bcad35c7e35b1851dfc32d161
class Application(QMainWindow):
    # канал, в который пишут все пользователи клиента; создаётся первым вошедшим пользователем
    chat_title = 'Test channel'
    chat_type = 'Channel'

    def __init__(self):
        super().__init__()

        # один Dao на всё приложение, т.к. он хранит JWT-токен полученный при входе
        self.dao = Dao()

        self.login_widget = LoginWidget(self.dao, self)
        self.login_widget.login_success.connect(self.goto_thread)
        self.login_widget.register_success.connect(self.goto_thread)
        self.setCentralWidget(self.login_widget)

        # создаётся после входа, т.к. сообщения доступны только с токеном
        self.thread_widget = None

        self.setGeometry(300, 300, 300, 200)
        self.setWindowTitle('Postgres Messenger')
        self.show()

    def goto_thread(self):
        # self.login_widget.hide()
        # self.setCentralWidget(self.thread_widget)
        if self.thread_widget is None:
            chat_id = self.dao.find_chat(self.chat_title, self.chat_type)
            if chat_id is None:
                chat_id = self.dao.create_chat(self.chat_title, self.chat_type)
            if chat_id is None:
                print('cannot find or create chat')
                return
            self.thread_widget = ThreadWidget(self.dao, chat_id, None)
        self.thread_widget.show()
