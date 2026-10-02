{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidEditorBar.pas
  Descrição: Barra de ferramentas dinâmica acoplada ao topo do Editor de Código (TSourceEditorWindow),
             exibindo Plataforma/ABI, Dispositivo Android USB conectado, Botão Refresh,
             Resolução real do aparelho (via ADB wm size/density), Modo de Build e Deploy com 1 clique.
  Licença: MIT
}
unit LazDroidEditorBar;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, ExtCtrls, StdCtrls, Buttons, Dialogs, LCLType,
  LazIDEIntf, IDEWindowIntf, ProjectIntf, CompOptsIntf, Project,
  LazDroidConfig, LazDroidDeviceManager;

type
  TLazDroidActionProc = procedure(Sender: TObject);

  { TLazDroidEditorBar }
  TLazDroidEditorBar = class(TComponent)
  private
    FBar: TPanel;
    FCbPlatform: TComboBox;
    FCbDevice: TComboBox;
    FBtnRefresh: TSpeedButton;
    FCbResolution: TComboBox;
    FCbBuildMode: TComboBox;
    FBtnDeploy: TSpeedButton;
    FBtnLogcat: TSpeedButton;
    FTimerAttach: TTimer;
    FDeviceManager: TLazDroidDeviceManager;
    FDevices: TAndroidDeviceArray;
    FUpdating: Boolean;
    FLastEditorForm: TCustomForm;
    FOnDeploy: TLazDroidActionProc;
    FOnLogcat: TLazDroidActionProc;

    function FindCodeEditorForm: TCustomForm;
    function IsAndroidProject: Boolean;
    procedure PlatformChange(Sender: TObject);
    procedure DeviceChange(Sender: TObject);
    procedure ResolutionChange(Sender: TObject);
    procedure BuildModeChange(Sender: TObject);
    procedure RefreshClick(Sender: TObject);
    procedure DeployClick(Sender: TObject);
    procedure LogcatClick(Sender: TObject);
    procedure TimerAttachTimer(Sender: TObject);
    function ProjectOpened(Sender: TObject; AProject: TLazProject): TModalResult;
    function ProjectClosed(Sender: TObject; AProject: TLazProject): TModalResult;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CreateBar;
    procedure AttachBar;
    procedure UpdateBar;
    procedure RefreshDevices(const AForce: Boolean = False);
    procedure UpdateResolutionForSelectedDevice;

    property OnDeploy: TLazDroidActionProc read FOnDeploy write FOnDeploy;
    property OnLogcat: TLazDroidActionProc read FOnLogcat write FOnLogcat;
  end;

var
  LazDroidEditorBarInstance: TLazDroidEditorBar = nil;

procedure InstallLazDroidEditorBar;
procedure UninstallLazDroidEditorBar;

implementation

procedure InstallLazDroidEditorBar;
begin
  if not Assigned(LazDroidEditorBarInstance) then
    LazDroidEditorBarInstance := TLazDroidEditorBar.Create(nil);
end;

procedure UninstallLazDroidEditorBar;
begin
  if Assigned(LazDroidEditorBarInstance) then
    FreeAndNil(LazDroidEditorBarInstance);
end;

{ TLazDroidEditorBar }

constructor TLazDroidEditorBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDeviceManager := TLazDroidDeviceManager.Create(DroidConfig.AdbPath);
  FUpdating := False;
  FLastEditorForm := nil;

  // Timer para ancoragem contínua e monitoramento da IDE
  FTimerAttach := TTimer.Create(Self);
  FTimerAttach.Interval := 1000;
  FTimerAttach.OnTimer := @TimerAttachTimer;
  FTimerAttach.Enabled := True;

  if Assigned(LazarusIDE) then
  begin
    LazarusIDE.AddHandlerOnProjectOpened(@ProjectOpened);
    LazarusIDE.AddHandlerOnProjectClose(@ProjectClosed);
  end;
end;

destructor TLazDroidEditorBar.Destroy;
begin
  FTimerAttach.Enabled := False;
  if Assigned(LazarusIDE) then
  begin
    LazarusIDE.RemoveHandlerOnProjectOpened(@ProjectOpened);
    LazarusIDE.RemoveHandlerOnProjectClose(@ProjectClosed);
  end;

  if Assigned(FBar) then
    FreeAndNil(FBar);

  if Assigned(FDeviceManager) then
    FreeAndNil(FDeviceManager);

  inherited Destroy;
