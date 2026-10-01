unit FormVendas;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, SalesData, SalesDatabase;

type
  { TFormVendas }

  TFormVendas = class(TForm)
    pnlHeader: TPanel;
    lblAppTitle: TLabel;
    lblVendedor: TLabel;
    lblSyncPill: TLabel;
    pnlMetaCard: TPanel;
    lblMetaTitulo: TLabel;
    lblMetaValores: TLabel;
    lblMetaPercent: TLabel;
    pbMeta: TProgressBar;
    lblTicketMedio: TLabel;
    lblComissao: TLabel;
    pnlMetricasGrid: TPanel;
    lblVendasHoje: TLabel;
    lblPedidosEmitidos: TLabel;
    lblVisitasHoje: TLabel;
    lblPositivacao: TLabel;
    pnlClientes: TPanel;
    lblRoteiroTitulo: TLabel;
    btnCliente1: TButton;
    btnCliente2: TButton;
    btnCliente3: TButton;
    btnCliente4: TButton;
    pnlAcoes: TPanel;
    btnNovoPedido: TButton;
    btnCarrinho: TButton;
    btnSincronizar: TButton;
    lblStatus: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCliente1Click(Sender: TObject);
    procedure btnCliente2Click(Sender: TObject);
    procedure btnCliente3Click(Sender: TObject);
    procedure btnCliente4Click(Sender: TObject);
    procedure btnNovoPedidoClick(Sender: TObject);
    procedure btnCarrinhoClick(Sender: TObject);
    procedure btnSincronizarClick(Sender: TObject);
  private
    procedure AtualizarDados;
  public
  end;

var
  frmVendas: TFormVendas;

implementation

{$R *.lfm}

{ TFormVendas }

