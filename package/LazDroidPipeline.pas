{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidPipeline.pas
  Descrição: Orquestrador da esteira de 6 estágios (Pre-check, FPC, Gradle, Deploy, Launch, Logcat).
}
unit LazDroidPipeline;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, FileUtil, LazFileUtils, LazDroidConfig, LazDroidDeviceManager,
  LazDroidProcessRunner, LazIDEIntf, ProjectIntf;

type
  { TPipelineStage }
  TPipelineStage = (
    stageIdle,
    stagePreCheck,
    stagePascalBuild,
    stagePackaging,
    stageDeploy,
    stageLaunch,
    stageLogcat,
    stageCompleted,
    stageFailed
  );

  TOnStageChange = procedure(AOldStage, ANewStage: TPipelineStage; const ADescription: string) of object;
  TOnPipelineFinish = procedure(ASuccess: Boolean; const AFinalMsg: string) of object;

  { TLazDroidPipeline }
  TLazDroidPipeline = class
  private
    FSettings: TLazDroidSettings;
    FDevManager: TLazDroidDeviceManager;
    FCurrentStage: TPipelineStage;
    FActiveDevice: TAndroidDevice;
    FTargetAbi: TAndroidAbi;
    FSelectedSerial: string;
    FIsDebugMode: Boolean;
    FActiveRunner: TLazDroidProcessThread;
    FLogcatRunner: TLazDroidProcessThread;
    FGdbServerRunner: TLazDroidProcessThread;
    FIsRunning: Boolean;
    FCancelRequested: Boolean;
    FScaffoldPath: string;
    FOutputApkPath: string;
    FCurrentAppTitle: string;
    FCurrentPackageName: string;
    FOverwriteConfirmed: Boolean;

    FOnStageChange: TOnStageChange;
    FOnPipelineFinish: TOnPipelineFinish;

    procedure SetStage(ANewStage: TPipelineStage; const ADescription: string);
    procedure LogMsg(const AText: string; AUrgency: TLazDroidLogUrgency = luInfo);

    procedure RunPreCheck;
    procedure RunPascalBuild;
    procedure RunPackaging;
    procedure RunDeploy;
    procedure RunLaunch;
    procedure SetupGdbServer;
    procedure StartLogcat;

    procedure HandleProcessFinished(AExitCode: Integer; const AErrorMsg: string);
    function ResolveScaffoldPath: string;
    function ResolveTargetProjectFile(out AMainPrjFile: string): Boolean;
  public
    constructor Create(ASettings: TLazDroidSettings = nil);
    destructor Destroy; override;

    procedure Start(const ATargetSerial: string = ''; ADebugMode: Boolean = False);
    procedure Cancel;

    property CurrentStage: TPipelineStage read FCurrentStage;
    property ActiveDevice: TAndroidDevice read FActiveDevice;
    property CurrentAppTitle: string read FCurrentAppTitle;
    property CurrentPackageName: string read FCurrentPackageName;
    property IsRunning: Boolean read FIsRunning;
    property IsDebugMode: Boolean read FIsDebugMode write FIsDebugMode;
    property OnStageChange: TOnStageChange read FOnStageChange write FOnStageChange;
    property OnPipelineFinish: TOnPipelineFinish read FOnPipelineFinish write FOnPipelineFinish;
  end;

function StageToString(AStage: TPipelineStage): string;

implementation

function StageToString(AStage: TPipelineStage): string;
begin
  case AStage of
    stageIdle: Result := 'Parado';
    stagePreCheck: Result := '1/6: Verificando Conexões e Dispositivos';
    stagePascalBuild: Result := '2/6: Compilando Binário Pascal (.so)';
    stagePackaging: Result := '3/6: Empacotando APK via Gradle';
    stageDeploy: Result := '4/6: Instalando APK no Dispositivo';
    stageLaunch: Result := '5/6: Iniciando Activity na Tela';
    stageLogcat: Result := '6/6: Monitorando Logcat em Tempo Real';
    stageCompleted: Result := 'Sucesso: Deploy Concluído!';
    stageFailed: Result := 'Falha na Execução';
  else
    Result := 'Desconhecido';
  end;
end;

{ TLazDroidPipeline }

constructor TLazDroidPipeline.Create(ASettings: TLazDroidSettings);
begin
  inherited Create;
  if Assigned(ASettings) then
    FSettings := ASettings
  else
    FSettings := DroidConfig;

  FDevManager := TLazDroidDeviceManager.Create(FSettings.AdbPath);
  FCurrentStage := stageIdle;
  FIsRunning := False;
  FCancelRequested := False;
end;

destructor TLazDroidPipeline.Destroy;
begin
  Cancel;
  FDevManager.Free;
  inherited Destroy;
end;

procedure TLazDroidPipeline.SetStage(ANewStage: TPipelineStage; const ADescription: string);
var
  Old: TPipelineStage;
begin
  Old := FCurrentStage;
  FCurrentStage := ANewStage;
  LogMsg(Format('>>> [%s] %s', [StageToString(ANewStage), ADescription]), luInfo);
  if Assigned(FOnStageChange) then
    FOnStageChange(Old, ANewStage, ADescription);
end;

procedure TLazDroidPipeline.LogMsg(const AText: string; AUrgency: TLazDroidLogUrgency);
begin
  LogToLazarusMessages(AText, AUrgency);
end;