end;

function TLazDroidEditorBar.FindCodeEditorForm: TCustomForm;
var
  vForm: TCustomForm;
  I: Integer;
begin
  Result := nil;

  // 1. Tenta a última janela ativada da IDE
  if Assigned(LazarusIDE.LastFormActivated) and (LazarusIDE.LastFormActivated is TCustomForm) then
  begin
    vForm := TCustomForm(LazarusIDE.LastFormActivated);
    if SameText(vForm.ClassName, 'TSourceEditorWindow') or
       SameText(vForm.Caption, 'Editor de Código') or
       SameText(vForm.Caption, 'Source Editor') then
    begin
      Result := vForm;
      Exit;
    end;
  end;

  // 2. Procura entre os formulários visíveis da tela
  for I := Screen.CustomFormCount - 1 downto 0 do
  begin
    vForm := Screen.CustomForms[I];
    if Assigned(vForm) and vForm.Visible then
    begin
      if SameText(vForm.ClassName, 'TSourceEditorWindow') or
         SameText(vForm.Caption, 'Editor de Código') or
         SameText(vForm.Caption, 'Source Editor') then
      begin
        Result := vForm;
        Exit;
      end;
    end;
  end;

  // 3. Procura por nome de classe padrão da janela do Source Notebook
  for I := 0 to Screen.CustomFormCount - 1 do
  begin
    vForm := Screen.CustomForms[I];
    if Assigned(vForm) and (SameText(vForm.ClassName, 'TSourceEditorWindow') or
       SameText(vForm.ClassName, 'SourceEditorWindow')) then
    begin
      Result := vForm;
      Exit;
    end;
  end;
end;

function TLazDroidEditorBar.IsAndroidProject: Boolean;
var
  P: TLazProject;
begin
  Result := False;
  P := LazarusIDE.ActiveProject;
  if not Assigned(P) then Exit;

  // 1. TargetOS é Android?
  if SameText(P.LazCompilerOptions.TargetOS, 'android') then
  begin
    Result := True;
    Exit;
  end;

  // 2. CustomOptions contém customdrawn ou -dandroid?
  if (Pos('customdrawn', LowerCase(P.LazCompilerOptions.CustomOptions)) > 0) or
     (Pos('-dandroid', LowerCase(P.LazCompilerOptions.CustomOptions)) > 0) then
  begin
    Result := True;
    Exit;
  end;

  // 3. Se DroidConfig tem diretório scaffold configurado
  if (DroidConfig.ScaffoldDirectory <> '') and DirectoryExists(DroidConfig.ScaffoldDirectory) then
  begin
    Result := True;
    Exit;
  end;
end;

procedure TLazDroidEditorBar.CreateBar;
var
  vEditor: TCustomForm;