procedure TFormVendas.FormResize(Sender: TObject);
var
  Scale: Double;
  TargetW, TargetH: Integer;
  Margin, CtlW, Pad, InnerW, ColW, BtnH: Integer;
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

  Margin := Round(12 * Scale);
  CtlW := TargetW - (2 * Margin);

  // 1. Cabeçalho Superior
  pnlHeader.Left := 0;
  pnlHeader.Top := 0;
  pnlHeader.Width := TargetW;
  pnlHeader.Height := Round(88 * Scale);

  lblAppTitle.Left := Round(14 * Scale);
  lblAppTitle.Top := Round(8 * Scale);
  lblAppTitle.Height := Round(28 * Scale);
  lblAppTitle.Font.Height := -Round(20 * Scale);
  lblAppTitle.Font.Style := [fsBold];

  lblSyncPill.Top := Round(10 * Scale);
  lblSyncPill.Width := Round(150 * Scale);
  lblSyncPill.Left := pnlHeader.ClientWidth - Round(164 * Scale);
  lblSyncPill.Height := Round(22 * Scale);
  lblSyncPill.Font.Height := -Round(11 * Scale);
  lblSyncPill.Font.Style := [fsBold];

  lblVendedor.Left := Round(14 * Scale);
  lblVendedor.Top := lblAppTitle.Top + lblAppTitle.Height + Round(4 * Scale);
  lblVendedor.Width := pnlHeader.ClientWidth - Round(28 * Scale);
  lblVendedor.Height := Round(22 * Scale);
  lblVendedor.Font.Height := -Round(11 * Scale);

  lblStatus.Left := Round(14 * Scale);
  lblStatus.Top := lblVendedor.Top + lblVendedor.Height + Round(2 * Scale);
  lblStatus.Width := pnlHeader.ClientWidth - Round(28 * Scale);
  lblStatus.Height := Round(22 * Scale);
  lblStatus.Font.Height := -Round(11 * Scale);
  lblStatus.Font.Style := [fsBold];

  // 2. Card de Meta Mensal
  pnlMetaCard.Left := Margin;
  pnlMetaCard.Top := pnlHeader.Height + Round(10 * Scale);
  pnlMetaCard.Width := CtlW;
  pnlMetaCard.Height := Round(122 * Scale);

  Pad := Round(12 * Scale);
  InnerW := pnlMetaCard.ClientWidth - (2 * Pad);

  lblMetaTitulo.Left := Pad;
  lblMetaTitulo.Top := Round(8 * Scale);
  lblMetaTitulo.Width := InnerW;
  lblMetaTitulo.Height := Round(20 * Scale);
  lblMetaTitulo.Font.Height := -Round(11 * Scale);
  lblMetaTitulo.Font.Style := [fsBold];

  lblMetaValores.Left := Pad;
  lblMetaValores.Top := lblMetaTitulo.Top + lblMetaTitulo.Height + Round(2 * Scale);
  lblMetaValores.Width := Round(InnerW * 0.70);
  lblMetaValores.Height := Round(30 * Scale);
  lblMetaValores.Font.Height := -Round(15 * Scale);
  lblMetaValores.Font.Style := [fsBold];

  lblMetaPercent.Top := lblMetaValores.Top;
  lblMetaPercent.Width := Round(InnerW * 0.28);
  lblMetaPercent.Left := pnlMetaCard.ClientWidth - Pad - lblMetaPercent.Width;
  lblMetaPercent.Height := Round(30 * Scale);
  lblMetaPercent.Font.Height := -Round(16 * Scale);
  lblMetaPercent.Font.Style := [fsBold];
  lblMetaPercent.Alignment := taRightJustify;
  lblMetaPercent.Font.Style := [fsBold];

  pbMeta.Left := Pad;
  pbMeta.Top := lblMetaValores.Top + lblMetaValores.Height + Round(6 * Scale);
  pbMeta.Width := InnerW;
  pbMeta.Height := Round(14 * Scale);

  lblTicketMedio.Left := Pad;
  lblTicketMedio.Top := pbMeta.Top + pbMeta.Height + Round(8 * Scale);
  lblTicketMedio.Width := Round(InnerW * 0.50);
  lblTicketMedio.Height := Round(22 * Scale);
  lblTicketMedio.Font.Height := -Round(11 * Scale);

  lblComissao.Top := lblTicketMedio.Top;
  lblComissao.Width := Round(InnerW * 0.50);
  lblComissao.Left := pnlMetaCard.ClientWidth - Pad - lblComissao.Width;
  lblComissao.Height := Round(22 * Scale);
  lblComissao.Font.Height := -Round(11 * Scale);
  lblComissao.Font.Style := [fsBold];

  // 3. Grid de Métricas
  pnlMetricasGrid.Left := Margin;
  pnlMetricasGrid.Top := pnlMetaCard.Top + pnlMetaCard.Height + Round(8 * Scale);
  pnlMetricasGrid.Width := CtlW;
  pnlMetricasGrid.Height := Round(76 * Scale);

  Pad := Round(10 * Scale);
  InnerW := pnlMetricasGrid.ClientWidth - (2 * Pad);
  ColW := (InnerW - Round(8 * Scale)) div 2;

  lblVendasHoje.Left := Pad;
  lblVendasHoje.Top := Round(8 * Scale);
  lblVendasHoje.Width := ColW;
  lblVendasHoje.Height := Round(26 * Scale);
  lblVendasHoje.Font.Height := -Round(12 * Scale);
  lblVendasHoje.Font.Style := [fsBold];

  lblPedidosEmitidos.Left := Pad + ColW + Round(8 * Scale);
  lblPedidosEmitidos.Top := lblVendasHoje.Top;
  lblPedidosEmitidos.Width := ColW;
  lblPedidosEmitidos.Height := Round(26 * Scale);
  lblPedidosEmitidos.Font.Height := -Round(12 * Scale);
  lblPedidosEmitidos.Font.Style := [fsBold];

  lblVisitasHoje.Left := Pad;
  lblVisitasHoje.Top := lblVendasHoje.Top + lblVendasHoje.Height + Round(4 * Scale);
  lblVisitasHoje.Width := ColW;
  lblVisitasHoje.Height := Round(26 * Scale);
  lblVisitasHoje.Font.Height := -Round(12 * Scale);

  lblPositivacao.Left := lblPedidosEmitidos.Left;
  lblPositivacao.Top := lblVisitasHoje.Top;
  lblPositivacao.Width := ColW;
  lblPositivacao.Height := Round(26 * Scale);
  lblPositivacao.Font.Height := -Round(12 * Scale);
  lblPositivacao.Font.Style := [fsBold];

  // 4. Roteiro de Clientes
  pnlClientes.Left := Margin;
  pnlClientes.Top := pnlMetricasGrid.Top + pnlMetricasGrid.Height + Round(8 * Scale);
  pnlClientes.Width := CtlW;
  pnlClientes.Height := Round(220 * Scale);

  Pad := Round(10 * Scale);
  InnerW := pnlClientes.ClientWidth - (2 * Pad);

  lblRoteiroTitulo.Left := Pad;
  lblRoteiroTitulo.Top := Round(8 * Scale);
  lblRoteiroTitulo.Width := InnerW;
  lblRoteiroTitulo.Height := Round(22 * Scale);
  lblRoteiroTitulo.Font.Height := -Round(12 * Scale);
  lblRoteiroTitulo.Font.Style := [fsBold];

  BtnH := Round(40 * Scale);

  btnCliente1.Left := Pad;
  btnCliente1.Top := lblRoteiroTitulo.Top + lblRoteiroTitulo.Height + Round(6 * Scale);
  btnCliente1.Width := InnerW;
  btnCliente1.Height := BtnH;
  btnCliente1.Font.Height := -Round(13 * Scale);

  btnCliente2.Left := Pad;
  btnCliente2.Top := btnCliente1.Top + btnCliente1.Height + Round(6 * Scale);
  btnCliente2.Width := InnerW;
  btnCliente2.Height := BtnH;
  btnCliente2.Font.Height := -Round(13 * Scale);

  btnCliente3.Left := Pad;
  btnCliente3.Top := btnCliente2.Top + btnCliente2.Height + Round(6 * Scale);
  btnCliente3.Width := InnerW;
  btnCliente3.Height := BtnH;
  btnCliente3.Font.Height := -Round(13 * Scale);

  btnCliente4.Left := Pad;
  btnCliente4.Top := btnCliente3.Top + btnCliente3.Height + Round(6 * Scale);
  btnCliente4.Width := InnerW;
  btnCliente4.Height := BtnH;
  btnCliente4.Font.Height := -Round(13 * Scale);

  // 5. Botões de Ação
  pnlAcoes.Left := Margin;
  pnlAcoes.Top := pnlClientes.Top + pnlClientes.Height + Round(8 * Scale);
  pnlAcoes.Width := CtlW;
  pnlAcoes.Height := Round(180 * Scale);

  Pad := Round(10 * Scale);
  InnerW := pnlAcoes.ClientWidth - (2 * Pad);
  BtnH := Round(50 * Scale);

  btnNovoPedido.Left := Pad;
  btnNovoPedido.Top := Round(8 * Scale);
  btnNovoPedido.Width := InnerW;
  btnNovoPedido.Height := BtnH;
  btnNovoPedido.Font.Height := -Round(14 * Scale);
  btnNovoPedido.Font.Style := [fsBold];

  btnCarrinho.Left := Pad;
  btnCarrinho.Top := btnNovoPedido.Top + btnNovoPedido.Height + Round(8 * Scale);
  btnCarrinho.Width := InnerW;
  btnCarrinho.Height := BtnH;
  btnCarrinho.Font.Height := -Round(14 * Scale);
  btnCarrinho.Font.Style := [fsBold];

  btnSincronizar.Left := Pad;
  btnSincronizar.Top := btnCarrinho.Top + btnCarrinho.Height + Round(8 * Scale);
  btnSincronizar.Width := InnerW;
  btnSincronizar.Height := BtnH;
  btnSincronizar.Font.Height := -Round(14 * Scale);
  btnSincronizar.Font.Style := [fsBold];