function TLazDroidPipeline.ResolveScaffoldPath: string;
begin
  if (FSettings.ScaffoldDirectory <> '') and DirectoryExists(FSettings.ScaffoldDirectory) then
    Result := FSettings.ScaffoldDirectory
  else
  begin
    // Procura na pasta do projeto ativo ou na pasta do plugin
    if Assigned(LazarusIDE) and Assigned(LazarusIDE.ActiveProject) then
    begin
      Result := ExtractFilePath(LazarusIDE.ActiveProject.MainFile.Filename) + 'scaffold';
      if not DirectoryExists(Result) then
        Result := ExtractFilePath(LazarusIDE.ActiveProject.MainFile.Filename) + '..' + PathDelim + 'scaffold';
    end;

    if not DirectoryExists(Result) then
      Result := 'd:\Projetos AntiGravity\LazarusAndroid\scaffold';
  end;
end;

function SanitizePackageIdentifier(const S: string): string;
var
  i: Integer;
  c: Char;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    c := S[i];
    if (c in ['a'..'z']) or (c in ['0'..'9']) or (c = '_') then
      Result := Result + c
    else if (c in ['A'..'Z']) then
      Result := Result + LowerCase(c);
  end;
  if Result = '' then
    Result := 'app';
  if not (Result[1] in ['a'..'z']) then
    Result := 'app' + Result;
end;

procedure UpdateScaffoldStringsXml(const AScaffoldDir, AAppName: string);
var
  StringsXmlPath: string;
  Content: string;
  List: TStringList;
begin
  if Trim(AAppName) = '' then Exit;
  StringsXmlPath := IncludeTrailingPathDelimiter(AScaffoldDir) +
    'app' + PathDelim + 'src' + PathDelim + 'main' + PathDelim + 'res' + PathDelim + 'values' + PathDelim + 'strings.xml';
  ForceDirectories(ExtractFilePath(StringsXmlPath));
  Content := '<?xml version="1.0" encoding="utf-8"?>' + LineEnding +
             '<resources>' + LineEnding +
             '    <string name="app_name">' + AAppName + '</string>' + LineEnding +
             '</resources>' + LineEnding;
  List := TStringList.Create;
  try
    List.Text := Content;
    List.SaveToFile(StringsXmlPath);
  finally
    List.Free;
  end;
end;

function TLazDroidPipeline.ResolveTargetProjectFile(out AMainPrjFile: string): Boolean;
var
  Prj: TLazProject;
  CurFile: string;
  CleanIdent: string;
begin
  Result := False;
  AMainPrjFile := '';

  if not Assigned(LazarusIDE) or not Assigned(LazarusIDE.ActiveProject) then
  begin
    LogMsg('ERRO: Nenhum projeto ativo aberto no Lazarus IDE.', luError);
    Exit(False);
  end;

  Prj := LazarusIDE.ActiveProject;

  // Se o projeto for novo / virtual / não salvo no disco:
  if Prj.IsVirtual or (Prj.ProjectInfoFile = '') or not FileExists(Prj.MainFile.Filename) then
  begin
    LogMsg('O projeto atual ainda não foi salvo em disco.', luWarning);
    LogMsg('Para compilar para Android, o projeto deve ser salvo primeiro...', luInfo);

    // Abre a janela de salvar projeto do Lazarus
    if LazarusIDE.DoSaveProject([]) <> mrOk then
    begin
      LogMsg('Operação cancelada: O projeto precisa ser salvo antes de compilar para Android.', luWarning);
      Exit(False);
    end;
  end;

  // Garante que todas as alterações abertas no editor sejam salvas no disco
  LazarusIDE.DoSaveAll([]);

  if Assigned(Prj.MainFile) and FileExists(Prj.MainFile.Filename) then
  begin
    AMainPrjFile := Prj.MainFile.Filename;
    Result := True;
  end
  else if (Prj.ProjectInfoFile <> '') then
  begin
    CurFile := ChangeFileExt(Prj.ProjectInfoFile, '.lpr');
    if FileExists(CurFile) then
    begin
      AMainPrjFile := CurFile;
      Result := True;
    end;
  end;

  if not Result then
  begin
    LogMsg('ERRO FATAL: Não foi possível localizar o arquivo principal (.lpr) do projeto ativo.', luError);
    LogMsg('Certifique-se de salvar o projeto em uma pasta antes de compilar.', luInfo);
    Exit(False);
  end;

  // Determina Título e Identificador da Aplicação baseado no projeto ativo carregado na IDE
  if (Prj.Title <> '') and not SameText(Prj.Title, 'project1') then
    FCurrentAppTitle := Prj.Title
  else
    FCurrentAppTitle := ChangeFileExt(ExtractFileName(AMainPrjFile), '');

  CleanIdent := SanitizePackageIdentifier(FCurrentAppTitle);
  if (CleanIdent = '') or SameText(CleanIdent, 'project1') then
    CleanIdent := SanitizePackageIdentifier(ChangeFileExt(ExtractFileName(AMainPrjFile), ''));
  if CleanIdent = '' then
    CleanIdent := 'app';

  if SameText(ExtractFileName(AMainPrjFile), 'LazAndroidDemo.lpr') then
    FCurrentPackageName := DEFAULT_PACKAGE_NAME
  else if (FSettings.PackageName <> '') and (FSettings.PackageName <> DEFAULT_PACKAGE_NAME) then
    FCurrentPackageName := FSettings.PackageName
  else
    FCurrentPackageName := 'com.lazarus.android.' + CleanIdent;
end;

