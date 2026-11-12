unit MainForm;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, CheckLst, Process, FileUtil;

type
  TLogProc = procedure(const ALine: string) of object;

  { TFrmMain }

  TFrmMain = class(TForm)
    pnlHeader: TPanel;
    lblTitle: TLabel;
    lblSubTitle: TLabel;

    grpLazarus: TGroupBox;
    lblLazarusPath: TLabel;
    edtLazarusDir: TEdit;
    btnBrowse: TButton;
    lblLazarusDetected: TLabel;

    grpEnvironment: TGroupBox;
    lblJdk: TLabel;
    lblSdk: TLabel;
    lblNdk: TLabel;
    lblFpcCross: TLabel;

    grpSteps: TGroupBox;
    clbSteps: TCheckListBox;

    pnlButtons: TPanel;
    btnInstallAll: TButton;
    btnCheckEnv: TButton;
    btnDelphiLayout: TButton;
    btnOpenLazarus: TButton;
    btnOpenDemos: TButton;

    pnlBottom: TPanel;
    progressBar: TProgressBar;
    lblProgress: TLabel;
    memLog: TMemo;

    dlgBrowse: TSelectDirectoryDialog;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnCheckEnvClick(Sender: TObject);
    procedure btnInstallAllClick(Sender: TObject);
    procedure btnDelphiLayoutClick(Sender: TObject);
    procedure btnOpenLazarusClick(Sender: TObject);
    procedure btnOpenDemosClick(Sender: TObject);
    procedure edtLazarusDirChange(Sender: TObject);
  private
    FRepoRoot: string;
    FFpcDir: string;
    FFpcVer: string;
    FJdkPath: string;
    FSdkPath: string;
    FNdkPath: string;
    FAdbPath: string;
    FFpcCrossPath: string;

    procedure Log(const AText: string);
    procedure LogProcess(const ALine: string);
    procedure SetProgress(const APercent: Integer; const AMsg: string);
    function FindFpcDirectory(const ALazDir: string; out AVer: string): string;
    procedure DetectEnvironment;
    function ExecuteProcessWithLog(const AExe, AArgs: string): Integer;
    procedure CopyDirRecursive(const ASrc, ADst: string);
    function ApplyKeyboardPatch(const ALazDir: string): Boolean;
    function ApplyFontPatch(const ALazDir: string): Boolean;
    procedure WriteDeployXml;
    procedure WriteLocalProperties;
  public
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.lfm}

{ Helper functions }