end;

procedure TFormVendas.FormShow(Sender: TObject);
begin
  FormResize(Sender);
end;

procedure TFormVendas.FormCreate(Sender: TObject);
begin
  AtualizarDados;
  FormResize(Sender);
end;

procedure TFormVendas.AtualizarDados;
var
  Pct: Double;
  Cli: TClientRecord;
begin
  // Cabeçalho
  lblVendedor.Caption := Format('Representante: %s (%s) • %s',
    [SalesStore.CurrentSeller.Nome, SalesStore.CurrentSeller.Codigo, SalesStore.CurrentSeller.Rota]);

  // Card de Meta Mensal
  Pct := SalesStore.GetPercentMeta;
  lblMetaValores.Caption := Format('R$ %s / R$ %s',
    [FormatFloat('#,##0.00', SalesStore.GetTotalVendasMes), FormatFloat('#,##0.00', SalesStore.MetaMes)]);
  lblMetaPercent.Caption := Format('%.1f%%', [Pct]);
  pbMeta.Position := Round(Pct);

  // Clientes da Rota
  if SalesStore.ClientCount > 0 then
  begin
    Cli := SalesStore.GetClient(0);
    btnCliente1.Caption := Format('1. %s [R$ %s disp.]', [Cli.Fantasia, FormatFloat('#,##0', Cli.SaldoDisponivel)]);
  end;
  if SalesStore.ClientCount > 1 then
  begin
    Cli := SalesStore.GetClient(1);
    btnCliente2.Caption := Format('2. %s [R$ %s disp.]', [Cli.Fantasia, FormatFloat('#,##0', Cli.SaldoDisponivel)]);
  end;
  if SalesStore.ClientCount > 2 then
  begin
    Cli := SalesStore.GetClient(2);
    btnCliente3.Caption := Format('3. %s [R$ %s disp.]', [Cli.Fantasia, FormatFloat('#,##0', Cli.SaldoDisponivel)]);
  end;
  if SalesStore.ClientCount > 3 then
  begin
    Cli := SalesStore.GetClient(3);
    btnCliente4.Caption := Format('4. %s [R$ %s disp.]', [Cli.Fantasia, FormatFloat('#,##0', Cli.SaldoDisponivel)]);
  end;

  // Carrinho
  btnCarrinho.Caption := Format('CARRINHO (%d ITENS - R$ %s)',
    [SalesStore.CartItemCount, FormatFloat('#,##0.00', SalesStore.GetCartTotal)]);

  // Status de Conexão com SQLite
  if SalesDB.IsConnected then
    lblStatus.Caption := Format('● SQLite Conectado: %s (%d Clientes | %d Produtos | %d Pedidos no Banco)',
      [ExtractFileName(SalesDB.DbPath), SalesStore.ClientCount, SalesStore.ProductCount, SalesStore.OrderCount])
  else
    lblStatus.Caption := '○ SQLite: Modo Fallback (Banco de Dados Offline)';
