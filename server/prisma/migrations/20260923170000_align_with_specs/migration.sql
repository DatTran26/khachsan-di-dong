-- AlterTable
ALTER TABLE "audit_log_changes" ADD COLUMN     "entity_id" TEXT,
ADD COLUMN     "entity_label" TEXT,
ADD COLUMN     "entity_type" "audit_entity_type";

-- AlterTable
ALTER TABLE "housekeeping_tasks" ADD COLUMN     "assigned_at" TIMESTAMPTZ,
ALTER COLUMN "return_note" SET DATA TYPE VARCHAR(500);

-- AlterTable
ALTER TABLE "maintenance_tasks" ALTER COLUMN "description" SET DATA TYPE VARCHAR(500),
ALTER COLUMN "location" SET DATA TYPE VARCHAR(100),
ALTER COLUMN "cancel_reason" SET DATA TYPE VARCHAR(200);

-- AlterTable
ALTER TABLE "out_of_service_holds" ALTER COLUMN "reason" SET DATA TYPE VARCHAR(200);

-- CreateIndex
CREATE UNIQUE INDEX "housekeeping_tasks_stay_id_key" ON "housekeeping_tasks"("stay_id");

