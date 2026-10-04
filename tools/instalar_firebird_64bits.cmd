@echo off
setlocal
echo ========================================================
echo     INSTALANDO FIREBIRD 5.0 (64 BITS) NO SISTEMA
echo ========================================================

echo [1/4] Parando servico do Firebird 32 bits...
net stop FirebirdServerDefaultInstance >nul 2>&1
taskkill /F /IM firebird.exe >nul 2>&1

echo [2/4] Desinstalando versao 32 bits...
if exist "C:\Program Files (x86)\Firebird\Firebird_5_0\unins000.exe" (
    "C:\Program Files (x86)\Firebird\Firebird_5_0\unins000.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
    timeout /t 3 /nobreak >nul
)

echo [3/4] Instalando Firebird 5.0 64 bits...
"%USERPROFILE%\Downloads\Firebird-5.0.4-x64.exe" /SP- /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
timeout /t 5 /nobreak >nul

echo [4/4] Configurando bibliotecas de cliente 64 bits (System32)...
if exist "C:\Program Files\Firebird\Firebird_5_0\fbclient.dll" (
    copy /Y "C:\Program Files\Firebird\Firebird_5_0\fbclient.dll" "%WINDIR%\System32\fbclient.dll" >nul
    copy /Y "C:\Program Files\Firebird\Firebird_5_0\fbclient.dll" "%WINDIR%\System32\gds32.dll" >nul
    echo Bibliotecas copiadas com sucesso para System32.
)

net start FirebirdServerDefaultInstance >nul 2>&1
echo ========================================================
echo     INSTALACAO DO FIREBIRD 64 BITS CONCLUIDA!
echo ========================================================
exit /b 0
