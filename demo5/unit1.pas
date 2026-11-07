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
  LazDroidEdit1.Text := 'admin';
  LazDroidEdit2.Text := '1234';
end;

procedure TForm1.LazDroidButton1Click(Sender: TObject);
var
  NomeUser, NivelUser: string;
begin
  if Trim(LazDroidEdit1.Text) = '' then
  begin
    ShowMobileToast(Self, 'Por favor, informe o seu usuário.');
    Exit;
  end;

  if Trim(LazDroidEdit2.Text) = '' then
  begin
    ShowMobileToast(Self, 'Por favor, informe a sua senha.');
    Exit;
  end;

  DLog('click: validando');
  if Assigned(DataModule1) and DataModule1.ValidarLogin(LazDroidEdit1.Text, LazDroidEdit2.Text, NomeUser, NivelUser) then
  begin
    DLog('click: login ok');
    if not Assigned(Form2) then
      Application.CreateForm(TForm2, Form2);
    DLog('click: form2 criado');

    Form2.ConfigurarSessao(NomeUser, NivelUser);
    DLog('click: sessao ok');
    Form2.WindowState := Self.WindowState;
    Form2.SetBounds(0, 0, Screen.Width, Screen.Height);
    Form2.Show;
    DLog('click: form2 show ok');
    // No CustomDrawn/Android o OnShow nao e disparado: abre o CRUD de clientes explicitamente
    Form2.FormShow(Self);
    Self.Hide;
    DLog('click: form1 hide ok');
  end
  else
  begin
    ShowMobileToast(Self, 'Acesso negado: Usuário ou senha inválidos.');
  end;
end;

end.
