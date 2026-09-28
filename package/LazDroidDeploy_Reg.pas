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
  LazDroidDeviceSelectDlg, LazDroidPipeline, LazDroidProcessRunner;

var
  DroidOptionsIndex: Integer = 1050;

procedure Register;

implementation

var
  CmdDeployAndRun: TIDECommand = nil;
  CmdCancelDeploy: TIDECommand = nil;
  GlobalPipeline: TLazDroidPipeline = nil;

procedure EnsurePipeline;
begin
  if not Assigned(GlobalPipeline) then
    GlobalPipeline := TLazDroidPipeline.Create(DroidConfig);
end;

procedure DoDeployAndRun(Sender: TObject);
var
  TargetDevice: TAndroidDevice;
begin
  EnsurePipeline;

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
  GlobalPipeline.Start(TargetDevice.Serial);
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
  ShortcutDeploy, ShortcutCancel: TIDEShortCut;
begin
  // 1. Registrar Categoria de Comandos no IDECommands
  CmdCategory := IDECommandList.CreateCategory(nil, 'LazDroid', 'LazDroid Android Automation');

  ShortcutDeploy := IDEShortCut(VK_F9, [ssCtrl, ssShift]);
  ShortcutCancel := IDEShortCut(VK_CANCEL, [ssCtrl, ssShift]);

  // 2. Registrar Comando IDE com Atalho padrão (Ctrl+Shift+F9)
  CmdDeployAndRun := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidDeployAndRun',
    'Deploy & Run on Android Device',
    ShortcutDeploy,
    nil,
    @DoDeployAndRun
  );

  CmdCancelDeploy := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidCancelDeploy',
    'Cancel Android Deployment',
    ShortcutCancel,
    nil,
    @DoCancelDeploy
  );

  // 3. Registrar Itens no Menu 'Run' (Executar) da IDE
  RunSection := itmRunBuilding;
  if RunSection = nil then
    RunSection := mnuRun;

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
    'itmLazDroidCancel',
    'Cancelar Deploy Android',
    nil,
    @DoCancelDeploy,
    CmdCancelDeploy
  );

  // 4. Registrar Página nas Opções da IDE (Tools -> Options -> Environment)
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