begin
  if Assigned(FBar) then Exit;
  vEditor := FindCodeEditorForm;
  if not Assigned(vEditor) then Exit;

  FLastEditorForm := vEditor;

  FBar := TPanel.Create(Self);
  FBar.Name := 'LazDroidQuickToolBar';
  FBar.Caption := '';
  FBar.Parent := vEditor;
  FBar.Align := alTop;
  FBar.AutoSize := False;
  FBar.BevelOuter := bvNone;
  FBar.Height := 34;
  FBar.Visible := True;
  FBar.DoubleBuffered := True;

  // 1. Plataforma / ABI
  FCbPlatform := TComboBox.Create(FBar);
  FCbPlatform.Parent := FBar;
  FCbPlatform.Left := 6;
  FCbPlatform.Top := 5;
  FCbPlatform.Width := 195;
  FCbPlatform.Height := 24;
  FCbPlatform.Style := csDropDownList;
  FCbPlatform.Color := clWhite;
  FCbPlatform.Font.Color := clBlack;
  FCbPlatform.Items.Add('Android ARM64 (aarch64)');
  FCbPlatform.Items.Add('Android ARMv7 (armeabi-v7a)');
  FCbPlatform.Items.Add('Android x86_64');
  FCbPlatform.Items.Add('Android x86');
  FCbPlatform.ItemIndex := 0;
  FCbPlatform.OnChange := @PlatformChange;
  FCbPlatform.ShowHint := True;
  FCbPlatform.Hint := 'Arquitetura e Plataforma Alvo Android (ABI)';

  // 2. Aparelho Conectado (Modelo + Serial)
  FCbDevice := TComboBox.Create(FBar);
  FCbDevice.Parent := FBar;
  FCbDevice.Left := 207;
  FCbDevice.Top := 5;
  FCbDevice.Width := 290;
  FCbDevice.Height := 24;
  FCbDevice.Style := csDropDownList;
  FCbDevice.Color := clWhite;
  FCbDevice.Font.Color := clBlack;
  FCbDevice.Items.Add('(Procurando dispositivos USB...)');
  FCbDevice.ItemIndex := 0;
  FCbDevice.OnChange := @DeviceChange;
  FCbDevice.ShowHint := True;
  FCbDevice.Hint := 'Dispositivo Android conectado via USB (ADB)';

  // 3. Botão Refresh
  FBtnRefresh := TSpeedButton.Create(FBar);
  FBtnRefresh.Parent := FBar;
  FBtnRefresh.Left := 503;
  FBtnRefresh.Top := 4;
  FBtnRefresh.Width := 26;
  FBtnRefresh.Height := 24;
  FBtnRefresh.Caption := '⟳';
  FBtnRefresh.Font.Style := [fsBold];
  FBtnRefresh.Font.Size := 12;
  FBtnRefresh.Flat := True;
  FBtnRefresh.ShowHint := True;
  FBtnRefresh.Hint := 'Atualizar lista de dispositivos conectados via ADB';
  FBtnRefresh.OnClick := @RefreshClick;

  // 4. Resolução da Tela
  FCbResolution := TComboBox.Create(FBar);
  FCbResolution.Parent := FBar;
  FCbResolution.Left := 535;
  FCbResolution.Top := 5;
  FCbResolution.Width := 200;
  FCbResolution.Height := 24;
  FCbResolution.Style := csDropDownList;
  FCbResolution.Color := clWhite;
  FCbResolution.Font.Color := clBlack;
  FCbResolution.Items.Add('Device (Auto)');
  FCbResolution.Items.Add('360 x 800 (FHD+ 20:9)');
  FCbResolution.Items.Add('720 x 1600 (HD+ 20:9)');
  FCbResolution.Items.Add('1080 x 1920 (FHD 16:9)');
  FCbResolution.Items.Add('1080 x 2400 (FHD+ 20:9)');
  FCbResolution.Items.Add('1440 x 3200 (QHD+)');
  FCbResolution.ItemIndex := 0;
  FCbResolution.OnChange := @ResolutionChange;
  FCbResolution.ShowHint := True;
  FCbResolution.Hint := 'Resolução real de exibição do dispositivo conectado';

  // 5. Modo de Compilação (Debug / Release)
  FCbBuildMode := TComboBox.Create(FBar);
  FCbBuildMode.Parent := FBar;
  FCbBuildMode.Left := 741;
  FCbBuildMode.Top := 5;
  FCbBuildMode.Width := 90;
  FCbBuildMode.Height := 24;
  FCbBuildMode.Style := csDropDownList;
  FCbBuildMode.Color := clWhite;
  FCbBuildMode.Font.Color := clBlack;
  FCbBuildMode.Items.Add('Debug');
  FCbBuildMode.Items.Add('Release');
  FCbBuildMode.ItemIndex := 0;
  FCbBuildMode.OnChange := @BuildModeChange;
  FCbBuildMode.ShowHint := True;
  FCbBuildMode.Hint := 'Modo de build da aplicação (Debug ou Release)';

  // 6. Botão Deploy Rápido (1 clique)
  FBtnDeploy := TSpeedButton.Create(FBar);
  FBtnDeploy.Parent := FBar;
  FBtnDeploy.Left := 837;
  FBtnDeploy.Top := 4;
  FBtnDeploy.Width := 90;
  FBtnDeploy.Height := 24;
  FBtnDeploy.Caption := '▶ Deploy';
  FBtnDeploy.Font.Style := [fsBold];
  FBtnDeploy.Flat := False;
  FBtnDeploy.ShowHint := True;
  FBtnDeploy.Hint := 'Compilar, empacotar e fazer Deploy no aparelho USB selecionado (F9)';
  FBtnDeploy.OnClick := @DeployClick;

  // 7. Botão Logcat Rápido
  FBtnLogcat := TSpeedButton.Create(FBar);
  FBtnLogcat.Parent := FBar;
  FBtnLogcat.Left := 933;
  FBtnLogcat.Top := 4;
  FBtnLogcat.Width := 65;
  FBtnLogcat.Height := 24;
  FBtnLogcat.Caption := 'Logcat';
  FBtnLogcat.Flat := False;
  FBtnLogcat.ShowHint := True;
  FBtnLogcat.Hint := 'Abrir monitor de Logcat em tempo real';
  FBtnLogcat.OnClick := @LogcatClick;

  FBar.BringToFront;
  RefreshDevices(False);
