# Backend KhachSanDiDong — image chạy trên VPS (tôn chỉ: Docker Compose + Nginx HTTPS).
# Build:  docker build -t khachsan-api ./server
# Chạy:   xem service "api" trong docker-compose.yml (profile "full")

# ---- build: cài đủ thư viện, sinh Prisma Client, biên dịch TypeScript ----
FROM node:22-bookworm-slim AS build
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*
COPY package.json package-lock.json ./
# postinstall chạy `prisma generate` → cần thư mục prisma trước khi cài thư viện
COPY prisma ./prisma
RUN npm ci
COPY tsconfig.json tsconfig.build.json ./
COPY src ./src
RUN npm run build

# ---- runtime: chỉ những gì cần để chạy ----
FROM node:22-bookworm-slim
WORKDIR /app
ENV NODE_ENV=production
RUN apt-get update && apt-get install -y --no-install-recommends openssl && rm -rf /var/lib/apt/lists/*
# Giữ node_modules của bước build (có Prisma CLI) để chạy `prisma migrate deploy` khi khởi động.
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY prisma ./prisma
COPY package.json ./
# Thư mục ảnh nghiệm thu (gắn volume) phải ghi được bởi user node.
RUN mkdir -p /app/uploads && chown node:node /app/uploads
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s \
  CMD node -e "fetch('http://localhost:'+(process.env.PORT||3000)+'/api/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
# Áp migration còn thiếu rồi mới mở server (an toàn khi chạy lại nhiều lần).
CMD ["sh", "-c", "npx prisma migrate deploy && node dist/server.js"]
