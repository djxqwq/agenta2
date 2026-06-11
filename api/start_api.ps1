cd $PSScriptRoot

$env:POSTGRES_URI_CORE = "postgresql+asyncpg://username:password@localhost:5432/agenta_oss_core"
$env:POSTGRES_URI_TRACING = "postgresql+asyncpg://username:password@localhost:5432/agenta_oss_tracing"
$env:SUPERTOKENS_URI_CORE = "http://localhost:3567"
$env:AGENTA_LICENSE = "oss"
$env:AGENTA_AUTH_KEY = "agenta-local-dev-auth-key-2024"
$env:AGENTA_CRYPT_KEY = "agenta-local-dev-crypt-key-2024"
$env:AGENTA_WEB_URL = "http://localhost:3000"
$env:AGENTA_API_URL = "http://localhost:8000"
$env:AGENTA_SERVICES_URL = "http://localhost:8080"
$env:REDIS_URI = "redis://localhost:6379/0"
$env:REDIS_URI_DURABLE = "redis://localhost:6381/0"
$env:REDIS_URI_VOLATILE = "redis://localhost:6379/0"
$env:ALEMBIC_CFG_PATH_CORE = "$PSScriptRoot/oss/databases/postgres/migrations/core/alembic.ini"
$env:ALEMBIC_CFG_PATH_TRACING = "$PSScriptRoot/oss/databases/postgres/migrations/tracing/alembic.ini"

Write-Host "Starting Agenta API..."
uv run python -m uvicorn entrypoints.routers:app --host 0.0.0.0 --port 8000 --reload