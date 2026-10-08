import json
import os
from pathlib import Path

from PySide6.QtCore import Property, QObject, Signal, Slot

WEEKS_PATH = Path.home() / ".config" / "time-counter" / "weeks.json"


class Weeks(QObject):
    """Archive of finished study weeks, persisted as JSON."""

    recordsChanged = Signal()

    def __init__(self, parent=None):
        super().__init__(parent)
        self._weeks = []
        try:
            data = json.loads(WEEKS_PATH.read_text(encoding="utf-8"))
            self._weeks = list(data.get("weeks", []))
        except (OSError, json.JSONDecodeError, AttributeError):
            pass

    @Property("QVariantList", notify=recordsChanged)
    def records(self):
        # Newest week first, for display.
        return sorted(self._weeks, key=lambda w: w["week"], reverse=True)

    @Property(int, notify=recordsChanged)
    def nextWeek(self):
        return max((w["week"] for w in self._weeks), default=0) + 1

    def _append(self, week, week_start, week_end, hours, goal, days=None):
        total = sum(hours.values())
        self._weeks.append(
            {
                "week": week,
                "weekStart": week_start,
                "weekEnd": week_end,
                "totalHours": total,
                "goalHours": goal,
                "percentage": round(total / goal * 100, 1) if goal else 0.0,
                "subjects": hours,
                "days": days or [],
            }
        )
        self._weeks.sort(key=lambda w: w["week"])
        self._save()
        self.recordsChanged.emit()

    @Slot(str, str, "QVariantMap", int, "QVariantList")
    def archive(self, week_start, week_end, subjects, goal, days):
        """Automatic archive of the week that just ended.

        Numbered after the highest week already on file (120 -> 121).
        `days` holds the hours studied on Sunday..Saturday.
        """
        hours = {name: int(value) for name, value in subjects.items()}
        self._append(self.nextWeek, week_start, week_end, hours, goal, [int(d) for d in days])

    @Slot(int, "QVariantMap", int, result=str)
    def addManual(self, week, subjects, goal):
        """Add a past week typed in by hand. Returns an error message, or "" on success."""
        if week < 1:
            return "O número da semana deve ser maior que zero."
        if any(w["week"] == week for w in self._weeks):
            return f"A semana {week} já está registrada."
        hours = {name: int(value) for name, value in subjects.items()}
        self._append(week, "", "", hours, goal)
        return ""

    def _save(self):
        WEEKS_PATH.parent.mkdir(parents=True, exist_ok=True)
        tmp = WEEKS_PATH.with_suffix(".json.tmp")
        tmp.write_text(json.dumps({"weeks": self._weeks}, ensure_ascii=False, indent=2), encoding="utf-8")
        os.replace(tmp, WEEKS_PATH)