procedure TLazDroidPipeline.Start(const ATargetSerial: string; ADebugMode: Boolean);
begin
  if FIsRunning then
  begin
    LogMsg('Pipeline já em execução. Cancele antes de reiniciar.', luWarning);
    Exit;
  end;

  FIsDebugMode := ADebugMode;
  FIsRunning := True;
  FCancelRequested := False;
  FOverwriteConfirmed := False;
  FSelectedSerial := ATargetSerial;

  LogMsg('=========================================================', luInfo);
  if FIsDebugMode then
    LogMsg('  INICIANDO PIPELINE LAZDROID-DEPLOY (MODO DEPURAÇÃO GDB)', luSuccess)
  else
    LogMsg('  INICIANDO PIPELINE LAZDROID-DEPLOY (ANDROID AUTOMATION)', luSuccess);
  LogMsg('=========================================================', luInfo);

  RunPreCheck;
end;

procedure TLazDroidPipeline.Cancel;
begin
  FCancelRequested := True;
  if Assigned(FActiveRunner) then
  begin
    FActiveRunner.RequestCancel;
    FActiveRunner := nil;
  end;

  if Assigned(FLogcatRunner) then
  begin
    FLogcatRunner.RequestCancel;
    FLogcatRunner := nil;
  end;

  if Assigned(FGdbServerRunner) then
  begin
    FGdbServerRunner.RequestCancel;
    FGdbServerRunner := nil;
  end;

  if FIsRunning then
  begin
    FIsRunning := False;
    SetStage(stageFailed, 'Pipeline cancelado pelo usuário.');
    if Assigned(FOnPipelineFinish) then
      FOnPipelineFinish(False, 'Operação cancelada.');
  end;
end;

procedure TLazDroidPipeline.RunPreCheck;
var
  Errors: string;
  DevFound: Boolean;
  TargetPrj: string;
