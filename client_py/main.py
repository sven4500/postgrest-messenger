import sys
from PyQt5.QtWidgets import (QApplication)
from application import Application

if __name__ == '__main__':
    app = QApplication(sys.argv)
    # имя приложения вместо "python" для окон без заголовка
    app.setApplicationName('Postgres Messenger')
    ex = Application()
    sys.exit(app.exec_())