end;

procedure TFormVendas.btnCliente1Click(Sender: TObject);
begin
  SalesStore.SelectClient(0);
  ShowMessage('Cliente Selecionado: ' + SalesStore.GetClient(0).Fantasia + #13#10 +
              'CNPJ: ' + SalesStore.GetClient(0).Cnpj + #13#10 +
              'Limite Disponível: R$ ' + FormatFloat('#,##0.00', SalesStore.GetClient(0).SaldoDisponivel));
end;

procedure TFormVendas.btnCliente2Click(Sender: TObject);
begin
  SalesStore.SelectClient(1);
  ShowMessage('Cliente Selecionado: ' + SalesStore.GetClient(1).Fantasia);
end;

procedure TFormVendas.btnCliente3Click(Sender: TObject);
begin
  SalesStore.SelectClient(2);
  ShowMessage('Cliente Selecionado: ' + SalesStore.GetClient(2).Fantasia);
end;

procedure TFormVendas.btnCliente4Click(Sender: TObject);
begin
  SalesStore.SelectClient(3);
  ShowMessage('Cliente Selecionado: ' + SalesStore.GetClient(3).Fantasia);
end;

procedure TFormVendas.btnNovoPedidoClick(Sender: TObject);
begin
  ShowMessage('Catálogo de Produtos SQLite: ' + IntToStr(SalesStore.ProductCount) + ' itens disponíveis para venda.');
end;

procedure TFormVendas.btnCarrinhoClick(Sender: TObject);
begin
  ShowMessage('Total do Carrinho: R$ ' + FormatFloat('#,##0.00', SalesStore.GetCartTotal));
end;

procedure TFormVendas.btnSincronizarClick(Sender: TObject);
var
  NewNum: Integer;
begin
  if SalesStore.FinalizeOrder(NewNum) then
  begin
    ShowMessage(Format('Pedido #%d transmitido e registrado com sucesso no banco SQLite!', [NewNum]));
    AtualizarDados;
  end
  else
    ShowMessage('Carrinho vazio! Adicione itens no pedido antes de transmitir.');
end;

end.
