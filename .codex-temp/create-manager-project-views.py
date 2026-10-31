import json
import subprocess
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
PROJECT_ID = "PVT_kwHOCF-thM4Bj7wB"
VISIBLE_FIELDS = [
    "PVTF_lAHOCF-thM4Bj7wBzhiuRtI",  # Title
    "PVTSSF_lAHOCF-thM4Bj7wBzhiuRtQ",  # Status
    "PVTF_lAHOCF-thM4Bj7wBzhiuRtM",  # Assignees
    "PVTF_lAHOCF-thM4Bj7wBzhnej2Y",  # WBS ID
    "PVTSSF_lAHOCF-thM4Bj7wBzhnej3M",  # Sprint
    "PVTSSF_lAHOCF-thM4Bj7wBzhnej4U",  # Workstream
    "PVTSSF_lAHOCF-thM4Bj7wBzhnej5k",  # Evidence level
    "PVTSSF_lAHOCF-thM4Bj7wBzhnej7U",  # Acceptance type
    "PVTSSF_lAHOCF-thM4Bj7wBzhiuoOY",  # Kanban
    "PVTF_lAHOCF-thM4Bj7wBzhiuRvA",  # Estimate
    "PVTF_lAHOCF-thM4Bj7wBzhiuRvE",  # Start date
    "PVTF_lAHOCF-thM4Bj7wBzhiuRvI",  # Target date
    "PVTF_lAHOCF-thM4Bj7wBzhnej8k",  # Last verified
]
VIEWS = [
    ("By Sprint", ""),
    ("By Workstream", ""),
    ("By Owner", "has:assignee"),
    ("Needs evidence", '"Evidence level":"No evidence"'),
    ("Blocked", "Kanban:Blocked"),
    ("Done awaiting acceptance", 'Status:Done -"Evidence level":Acceptance'),
]

def graphql(query):
    result = subprocess.run(["gh", "api", "graphql", "-f", f"query={query}"], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
    if result.returncode:
        raise RuntimeError(result.stderr or result.stdout)
    payload = json.loads(result.stdout)
    if payload.get("errors"):
        raise RuntimeError(json.dumps(payload["errors"], ensure_ascii=False))
    return payload["data"]

existing_query = f'query {{ node(id: "{PROJECT_ID}") {{ ... on ProjectV2 {{ views(first: 50) {{ nodes {{ id name layout filter }} }} }} }} }}'
existing = {view["name"]: view for view in graphql(existing_query)["node"]["views"]["nodes"]}
created = []
for name, filter_text in VIEWS:
    view = existing.get(name)
    if not view:
        field_ids = ", ".join(json.dumps(field_id) for field_id in VISIBLE_FIELDS)
        query = (
            "mutation { createProjectV2View(input: {"
            f'projectId: "{PROJECT_ID}", name: {json.dumps(name)}, layout: TABLE_LAYOUT, '
            f"configuration: {{visibleFieldIds: [{field_ids}]}}"
            "}) { projectV2View { id name layout filter } } }"
        )
        view = graphql(query)["createProjectV2View"]["projectV2View"]
        created.append(name)
    if filter_text:
        query = (
            "mutation { updateProjectV2View(input: {"
            f'viewId: "{view["id"]}", filter: {json.dumps(filter_text)}'
            "}) { projectV2View { id name layout filter } } }"
        )
        view = graphql(query)["updateProjectV2View"]["projectV2View"]
    existing[name] = view

report = {"created": created, "views": [existing[name] for name, _ in VIEWS]}
(ROOT / ".codex-temp" / "manager-project-views-report.json").write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
print(json.dumps(report, ensure_ascii=False))