end;

procedure TLazDroidEditorBar.AttachBar;
var
  vEditor: TCustomForm;
  MustShow: Boolean;
begin
  vEditor := FindCodeEditorForm;
  if not Assigned(vEditor) then Exit;

  if not Assigned(FBar) then
  begin
    CreateBar;
    Exit;
  end;

  if FBar.Parent <> vEditor then
  begin
    FBar.Parent := vEditor;
    FBar.Align := alTop;
    FLastEditorForm := vEditor;
  end;

  MustShow := IsAndroidProject;
  if FBar.Visible <> MustShow then
    FBar.Visible := MustShow;

  if MustShow then
    FBar.BringToFront;
end;

procedure TLazDroidEditorBar.UpdateBar;
begin
  AttachBar;
  if Assigned(FBar) and FBar.Visible then
    RefreshDevices(False);
end;

procedure TLazDroidEditorBar.RefreshDevices(const AForce: Boolean);
var
  I: Integer;
  DevDesc: string;
  SelectedIdx: Integer;
  SavedSerial: string;
begin
  if not Assigned(FCbDevice) then Exit;

  FUpdating := True;
  try
    FDevices := FDeviceManager.EnumerateDevices;
    FCbDevice.Items.Clear;

    if Length(FDevices) = 0 then
    begin
      FCbDevice.Items.Add('(Nenhum aparelho Android conectado)');
      FCbDevice.ItemIndex := 0;
      Exit;
    end;

    SelectedIdx := -1;
    SavedSerial := DroidConfig.TargetDeviceSerial;

    for I := 0 to High(FDevices) do
    begin
      DevDesc := FDevices[I].Model;
      if DevDesc = '' then
        DevDesc := FDevices[I].DeviceCode;
      if DevDesc = '' then
        DevDesc := 'Android Device';

      DevDesc := DevDesc + ' [' + FDevices[I].Serial + ']';

      if not FDevices[I].IsReady then
        DevDesc := DevDesc + ' (' + FDevices[I].State + ')';

      FCbDevice.Items.Add(DevDesc);

      if (SelectedIdx < 0) and (SavedSerial <> '') and (FDevices[I].Serial = SavedSerial) then
        SelectedIdx := I;
    end;

    if (SelectedIdx < 0) and (Length(FDevices) > 0) then
      SelectedIdx := 0;

    FCbDevice.ItemIndex := SelectedIdx;

    if (SelectedIdx >= 0) and (SelectedIdx < Length(FDevices)) then
    begin
      DroidConfig.TargetDeviceSerial := FDevices[SelectedIdx].Serial;

      // Sincroniza a ABI da plataforma se conhecida
      if Pos('arm64', LowerCase(FDevices[SelectedIdx].PrimaryAbi)) > 0 then
        FCbPlatform.ItemIndex := 0
      else if Pos('arm', LowerCase(FDevices[SelectedIdx].PrimaryAbi)) > 0 then
        FCbPlatform.ItemIndex := 1
      else if Pos('x86_64', LowerCase(FDevices[SelectedIdx].PrimaryAbi)) > 0 then
        FCbPlatform.ItemIndex := 2
      else if Pos('x86', LowerCase(FDevices[SelectedIdx].PrimaryAbi)) > 0 then
        FCbPlatform.ItemIndex := 3;

      UpdateResolutionForSelectedDevice;
    end;
  finally
    FUpdating := False;
  end;
end;

procedure TLazDroidEditorBar.UpdateResolutionForSelectedDevice;
var
  DevSerial: string;
  Res, Dens: string;
  DisplayStr: string;
  Output: string;
