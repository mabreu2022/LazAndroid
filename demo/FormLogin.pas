unit FormLogin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  SalesData, SalesDatabase;

type
  { TFormLogin }

  TFormLogin = class(TForm)
    pnlCard: TPanel;
    pnlHeaderBadge: TPanel;
    lblHeaderBadge: TLabel;
    lblLogo: TLabel;
    lblSubtitle: TLabel;
    lblWelcome: TLabel;
    lblDbStatus: TLabel;
    lblEmpresa: TLabel;
    edtEmpresa: TEdit;
    lblUsuario: TLabel;
    edtUsuario: TEdit;
    lblSenha: TLabel;
    edtSenha: TEdit;
    chkLembrar: TCheckBox;
    btnLogin: TButton;
    lblMensagem: TLabel;
    pnlSyncInfo: TPanel;
    lblSyncTitle: TLabel;
    lblSyncDesc: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
  private
    FLoginEfetuado: Boolean;
    procedure AtualizarStatusBanco;
  public
    property LoginEfetuado: Boolean read FLoginEfetuado;
  end;

var
  frmLogin: TFormLogin;

implementation

uses FormVendas;

{$R *.lfm}

{ TFormLogin }

procedure TFormLogin.AtualizarStatusBanco;
var
  CliC, ProdC, OrdC: Integer;
begin
  if SalesDB.IsConnected then
  begin
    SalesDB.ObterEstatisticas(CliC, ProdC, OrdC);
    lblDbStatus.Font.Color := TColor($004A6C00); // Verde Esmeralda VendaForce
    lblDbStatus.Caption := Format('● SQLite Conectado: %s (%d Clientes | %d Produtos | %d Pedidos)',
      [ExtractFileName(SalesDB.DbPath), CliC, ProdC, OrdC]);
    lblSyncTitle.Caption := 'Tabelas de Precos e Estoque: Pronto';
    lblSyncDesc.Caption := Format('Base SQLite "%s" integrada (Modo Offline apto)', [ExtractFileName(SalesDB.DbPath)]);
  end
  else
  begin
    lblDbStatus.Font.Color := TColor($000677D9); // Âmbar alerta
    lblDbStatus.Caption := '○ SQLite: ' + SalesDB.StatusMsg;
    lblSyncTitle.Caption := 'SQLite em Modo Fallback';
    lblSyncDesc.Caption := 'Memoria local ativa';
  end;
end;

function __android_log_write(prio: Integer; tag: PChar; text: PChar): Integer; cdecl; external 'liblog.so' name '__android_log_write';

procedure TFormLogin.FormResize(Sender: TObject);
var
  Scale: Double;
  TargetW, TargetH: Integer;
  Margin, CardW, Pad, InnerW, TopMargin, CurY: Integer;
