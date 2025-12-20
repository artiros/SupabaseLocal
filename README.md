# Supabase Self-Hosted on Synology NAS

Self-hosted Supabase deployment for the TriathlonHelper project, running on Docker.

## Quick Start

### Deploy to NAS

```powershell
.\deploy-nas.ps1
```

### Access URLs (after deployment)

| Service | URL |
|---------|-----|
| **API Gateway** | http://192.168.50.212:8100 |
| **Studio Dashboard** | http://192.168.50.212:8100 |
| **PostgreSQL** | postgresql://postgres@192.168.50.212:5432/postgres |
| **Connection Pooler** | postgresql://postgres@192.168.50.212:6543/postgres |

### Dashboard Credentials

- **Username**: `supabase`
- **Password**: See `.env` file (`DASHBOARD_PASSWORD`)

## Configuration

All configuration is in the `.env` file. Key settings:

| Variable | Description | Default |
|----------|-------------|---------|
| `KONG_HTTP_PORT` | API Gateway port | 8100 |
| `POSTGRES_PASSWORD` | Database password | (set in .env) |
| `JWT_SECRET` | JWT signing secret | (set in .env) |
| `ANON_KEY` | Public API key | (set in .env) |
| `SERVICE_ROLE_KEY` | Service role API key | (set in .env) |

## Services (Lightweight - 8 containers)

- **Studio** - Admin dashboard
- **Kong** - API gateway
- **Auth (GoTrue)** - Authentication
- **REST (PostgREST)** - RESTful API
- **Storage** - File storage
- **imgproxy** - Image transformations
- **Meta** - Database management
- **Database (PostgreSQL 15)** - Primary database

## Migrating from Supabase Cloud

1. Export data from cloud:
   ```bash
   supabase db dump --linked > cloud_backup.sql
   ```

2. Import to self-hosted:
   ```bash
   psql -h 192.168.50.212 -p 5432 -U postgres -d postgres < cloud_backup.sql
   ```

## Troubleshooting

### View logs
```bash
ssh Artiros@192.168.50.212
cd /volume2/docker/supabase
sudo docker-compose logs -f
```

### Restart all services
```bash
sudo docker-compose restart
```

### Reset database (DANGER: deletes all data)
```bash
sudo docker-compose down -v
sudo rm -rf volumes/db/data
sudo docker-compose up -d
```
