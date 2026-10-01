<#
.SYNOPSIS
    Instalador e Configurador Automatico do LazDroid-Deploy para Lazarus IDE.
.DESCRIPTION
    Configura a cadeia de ferramentas Free Pascal (cross-compilers e units RTL para Android AArch64 e ARMv7),
    aplica melhorias de suporte mobile na LCL CustomDrawn, compila as units LCL para Android,
    registra o pacote LazDroidDeploy.lpk na IDE e gera a configuracao XML com SDK/NDK/ADB/JDK.
#>

param(
    [string]$LazarusDir = "",
    [switch]$RebuildIDE = $false,
    [switch]$NonInteractive = $false
)

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Step, [string]$Title)
    Write-Host ""
    Write-Host "[$Step] $Title" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Text)
    Write-Host "  [OK] $Text" -ForegroundColor Green
}

function Write-Info {
    param([string]$Text)
    Write-Host "  [..] $Text" -ForegroundColor Gray
}

function Write-Warn {
    param([string]$Text)
    Write-Host "  [AVISO] $Text" -ForegroundColor DarkYellow
}

function Write-Err {
    param([string]$Text)
    Write-Host "  [ERRO] $Text" -ForegroundColor Red
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$RepoRoot = (Resolve-Path "$ScriptDir\..\..").Path
$ToolsDir = "$RepoRoot\tools"

Clear-Host
Write-Header "LazDroid-Deploy - Instalador e Configurador Automatico"
Write-Host "  Repositorio: $RepoRoot" -ForegroundColor DarkGray
Write-Host "  Data: $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor DarkGray

# -----------------------------------------------------------------------------
# 1. Localizacao do Lazarus IDE
# -----------------------------------------------------------------------------
Write-Step "1/7" "Localizando a instalacao do Lazarus IDE..."

if ([string]::IsNullOrWhiteSpace($LazarusDir)) {
    $Candidates = @(
        "C:\lazarus",
        "D:\lazarus",
        "${env:ProgramFiles}\lazarus",
        "${env:ProgramFiles(x86)}\lazarus"
    )
    foreach ($cand in $Candidates) {
        if (Test-Path "$cand\lazbuild.exe") {
            $LazarusDir = $cand
            break
        }
    }
}

if (-not (Test-Path "$LazarusDir\lazbuild.exe")) {
    Write-Err "O executavel lazbuild.exe nao foi localizado em '$LazarusDir'."
    Write-Host "Informe o caminho do diretorio onde o Lazarus esta instalado:" -ForegroundColor Yellow
    $UserInput = Read-Host "Caminho do Lazarus (ex: C:\lazarus)"
    if (Test-Path "$UserInput\lazbuild.exe") {
        $LazarusDir = $UserInput
    } else {
        throw "Diretorio invalido do Lazarus: $UserInput"
    }
}

Write-Success "Lazarus localizado em: $LazarusDir"

# Localiza pasta do FPC dentro do Lazarus
$FpcDir = ""
$FpcVer = ""
$FpcBase = "$LazarusDir\fpc"
if (Test-Path $FpcBase) {
    $SubDirs = Get-ChildItem -Path $FpcBase -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+' } | Sort-Object Name -Descending
    if ($SubDirs.Count -gt 0) {
        $FpcVer = $SubDirs[0].Name
        $FpcDir = $SubDirs[0].FullName
    }
}

if ([string]::IsNullOrWhiteSpace($FpcDir) -or -not (Test-Path $FpcDir)) {
    throw "Nao foi possivel identificar a versao do Free Pascal em '$FpcBase'."
}

Write-Success "Free Pascal detectado: versao $FpcVer em '$FpcDir'"

# -----------------------------------------------------------------------------
# 2. Extracao / Preparacao dos Arquivos do Cross-Compiler FPC
# -----------------------------------------------------------------------------
Write-Step "2/7" "Preparando compiladores cruzados e pacotes FPC para Android..."

$FpcExtracted = "$ToolsDir\fpc_extracted\app"
if (-not (Test-Path "$FpcExtracted\bin\i386-win32\ppcrossa64.exe")) {
    Write-Info "Base extraida nao encontrada. Extraindo instalador cruzado FPC Android..."
    $CrossInstaller = "$ToolsDir\fpc-3.2.2.i386-win32.cross.android.exe"
    $InnoExtract = "$ToolsDir\innoextract\innoextract.exe"

    if (-not (Test-Path $CrossInstaller)) {
        throw "Instalador $CrossInstaller nao encontrado!"
    }
    if (-not (Test-Path $InnoExtract)) {
        throw "Utilitario innoextract.exe nao encontrado em $InnoExtract!"
    }

    $OutExtract = "$ToolsDir\fpc_extracted"
    New-Item -ItemType Directory -Force -Path $OutExtract | Out-Null
    & "$InnoExtract" -s -e -d "$OutExtract" "$CrossInstaller"
    Write-Success "Instalador FPC extraido com sucesso em '$OutExtract'."
} else {
    Write-Success "Base FPC Android pronta em '$FpcExtracted'."
}

# -----------------------------------------------------------------------------
# 3. Instalacao de Binarios e Units FPC no Lazarus
# -----------------------------------------------------------------------------
Write-Step "3/7" "Copiando binarios e units da RTL para o Lazarus..."

# 3.1 Binarios (ppcrossa64.exe, ppcrossarm.exe e aliases)
$SourceBinDir = "$FpcExtracted\bin\i386-win32"
$DestBinDirs = @(
    "$FpcDir\bin\i386-win32",
    "$FpcDir\bin\x86_64-win64"
)

foreach ($dest in $DestBinDirs) {
    if (Test-Path $dest) {
        if (Test-Path "$SourceBinDir\ppcrossa64.exe") {
            Copy-Item -Force "$SourceBinDir\ppcrossa64.exe" "$dest\ppcrossa64.exe"
            Copy-Item -Force "$SourceBinDir\ppcrossa64.exe" "$dest\ppcrossaarch64.exe"
            Copy-Item -Force "$SourceBinDir\ppcrossa64.exe" "$dest\ppca64.exe"
            Copy-Item -Force "$SourceBinDir\ppcrossa64.exe" "$dest\ppcaarch64.exe"
        }
        if (Test-Path "$SourceBinDir\ppcrossarm.exe") {
            Copy-Item -Force "$SourceBinDir\ppcrossarm.exe" "$dest\ppcrossarm.exe"
            Copy-Item -Force "$SourceBinDir\ppcrossarm.exe" "$dest\ppcarm.exe"
        }
        Write-Success "Binarios do compilador cruzado instalados em '$dest'."
    }
}

# 3.2 Units (aarch64-android e arm-android)
$SourceUnitsDir = "$FpcExtracted\units"
$DestUnitsBase = "$FpcDir\units"

$Archs = @("aarch64-android", "arm-android")
foreach ($arch in $Archs) {
    $srcArch = "$SourceUnitsDir\$arch"
    $dstArch = "$DestUnitsBase\$arch"
    if (Test-Path $srcArch) {
        Write-Info "Copiando units FPC para $arch..."
        New-Item -ItemType Directory -Force -Path $dstArch | Out-Null
        Copy-Item -Recurse -Force "$srcArch\*" "$dstArch\"
        Write-Success "Units FPC para $arch instaladas em '$dstArch'."
    }
}

# -----------------------------------------------------------------------------
# 4. Patch Mobile na LCL CustomDrawn (Teclado Virtual e Foco)
# -----------------------------------------------------------------------------
Write-Step "4/7" "Aplicando suporte automatico a teclado virtual na LCL CustomDrawn..."

$CustomDrawnStdCtrls = "$LazarusDir\lcl\interfaces\customdrawn\customdrawnwsstdctrls.pas"
if (Test-Path $CustomDrawnStdCtrls) {
    $cdContent = [System.IO.File]::ReadAllText($CustomDrawnStdCtrls, [System.Text.Encoding]::UTF8)
    if (-not $cdContent.Contains("csRequiresKeyboardInput")) {
        $target = "Result := TCDWSWinControl.CreateHandle(AWinControl, AParams);"
        $replacement = "if Assigned(AWinControl) then`r`n    AWinControl.ControlStyle := AWinControl.ControlStyle + [csRequiresKeyboardInput];`r`n  Result := TCDWSWinControl.CreateHandle(AWinControl, AParams);"
        if ($cdContent.Contains($target)) {
            $newCdContent = $cdContent.Replace($target, $replacement)
            [System.IO.File]::WriteAllText($CustomDrawnStdCtrls, $newCdContent, [System.Text.Encoding]::UTF8)
            Write-Success "Patch aplicado: TEdit e TMemo configurados com csRequiresKeyboardInput."
        } else {
            Write-Warn "Assinatura de CreateHandle ja alterada ou nao encontrada."
        }
    } else {
        Write-Success "LCL CustomDrawn ja possui o patch csRequiresKeyboardInput ativo."
    }
} else {
    Write-Warn "Arquivo $CustomDrawnStdCtrls nao localizado."
}

# -----------------------------------------------------------------------------
# 5. Compilacao das Units da LCL CustomDrawn e LazDroidControls para Android AArch64
# -----------------------------------------------------------------------------
Write-Step "5/7" "Compilando pacotes LCL CustomDrawn e LazDroidControls para Android AArch64..."

$LclPkg = "$LazarusDir\lcl\interfaces\lcl.lpk"
if (Test-Path $LclPkg) {
    Write-Info "Executando lazbuild para aarch64-android (customdrawn)..."
    $BuildOutput = & "$LazarusDir\lazbuild.exe" --os=android --cpu=aarch64 --ws=customdrawn "$LclPkg" 2>&1
    $ExitCode = $LASTEXITCODE
    if ($ExitCode -eq 0) {
        Write-Success "LCL CustomDrawn compilada com sucesso para aarch64-android!"
    } else {
        Write-Warn "Aviso na compilacao da LCL (ExitCode $ExitCode):"
        Write-Host ($BuildOutput | Out-String) -ForegroundColor DarkGray
    }
} else {
    Write-Warn "Pacote $LclPkg nao localizado."
}

# Compila a paleta LazDroidControls para Android
$ControlsPkg = "$RepoRoot\package\LazDroidControls.lpk"
if (Test-Path $ControlsPkg) {
    Write-Info "Compilando paleta de componentes LazDroidControls para Android AArch64..."
    $CtrlOut = & "$LazarusDir\lazbuild.exe" --os=android --cpu=aarch64 --ws=customdrawn "$ControlsPkg" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "LazDroidControls compilado com sucesso para aarch64-android!"
    } else {
        Write-Warn "Aviso na compilacao do LazDroidControls para Android:"
        Write-Host ($CtrlOut | Out-String) -ForegroundColor DarkGray
    }
}

