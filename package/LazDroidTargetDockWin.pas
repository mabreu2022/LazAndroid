{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidTargetDockWin.pas
  Descrição: Janela acoplável (Dockable Window) estilo Delphi Project Manager "Target",
             com reconhecimento dinâmico de dispositivos Android conectados via USB (Plug & Play),
             árvore de targets, seleção de alvo padrão e ações de deploy com 1 clique.
}
unit LazDroidTargetDockWin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Buttons, Menus, StdCtrls, LCLType,
  // Lazarus IDE Open Tools API
  IDEWindowIntf, LazIDEIntf, IDECommands, IDEOptionsIntf,
  // LazDroid
  LazDroidConfig, LazDroidConfigFrame, LazDroidDeviceManager;

type
  { TLazDroidTargetDockForm }
  TLazDroidTargetDockForm = class(TForm)
    pnlToolbar: TPanel;
    btnRefresh: TSpeedButton;
    btnDeploy: TSpeedButton;
    btnDebug: TSpeedButton;
    btnLogcat: TSpeedButton;
    btnSettings: TSpeedButton;
    tvTargets: TTreeView;
    pnlStatus: TPanel;
    lblStatusLeft: TLabel;
    lblStatusRight: TLabel;
    TimerDetect: TTimer;
    pmDevice: TPopupMenu;
    miSetDefault: TMenuItem;
    miDeployRun: TMenuItem;
    miDeployDebug: TMenuItem;
    miSep1: TMenuItem;
    miDeviceProps: TMenuItem;
    miOpenLogcat: TMenuItem;
    miSep2: TMenuItem;
    miRestartAdb: TMenuItem;
    miRefreshNow: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TimerDetectTimer(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnDeployClick(Sender: TObject);
    procedure btnDebugClick(Sender: TObject);
    procedure btnLogcatClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure tvTargetsDblClick(Sender: TObject);
    procedure tvTargetsSelectionChanged(Sender: TObject);
    procedure tvTargetsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure tvTargetsAdvancedCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
    procedure miSetDefaultClick(Sender: TObject);
    procedure miDeployRunClick(Sender: TObject);
    procedure miDeployDebugClick(Sender: TObject);
    procedure miDevicePropsClick(Sender: TObject);
    procedure miOpenLogcatClick(Sender: TObject);
    procedure miRestartAdbClick(Sender: TObject);
    procedure miRefreshNowClick(Sender: TObject);
  private
    FDevManager: TLazDroidDeviceManager;
    FDevices: TAndroidDeviceArray;
    FActiveSerial: string;
    FIsScanning: Boolean;
    FLastSnapshot: string;

    FNodeProject: TTreeNode;
    FNodeAndroid: TTreeNode;
    FNodeTarget: TTreeNode;
    FNodeConfig: TTreeNode;
    FNodeActions: TTreeNode;

    procedure BuildTreeSkeleton;
    procedure RebuildTargetNodes;
    procedure RefreshDeviceList(const AForce: Boolean = False);
    function ComputeSnapshot: string;
    function GetDeviceBySerial(const ASerial: string; out ADev: TAndroidDevice): Boolean;
    function GetSelectedDeviceFromTree(out ADev: TAndroidDevice): Boolean;
    procedure SetActiveDevice(const ASerial: string);
  public
    function GetActiveDevice(out ADev: TAndroidDevice): Boolean;
  end;

var
  LazDroidTargetDockForm: TLazDroidTargetDockForm = nil;
  LazDroidTargetDockCreator: TIDEWindowCreator = nil;

procedure ShowLazDroidTargetWindow(Sender: TObject);
procedure CreateLazDroidTargetWindow(Sender: TObject; aFormName: string;
  var AForm: TCustomForm; DoDisableAutoSizing: boolean);
function GetActiveTargetDevice(out ADev: TAndroidDevice): Boolean;

implementation

{$R *.lfm}

procedure ShowLazDroidTargetWindow(Sender: TObject);
begin
  if Assigned(LazDroidTargetDockCreator) then
    IDEWindowCreators.ShowForm(LazDroidTargetDockCreator.FormName, True);
end;

procedure CreateLazDroidTargetWindow(Sender: TObject; aFormName: string;
  var AForm: TCustomForm; DoDisableAutoSizing: boolean);
begin
  if CompareText(aFormName, 'TLazDroidTargetDockForm') <> 0 then Exit;
  IDEWindowCreators.CreateForm(AForm, TLazDroidTargetDockForm, DoDisableAutoSizing,
    LazarusIDE.OwningComponent);
  AForm.Name := aFormName;
  LazDroidTargetDockForm := AForm as TLazDroidTargetDockForm;
end;

function GetActiveTargetDevice(out ADev: TAndroidDevice): Boolean;
begin
  Result := False;
  if Assigned(LazDroidTargetDockForm) then
    Result := LazDroidTargetDockForm.GetActiveDevice(ADev);
end;

{ TLazDroidTargetDockForm }

procedure TLazDroidTargetDockForm.FormCreate(Sender: TObject);
begin
  FDevManager := TLazDroidDeviceManager.Create(DroidConfig.AdbPath);
  FActiveSerial := DroidConfig.TargetDeviceSerial;
  FIsScanning := False;
  FLastSnapshot := '';
  BuildTreeSkeleton;
end;

procedure TLazDroidTargetDockForm.FormDestroy(Sender: TObject);
begin
  TimerDetect.Enabled := False;
  FDevManager.Free;
  if LazDroidTargetDockForm = Self then
    LazDroidTargetDockForm := nil;
end;

procedure TLazDroidTargetDockForm.FormShow(Sender: TObject);
begin
  RefreshDeviceList(True);
  TimerDetect.Enabled := True;
end;

procedure TLazDroidTargetDockForm.BuildTreeSkeleton;
var
  ProjName: string;
begin
  tvTargets.Items.BeginUpdate;
  try
    tvTargets.Items.Clear;

    ProjName := 'Nenhum projeto ativo';
    if Assigned(LazarusIDE.ActiveProject) then
    begin
      ProjName := ExtractFileName(LazarusIDE.ActiveProject.ProjectInfoFile);
      if ProjName = '' then
        ProjName := LazarusIDE.ActiveProject.Title;
      if ProjName = '' then
        ProjName := 'Projeto Atual';
    end;

    // 1. Nó Raiz: Projeto
    FNodeProject := tvTargets.Items.Add(nil, '📦 ' + ProjName);

    // 2. Plataforma: Android 64-bit
    FNodeAndroid := tvTargets.Items.AddChild(FNodeProject, '🤖 Android 64-bit (aarch64) - LCL CustomDrawn');

    // 3. Nó Target (onde os aparelhos USB serão listados em tempo real)
    FNodeTarget := tvTargets.Items.AddChild(FNodeAndroid, '🎯 Target');

    // 4. Configuração de Build
    FNodeConfig := tvTargets.Items.AddChild(FNodeAndroid, '⚙️ Configuration');
    tvTargets.Items.AddChild(FNodeConfig, '● Debug (GDB Remote & Símbolos)');
    tvTargets.Items.AddChild(FNodeConfig, '○ Release (Otimizado -O3 -Xs)');

    // 5. Ações Rápidas
    FNodeActions := tvTargets.Items.AddChild(FNodeAndroid, '⚡ Ações Rápidas');
    tvTargets.Items.AddChild(FNodeActions, '▶️ Deploy & Executar (Ctrl+Shift+F9)');
    tvTargets.Items.AddChild(FNodeActions, '🐞 Deploy & Depurar (Ctrl+F9)');
    tvTargets.Items.AddChild(FNodeActions, '📋 Abrir Terminal Logcat');
    tvTargets.Items.AddChild(FNodeActions, '🔄 Atualizar Dispositivos USB');
    tvTargets.Items.AddChild(FNodeActions, '⚙️ Opções LazDroid...');

    // Expande a árvore por padrão
    FNodeProject.Expanded := True;
    FNodeAndroid.Expanded := True;
    FNodeTarget.Expanded := True;
    FNodeConfig.Expanded := False;
    FNodeActions.Expanded := False;
  finally
    tvTargets.Items.EndUpdate;
  end;
end;

function TLazDroidTargetDockForm.ComputeSnapshot: string;
var
  I: Integer;
begin
  Result := '';
  for I := Low(FDevices) to High(FDevices) do
    Result := Result + FDevices[I].Serial + ':' + FDevices[I].State + ';';
end;

procedure TLazDroidTargetDockForm.RebuildTargetNodes;
var
  I: Integer;
  Dev: TAndroidDevice;
  NodeText: string;
  DevNode: TTreeNode;
  HasSelected: Boolean;
begin
  if not Assigned(FNodeTarget) then Exit;

  tvTargets.Items.BeginUpdate;
  try
    FNodeTarget.DeleteChildren;

    if Length(FDevices) = 0 then
    begin
      tvTargets.Items.AddChild(FNodeTarget, '⚠️ (Nenhum dispositivo USB detectado - Conecte o cabo USB)');
      lblStatusLeft.Caption := ' Aguardando conexão USB com Depuração USB ativada...';
      Exit;
    end;

    HasSelected := False;
    for I := Low(FDevices) to High(FDevices) do
    begin
      Dev := FDevices[I];

      if Dev.Serial = FActiveSerial then
      begin
        NodeText := Format('🟢 %s [%s] (%s | %s) ★ [ATIVO]',
          [Dev.Model, Dev.Serial, Dev.PrimaryAbi, Dev.AndroidVersion]);
        HasSelected := True;
      end
      else if Dev.IsReady then
      begin
        NodeText := Format('⚪ %s [%s] (%s | %s)',
          [Dev.Model, Dev.Serial, Dev.PrimaryAbi, Dev.AndroidVersion]);
      end
      else if Dev.State = 'unauthorized' then
      begin
        NodeText := Format('🔒 %s [%s] - NÃO AUTORIZADO (Desbloqueie a tela do celular)',
          [Dev.Model, Dev.Serial]);
      end
      else
      begin
        NodeText := Format('⚠️ %s [%s] - %s',
          [Dev.Model, Dev.Serial, Dev.State]);
      end;

      DevNode := tvTargets.Items.AddChild(FNodeTarget, NodeText);
      if Dev.Serial = FActiveSerial then
        tvTargets.Selected := DevNode;
    end;

    // Se nenhum estava marcado como ativo, define o primeiro pronto
    if not HasSelected and (Length(FDevices) > 0) then
    begin
      for I := Low(FDevices) to High(FDevices) do
      begin
        if FDevices[I].IsReady then
        begin
          SetActiveDevice(FDevices[I].Serial);
          Break;
        end;
      end;
    end;

    FNodeTarget.Expanded := True;

    if GetDeviceBySerial(FActiveSerial, Dev) then
      lblStatusLeft.Caption := ' Alvo Ativo: ' + Dev.Model + ' [' + Dev.Serial + ']'
    else
      lblStatusLeft.Caption := Format(' %d dispositivo(s) detectado(s)', [Length(FDevices)]);

  finally
    tvTargets.Items.EndUpdate;
  end;
end;

procedure TLazDroidTargetDockForm.RefreshDeviceList(const AForce: Boolean);
var
  NewSnapshot: string;
begin
  if FIsScanning then Exit;
  FIsScanning := True;
  try
    FDevices := FDevManager.EnumerateDevices;
    NewSnapshot := ComputeSnapshot;

    if AForce or (NewSnapshot <> FLastSnapshot) then
    begin
      FLastSnapshot := NewSnapshot;
      RebuildTargetNodes;
    end;
  finally
    FIsScanning := False;
  end;
end;

procedure TLazDroidTargetDockForm.TimerDetectTimer(Sender: TObject);
begin
  // Polling silencioso não-bloqueante
  RefreshDeviceList(False);
end;

procedure TLazDroidTargetDockForm.btnRefreshClick(Sender: TObject);
begin
  RefreshDeviceList(True);
end;

procedure TLazDroidTargetDockForm.btnDeployClick(Sender: TObject);
var
  Cmd: TIDECommand;
begin
  Cmd := IDECommandList.FindCommandByName('ecLazDroidDeployAndRun');
  if Assigned(Cmd) then
    Cmd.Execute(Self)
  else
    ShowMessage('Comando Deploy & Run não encontrado.');
end;

procedure TLazDroidTargetDockForm.btnDebugClick(Sender: TObject);
var
  Cmd: TIDECommand;
begin
  Cmd := IDECommandList.FindCommandByName('ecLazDroidDeployAndDebug');
  if Assigned(Cmd) then
    Cmd.Execute(Self)
  else
    ShowMessage('Comando Deploy & Debug não encontrado.');
end;

procedure TLazDroidTargetDockForm.btnLogcatClick(Sender: TObject);
begin
  miOpenLogcatClick(Sender);
end;

procedure TLazDroidTargetDockForm.btnSettingsClick(Sender: TObject);
begin
  LazarusIDE.DoOpenIDEOptions(TLazDroidOptionsFrame, 'LazDroid');
end;

procedure TLazDroidTargetDockForm.SetActiveDevice(const ASerial: string);
var
  Dev: TAndroidDevice;
begin
  FActiveSerial := ASerial;
  DroidConfig.TargetDeviceSerial := ASerial;
  DroidConfig.Save;
  RebuildTargetNodes;
  if GetDeviceBySerial(ASerial, Dev) then
    lblStatusLeft.Caption := ' Alvo Ativo: ' + Dev.Model + ' [' + Dev.Serial + '] (' + Dev.PrimaryAbi + ')'
  else
    lblStatusLeft.Caption := ' Nenhum alvo ativo selecionado';
end;

function TLazDroidTargetDockForm.GetDeviceBySerial(const ASerial: string; out ADev: TAndroidDevice): Boolean;
var
  I: Integer;
begin
  Result := False;
  if ASerial = '' then Exit;
  for I := Low(FDevices) to High(FDevices) do
  begin
    if FDevices[I].Serial = ASerial then
    begin
      ADev := FDevices[I];
      Exit(True);
    end;
  end;
end;

function TLazDroidTargetDockForm.GetSelectedDeviceFromTree(out ADev: TAndroidDevice): Boolean;
var
  I: Integer;
  CurNode: TTreeNode;
begin
  Result := False;
  CurNode := tvTargets.Selected;
  if not Assigned(CurNode) then Exit;

  for I := Low(FDevices) to High(FDevices) do
  begin
    if Pos('[' + FDevices[I].Serial + ']', CurNode.Text) > 0 then
    begin
      ADev := FDevices[I];
      Exit(True);
    end;
  end;
end;

function TLazDroidTargetDockForm.GetActiveDevice(out ADev: TAndroidDevice): Boolean;
var
  I: Integer;
begin
  Result := False;
  // 1. Procura dispositivo ativo selecionado
  if FActiveSerial <> '' then
  begin
    for I := Low(FDevices) to High(FDevices) do
    begin
      if (FDevices[I].Serial = FActiveSerial) and FDevices[I].IsReady then
      begin
        ADev := FDevices[I];
        Exit(True);
      end;
    end;
  end;

  // 2. Se houver exatamente 1 dispositivo pronto, assume ele como padrão
  if Length(FDevices) = 1 then
  begin
    if FDevices[0].IsReady then
    begin
      ADev := FDevices[0];
      Exit(True);
    end;
  end;
end;

procedure TLazDroidTargetDockForm.tvTargetsDblClick(Sender: TObject);
var
  Dev: TAndroidDevice;
  CurNode: TTreeNode;
begin
  CurNode := tvTargets.Selected;
  if not Assigned(CurNode) then Exit;

  // Se clicou num dispositivo sob Target
  if GetSelectedDeviceFromTree(Dev) then
  begin
    if Dev.IsReady then
      SetActiveDevice(Dev.Serial)
    else
      ShowMessage('O dispositivo "' + Dev.Model + '" está no estado: ' + Dev.State + LineEnding +
                  'Verifique se você permitiu a "Depuração USB" na tela do aparelho.');
    Exit;
  end;

  // Se clicou numa ação rápida
  if Pos('Deploy & Executar', CurNode.Text) > 0 then
    btnDeployClick(Sender)
  else if Pos('Deploy & Depurar', CurNode.Text) > 0 then
    btnDebugClick(Sender)
  else if Pos('Logcat', CurNode.Text) > 0 then
    btnLogcatClick(Sender)
  else if Pos('Atualizar', CurNode.Text) > 0 then
    btnRefreshClick(Sender)
  else if Pos('Opções', CurNode.Text) > 0 then
    btnSettingsClick(Sender);
end;

procedure TLazDroidTargetDockForm.tvTargetsSelectionChanged(Sender: TObject);
var
  Dev: TAndroidDevice;
begin
  if GetSelectedDeviceFromTree(Dev) then
  begin
    lblStatusLeft.Caption := Format(' Selecionado: %s [%s] - %s', [Dev.Model, Dev.Serial, Dev.State]);
  end;
end;

procedure TLazDroidTargetDockForm.tvTargetsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  HitNode: TTreeNode;
begin
  if Button = mbRight then
  begin
    HitNode := tvTargets.GetNodeAt(X, Y);
    if Assigned(HitNode) then
      tvTargets.Selected := HitNode;
  end;
end;

procedure TLazDroidTargetDockForm.tvTargetsAdvancedCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  Stage: TCustomDrawStage; var PaintImages, DefaultDraw: Boolean);
begin
  if Stage = cdPrePaint then
  begin
    if Assigned(Node) and (Pos('★ [ATIVO]', Node.Text) > 0) then
    begin
      Sender.Canvas.Font.Style := Sender.Canvas.Font.Style + [fsBold];
      Sender.Canvas.Font.Color := $00008800; // Verde escuro elegante
    end
    else if Assigned(Node) and ((Node = FNodeTarget) or (Node = FNodeProject)) then
    begin
      Sender.Canvas.Font.Style := Sender.Canvas.Font.Style + [fsBold];
    end;
  end;
  DefaultDraw := True;
