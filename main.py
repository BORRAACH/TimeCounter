import sys
from pathlib import Path

from PySide6.QtGui import QFont, QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from theme import Theme

QML_FILE = Path(__file__).parent / "qml" / "Main.qml"


def main() -> int:
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("time-counter")
    app.setApplicationName("Time Counter")
    # Matches .config/quickshell/caelestia's appearance.font.family.sans.
    app.setFont(QFont("Rubik"))

    theme = Theme()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("Theme", theme)
    engine.load(QML_FILE)

    if not engine.rootObjects():
        return -1

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
