import json
import math
import re
import xml.etree.ElementTree as ET
from pathlib import Path

SOURCE_XML = Path(
    r"D:\Projects\KhachSanDiDong\plans\260923-1658-four-sprint-mvp-backlog\Ke-hoach-KhachSanDiDong-MSProject-2021.xml"
)
OUTPUT_JSON = Path(r"D:\Projects\KhachSanDiDong\.codex-temp\wbs-review-data.json")
NS = {"m": "http://schemas.microsoft.com/project"}


SUMMARY_NAMES = {
    "Khách Sạn Di Động — MVP quản lý phòng realtime": "Khách Sạn Di Động — MVP quản lý vận hành phòng realtime",
    "Mốc 24/09/2026: việc chưa xong được lập lịch từ ngày trạng thái": "Milestone: Rà soát tiến độ và tái lập lịch từ 24/09/2026",
    "Khảo sát, kickoff, phỏng vấn, AS-IS/TO-BE, requirement và sign-off": "Khảo sát và phê duyệt yêu cầu MVP",
    "Artefact nghiệp vụ Đạt đã có bằng chứng trong repository": "Hoàn thiện artefact nghiệp vụ đã có bằng chứng",
    "Kiến trúc, contract API, môi trường dev/staging": "Thiết kế kiến trúc, contract API và môi trường",
    "Backend: Express, Prisma, auth, RBAC, danh mục phòng, Socket.IO": "Xây dựng backend nền tảng và realtime",
    "Flutter Web, Android, Design Token và QA nền tảng": "Xây dựng Flutter Web, Android và QA nền tảng",
    "Cổng Sprint 1: quản lý đăng nhập, sửa phòng, seed 50 phòng, RBAC chặn ghi, realtime hai client": "Milestone: Hoàn thành Sprint 1",
    "Chốt rule vận hành trước khi code check-in, housekeeping, maintenance": "Chốt quy tắc vận hành trước khi phát triển",
    "Check-in, check-out, housekeeping, maintenance, audit log và Socket.IO": "Xây dựng nghiệp vụ vận hành và realtime",
    "Flutter Web và Android cho nhận trả, dọn phòng, bảo trì, nhật ký": "Xây dựng giao diện vận hành Web và Android",
    "Cổng Sprint 2: check-in, check-out, dọn, xác nhận, check-in lại; báo hỏng chặn nhận phòng; audit sau commit": "Milestone: Hoàn thành Sprint 2",
    "Chốt KPI dashboard và hợp đồng AI summary": "Chốt KPI dashboard và contract AI summary",
    "API dashboard, job quá hạn và AI summary phía server": "Xây dựng API dashboard, job quá hạn và AI summary",
    "UI dashboard, AI summary, responsive và accessibility": "Xây dựng dashboard, AI summary và accessibility",
    "Cổng Sprint 3: dashboard khớp fixture, AI không gửi PII, fallback 15 giây và trần 300.000 đồng": "Milestone: Hoàn thành Sprint 3",
    "Security, CI/CD, staging, rollback và hồ sơ bàn giao": "Thiết lập bảo mật, CI/CD, staging và bàn giao",
    "Gia cố backend, diễn tập migration, APK Android": "Gia cố backend, diễn tập migration và phát hành APK",
    "UAT, responsive, accessibility và bàn giao demo": "Thực hiện UAT, accessibility và bàn giao demo",
    "Bàn giao 27/10/2026: Web HTTPS, APK Android, CI xanh, runbook rollback và handover pack": "Milestone: Bàn giao MVP ngày 27/10/2026",
}

