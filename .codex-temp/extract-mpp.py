import json
import sys
from pathlib import Path

sys.path.insert(0, r"D:\Projects\KhachSanDiDong\.codex-temp\pydeps")
import comtypes.client  # noqa: E402


OUTPUT_PATH = Path(r"D:\Projects\KhachSanDiDong\.codex-temp\mpp-tasks.json")


def text(value):
    return None if value is None else str(value)


app = comtypes.client.GetActiveObject("MSProject.Application")
project = app.ActiveProject
tasks = project.Tasks

meta = {
    "Name": text(project.Name),
    "Title": text(project.Title),
    "StartDate": text(project.ProjectStart),
    "FinishDate": text(project.ProjectFinish),
    "CurrentDate": text(project.CurrentDate),
    "ScheduleFromStart": bool(project.ScheduleFromStart),
    "HoursPerDay": float(project.HoursPerDay),
    "HoursPerWeek": float(project.HoursPerWeek),
    "DaysPerMonth": float(project.DaysPerMonth),
    "DefaultCalendar": text(project.Calendar.Name),
    "TaskCount": int(tasks.Count),
}

rows = []
for index in range(1, int(tasks.Count) + 1):
    task = tasks.Item(index)
    if task is None:
        continue
    rows.append(
        {
            "ID": int(task.ID),
            "OutlineNumber": text(task.OutlineNumber),
            "OutlineLevel": int(task.OutlineLevel),
            "Name": text(task.Name),
            "Summary": bool(task.Summary),
            "Milestone": bool(task.Milestone),
            "DurationMinutes": float(task.Duration),
            "Start": text(task.Start),
            "Finish": text(task.Finish),
            "Predecessors": text(task.Predecessors),
            "PercentComplete": int(task.PercentComplete),
            "Notes": text(task.Notes),
        }
    )

OUTPUT_PATH.write_text(
    json.dumps({"Meta": meta, "Tasks": rows}, ensure_ascii=False, indent=2),
    encoding="utf-8",
)
print(OUTPUT_PATH)
