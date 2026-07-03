# Deploy On RHEL-Compatible Servers

This guide targets RHEL / Rocky Linux / AlmaLinux / CentOS Stream servers with `systemd` and `nginx`.

## 1. Requirements

Project requirements:

- Java 11+
- Maven 3.8+
- Node.js 18+
- Nginx
- MySQL 8
- Redis 6+

The backend uses Spring Boot `2.7.18` and the project `pom.xml` targets Java 11.

## 2. Prepare Directories

```bash
sudo useradd --system --create-home --home-dir /srv/cash-register-system cashregister
sudo mkdir -p /srv/cash-register-system
sudo mkdir -p /var/www/cash-register-system/current
sudo mkdir -p /etc/cash-register-system
sudo chown -R cashregister:cashregister /srv/cash-register-system
sudo chown -R nginx:nginx /var/www/cash-register-system
```

## 3. Pull Code

```bash
cd /srv/cash-register-system
sudo -u cashregister git clone git@github.com:Mikey0Chen/Cash-register-system.git .
```

If the directory already contains the project:

```bash
cd /srv/cash-register-system
sudo -u cashregister git pull --ff-only
```

## 4. Build Locally On The Server

```bash
cd /srv/cash-register-system
sudo -u cashregister ./scripts/build-release.sh
```

Build output:

- Backend jar: `/srv/cash-register-system/backend/target/cash-register-backend.jar`
- Frontend dist: `/srv/cash-register-system/frontend/dist`

## 5. Publish Frontend To Nginx

```bash
sudo rsync -av --delete /srv/cash-register-system/frontend/dist/ /var/www/cash-register-system/current/
sudo chown -R nginx:nginx /var/www/cash-register-system/current
```

## 6. Configure Backend Environment

```bash
sudo cp /srv/cash-register-system/deploy/env/cash-register.env.example /etc/cash-register-system/cash-register.env
sudo chmod 640 /etc/cash-register-system/cash-register.env
```

Edit `/etc/cash-register-system/cash-register.env` and set:

- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `REDIS_HOST`
- `REDIS_PORT`
- `REDIS_PASSWORD`
- `JWT_SECRET`

Example:

```bash
sudo vi /etc/cash-register-system/cash-register.env
```

## 7. Install systemd Service

```bash
sudo cp /srv/cash-register-system/deploy/systemd/cash-register-backend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cash-register-backend
sudo systemctl status cash-register-backend
```

Useful checks:

```bash
sudo journalctl -u cash-register-backend -f
curl http://127.0.0.1:8080/actuator/health
```

## 8. Install Nginx Site

```bash
sudo cp /srv/cash-register-system/deploy/nginx/cash-register.conf /etc/nginx/conf.d/cash-register.conf
sudo nginx -t
sudo systemctl reload nginx
```

The default Nginx config serves:

- frontend static files from `/var/www/cash-register-system/current`
- API traffic from `/api/*` to `http://127.0.0.1:8080/*`

If you want a domain name, edit `server_name` in `/etc/nginx/conf.d/cash-register.conf`.

## 9. Update Procedure

```bash
cd /srv/cash-register-system
sudo -u cashregister git pull --ff-only
sudo -u cashregister ./scripts/build-release.sh
sudo rsync -av --delete /srv/cash-register-system/frontend/dist/ /var/www/cash-register-system/current/
sudo systemctl restart cash-register-backend
sudo nginx -t && sudo systemctl reload nginx
```

## 10. Notes

- The frontend sends requests to `/api`, and Nginx removes that prefix before proxying to Spring Boot.
- The backend listens on `127.0.0.1:8080` through the local host network path exposed by the service.
- Keep `/etc/cash-register-system/cash-register.env` out of Git.