end;

procedure TLazDroidTargetDockForm.miSetDefaultClick(Sender: TObject);
var
  Dev: TAndroidDevice;
begin
  if GetSelectedDeviceFromTree(Dev) then
    SetActiveDevice(Dev.Serial)
  else
    ShowMessage('Selecione um dispositivo Android válido para definir como alvo padrão.');
end;

procedure TLazDroidTargetDockForm.miDeployRunClick(Sender: TObject);
var
  Dev: TAndroidDevice;
begin
  if GetSelectedDeviceFromTree(Dev) and Dev.IsReady then
    SetActiveDevice(Dev.Serial);
  btnDeployClick(Sender);
end;

procedure TLazDroidTargetDockForm.miDeployDebugClick(Sender: TObject);
var
  Dev: TAndroidDevice;
begin
  if GetSelectedDeviceFromTree(Dev) and Dev.IsReady then
    SetActiveDevice(Dev.Serial);
  btnDebugClick(Sender);
end;

procedure TLazDroidTargetDockForm.miDevicePropsClick(Sender: TObject);
var
  Dev: TAndroidDevice;
  InfoMsg: string;
begin
  if not GetSelectedDeviceFromTree(Dev) then
  begin
    ShowMessage('Selecione um dispositivo Android na árvore para ver suas propriedades.');
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  try
    FDevManager.PopulateFullDeviceInfo(Dev);
  finally
    Screen.Cursor := crDefault;
  end;

  InfoMsg := '📱 PROPRIEDADES DO DISPOSITIVO ANDROID' + LineEnding +
             '====================================' + LineEnding +
             '• Modelo: ' + Dev.Model + LineEnding +
             '• Fabricante: ' + Dev.Manufacturer + LineEnding +
             '• Número de Série (ADB): ' + Dev.Serial + LineEnding +
             '• Versão do Android: ' + Dev.AndroidVersion + LineEnding +
             '• Nível da API (SDK): ' + Dev.SdkLevel + LineEnding +
             '• Arquitetura CPU (ABI): ' + Dev.PrimaryAbi + LineEnding +
             '• Resolução da Tela: ' + Dev.ScreenSize + LineEnding +
             '• Nível da Bateria: ' + Dev.BatteryLevel + LineEnding +
             '• Estado da Conexão: ' + Dev.State + LineEnding +
             '• Alvo Padrão Selecionado: ' + BoolToStr(Dev.Serial = FActiveSerial, 'SIM (Ativo)', 'NÃO');

  ShowMessage(InfoMsg);
end;

procedure TLazDroidTargetDockForm.miOpenLogcatClick(Sender: TObject);
var
  Dev: TAndroidDevice;
  SerialToUse: string;
begin
  SerialToUse := FActiveSerial;
  if GetSelectedDeviceFromTree(Dev) then
    SerialToUse := Dev.Serial;

  if SerialToUse = '' then
  begin
    ShowMessage('Nenhum dispositivo Android conectado ou selecionado para exibir o Logcat.');
    Exit;
  end;

  if not FDevManager.OpenLogcatConsole(SerialToUse, DroidConfig.LogcatFilter) then
    ShowMessage('Não foi possível iniciar o console do ADB Logcat.');
end;

procedure TLazDroidTargetDockForm.miRestartAdbClick(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    FDevManager.RestartAdbServer;
    RefreshDeviceList(True);
  finally
    Screen.Cursor := crDefault;
  end;
  ShowMessage('Servidor ADB reiniciado com sucesso.');
end;

procedure TLazDroidTargetDockForm.miRefreshNowClick(Sender: TObject);
begin
  RefreshDeviceList(True);
end;

end.
