from PyQt5.QtWidgets import (QWidget, QTextEdit, QGridLayout, QListWidget, QPushButton)
from PyQt5.QtGui import (QColor, QPalette, QColorConstants)


class ThreadWidget(QWidget):
    def __init__(self, dao, chat_id, parent):
        super().__init__(parent)
        self.dao = dao
        self.chat_id = chat_id

        self.list_widget = QListWidget(self)
        self.populate_list()

        self.text_edit = QTextEdit(self)
        self.text_edit.setFixedHeight(80)
        self.text_edit.setPlaceholderText('Enter message...')

        self.button = QPushButton('Send')
        self.button.setFixedWidth(120)
        self.button.clicked.connect(self.send_message)

        layout = QGridLayout(self)
        layout.addWidget(self.list_widget, 0, 0)
        layout.addWidget(self.text_edit, 1, 0)
        layout.addWidget(self.button, 2, 0)

        self.setLayout(layout)

    def send_message(self):
        self.dao.send_message(self.chat_id, self.text_edit.toPlainText())
        self.populate_list()

    def populate_list(self):
        self.list_widget.clear()
        messages = self.dao.list_messages(self.chat_id)
        for message in messages:
            # self.list_widget.insertItem(0, message['message_text'])
            self.list_widget.insertItem(0, '{0}\n{1}\n'.format(message['message_text'], message['created_at']))
