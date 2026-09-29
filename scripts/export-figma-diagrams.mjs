// Export each diagram frame on the Figma "Flow-Act-Sqe" page to PNG
// via the Reqwise bridge POST /rpc (leader on localhost:38470).
// Usage: node scripts/export-figma-diagrams.mjs [outDir]
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const leaderFile = join(tmpdir(), "reqwise-figma-mcp", "leader-38470.json");
const { port, token } = JSON.parse(readFileSync(leaderFile, "utf8"));
const outDir = resolve(process.argv[2] || "docs/assets/figma");
mkdirSync(outDir, { recursive: true });

const JOBS = [
  ["17:8557", "usecase-khachsandidong.png"],
  ["17:8610", "usecase-auth-roles.png"],
  ["17:8643", "userflow-auth-roles.png"],
  ["17:8728", "state-auth-roles-taikhoannhanvien.png"],
  ["17:8757", "state-auth-roles-phiendangnhap.png"],
  ["17:8780", "erd-auth-roles.png"],
  ["17:9228", "usecase-check-in-out.png"],
  ["17:9269", "userflow-check-in-out.png"],
  ["17:9374", "state-check-in-out-luotluutru.png"],
  ["17:9395", "state-phong-trucluutru.png"],
  ["17:9415", "erd-check-in-out.png"],
  ["17:9541", "sequence-check-in-out-nhanphong.png"],
  ["17:9607", "sequence-check-in-out-traphong.png"],
  ["17:9651", "usecase-housekeeping.png"],
  ["17:9711", "userflow-housekeeping.png"],
  ["17:9822", "state-housekeeping-viecdonphong.png"],
  ["17:9872", "state-phong-trucvesinh.png"],
  ["17:9904", "erd-housekeeping.png"],
  ["17:10093", "activity-housekeeping.png"],
  ["17:10228", "sequence-auth-roles.png"],
  ["17:10283", "usecase-room-dashboard.png"],
  ["17:10323", "userflow-room-dashboard.png"],
  ["17:10379", "state-room-dashboard-phienxemdashboard.png"],
  ["17:10420", "erd-room-dashboard.png"],
  ["17:10891", "usecase-audit-log.png"],
  ["17:10927", "userflow-audit-log.png"],
  ["17:10994", "erd-audit-log.png"],
  ["17:11125", "sequence-audit-log.png"],
  ["17:11454", "usecase-room-catalog.png"],
  ["17:11501", "usecase-ai-ops-summary.png"],
  ["17:11532", "userflow-ai-ops-summary.png"],
  ["17:11626", "state-ai-ops-summary-bantomtatky.png"],
  ["17:11666", "state-ai-ops-summary-hanmucai.png"],
  ["17:11686", "sequence-ai-ops-summary.png"],
  ["17:11772", "erd-ai-ops-summary.png"],
  ["17:12041", "userflow-room-catalog.png"],
  ["17:12151", "state-phong-trucbaotri.png"],
  ["17:12168", "state-room-catalog-loaiphong.png"],
  ["17:12185", "erd-room-catalog.png"],
  ["17:12317", "sitemap-khachsandidong.png"],
  ["17:12846", "usecase-maintenance.png"],
  ["17:12898", "userflow-maintenance.png"],
  ["17:13006", "state-maintenance-viecbaotri.png"],
  ["17:13032", "state-maintenance-trucbaotriphong.png"],
  ["17:13053", "erd-maintenance.png"],
  ["17:13313", "activity-maintenance.png"],
  ["17:13464", "usecase-realtime-sync.png"],
  ["17:13503", "sequence-realtime-sync-lantruyen.png"],
  ["17:13536", "sequence-realtime-sync-xungdot.png"],
  ["17:13565", "sequence-realtime-sync-reconnect.png"],
  ["17:13612", "state-realtime-sync-ketnoithietbi.png"],
  ["17:13637", "state-realtime-sync-ghidoituong.png"],
  ["17:13663", "erd-realtime-sync.png"],
  ["17:13805", "userflow-realtime-sync.png"],
];

let okCount = 0;
const fails = [];
for (const [nodeId, file] of JOBS) {
  const res = await fetch(`http://localhost:${port}/rpc`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      op: "export_node",
      params: { nodeId, format: "png", scale: 2 },
    }),
  });
  const json = await res.json();
  if (json.ok && json.result?.base64) {
    writeFileSync(join(outDir, file), Buffer.from(json.result.base64, "base64"));
    okCount++;
    console.log(`OK  ${file}`);
  } else {
    fails.push({ nodeId, file, error: json.error || json });
    console.log(`ERR ${file} :: ${JSON.stringify(json.error || json).slice(0, 200)}`);
  }
}
console.log(`\nDone: ${okCount}/${JOBS.length} -> ${outDir}`);
if (fails.length) process.exitCode = 1;
