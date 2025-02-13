from PyQt5.QtWidgets import (QWidget)
from PyQt5.QtGui import (QColor, QPalette, QColorConstants)
from dao import Dao


class ThreadWidget(QWidget):
    dao = Dao()

    def __init__(self, parent):
        super().__init__(parent)

        palette = self.palette()
        palette.setColor(QPalette.Background, QColorConstants.Magenta)

        self.setPalette(palette)
