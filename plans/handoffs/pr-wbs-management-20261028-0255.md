---
handoff-version: 1
generated: 2026-10-28T02:55:00+07:00
generator: ak:handoff@2.1.0
focus: "Continue PR, WBS and evidence management for KhachSanDiDong"
workspace: D:/Projects/KhachSanDiDong
branch: develop-dat
head: 2ddc10e7c451302fb37bec10da93d7c58418a4f9
---

# HANDOFF: PR, WBS and evidence management

## Mission and current status

Focus: "Continue PR, WBS and evidence management for KhachSanDiDong".

Done:

- Audited all 53 historical PRs and standardized their displayed task scope.
- Backfilled #1–#33 with an aggregate task name, evidence treatment and a clear WBS-link boundary.
- Retained the validated WBS Issue links on #34–#53.
- Created 178 canonical WBS Issues in GitHub Project #14 with fields, Kanban values and saved views.
- Exported the Phase 5 evidence register with a full `All PR Audit` sheet.

Remaining:

- Keep six duplicate Issues open and outside Project #14, as explicitly requested by the user.
- Use the new templates on the next real PR, then verify its WBS Issue, CI/evidence and acceptance flow.
- Decide whether to commit and push the local PR/Issue template changes.

Urgency: normal.

## Scope and guardrails

Workspace: `D:/Projects/KhachSanDiDong`

In scope: historical PR metadata, WBS Issue/Project evidence management, evidence register workbook and future PR/Issue templates.

Out of scope: rewriting commit history, changing merged PR branches or states, modifying the `.mpp` baseline, or marking WBS work as Done without evidence and acceptance.

Constraints: preserve Gitflow. Feature PRs target `develop`; only releases/hotfixes target `main`. Use Vietnamese for human-facing GitHub prose and English conventional-commit titles.

Safety boundaries: do not close Issues unless the user explicitly authorizes it. Do not infer a precise WBS Issue for legacy PRs with broad or mixed scope. Merge into `develop` is not completion.

## Current state

Branch: `develop-dat`

HEAD: `2ddc10e7c451302fb37bec10da93d7c58418a4f9`

Working tree: dirty.

Changed files:

- `.github/ISSUE_TEMPLATE/task.yml`
- `.github/pull_request_template.md`

Untracked files:

- `.codex-temp/`
- `outputs/`
- `plans/261027-1654-pr-wbs-evidence-management/`
- `plans/handoffs/pr-wbs-management-20261028-0255.md`

Intentional local modifications: yes. The templates, plans, outputs and temporary audit artifacts belong to this WBS/PR management work. Do not discard unrelated changes.

## Decisions and rationale

- 178 task leaves each have one canonical GitHub Issue — required for task-level management and completion marking.
- `WBS ID` is immutable — it remains the join key across MS Project, Issues, Project #14 and the evidence register.
- #1–#33 use aggregate task names — their broad historical scope does not prove a one-to-one WBS mapping.
- #34–#53 retain canonical WBS Issue links — their earlier audit found concrete candidate mappings and updated PR bodies.
- Only `Acceptance` evidence can lead to Done — code, CI and merge remain delivery evidence.
- Đạt is the acceptance owner for UI and operational work — this was chosen by the user.
- Six duplicate Issues (#74, #80, #87, #94, #95 and #96) remain open — the user explicitly decided they do not need to be closed.

## Work performed

- Fetched all PRs #1–#53 with title, body, files, commits, branch and state evidence.
- Updated title/body metadata of PRs #1–#33 with task names that match their aggregate delivery scope.
- Re-fetched all 53 PRs. Title/body checks passed and base branch, head branch and state matched the pre-edit snapshot.
- Created Project #14 custom fields: WBS ID, Sprint, Workstream, Evidence level, Acceptance type and Last verified.
- Added 178 canonical WBS Issues to Project #14 and populated Project fields. Current values are 32 Review/In review, 146 Triage/Backlog and zero Done.
- Created saved views: By Sprint, By Workstream, By Owner, Needs evidence, Blocked and Done awaiting acceptance.
- Extended `.github/pull_request_template.md` and `.github/ISSUE_TEMPLATE/task.yml` with WBS, evidence, reviewer and acceptance requirements.
- Built `outputs/evidence-register-261028-phase5/khach-san-di-dong-evidence-register.xlsx`.

0 redactions applied.

## Verification

| Check | Command or evidence | Outcome | When |
| --- | --- | --- | --- |
| PR metadata | `.codex-temp/verify-all-pr-task-backfill.py` | 53 checked; 33 new aggregate records and 20 existing WBS-link records; no failures | 2026-10-28 |
| Project data | `gh project item-list 14 --owner DatTran26 --limit 500 --format json` | 178 cards, 178 unique WBS IDs, 32 Review, 146 Triage, zero Done | 2026-10-28 |
| Workbook | Artifact-tool inspection, formula-error scan and rendered sheets | Workbook exported; no formula errors found | 2026-10-28 |
| Issue template | Ruby YAML parse of `.github/ISSUE_TEMPLATE/task.yml` | Parsed; 10 required form fields found | 2026-10-28 |
| Template diff | `git diff --check` | Passed; only line-ending warnings reported | 2026-10-28 |

Not run:

- No real follow-up PR was created because a dummy PR would create misleading delivery history.
- No end-to-end application test was run because this work changed GitHub metadata, templates and planning artifacts only.

## Open risks and blockers

- Type: accepted risk. Owner: project owner. Impact: six duplicate Issues (#74, #80, #87, #94, #95 and #96) remain open outside Project #14 by explicit user decision; do not close or re-add them without a new instruction.
- Type: risk. Owner: acceptance owner. Impact: 32 Review cards have delivery evidence but no acceptance evidence; they must not move to Done yet.
- Type: question. Owner: user. Impact: local template changes are not committed or pushed; decide whether to include them in the next focused PR.
- Type: risk. Owner: next maintainer. Impact: `plans/261027-1654-pr-wbs-evidence-management/plan.md` still declares the overall plan and five phase links as Pending although this handoff records completed Phase 2–4 work; reconcile plan status from evidence before reporting progress.

## Exact next actions

1. **First safe step** — read this handoff and re-run `git status --short`, then inspect Project #14 item counts before changing any GitHub state.
2. Reconcile the plan and phase status against this handoff before marking any phase complete.
3. When real feature work is ready, create a PR using `.github/pull_request_template.md`, link one or more WBS Issues, run the required checks and keep the Project card in Review until acceptance evidence is recorded.
4. If approved, commit the two template files separately from temporary outputs and planning artifacts.

## Source pointers

- `outputs/evidence-register-261028-phase5/khach-san-di-dong-evidence-register.xlsx`
- `.github/pull_request_template.md`
- `.github/ISSUE_TEMPLATE/task.yml`
- `plans/261027-1654-pr-wbs-evidence-management/plan.md`
- `plans/261027-1654-pr-wbs-evidence-management/phase-03-backfill-historical-prs.md`
- `https://github.com/users/DatTran26/projects/14`
- `https://github.com/DatTran26/khachsan-di-dong/pulls`
