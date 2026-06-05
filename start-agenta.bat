@echo off
chcp 65001 >nul
echo ==============================================
echo          Agenta Local Development Environment
echo ==============================================
echo.

setlocal enabledelayedexpansion

echo 1. Starting Docker infrastructure...
pushd "%~dp0hosting\docker-compose\oss"
set COMPOSE_PROJECT_NAME=agenta-v101
docker compose -f docker-compose.infrastructure.yml --env-file .env.oss.dev up -d

if !errorlevel! neq 0 (
    echo Error: Failed to start Docker infrastructure
    pause
    popd
    exit /b 1
)

echo    Docker infrastructure started successfully!
popd
echo.

echo 2. Waiting for database services to be ready...
timeout /t 10 /nobreak >nul

echo 3. Running database migrations...
pushd "%~dp0api"
set POSTGRES_URI_CORE=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_core
set POSTGRES_URI_TRACING=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_tracing
set SUPERTOKENS_URI_CORE=http://localhost:3567
set AGENTA_LICENSE=oss
set AGENTA_AUTH_KEY=agenta-local-dev-auth-key-2024
set AGENTA_CRYPT_KEY=agenta-local-dev-crypt-key-2024
set ALEMBIC_CFG_PATH_CORE=oss/databases/postgres/migrations/core/alembic.ini
set ALEMBIC_CFG_PATH_TRACING=oss/databases/postgres/migrations/tracing/alembic.ini

uv run python -m oss.databases.postgres.migrations.runner

if !errorlevel! neq 0 (
    echo Warning: Database migration may have issues
) else (
    echo    Database migration completed successfully!
)
popd
echo.

echo 4. Starting Backend API Service...
pushd "%~dp0api"
start "Agenta API" "%~dp0start-api.bat"
popd
echo    Backend API Service started (port 8000)...
echo.

echo 5. Starting Frontend Web Service...
pushd "%~dp0web\oss"
start "Agenta Web" cmd /k "pnpm dev"
popd
echo    Frontend Web Service started (port 3000)...
echo.

echo 6. Starting Services (Chat API)...
pushd "%~dp0services"
start "Agenta Services" "%~dp0start-services.bat"
popd
echo    Services started (port 8080)...
echo.

echo ==============================================
echo              Services started successfully!
echo ==============================================
echo.
echo Access URLs:
echo   - Frontend: http://localhost:3000
echo   - API Docs: http://localhost:8000/docs
echo.
echo Press any key to exit...
pause >nul