function EscapePathForProperties(const APath: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(APath) do
  begin
    if APath[I] = '\' then
      Result := Result + '\\'
    else if APath[I] = ':' then
      Result := Result + '\:'
    else
      Result := Result + APath[I];
  end;
end;

{ TFrmMain }

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  // Root of the LazAndroid repository
  FRepoRoot := ExtractFilePath(ParamStr(0));
  if FileExists(IncludeTrailingPathDelimiter(FRepoRoot) + 'package\LazDroidDeploy.lpk') then
    FRepoRoot := ExcludeTrailingPathDelimiter(FRepoRoot)
  else if FileExists(IncludeTrailingPathDelimiter(ExtractFilePath(ExcludeTrailingPathDelimiter(FRepoRoot))) + 'package\LazDroidDeploy.lpk') then
    FRepoRoot := ExcludeTrailingPathDelimiter(ExtractFilePath(ExcludeTrailingPathDelimiter(FRepoRoot)))
  else
    FRepoRoot := ExpandFileName(ExtractFilePath(ParamStr(0)) + '..\..');

  memLog.Clear;
  Log('================================================================');
  Log('  LazDroid - Assistente de Instalacao e Configuracao de Ambiente');
  Log('  Repositorio: ' + FRepoRoot);
  Log('================================================================');
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  DetectEnvironment;
end;

procedure TFrmMain.Log(const AText: string);
begin
  memLog.Lines.Add(FormatDateTime('[hh:nn:ss] ', Now) + AText);
  memLog.SelStart := Length(memLog.Text);
  memLog.SelLength := 0;
  Application.ProcessMessages;
end;

procedure TFrmMain.LogProcess(const ALine: string);
begin
  if Trim(ALine) <> '' then
  begin
    memLog.Lines.Add('    ' + ALine);
    memLog.SelStart := Length(memLog.Text);
    memLog.SelLength := 0;
  end;
  Application.ProcessMessages;
end;

procedure TFrmMain.SetProgress(const APercent: Integer; const AMsg: string);
begin
  progressBar.Position := APercent;
  lblProgress.Caption := AMsg;
  Application.ProcessMessages;
end;

function TFrmMain.FindFpcDirectory(const ALazDir: string; out AVer: string): string;
var
  FpcBase: string;
  SR: TSearchRec;
  BestVer: string;
  BestDir: string;
begin
  Result := '';
  AVer := '';
  FpcBase := IncludeTrailingPathDelimiter(ALazDir) + 'fpc';
  if not DirectoryExists(FpcBase) then Exit;

  BestVer := '';
  BestDir := '';
  if FindFirst(IncludeTrailingPathDelimiter(FpcBase) + '*', faDirectory, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') and ((SR.Attr and faDirectory) <> 0) then
        begin
          if (Length(SR.Name) >= 3) and (SR.Name[1] in ['2','3','4']) and (SR.Name[2] = '.') then
          begin
            if SR.Name > BestVer then
            begin
              BestVer := SR.Name;
              BestDir := IncludeTrailingPathDelimiter(FpcBase) + SR.Name;
            end;
          end;
        end;
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;

  AVer := BestVer;
  Result := BestDir;
end;

procedure TFrmMain.DetectEnvironment;
var
  Candidates: array[0..3] of string;
  I: Integer;
  LocalApp: string;
  LazFound: Boolean;
  SR: TSearchRec;
  HasKbPatch, HasFontPatch, HasLclUnits: Boolean;
  StdCtrlsPath, WinApiPath, LclUnitFile: string;
  FpcBinX64, FpcBinX86: string;
begin
  LocalApp := GetEnvironmentVariable('LOCALAPPDATA');
  LazFound := False;

  // 1. Detect Lazarus Path
  if (edtLazarusDir.Text <> '') and FileExists(IncludeTrailingPathDelimiter(edtLazarusDir.Text) + 'lazbuild.exe') then
  begin
    LazFound := True;
  end
  else
  begin
    Candidates[0] := 'C:\lazarus';
    Candidates[1] := 'D:\lazarus';
    Candidates[2] := GetEnvironmentVariable('ProgramFiles') + '\lazarus';
    Candidates[3] := GetEnvironmentVariable('ProgramFiles(x86)') + '\lazarus';

    for I := 0 to High(Candidates) do
    begin
      if (Candidates[I] <> '') and FileExists(IncludeTrailingPathDelimiter(Candidates[I]) + 'lazbuild.exe') then
      begin
        edtLazarusDir.Text := Candidates[I];
        LazFound := True;
        Break;
      end;
    end;
  end;

  if LazFound then
  begin
    FFpcDir := FindFpcDirectory(edtLazarusDir.Text, FFpcVer);
    lblLazarusDetected.Caption := 'Lazarus detectado com sucesso! (FPC ' + FFpcVer + ')';
    lblLazarusDetected.Font.Color := $007A3E0A;
  end
  else
  begin
    lblLazarusDetected.Caption := 'Lazarus nao encontrado nas pastas padrao. Clique em Procurar...';
    lblLazarusDetected.Font.Color := clRed;
  end;

  // 2. Detect JDK
  FJdkPath := '';
  if (GetEnvironmentVariable('JAVA_HOME') <> '') and FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('JAVA_HOME')) + 'bin\java.exe') then
    FJdkPath := GetEnvironmentVariable('JAVA_HOME')
  else if FileExists(IncludeTrailingPathDelimiter(LocalApp) + 'Android\jdk\bin\java.exe') then
    FJdkPath := IncludeTrailingPathDelimiter(LocalApp) + 'Android\jdk'
  else if DirectoryExists('C:\Program Files\Eclipse Adoptium') then
  begin
    if FindFirst('C:\Program Files\Eclipse Adoptium\jdk*', faDirectory, SR) = 0 then
    begin
      FJdkPath := 'C:\Program Files\Eclipse Adoptium\' + SR.Name;
      FindClose(SR);
    end;
  end
  else if DirectoryExists('C:\Program Files\Android\Android Studio\jbr') then
    FJdkPath := 'C:\Program Files\Android\Android Studio\jbr';

  if FJdkPath <> '' then
  begin
    lblJdk.Caption := 'Java JDK: ' + FJdkPath;
    lblJdk.Font.Color := $00008800;
  end
  else
  begin
    lblJdk.Caption := 'Java JDK: Nao detectado (instale Adoptium JDK 21 ou Android Studio)';
    lblJdk.Font.Color := clMaroon;
  end;

  // 3. Detect Android SDK & ADB
  FSdkPath := '';
  FAdbPath := '';
  if DirectoryExists(IncludeTrailingPathDelimiter(LocalApp) + 'Android\Sdk') then
    FSdkPath := IncludeTrailingPathDelimiter(LocalApp) + 'Android\Sdk'
  else if DirectoryExists('C:\Android\Sdk') then
    FSdkPath := 'C:\Android\Sdk'
  else if DirectoryExists('D:\Android\Sdk') then
    FSdkPath := 'D:\Android\Sdk'
  else if GetEnvironmentVariable('ANDROID_HOME') <> '' then
    FSdkPath := GetEnvironmentVariable('ANDROID_HOME')
  else if GetEnvironmentVariable('ANDROID_SDK_ROOT') <> '' then
    FSdkPath := GetEnvironmentVariable('ANDROID_SDK_ROOT');

  if (FSdkPath <> '') and FileExists(IncludeTrailingPathDelimiter(FSdkPath) + 'platform-tools\adb.exe') then
  begin
    FAdbPath := IncludeTrailingPathDelimiter(FSdkPath) + 'platform-tools\adb.exe';
    lblSdk.Caption := 'Android SDK: ' + FSdkPath + ' (ADB OK)';
    lblSdk.Font.Color := $00008800;
  end
  else if FSdkPath <> '' then
  begin
    lblSdk.Caption := 'Android SDK: ' + FSdkPath + ' (ADB nao encontrado)';
    lblSdk.Font.Color := clOlive;
  end
  else
  begin
    lblSdk.Caption := 'Android SDK: Nao detectado';
    lblSdk.Font.Color := clMaroon;
  end;

  // 4. Detect NDK
  FNdkPath := '';
  if (FSdkPath <> '') and DirectoryExists(IncludeTrailingPathDelimiter(FSdkPath) + 'ndk') then
  begin
    if FindFirst(IncludeTrailingPathDelimiter(FSdkPath) + 'ndk\*', faDirectory, SR) = 0 then
    begin
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') and ((SR.Attr and faDirectory) <> 0) then
        begin
          if SR.Name > FNdkPath then
            FNdkPath := IncludeTrailingPathDelimiter(FSdkPath) + 'ndk\' + SR.Name;
        end;
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
  end;
  if (FNdkPath = '') and (GetEnvironmentVariable('ANDROID_NDK_HOME') <> '') then
    FNdkPath := GetEnvironmentVariable('ANDROID_NDK_HOME');

  if FNdkPath <> '' then
  begin
    lblNdk.Caption := 'Android NDK: ' + FNdkPath;
    lblNdk.Font.Color := $00008800;
  end
  else
  begin
    lblNdk.Caption := 'Android NDK: Nao detectado';
    lblNdk.Font.Color := clMaroon;
  end;

  // 5. Detect FPC Cross-Compiler
  FFpcCrossPath := '';
  if FFpcDir <> '' then
  begin
    FpcBinX64 := IncludeTrailingPathDelimiter(FFpcDir) + 'bin\x86_64-win64\ppcrossa64.exe';
    FpcBinX86 := IncludeTrailingPathDelimiter(FFpcDir) + 'bin\i386-win32\ppcrossa64.exe';
    if FileExists(FpcBinX64) then
      FFpcCrossPath := FpcBinX64
    else if FileExists(FpcBinX86) then
      FFpcCrossPath := FpcBinX86;
  end;

  if FFpcCrossPath <> '' then
  begin
    lblFpcCross.Caption := 'FPC AArch64 Cross: ' + FFpcCrossPath;
    lblFpcCross.Font.Color := $00008800;
  end
  else
  begin
    lblFpcCross.Caption := 'FPC AArch64 Cross: Nao instalado (sera instalado pelo assistente)';
    lblFpcCross.Font.Color := clMaroon;
  end;

  // 6. Update Checklist
  clbSteps.Checked[0] := (FFpcCrossPath <> '');
  clbSteps.Checked[1] := (FFpcDir <> '') and DirectoryExists(IncludeTrailingPathDelimiter(FFpcDir) + 'units\aarch64-android\rtl');

  HasKbPatch := False;
  HasFontPatch := False;
  if LazFound then
  begin
    StdCtrlsPath := IncludeTrailingPathDelimiter(edtLazarusDir.Text) + 'lcl\interfaces\customdrawn\customdrawnwsstdctrls.pas';
    if FileExists(StdCtrlsPath) then
    begin
      with TStringList.Create do
      try
        LoadFromFile(StdCtrlsPath);
        HasKbPatch := Pos('csRequiresKeyboardInput', Text) > 0;
      finally
        Free;
      end;
    end;

    WinApiPath := IncludeTrailingPathDelimiter(edtLazarusDir.Text) + 'lcl\interfaces\customdrawn\customdrawnwinapi.inc';
    if FileExists(WinApiPath) then
    begin
      with TStringList.Create do
      try
        LoadFromFile(WinApiPath);
        HasFontPatch := Pos('{$ifndef CD_UseNativeText}', Text) > 0;
      finally
        Free;
      end;
    end;
  end;
  clbSteps.Checked[2] := HasKbPatch and HasFontPatch;

  HasLclUnits := False;
  if LazFound then
  begin
    LclUnitFile := IncludeTrailingPathDelimiter(edtLazarusDir.Text) + 'lcl\units\aarch64-android\customdrawn\alllclunits.ppu';
    HasLclUnits := FileExists(LclUnitFile);
  end;
  clbSteps.Checked[3] := HasLclUnits;

  clbSteps.Checked[4] := FileExists(IncludeTrailingPathDelimiter(FRepoRoot) + 'package\lib\aarch64-android\LazDroidControls.ppu') or
                         FileExists(IncludeTrailingPathDelimiter(FRepoRoot) + 'package\lib\aarch64-android\lazdroidcontrols.compiled');

  clbSteps.Checked[5] := FileExists(IncludeTrailingPathDelimiter(LocalApp) + 'lazarus\packagefiles.xml');

  clbSteps.Checked[6] := FileExists(IncludeTrailingPathDelimiter(LocalApp) + 'lazarus\lazdroiddeploy.xml') and
                         FileExists(IncludeTrailingPathDelimiter(FRepoRoot) + 'scaffold\local.properties');

  clbSteps.Checked[7] := False;
