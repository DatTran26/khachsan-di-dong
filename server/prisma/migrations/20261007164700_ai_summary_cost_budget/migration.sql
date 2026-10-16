-- ai-ops-summary: hạn mức theo CHI PHÍ thực tế (tổng 300.000 VNĐ cho MVP) thay cho đếm lượt/ngày; lưu mỗi lượt tạo.
-- ai_summaries / ai_quotas chưa từng có code ghi dữ liệu trước migration này → đổi kiểu cột/xóa bảng không mất dữ liệu.
/*
  Warnings:

  - You are about to drop the `ai_quotas` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `period_end` to the `ai_summaries` table without a default value. This is not possible if the table is not empty.
  - Added the required column `period_start` to the `ai_summaries` table without a default value. This is not possible if the table is not empty.
  - Changed the type of `highlights` on the `ai_summaries` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.
  - Changed the type of `attention` on the `ai_summaries` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- CreateEnum
CREATE TYPE "summary_failure" AS ENUM ('NOT_CONFIGURED', 'QUOTA_EXCEEDED', 'TIMEOUT', 'AI_ERROR', 'INVALID_OUTPUT');

-- AlterEnum
ALTER TYPE "summary_source" ADD VALUE 'EMPTY';

-- AlterTable
ALTER TABLE "ai_summaries" ADD COLUMN     "called_ai" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "cost_vnd" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "failure_reason" "summary_failure",
ADD COLUMN     "model" VARCHAR(60),
ADD COLUMN     "period_end" TIMESTAMPTZ NOT NULL,
ADD COLUMN     "period_start" TIMESTAMPTZ NOT NULL,
DROP COLUMN "highlights",
ADD COLUMN     "highlights" JSONB NOT NULL,
DROP COLUMN "attention",
ADD COLUMN     "attention" JSONB NOT NULL;

-- DropTable
DROP TABLE "ai_quotas";

-- CreateIndex
CREATE INDEX "ai_summaries_period_created_at_idx" ON "ai_summaries"("period", "created_at");
