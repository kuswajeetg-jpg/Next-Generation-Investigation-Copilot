@echo off
title PoliceMind AI Launcher
echo =====================================================================
echo             PoliceMind AI - Investigation Copilot Launcher
echo =====================================================================
echo.
echo [+] [1/2] Launching FastAPI Python Server in a new window...
start "PoliceMind AI Backend" cmd /k "cd backend && venv\Scripts\python -m uvicorn app.main:app --host 0.0.0.0 --port 8000"

echo.
echo [+] [2/2] Resolving Flutter client dependencies...
cd frontend
call flutter pub get

echo.
echo [+] Starting Flutter Application...
call flutter run
pause
