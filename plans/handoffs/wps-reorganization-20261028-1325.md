---
handoff-version: 1
generated: 2026-10-28T13:25:00+07:00
generator: ak:handoff@2.1.0
focus: "Create a valid WPS/MS Project daily schedule from 08/09/2026 to 27/10/2026"
workspace: D:/Projects/KhachSanDiDong
branch: develop-dat
head: 2ddc10e7c451302fb37bec10da93d7c58418a4f9
---

# HANDOFF: WPS daily schedule reorganization

## Mission and current status

Focus: "Create a valid WPS/MS Project daily schedule from 08/09/2026 to 27/10/2026".

Done:

- Confirmed the user wants `Task Name` to contain only the work, never the person's name.
- Confirmed the schedule boundary is 08/09/2026 through 27/10/2026.
- Established the WPS display contract: Task Name, Duration, Start, Finish, Predecessors, Resource Names, Work, WBS Ref, Reviewer and Expected Output.
- Audited the existing WBS review workbook: 202 rows, including 178 leaf tasks; owners are Bảo (63), Đạt (61) and Hoàng (54).
- Proved that mechanically converting every hourly leaf task to a one-day task is not a valid calendar schedule.

Remaining:

- Obtain approval for the resource rebalance required to fit the fixed dates.
- Build the final daily-package XLSX after that approval.
- Have the user review Task Names and daily work packages before any `.mpp` edit.

Urgency: high because the requested end date is fixed.

## Scope and guardrails

Workspace: `D:/Projects/KhachSanDiDong`

In scope: reorganize the WPS/MS Project schedule and produce a review XLSX for the 08/09/2026–27/10/2026 window.

Out of scope: editing `KhachSanSach.mpp`, changing code, marking work Done, altering GitHub PRs/Issues, or changing the project period.

Constraints: Task Name has no person name. Resource Names is the authoritative owner field. Duration is an integer number of working days; milestone is `0 days`; summary rows calculate from children. The plan must show what each person does on each working day.

Safety boundaries: do not silently reassign ownership. Do not import the temporary draft workbook into WPS/MS Project. Do not treat merge, CI or a calendar date as completion evidence.

## Current state

Branch: `develop-dat`

HEAD: `2ddc10e7c451302fb37bec10da93d7c58418a4f9`

Working tree: dirty.

Changed files:

- `.github/ISSUE_TEMPLATE/task.yml`
- `.github/pull_request_template.md`

Untracked files:

- `.codex-temp/` including the schedule-analysis helper
- `outputs/` including WBS review, evidence registers and the non-importable schedule draft
- `plans/261027-1654-pr-wbs-evidence-management/`
- `plans/handoffs/`

Intentional local modifications: yes. Preserve all existing changes; no work has been committed in this handoff scope.

## Decisions and rationale

- Use two levels of planning — WPS has daily work packages; the WBS/evidence register keeps all 178 detailed IDs. This preserves traceability without turning each 1–4 hour activity into an artificial full-day calendar task.
- Keep names out of Task Name — user explicitly requested this. Put Đạt, Bảo or Hoàng only in Resource Names.
- Keep Work in hours beside Duration in days — Duration answers calendar planning; Work and Resource Units keep capacity and cost calculations honest.
- Use `1 day` for a daily work package and `0 days` for a milestone — this satisfies the integer-duration requirement without inflating each original microtask.
- Keep same-day sequencing inside the daily package Notes/WBS Ref — using Finish-to-Start between all original microtasks would make the plan end on 23/11/2026.
- Do not reuse the existing generated draft as an import source — its resource-levelled calculation reaches 23/11/2026, so it violates the agreed period.

## Work performed

- Read `outputs/wbs-review-261027/khach-san-di-dong-wbs-task-name-review.xlsx` and confirmed its `WBS Review` sheet has 178 leaf tasks and a 08/09/2026–27/10/2026 source range.
- Inspected the detailed WBS source and the Phase 2 normalization plan.
- Created `.codex-temp/create_wps_reorganization_draft.py` to test integer-day conversion, WPS predecessor conversion and resource-leveling.
- Ran the prototype twice. The first run reported 23 overloaded day/owner pairs. A resource-levelled run removed overload but extended completion to 23/11/2026; an earlier strict predecessor run extended it to 28/01/2027.
- Calculated capacity by sprint and owner. Sprint 1 has the blocking imbalance: Đạt has 174 hours in 10 workdays (80-hour capacity), while Bảo has 37 hours and Hoàng has 67 hours of spare Sprint 1 capacity.

