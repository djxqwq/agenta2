cd $PSScriptRoot

$env:AGENTA_API_URL = "http://localhost:8000"
$env:AGENTA_WEB_URL = "http://localhost:3000"

Write-Host "Starting Agenta Services..."
uv run python -m uvicorn entrypoints.main:app --host 0.0.0.0 --port 8080 --reload