begin
  SetStage(stagePreCheck, 'Validando ambiente e detectando aparelho...');

  // Validação de configurações mínimas
  if not FSettings.ValidatePaths(Errors) then
  begin
    LogMsg('Aviso de Validação de Caminhos:' + LineEnding + Errors, luWarning);
  end;

  // 1. Identifica rigorosamente o projeto ativo carregado na IDE do Lazarus
  if not ResolveTargetProjectFile(TargetPrj) then
  begin
    FIsRunning := False;
    SetStage(stageFailed, 'Projeto ativo não definido ou não salvo.');
    if Assigned(FOnPipelineFinish) then
      FOnPipelineFinish(False, 'Operação cancelada: Salve o projeto antes de compilar para Android.');
    Exit;
  end;

  LogMsg(Format('>>> [PROJETO ATIVO NA IDE] %s', [TargetPrj]), luSuccess);
  LogMsg(Format('>>> Aplicação: "%s" | Pacote Android: %s', [FCurrentAppTitle, FCurrentPackageName]), luInfo);

  // 2. Busca do dispositivo Android
  if FSelectedSerial <> '' then
  begin
    DevFound := FDevManager.IsDeviceConnected(FSelectedSerial);
    if DevFound then
    begin
      FActiveDevice.Serial := FSelectedSerial;
      FActiveDevice.PrimaryAbi := FDevManager.QueryDeviceAbi(FSelectedSerial);
      FActiveDevice.AndroidVersion := FDevManager.QueryAndroidVersion(FSelectedSerial);
      FActiveDevice.Model := 'Dispositivo ' + FSelectedSerial;
    end;
  end
  else
  begin
    DevFound := FDevManager.GetFirstReadyDevice(FActiveDevice);
  end;

  if not DevFound then
  begin
    LogMsg('ERRO FATAL: Nenhum dispositivo Android pronto detectado via USB/ADB.', luError);
    LogMsg('Certifique-se de que a Depuração USB está ativada no celular.', luInfo);
    FIsRunning := False;
    SetStage(stageFailed, 'Dispositivo não encontrado.');
    if Assigned(FOnPipelineFinish) then
      FOnPipelineFinish(False, 'Nenhum dispositivo Android pronto conectado.');
    Exit;
  end;

  FTargetAbi := FSettings.StringToAbi(FActiveDevice.PrimaryAbi);
  LogMsg(Format('Aparelho Selecionado: %s | ABI: %s | SO: %s',
    [FActiveDevice.Model, FActiveDevice.PrimaryAbi, FActiveDevice.AndroidVersion]), luSuccess);

  FScaffoldPath := ResolveScaffoldPath;
  if not DirectoryExists(FScaffoldPath) then
  begin
    LogMsg('ERRO FATAL: Diretório do scaffold Android não localizado: ' + FScaffoldPath, luError);
    FIsRunning := False;
    SetStage(stageFailed, 'Scaffold não localizado.');
    if Assigned(FOnPipelineFinish) then
      FOnPipelineFinish(False, 'Diretório do Scaffold não encontrado.');
    Exit;
  end;

  // 3. Verificação de Sobrescrita:
  // Se já existe um aplicativo instalado com esse mesmo pacote no aparelho, pergunta ao usuário se quer passar por cima
  if FDevManager.IsPackageInstalled(FActiveDevice.Serial, FCurrentPackageName) then
  begin
    if MessageDlg('LazDroid - Confirmação de Instalação',
         Format('O aplicativo "%s"' + LineEnding +
                'Pacote: %s' + LineEnding + LineEnding +
                'já está instalado no dispositivo conectado (%s).' + LineEnding + LineEnding +
                'Deseja sobrescrever (passar por cima) da versão existente?',
                [FCurrentAppTitle, FCurrentPackageName, FActiveDevice.Model]),
         mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    begin
      LogMsg(Format('Deploy cancelado pelo usuário: O aplicativo "%s" existente no aparelho foi mantido sem alterações.',
        [FCurrentAppTitle]), luWarning);
      FIsRunning := False;
      SetStage(stageIdle, 'Deploy cancelado para preservar aplicativo existente.');
      if Assigned(FOnPipelineFinish) then
        FOnPipelineFinish(False, 'Deploy cancelado para manter versão existente.');
      Exit;
    end;

    FOverwriteConfirmed := True;
    LogMsg(Format('Confirmado pelo usuário: A versão existente de "%s" será sobrescrita no aparelho.', [FCurrentAppTitle]), luInfo);
  end;

  // Prosseguir para Estágio 2
  RunPascalBuild;
end;

procedure TLazDroidPipeline.RunPascalBuild;
var
  PrjFile: string;
  CompilerExe: string;
  TargetCpu: string;
  TargetAbiStr: string;
  JniOutDir: string;
  UnitOutDir: string;
  NdkBin: string;
  NdkLib: string;
  LazDir: string;
  LclCdDir: string;
  PkgDir: string;
  OtherUnits: string;
  UnitPath: string;
  OtherList: TStringList;
  i: Integer;
  Params: TStringList;
  Env: TStringList;
begin
  SetStage(stagePascalBuild, 'Invocando Free Pascal Cross-Compiler...');

  if not ResolveTargetProjectFile(PrjFile) then
  begin
    LogMsg('ERRO: Nenhum projeto Pascal válido selecionado para compilação.', luError);
    FIsRunning := False;
    SetStage(stageFailed, 'Arquivo de projeto ausente.');
    Exit;
  end;

  TargetAbiStr := FSettings.AbiToString(FTargetAbi);
  CompilerExe  := FSettings.GetFpcCompilerForAbi(FTargetAbi);
  TargetCpu    := FSettings.GetFpcTargetCpuForAbi(FTargetAbi);

  // Validação amigável da existência do compilador cruzado FPC
  if (CompilerExe = '') or
     ((ExtractFilePath(CompilerExe) <> '') and not FileExists(CompilerExe)) or
     ((ExtractFilePath(CompilerExe) = '') and (FindDefaultExecutablePath(CompilerExe) = '')) then
  begin
    LogMsg(Format('ERRO: O compilador cruzado FPC "%s" não foi encontrado no sistema.', [CompilerExe]), luError);
    LogMsg(Format('O seu dispositivo conectado requer a arquitetura: %s (%s).', [TargetAbiStr, TargetCpu]), luWarning);
    LogMsg('COMO RESOLVER:', luInfo);
    LogMsg('1. É necessário ter o cross-compiler FPC para Android (ppcrossa64.exe) e a RTL instalados.', luInfo);
    LogMsg('2. No menu "Ferramentas -> Opções -> Ambiente -> LazDroid Android Deploy", configure o caminho do compilador.', luInfo);
    FIsRunning := False;
    SetStage(stageFailed, 'Compilador cruzado FPC não localizado.');
    Exit;
  end;

  JniOutDir    := IncludeTrailingPathDelimiter(FScaffoldPath) +
                  'app' + PathDelim + 'src' + PathDelim + 'main' + PathDelim +
                  'jniLibs' + PathDelim + TargetAbiStr;

  ForceDirectories(JniOutDir);

  UnitOutDir   := IncludeTrailingPathDelimiter(ExtractFilePath(PrjFile)) +
                  'lib' + PathDelim + TargetCpu + '-android';
  ForceDirectories(UnitOutDir);

  // Remove qualquer binário anterior para garantir que um build quebrado nunca empacote versão antiga
  if FileExists(JniOutDir + PathDelim + DEFAULT_SO_NAME) then
    DeleteFile(JniOutDir + PathDelim + DEFAULT_SO_NAME);

  Params := TStringList.Create;
  Env := TStringList.Create;
  try
    Params.Add('-Tandroid');
    Params.Add('-P' + TargetCpu);
    Params.Add('-fPIC');
    Params.Add('-FE' + JniOutDir);
    Params.Add('-FU' + UnitOutDir);
    Params.Add('-o' + JniOutDir + PathDelim + DEFAULT_SO_NAME);

    // Símbolos de depuração e números de linha DWARF 2 (estilo Delphi)
    Params.Add('-gw2');
    Params.Add('-godwarfsets');
    Params.Add('-gl');

    // Ferramentas binárias do Android NDK (as.exe, ld.exe)
    NdkBin := FSettings.GetNdkToolchainBinForAbi(FTargetAbi);
    if NdkBin <> '' then
      Params.Add('-FD' + NdkBin);

    // Bibliotecas de sistema do NDK (libc.so, liblog.so, crtbegin_so.o)
    NdkLib := FSettings.GetNdkSysrootLibForAbi(FTargetAbi);
    if NdkLib <> '' then
      Params.Add('-Fl' + NdkLib);

    // Flags extras do usuário (O3, Xs, etc)
    if FSettings.ExtraFpcFlags <> '' then
    begin
      Params.Delimiter := ' ';
      Params.DelimitedText := Params.DelimitedText + ' ' + FSettings.ExtraFpcFlags;
    end;

    // Incluir diretório do projeto nas units e arquivos de inclusão
    Params.Add('-Fu' + ExtractFilePath(PrjFile));
    Params.Add('-Fi' + ExtractFilePath(PrjFile));

    // Suporte automático a LCL CustomDrawn para Android caso esteja presente no Lazarus
    LazDir := 'C:\lazarus';
    if not DirectoryExists(LazDir) and DirectoryExists('D:\lazarus') then
      LazDir := 'D:\lazarus';

    if DirectoryExists(LazDir) then
    begin
      LclCdDir := LazDir + PathDelim + 'lcl' + PathDelim + 'units' + PathDelim + TargetCpu + '-android' + PathDelim + 'customdrawn';
      if DirectoryExists(LclCdDir) then
      begin
        Params.Add('-Fu' + LclCdDir);
        Params.Add('-Fu' + LazDir + PathDelim + 'lcl' + PathDelim + 'units' + PathDelim + TargetCpu + '-android');
        Params.Add('-Fu' + LazDir + PathDelim + 'components' + PathDelim + 'lazutils' + PathDelim + 'lib' + PathDelim + TargetCpu + '-android');
        Params.Add('-Fu' + LazDir + PathDelim + 'components' + PathDelim + 'freetype' + PathDelim + 'lib' + PathDelim + TargetCpu + '-android');
        Params.Add('-Fu' + LazDir + PathDelim + 'packager' + PathDelim + 'units' + PathDelim + TargetCpu + '-android');
        Params.Add('-dLCL');
        Params.Add('-dLCLcustomdrawn');
      end;
    end;

    // Suporte automático aos componentes do pacote LazDroid (LazDroidControls, etc.)
    PkgDir := '';
    if (FScaffoldPath <> '') then
      PkgDir := IncludeTrailingPathDelimiter(ExtractFilePath(ExcludeTrailingPathDelimiter(FScaffoldPath))) + 'package';
    if (PkgDir = '') or not DirectoryExists(PkgDir) then
      PkgDir := ExtractFilePath(PrjFile) + '..' + PathDelim + 'package';

    if DirectoryExists(PkgDir) then
    begin
      Params.Add('-Fu' + PkgDir);
      Params.Add('-Fi' + PkgDir);
      if DirectoryExists(PkgDir + PathDelim + 'lib' + PathDelim + TargetCpu + '-android') then
        Params.Add('-Fu' + PkgDir + PathDelim + 'lib' + PathDelim + TargetCpu + '-android');
    end;

    // Incorpora dinamicamente quaisquer OtherUnitFiles definidos no projeto ativo
    if Assigned(LazarusIDE) and Assigned(LazarusIDE.ActiveProject) then
    begin
      OtherUnits := LazarusIDE.ActiveProject.LazCompilerOptions.OtherUnitFiles;
      if OtherUnits <> '' then
      begin
        OtherUnits := StringReplace(OtherUnits, '$(TargetCPU)', TargetCpu, [rfReplaceAll, rfIgnoreCase]);
        OtherUnits := StringReplace(OtherUnits, '$(TargetOS)', 'android', [rfReplaceAll, rfIgnoreCase]);
        OtherUnits := StringReplace(OtherUnits, '$(LazarusDir)', LazDir, [rfReplaceAll, rfIgnoreCase]);
        OtherUnits := StringReplace(OtherUnits, '$(ProjOutDir)', UnitOutDir, [rfReplaceAll, rfIgnoreCase]);

        OtherList := TStringList.Create;
        try
          OtherList.Delimiter := ';';
          OtherList.StrictDelimiter := True;
          OtherList.DelimitedText := OtherUnits;
          for i := 0 to OtherList.Count - 1 do
          begin
            UnitPath := Trim(OtherList[i]);
            if UnitPath <> '' then
            begin
              if not FilenameIsAbsolute(UnitPath) then
                UnitPath := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(PrjFile)) + UnitPath);
              if DirectoryExists(UnitPath) then
                Params.Add('-Fu' + UnitPath);
            end;
          end;
        finally
          OtherList.Free;
        end;
      end;
    end;

    Params.Add(PrjFile);

    LogMsg(Format('>>> [PROJETO ATIVO] Compilando: %s', [PrjFile]), luSuccess);
    LogMsg(Format('Executando FPC: %s com alvo %s (%s)', [CompilerExe, TargetCpu, TargetAbiStr]), luInfo);

    FActiveRunner := TLazDroidProcessThread.Create(
      CompilerExe,
      Params,
      ExtractFilePath(PrjFile),
      Env
    );
    FActiveRunner.OnFinished := @HandleProcessFinished;
    FActiveRunner.Start;
  finally
    Params.Free;
    Env.Free;
  end;