begin
  TargetW := ClientWidth;
  TargetH := ClientHeight;
  if TargetW < Screen.Width then TargetW := Screen.Width;
  if TargetH < Screen.Height then TargetH := Screen.Height;
  if TargetW < 800 then TargetW := 1080;
  if TargetH < 1200 then TargetH := 2168;

  Self.Left := 0;
  Self.Top := 0;
  Self.Width := TargetW;
  Self.Height := TargetH;

  // Escala mobile para Samsung Galaxy (1080 / 360 = 3.0x)
  Scale := TargetW / 360.0;
  if Scale < 1.0 then Scale := 1.0;

  Margin := Round(14 * Scale); // ~42px
  TopMargin := Round(28 * Scale); // ~84px
  CardW := TargetW - (2 * Margin);

  pnlCard.Left := Margin;
  pnlCard.Top := TopMargin;
  pnlCard.Width := CardW;
  pnlCard.Height := TargetH - TopMargin - Margin;

  Pad := Round(16 * Scale); // ~48px
  InnerW := pnlCard.Width - (2 * Pad);

  CurY := Round(16 * Scale);

  // 1. Badge Superior
  pnlHeaderBadge.Left := Pad;
  pnlHeaderBadge.Top := CurY;
  pnlHeaderBadge.Width := InnerW;
  pnlHeaderBadge.Height := Round(32 * Scale);
  lblHeaderBadge.Font.Height := -Round(11 * Scale); // ~33px
  Inc(CurY, pnlHeaderBadge.Height + Round(12 * Scale));

  // 2. Logo VENDAFORCE MOBILE
  lblLogo.Left := Pad;
  lblLogo.Top := CurY;
  lblLogo.Width := InnerW;
  lblLogo.Height := Round(40 * Scale);
  lblLogo.Font.Height := -Round(22 * Scale); // ~66px (GRANDE, NÍTIDO, IMPONENTE!)
  lblLogo.Font.Style := [fsBold];
  Inc(CurY, lblLogo.Height + Round(4 * Scale));

  // 3. Subtítulo
  lblSubtitle.Left := Pad;
  lblSubtitle.Top := CurY;
  lblSubtitle.Width := InnerW;
  lblSubtitle.Height := Round(24 * Scale);
  lblSubtitle.Font.Height := -Round(12 * Scale); // ~36px
  Inc(CurY, lblSubtitle.Height + Round(10 * Scale));

  // 4. Bem-vindo de volta
  lblWelcome.Left := Pad;
  lblWelcome.Top := CurY;
  lblWelcome.Width := InnerW;
  lblWelcome.Height := Round(30 * Scale);
  lblWelcome.Font.Height := -Round(16 * Scale); // ~48px
  lblWelcome.Font.Style := [fsBold];
  Inc(CurY, lblWelcome.Height + Round(6 * Scale));

  // 5. Status do SQLite
  lblDbStatus.Left := Pad;
  lblDbStatus.Top := CurY;
  lblDbStatus.Width := InnerW;
  lblDbStatus.Height := Round(26 * Scale);
  lblDbStatus.Font.Height := -Round(11 * Scale); // ~33px
  Inc(CurY, lblDbStatus.Height + Round(16 * Scale));

  // 6. Label Empresa
  lblEmpresa.Left := Pad;
  lblEmpresa.Top := CurY;
  lblEmpresa.Width := InnerW;
  lblEmpresa.Height := Round(26 * Scale);
  lblEmpresa.Font.Height := -Round(13 * Scale); // ~39px
  lblEmpresa.Font.Style := [fsBold];
  Inc(CurY, lblEmpresa.Height + Round(6 * Scale));

  // 7. Edit Empresa
  edtEmpresa.Left := Pad;
  edtEmpresa.Top := CurY;
  edtEmpresa.Width := InnerW;
  edtEmpresa.Height := Round(52 * Scale); // ~156px (Fácil de tocar!)
  edtEmpresa.Font.Height := -Round(16 * Scale); // ~48px
  Inc(CurY, edtEmpresa.Height + Round(14 * Scale));

  // 8. Label Usuário
  lblUsuario.Left := Pad;
  lblUsuario.Top := CurY;
  lblUsuario.Width := InnerW;
  lblUsuario.Height := Round(26 * Scale);
  lblUsuario.Font.Height := -Round(13 * Scale); // ~39px
  lblUsuario.Font.Style := [fsBold];
  Inc(CurY, lblUsuario.Height + Round(6 * Scale));

  // 9. Edit Usuário
  edtUsuario.Left := Pad;
  edtUsuario.Top := CurY;
  edtUsuario.Width := InnerW;
  edtUsuario.Height := Round(52 * Scale); // ~156px
  edtUsuario.Font.Height := -Round(16 * Scale); // ~48px
  Inc(CurY, edtUsuario.Height + Round(14 * Scale));

  // 10. Label Senha
  lblSenha.Left := Pad;
  lblSenha.Top := CurY;
  lblSenha.Width := InnerW;
  lblSenha.Height := Round(26 * Scale);
  lblSenha.Font.Height := -Round(13 * Scale); // ~39px
  lblSenha.Font.Style := [fsBold];
  Inc(CurY, lblSenha.Height + Round(6 * Scale));

  // 11. Edit Senha
  edtSenha.Left := Pad;
  edtSenha.Top := CurY;
  edtSenha.Width := InnerW;
  edtSenha.Height := Round(52 * Scale); // ~156px
  edtSenha.Font.Height := -Round(16 * Scale); // ~48px
  Inc(CurY, edtSenha.Height + Round(12 * Scale));

  // 12. Checkbox Lembrar
  chkLembrar.Left := Pad;
  chkLembrar.Top := CurY;
  chkLembrar.Width := InnerW;
  chkLembrar.Height := Round(32 * Scale);
  chkLembrar.Font.Height := -Round(12 * Scale); // ~36px
  Inc(CurY, chkLembrar.Height + Round(14 * Scale));

  // 13. Botão ENTRAR NO SISTEMA
  btnLogin.Left := Pad;
  btnLogin.Top := CurY;
  btnLogin.Width := InnerW;
  btnLogin.Height := Round(58 * Scale); // ~174px (Botão de destaque Touch)
  btnLogin.Font.Height := -Round(16 * Scale); // ~48px
  btnLogin.Font.Style := [fsBold];
  Inc(CurY, btnLogin.Height + Round(10 * Scale));

  // 14. Mensagem de Feedback
  lblMensagem.Left := Pad;
  lblMensagem.Top := CurY;
  lblMensagem.Width := InnerW;
  lblMensagem.Height := Round(30 * Scale);
  lblMensagem.Font.Height := -Round(13 * Scale); // ~39px
  Inc(CurY, lblMensagem.Height + Round(12 * Scale));

  // 15. Card de Sincronismo Offline
  pnlSyncInfo.Left := Pad;
  pnlSyncInfo.Top := CurY;
  pnlSyncInfo.Width := InnerW;
  pnlSyncInfo.Height := Round(80 * Scale);

  lblSyncTitle.Left := Round(12 * Scale);
  lblSyncTitle.Top := Round(10 * Scale);
  lblSyncTitle.Width := pnlSyncInfo.ClientWidth - Round(24 * Scale);
  lblSyncTitle.Height := Round(26 * Scale);
  lblSyncTitle.Font.Height := -Round(11 * Scale); // ~33px
  lblSyncTitle.Font.Style := [fsBold];

  lblSyncDesc.Left := Round(12 * Scale);
  lblSyncDesc.Top := lblSyncTitle.Top + lblSyncTitle.Height + Round(4 * Scale);
  lblSyncDesc.Width := pnlSyncInfo.ClientWidth - Round(24 * Scale);
  lblSyncDesc.Height := Round(40 * Scale);
  lblSyncDesc.Font.Height := -Round(11 * Scale); // ~33px
