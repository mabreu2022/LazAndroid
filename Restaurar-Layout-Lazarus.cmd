@echo off
title Restaurador de Layout Docado - Lazarus
setlocal EnableDelayedExpansion

cd /d "%~dp0"

echo =======================================================================
echo          Restaurador de Layout Docado para IDE Lazarus
echo =======================================================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\scripts\Restaurar-Layout-Lazarus.ps1"

echo.
echo =======================================================================
echo  Pressione qualquer tecla para fechar esta janela...
echo =======================================================================
pause >nul
