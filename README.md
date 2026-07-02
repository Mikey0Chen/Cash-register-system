# Cocktail Bar System

鸡尾酒酒吧收银与库存管理系统，包含 Vue 3 前端和 Spring Boot 后端。

## Stack

- Frontend: Vue 3, Vite, Element Plus
- Backend: Spring Boot, MyBatis-Plus, MySQL, Redis
- Deploy: Docker, Docker Compose, Nginx

## Structure

```text
backend/               Spring Boot API
frontend/              Vue application
database/              MySQL schema and seed data
docker/                Nginx config
docker-compose.yml     Local deployment
```

## Run

```bash
cp .env.example .env
docker compose up -d
```

Frontend: `http://localhost`  
Backend: `http://localhost:8080`
