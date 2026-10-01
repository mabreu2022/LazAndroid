{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidConfig.pas
  Descrição: Gerenciamento e persistência das configurações do SDK, NDK, FPC e Gradle.
}
unit LazDroidConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazConfigStorage, BaseIDEIntf;

const
  LAZDROID_CONFIG_FILENAME = 'lazdroiddeploy.xml';
  DEFAULT_PACKAGE_NAME    = 'com.lazarus.android.demo';
  DEFAULT_ACTIVITY_NAME   = 'com.pascal.lclproject.LCLActivity';
  DEFAULT_SO_NAME         = 'liblazapp.so';

type
  TAndroidAbi = (abiArm64_v8a, abiArmeabi_v7a, abiX86_64, abiX86);

  { TLazDroidSettings }
  TLazDroidSettings = class
  private
    FAndroidSdkRoot: string;
    FAndroidNdkRoot: string;
    FAdbPath: string;
    FJavaHome: string;
    FFpcCrossAarch64: string;
    FFpcCrossArm: string;
    FGradleExecutable: string;
    FDefaultAbi: TAndroidAbi;
    FScaffoldDirectory: string;
    FPackageName: string;
    FActivityName: string;
    FAutoShowLogcat: Boolean;
    FLogcatFilter: string;
    FExtraFpcFlags: string;
    FLogLevelDebug: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AutoDetectPaths;
    procedure Load;
    procedure Save;

    function GetFpcCompilerForAbi(const AAbi: TAndroidAbi): string;
    function GetFpcTargetCpuForAbi(const AAbi: TAndroidAbi): string;
    function AbiToString(const AAbi: TAndroidAbi): string;
    function StringToAbi(const AStr: string): TAndroidAbi;
    function ValidatePaths(out AErrors: string): Boolean;
    function GetNdkToolchainBinForAbi(const AAbi: TAndroidAbi): string;
    function GetNdkSysrootLibForAbi(const AAbi: TAndroidAbi): string;

    property AndroidSdkRoot: string read FAndroidSdkRoot write FAndroidSdkRoot;
    property AndroidNdkRoot: string read FAndroidNdkRoot write FAndroidNdkRoot;
    property AdbPath: string read FAdbPath write FAdbPath;
    property JavaHome: string read FJavaHome write FJavaHome;
    property FpcCrossAarch64: string read FFpcCrossAarch64 write FFpcCrossAarch64;
    property FpcCrossArm: string read FFpcCrossArm write FFpcCrossArm;
    property GradleExecutable: string read FGradleExecutable write FGradleExecutable;
    property DefaultAbi: TAndroidAbi read FDefaultAbi write FDefaultAbi;
    property ScaffoldDirectory: string read FScaffoldDirectory write FScaffoldDirectory;
    property PackageName: string read FPackageName write FPackageName;
    property ActivityName: string read FActivityName write FActivityName;
    property AutoShowLogcat: Boolean read FAutoShowLogcat write FAutoShowLogcat;
    property LogcatFilter: string read FLogcatFilter write FLogcatFilter;
    property ExtraFpcFlags: string read FExtraFpcFlags write FExtraFpcFlags;
    property LogLevelDebug: Boolean read FLogLevelDebug write FLogLevelDebug;
  end;

function DroidConfig: TLazDroidSettings;

implementation

uses
  FileUtil;

var
  GSettings: TLazDroidSettings = nil;

function DroidConfig: TLazDroidSettings;
begin
  if not Assigned(GSettings) then
  begin
    GSettings := TLazDroidSettings.Create;
    GSettings.Load;
  end;
  Result := GSettings;
end;

{ TLazDroidSettings }

constructor TLazDroidSettings.Create;
begin
  inherited Create;
  FDefaultAbi := abiArm64_v8a;
  FPackageName := DEFAULT_PACKAGE_NAME;
  FActivityName := DEFAULT_ACTIVITY_NAME;
  FAutoShowLogcat := True;
  FLogcatFilter := 'LazApp:* AndroidRuntime:E DEBUG:*';
  FExtraFpcFlags := '-O3 -Xs -XX -vewnhi';
  FLogLevelDebug := False;
  AutoDetectPaths;
