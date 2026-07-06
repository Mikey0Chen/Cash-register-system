FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

FROM nginx:alpine

# 复制构建产物到 Nginx 默认目录
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 Nginx 配置到 vhost 目录（容器内标准位置）
COPY cash-register-frontend.conf /etc/nginx/conf.d/cash-register-frontend.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
