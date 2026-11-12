; Script de Instalação Inno Setup para o Projeto LazDroid
; Gera o executável de distribuição Setup-LazAndroid.exe

#define MyAppName "LazDroid"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "mabreu2022"
#define MyAppURL "https://github.com/mabreu2022/LazAndroid"
#define MyAppExeName "Instalar-LazDroid.exe"

[Setup]
AppId={{B5658602-C753-4809-B2C1-60FDE5961DF8}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={sd}\LazAndroid
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
OutputDir=..\..\dist
OutputBaseFilename=Setup-LazAndroid
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesInstallIn64BitMode=x64
DisableWelcomePage=no
DisableDirPage=no
DisableProgramGroupPage=no

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Executáveis e scripts raiz
Source: "..\..\Instalar-LazDroid.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\Instalar-LazDroid.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\Restaurar-Layout-Lazarus.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\Abrir-Livro-LazDroid.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\Abrir-Manual-Componentes.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\Abrir-Manual-PDF.cmd"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\README.en.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\packagefiles.xml"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\CODE_OF_CONDUCT.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\CONTRIBUTING.md"; DestDir: "{app}"; Flags: ignoreversion

; Pastas do projeto
Source: "..\..\package\*"; DestDir: "{app}\package"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\scaffold\*"; DestDir: "{app}\scaffold"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: ".gradle\*,build\*,app\build\*,app\src\main\jniLibs\arm64-v8a\liblazapp.so,app\src\main\jniLibs\armeabi-v7a\liblazapp.so"
Source: "..\..\demo\*"; DestDir: "{app}\demo"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "lib\*,backup\*,*.ppu,*.o"
Source: "..\..\demo2\*"; DestDir: "{app}\demo2"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "lib\*,backup\*,*.ppu,*.o"
Source: "..\..\demo3\*"; DestDir: "{app}\demo3"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "lib\*,backup\*,*.ppu,*.o"
Source: "..\..\demo4\*"; DestDir: "{app}\demo4"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "lib\*,backup\*,*.ppu,*.o"
Source: "..\..\demo5\*"; DestDir: "{app}\demo5"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "lib\*,backup\*,*.ppu,*.o"
Source: "..\..\docs\*"; DestDir: "{app}\docs"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\tools\scripts\*"; DestDir: "{app}\tools\scripts"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\tools\installer\*"; DestDir: "{app}\tools\installer"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.iss"
Source: "..\..\tools\installer_gui\*"; DestDir: "{app}\tools\installer_gui"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "lib\*,backup\*,*.ppu,*.o"
Source: "..\..\tools\sqlite\*"; DestDir: "{app}\tools\sqlite"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\tools\sqlite_lib\*"; DestDir: "{app}\tools\sqlite_lib"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\tools\innoextract\*"; DestDir: "{app}\tools\innoextract"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\tools\settings.ini"; DestDir: "{app}\tools"; Flags: ignoreversion
Source: "..\..\tools\defmods.ini"; DestDir: "{app}\tools"; Flags: ignoreversion
Source: "..\..\tools\fpcup.ini"; DestDir: "{app}\tools"; Flags: ignoreversion

; FPC Cross-Compiler binaries e units para Android AArch64 e ARMv7
Source: "..\..\tools\fpc_extracted\app\bin\i386-win32\*"; DestDir: "{app}\tools\fpc_extracted\app\bin\i386-win32"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\tools\fpc_extracted\app\units\aarch64-android\*"; DestDir: "{app}\tools\fpc_extracted\app\units\aarch64-android"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\..\tools\fpc_extracted\app\units\arm-android\*"; DestDir: "{app}\tools\fpc_extracted\app\units\arm-android"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName} - Assistente de Instalação e Configuração"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{group}\{#MyAppName} - Restaurar Layout Delphi na IDE"; Filename: "{app}\Restaurar-Layout-Lazarus.cmd"; WorkingDir: "{app}"
Name: "{group}\{#MyAppName} - Manual de Componentes Mobile (HTML)"; Filename: "{app}\Abrir-Manual-Componentes.cmd"; WorkingDir: "{app}"
Name: "{group}\{#MyAppName} - Livro Oficial LazDroid (HTML)"; Filename: "{app}\Abrir-Livro-LazDroid.cmd"; WorkingDir: "{app}"
Name: "{group}\{#MyAppName} - Manual em PDF"; Filename: "{app}\Abrir-Manual-PDF.cmd"; WorkingDir: "{app}"
Name: "{group}\Demos\Demo 1 - Controles Visuais"; Filename: "{app}\demo\LazAndroidDemo.lpi"; WorkingDir: "{app}\demo"
Name: "{group}\Demos\Demo 2 - Sensores e Hardware"; Filename: "{app}\demo2\project1.lpi"; WorkingDir: "{app}\demo2"
Name: "{group}\Demos\Demo 3 - CRUD SQLite Mobile"; Filename: "{app}\demo3\demo3.lpi"; WorkingDir: "{app}\demo3"
Name: "{group}\Demos\Demo 4 - Câmera e Mídia"; Filename: "{app}\demo4\demo4.lpi"; WorkingDir: "{app}\demo4"
Name: "{group}\Demos\Demo 5 - Multi-telas e Navegação"; Filename: "{app}\demo5\project1.lpi"; WorkingDir: "{app}\demo5"
Name: "{group}\Pasta do Projeto LazDroid"; Filename: "{app}"
Name: "{group}\Desinstalar {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName} - Assistente"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Executar o Assistente Visual do LazDroid para configurar o Lazarus agora"; Flags: postinstall nowait skipifsilent