end;

procedure TFormLogin.FormShow(Sender: TObject);
begin
  FormResize(Sender);
end;

procedure TFormLogin.FormCreate(Sender: TObject);
begin
  FLoginEfetuado := False;
  edtEmpresa.Text := 'EMP-4029';
  edtUsuario.Text := 'carlos';
  edtSenha.Text := '123';
  lblMensagem.Caption := '';

  // Conectar e inicializar banco de dados SQLite (cria caso não exista e popula)
  try
    SalesDB.ConnectAndInitialize;
    SalesStore.CarregarDadosDoBanco;
  except
    on E: Exception do ;
  end;

  AtualizarStatusBanco;
  FormResize(Sender);
end;

procedure TFormLogin.btnLoginClick(Sender: TObject);
var
  Sucesso: Boolean;
begin
  // Autenticação direta no banco SQLite integrado
  Sucesso := SalesStore.Login(edtUsuario.Text, edtSenha.Text);
  if Sucesso then
  begin
    FLoginEfetuado := True;
    lblMensagem.Font.Color := TColor($004A6C00); // Verde Esmeralda
    lblMensagem.Caption := 'Autenticado no SQLite! Bem-vindo, ' + SalesStore.CurrentSeller.Nome + '!';
    AtualizarStatusBanco;
    if Assigned(frmVendas) then
    begin
      frmVendas.Show;
      frmVendas.BringToFront;
      frmVendas.Invalidate;
      Self.Hide;
    end;
  end
  else
  begin
    FLoginEfetuado := False;
    lblMensagem.Font.Color := clRed;
    lblMensagem.Caption := 'Usuario ou senha invalidos no banco SQLite.';
  end;
end;

end.
