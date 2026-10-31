import argparse
import json
import subprocess
from pathlib import Path

ROOT = Path(r"D:\Projects\KhachSanDiDong")
ITEMS_PATH = ROOT / ".codex-temp" / "wbs-project-items.json"
PROJECT_ID = "PVT_kwHOCF-thM4Bj7wB"
FIELDS = {
    "status": "PVTSSF_lAHOCF-thM4Bj7wBzhiuRtQ",
    "kanban": "PVTSSF_lAHOCF-thM4Bj7wBzhiuoOY",
    "wbs": "PVTF_lAHOCF-thM4Bj7wBzhnej2Y",
    "sprint": "PVTSSF_lAHOCF-thM4Bj7wBzhnej3M",
    "workstream": "PVTSSF_lAHOCF-thM4Bj7wBzhnej4U",
    "evidence": "PVTSSF_lAHOCF-thM4Bj7wBzhnej5k",
    "acceptance": "PVTSSF_lAHOCF-thM4Bj7wBzhnej7U",
    "last_verified": "PVTF_lAHOCF-thM4Bj7wBzhnej8k",
    "estimate": "PVTF_lAHOCF-thM4Bj7wBzhiuRvA",
    "start": "PVTF_lAHOCF-thM4Bj7wBzhiuRvE",
    "target": "PVTF_lAHOCF-thM4Bj7wBzhiuRvI",
}
OPTIONS = {
    "status": {"Backlog": "f75ad846", "In review": "df73e18b"},
    "kanban": {"Triage": "798dfc8d", "Review": "c11e5ecd"},
    "sprint": {"S1": "c9d34b1f", "S2": "67653fb4", "S3": "8dfe30ec", "S4": "413c3822"},
    "workstream": {"Discovery": "585a757d", "Architecture": "0a548915", "Backend": "0adaa34d", "Flutter": "8a171801", "Operations": "9b3ec520", "Dashboard": "b7133c02", "AI": "63f234fd", "QA": "f1231c81", "DevOps": "2ecc181f", "Project management": "85f52381"},
    "evidence": {"No evidence": "42ab1d3b", "Code": "4cb4413b", "Code + test/CI": "1933e071", "Acceptance": "bc15256b"},
    "acceptance": {"UAT": "8b928720", "Stakeholder sign-off": "7e44952f", "Reviewer approval": "c5338fdd", "Not applicable": "4fe0beb3"},
}

parser = argparse.ArgumentParser()
parser.add_argument("--start", type=int, required=True)
parser.add_argument("--end", type=int, required=True)
args = parser.parse_args()

items = list(json.loads(ITEMS_PATH.read_text(encoding="utf-8")).values())
items.sort(key=lambda item: item["wbs_id"])
selected = items[args.start:args.end]

mutations = []
alias = 0
def add(item, field_id, value):
    global alias
    mutations.append(
        f'm{alias}: updateProjectV2ItemFieldValue(input: {{projectId: "{PROJECT_ID}", itemId: "{item["project_item_id"]}", fieldId: "{field_id}", value: {value}}}) {{ projectV2Item {{ id }} }}'
    )
    alias += 1

for item in selected:
    add(item, FIELDS["wbs"], "{text: " + json.dumps(item["wbs_id"], ensure_ascii=False) + "}")
    add(item, FIELDS["sprint"], "{singleSelectOptionId: " + json.dumps(OPTIONS["sprint"][item["sprint"]]) + "}")
    add(item, FIELDS["workstream"], "{singleSelectOptionId: " + json.dumps(OPTIONS["workstream"][item["workstream"]]) + "}")
    add(item, FIELDS["evidence"], "{singleSelectOptionId: " + json.dumps(OPTIONS["evidence"][item["evidence_level"]]) + "}")
    add(item, FIELDS["acceptance"], "{singleSelectOptionId: " + json.dumps(OPTIONS["acceptance"][item["acceptance_type"]]) + "}")
    add(item, FIELDS["kanban"], "{singleSelectOptionId: " + json.dumps(OPTIONS["kanban"][item["kanban"]]) + "}")
    status = "In review" if item["kanban"] == "Review" else "Backlog"
    add(item, FIELDS["status"], "{singleSelectOptionId: " + json.dumps(OPTIONS["status"][status]) + "}")
    add(item, FIELDS["estimate"], "{number: " + str(item["estimate"]) + "}")
    add(item, FIELDS["start"], "{date: " + json.dumps(item["start"]) + "}")
    add(item, FIELDS["target"], "{date: " + json.dumps(item["target"]) + "}")
    if item["last_verified"]:
        add(item, FIELDS["last_verified"], "{date: " + json.dumps(item["last_verified"]) + "}")

query = "mutation { " + " ".join(mutations) + " }"
result = subprocess.run(["gh", "api", "graphql", "-f", f"query={query}"], cwd=ROOT, capture_output=True, text=True, encoding="utf-8")
if result.returncode:
    raise RuntimeError(result.stderr or result.stdout)
payload = json.loads(result.stdout)
if payload.get("errors"):
    raise RuntimeError(json.dumps(payload["errors"], ensure_ascii=False))
print(json.dumps({"items": len(selected), "field_updates": len(mutations), "aliases_returned": len(payload.get("data", {}))}))
