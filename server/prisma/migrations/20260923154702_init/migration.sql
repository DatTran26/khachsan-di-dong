-- CreateEnum
CREATE TYPE "role" AS ENUM ('MANAGER', 'RECEPTIONIST', 'STAFF');

-- CreateEnum
CREATE TYPE "account_status" AS ENUM ('PENDING_ACTIVATION', 'ACTIVE', 'LOCKED');

-- CreateEnum
CREATE TYPE "occupancy_status" AS ENUM ('VACANT', 'OCCUPIED');

-- CreateEnum
CREATE TYPE "cleaning_status" AS ENUM ('DIRTY', 'CLEANING', 'PENDING_INSPECTION', 'CLEAN');

-- CreateEnum
CREATE TYPE "service_status" AS ENUM ('IN_SERVICE', 'OUT_OF_SERVICE');

-- CreateEnum
CREATE TYPE "stay_status" AS ENUM ('OPEN', 'CLOSED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "housekeeping_task_status" AS ENUM ('UNASSIGNED', 'ASSIGNED', 'IN_PROGRESS', 'PENDING_CONFIRM', 'DONE');

-- CreateEnum
CREATE TYPE "maintenance_task_status" AS ENUM ('OPEN', 'IN_PROGRESS', 'DONE', 'CANCELLED');

-- CreateEnum
CREATE TYPE "audit_entity_type" AS ENUM ('ROOM', 'ROOM_TYPE', 'STAY', 'HOUSEKEEPING_TASK', 'MAINTENANCE_TASK', 'OUT_OF_SERVICE_HOLD', 'USER', 'AI_SUMMARY');

-- CreateEnum
CREATE TYPE "summary_period" AS ENUM ('CURRENT_SHIFT', 'PREVIOUS_SHIFT', 'TODAY');

-- CreateEnum
CREATE TYPE "summary_source" AS ENUM ('AI', 'FALLBACK');

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "phone" VARCHAR(10) NOT NULL,
    "full_name" TEXT NOT NULL,
    "role" "role" NOT NULL,
    "status" "account_status" NOT NULL DEFAULT 'PENDING_ACTIVATION',
    "password_hash" TEXT NOT NULL,
    "must_change_password" BOOLEAN NOT NULL DEFAULT true,
    "failed_login_count" INTEGER NOT NULL DEFAULT 0,
    "on_duty" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sessions" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "device_info" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expires_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "room_types" (
    "id" UUID NOT NULL,
    "name" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "room_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rooms" (
    "id" UUID NOT NULL,
    "number" TEXT NOT NULL,
    "floor" INTEGER NOT NULL,
    "room_type_id" UUID NOT NULL,
    "occupancy" "occupancy_status" NOT NULL DEFAULT 'VACANT',
    "cleaning" "cleaning_status" NOT NULL DEFAULT 'CLEAN',
    "service" "service_status" NOT NULL DEFAULT 'IN_SERVICE',
    "version" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "rooms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stays" (
    "id" UUID NOT NULL,
    "room_id" UUID NOT NULL,
    "guest_name" TEXT NOT NULL,
    "guest_count" INTEGER NOT NULL DEFAULT 1,
    "status" "stay_status" NOT NULL DEFAULT 'OPEN',
    "checked_in_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "checked_out_at" TIMESTAMPTZ,
    "expected_checkout" TIMESTAMPTZ,
    "note" VARCHAR(500),
    "checked_in_by_id" UUID NOT NULL,
    "checked_out_by_id" UUID,
    "version" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "stays_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "housekeeping_tasks" (
    "id" UUID NOT NULL,
    "room_id" UUID NOT NULL,
    "stay_id" UUID,
    "assignee_id" UUID,
    "status" "housekeeping_task_status" NOT NULL DEFAULT 'UNASSIGNED',
    "return_note" TEXT,
    "due_at" TIMESTAMPTZ NOT NULL,
    "overdue_flagged_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "started_at" TIMESTAMPTZ,
    "completed_at" TIMESTAMPTZ,
    "confirmed_at" TIMESTAMPTZ,
    "confirmed_by_id" UUID,
    "version" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "housekeeping_tasks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "maintenance_tasks" (
    "id" UUID NOT NULL,
    "room_id" UUID NOT NULL,
    "description" TEXT NOT NULL,
    "location" TEXT,
    "status" "maintenance_task_status" NOT NULL DEFAULT 'OPEN',
    "reporter_id" UUID NOT NULL,
    "assignee_id" UUID,
    "cancel_reason" TEXT,
    "due_at" TIMESTAMPTZ,
    "overdue_flagged_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,
    "version" INTEGER NOT NULL DEFAULT 1,

    CONSTRAINT "maintenance_tasks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "out_of_service_holds" (
    "id" UUID NOT NULL,
    "room_id" UUID NOT NULL,
    "reason" TEXT NOT NULL,
    "placed_by_id" UUID NOT NULL,
    "placed_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "lifted_by_id" UUID,
    "lifted_at" TIMESTAMPTZ,

    CONSTRAINT "out_of_service_holds_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "occurred_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "actor_id" UUID,
    "actor_role" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "entity_type" "audit_entity_type" NOT NULL,
    "entity_id" TEXT NOT NULL,
    "entity_label" TEXT,
    "room_id" UUID,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_log_changes" (
    "id" UUID NOT NULL,
    "audit_log_id" UUID NOT NULL,
    "field" TEXT NOT NULL,
    "before" TEXT,
    "after" TEXT,
    "position" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "audit_log_changes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_summaries" (
    "id" UUID NOT NULL,
    "period" "summary_period" NOT NULL,
    "data_as_of" TIMESTAMPTZ NOT NULL,
    "source" "summary_source" NOT NULL,
    "overview" TEXT NOT NULL,
    "highlights" TEXT NOT NULL,
    "attention" TEXT NOT NULL,
    "metrics" JSONB NOT NULL,
    "created_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ai_summaries_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ai_quotas" (
    "day" DATE NOT NULL,
    "used" INTEGER NOT NULL DEFAULT 0,
    "limit" INTEGER NOT NULL,
    "cost_vnd" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "ai_quotas_pkey" PRIMARY KEY ("day")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_user_id_key" ON "sessions"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "room_types_name_key" ON "room_types"("name");

-- CreateIndex
CREATE UNIQUE INDEX "rooms_number_key" ON "rooms"("number");

-- CreateIndex
CREATE INDEX "rooms_floor_idx" ON "rooms"("floor");

-- CreateIndex
CREATE INDEX "stays_room_id_status_idx" ON "stays"("room_id", "status");

-- CreateIndex
CREATE INDEX "housekeeping_tasks_status_due_at_idx" ON "housekeeping_tasks"("status", "due_at");

-- CreateIndex
CREATE INDEX "housekeeping_tasks_assignee_id_status_idx" ON "housekeeping_tasks"("assignee_id", "status");

-- CreateIndex
CREATE INDEX "maintenance_tasks_status_idx" ON "maintenance_tasks"("status");

-- CreateIndex
CREATE INDEX "maintenance_tasks_room_id_status_idx" ON "maintenance_tasks"("room_id", "status");

-- CreateIndex
CREATE INDEX "out_of_service_holds_room_id_idx" ON "out_of_service_holds"("room_id");

-- CreateIndex
CREATE INDEX "audit_logs_room_id_occurred_at_idx" ON "audit_logs"("room_id", "occurred_at");

-- CreateIndex
CREATE INDEX "audit_logs_occurred_at_idx" ON "audit_logs"("occurred_at");

-- CreateIndex
CREATE INDEX "audit_logs_actor_id_occurred_at_idx" ON "audit_logs"("actor_id", "occurred_at");

-- CreateIndex
CREATE INDEX "audit_log_changes_audit_log_id_idx" ON "audit_log_changes"("audit_log_id");

-- CreateIndex
CREATE INDEX "ai_summaries_created_at_idx" ON "ai_summaries"("created_at");

-- AddForeignKey
ALTER TABLE "sessions" ADD CONSTRAINT "sessions_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rooms" ADD CONSTRAINT "rooms_room_type_id_fkey" FOREIGN KEY ("room_type_id") REFERENCES "room_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stays" ADD CONSTRAINT "stays_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stays" ADD CONSTRAINT "stays_checked_in_by_id_fkey" FOREIGN KEY ("checked_in_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stays" ADD CONSTRAINT "stays_checked_out_by_id_fkey" FOREIGN KEY ("checked_out_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "housekeeping_tasks" ADD CONSTRAINT "housekeeping_tasks_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "housekeeping_tasks" ADD CONSTRAINT "housekeeping_tasks_stay_id_fkey" FOREIGN KEY ("stay_id") REFERENCES "stays"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "housekeeping_tasks" ADD CONSTRAINT "housekeeping_tasks_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "housekeeping_tasks" ADD CONSTRAINT "housekeeping_tasks_confirmed_by_id_fkey" FOREIGN KEY ("confirmed_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "maintenance_tasks" ADD CONSTRAINT "maintenance_tasks_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "maintenance_tasks" ADD CONSTRAINT "maintenance_tasks_reporter_id_fkey" FOREIGN KEY ("reporter_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "maintenance_tasks" ADD CONSTRAINT "maintenance_tasks_assignee_id_fkey" FOREIGN KEY ("assignee_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "out_of_service_holds" ADD CONSTRAINT "out_of_service_holds_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "out_of_service_holds" ADD CONSTRAINT "out_of_service_holds_placed_by_id_fkey" FOREIGN KEY ("placed_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "out_of_service_holds" ADD CONSTRAINT "out_of_service_holds_lifted_by_id_fkey" FOREIGN KEY ("lifted_by_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_log_changes" ADD CONSTRAINT "audit_log_changes_audit_log_id_fkey" FOREIGN KEY ("audit_log_id") REFERENCES "audit_logs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ai_summaries" ADD CONSTRAINT "ai_summaries_created_by_id_fkey" FOREIGN KEY ("created_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- =====================================================================
-- Ràng buộc viết tay (Prisma schema chưa diễn tả được) — xem docs/_shared/database-design.md
-- =====================================================================

-- CHECK dữ liệu cơ bản
ALTER TABLE "rooms" ADD CONSTRAINT "rooms_floor_positive" CHECK ("floor" > 0);
ALTER TABLE "stays" ADD CONSTRAINT "stays_guest_count_positive" CHECK ("guest_count" > 0);

-- Mỗi phòng tối đa 1 lượt lưu trú đang mở
CREATE UNIQUE INDEX "stays_one_open_per_room" ON "stays"("room_id") WHERE "status" = 'OPEN';

-- Mỗi phòng tối đa 1 lần "ngừng phục vụ tay" đang đặt
CREATE UNIQUE INDEX "out_of_service_holds_one_active_per_room" ON "out_of_service_holds"("room_id") WHERE "lifted_at" IS NULL;

-- Chống ghi đè ở tầng CSDL: MỌI lệnh UPDATE đều tăng version đúng 1 đơn vị,
-- kể cả khi code quên dùng updateWithVersion() → client cầm version cũ luôn bị từ chối.
CREATE FUNCTION "bump_version"() RETURNS trigger AS $$
BEGIN
  NEW."version" := OLD."version" + 1;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "rooms_bump_version" BEFORE UPDATE ON "rooms"
  FOR EACH ROW EXECUTE FUNCTION "bump_version"();
CREATE TRIGGER "stays_bump_version" BEFORE UPDATE ON "stays"
  FOR EACH ROW EXECUTE FUNCTION "bump_version"();
CREATE TRIGGER "housekeeping_tasks_bump_version" BEFORE UPDATE ON "housekeeping_tasks"
  FOR EACH ROW EXECUTE FUNCTION "bump_version"();
CREATE TRIGGER "maintenance_tasks_bump_version" BEFORE UPDATE ON "maintenance_tasks"
  FOR EACH ROW EXECUTE FUNCTION "bump_version"();

-- Nhật ký chỉ được thêm, không sửa/xóa (audit-log: bất biến)
CREATE FUNCTION "forbid_audit_mutation"() RETURNS trigger AS $$
BEGIN
  RAISE EXCEPTION 'Nhật ký chỉ được thêm mới, không được sửa hoặc xóa (%).', TG_TABLE_NAME;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER "audit_logs_append_only" BEFORE UPDATE OR DELETE ON "audit_logs"
  FOR EACH ROW EXECUTE FUNCTION "forbid_audit_mutation"();
CREATE TRIGGER "audit_log_changes_append_only" BEFORE UPDATE OR DELETE ON "audit_log_changes"
  FOR EACH ROW EXECUTE FUNCTION "forbid_audit_mutation"();
