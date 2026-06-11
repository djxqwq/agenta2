@echo off
chcp 65001 >nul

set "ROOT=%~dp0"
set "ROOT=%ROOT:~0,-1%"

echo ==============================================
echo     Agenta Local Dev Environment
echo ==============================================
echo.

REM ---- 1. Docker ----
echo [1/5] Docker infrastructure...
cd /d "%ROOT%\hosting\docker-compose\oss"
docker compose -f docker-compose.infrastructure.yml up -d
if %errorlevel% neq 0 (
    echo [ERROR] Docker failed. Is Docker Desktop running?
    pause
    exit /b 1
)
echo        OK. Waiting for DB...
timeout /t 10 /nobreak >nul
echo.

REM ---- 2. Migrations ----
echo [2/5] Database migration...
cd /d "%ROOT%\api"
set POSTGRES_URI_CORE=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_core
set POSTGRES_URI_TRACING=postgresql+asyncpg://username:password@localhost:5432/agenta_oss_tracing
set SUPERTOKENS_URI_CORE=http://localhost:3567
set AGENTA_LICENSE=oss
set AGENTA_AUTH_KEY=agenta-local-dev-auth-key-2024
set AGENTA_CRYPT_KEY=agenta-local-dev-crypt-key-2024
set ALEMBIC_CFG_PATH_CORE=%ROOT%\api\oss\databases\postgres\migrations\core\alembic.ini
set ALEMBIC_CFG_PATH_TRACING=%ROOT%\api\oss\databases\postgres\migrations\tracing\alembic.ini
uv run python -m oss.databases.postgres.migrations.runner
echo.

REM ---- 3. API (8000) ----
echo [3/5] API (port 8000)...
start "Agenta API" powershell -File "%ROOT%\api\start_api.ps1"

REM ---- 4. Services (8080) ----
echo [4/5] Services (port 8080)...
start "Agenta Services" powershell -File "%ROOT%\services\start_services.ps1"

REM ---- 5. Frontend (3000) ----
echo [5/5] Frontend (port 3000)...
start "Agenta Web" powershell -File "%ROOT%\web\oss\start_web.ps1"

echo.
echo ==============================================
echo   All services launched!
echo   Frontend : http://localhost:3000
echo   API Docs : http://localhost:8000/docs
echo   Services : http://localhost:8080/docs
echo ==============================================
pause