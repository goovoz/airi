# 第一阶段：构建阶段
FROM node:20-slim AS builder
WORKDIR /app

# 启用 pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# 先复制依赖文件，利用 Docker 缓存
COPY pnpm-lock.yaml* package.json ./
RUN pnpm install --frozen-lockfile

# 复制源码并构建
COPY . .
RUN pnpm run build

# 第二阶段：运行阶段
FROM node:20-slim
WORKDIR /app

# 只安装生产环境必要的运行工具（如果项目需要）
RUN corepack enable && corepack prepare pnpm@latest --activate

# 从构建阶段复制构建后的产物 (假设产物在 dist 目录)
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

# 暴露端口
EXPOSE 5173

# 启动命令 (Vite 项目通常使用 preview 来预览构建后的网页)
# 注意：一定要加上 --host 0.0.0.0 才能在容器外访问
CMD ["pnpm", "run", "preview", "--host", "0.0.0.0", "--port", "5173"]
