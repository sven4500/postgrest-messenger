import sys
from PyQt5.QtWidgets import (QApplication)
from application import Application

if __name__ == '__main__':
    app = QApplication(sys.argv)
    ex = Application()
    sys.exit(app.exec_())
