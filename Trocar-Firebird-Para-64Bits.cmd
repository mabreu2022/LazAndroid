@echo off
setlocal
title Instalador Firebird 5.0 (64-bits)

:: Verifica se esta executando como Administrador; se nao, solicita elevacao UAC
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando permissao de Administrador...
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo ================================================================
echo      MIGRACAO PARA FIREBIRD 5.0 (64 BITS)
echo ================================================================
echo.

echo [1/5] Parando servico ativo do Firebird 32 bits...
net stop FirebirdServerDefaultInstance >nul 2>&1
taskkill /F /IM firebird.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [2/5] Desinstalando versao anterior (32 bits)...
if exist "C:\Program Files (x86)\Firebird\Firebird_5_0\unins000.exe" (
    "C:\Program Files (x86)\Firebird\Firebird_5_0\unins000.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    timeout /t 4 /nobreak >nul
)

echo [3/5] Instalando Firebird 5.0 (64 bits) oficial...
"%USERPROFILE%\Downloads\Firebird-5.0.4-x64.exe" /SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
timeout /t 6 /nobreak >nul

echo [4/5] Copiando bibliotecas de cliente 64 bits para System32...
if exist "C:\Program Files\Firebird\Firebird_5_0\fbclient.dll" (
    copy /Y "C:\Program Files\Firebird\Firebird_5_0\fbclient.dll" "%WINDIR%\System32\fbclient.dll" >nul
    copy /Y "C:\Program Files\Firebird\Firebird_5_0\fbclient.dll" "%WINDIR%\System32\gds32.dll" >nul
    echo      fbclient.dll e gds32.dll (64 bits) configuradas no System32 com sucesso!
) else (
    echo      Aviso: Nao foi encontrada a DLL em C:\Program Files\Firebird\Firebird_5_0.
)

echo [5/5] Iniciando servico Firebird 64 bits...
net start FirebirdServerDefaultInstance >nul 2>&1

echo.
echo ================================================================
echo      FIREBIRD 5.0 (64 BITS) INSTALADO COM SUCESSO!
echo ================================================================
echo.
pause
