unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LazDroidMobileControls;

type

  { TForm1 }

  TForm1 = class(TForm)
    LazDroidAppBar1: TLazDroidAppBar;
    LazDroidButton1: TLazDroidButton;
    LazDroidSwitch1: TLazDroidSwitch;
    LazDroidActivityIndicator1: TLazDroidActivityIndicator;
    LazDroidFAB1: TLazDroidFAB;
    procedure FormCreate(Sender: TObject);
    procedure LazDroidButton1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  AdaptMobileFormLayout(Self);
end;

procedure TForm1.LazDroidButton1Click(Sender: TObject);
begin
  Showmessage('olá mundo!');
end;

end.