end;

destructor TLazDroidSettings.Destroy;
begin
  inherited Destroy;
end;

function TLazDroidSettings.AbiToString(const AAbi: TAndroidAbi): string;
begin
  case AAbi of
    abiArm64_v8a: Result := 'arm64-v8a';
    abiArmeabi_v7a: Result := 'armeabi-v7a';
    abiX86_64: Result := 'x86_64';
    abiX86: Result := 'x86';
  else
    Result := 'arm64-v8a';
  end;
end;

function TLazDroidSettings.StringToAbi(const AStr: string): TAndroidAbi;
var
  S: string;
begin
  S := LowerCase(Trim(AStr));
  if (S = 'arm64-v8a') or (S = 'aarch64') then
    Result := abiArm64_v8a
  else if (S = 'armeabi-v7a') or (S = 'armv7') or (S = 'arm') then
    Result := abiArmeabi_v7a
  else if S = 'x86_64' then
    Result := abiX86_64
  else if S = 'x86' then
    Result := abiX86
  else
    Result := abiArm64_v8a;
end;

procedure TLazDroidSettings.AutoDetectPaths;
var
  LocalApp: string;
  ProgramFiles: string;
  PossibleSdk: string;
  CandidateNdk: string;
  NdkSearchRec: TSearchRec;
