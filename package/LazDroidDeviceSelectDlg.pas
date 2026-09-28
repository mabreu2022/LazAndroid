{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidDeviceSelectDlg.pas
  Descrição: Diálogo rápido de seleção de dispositivo USB conectado via ADB.
}
unit LazDroidDeviceSelectDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, LazDroidDeviceManager, LazDroidConfig;

type
  { TLazDroidDeviceSelectForm }
  TLazDroidDeviceSelectForm = class(TForm)
    pnlBottom: TPanel;
    btnDeploy: TBitBtn;
    btnCancel: TBitBtn;
    btnRefresh: TButton;
    grpDevices: TGroupBox;
    lstDevices: TListBox;
    lblStatus: TLabel;
    pnlInfo: TPanel;
    lblDetails: TLabel;

    procedure FormShow(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure lstDevicesSelectionChange(Sender: TObject; User: boolean);
    procedure lstDevicesDblClick(Sender: TObject);
  private
    FDevManager: TLazDroidDeviceManager;
    FDevices: TAndroidDeviceArray;
    FSelectedDevice: TAndroidDevice;
    function GetSelectedSerial: string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure RefreshDevices;
    property SelectedDevice: TAndroidDevice read FSelectedDevice;
    property SelectedSerial: string read GetSelectedSerial;
  end;

function ShowSelectDeviceDialog(out AChosenDevice: TAndroidDevice): Boolean;

implementation

{$R *.lfm}

function ShowSelectDeviceDialog(out AChosenDevice: TAndroidDevice): Boolean;
var
  Dlg: TLazDroidDeviceSelectForm;
begin
  Result := False;
  Dlg := TLazDroidDeviceSelectForm.Create(Application);
  try
    Dlg.RefreshDevices;
    if Length(Dlg.FDevices) = 1 then
    begin
      // Se houver exatamente um dispositivo pronto, seleciona imediatamente
      if Dlg.FDevices[0].IsReady then
      begin
        AChosenDevice := Dlg.FDevices[0];
        Exit(True);
      end;
    end;

    if Dlg.ShowModal = mrOk then
    begin
      AChosenDevice := Dlg.SelectedDevice;
      Result := AChosenDevice.IsReady;
    end;
  finally
    Dlg.Free;
  end;
end;

{ TLazDroidDeviceSelectForm }

constructor TLazDroidDeviceSelectForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDevManager := TLazDroidDeviceManager.Create(DroidConfig.AdbPath);
end;

destructor TLazDroidDeviceSelectForm.Destroy;
begin
  FDevManager.Free;
  inherited Destroy;
end;

function TLazDroidDeviceSelectForm.GetSelectedSerial: string;
begin
  Result := FSelectedDevice.Serial;
end;

procedure TLazDroidDeviceSelectForm.FormShow(Sender: TObject);
begin
  RefreshDevices;
end;

procedure TLazDroidDeviceSelectForm.RefreshDevices;
var
  I: Integer;
begin
  lstDevices.Clear;
  lblDetails.Caption := 'Nenhum dispositivo selecionado.';
  btnDeploy.Enabled := False;

  FDevices := FDevManager.EnumerateDevices;
  if Length(FDevices) = 0 then
  begin
    lblStatus.Caption := 'Nenhum dispositivo Android detectado via ADB.';
    Exit;
  end;

  lblStatus.Caption := Format('%d dispositivo(s) conectado(s).', [Length(FDevices)]);

  for I := Low(FDevices) to High(FDevices) do
  begin
    FDevices[I].PrimaryAbi := FDevManager.QueryDeviceAbi(FDevices[I].Serial);
    FDevices[I].AndroidVersion := FDevManager.QueryAndroidVersion(FDevices[I].Serial);
    lstDevices.Items.Add(FDevManager.FormatDeviceDescription(FDevices[I]));
  end;

  if lstDevices.Count > 0 then
  begin
    lstDevices.ItemIndex := 0;
    lstDevicesSelectionChange(nil, True);
  end;
end;

procedure TLazDroidDeviceSelectForm.btnRefreshClick(Sender: TObject);
begin
  RefreshDevices;
end;

procedure TLazDroidDeviceSelectForm.lstDevicesSelectionChange(Sender: TObject; User: boolean);
var
  Idx: Integer;
begin
  Idx := lstDevices.ItemIndex;
  if (Idx >= 0) and (Idx < Length(FDevices)) then
  begin
    FSelectedDevice := FDevices[Idx];
    btnDeploy.Enabled := FSelectedDevice.IsReady;

    lblDetails.Caption := Format(
      'Modelo: %s' + LineEnding +
      'Serial: %s' + LineEnding +
      'Arquitetura (ABI): %s' + LineEnding +
      'Versão Android: %s' + LineEnding +
      'Estado: %s',
      [FSelectedDevice.Model,
       FSelectedDevice.Serial,
       FSelectedDevice.PrimaryAbi,
       FSelectedDevice.AndroidVersion,
       FSelectedDevice.State]
    );

    if not FSelectedDevice.IsReady then
      lblDetails.Caption := lblDetails.Caption + LineEnding +
        'ATENÇÃO: Aparelho não autorizado ou offline. Autorize no display do celular!';
  end
  else
  begin
    btnDeploy.Enabled := False;
    lblDetails.Caption := 'Selecione um dispositivo válido.';
  end;
end;

procedure TLazDroidDeviceSelectForm.lstDevicesDblClick(Sender: TObject);
begin
  if btnDeploy.Enabled then
    ModalResult := mrOk;
end;

end.