# -----------------------------------------------------------------------------
# 6. Registro dos Pacotes no Lazarus IDE
# -----------------------------------------------------------------------------
Write-Step "6/7" "Registrando pacotes LazDroidControls.lpk e LazDroidDeploy.lpk no Lazarus..."

if (Test-Path $ControlsPkg) {
    Write-Info "Registrando paleta de componentes LazDroidControls.lpk..."
    & "$LazarusDir\lazbuild.exe" --add-package-link "$ControlsPkg" | Out-Null
    & "$LazarusDir\lazbuild.exe" --add-package "$ControlsPkg" | Out-Null
    Write-Success "Paleta de componentes LazDroidControls.lpk registrada na IDE!"
}

$PkgPath = "$RepoRoot\package\LazDroidDeploy.lpk"
if (Test-Path $PkgPath) {
    Write-Info "Registrando plugin LazDroidDeploy.lpk..."
    & "$LazarusDir\lazbuild.exe" --add-package-link "$PkgPath" | Out-Null
    & "$LazarusDir\lazbuild.exe" --add-package "$PkgPath" | Out-Null
    Write-Success "Pacote LazDroidDeploy.lpk registrado com sucesso no Lazarus!"
} else {
    Write-Err "Pacote nao encontrado: $PkgPath"
}