begin
  LocalApp := GetEnvironmentVariable('LOCALAPPDATA');
  ProgramFiles := GetEnvironmentVariable('ProgramFiles');

  // 1. Android SDK & ADB
  if LocalApp <> '' then
  begin
    PossibleSdk := IncludeTrailingPathDelimiter(LocalApp) + 'Android' + PathDelim + 'Sdk';
    if DirectoryExists(PossibleSdk) then
    begin
      FAndroidSdkRoot := PossibleSdk;
      if FileExists(PossibleSdk + PathDelim + 'platform-tools' + PathDelim + 'adb.exe') then
        FAdbPath := PossibleSdk + PathDelim + 'platform-tools' + PathDelim + 'adb.exe';

      // NDK search
      CandidateNdk := PossibleSdk + PathDelim + 'ndk';
      if DirectoryExists(CandidateNdk) then
      begin
        if FindFirst(CandidateNdk + PathDelim + '*', faDirectory, NdkSearchRec) = 0 then
        begin
          repeat
            if (NdkSearchRec.Name <> '.') and (NdkSearchRec.Name <> '..') and
               ((NdkSearchRec.Attr and faDirectory) <> 0) and
               FileExists(CandidateNdk + PathDelim + NdkSearchRec.Name + PathDelim + 'source.properties') then
            begin
              FAndroidNdkRoot := CandidateNdk + PathDelim + NdkSearchRec.Name;
              Break;
            end;
          until FindNext(NdkSearchRec) <> 0;
          FindClose(NdkSearchRec);
        end;
      end;
    end;
  end;

  // Fallback ADB
  if (FAdbPath = '') and (FileExists('adb.exe')) then
    FAdbPath := 'adb.exe';

  // 2. Java Home (validar existência real de bin\java.exe)
  if (GetEnvironmentVariable('JAVA_HOME') <> '') and
     FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('JAVA_HOME')) + 'bin' + PathDelim + 'java.exe') then
    FJavaHome := GetEnvironmentVariable('JAVA_HOME')
  else if (ProgramFiles <> '') and DirectoryExists(ProgramFiles + PathDelim + 'Eclipse Adoptium') then
  begin
    if FindFirst(ProgramFiles + PathDelim + 'Eclipse Adoptium' + PathDelim + 'jdk*', faDirectory, NdkSearchRec) = 0 then
    begin
      repeat
        if FileExists(ProgramFiles + PathDelim + 'Eclipse Adoptium' + PathDelim + NdkSearchRec.Name + PathDelim + 'bin' + PathDelim + 'java.exe') then
        begin
          FJavaHome := ProgramFiles + PathDelim + 'Eclipse Adoptium' + PathDelim + NdkSearchRec.Name;
          Break;
        end;
      until FindNext(NdkSearchRec) <> 0;
      FindClose(NdkSearchRec);
    end;
  end
  else if DirectoryExists('D:\DesthStrokeIDE\Android\jdk') and FileExists('D:\DesthStrokeIDE\Android\jdk\bin\java.exe') then
    FJavaHome := 'D:\DesthStrokeIDE\Android\jdk'
  else if (ProgramFiles <> '') and FileExists(ProgramFiles + PathDelim + 'Android' + PathDelim + 'Android Studio' + PathDelim + 'jbr' + PathDelim + 'bin' + PathDelim + 'java.exe') then
    FJavaHome := ProgramFiles + PathDelim + 'Android' + PathDelim + 'Android Studio' + PathDelim + 'jbr'
  else if (ProgramFiles <> '') and DirectoryExists(ProgramFiles + PathDelim + 'Java') then
  begin
    if FindFirst(ProgramFiles + PathDelim + 'Java' + PathDelim + 'jdk*', faDirectory, NdkSearchRec) = 0 then
    begin
      repeat
        if FileExists(ProgramFiles + PathDelim + 'Java' + PathDelim + NdkSearchRec.Name + PathDelim + 'bin' + PathDelim + 'java.exe') then
        begin
          FJavaHome := ProgramFiles + PathDelim + 'Java' + PathDelim + NdkSearchRec.Name;
          Break;
        end;
      until FindNext(NdkSearchRec) <> 0;
      FindClose(NdkSearchRec);
    end;
  end;

  // 3. FPC Cross Compilers
  // Standard locations in Lazarus installation (ppcrossa64 or ppca64)
  if FileExists('C:\lazarus\fpc\3.2.2\bin\i386-win32\ppcrossa64.exe') then
    FFpcCrossAarch64 := 'C:\lazarus\fpc\3.2.2\bin\i386-win32\ppcrossa64.exe'
  else if FileExists('C:\lazarus\fpc\3.2.2\bin\i386-win32\ppca64.exe') then
    FFpcCrossAarch64 := 'C:\lazarus\fpc\3.2.2\bin\i386-win32\ppca64.exe'
  else if FileExists('C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ppcrossa64.exe') then
    FFpcCrossAarch64 := 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ppcrossa64.exe'
  else if FileExists('C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ppca64.exe') then
    FFpcCrossAarch64 := 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ppca64.exe'
  else
    FFpcCrossAarch64 := 'ppcrossa64.exe';

  if FileExists('C:\lazarus\fpc\3.2.2\bin\i386-win32\ppcrossarm.exe') then
    FFpcCrossArm := 'C:\lazarus\fpc\3.2.2\bin\i386-win32\ppcrossarm.exe'
  else if FileExists('C:\lazarus\fpc\3.2.2\bin\i386-win32\ppcarm.exe') then
    FFpcCrossArm := 'C:\lazarus\fpc\3.2.2\bin\i386-win32\ppcarm.exe'
  else if FileExists('C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ppcrossarm.exe') then
    FFpcCrossArm := 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ppcrossarm.exe'
  else if FileExists('C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ppcarm.exe') then
    FFpcCrossArm := 'C:\lazarus\fpc\3.2.2\bin\x86_64-win64\ppcarm.exe'
  else
    FFpcCrossArm := 'ppcrossarm.exe';
end;

procedure TLazDroidSettings.Load;
var
  Storage: TConfigStorage;
  AbiStr: string;
