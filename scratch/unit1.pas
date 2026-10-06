unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LazDroidMobileControls, Unit3, Unit4;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    LazDroidButton1: TLazDroidButton;
    LazDroidEdit1: TLazDroidEdit;
    LazDroidEdit2: TLazDroidEdit;
    LazDroidLayout1: TLazDroidLayout;
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
  LazDroidEdit1.Placeholder := 'Usuário (admin / vendedor)';
  LazDroidEdit2.Placeholder := 'Senha (1234)';
  LazDroidEdit2.IsPassword := True;
end;

procedure TForm1.LazDroidButton1Click(Sender: TObject);
var
  NomeUser, NivelUser: string;
begin
  if Trim(LazDroidEdit1.Text) = '' then
  begin
    ShowMessage('Por favor, informe o seu usuário.');
    Exit;
  end;

  if Trim(LazDroidEdit2.Text) = '' then
  begin
    ShowMessage('Por favor, informe a sua senha.');
    Exit;
  end;

  if Assigned(DataModule1) and DataModule1.ValidarLogin(LazDroidEdit1.Text, LazDroidEdit2.Text, NomeUser, NivelUser) then
  begin
    if not Assigned(Form2) then
      Application.CreateForm(TForm2, Form2);

    Form2.WindowState := Self.WindowState;
    Form2.Show;
    Self.Hide;
  end
  else
  begin
    ShowMessage('Acesso negado: Usuário ou senha inválidos.');
  end;
end;

end.
