@echo off
chcp 65001 >nul
set AGENTA_API_URL=http://localhost:8000
set AGENTA_WEB_URL=http://localhost:3000
uv run uvicorn entrypoints.main:app --host 0.0.0.0 --port 8080 --reload