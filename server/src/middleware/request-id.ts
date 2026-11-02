import { randomUUID } from 'node:crypto';
import type { NextFunction, Request, Response } from 'express';

// Chỉ nhận mã từ client khi gọn và an toàn để ghi log/nhật ký; còn lại tự sinh.
const SAFE_ID = /^[A-Za-z0-9_-]{8,64}$/;

/**
 * Gắn mã request cho mỗi lượt gọi (WBS 1.4.2.11): lấy `X-Request-Id` của client nếu hợp lệ, không thì tự sinh.
 * Trả lại trong header phản hồi để đối chiếu log máy chủ, nhật ký và màn hình khi điều tra một lượt cụ thể.
 */
export function requestId() {
  return (req: Request, res: Response, next: NextFunction) => {
    const incoming = req.get('X-Request-Id');
    const id = incoming && SAFE_ID.test(incoming) ? incoming : randomUUID();
    res.locals.requestId = id;
    res.setHeader('X-Request-Id', id);
    next();
  };
}

export function requestIdOf(res: Response): string {
  return res.locals.requestId as string;
}