LEAF_NAMES = {
    "Bootstrap API": "Khởi tạo khung API backend",
    "Env validation": "Thiết lập và kiểm tra cấu hình môi trường",
    "Health/readiness endpoint": "Tạo endpoint kiểm tra health và readiness",
    "Prisma baseline": "Thiết lập Prisma và cấu hình dữ liệu nền",
    "User/role schema": "Thiết kế schema người dùng và vai trò",
    "Room schema": "Thiết kế schema phòng",
    "Seed data": "Tạo dữ liệu mẫu 50 phòng",
    "Password service": "Xây dựng dịch vụ mã hóa mật khẩu",
    "Login endpoint": "Xây dựng API đăng nhập",
    "Auth middleware": "Xây dựng middleware xác thực",
    "RBAC guard": "Xây dựng guard phân quyền RBAC",
    "Room read APIs": "Xây dựng API đọc danh mục phòng",
    "Room write APIs": "Xây dựng API cập nhật phòng",
    "Socket foundation": "Thiết lập nền tảng Socket.IO realtime",
    "Backend quality gate": "Thiết lập quality gate cho backend",
    "Bootstrap Flutter": "Khởi tạo ứng dụng Flutter",
    "App shell/routing": "Thiết lập khung ứng dụng và điều hướng",
    "Token implementation": "Áp dụng design token vào giao diện",
    "Network client": "Xây dựng client gọi API",
    "Login UI": "Xây dựng giao diện đăng nhập",
    "Session persistence": "Lưu và khôi phục phiên đăng nhập",
    "Room catalog list": "Xây dựng danh sách phòng",
    "Room detail/form": "Xây dựng màn hình chi tiết và biểu mẫu phòng",
    "Realtime client": "Tích hợp client realtime",
    "Offline UI": "Xây dựng trạng thái giao diện khi mất kết nối",
    "S1 QA matrix": "Lập ma trận kiểm thử Sprint 1",
    "Check-in screen": "Xây dựng màn hình nhận phòng",
    "Check-out screen": "Xây dựng màn hình trả phòng",
    "My cleaning tasks mobile": "Xây dựng danh sách việc dọn phòng trên Android",
    "Cleaning task action UI": "Xây dựng thao tác xử lý việc dọn phòng",
    "Manager cleaning confirmation": "Xây dựng màn hình quản lý xác nhận dọn phòng",
    "Report maintenance UI": "Xây dựng giao diện báo hỏng",
    "Maintenance task mobile UI": "Xây dựng giao diện việc bảo trì trên Android",
    "Audit log web UI": "Xây dựng giao diện nhật ký audit trên Web",
    "Conflict/reconnect UX": "Thiết kế trải nghiệm xung đột và kết nối lại",
    "E2E and visual QA": "Thực hiện kiểm thử E2E và giao diện",
    "Dashboard aggregate query": "Xây dựng truy vấn tổng hợp dashboard",
    "Query/index profiling": "Đo và tối ưu truy vấn, chỉ mục",
    "Overdue rule/job": "Xây dựng quy tắc và job xử lý quá hạn",
    "Summary aggregate builder": "Xây dựng bộ tổng hợp dữ liệu AI summary",
    "OpenAI adapter": "Xây dựng adapter tích hợp OpenAI",
    "Quota/cost/timeout control": "Thiết lập giới hạn quota, chi phí và timeout",
    "Output validator/fallback": "Kiểm tra đầu ra AI và xây dựng fallback",
    "Persist/view latest summary": "Lưu và hiển thị AI summary mới nhất",
    "AI quality/security tests": "Kiểm thử chất lượng và bảo mật AI",
    "Dashboard layout": "Xây dựng bố cục dashboard",
    "Dashboard filters/details": "Xây dựng bộ lọc và chi tiết dashboard",
    "Realtime dashboard refresh": "Cập nhật dashboard theo thời gian thực",
    "Overdue presentation": "Hiển thị cảnh báo quá hạn trên dashboard",
    "AI summary screen": "Xây dựng màn hình AI summary",
    "AI error/fallback states": "Xây dựng trạng thái lỗi và fallback AI",
    "Cross-device polish": "Hoàn thiện giao diện đa thiết bị",
    "Reconciliation and AI QA": "Đối soát dữ liệu và kiểm thử AI",
    "Freeze scope và triage board": "Đóng băng phạm vi và lập bảng triage",
    "Security review": "Rà soát bảo mật",
    "CI workflow": "Thiết lập workflow CI",
    "Deploy/rollback runbook": "Viết runbook triển khai và rollback",
    "Acceptance script": "Viết kịch bản nghiệm thu",
    "Handover pack": "Chuẩn bị bộ hồ sơ bàn giao",
    "Fix blocker/critical backend defects": "Khắc phục lỗi blocker và lỗi nghiêm trọng backend",
    "Migration rehearsal": "Diễn tập migration cơ sở dữ liệu",
    "Backend test and load proof": "Chạy kiểm thử backend và chứng minh tải",
    "API smoke after deploy": "Chạy smoke test API sau triển khai",
    "Android release artifact": "Tạo artefact phát hành Android",
    "Full role regression": "Chạy regression test cho toàn bộ vai trò",
    "Responsive/browser QA": "Kiểm thử responsive và trình duyệt",
    "Accessibility quick pass": "Rà soát accessibility",
    "Visual regression/design token audit": "Chạy visual regression và audit design token",
    "UAT rehearsal": "Diễn tập UAT",
}