end;

procedure TLazDroidPipeline.RunPackaging;
var
  GradlewBin: string;
  LocalPropFile: string;
  PropLines: TStringList;
  Params: TStringList;
  Env: TStringList;
  TargetAbiStr: string;
  ExpectedSo: string;
begin
  SetStage(stagePackaging, 'Empacotando aplicação Android via Gradle Wrapper...');

  TargetAbiStr := FSettings.AbiToString(FTargetAbi);
  ExpectedSo := IncludeTrailingPathDelimiter(FScaffoldPath) +
                'app' + PathDelim + 'src' + PathDelim + 'main' + PathDelim +
                'jniLibs' + PathDelim + TargetAbiStr + PathDelim + DEFAULT_SO_NAME;

  if not FileExists(ExpectedSo) then
  begin
    LogMsg('ERRO FATAL: O binário compilado "' + DEFAULT_SO_NAME + '" não foi encontrado em: ' + ExpectedSo, luError);
    LogMsg('O compilador FPC pode ter falhado. Verifique as mensagens de erro.', luInfo);
    FIsRunning := False;
    SetStage(stageFailed, 'Binário compilado ausente.');
    if Assigned(FOnPipelineFinish) then
      FOnPipelineFinish(False, 'Falha ao compilar binário Pascal.');
    Exit;
  end;

  // Assegura arquivo local.properties no scaffold com caminhos corretos do SDK e NDK
  LocalPropFile := IncludeTrailingPathDelimiter(FScaffoldPath) + 'local.properties';
  if not FileExists(LocalPropFile) and (FSettings.AndroidSdkRoot <> '') then
  begin
    PropLines := TStringList.Create;
    try
      PropLines.Add('sdk.dir=' + StringReplace(FSettings.AndroidSdkRoot, '\', '\\', [rfReplaceAll]));
      if FSettings.AndroidNdkRoot <> '' then
        PropLines.Add('ndk.dir=' + StringReplace(FSettings.AndroidNdkRoot, '\', '\\', [rfReplaceAll]));
      PropLines.SaveToFile(LocalPropFile);
    finally
      PropLines.Free;
    end;
  end;

  {$IFDEF WINDOWS}
  GradlewBin := IncludeTrailingPathDelimiter(FScaffoldPath) + 'gradlew.bat';
  {$ELSE}
  GradlewBin := IncludeTrailingPathDelimiter(FScaffoldPath) + 'gradlew';
  {$ENDIF}

  if not FileExists(GradlewBin) then
  begin
    LogMsg('AVISO: Gradlew não encontrado no scaffold, buscando gradlew no PATH...', luWarning);
    GradlewBin := 'gradlew';
  end;

  FOutputApkPath := IncludeTrailingPathDelimiter(FScaffoldPath) +
    'app' + PathDelim + 'build' + PathDelim + 'outputs' + PathDelim +
    'apk' + PathDelim + 'debug' + PathDelim + 'app-debug.apk';

  Params := TStringList.Create;
  Env := TStringList.Create;
  try
    {$IFDEF WINDOWS}
    GradlewBin := GetEnvironmentVariable('COMSPEC');
    if GradlewBin = '' then GradlewBin := 'cmd.exe';
    Params.Add('/c');
    Params.Add(IncludeTrailingPathDelimiter(FScaffoldPath) + 'gradlew.bat');
    {$ENDIF}

    // Atualiza o nome da aplicação no strings.xml do scaffold para refletir o projeto carregado no Lazarus
    UpdateScaffoldStringsXml(FScaffoldPath, FCurrentAppTitle);

    Params.Add('-PappId=' + FCurrentPackageName);
    Params.Add('assembleDebug');
    Params.Add('--no-daemon');

    // Resolução segura de JAVA_HOME com bin\java.exe garantido
    if (FSettings.JavaHome <> '') and FileExists(IncludeTrailingPathDelimiter(FSettings.JavaHome) + 'bin' + PathDelim + 'java.exe') then
      Env.Add('JAVA_HOME=' + FSettings.JavaHome)
    else if (GetEnvironmentVariable('JAVA_HOME') <> '') and FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('JAVA_HOME')) + 'bin' + PathDelim + 'java.exe') then
      Env.Add('JAVA_HOME=' + GetEnvironmentVariable('JAVA_HOME'))
    else if FileExists('C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot\bin\java.exe') then
      Env.Add('JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot')
    else if FileExists('D:\DesthStrokeIDE\Android\jdk\bin\java.exe') then
      Env.Add('JAVA_HOME=D:\DesthStrokeIDE\Android\jdk');

    if FSettings.AndroidSdkRoot <> '' then
      Env.Add('ANDROID_HOME=' + FSettings.AndroidSdkRoot);

    if FSettings.AndroidNdkRoot <> '' then
      Env.Add('ANDROID_NDK_HOME=' + FSettings.AndroidNdkRoot);

    LogMsg('Disparando build do APK Debug: ' + GradlewBin, luInfo);

    FActiveRunner := TLazDroidProcessThread.Create(
      GradlewBin,
      Params,
      FScaffoldPath,
      Env
    );
    FActiveRunner.OnFinished := @HandleProcessFinished;
    FActiveRunner.Start;
  finally
    Params.Free;
    Env.Free;
  end;
end;

procedure TLazDroidPipeline.RunDeploy;
var
  Params: TStringList;
begin
  SetStage(stageDeploy, 'Instalando APK no dispositivo físico via USB...');

  if not FileExists(FOutputApkPath) then
  begin
    LogMsg('ERRO: O binário APK gerado não foi encontrado em: ' + FOutputApkPath, luError);
    FIsRunning := False;
    SetStage(stageFailed, 'Arquivo APK não encontrado.');
    Exit;
  end;

  // Verificação de segurança adicional caso o aparelho tenha mudado ou não verificado antes
  if (not FOverwriteConfirmed) and FDevManager.IsPackageInstalled(FActiveDevice.Serial, FCurrentPackageName) then
  begin
    if MessageDlg('LazDroid - Confirmação de Instalação',
         Format('O aplicativo "%s" com o identificador:' + LineEnding +
                '  %s' + LineEnding +
                'já está instalado no aparelho (%s).' + LineEnding + LineEnding +
                'Deseja sobrescrever (passar por cima) da versão existente?',
                [FCurrentAppTitle, FCurrentPackageName, FActiveDevice.Model]),
         mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    begin
      LogMsg(Format('Instalação cancelada pelo usuário. O aplicativo "%s" existente foi mantido.', [FCurrentAppTitle]), luWarning);
      FIsRunning := False;
      SetStage(stageIdle, 'Instalação cancelada pelo usuário.');
      if Assigned(FOnPipelineFinish) then
        FOnPipelineFinish(False, 'Instalação cancelada pelo usuário.');
      Exit;
    end;
    FOverwriteConfirmed := True;
  end;

  Params := TStringList.Create;
  try
    Params.Add('-s');
    Params.Add(FActiveDevice.Serial);
    Params.Add('install');
    Params.Add('-r');
    Params.Add('-d');
    Params.Add(FOutputApkPath);

    LogMsg(Format('Comando: adb -s %s install -r -d "%s"', [FActiveDevice.Serial, FOutputApkPath]), luInfo);

    FActiveRunner := TLazDroidProcessThread.Create(
      FSettings.AdbPath,
      Params,
      FScaffoldPath
    );
    FActiveRunner.OnFinished := @HandleProcessFinished;
    FActiveRunner.Start;
  finally
    Params.Free;
  end;
end;

procedure TLazDroidPipeline.RunLaunch;
var
  Params: TStringList;
  ComponentTarget, TargetAct: string;
begin
  SetStage(stageLaunch, 'Iniciando Activity principal no dispositivo...');

  TargetAct := Trim(FSettings.ActivityName);
  if (TargetAct = '') or (TargetAct = 'android.app.NativeActivity') then
    TargetAct := 'com.pascal.lclproject.LCLActivity';

  ComponentTarget := FCurrentPackageName + '/' + TargetAct;

  Params := TStringList.Create;
  try
    Params.Add('-s');
    Params.Add(FActiveDevice.Serial);
    Params.Add('shell');
    Params.Add('am');
    Params.Add('start');
    Params.Add('-n');
    Params.Add(ComponentTarget);

    LogMsg('Iniciando Activity: ' + ComponentTarget, luSuccess);

    FActiveRunner := TLazDroidProcessThread.Create(
      FSettings.AdbPath,
      Params,
      FScaffoldPath
    );
    FActiveRunner.OnFinished := @HandleProcessFinished;
    FActiveRunner.Start;
  finally
    Params.Free;
  end;
end;

function FindDebugServerBinary(const ANDKRoot: string; AAbi: TAndroidAbi): string;
var
  Candidate: string;
  ArchDir: string;
begin
  Result := '';
  if AAbi in [abiArm64_v8a] then
    ArchDir := 'aarch64'
  else
    ArchDir := 'arm';

  // 1. Procura lldb-server no NDK Clang
  Candidate := IncludeTrailingPathDelimiter(ANDKRoot) +
    'toolchains\llvm\prebuilt\windows-x86_64\lib64\clang\11.0.5\lib\linux\' + ArchDir + '\lldb-server';
  if FileExists(Candidate) then Exit(Candidate);

  // 2. Procura gdbserver clássico no NDK
  if AAbi in [abiArm64_v8a] then
    Candidate := IncludeTrailingPathDelimiter(ANDKRoot) + 'prebuilt\android-arm64\gdbserver\gdbserver'
  else
    Candidate := IncludeTrailingPathDelimiter(ANDKRoot) + 'prebuilt\android-arm\gdbserver\gdbserver';
  if FileExists(Candidate) then Exit(Candidate);

  // 3. Fallback no NDK alternativo (DeathStroke ou SDK padrão)
  Candidate := 'D:\DesthStrokeIDE\Android\sdk\ndk-bundle\toolchains\llvm\prebuilt\windows-x86_64\lib64\clang\11.0.5\lib\linux\' + ArchDir + '\lldb-server';
  if FileExists(Candidate) then Exit(Candidate);

  if AAbi in [abiArm64_v8a] then
    Candidate := 'D:\DesthStrokeIDE\Android\sdk\ndk-bundle\prebuilt\android-arm64\gdbserver\gdbserver'
  else
    Candidate := 'D:\DesthStrokeIDE\Android\sdk\ndk-bundle\prebuilt\android-arm\gdbserver\gdbserver';
  if FileExists(Candidate) then Exit(Candidate);
end;

procedure TLazDroidPipeline.SetupGdbServer;
var
  AppPid: string;
  OutputStr: string;
  Params: TStringList;
  Pkg: string;
  ServerBin: string;
  IsLLDB: Boolean;
begin
  Pkg := Trim(FCurrentPackageName);
  if Pkg = '' then Pkg := DEFAULT_PACKAGE_NAME;

  LogMsg('=========================================================', luSuccess);
  LogMsg('  CONFIGURANDO SESSÃO DE DEPURAÇÃO REMOTA (LLDB / GDB)   ', luSuccess);
  LogMsg('=========================================================', luSuccess);

  // 1. Localiza o binário do servidor de depuração no NDK (lldb-server ou gdbserver)
  ServerBin := FindDebugServerBinary(FSettings.AndroidNdkRoot, FTargetAbi);
  IsLLDB := (ServerBin <> '') and (Pos('lldb-server', LowerCase(ServerBin)) > 0);

  if ServerBin <> '' then
  begin
    LogMsg('>>> [DEBUG] Servidor nativo localizado: ' + ServerBin, luInfo);
    // Envia o servidor para o /data/local/tmp
    FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'push', ServerBin, '/data/local/tmp/lazdroid-server'], OutputStr);
    FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'shell', 'chmod', '755', '/data/local/tmp/lazdroid-server'], OutputStr);

    // Prepara o diretório files/ na sandbox da aplicação via run-as
    FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'shell', 'run-as', Pkg, 'mkdir', '-p', 'files'], OutputStr);
    FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'shell', 'run-as', Pkg, 'cp', '/data/local/tmp/lazdroid-server', 'files/lazdroid-server'], OutputStr);
    FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'shell', 'run-as', Pkg, 'chmod', '700', 'files/lazdroid-server'], OutputStr);
  end
  else
    LogMsg('AVISO: Servidor nativo (lldb-server/gdbserver) não localizado no NDK; tentando usar binário já existente no aparelho.', luWarning);

  // 2. Marca a aplicação como debug-app para evitar congelamento por ANR do Android
  FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'shell', 'am', 'set-debug-app', Pkg], OutputStr);

  // 3. Redireciona a porta TCP 5039 do Android para o Windows Host
  FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'forward', 'tcp:5039', 'tcp:5039'], OutputStr);
  LogMsg('>>> [DEBUG] Porta TCP 5039 redirecionada via ADB (localhost:5039 <-> celular:5039).', luInfo);

  // 4. Aguarda a inicialização do processo da Activity e detecta o PID
  Sleep(1200);
  if FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'shell', 'pidof', Pkg], OutputStr) = 0 then
    AppPid := Trim(OutputStr)
  else
    AppPid := '';

  if AppPid = '' then
  begin
    LogMsg('AVISO: Não foi possível obter o PID de ' + Pkg + ' para attach automático do depurador.', luWarning);
    Exit;
  end;

  LogMsg(Format('>>> [DEBUG] Aplicação Android detectada com PID: %s', [AppPid]), luSuccess);

  // 5. Inicia o servidor de depuração em background anexado ao PID
  if Assigned(FGdbServerRunner) then
  begin
    FGdbServerRunner.RequestCancel;
    FGdbServerRunner := nil;
  end;

  Params := TStringList.Create;
  try
    Params.Add('-s');
    Params.Add(FActiveDevice.Serial);
    Params.Add('shell');
    Params.Add('run-as');
    Params.Add(Pkg);

    if IsLLDB then
    begin
      Params.Add('sh');
      Params.Add('-c');
      Params.Add('files/lazdroid-server gdbserver 127.0.0.1:5039 --attach ' + AppPid);
    end
    else
    begin
      Params.Add('files/lazdroid-server');
      Params.Add(':5039');
      Params.Add('--attach');
      Params.Add(AppPid);
    end;

    FGdbServerRunner := TLazDroidProcessThread.Create(
      FSettings.AdbPath,
      Params,
      FScaffoldPath
    );
    FGdbServerRunner.Start;
  finally
    Params.Free;
  end;

  if IsLLDB then
    LogMsg('>>> [DEBUG] LLDB-Server ATIVO no celular aguardando conexão em localhost:5039!', luSuccess)
  else
    LogMsg('>>> [DEBUG] GDB-Server ATIVO no celular aguardando conexão em localhost:5039!', luSuccess);

  LogMsg('>>> [DEBUG] O depurador do Lazarus (FpLldb / GDB) pode agora conectar em localhost:5039.', luInfo);
  LogMsg('=========================================================', luSuccess);
