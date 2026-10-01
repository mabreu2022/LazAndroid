@echo off
title Instalador LazDroid-Deploy para Lazarus
setlocal EnableDelayedExpansion

:: Verifica privilegios de Administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [LazDroid] Solicitando privilegios de Administrador...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

echo =======================================================================
echo          LazDroid-Deploy — Instalador & Configurador Lazarus
echo =======================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\installer\install.ps1"

echo.
echo =======================================================================
echo  Pressione qualquer tecla para fechar esta janela...
echo =======================================================================
pause >nul
