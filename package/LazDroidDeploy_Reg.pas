{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidDeploy_Reg.pas
  Descrição: Registro de comandos, menus, atalhos de teclado e painel de opções no Lazarus IDE.
}
unit LazDroidDeploy_Reg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, LCLType,
  // Lazarus Open Tools API units
  MenuIntf, IDECommands, LazIDEIntf, IDEOptionsIntf, IDEOptEditorIntf,
  // LazDroid units
  LazDroidConfig, LazDroidConfigFrame, LazDroidDeviceManager,
  LazDroidDeviceSelectDlg, LazDroidPipeline, LazDroidProcessRunner,
  LazDroidProjectDescriptor;

var
  DroidOptionsIndex: Integer = 1050;

procedure Register;

implementation

var
  CmdDeployAndRun: TIDECommand = nil;
  CmdDeployAndDebug: TIDECommand = nil;
  CmdCancelDeploy: TIDECommand = nil;
  CmdConfigureProject: TIDECommand = nil;
  GlobalPipeline: TLazDroidPipeline = nil;

procedure EnsurePipeline;
begin
  if not Assigned(GlobalPipeline) then
    GlobalPipeline := TLazDroidPipeline.Create(DroidConfig);
end;

procedure DoConfigureProject(Sender: TObject);
begin
  if Assigned(LazarusIDE.ActiveProject) then
  begin
    ConfigureProjectAndroidCustomDrawn(LazarusIDE.ActiveProject);
    ShowMessage('Projeto configurado com sucesso para Android (aarch64 / LCL CustomDrawn)!' + LineEnding +
                'A macro LCLWidgetType foi definida para "customdrawn".');
  end
  else
    ShowMessage('Nenhum projeto ativo no momento para configurar.');
end;

procedure DoDeployAndRun(Sender: TObject);
var
  TargetDevice: TAndroidDevice;
begin
  EnsurePipeline;

  // Garante que o projeto ativo esteja calibrado com LCLWidgetType=customdrawn
  if Assigned(LazarusIDE.ActiveProject) then
    ConfigureProjectAndroidCustomDrawn(LazarusIDE.ActiveProject);

  if GlobalPipeline.IsRunning then
  begin
    if MessageDlg('LazDroid-Deploy',
      'O pipeline de deploy Android já está em execução.' + LineEnding +
      'Deseja cancelar o processo atual?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      GlobalPipeline.Cancel;
    end;
    Exit;
  end;

  // Seleciona dispositivo conectado via ADB
  if not ShowSelectDeviceDialog(TargetDevice) then
    Exit; // Usuário cancelou ou nenhum aparelho pronto

  // Dispara esteira de compilação, empacotamento e deploy
  GlobalPipeline.Start(TargetDevice.Serial, False);
end;

procedure DoDeployAndDebug(Sender: TObject);
var
  TargetDevice: TAndroidDevice;
begin
  EnsurePipeline;

  // Garante que o projeto ativo esteja calibrado com LCLWidgetType=customdrawn
  if Assigned(LazarusIDE.ActiveProject) then
    ConfigureProjectAndroidCustomDrawn(LazarusIDE.ActiveProject);

  if GlobalPipeline.IsRunning then
  begin
    if MessageDlg('LazDroid-Deploy',
      'O pipeline de deploy Android já está em execução.' + LineEnding +
      'Deseja cancelar o processo atual?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      GlobalPipeline.Cancel;
    end;
    Exit;
  end;

  // Seleciona dispositivo conectado via ADB
  if not ShowSelectDeviceDialog(TargetDevice) then
    Exit;

  // Dispara esteira em modo depuração GDB Remote
  GlobalPipeline.Start(TargetDevice.Serial, True);
end;

procedure DoCancelDeploy(Sender: TObject);
begin
  if Assigned(GlobalPipeline) and GlobalPipeline.IsRunning then
  begin
    GlobalPipeline.Cancel;
    LogToLazarusMessages('Cancelamento manual do pipeline acionado pelo usuário.', luWarning);
  end
  else
  begin
    ShowMessage('Nenhum pipeline LazDroid em execução no momento.');
  end;
end;

procedure Register;
var
  CmdCategory: TIDECommandCategory;
  RunSection: TIDEMenuSection;
  ShortcutDeploy, ShortcutDebug, ShortcutCancel: TIDEShortCut;
begin
  // 1. Registrar Project Descriptor (Template de Novo Projeto Android na IDE)
  RegisterProjectTemplate;

  // 2. Registrar Categoria de Comandos no IDECommands
  CmdCategory := IDECommandList.CreateCategory(nil, 'LazDroid', 'LazDroid Android Automation');

  ShortcutDeploy := IDEShortCut(VK_F9, [ssCtrl, ssShift]);
  ShortcutDebug  := IDEShortCut(VK_F9, [ssCtrl]);
  ShortcutCancel := IDEShortCut(VK_CANCEL, [ssCtrl, ssShift]);

  // 3. Registrar Comandos IDE com Atalhos
  CmdDeployAndRun := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidDeployAndRun',
    'Deploy & Run on Android Device',
    ShortcutDeploy,
    nil,
    @DoDeployAndRun
  );

  CmdDeployAndDebug := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidDeployAndDebug',
    'Deploy & Debug on Android Device (GDB Remote)',
    ShortcutDebug,
    nil,
    @DoDeployAndDebug
  );

  CmdCancelDeploy := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidCancelDeploy',
    'Cancel Android Deployment',
    ShortcutCancel,
    nil,
    @DoCancelDeploy
  );

  CmdConfigureProject := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidConfigureProject',
    'Configurar Projeto Atual para Android (LCL CustomDrawn)',
    CleanIDEShortCut,
    nil,
    @DoConfigureProject
  );

  // 4. Registrar Itens no Menu 'Run' (Executar) da IDE
  RunSection := itmRunBuilding;
  if RunSection = nil then
    RunSection := mnuRun;

  RegisterIDEMenuCommand(
    RunSection,
    'itmLazDroidConfigProject',
    'Configurar Projeto Atual para Android (LCL CustomDrawn)',
    nil,
    @DoConfigureProject,
    CmdConfigureProject
  );

  RegisterIDEMenuCommand(
    RunSection,
    'itmLazDroidDeployRun',
    'Deploy & Run on Android Device (USB)',
    nil,
    @DoDeployAndRun,
    CmdDeployAndRun
  );

  RegisterIDEMenuCommand(
    RunSection,
    'itmLazDroidDeployDebug',
    'Deploy & Debug on Android Device (GDB Remote)',
    nil,
    @DoDeployAndDebug,
    CmdDeployAndDebug
  );

  RegisterIDEMenuCommand(
    RunSection,
    'itmLazDroidCancel',
    'Cancelar Deploy Android',
    nil,
    @DoCancelDeploy,
    CmdCancelDeploy
  );

  // 5. Registrar Página nas Opções da IDE (Tools -> Options -> Environment)
  DroidOptionsIndex := RegisterIDEOptionsEditor(
    GroupEnvironment,
    TLazDroidOptionsFrame,
    DroidOptionsIndex
  )^.Index;
end;

initialization

finalization
  if Assigned(GlobalPipeline) then
    FreeAndNil(GlobalPipeline);

end.
