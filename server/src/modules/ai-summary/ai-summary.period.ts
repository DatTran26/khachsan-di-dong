import type { SummaryPeriod } from '@prisma/client';

/**
 * Kỳ tóm tắt theo giờ Việt Nam (UTC+7, không đổi giờ mùa hè).
 * Ca cố định 06:00–14:00, 14:00–22:00, 22:00–06:00 (ai-ops-summary spec mục 11 — Assumptions).
 * Chỉ có 3 lựa chọn, đều kết thúc ≤ T → không thể chọn kỳ tương lai (FR-ai-ops-summary-001).
 */
const VN_OFFSET_MS = 7 * 3_600_000;
const HOUR_MS = 3_600_000;
const SHIFT_STARTS = [22, 14, 6] as const;

export interface PeriodRange {
  period: SummaryPeriod;
  start: Date;
  end: Date;
  label: string; // vd "Ca 06:00–14:00 ngày 07/10"
}

const pad = (n: number) => String(n).padStart(2, '0');

/** Giờ/ngày/tháng theo giờ VN của một mốc. */
export function vnParts(date: Date) {
  const local = new Date(date.getTime() + VN_OFFSET_MS);
  return { hour: local.getUTCHours(), minute: local.getUTCMinutes(), day: local.getUTCDate(), month: local.getUTCMonth() + 1 };
}

/** "14:32 07/10" theo giờ VN. */
export function formatVnTime(date: Date) {
  const p = vnParts(date);
  return `${pad(p.hour)}:${pad(p.minute)} ${pad(p.day)}/${pad(p.month)}`;
}

/** 00:00 giờ VN của ngày chứa `date`. */
function vnMidnight(date: Date) {
  const local = new Date(date.getTime() + VN_OFFSET_MS);
  return new Date(Date.UTC(local.getUTCFullYear(), local.getUTCMonth(), local.getUTCDate()) - VN_OFFSET_MS);
}

/** Đầu ca đang chạy tại `now`. */
function currentShiftStart(now: Date) {
  const midnight = vnMidnight(now);
  const hour = vnParts(now).hour;
  const startHour = SHIFT_STARTS.find((h) => hour >= h);
  // 00:00–05:59 thuộc ca 22:00 của hôm trước.
  return new Date(midnight.getTime() + (startHour ?? -2) * HOUR_MS);
}

function shiftLabel(start: Date) {
  const s = vnParts(start);
  const endHour = (s.hour + 8) % 24;
  return `Ca ${pad(s.hour)}:00–${pad(endHour)}:00 ngày ${pad(s.day)}/${pad(s.month)}`;
}

/** Nhãn kỳ từ loại kỳ + mốc bắt đầu (dùng lại khi đọc bản đã lưu). */
export function periodLabel(period: SummaryPeriod, start: Date) {
  if (period !== 'TODAY') return shiftLabel(start);
  const p = vnParts(start);
  return `Hôm nay ${pad(p.day)}/${pad(p.month)}`;
}

export function resolvePeriod(period: SummaryPeriod, now: Date): PeriodRange {
  const current = currentShiftStart(now);
  const [start, end] =
    period === 'TODAY'
      ? [vnMidnight(now), now]
      : period === 'CURRENT_SHIFT'
        ? [current, now]
        : [new Date(current.getTime() - 8 * HOUR_MS), current];
  return { period, start, end, label: periodLabel(period, start) };
}
