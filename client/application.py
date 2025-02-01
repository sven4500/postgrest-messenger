from PyQt5.QtWidgets import (QWidget, QToolTip, QPushButton)
from PyQt5.QtGui import QFont


class Application(QWidget):
    def __init__(self):
        super().__init__()
        self.init_ui()

    def init_ui(self):
        QToolTip.setFont(QFont('SansSerif', 10))

        self.setToolTip('This is a <b>QWidget</b> widget')

        btn = QPushButton('Button', self)
        btn.setToolTip('This is a <b>QPushButton</b> widget')
        btn.resize(btn.sizeHint())
        btn.move(50, 50)

        self.setGeometry(300, 300, 300, 200)
        self.setWindowTitle('Tooltips')
        self.show()