begin
  try
    Storage := GetIDEConfigStorage(LAZDROID_CONFIG_FILENAME, True);
    try
      FAndroidSdkRoot     := Storage.GetValue('AndroidSdkRoot', FAndroidSdkRoot);
      FAndroidNdkRoot     := Storage.GetValue('AndroidNdkRoot', FAndroidNdkRoot);
      FAdbPath            := Storage.GetValue('AdbPath', FAdbPath);
      FJavaHome           := Storage.GetValue('JavaHome', FJavaHome);
      FFpcCrossAarch64    := Storage.GetValue('FpcCrossAarch64', FFpcCrossAarch64);
      FFpcCrossArm        := Storage.GetValue('FpcCrossArm', FFpcCrossArm);
      FGradleExecutable   := Storage.GetValue('GradleExecutable', FGradleExecutable);
      FScaffoldDirectory  := Storage.GetValue('ScaffoldDirectory', FScaffoldDirectory);
      FPackageName        := Storage.GetValue('PackageName', FPackageName);
      FActivityName       := Storage.GetValue('ActivityName', FActivityName);
      FAutoShowLogcat     := Storage.GetValue('AutoShowLogcat', FAutoShowLogcat);
      FLogcatFilter       := Storage.GetValue('LogcatFilter', FLogcatFilter);
      FExtraFpcFlags      := Storage.GetValue('ExtraFpcFlags', FExtraFpcFlags);
      FLogLevelDebug      := Storage.GetValue('LogLevelDebug', FLogLevelDebug);

      AbiStr              := Storage.GetValue('DefaultAbi', 'arm64-v8a');
      FDefaultAbi         := StringToAbi(AbiStr);
    finally
      Storage.Free;
    end;
  except
    // Mantém defaults detectados caso storage falhe
  end;
end;

procedure TLazDroidSettings.Save;
var
  Storage: TConfigStorage;
begin
  try
    Storage := GetIDEConfigStorage(LAZDROID_CONFIG_FILENAME, False);
    try
      Storage.SetValue('AndroidSdkRoot', FAndroidSdkRoot);
      Storage.SetValue('AndroidNdkRoot', FAndroidNdkRoot);
      Storage.SetValue('AdbPath', FAdbPath);
      Storage.SetValue('JavaHome', FJavaHome);
      Storage.SetValue('FpcCrossAarch64', FFpcCrossAarch64);
      Storage.SetValue('FpcCrossArm', FFpcCrossArm);
      Storage.SetValue('GradleExecutable', FGradleExecutable);
      Storage.SetValue('ScaffoldDirectory', FScaffoldDirectory);
      Storage.SetValue('PackageName', FPackageName);
      Storage.SetValue('ActivityName', FActivityName);
      Storage.SetValue('AutoShowLogcat', FAutoShowLogcat);
      Storage.SetValue('LogcatFilter', FLogcatFilter);
      Storage.SetValue('ExtraFpcFlags', FExtraFpcFlags);
      Storage.SetValue('LogLevelDebug', FLogLevelDebug);
      Storage.SetValue('DefaultAbi', AbiToString(FDefaultAbi));
    finally
      Storage.Free;
    end;
  except
    // Falha silenciosa de escrita para não travar a IDE
  end;
end;

function TLazDroidSettings.GetFpcCompilerForAbi(const AAbi: TAndroidAbi): string;
var
  Candidate: string;
  Dir: string;
begin
  case AAbi of
    abiArm64_v8a: Candidate := FFpcCrossAarch64;
    abiArmeabi_v7a: Candidate := FFpcCrossArm;
    abiX86_64: Candidate := 'ppcrossx64.exe';
    abiX86: Candidate := 'ppcross386.exe';
  else
    Candidate := FFpcCrossAarch64;
  end;

  // Se o caminho apontado não existe, verificar se existe com prefixo ppcross ou ppc
  if (Candidate <> '') and not FileExists(Candidate) then
  begin
    Dir := ExtractFilePath(Candidate);
    if (ExtractFileName(Candidate) = 'ppca64.exe') and FileExists(Dir + 'ppcrossa64.exe') then
      Candidate := Dir + 'ppcrossa64.exe'
    else if (ExtractFileName(Candidate) = 'ppcrossa64.exe') and FileExists(Dir + 'ppca64.exe') then
      Candidate := Dir + 'ppca64.exe'
    else if (ExtractFileName(Candidate) = 'ppcarm.exe') and FileExists(Dir + 'ppcrossarm.exe') then
      Candidate := Dir + 'ppcrossarm.exe'
    else if (ExtractFileName(Candidate) = 'ppcrossarm.exe') and FileExists(Dir + 'ppcarm.exe') then
      Candidate := Dir + 'ppcarm.exe';
  end;

  Result := Candidate;