begin
  if not Assigned(FCbResolution) or not Assigned(FCbDevice) then Exit;
  if (FCbDevice.ItemIndex < 0) or (Length(FDevices) = 0) then Exit;
  if FCbDevice.ItemIndex >= Length(FDevices) then Exit;

  DevSerial := FDevices[FCbDevice.ItemIndex].Serial;
  if DevSerial = '' then Exit;

  Res := FDeviceManager.QueryDeviceScreenSize(DevSerial);
  if Res = '' then
    Res := FDevices[FCbDevice.ItemIndex].ScreenSize;

  // Consulta densidade real dpi via ADB
  Dens := '';
  if FDeviceManager.RunCommandSync(DroidConfig.AdbPath, ['-s', DevSerial, 'shell', 'wm', 'density'], Output) = 0 then
  begin
    Output := Trim(Output);
    Output := StringReplace(Output, 'Physical density: ', '', [rfIgnoreCase]);
    if Output <> '' then
      Dens := Trim(Output) + 'dpi';
  end;

  if Res <> '' then
  begin
    if Dens <> '' then
      DisplayStr := 'Device (' + Res + ' ' + Dens + ')'
    else
      DisplayStr := 'Device (' + Res + ')';

    FCbResolution.Items[0] := DisplayStr;
    FCbResolution.ItemIndex := 0;
  end;
end;

procedure TLazDroidEditorBar.PlatformChange(Sender: TObject);
var
  TargetCpu: string;
  SelectedAbi: TAndroidAbi;
begin
  if FUpdating then Exit;
  case FCbPlatform.ItemIndex of
    0: begin TargetCpu := 'aarch64'; SelectedAbi := abiArm64_v8a; end;
    1: begin TargetCpu := 'arm';     SelectedAbi := abiArmeabi_v7a; end;
    2: begin TargetCpu := 'x86_64';  SelectedAbi := abiX86_64; end;
    3: begin TargetCpu := 'i386';    SelectedAbi := abiX86; end;
    else Exit;
  end;

  DroidConfig.DefaultAbi := SelectedAbi;

  if Assigned(LazarusIDE.ActiveProject) then
  begin
    LazarusIDE.ActiveProject.LazCompilerOptions.TargetOS := 'android';
    LazarusIDE.ActiveProject.LazCompilerOptions.TargetCPU := TargetCpu;
    LazarusIDE.PrepareBuildTarget(True);
  end;
end;

procedure TLazDroidEditorBar.DeviceChange(Sender: TObject);
var
  Idx: Integer;
begin
  if FUpdating then Exit;
  Idx := FCbDevice.ItemIndex;
  if (Idx >= 0) and (Idx < Length(FDevices)) then
  begin
    DroidConfig.TargetDeviceSerial := FDevices[Idx].Serial;
    UpdateResolutionForSelectedDevice;
  end;
end;

procedure TLazDroidEditorBar.ResolutionChange(Sender: TObject);
begin
  // Permite selecionar proporções de tela para testes de layout
end;

procedure TLazDroidEditorBar.BuildModeChange(Sender: TObject);
begin
  if FUpdating then Exit;
  if not Assigned(LazarusIDE.ActiveProject) then Exit;
  LazarusIDE.ActiveProject.CustomData.Values['LazDroid.BuildMode'] := FCbBuildMode.Text;
  if FCbBuildMode.ItemIndex = 1 then
    DroidConfig.LogLevelDebug := False
  else
    DroidConfig.LogLevelDebug := True;
end;

procedure TLazDroidEditorBar.RefreshClick(Sender: TObject);
begin
  RefreshDevices(True);
end;

procedure TLazDroidEditorBar.DeployClick(Sender: TObject);
begin
  if Assigned(FOnDeploy) then
    FOnDeploy(Sender);
end;

procedure TLazDroidEditorBar.LogcatClick(Sender: TObject);
var
  Serial: string;
begin
  if Assigned(FOnLogcat) then
  begin
    FOnLogcat(Sender);
    Exit;
  end;

  Serial := DroidConfig.TargetDeviceSerial;
  if (Serial = '') and (Length(FDevices) > 0) then
    Serial := FDevices[0].Serial;

  if Serial <> '' then
    FDeviceManager.OpenLogcatConsole(Serial, DroidConfig.LogcatFilter);
end;

procedure TLazDroidEditorBar.TimerAttachTimer(Sender: TObject);
begin
  AttachBar;
end;

function TLazDroidEditorBar.ProjectOpened(Sender: TObject; AProject: TLazProject): TModalResult;
begin
  UpdateBar;
  Result := mrOk;
end;

function TLazDroidEditorBar.ProjectClosed(Sender: TObject; AProject: TLazProject): TModalResult;
begin
  if Assigned(FBar) then
    FBar.Visible := False;
  Result := mrOk;
end;

end.