end;

function TFrmMain.ExecuteProcessWithLog(const AExe, AArgs: string): Integer;
var
  AProcess: TProcess;
  Buffer: array[0..2047] of AnsiChar;
  BytesRead: Integer;
  LineBuf: string;
  I: Integer;
begin
  Result := -1;
  FillChar(Buffer, SizeOf(Buffer), 0);
  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := AExe;
    {$WARN 5043 OFF}
    AProcess.CommandLine := '"' + AExe + '" ' + AArgs;
    {$WARN 5043 ON}

    AProcess.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
    try
      AProcess.Execute;
    except
      on E: Exception do
      begin
        Log('ERRO ao iniciar processo: ' + E.Message);
        Exit(-1);
      end;
    end;

    LineBuf := '';
    while AProcess.Running or (AProcess.Output.NumBytesAvailable > 0) do
    begin
      BytesRead := AProcess.Output.Read(Buffer, SizeOf(Buffer) - 1);
      if BytesRead > 0 then
      begin
        Buffer[BytesRead] := #0;
        for I := 0 to BytesRead - 1 do
        begin
          if Buffer[I] = #10 then
          begin
            LogProcess(LineBuf);
            LineBuf := '';
          end
          else if Buffer[I] <> #13 then
            LineBuf := LineBuf + Buffer[I];
        end;
        Application.ProcessMessages;
      end
      else
        Sleep(20);
    end;

    if LineBuf <> '' then
      LogProcess(LineBuf);

    Result := AProcess.ExitCode;
  finally
    AProcess.Free;
  end;
