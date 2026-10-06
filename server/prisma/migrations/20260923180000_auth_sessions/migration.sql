-- AlterTable
ALTER TABLE "sessions" ADD COLUMN     "token_hash" CHAR(64) NOT NULL;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "version" INTEGER NOT NULL DEFAULT 1;

-- CreateIndex
CREATE UNIQUE INDEX "sessions_token_hash_key" ON "sessions"("token_hash");


-- Tài khoản cũng chống ghi đè như phòng/việc: mọi UPDATE tăng version.
CREATE TRIGGER "users_bump_version" BEFORE UPDATE ON "users"
  FOR EACH ROW EXECUTE FUNCTION "bump_version"();