# -----------------------------------------------------------------------------
# 7. Auto-Deteccao de Ferramentas e Gravacao do lazdroiddeploy.xml
# -----------------------------------------------------------------------------
Write-Step "7/7" "Autodetectando Android SDK, NDK, ADB, JDK e gravando configuracoes..."

$UserLocalApp = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::LocalApplicationData)
$LazConfigDir = "$UserLocalApp\lazarus"
New-Item -ItemType Directory -Force -Path $LazConfigDir | Out-Null
$CfgFile = "$LazConfigDir\lazdroiddeploy.xml"

# Busca SDK
$SdkRoot = ""
$SdkCandidates = @(
    "$UserLocalApp\Android\Sdk",
    "C:\Android\Sdk",
    "D:\Android\Sdk",
    "${env:ANDROID_HOME}",
    "${env:ANDROID_SDK_ROOT}"
)
foreach ($cand in $SdkCandidates) {
    if (![string]::IsNullOrWhiteSpace($cand) -and (Test-Path "$cand\platform-tools\adb.exe")) {
        $SdkRoot = $cand
        break
    }
}

# Busca ADB
$AdbExe = ""
if (![string]::IsNullOrWhiteSpace($SdkRoot) -and (Test-Path "$SdkRoot\platform-tools\adb.exe")) {
    $AdbExe = "$SdkRoot\platform-tools\adb.exe"
} else {
    $cmdAdb = Get-Command "adb.exe" -ErrorAction SilentlyContinue
    if ($cmdAdb) { $AdbExe = $cmdAdb.Source }
}

# Busca NDK
$NdkRoot = ""
if (![string]::IsNullOrWhiteSpace($SdkRoot) -and (Test-Path "$SdkRoot\ndk")) {
    $ndkDirs = Get-ChildItem -Path "$SdkRoot\ndk" -Directory | Sort-Object Name -Descending
    if ($ndkDirs.Count -gt 0) {
        $NdkRoot = $ndkDirs[0].FullName
    }
}
if ([string]::IsNullOrWhiteSpace($NdkRoot) -and !([string]::IsNullOrWhiteSpace(${env:ANDROID_NDK_HOME}))) {
    $NdkRoot = ${env:ANDROID_NDK_HOME}
}

