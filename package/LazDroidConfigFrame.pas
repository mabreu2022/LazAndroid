{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidConfigFrame.pas
  Descrição: Frame de configuração integrado às Opções da IDE do Lazarus (IDEOptionsIntf).
}
unit LazDroidConfigFrame;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, StdCtrls, EditBtn, Dialogs, ExtCtrls,
  IDEOptionsIntf, IDEOptEditorIntf, LazDroidConfig;

type
  { TLazDroidOptionsFrame }
  TLazDroidOptionsFrame = class(TAbstractIDEOptionsEditor)
    pnlTop: TPanel;
    btnAutoDetect: TButton;
    lblInfo: TLabel;

    grpPaths: TGroupBox;
    lblSdk: TLabel;
    edtSdk: TDirectoryEdit;
    lblNdk: TLabel;
    edtNdk: TDirectoryEdit;
    lblAdb: TLabel;
    edtAdb: TFileNameEdit;
    lblJava: TLabel;
    edtJava: TDirectoryEdit;

    grpFpc: TGroupBox;
    lblFpcA64: TLabel;
    edtFpcA64: TFileNameEdit;
    lblFpcArm: TLabel;
    edtFpcArm: TFileNameEdit;
    lblExtraFlags: TLabel;
    edtExtraFlags: TEdit;

    grpProject: TGroupBox;
    lblScaffold: TLabel;
    edtScaffold: TDirectoryEdit;
    lblPackage: TLabel;
    edtPackage: TEdit;
    lblActivity: TLabel;
    edtActivity: TEdit;
    chkAutoLogcat: TCheckBox;

    procedure btnAutoDetectClick(Sender: TObject);
  public
    class function SupportedOptionsClass: TAbstractIDEOptionsClass; override;
    function GetTitle: string; override;
    procedure Setup({%H-}ADialog: TAbstractOptionsEditorDialog); override;
    procedure ReadSettings({%H-}AOptions: TAbstractIDEOptions); override;
    procedure WriteSettings({%H-}AOptions: TAbstractIDEOptions); override;
  end;

implementation

{$R *.lfm}

{ TLazDroidOptionsFrame }

class function TLazDroidOptionsFrame.SupportedOptionsClass: TAbstractIDEOptionsClass;
begin
  Result := IDEEditorGroups.GetByIndex(GroupEnvironment)^.GroupClass;
end;

function TLazDroidOptionsFrame.GetTitle: string;
begin
  Result := 'LazDroid Android Deploy';
end;

procedure TLazDroidOptionsFrame.Setup(ADialog: TAbstractOptionsEditorDialog);
begin
  // Inicialização de controles de interface
end;

procedure TLazDroidOptionsFrame.ReadSettings(AOptions: TAbstractIDEOptions);
var
  Cfg: TLazDroidSettings;
begin
  Cfg := DroidConfig;
  edtSdk.Directory       := Cfg.AndroidSdkRoot;
  edtNdk.Directory       := Cfg.AndroidNdkRoot;
  edtAdb.FileName        := Cfg.AdbPath;
  edtJava.Directory      := Cfg.JavaHome;
  edtFpcA64.FileName     := Cfg.FpcCrossAarch64;
  edtFpcArm.FileName     := Cfg.FpcCrossArm;
  edtExtraFlags.Text     := Cfg.ExtraFpcFlags;
  edtScaffold.Directory  := Cfg.ScaffoldDirectory;
  edtPackage.Text        := Cfg.PackageName;
  edtActivity.Text       := Cfg.ActivityName;
  chkAutoLogcat.Checked  := Cfg.AutoShowLogcat;
end;

procedure TLazDroidOptionsFrame.WriteSettings(AOptions: TAbstractIDEOptions);
var
  Cfg: TLazDroidSettings;
begin
  Cfg := DroidConfig;
  Cfg.AndroidSdkRoot    := edtSdk.Directory;
  Cfg.AndroidNdkRoot    := edtNdk.Directory;
  Cfg.AdbPath           := edtAdb.FileName;
  Cfg.JavaHome          := edtJava.Directory;
  Cfg.FpcCrossAarch64   := edtFpcA64.FileName;
  Cfg.FpcCrossArm       := edtFpcArm.FileName;
  Cfg.ExtraFpcFlags     := edtExtraFlags.Text;
  Cfg.ScaffoldDirectory := edtScaffold.Directory;
  Cfg.PackageName       := edtPackage.Text;
  Cfg.ActivityName      := edtActivity.Text;
  Cfg.AutoShowLogcat    := chkAutoLogcat.Checked;
  Cfg.Save;
end;

procedure TLazDroidOptionsFrame.btnAutoDetectClick(Sender: TObject);
var
  Cfg: TLazDroidSettings;
begin
  Cfg := DroidConfig;
  Cfg.AutoDetectPaths;
  ReadSettings(nil);
  ShowMessage('Caminhos do Android SDK, ADB, NDK e FPC autodetectados com sucesso!');
end;

end.
