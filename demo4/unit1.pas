unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  LazDroidMobileControls;

type
  { TForm1 }
  TForm1 = class(TForm)
    appBar: TLazDroidAppBar;
    bottomNav: TLazDroidBottomNav;
    cardMetrics: TLazDroidCard;
    badgeStatus: TLazDroidBadge;
    lblMeta: TLabel;
    lblTotalVendido: TLabel;
    lblSubMeta: TLabel;
    edtBusca: TLazDroidEdit;
    btnNovoPedido: TLazDroidButton;
    btnSincronizar: TLazDroidButton;
    listVendas: TLazDroidListView;

    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure appBarActionClick(Sender: TObject);
    procedure appBarBackClick(Sender: TObject);
    procedure bottomNavTabSelected(Sender: TObject; AIndex: Integer);
    procedure btnNovoPedidoClick(Sender: TObject);
    procedure btnSincronizarClick(Sender: TObject);
    procedure listVendasItemClick(Sender: TObject; AIndex: Integer);
    procedure edtBuscaChange(Sender: TObject);
  private
    FTotalVendas: Double;
    procedure AtualizarMetricas;
    procedure CarregarDadosExemplo;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  CarregarDadosExemplo;
  AtualizarMetricas;
  FormResize(Self);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  // Layout responsivo móvel proporcional
  if Assigned(cardMetrics) then
  begin
    cardMetrics.Left := 16;
    cardMetrics.Top := appBar.Height + 12;
    cardMetrics.Width := ClientWidth - 32;
    cardMetrics.Height := 92;
  end;

  if Assigned(edtBusca) then
  begin
    edtBusca.Left := 16;
    edtBusca.Top := cardMetrics.Top + cardMetrics.Height + 12;
    edtBusca.Width := ClientWidth - 32;
    edtBusca.Height := 48;
  end;

  if Assigned(btnNovoPedido) and Assigned(btnSincronizar) then
  begin
    btnNovoPedido.Left := 16;
    btnNovoPedido.Top := edtBusca.Top + edtBusca.Height + 10;
    btnNovoPedido.Width := (ClientWidth - 40) div 2;
    btnNovoPedido.Height := 46;

    btnSincronizar.Left := btnNovoPedido.Left + btnNovoPedido.Width + 8;
    btnSincronizar.Top := btnNovoPedido.Top;
    btnSincronizar.Width := btnNovoPedido.Width;
    btnSincronizar.Height := 46;
  end;

  if Assigned(listVendas) then
  begin
    listVendas.Left := 16;
    listVendas.Top := btnNovoPedido.Top + btnNovoPedido.Height + 12;
    listVendas.Width := ClientWidth - 32;
    listVendas.Height := ClientHeight - listVendas.Top - bottomNav.Height - 12;
    if listVendas.Height < 100 then listVendas.Height := 100;
  end;
end;

procedure TForm1.CarregarDadosExemplo;
var
  Item: TLazDroidListItem;
begin
  listVendas.Items.Clear;

  Item := listVendas.Items.Add;
  Item.Title := 'Distribuidora São Paulo Ltda';
  Item.Subtitle := 'Pedido #1042 • 12 itens • Faturado';
  Item.Value := 'R$ 4.850,00';

  Item := listVendas.Items.Add;
  Item.Title := 'Supermercado Central';
  Item.Subtitle := 'Pedido #1043 • 34 itens • Em Rota';
  Item.Value := 'R$ 12.390,00';

  Item := listVendas.Items.Add;
  Item.Title := 'Auto Peças Progresso';
  Item.Subtitle := 'Pedido #1044 • 5 itens • Pendente';
  Item.Value := 'R$ 1.980,50';

  Item := listVendas.Items.Add;
  Item.Title := 'Farmácia Saúde Total';
  Item.Subtitle := 'Pedido #1045 • 8 itens • Aprovado';
  Item.Value := 'R$ 3.420,00';

  Item := listVendas.Items.Add;
  Item.Title := 'Padaria & Confeitaria Estrela';
  Item.Subtitle := 'Pedido #1046 • 15 itens • Faturado';
  Item.Value := 'R$ 890,00';

  FTotalVendas := 23530.50;
end;

procedure TForm1.AtualizarMetricas;
begin
  lblTotalVendido.Caption := Format('R$ %.2f', [FTotalVendas]);
  lblSubMeta := lblSubMeta; // Mantém
end;

procedure TForm1.appBarActionClick(Sender: TObject);
begin
  ShowMessage('Menu de Opções LazDroid acionado!');
end;

procedure TForm1.appBarBackClick(Sender: TObject);
begin
  ShowMessage('Navegação Voltar acionada.');
end;

procedure TForm1.bottomNavTabSelected(Sender: TObject; AIndex: Integer);
begin
  case AIndex of
    0: appBar.Title := 'VendaForce Mobile - Painel';
    1: appBar.Title := 'Pedidos & Vendas';
    2: appBar.Title := 'Carteira de Clientes';
    3: appBar.Title := 'Configurações do App';
  end;
end;

procedure TForm1.btnNovoPedidoClick(Sender: TObject);
var
  Item: TLazDroidListItem;
begin
  Item := listVendas.Items.Add;
  Item.Title := 'Novo Cliente ' + FormatDateTime('hh:nn:ss', Now);
  Item.Subtitle := 'Pedido Rápido Mobile • Pendente';
  Item.Value := 'R$ 750,00';
  FTotalVendas := FTotalVendas + 750.00;
  AtualizarMetricas;
  listVendas.Invalidate;
  ShowMessage('Novo pedido criado com sucesso na lista mobile!');
end;

procedure TForm1.btnSincronizarClick(Sender: TObject);
begin
  badgeStatus.Caption := 'Sincronizado';
  badgeStatus.Style := bsSuccess;
  ShowMessage('Dados sincronizados com o servidor em nuvem com sucesso!');
end;

procedure TForm1.listVendasItemClick(Sender: TObject; AIndex: Integer);
var
  Item: TLazDroidListItem;
begin
  if (AIndex >= 0) and (AIndex < listVendas.Items.Count) then
  begin
    Item := listVendas.Items[AIndex];
    ShowMessage(Format('Pedido Selecionado:' + LineEnding +
                       'Cliente: %s' + LineEnding +
                       'Detalhes: %s' + LineEnding +
                       'Valor: %s', [Item.Title, Item.Subtitle, Item.Value]));
  end;
end;

procedure TForm1.edtBuscaChange(Sender: TObject);
begin
  // Filtro interativo de busca com teclado
end;

end.
