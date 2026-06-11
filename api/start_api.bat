@echo off
chcp 65001 >nul

cd /d "%~dp0"

set POSTGRES_URI_CORE=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_core
set POSTGRES_URI_TRACING=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_tracing
set SUPERTOKENS_URI_CORE=http://localhost:3567
set AGENTA_LICENSE=oss
set AGENTA_AUTH_KEY=agenta-local-dev-auth-key-2024
set AGENTA_CRYPT_KEY=agenta-local-dev-crypt-key-2024
set AGENTA_WEB_URL=http://localhost:3000
set AGENTA_API_URL=http://localhost:8000
set AGENTA_SERVICES_URL=http://localhost:8080
set REDIS_URI=redis://localhost:6379/0
set REDIS_URI_DURABLE=redis://localhost:6381/0
set REDIS_URI_VOLATILE=redis://localhost:6379/0
set ALEMBIC_CFG_PATH_CORE=%~dp0oss\databases\postgres\migrations\core\alembic.ini
set ALEMBIC_CFG_PATH_TRACING=%~dp0oss\databases\postgres\migrations\tracing\alembic.ini

echo Starting Agenta API...
uv run python -m uvicorn entrypoints.routers:app --host 0.0.0.0 --port 8000 --reload