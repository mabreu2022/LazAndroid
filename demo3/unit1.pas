unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls;

type
  TCliente = record
    Id: Integer;
    Nome: string;
    CpfCnpj: string;
    Telefone: string;
    Cidade: string;
    LimiteCredito: Double;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    pgcClientes: TPageControl;
    tabLista: TTabSheet;
    tabCadastro: TTabSheet;
    tabEstatisticas: TTabSheet;

    // Header
    pnlHeader: TPanel;
    lblHeaderTitulo: TLabel;
    lblHeaderSub: TLabel;

    // Aba 1 - Lista
    pnlCardCliente: TPanel;
    lblCardNome: TLabel;
    lblCardDoc: TLabel;
    lblCardTel: TLabel;
    lblCardCidade: TLabel;
    lblCardLimite: TLabel;
    lblCardIndice: TLabel;
    btnAnterior: TButton;
    btnProximo: TButton;
    btnNovo: TButton;
    btnEditar: TButton;
    btnExcluir: TButton;

    // Aba 2 - Cadastro / Edição
    lblTituloForm: TLabel;
    lblNome: TLabel;
    edtNome: TEdit;
    lblCpf: TLabel;
    edtCpf: TEdit;
    lblTelefone: TLabel;
    edtTelefone: TEdit;
    lblCidade: TLabel;
    edtCidade: TEdit;
    lblLimite: TLabel;
    edtLimite: TEdit;
    btnSalvar: TButton;
    btnCancelar: TButton;

    // Aba 3 - Estatísticas
    lblStatTitulo: TLabel;
    pnlStat1: TPanel;
    lblTotalCount: TLabel;
    pnlStat2: TPanel;
    lblTotalVolume: TLabel;
    pnlStat3: TPanel;
    lblMediaVolume: TLabel;
    btnRestaurar: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnAnteriorClick(Sender: TObject);
    procedure btnProximoClick(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnEditarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnRestaurarClick(Sender: TObject);
    procedure pgcClientesChange(Sender: TObject);
  private
    FLista: array of TCliente;
    FIndiceAtual: Integer;
    FEditandoId: Integer;
    FProximoId: Integer;

    procedure InicializarDadosMock;
    procedure AtualizarVisualizacaoCliente;
    procedure AtualizarEstatisticas;
    procedure LimparCamposCadastro;
  public

  end;

var
  Form1: TForm1;

function __android_log_write(prio: Integer; tag: PChar; text: PChar): Integer; cdecl; external 'liblog.so' name '__android_log_write';

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  __android_log_write(4, 'lclapp', 'TForm1.FormCreate demo3 iniciado');
  FProximoId := 1;
  FIndiceAtual := 0;
  FEditandoId := 0;

  InicializarDadosMock;
  AtualizarVisualizacaoCliente;
  AtualizarEstatisticas;

  pgcClientes.ActivePage := tabLista;
  pgcClientes.TabIndex := 0;
  FormResize(Self);
  __android_log_write(4, 'lclapp', PChar(Format('TForm1.FormCreate demo3 finalizado: ActivePage=%s TabIndex=%d Count=%d',
    [pgcClientes.ActivePage.Caption, pgcClientes.TabIndex, pgcClientes.PageCount])));
end;

procedure TForm1.InicializarDadosMock;
begin
  SetLength(FLista, 3);

  FLista[0].Id := 1;
  FLista[0].Nome := 'Carlos Eduardo Souza';
  FLista[0].CpfCnpj := '123.456.789-01';
  FLista[0].Telefone := '(11) 98765-4321';
  FLista[0].Cidade := 'Sao Paulo - SP';
  FLista[0].LimiteCredito := 15000.00;

  FLista[1].Id := 2;
  FLista[1].Nome := 'Mariana Dias Oliveira';
  FLista[1].CpfCnpj := '987.654.321-99';
  FLista[1].Telefone := '(21) 99123-5566';
  FLista[1].Cidade := 'Rio de Janeiro - RJ';
  FLista[1].LimiteCredito := 8500.00;

  FLista[2].Id := 3;
  FLista[2].Nome := 'Distribuidora Alfa Ltda';
  FLista[2].CpfCnpj := '12.345.678/0001-90';
  FLista[2].Telefone := '(31) 3344-8899';
  FLista[2].Cidade := 'Belo Horizonte - MG';
  FLista[2].LimiteCredito := 45000.00;

  FProximoId := 4;
  FIndiceAtual := 0;
end;

procedure TForm1.AtualizarVisualizacaoCliente;
var
  Total: Integer;
begin
  Total := Length(FLista);
  if Total = 0 then
  begin
    lblCardNome.Caption := '(Nenhum cliente cadastrado)';
    lblCardDoc.Caption := 'CPF/CNPJ: -';
    lblCardTel.Caption := 'Telefone: -';
    lblCardCidade.Caption := 'Cidade: -';
    lblCardLimite.Caption := 'Limite: R$ 0,00';
    lblCardIndice.Caption := 'Registro 0 de 0';
    btnEditar.Enabled := False;
    btnExcluir.Enabled := False;
    btnAnterior.Enabled := False;
    btnProximo.Enabled := False;
    Exit;
  end;

  if FIndiceAtual < 0 then FIndiceAtual := 0;
  if FIndiceAtual >= Total then FIndiceAtual := Total - 1;

  lblCardNome.Caption := FLista[FIndiceAtual].Nome;
  lblCardDoc.Caption := 'Documento: ' + FLista[FIndiceAtual].CpfCnpj;
  lblCardTel.Caption := 'WhatsApp: ' + FLista[FIndiceAtual].Telefone;
  lblCardCidade.Caption := 'Cidade: ' + FLista[FIndiceAtual].Cidade;
  lblCardLimite.Caption := Format('Limite: R$ %.2f', [FLista[FIndiceAtual].LimiteCredito]);
  lblCardIndice.Caption := Format('Cliente %d de %d (ID #%d)', [FIndiceAtual + 1, Total, FLista[FIndiceAtual].Id]);

  btnEditar.Enabled := True;
  btnExcluir.Enabled := True;
  btnAnterior.Enabled := (FIndiceAtual > 0);
  btnProximo.Enabled := (FIndiceAtual < Total - 1);
end;

procedure TForm1.AtualizarEstatisticas;
var
  i, Total: Integer;
  Soma: Double;
begin
  Total := Length(FLista);
  Soma := 0.0;
  for i := 0 to Total - 1 do
    Soma := Soma + FLista[i].LimiteCredito;

  lblTotalCount.Caption := Format('● Total de Clientes: %d cadastrados', [Total]);
  lblTotalVolume.Caption := Format('● Volume Total de Credito: R$ %.2f', [Soma]);
  if Total > 0 then
    lblMediaVolume.Caption := Format('● Media por Cliente: R$ %.2f', [Soma / Total])
  else
    lblMediaVolume.Caption := '● Media por Cliente: R$ 0,00';
end;

procedure TForm1.LimparCamposCadastro;
begin
  edtNome.Text := '';
  edtCpf.Text := '';
  edtTelefone.Text := '';
  edtCidade.Text := '';
  edtLimite.Text := '1000.00';
end;

procedure TForm1.FormResize(Sender: TObject);
var
  W, H, Pad, InnerW, HalfW, CurY: Integer;
begin
  W := ClientWidth;
  H := ClientHeight;
  if (Screen.Width > 0) and (Screen.Width > W) then
  begin
    W := Screen.Width;
    H := Screen.Height;
  end;
  __android_log_write(4, 'lclapp', PChar(Format('TForm1.FormResize chamado: W=%d H=%d ScreenW=%d ScreenH=%d',
    [W, H, Screen.Width, Screen.Height])));
  if W < 100 then Exit;

  Pad := 30;
  InnerW := W - (2 * Pad);

  // 1. Header Superior
  pnlHeader.Left := 0;
  pnlHeader.Top := 0;
  pnlHeader.Width := W;
  pnlHeader.Height := 140;

  lblHeaderTitulo.Left := Pad;
  lblHeaderTitulo.Top := 24;
  lblHeaderTitulo.Width := InnerW;
  lblHeaderTitulo.Height := 45;

  lblHeaderSub.Left := Pad;
  lblHeaderSub.Top := 75;
  lblHeaderSub.Width := InnerW;
  lblHeaderSub.Height := 35;

  // 2. PageControl preenchendo o restante
  pgcClientes.Left := 0;
  pgcClientes.Top := pnlHeader.Height;
  pgcClientes.Width := W;
  pgcClientes.Height := H - pnlHeader.Height;

  // Sincronizar tamanho das páginas com a tela cheia
  tabLista.Left := 0;
  tabLista.Top := 0;
  tabLista.Width := W;
  tabLista.Height := pgcClientes.Height;

  tabCadastro.Left := 0;
  tabCadastro.Top := 0;
  tabCadastro.Width := W;
  tabCadastro.Height := pgcClientes.Height;

  tabEstatisticas.Left := 0;
  tabEstatisticas.Top := 0;
  tabEstatisticas.Width := W;
  tabEstatisticas.Height := pgcClientes.Height;

  // --- Layout da Aba 1 (Lista) ---
  pnlCardCliente.Left := Pad;
  pnlCardCliente.Top := 30;
  pnlCardCliente.Width := InnerW;
  pnlCardCliente.Height := 420;

  CurY := 20;
  lblCardNome.Left := 25;
  lblCardNome.Top := CurY;
  lblCardNome.Width := pnlCardCliente.Width - 50;
  lblCardNome.Height := 45;
  Inc(CurY, 55);

  lblCardDoc.Left := 25;
  lblCardDoc.Top := CurY;
  lblCardDoc.Width := pnlCardCliente.Width - 50;
  lblCardDoc.Height := 35;
  Inc(CurY, 45);

  lblCardTel.Left := 25;
  lblCardTel.Top := CurY;
  lblCardTel.Width := pnlCardCliente.Width - 50;
  lblCardTel.Height := 35;
  Inc(CurY, 45);

  lblCardCidade.Left := 25;
  lblCardCidade.Top := CurY;
  lblCardCidade.Width := pnlCardCliente.Width - 50;
  lblCardCidade.Height := 35;
  Inc(CurY, 45);

  lblCardLimite.Left := 25;
  lblCardLimite.Top := CurY;
  lblCardLimite.Width := pnlCardCliente.Width - 50;
  lblCardLimite.Height := 35;
  Inc(CurY, 45);

  lblCardIndice.Left := 25;
  lblCardIndice.Top := CurY;
  lblCardIndice.Width := pnlCardCliente.Width - 50;
  lblCardIndice.Height := 35;

  // Botões de Navegação (Anterior / Próximo)
  HalfW := (InnerW - 20) div 2;
  btnAnterior.Left := Pad;
  btnAnterior.Top := pnlCardCliente.Top + pnlCardCliente.Height + 25;
  btnAnterior.Width := HalfW;
  btnAnterior.Height := 90;

  btnProximo.Left := Pad + HalfW + 20;
  btnProximo.Top := btnAnterior.Top;
  btnProximo.Width := HalfW;
  btnProximo.Height := 90;

  // Botões de Ação
  btnNovo.Left := Pad;
  btnNovo.Top := btnAnterior.Top + btnAnterior.Height + 25;
  btnNovo.Width := InnerW;
  btnNovo.Height := 105;

  btnEditar.Left := Pad;
  btnEditar.Top := btnNovo.Top + btnNovo.Height + 20;
  btnEditar.Width := HalfW;
  btnEditar.Height := 95;

  btnExcluir.Left := Pad + HalfW + 20;
  btnExcluir.Top := btnEditar.Top;
  btnExcluir.Width := HalfW;
  btnExcluir.Height := 95;

  // --- Layout da Aba 2 (Cadastro) ---
  lblTituloForm.Left := Pad;
  lblTituloForm.Top := 20;
  lblTituloForm.Width := InnerW;
  lblTituloForm.Height := 45;

  CurY := 75;

  lblNome.Left := Pad;
  lblNome.Top := CurY;
  lblNome.Width := InnerW;
  lblNome.Height := 32;
  Inc(CurY, 36);

  edtNome.Left := Pad;
  edtNome.Top := CurY;
  edtNome.Width := InnerW;
  edtNome.Height := 80;
  Inc(CurY, 95);

  lblCpf.Left := Pad;
  lblCpf.Top := CurY;
  lblCpf.Width := InnerW;
  lblCpf.Height := 32;
  Inc(CurY, 36);

  edtCpf.Left := Pad;
  edtCpf.Top := CurY;
  edtCpf.Width := InnerW;
  edtCpf.Height := 80;
  Inc(CurY, 95);

  lblTelefone.Left := Pad;
  lblTelefone.Top := CurY;
  lblTelefone.Width := InnerW;
  lblTelefone.Height := 32;
  Inc(CurY, 36);

  edtTelefone.Left := Pad;
  edtTelefone.Top := CurY;
  edtTelefone.Width := InnerW;
  edtTelefone.Height := 80;
  Inc(CurY, 95);

  lblCidade.Left := Pad;
  lblCidade.Top := CurY;
  lblCidade.Width := InnerW;
  lblCidade.Height := 32;
  Inc(CurY, 36);

  edtCidade.Left := Pad;
  edtCidade.Top := CurY;
  edtCidade.Width := InnerW;
  edtCidade.Height := 80;
  Inc(CurY, 95);

  lblLimite.Left := Pad;
  lblLimite.Top := CurY;
  lblLimite.Width := InnerW;
  lblLimite.Height := 32;
  Inc(CurY, 36);

  edtLimite.Left := Pad;
  edtLimite.Top := CurY;
  edtLimite.Width := InnerW;
  edtLimite.Height := 80;
  Inc(CurY, 110);

  btnSalvar.Left := Pad;
  btnSalvar.Top := CurY;
  btnSalvar.Width := InnerW;
  btnSalvar.Height := 105;
  Inc(CurY, 120);

  btnCancelar.Left := Pad;
  btnCancelar.Top := CurY;
  btnCancelar.Width := InnerW;
  btnCancelar.Height := 85;

  // --- Layout da Aba 3 (Estatísticas) ---
  lblStatTitulo.Left := Pad;
  lblStatTitulo.Top := 30;
  lblStatTitulo.Width := InnerW;
  lblStatTitulo.Height := 50;

  pnlStat1.Left := Pad;
  pnlStat1.Top := 100;
  pnlStat1.Width := InnerW;
  pnlStat1.Height := 100;

  lblTotalCount.Left := 20;
  lblTotalCount.Top := 30;
  lblTotalCount.Width := pnlStat1.Width - 40;
  lblTotalCount.Height := 40;

  pnlStat2.Left := Pad;
  pnlStat2.Top := 220;
  pnlStat2.Width := InnerW;
  pnlStat2.Height := 100;

  lblTotalVolume.Left := 20;
  lblTotalVolume.Top := 30;
  lblTotalVolume.Width := pnlStat2.Width - 40;
  lblTotalVolume.Height := 40;

  pnlStat3.Left := Pad;
  pnlStat3.Top := 340;
  pnlStat3.Width := InnerW;
  pnlStat3.Height := 100;

  lblMediaVolume.Left := 20;
  lblMediaVolume.Top := 30;
  lblMediaVolume.Width := pnlStat3.Width - 40;
  lblMediaVolume.Height := 40;

  btnRestaurar.Left := Pad;
  btnRestaurar.Top := 480;
  btnRestaurar.Width := InnerW;
  btnRestaurar.Height := 100;

  __android_log_write(4, 'lclapp', PChar(Format('FormResize fim: tabLista W=%d H=%d Vis=%d | pnlCard L=%d T=%d W=%d H=%d Vis=%d | btnNovo L=%d T=%d W=%d H=%d Vis=%d',
    [tabLista.Width, tabLista.Height, Ord(tabLista.Visible),
     pnlCardCliente.Left, pnlCardCliente.Top, pnlCardCliente.Width, pnlCardCliente.Height, Ord(pnlCardCliente.Visible),
     btnNovo.Left, btnNovo.Top, btnNovo.Width, btnNovo.Height, Ord(btnNovo.Visible)])));
end;

procedure TForm1.btnAnteriorClick(Sender: TObject);
begin
  if FIndiceAtual > 0 then
  begin
    Dec(FIndiceAtual);
    AtualizarVisualizacaoCliente;
  end;
end;

procedure TForm1.btnProximoClick(Sender: TObject);
begin
  if FIndiceAtual < Length(FLista) - 1 then
  begin
    Inc(FIndiceAtual);
    AtualizarVisualizacaoCliente;
  end;
end;

procedure TForm1.btnNovoClick(Sender: TObject);
begin
  FEditandoId := 0;
  LimparCamposCadastro;
  lblTituloForm.Caption := '+ NOVO CLIENTE';
  pgcClientes.ActivePage := tabCadastro;
  tabCadastro.BringToFront;
  FormResize(Self);
end;

procedure TForm1.btnEditarClick(Sender: TObject);
begin
  if (FIndiceAtual < 0) or (FIndiceAtual >= Length(FLista)) then Exit;

  FEditandoId := FLista[FIndiceAtual].Id;
  lblTituloForm.Caption := Format('EDITANDO CLIENTE #%d', [FEditandoId]);
  edtNome.Text := FLista[FIndiceAtual].Nome;
  edtCpf.Text := FLista[FIndiceAtual].CpfCnpj;
  edtTelefone.Text := FLista[FIndiceAtual].Telefone;
  edtCidade.Text := FLista[FIndiceAtual].Cidade;
  edtLimite.Text := FormatFloat('0.00', FLista[FIndiceAtual].LimiteCredito);

  pgcClientes.ActivePage := tabCadastro;
  tabCadastro.BringToFront;
  FormResize(Self);
end;

procedure TForm1.btnExcluirClick(Sender: TObject);
var
  i, Len: Integer;
  NomeExcluido: string;
begin
  if (FIndiceAtual < 0) or (FIndiceAtual >= Length(FLista)) then Exit;

  NomeExcluido := FLista[FIndiceAtual].Nome;
  Len := Length(FLista);

  for i := FIndiceAtual to Len - 2 do
    FLista[i] := FLista[i + 1];

  SetLength(FLista, Len - 1);

  if FIndiceAtual >= Length(FLista) then
    FIndiceAtual := Length(FLista) - 1;

  AtualizarVisualizacaoCliente;
  AtualizarEstatisticas;

  ShowMessage('Cliente "' + NomeExcluido + '" excluido com sucesso!');
end;

procedure TForm1.btnSalvarClick(Sender: TObject);
var
  NovoIdx: Integer;
  LimVal: Double;
begin
  if Trim(edtNome.Text) = '' then
  begin
    ShowMessage('Por favor, informe o Nome do cliente.');
    Exit;
  end;

  LimVal := StrToFloatDef(Trim(edtLimite.Text), 0.0);

  if FEditandoId = 0 then
  begin
    // Inserção
    NovoIdx := Length(FLista);
    SetLength(FLista, NovoIdx + 1);

    FLista[NovoIdx].Id := FProximoId;
    Inc(FProximoId);
    FLista[NovoIdx].Nome := Trim(edtNome.Text);
    FLista[NovoIdx].CpfCnpj := Trim(edtCpf.Text);
    FLista[NovoIdx].Telefone := Trim(edtTelefone.Text);
    FLista[NovoIdx].Cidade := Trim(edtCidade.Text);
    FLista[NovoIdx].LimiteCredito := LimVal;

    FIndiceAtual := NovoIdx;
    ShowMessage('Cliente "' + FLista[NovoIdx].Nome + '" cadastrado com sucesso!');
  end
  else
  begin
    // Atualização
    if (FIndiceAtual >= 0) and (FIndiceAtual < Length(FLista)) then
    begin
      FLista[FIndiceAtual].Nome := Trim(edtNome.Text);
      FLista[FIndiceAtual].CpfCnpj := Trim(edtCpf.Text);
      FLista[FIndiceAtual].Telefone := Trim(edtTelefone.Text);
      FLista[FIndiceAtual].Cidade := Trim(edtCidade.Text);
      FLista[FIndiceAtual].LimiteCredito := LimVal;
      ShowMessage('Cliente atualizado com sucesso!');
    end;
  end;

  AtualizarVisualizacaoCliente;
  AtualizarEstatisticas;
  pgcClientes.ActivePage := tabLista;
  tabLista.BringToFront;
  FormResize(Self);
end;

procedure TForm1.btnCancelarClick(Sender: TObject);
begin
  pgcClientes.ActivePage := tabLista;
  tabLista.BringToFront;
  FormResize(Self);
end;

procedure TForm1.btnRestaurarClick(Sender: TObject);
begin
  InicializarDadosMock;
  AtualizarVisualizacaoCliente;
  AtualizarEstatisticas;
  ShowMessage('Base de dados de exemplo restaurada!');
  pgcClientes.ActivePage := tabLista;
  tabLista.BringToFront;
  FormResize(Self);
end;

procedure TForm1.pgcClientesChange(Sender: TObject);
begin
  if pgcClientes.ActivePage = tabEstatisticas then
  begin
    AtualizarEstatisticas;
    tabEstatisticas.BringToFront;
  end
  else if pgcClientes.ActivePage = tabCadastro then
    tabCadastro.BringToFront
  else
    tabLista.BringToFront;

  FormResize(Self);
end;

end.
