import sys

from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtQuick import QQuickWindow
from PyQt6.QtCore import QObject, pyqtSlot as Slot

from config_reader import config

class SettingsService(QObject):
    @Slot(int)
    def work_time(self, value):
        if value > 0:
            config.update_value("work_time", int(value))

    @Slot(int)
    def rest_time(self, value):
        if value > 0:
            config.update_value("rest_time", int(value))

class WorkflowService(QObject):
    @Slot()
    def startWork(self):
        print('Start work')
        pass

    def startRest(self):
        print('Start rest')
        pass

def main():
    app = QGuiApplication(sys.argv)
    settings_service = SettingsService()
    workflow_service = WorkflowService()

    QQuickWindow.setSceneGraphBackend('software')
    engine = QQmlApplicationEngine()
    engine.quit.connect(app.quit)
    engine.load('./app.qml')
    obj = engine.rootObjects()[0]
    obj.setProperty('work_time_seconds', config.work_time_seconds)
    obj.setProperty('rest_time_seconds', config.rest_time_seconds)
    obj.setProperty('settings_service', settings_service)
    obj.setProperty('workflow_service', workflow_service)

    sys.exit(app.exec())


if __name__ == '__main__':
    main()