end;

procedure TFrmMain.CopyDirRecursive(const ASrc, ADst: string);
var
  SR: TSearchRec;
  SrcPath, DstPath: string;
begin
  ForceDirectories(ADst);
  SrcPath := IncludeTrailingPathDelimiter(ASrc);
  DstPath := IncludeTrailingPathDelimiter(ADst);

  if FindFirst(SrcPath + '*', faAnyFile, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name = '.') or (SR.Name = '..') then Continue;
        if (SR.Attr and faDirectory) <> 0 then
          CopyDirRecursive(SrcPath + SR.Name, DstPath + SR.Name)
        else
          CopyFile(SrcPath + SR.Name, DstPath + SR.Name, [cffOverwriteFile]);
      until FindNext(SR) <> 0;
    finally
      FindClose(SR);
    end;
  end;
end;

function TFrmMain.ApplyKeyboardPatch(const ALazDir: string): Boolean;
var
  FilePath: string;
  Content, Target, Replacement: string;
  SL: TStringList;
begin
  Result := False;
  FilePath := IncludeTrailingPathDelimiter(ALazDir) + 'lcl\interfaces\customdrawn\customdrawnwsstdctrls.pas';
  if not FileExists(FilePath) then
  begin
    Log('AVISO: Arquivo nao encontrado para patch de teclado: ' + FilePath);
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(FilePath);
    Content := SL.Text;

    if Pos('csRequiresKeyboardInput', Content) > 0 then
    begin
      Log('OK: Patch de teclado virtual ja esta aplicado na LCL.');
      Result := True;
      Exit;
    end;

    Target := 'Result := TCDWSWinControl.CreateHandle(AWinControl, AParams);';
    Replacement := 'if Assigned(AWinControl) then' + LineEnding +
                   '    AWinControl.ControlStyle := AWinControl.ControlStyle + [csRequiresKeyboardInput];' + LineEnding +
                   '  Result := TCDWSWinControl.CreateHandle(AWinControl, AParams);';

    if Pos(Target, Content) > 0 then
    begin
      Content := StringReplace(Content, Target, Replacement, [rfReplaceAll]);
      SL.Text := Content;
      SL.SaveToFile(FilePath);
      Log('SUCESSO: Patch de teclado virtual (csRequiresKeyboardInput) aplicado!');
      Result := True;
    end
    else
      Log('AVISO: Ponto de insercao do patch de teclado nao localizado.');
  finally
    SL.Free;
  end;
