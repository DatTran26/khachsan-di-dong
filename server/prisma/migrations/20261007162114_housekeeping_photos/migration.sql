-- CreateEnum
CREATE TYPE "housekeeping_photo_category" AS ENUM ('OVERVIEW', 'BED', 'BATHROOM', 'CLOSEUP');

-- AlterTable
ALTER TABLE "housekeeping_tasks" ADD COLUMN     "has_issue" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "photo_round" INTEGER NOT NULL DEFAULT 1;

-- CreateTable
CREATE TABLE "housekeeping_photos" (
    "id" UUID NOT NULL,
    "task_id" UUID NOT NULL,
    "round" INTEGER NOT NULL,
    "category" "housekeeping_photo_category" NOT NULL,
    "storage_key" TEXT NOT NULL,
    "mime_type" VARCHAR(20) NOT NULL,
    "size_bytes" INTEGER NOT NULL,
    "uploaded_by_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "housekeeping_photos_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "housekeeping_photos_storage_key_key" ON "housekeeping_photos"("storage_key");

-- CreateIndex
CREATE INDEX "housekeeping_photos_task_id_round_idx" ON "housekeeping_photos"("task_id", "round");

-- AddForeignKey
ALTER TABLE "housekeeping_photos" ADD CONSTRAINT "housekeeping_photos_task_id_fkey" FOREIGN KEY ("task_id") REFERENCES "housekeeping_tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "housekeeping_photos" ADD CONSTRAINT "housekeeping_photos_uploaded_by_id_fkey" FOREIGN KEY ("uploaded_by_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