def value(node, name, default=""):
    child = node.find(f"m:{name}", NS)
    return child.text.strip() if child is not None and child.text else default


def as_bool(value):
    return value in {"1", "true", "True"}


def duration_minutes(iso_duration):
    days = hours = minutes = 0
    day_match = re.search(r"(\d+)D", iso_duration)
    hour_match = re.search(r"(\d+)H", iso_duration)
    minute_match = re.search(r"(\d+)M", iso_duration)
    if day_match:
        days = int(day_match.group(1))
    if hour_match:
        hours = int(hour_match.group(1))
    if minute_match:
        minutes = int(minute_match.group(1))
    return days * 480 + hours * 60 + minutes


def extract_deliverable(notes):
    notes = re.sub(r"\s+", " ", notes or "").strip()
    match = re.search(r"Đầu ra:\s*(.*?)(?=\s+Bằng chứng:|$)", notes, re.IGNORECASE)
    return match.group(1).strip() if match else ""


def proposed_name(name, is_summary, is_milestone):
    if name in SUMMARY_NAMES:
        return SUMMARY_NAMES[name]
    if name in LEAF_NAMES:
        return LEAF_NAMES[name]
    if is_milestone:
        return name if name.startswith("Milestone:") else f"Milestone: {name}"
    return name


root = ET.parse(SOURCE_XML).getroot()
resource_names = {
    value(resource, "UID"): value(resource, "Name")
    for resource in root.findall("m:Resources/m:Resource", NS)
}
task_resources = {}
for assignment in root.findall("m:Assignments/m:Assignment", NS):
    task_uid = value(assignment, "TaskUID")
    resource_uid = value(assignment, "ResourceUID")
    resource = resource_names.get(resource_uid)
    if task_uid and resource:
        task_resources.setdefault(task_uid, []).append(resource)

rows = []
for task in root.findall("m:Tasks/m:Task", NS):
    uid = value(task, "UID")
    duration = duration_minutes(value(task, "Duration"))
    is_summary = as_bool(value(task, "Summary"))
    is_milestone = as_bool(value(task, "Milestone"))
    original_name = value(task, "Name")
    predecessors = []
    for link in task.findall("m:PredecessorLink", NS):
        predecessor = value(link, "PredecessorUID")
        relation = value(link, "Type", "1")
        if predecessor:
            predecessors.append(f"UID {predecessor} (Type {relation})")

    if is_summary:
        task_type = "Tổng hợp"
        proposed_days = None
        mpp_duration = "Tự tính từ task con"
        schedule_action = "Tự tính lại từ task con"
    elif is_milestone:
        task_type = "Milestone"
        proposed_days = 0
        mpp_duration = "0 days"
        schedule_action = "Giữ mốc ngày"
    else:
        task_type = "Task"
        proposed_days = max(1, math.ceil(duration / 480))
        mpp_duration = f"{proposed_days} day" if proposed_days == 1 else f"{proposed_days} days"
        schedule_action = "Tính lại Start/Finish theo dependency"

    rows.append(
        {
            "wbs": value(task, "OutlineNumber"),
            "uid": uid,
            "level": int(value(task, "OutlineLevel", "1")),
            "type": task_type,
            "current_name": original_name,
            "proposed_name": proposed_name(original_name, is_summary, is_milestone),
            "deliverable": extract_deliverable(value(task, "Notes")),
            "resources": ", ".join(dict.fromkeys(task_resources.get(uid, []))),
            "original_hours": duration / 60,
            "proposed_days": proposed_days,
            "mpp_duration": mpp_duration,
            "start": value(task, "Start"),
            "finish": value(task, "Finish"),
            "predecessors": ", ".join(predecessors),
            "schedule_action": schedule_action,
        }
    )

uid_to_wbs = {row["uid"]: row["wbs"] for row in rows}
for row in rows:
    row["predecessors"] = re.sub(
        r"UID (\d+)",
        lambda match: f"WBS {uid_to_wbs.get(match.group(1), match.group(1))}",
        row["predecessors"],
    )

project_minutes_per_day = int(value(root, "MinutesPerDay", "480"))
payload = {
    "source": str(SOURCE_XML),
    "project": {
        "name": value(root, "Name"),
        "title": value(root, "Title"),
        "start": value(root, "StartDate"),
        "finish": value(root, "FinishDate"),
        "minutes_per_day": project_minutes_per_day,
        "scheduled_duration_days": 41.88,
    },
    "rows": rows,
}
OUTPUT_JSON.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"{len(rows)} rows written to {OUTPUT_JSON}")
