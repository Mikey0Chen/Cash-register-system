# Cash Register System

面向酒吧场景的收银与库存管理系统，包含 Vue 3 前端和 Spring Boot 后端。

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

## Run Without Docker

Prerequisites:

- Java 11+
- Maven 3.8+
- Node.js 20+
- MySQL 8
- Redis 6+

Prepare local environment:

```bash
cp scripts/local.env.example scripts/local.env
```

Update `scripts/local.env` with your local MySQL, Redis, and JWT settings.

Start backend in one terminal:

```bash
./scripts/start-backend-local.sh
```

Start frontend in another terminal:

```bash
./scripts/start-frontend-local.sh
```

Default local addresses:

- Frontend: `http://localhost:5173`
- Backend: `http://localhost:8080`

## Build Without Docker

Build backend jar and frontend static files:

```bash
./scripts/build-release.sh
```

Run the packaged backend:

```bash
./scripts/start-backend-jar.sh
```

Artifacts:

- Backend jar: `backend/target/cash-register-backend.jar`
- Frontend dist: `frontend/dist`

## Run With Docker

```bash
cp .env.example .env
docker compose up -d
```

Frontend: `http://localhost`  
Backend: `http://localhost:8080`

## Deploy On A Server

Prerequisites:

- Java 11+
- Maven 3.8+
- Node.js 20+
- Nginx
- MySQL 8
- Redis 6+

Build after pulling code:

```bash
./scripts/build-release.sh
```

Publish frontend files for Nginx:

```bash
sudo mkdir -p /var/www/cash-register-system
sudo rsync -av --delete frontend/dist/ /var/www/cash-register-system/current/
```

Backend artifact:

```text
backend/target/cash-register-backend.jar
```

Frontend artifact:

```text
frontend/dist
```

Recommended server layout:

```text
/srv/cash-register-system/
├── backend/
└── frontend/

/var/www/cash-register-system/
└── current/
```

Nginx:

- Copy `deploy/nginx/cash-register.conf` to `/etc/nginx/conf.d/cash-register.conf`
- Update `root` if you use a different web directory
- Validate and reload:

```bash
sudo nginx -t
sudo systemctl reload nginx
```

Backend service:

- Copy `deploy/systemd/cash-register-backend.service` to `/etc/systemd/system/`
- Copy `deploy/env/cash-register.env.example` to `/etc/cash-register-system/cash-register.env`
- Fill in database, Redis, and JWT values
- Start with:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now cash-register-backend
sudo systemctl status cash-register-backend
```

Detailed RHEL-compatible deployment guide:

- `deploy/DEPLOY_RHEL.md`
