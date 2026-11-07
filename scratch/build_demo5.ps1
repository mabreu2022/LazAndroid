param([string]$Device = "RQ8R70BFZEJ")
$env:Path = "C:\lazarus\fpc\3.2.2\bin\x86_64-win64;" + $env:Path
$ndk = "C:\Users\HOT\AppData\Local\Android\Sdk\ndk\21.4.7075529\toolchains\llvm\prebuilt\windows-x86_64\sysroot\usr\lib\aarch64-linux-android"
$sysroot = "$ndk\24"
$fpcUnits = "C:\lazarus\fpc\3.2.2\units\aarch64-android"
$lazaRoot = "c:\Projetos Antigrtavity\REA\LazAndroid"
$outSoDir = "$lazaRoot\scaffold\app\src\main\jniLibs\arm64-v8a"
$adb = "C:\Users\HOT\AppData\Local\Android\Sdk\platform-tools\adb.exe"

New-Item -ItemType Directory -Force -Path "$lazaRoot\demo5\lib\aarch64-android" | Out-Null
Remove-Item "$lazaRoot\demo5\lib\aarch64-android\*" -Force -ErrorAction SilentlyContinue
Remove-Item "$lazaRoot\package\lib\aarch64-android\*" -Force -ErrorAction SilentlyContinue

& "C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ppcrossa64.exe" `
  -Tandroid -Paarch64 -MObjFPC -Scghi -O1 -g -gl -l -vewnq `
  -Fl"$sysroot" -Fl"$ndk" `
  -Fu"$fpcUnits\rtl" -Fu"$fpcUnits\rtl-objpas" -Fu"$fpcUnits\fcl-base" -Fu"$fpcUnits\fcl-db" -Fu"$fpcUnits\sqlite" -Fu"$fpcUnits\rtl-extra" -Fu"$fpcUnits\fcl-image" -Fu"$fpcUnits\pasjpeg" -Fu"$fpcUnits\paszlib" -Fu"$fpcUnits\hash" -Fu"$fpcUnits\rtl-generics" -Fu"$fpcUnits\fcl-xml" -Fu"$fpcUnits\fcl-process" -Fu"$fpcUnits\chm" `
  -Fu"C:\lazarus\components\lazutils\lib\aarch64-android" `
  -Fu"C:\lazarus\lcl\units\aarch64-android" `
  -Fu"C:\lazarus\lcl\units\aarch64-android\customdrawn" `
  -Fu"C:\lazarus\packager\units\aarch64-android" `
  -Fu"$lazaRoot\package" -Fi"$lazaRoot\package" `
  -Fi"$lazaRoot\demo5\lib\aarch64-android" `
  -FU"$lazaRoot\demo5\lib\aarch64-android" `
  -FE"$outSoDir" -o"liblazapp.so" `
  -dLCL -dLCLcustomdrawn -dANDROID -fPIC `
  "$lazaRoot\demo5\project1.lpr"
if ($LASTEXITCODE -ne 0) { Write-Host "FPC FAILED"; exit $LASTEXITCODE }

Set-Location "$lazaRoot\scaffold"
& ".\gradlew.bat" -PappId="com.lazarus.android.demo" assembleDebug --no-daemon -q
if ($LASTEXITCODE -ne 0) { Write-Host "GRADLE FAILED"; exit $LASTEXITCODE }

& $adb -s $Device install -r "$lazaRoot\scaffold\app\build\outputs\apk\debug\app-debug.apk"
& $adb -s $Device logcat -c
Write-Host "BUILD+INSTALL OK"

