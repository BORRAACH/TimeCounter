import sys
from pathlib import Path

from PySide6.QtGui import QFont, QFontDatabase, QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from theme import Theme
from weeks import Weeks

BASE_DIR = Path(__file__).parent
QML_FILE = BASE_DIR / "qml" / "Main.qml"


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("time-counter")
    app.setApplicationName("Time Counter")
    for font in (BASE_DIR / "fonts").glob("*.ttf"):
        QFontDatabase.addApplicationFont(str(font))
    # Matches .config/quickshell/caelestia's appearance.font.family.sans.
    app.setFont(QFont("Rubik"))

    theme = Theme()
    weeks = Weeks()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("Theme", theme)
    engine.rootContext().setContextProperty("Weeks", weeks)
    engine.load(QML_FILE)

    if not engine.rootObjects():
        return -1

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