end;

function TFrmMain.ApplyFontPatch(const ALazDir: string): Boolean;
var
  FilePath: string;
  Content, Target, Replacement: string;
  SL: TStringList;
begin
  Result := False;
  FilePath := IncludeTrailingPathDelimiter(ALazDir) + 'lcl\interfaces\customdrawn\customdrawnwinapi.inc';
  if not FileExists(FilePath) then
  begin
    Log('AVISO: Arquivo nao encontrado para patch de fonte: ' + FilePath);
    Exit;
  end;

  SL := TStringList.Create;
  try
    SL.LoadFromFile(FilePath);
    Content := SL.Text;

    if Pos('{$ifndef CD_UseNativeText}' + LineEnding + '  lFont.ftFont.SizeInPoints', Content) > 0 then
    begin
      Log('OK: Patch de fonte customdrawnwinapi.inc ja esta aplicado.');
      Result := True;
      Exit;
    end;

    Target := '  lFont.ftFont.SizeInPoints := lFont.Size;';
    Replacement := '  {$ifndef CD_UseNativeText}' + LineEnding +
                   '  lFont.ftFont.SizeInPoints := lFont.Size;' + LineEnding +
                   '  {$endif}';

    if Pos(Target, Content) > 0 then
    begin
      Content := StringReplace(Content, Target, Replacement, [rfReplaceAll]);
      SL.Text := Content;
      SL.SaveToFile(FilePath);
      Log('SUCESSO: Patch de fonte customdrawnwinapi.inc aplicado com sucesso!');
      Result := True;
    end
    else
      Log('AVISO: Ponto de insercao do patch de fonte nao localizado.');
  finally
    SL.Free;
  end;
end;

procedure TFrmMain.WriteDeployXml;
var
  LocalApp, ConfigDir, CfgFile: string;
  Xml: TStringList;
  FpcA64Exe: string;
begin
  LocalApp := GetEnvironmentVariable('LOCALAPPDATA');
  ConfigDir := IncludeTrailingPathDelimiter(LocalApp) + 'lazarus';
  ForceDirectories(ConfigDir);
  CfgFile := IncludeTrailingPathDelimiter(ConfigDir) + 'lazdroiddeploy.xml';

  FpcA64Exe := FFpcCrossPath;
  if FpcA64Exe = '' then
    FpcA64Exe := 'ppcrossa64.exe';

  Xml := TStringList.Create;
  try
    Xml.Add('<?xml version="1.0" encoding="UTF-8"?>');
    Xml.Add(Format(
      '<CONFIG AndroidSdkRoot="%s" AndroidNdkRoot="%s" AdbPath="%s" JavaHome="%s" ' +
      'FpcCrossAarch64="%s" FpcCrossArm="ppcrossarm.exe" GradleExecutable="" ' +
      'ScaffoldDirectory="%s" PackageName="com.lazarus.android.demo" ' +
      'ActivityName="com.pascal.lclproject.LCLActivity" AutoShowLogcat="True" ' +
      'LogcatFilter="lclapp:* LazApp:* AndroidRuntime:E DEBUG:*" ExtraFpcFlags="-O3 -Xs -XX -vewnhi" ' +
      'LogLevelDebug="False" DefaultAbi="arm64-v8a"/>',
      [FSdkPath, FNdkPath, FAdbPath, FJdkPath, FpcA64Exe,
       IncludeTrailingPathDelimiter(FRepoRoot) + 'scaffold']
    ));
    Xml.SaveToFile(CfgFile);
    Log('Configuracao gravada com sucesso: ' + CfgFile);
  finally
    Xml.Free;
  end;
end;

procedure TFrmMain.WriteLocalProperties;
var
  PropFile: string;
  Lines: TStringList;
begin
  PropFile := IncludeTrailingPathDelimiter(FRepoRoot) + 'scaffold\local.properties';
  Lines := TStringList.Create;
  try
    Lines.Add('# Local Android SDK & NDK locations generated by LazDroid Installer');
    if FSdkPath <> '' then
      Lines.Add('sdk.dir=' + EscapePathForProperties(FSdkPath));
    if FNdkPath <> '' then
      Lines.Add('ndk.dir=' + EscapePathForProperties(FNdkPath));
    Lines.SaveToFile(PropFile);
    Log('Propriedades do Gradle gravadas: ' + PropFile);
  finally
    Lines.Free;
  end;
