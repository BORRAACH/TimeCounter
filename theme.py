import json
from pathlib import Path

from PySide6.QtCore import Property, QFileSystemWatcher, QObject, Signal

SCHEME_PATH = Path.home() / ".local" / "state" / "caelestia" / "scheme.json"


class Theme(QObject):
    coloursChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._colours = {}
        self._watcher = QFileSystemWatcher(self)
        self._watcher.fileChanged.connect(self._on_file_changed)
        self._load()

    def _load(self):
        try:
            data = json.loads(SCHEME_PATH.read_text())
            self._colours = {key: f"#{value}" for key, value in data["colours"].items()}
        except (OSError, json.JSONDecodeError, KeyError):
            self._colours = {}

        if str(SCHEME_PATH) not in self._watcher.files() and SCHEME_PATH.exists():
            self._watcher.addPath(str(SCHEME_PATH))

    def _on_file_changed(self):
        self._load()
        self.coloursChanged.emit()

    @Property("QVariantMap", notify=coloursChanged)
    def colours(self):
        return self._colours