end;

function TLazDroidSettings.GetFpcTargetCpuForAbi(const AAbi: TAndroidAbi): string;
begin
  case AAbi of
    abiArm64_v8a: Result := 'aarch64';
    abiArmeabi_v7a: Result := 'arm';
    abiX86_64: Result := 'x86_64';
    abiX86: Result := 'i386';
  else
    Result := 'aarch64';
  end;
end;

function TLazDroidSettings.ValidatePaths(out AErrors: string): Boolean;
var
  ErrList: TStringList;
begin
  ErrList := TStringList.Create;
  try
    if (FAdbPath = '') or (not FileExists(FAdbPath) and (ExtractFileName(FAdbPath) <> 'adb.exe')) then
      ErrList.Add('- Executável do ADB não encontrado ou inválido.');

    if (FAndroidSdkRoot <> '') and (not DirectoryExists(FAndroidSdkRoot)) then
      ErrList.Add('- Diretório Android SDK Root não existe.');

    if (FFpcCrossAarch64 = '') then
      ErrList.Add('- Compilador cruzado FPC AArch64 (ppca64) não configurado.');

    if (FScaffoldDirectory <> '') and (not DirectoryExists(FScaffoldDirectory)) then
      ErrList.Add('- Diretório do Scaffold Android informado não existe.');

    AErrors := ErrList.Text;
    Result := (ErrList.Count = 0);
  finally
    ErrList.Free;
  end;
end;

function TLazDroidSettings.GetNdkToolchainBinForAbi(const AAbi: TAndroidAbi): string;
var
  Base: string;
begin
  Result := '';
  if FAndroidNdkRoot = '' then Exit;

  // 1. LLVM prebuilt bin (NDK r19+)
  Base := IncludeTrailingPathDelimiter(FAndroidNdkRoot) +
    'toolchains' + PathDelim + 'llvm' + PathDelim + 'prebuilt' + PathDelim + 'windows-x86_64' + PathDelim + 'bin';
  if DirectoryExists(Base) then
  begin
    Result := Base;
    Exit;
  end;

  // 2. Standalone toolchain fallback
  case AAbi of
    abiArm64_v8a:
      Base := IncludeTrailingPathDelimiter(FAndroidNdkRoot) +
        'toolchains' + PathDelim + 'aarch64-linux-android-4.9' + PathDelim + 'prebuilt' + PathDelim + 'windows-x86_64' + PathDelim + 'bin';
    abiArmeabi_v7a:
      Base := IncludeTrailingPathDelimiter(FAndroidNdkRoot) +
        'toolchains' + PathDelim + 'arm-linux-androideabi-4.9' + PathDelim + 'prebuilt' + PathDelim + 'windows-x86_64' + PathDelim + 'bin';
  end;
  if DirectoryExists(Base) then
    Result := Base;
end;

function TLazDroidSettings.GetNdkSysrootLibForAbi(const AAbi: TAndroidAbi): string;
var
  Candidate: string;
  ArchName: string;
begin
  Result := '';
  if FAndroidNdkRoot = '' then Exit;

  case AAbi of
    abiArm64_v8a: ArchName := 'arch-arm64';
    abiArmeabi_v7a: ArchName := 'arch-arm';
    abiX86_64: ArchName := 'arch-x86_64';
    abiX86: ArchName := 'arch-x86';
  end;

  Candidate := IncludeTrailingPathDelimiter(FAndroidNdkRoot) +
    'platforms' + PathDelim + 'android-21' + PathDelim + ArchName + PathDelim + 'usr' + PathDelim + 'lib';
  if DirectoryExists(Candidate) then
  begin
    Result := Candidate;
    Exit;
  end;

  Candidate := IncludeTrailingPathDelimiter(FAndroidNdkRoot) +
    'platforms' + PathDelim + 'android-24' + PathDelim + ArchName + PathDelim + 'usr' + PathDelim + 'lib';
  if DirectoryExists(Candidate) then
    Result := Candidate;
end;

initialization

finalization
  if Assigned(GSettings) then
    FreeAndNil(GSettings);

end.