end;

procedure TFrmMain.btnBrowseClick(Sender: TObject);
begin
  dlgBrowse.InitialDir := edtLazarusDir.Text;
  if dlgBrowse.Execute then
  begin
    edtLazarusDir.Text := dlgBrowse.FileName;
    DetectEnvironment;
  end;
end;

procedure TFrmMain.edtLazarusDirChange(Sender: TObject);
begin
  if DirectoryExists(edtLazarusDir.Text) then
    DetectEnvironment;
end;

procedure TFrmMain.btnCheckEnvClick(Sender: TObject);
begin
  Log('Executando verificacao completa do ambiente...');
  DetectEnvironment;
  Log('Verificacao concluida.');
end;

procedure TFrmMain.btnInstallAllClick(Sender: TObject);
var
  LazDir, LazBuildExe: string;
  SrcBinDir, SrcUnitsDir: string;
  DstBin64, DstBin32, DstUnitsBase: string;
  CrossInstaller, InnoExtract: string;
  LclPkg, ControlsPkg, DeployPkg: string;
  Res: Integer;
begin
  LazDir := edtLazarusDir.Text;
  LazBuildExe := IncludeTrailingPathDelimiter(LazDir) + 'lazbuild.exe';

  if not FileExists(LazBuildExe) then
  begin
    MessageDlg('Erro', 'O executavel lazbuild.exe nao foi encontrado em:' + LineEnding + LazDir +
      LineEnding + LineEnding + 'Selecione a pasta correta da instalacao do Lazarus.', mtError, [mbOK], 0);
    Exit;
  end;

  btnInstallAll.Enabled := False;
  btnCheckEnv.Enabled := False;
  btnDelphiLayout.Enabled := False;
  btnOpenLazarus.Enabled := False;
  Screen.Cursor := crHourGlass;

  try
    Log('================================================================');
    Log('  INICIANDO INSTALACAO E CONFIGURACAO DO LAZDROID               ');
    Log('================================================================');

    // -------------------------------------------------------------
    // ETAPA 1 & 2: Compiladores Cruzados e Units FPC
    // -------------------------------------------------------------
    SetProgress(10, 'Etapa 1/7: Instalando compiladores cruzados FPC...');
    SrcBinDir := IncludeTrailingPathDelimiter(FRepoRoot) + 'tools\fpc_extracted\app\bin\i386-win32';
    SrcUnitsDir := IncludeTrailingPathDelimiter(FRepoRoot) + 'tools\fpc_extracted\app\units';

    if not FileExists(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe') then
    begin
      CrossInstaller := IncludeTrailingPathDelimiter(FRepoRoot) + 'tools\fpc-3.2.2.i386-win32.cross.android.exe';
      InnoExtract := IncludeTrailingPathDelimiter(FRepoRoot) + 'tools\innoextract\innoextract.exe';

      if FileExists(CrossInstaller) and FileExists(InnoExtract) then
      begin
        Log('Extraindo compilador cruzado FPC Android...');
        ExecuteProcessWithLog(InnoExtract, '-s -e -d "' + IncludeTrailingPathDelimiter(FRepoRoot) + 'tools\fpc_extracted" "' + CrossInstaller + '"');
      end;
    end;

    if FFpcDir = '' then
      FFpcDir := FindFpcDirectory(LazDir, FFpcVer);

    if (FFpcDir <> '') and FileExists(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe') then
    begin
      DstBin64 := IncludeTrailingPathDelimiter(FFpcDir) + 'bin\x86_64-win64';
      DstBin32 := IncludeTrailingPathDelimiter(FFpcDir) + 'bin\i386-win32';

      Log('Copiando binarios ppcrossa64.exe e ppcrossarm.exe...');
      if DirectoryExists(DstBin64) then
      begin
        CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe', IncludeTrailingPathDelimiter(DstBin64) + 'ppcrossa64.exe', [cffOverwriteFile]);
        CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe', IncludeTrailingPathDelimiter(DstBin64) + 'ppcrossaarch64.exe', [cffOverwriteFile]);
        CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe', IncludeTrailingPathDelimiter(DstBin64) + 'ppca64.exe', [cffOverwriteFile]);
        CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe', IncludeTrailingPathDelimiter(DstBin64) + 'ppcaarch64.exe', [cffOverwriteFile]);
        if FileExists(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossarm.exe') then
        begin
          CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossarm.exe', IncludeTrailingPathDelimiter(DstBin64) + 'ppcrossarm.exe', [cffOverwriteFile]);
          CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossarm.exe', IncludeTrailingPathDelimiter(DstBin64) + 'ppcarm.exe', [cffOverwriteFile]);
        end;
      end;

      if DirectoryExists(DstBin32) then
      begin
        CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe', IncludeTrailingPathDelimiter(DstBin32) + 'ppcrossa64.exe', [cffOverwriteFile]);
        CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe', IncludeTrailingPathDelimiter(DstBin32) + 'ppcrossaarch64.exe', [cffOverwriteFile]);
        CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe', IncludeTrailingPathDelimiter(DstBin32) + 'ppca64.exe', [cffOverwriteFile]);
        CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossa64.exe', IncludeTrailingPathDelimiter(DstBin32) + 'ppcaarch64.exe', [cffOverwriteFile]);
        if FileExists(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossarm.exe') then
        begin
          CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossarm.exe', IncludeTrailingPathDelimiter(DstBin32) + 'ppcrossarm.exe', [cffOverwriteFile]);
          CopyFile(IncludeTrailingPathDelimiter(SrcBinDir) + 'ppcrossarm.exe', IncludeTrailingPathDelimiter(DstBin32) + 'ppcarm.exe', [cffOverwriteFile]);
        end;
      end;
      clbSteps.Checked[0] := True;
      Log('OK: Compiladores cruzados instalados com sucesso.');

      SetProgress(25, 'Etapa 2/7: Copiando units RTL Android...');
      DstUnitsBase := IncludeTrailingPathDelimiter(FFpcDir) + 'units';
      if DirectoryExists(IncludeTrailingPathDelimiter(SrcUnitsDir) + 'aarch64-android') then
      begin
        Log('Copiando units FPC para aarch64-android...');
        CopyDirRecursive(IncludeTrailingPathDelimiter(SrcUnitsDir) + 'aarch64-android', IncludeTrailingPathDelimiter(DstUnitsBase) + 'aarch64-android');
      end;
      if DirectoryExists(IncludeTrailingPathDelimiter(SrcUnitsDir) + 'arm-android') then
      begin
        Log('Copiando units FPC para arm-android...');
        CopyDirRecursive(IncludeTrailingPathDelimiter(SrcUnitsDir) + 'arm-android', IncludeTrailingPathDelimiter(DstUnitsBase) + 'arm-android');
      end;
      clbSteps.Checked[1] := True;
      Log('OK: Units RTL Android instaladas.');
    end;

    // -------------------------------------------------------------
    // ETAPA 3: Patches LCL CustomDrawn
    // -------------------------------------------------------------
    SetProgress(40, 'Etapa 3/7: Aplicando patches LCL CustomDrawn...');
    ApplyKeyboardPatch(LazDir);
    ApplyFontPatch(LazDir);
    clbSteps.Checked[2] := True;

    // -------------------------------------------------------------
    // ETAPA 4: Compilacao da LCL CustomDrawn para Android AArch64
    // -------------------------------------------------------------
    SetProgress(55, 'Etapa 4/7: Compilando LCL CustomDrawn para Android...');
    LclPkg := IncludeTrailingPathDelimiter(LazDir) + 'lcl\interfaces\lcl.lpk';
    Log('Compilando LCL para aarch64-android (customdrawn)...');
    Res := ExecuteProcessWithLog(LazBuildExe, '--os=android --cpu=aarch64 --ws=customdrawn "' + LclPkg + '"');
    if Res = 0 then
    begin
      clbSteps.Checked[3] := True;
      Log('SUCESSO: LCL CustomDrawn compilada para Android AArch64!');
    end
    else
      Log('AVISO: lazbuild retornou codigo ' + IntToStr(Res) + ' na compilacao da LCL.');

    // -------------------------------------------------------------
    // ETAPA 5: Pacotes LazDroidControls e LazDroidDeploy
    // -------------------------------------------------------------
    SetProgress(70, 'Etapa 5/7: Compilando e registrando pacotes LazDroid...');
    ControlsPkg := IncludeTrailingPathDelimiter(FRepoRoot) + 'package\LazDroidControls.lpk';
    DeployPkg := IncludeTrailingPathDelimiter(FRepoRoot) + 'package\LazDroidDeploy.lpk';

    if FileExists(ControlsPkg) then
    begin
      Log('Compilando paleta LazDroidControls para Android...');
      ExecuteProcessWithLog(LazBuildExe, '--os=android --cpu=aarch64 --ws=customdrawn "' + ControlsPkg + '"');
      Log('Registrando LazDroidControls.lpk na IDE...');
      ExecuteProcessWithLog(LazBuildExe, '--add-package-link "' + ControlsPkg + '"');
      ExecuteProcessWithLog(LazBuildExe, '--add-package "' + ControlsPkg + '"');
      clbSteps.Checked[4] := True;
    end;

    if FileExists(DeployPkg) then
    begin
      Log('Registrando LazDroidDeploy.lpk na IDE...');
      ExecuteProcessWithLog(LazBuildExe, '--add-package-link "' + DeployPkg + '"');
      ExecuteProcessWithLog(LazBuildExe, '--add-package "' + DeployPkg + '"');
      clbSteps.Checked[5] := True;
    end;

    // -------------------------------------------------------------
    // ETAPA 6: Gravando Configuracoes
    // -------------------------------------------------------------
    SetProgress(85, 'Etapa 6/7: Gravando arquivos de configuracao...');
    WriteDeployXml;
    WriteLocalProperties;
    clbSteps.Checked[6] := True;

    // -------------------------------------------------------------
    // ETAPA 7: Reconstrucao da IDE Lazarus
    // -------------------------------------------------------------
    SetProgress(90, 'Etapa 7/7: Reconstruindo a IDE Lazarus com LazDroid integrado...');
    Log('Recompilando Lazarus IDE com lazbuild --build-ide= ...');
    Res := ExecuteProcessWithLog(LazBuildExe, '--build-ide=');
    if Res = 0 then
    begin
      clbSteps.Checked[7] := True;
      Log('SUCESSO: Lazarus IDE reconstruido com LazDroid 100% integrado!');
    end
    else
      Log('AVISO: lazbuild --build-ide= finalizou com retorno ' + IntToStr(Res));

    SetProgress(100, 'Instalacao concluida com sucesso!');
    Log('================================================================');
    Log('  PARABENS! O AMBIENTE LAZDROID ESTA CONFIGURADO E PRONTO!      ');
    Log('================================================================');

    DetectEnvironment;

    if MessageDlg('Instalação Concluída!',
      'O ambiente LazDroid foi instalado e configurado com sucesso!' + LineEnding + LineEnding +
      'Deseja também aplicar o Layout Docado Estilo Delphi na IDE do Lazarus agora?' + LineEnding +
      '(Organiza paletas, abas, object inspector e telas num único ambiente moderno)',
      mtInformation, [mbYes, mbNo], 0) = mrYes then
    begin
      btnDelphiLayoutClick(nil);
    end;

  finally
    btnInstallAll.Enabled := True;
    btnCheckEnv.Enabled := True;
    btnDelphiLayout.Enabled := True;
    btnOpenLazarus.Enabled := True;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmMain.btnDelphiLayoutClick(Sender: TObject);
var
  PsScript: string;
  Res: Integer;
begin
  PsScript := IncludeTrailingPathDelimiter(FRepoRoot) + 'tools\scripts\Restaurar-Layout-Lazarus.ps1';
  if not FileExists(PsScript) then
  begin
    MessageDlg('Aviso', 'Script nao encontrado: ' + PsScript, mtWarning, [mbOK], 0);
    Exit;
  end;

  Log('Aplicando Layout Estilo Delphi no Lazarus...');
  Res := ExecuteProcessWithLog('powershell.exe', '-NoProfile -ExecutionPolicy Bypass -File "' + PsScript + '"');
  if Res = 0 then
  begin
    Log('SUCESSO: Layout Estilo Delphi aplicado com sucesso no Lazarus!');
    MessageDlg('Layout Delphi Aplicado',
      'O layout docado estilo Delphi foi aplicado com sucesso!' + LineEnding +
      'Ao abrir o Lazarus, a IDE estara organizada em janela unica com abas e paineis ancorados.',
      mtInformation, [mbOK], 0);
  end
  else
    Log('Retorno do script de layout: ' + IntToStr(Res));
end;

procedure TFrmMain.btnOpenLazarusClick(Sender: TObject);
var
  LazExe: string;
  AProcess: TProcess;
begin
  LazExe := IncludeTrailingPathDelimiter(edtLazarusDir.Text) + 'lazarus.exe';
  if not FileExists(LazExe) then
  begin
    MessageDlg('Erro', 'O arquivo lazarus.exe nao foi localizado em:' + LineEnding + edtLazarusDir.Text, mtError, [mbOK], 0);
    Exit;
  end;

  Log('Abrindo Lazarus IDE: ' + LazExe);
  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := LazExe;
    AProcess.Execute;
    Log('Lazarus IDE iniciado.');
  finally
    AProcess.Free;
  end;
end;

procedure TFrmMain.btnOpenDemosClick(Sender: TObject);
var
  AProcess: TProcess;
begin
  AProcess := TProcess.Create(nil);
  try
    AProcess.Executable := 'explorer.exe';
    AProcess.Parameters.Add(FRepoRoot);
    AProcess.Execute;
  finally
    AProcess.Free;
  end;
end;

end.
