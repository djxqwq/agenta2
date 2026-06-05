@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo ==============================================
echo          Agenta Local Development Environment
echo          Project: %SCRIPT_DIR%
echo ==============================================
echo.

REM ---- 1. Docker ----
echo [1/5] Starting Docker infrastructure...
cd /d "%SCRIPT_DIR%\hosting\docker-compose\oss"
set COMPOSE_PROJECT_NAME=agenta-v101
docker compose -f docker-compose.infrastructure.yml --env-file .env.oss.dev up -d
if !errorlevel! neq 0 (
    echo [ERROR] Failed to start Docker infrastructure
    pause
    exit /b 1
)
echo        Docker infrastructure started successfully.
echo.

REM ---- 2. Wait for DB ----
echo [2/5] Waiting for database services (10s)...
timeout /t 10 /nobreak >nul
echo.

REM ---- 3. Migrations ----
echo [3/5] Running database migrations...
cd /d "%SCRIPT_DIR%\api"

set POSTGRES_URI_CORE=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_core
set POSTGRES_URI_TRACING=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_tracing
set SUPERTOKENS_URI_CORE=http://localhost:3567
set AGENTA_LICENSE=oss
set AGENTA_AUTH_KEY=agenta-local-dev-auth-key-2024
set AGENTA_CRYPT_KEY=agenta-local-dev-crypt-key-2024
set ALEMBIC_CFG_PATH_CORE=%SCRIPT_DIR%\api\oss\databases\postgres\migrations\core\alembic.ini
set ALEMBIC_CFG_PATH_TRACING=%SCRIPT_DIR%\api\oss\databases\postgres\migrations\tracing\alembic.ini

uv run python -m oss.databases.postgres.migrations.runner
if !errorlevel! neq 0 (
    echo [WARN] Database migration warnings (non-fatal)
) else (
    echo        Database migration completed.
)
echo.

REM ---- 4. API (port 8000) ----
echo [4/5] Starting API service (port 8000)...
start "Agenta API" cmd /k "cd /d "%SCRIPT_DIR%\api" && ^
set POSTGRES_URI_CORE=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_core && ^
set POSTGRES_URI_TRACING=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_tracing && ^
set SUPERTOKENS_URI_CORE=http://localhost:3567 && ^
set AGENTA_LICENSE=oss && ^
set AGENTA_AUTH_KEY=agenta-local-dev-auth-key-2024 && ^
set AGENTA_CRYPT_KEY=agenta-local-dev-crypt-key-2024 && ^
set AGENTA_WEB_URL=http://localhost:3000 && ^
set AGENTA_API_URL=http://localhost:8000 && ^
set AGENTA_SERVICES_URL=http://localhost:8080 && ^
set REDIS_URI=redis://localhost:6379/0 && ^
set REDIS_URI_DURABLE=redis://localhost:6381/0 && ^
set REDIS_URI_VOLATILE=redis://localhost:6379/0 && ^
set ALEMBIC_CFG_PATH_CORE=%SCRIPT_DIR%\api\oss\databases\postgres\migrations\core\alembic.ini && ^
set ALEMBIC_CFG_PATH_TRACING=%SCRIPT_DIR%\api\oss\databases\postgres\migrations\tracing\alembic.ini && ^
uv run python -m uvicorn entrypoints.routers:app --host 0.0.0.0 --port 8000 --reload"
echo        API service starting...
echo.

REM ---- 5. Services (port 8080) ----
echo [5/5] Starting Services (port 8080)...
start "Agenta Services" cmd /k "cd /d "%SCRIPT_DIR%\services" && ^
set AGENTA_API_URL=http://localhost:8000 && ^
set AGENTA_WEB_URL=http://localhost:3000 && ^
uv run python -m uvicorn entrypoints.main:app --host 0.0.0.0 --port 8080 --reload"
echo        Services starting...
echo.

REM ---- Frontend hint ----
echo ==============================================
echo   Backend services launched in new windows.
echo ==============================================
echo.
echo   To start the frontend, open a terminal and run:
echo     cd /d "%SCRIPT_DIR%\web\oss"
echo     pnpm dev
echo.
echo   Access URLs:
echo     - Frontend : http://localhost:3000
echo     - API Docs : http://localhost:8000/docs
echo     - Services : http://localhost:8080
echo.
echo ==============================================
pause
