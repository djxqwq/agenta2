@echo off
chcp 65001 >nul

cd /d "%~dp0"

echo Starting Agenta Web...
pnpm dev