# Busca Java JDK
$JavaHome = ""
$JdkCandidates = @(
    "${env:JAVA_HOME}",
    "C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot",
    "C:\Program Files\Android\Android Studio\jbr",
    "C:\Program Files\Java\jdk-21",
    "C:\Program Files\Java\jdk-17",
    "D:\DesthStrokeIDE\Android\jdk"
)
foreach ($cand in $JdkCandidates) {
    if (![string]::IsNullOrWhiteSpace($cand) -and (Test-Path "$cand\bin\java.exe")) {
        $JavaHome = $cand
        break
    }
}

# Busca Compilador FPC AArch64
$FpcA64 = ""
if (Test-Path "$FpcDir\bin\x86_64-win64\ppcrossa64.exe") {
    $FpcA64 = "$FpcDir\bin\x86_64-win64\ppcrossa64.exe"
} elseif (Test-Path "$FpcDir\bin\i386-win32\ppcrossa64.exe") {
    $FpcA64 = "$FpcDir\bin\i386-win32\ppcrossa64.exe"
}

# Escreve o arquivo de configuracao XML
$XmlLines = @(
    '<?xml version="1.0" encoding="UTF-8"?>',
    "<CONFIG AndroidSdkRoot=`"$SdkRoot`" AndroidNdkRoot=`"$NdkRoot`" AdbPath=`"$AdbExe`" JavaHome=`"$JavaHome`" FpcCrossAarch64=`"$FpcA64`" FpcCrossArm=`"ppcrossarm.exe`" GradleExecutable=`"`" ScaffoldDirectory=`"$RepoRoot\scaffold`" PackageName=`"com.lazarus.android.demo`" ActivityName=`"com.pascal.lclproject.LCLActivity`" AutoShowLogcat=`"True`" LogcatFilter=`"lclapp:* LazApp:* AndroidRuntime:E DEBUG:*`" ExtraFpcFlags=`"-O3 -Xs -XX -vewnhi`" LogLevelDebug=`"False`" DefaultAbi=`"arm64-v8a`"/>"
)

[System.IO.File]::WriteAllLines($CfgFile, $XmlLines, [System.Text.Encoding]::UTF8)
Write-Success "Configuracao gravada com sucesso em: $CfgFile"
Write-Info "SDK: $SdkRoot"
Write-Info "NDK: $NdkRoot"
Write-Info "ADB: $AdbExe"
Write-Info "JDK: $JavaHome"
Write-Info "FPC: $FpcA64"

# -----------------------------------------------------------------------------
# Recompilacao Opcional da IDE Lazarus
# -----------------------------------------------------------------------------
Write-Host ""
$DoRebuild = $RebuildIDE

if (-not $NonInteractive -and -not $RebuildIDE) {
    Write-Host "Deseja recompilar o Lazarus IDE agora para ativar o plugin e os menus imediatamente? [S/N]" -ForegroundColor Cyan
    $Resp = Read-Host "Opcao (Padrao: S)"
    if ([string]::IsNullOrWhiteSpace($Resp) -or $Resp.Trim().ToUpper() -eq "S") {
        $DoRebuild = $true
    }
}

if ($DoRebuild) {
    Write-Host ""
    Write-Info "Recompilando Lazarus IDE com o pacote LazDroid-Deploy integrado..."
    $IdeBuildOut = & "$LazarusDir\lazbuild.exe" --build-ide= 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Lazarus IDE recompilado com sucesso!"
    } else {
        Write-Warn "Aviso durante recompilacao da IDE (voce tambem pode recompilar pelo menu 'Package -> Install/Uninstall Packages' no Lazarus):"
        Write-Host ($IdeBuildOut | Out-String) -ForegroundColor DarkGray
    }
}

Write-Header "INSTALACAO CONCLUIDA COM SUCESSO!"
Write-Host "O que voce pode fazer agora:" -ForegroundColor White
Write-Host "  1. Abra o Lazarus IDE." -ForegroundColor Yellow
Write-Host "  2. Crie um novo aplicativo Android em: 'Arquivo -> Novo... -> Aplicacao Android (LazDroid)'" -ForegroundColor Yellow
Write-Host "  3. Ou abra uma demo pronta: 'demo3\demo3.lpi' ou 'demo\LazAndroidDemo.lpi'." -ForegroundColor Yellow
Write-Host "  4. Conecte seu celular via USB e tecle: 'Ctrl + Shift + F9'!" -ForegroundColor Yellow
Write-Host ""