0 redactions applied.

## Verification

| Check | Command or evidence | Outcome | When |
| --- | --- | --- | --- |
| WBS source count | pandas read of `WBS Review` sheet | 202 rows: 178 Task, 19 Summary and 5 Milestone | 2026-10-28 |
| Owner coverage | pandas value count | Bảo 63, Đạt 61 and Hoàng 54 leaf tasks | 2026-10-28 |
| Original date boundary | pandas min/max on leaf dates | 08/09/2026 to 27/10/2026 | 2026-10-28 |
| Integer-day conversion | `create_wps_reorganization_draft.py` | All converted task durations are whole days, but strict scheduling ends 23/11/2026 | 2026-10-28 |
| Capacity check | sprint/owner work-hour aggregation | Sprint 1 Đạt requires 174h vs 80h capacity; no compliant schedule exists with unchanged ownership | 2026-10-28 |

Not run:

- No final XLSX was created because doing so before owner rebalance approval would produce a misleading schedule.
- No `.mpp` import or edit was attempted.
- No resource-cost calculation was updated; the user has not approved the final allocation.

## Open risks and blockers

- Type: blocker. Owner: user. Impact: retaining the current Sprint 1 ownership makes the fixed 08/09–27/10 dates impossible. At least 94 hours must move off Đạt in Sprint 1, or the dates/scope/capacity must change.
- Type: question. Owner: user. Impact: approve or reject the proposed rebalance below before finalizing Resource Names.
- Type: risk. Owner: successor. Impact: the temporary `outputs/wps-reorganization-261028/khach-san-di-dong-wps-task-name-draft.xlsx` is diagnostic only and ends after the agreed period; importing it would publish an invalid plan.

## Exact next actions

1. **First safe step** — obtain explicit approval for the proposed Sprint 1 rebalance, or obtain a different approved capacity/scope decision. Do not edit `.mpp` first.
2. If approved, assign these 57 Sprint 1 hours from Đạt to Hoàng: `1.2.2.3` (36h), `1.2.2.6` (8h), `1.2.1.3–1.2.1.6` (8h), `1.2.1.12` (3h) and `1.2.1.14` (2h). They align with UI/UX, wireframe, design-token and research work.
3. If approved, assign these 37 Sprint 1 hours from Đạt to Bảo: `1.2.2.2` (32h), `1.2.3.2` (1h), `1.2.3.3` (2h) and `1.2.3.4` (2h). They align with technical specification, architecture, API contract and shared enum work.
4. Resolve Sprint 2's 3-hour backend excess by user-approved reassignment, additional approved capacity, or a scope change. Do not silently assign a backend migration/API task to a non-backend owner.
5. Create daily packages from the 178 WBS rows: pack only compatible same-owner work into a package of at most 8 Work hours; use `1 day` Duration; retain every covered WBS ID in `WBS Ref` and Notes.
6. Build a new file, not an overwrite of the diagnostic draft: `outputs/wps-reorganization-261028/khach-san-di-dong-wps-daily-package-review.xlsx`. Include `Hướng dẫn`, `WPS Gantt Draft`, `Lịch theo ngày`, `Kiểm tra tải` and `WBS Mapping` sheets.
7. Schedule each package inside its Sprint boundary: S1 08/09–21/09, S2 22/09–05/10, S3 06/10–19/10 and S4 20/10–27/10. Summary rows have no owner and auto-roll-up Duration; milestones are 0 days.
8. Validate 178 unique WBS references, zero day/owner loads above 8h, first leaf Start 08/09/2026, last leaf Finish no later than 27/10/2026, and no formula errors. Render and inspect the Gantt and daily sheets before user review.
9. Give the XLSX to the user for Task Name and Resource Names review. Only after written approval may the user copy it to WPS/MS Project or request an `.mpp` update.

## Source pointers

- `outputs/wbs-review-261027/khach-san-di-dong-wbs-task-name-review.xlsx`
- `outputs/wps-reorganization-261028/khach-san-di-dong-wps-task-name-draft.xlsx` — diagnostic only; do not import
- `.codex-temp/create_wps_reorganization_draft.py`
- `plans/260923-1658-four-sprint-mvp-backlog/detailed-task-breakdown.md`
- `plans/260923-1658-four-sprint-mvp-backlog/Ke-hoach-KhachSanDiDong-MSProject-2021.xml`
- `plans/261027-1654-pr-wbs-evidence-management/phase-02-normalize-wbs-and-evidence.md`
- `plans/handoffs/pr-wbs-management-20261028-0255.md`
