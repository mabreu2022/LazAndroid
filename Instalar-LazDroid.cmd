@echo off
title Instalador LazDroid-Deploy para Lazarus
setlocal EnableDelayedExpansion

:: Verifica privilegios de Administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [LazDroid] Solicitando privilegios de Administrador (UAC)...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\" %*' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"

:: Se o usuario passar argumento --cli, roda versao texto PowerShell
if "%~1"=="--cli" goto RUN_CLI

:: Se o executavel do assistente visual existir, abre o assistente nativo LCL
if exist "%~dp0Instalar-LazDroid.exe" (
    echo [LazDroid] Iniciando Assistente Visual LazDroid...
    start "" "%~dp0Instalar-LazDroid.exe"
    exit /b 0
)

:RUN_CLI
echo =======================================================================
echo          LazDroid-Deploy — Instalador & Configurador Lazarus
echo =======================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\installer\install.ps1" %*

echo.
echo =======================================================================
echo  Pressione qualquer tecla para fechar esta janela...
echo =======================================================================
pause >nul
