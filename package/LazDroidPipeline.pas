{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidPipeline.pas
  Descrição: Orquestrador da esteira de 6 estágios (Pre-check, FPC, Gradle, Deploy, Launch, Logcat).
}
unit LazDroidPipeline;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, FileUtil, LazDroidConfig, LazDroidDeviceManager,
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
    FActiveRunner: TLazDroidProcessThread;
    FLogcatRunner: TLazDroidProcessThread;
    FIsRunning: Boolean;
    FCancelRequested: Boolean;
    FScaffoldPath: string;
    FOutputApkPath: string;

    FOnStageChange: TOnStageChange;
    FOnPipelineFinish: TOnPipelineFinish;

    procedure SetStage(ANewStage: TPipelineStage; const ADescription: string);
    procedure LogMsg(const AText: string; AUrgency: TLazDroidLogUrgency = luInfo);

    procedure RunPreCheck;
    procedure RunPascalBuild;
    procedure RunPackaging;
    procedure RunDeploy;
    procedure RunLaunch;
    procedure StartLogcat;

    procedure HandleProcessFinished(AExitCode: Integer; const AErrorMsg: string);
    function ResolveScaffoldPath: string;
    function ResolveTargetProjectFile(out AMainPrjFile: string): Boolean;
  public
    constructor Create(ASettings: TLazDroidSettings = nil);
    destructor Destroy; override;

    procedure Start(const ATargetSerial: string = '');
    procedure Cancel;

    property CurrentStage: TPipelineStage read FCurrentStage;
    property ActiveDevice: TAndroidDevice read FActiveDevice;
    property IsRunning: Boolean read FIsRunning;
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

function TLazDroidPipeline.ResolveTargetProjectFile(out AMainPrjFile: string): Boolean;
begin
  Result := False;
  AMainPrjFile := '';

  if Assigned(LazarusIDE) and Assigned(LazarusIDE.ActiveProject) then
  begin
    AMainPrjFile := LazarusIDE.ActiveProject.MainFile.Filename;
    Result := FileExists(AMainPrjFile);
  end;

  // Fallback demo caso não haja projeto aberto no editor
  if not Result then
  begin
    AMainPrjFile := 'd:\Projetos AntiGravity\LazarusAndroid\demo\LazAndroidDemo.lpr';
    Result := FileExists(AMainPrjFile);
  end;
end;

procedure TLazDroidPipeline.Start(const ATargetSerial: string);
begin
  if FIsRunning then
  begin
    LogMsg('Pipeline já em execução. Cancele antes de reiniciar.', luWarning);
    Exit;
  end;

  FIsRunning := True;
  FCancelRequested := False;
  FSelectedSerial := ATargetSerial;

  LogMsg('=========================================================', luInfo);
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
begin
  SetStage(stagePreCheck, 'Validando ambiente e detectando aparelho...');

  // Validação de configurações mínimas
  if not FSettings.ValidatePaths(Errors) then
  begin
    LogMsg('Aviso de Validação de Caminhos:' + LineEnding + Errors, luWarning);
  end;

  // Busca do dispositivo
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

  Params := TStringList.Create;
  Env := TStringList.Create;
  try
    Params.Add('-Tandroid');
    Params.Add('-P' + TargetCpu);
    Params.Add('-fPIC');
    Params.Add('-FE' + JniOutDir);
    Params.Add('-FU' + UnitOutDir);
    Params.Add('-o' + DEFAULT_SO_NAME);

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

    // Incluir diretório do projeto nas units
    Params.Add('-Fu' + ExtractFilePath(PrjFile));
    Params.Add(PrjFile);

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
begin
  SetStage(stagePackaging, 'Empacotando aplicação Android via Gradle Wrapper...');

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
    Params.Add('assembleDebug');
    Params.Add('--parallel');
    Params.Add('--no-daemon');

    if FSettings.JavaHome <> '' then
      Env.Add('JAVA_HOME=' + FSettings.JavaHome);

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
  ComponentTarget: string;
begin
  SetStage(stageLaunch, 'Iniciando Activity principal no dispositivo...');

  ComponentTarget := FSettings.PackageName + '/' + FSettings.ActivityName;

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

procedure TLazDroidPipeline.StartLogcat;
var
  Params: TStringList;
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
  FDevManager.RunCommandSync(FSettings.AdbPath, ['-s', FActiveDevice.Serial, 'logcat', '-c'], FOutputApkPath);

  Params := TStringList.Create;
  try
    Params.Add('-s');
    Params.Add(FActiveDevice.Serial);
    Params.Add('logcat');
    Params.Add('-v');
    Params.Add('time');
    Params.Add('-s');
    Params.Add('LazApp:*');
    Params.Add('AndroidRuntime:E');
    Params.Add('DEBUG:*');

    LogMsg('Logcat ativo (Filtro: LazApp:* AndroidRuntime:E DEBUG:*)', luLogcat);

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
    stageLaunch:      StartLogcat;
  end;
end;

end.