end;

procedure TLazDroidPipeline.StartLogcat;
var
  Params: TStringList;
  DummyStr: string;
begin
  SetStage(stageLogcat, 'Conectado ao Logcat. Monitorando logs da aplicação...');

  if not FSettings.AutoShowLogcat then
  begin
    FIsRunning := False;
    SetStage(stageCompleted, 'Pipeline finalizado com sucesso (Logcat desativado).');
    if Assigned(FOnPipelineFinish) then
      FOnPipelineFinish(True, 'Deploy e Execução concluídos!');
    Exit;
  end;

  // Limpa buffer de logs anterior no aparelho
  FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'logcat', '-c'], DummyStr);

  Params := TStringList.Create;
  try
    Params.Add('-s');
    Params.Add(FActiveDevice.Serial);
    Params.Add('logcat');
    Params.Add('-v');
    Params.Add('time');
    Params.Add('-s');
    Params.Add('lclapp:*');
    Params.Add('LazApp:*');
    Params.Add('AndroidRuntime:*');
    Params.Add('DEBUG:*');
    Params.Add('libc:*');
    Params.Add('System.out:*');
    Params.Add('*:E');

    LogMsg('Logcat ativo (Filtro: lclapp:* LazApp:* AndroidRuntime:* DEBUG:* libc:*)', luLogcat);

    FLogcatRunner := TLazDroidProcessThread.Create(
      FSettings.AdbPath,
      Params,
      FScaffoldPath
    );
    // Logcat fica rodando indefinidamente em background até cancelamento
    FLogcatRunner.Start;

    FIsRunning := False;
    SetStage(stageCompleted, 'App executando no aparelho! Logs ativos na janela Messages.');
    if Assigned(FOnPipelineFinish) then
      FOnPipelineFinish(True, 'Deploy concluído com sucesso!');
  finally
    Params.Free;
  end;
end;

procedure TLazDroidPipeline.HandleProcessFinished(AExitCode: Integer; const AErrorMsg: string);
begin
  if FCancelRequested then
    Exit;

  if AExitCode <> 0 then
  begin
    LogMsg(Format('Falha no estágio [%s] com código de saída: %d. %s',
      [StageToString(FCurrentStage), AExitCode, AErrorMsg]), luError);
    FIsRunning := False;
    SetStage(stageFailed, 'Processo encerrou com erro.');
    if Assigned(FOnPipelineFinish) then
      FOnPipelineFinish(False, Format('Falha no estágio %s (Código %d)', [StageToString(FCurrentStage), AExitCode]));
    Exit;
  end;

  // Transições de estágio com base no sucesso do anterior
  case FCurrentStage of
    stagePascalBuild: RunPackaging;
    stagePackaging:   RunDeploy;
    stageDeploy:      RunLaunch;
    stageLaunch:
    begin
      if FIsDebugMode then
        SetupGdbServer;
      StartLogcat;
    end;
  end;
end;

end.
