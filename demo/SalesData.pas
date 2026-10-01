{
  LazDroid-Deploy Demo: Camada de Dados de Força de Vendas
  Unit: SalesData.pas
  Descrição: Modelos de dados e repositório central integrados com banco SQLite:
             Clientes, Catálogo de Produtos, Carrinho e Emissão de Pedidos (VendaForce Mobile).
}
unit SalesData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SalesDatabase, AndroidLog;

type
  { TClientRecord }
  TClientRecord = record
    Id: Integer;
    RazaoSocial: string;
    Fantasia: string;
    Cnpj: string;
    CidadeUF: string;
    Endereco: string;
    LimiteCredito: Double;
    SaldoDisponivel: Double;
    IsLiberado: Boolean;
    Grau: string;
  end;

  { TProductRecord }
  TProductRecord = record
    Id: Integer;
    Codigo: string;
    Descricao: string;
    Categoria: string;
    Preco: Double;
    Unidade: string;
    Estoque: Integer;
  end;

  { TCartItem }
  TCartItem = record
    ProductIdx: Integer;
    Descricao: string;
    Qtd: Integer;
    PrecoUnit: Double;
    Subtotal: Double;
  end;

  { TSellerRecord: Dados do vendedor autenticado no sistema }
  TSellerRecord = record
    Id: Integer;
    Nome: string;
    Usuario: string;
    Senha: string;
    Codigo: string;
    Rota: string;
    Empresa: string;
    MetaMes: Double;
  end;

  { TOrderRecord }
  TOrderRecord = record
    Numero: Integer;
    ClienteNome: string;
    DataHora: string;
    QtdItens: Integer;
    Total: Double;
    Status: string;
  end;

  { TSalesStore: Repositório central de dados conectado ao SQLite }
  TSalesStore = class
  private
    FSeller: TSellerRecord;
    FIsLoggedIn: Boolean;
    FClients: array of TClientRecord;
    FProducts: array of TProductRecord;
    FCartItems: array of TCartItem;
    FOrders: array of TOrderRecord;
    FSelectedClientIdx: Integer;
    FMetaMes: Double;
    FNextOrderNum: Integer;
    procedure PopulateFallbackData;
  public
    constructor Create;
    destructor Destroy; override;

    // Sincronização e carga direta do SQLite
    procedure CarregarDadosDoBanco;

    // Autenticação de Vendedor
    function Login(const AUser, APass: string): Boolean;
    procedure Logout;
    property CurrentSeller: TSellerRecord read FSeller;
    property IsLoggedIn: Boolean read FIsLoggedIn;

    // Ações de Clientes
    function ClientCount: Integer;
    function GetClient(Index: Integer): TClientRecord;
    procedure SelectClient(Index: Integer);
    property SelectedClientIdx: Integer read FSelectedClientIdx write FSelectedClientIdx;

    // Ações de Produtos
    function ProductCount: Integer;
    function GetProduct(Index: Integer): TProductRecord;

    // Ações de Carrinho de Pedido
    function CartItemCount: Integer;
    function GetCartItem(Index: Integer): TCartItem;
    procedure AddProductToCart(ProductIdx: Integer);
    procedure RemoveProductFromCart(ProductIdx: Integer);
    procedure ClearCart;
    function GetCartSubtotal: Double;
    function GetCartDiscount: Double;
    function GetCartTotal: Double;
    function FinalizeOrder(out ANewOrderNum: Integer): Boolean;

    // Ações de Dashboard e Histórico
    function OrderCount: Integer;
    function GetOrder(Index: Integer): TOrderRecord;
    function GetTotalVendasMes: Double;
    function GetTotalVendasHoje: Double;
    function GetPercentMeta: Double;
    property MetaMes: Double read FMetaMes;
  end;

function SalesStore: TSalesStore;

implementation

var
  GSalesStore: TSalesStore = nil;

function SalesStore: TSalesStore;
begin
  if not Assigned(GSalesStore) then
    GSalesStore := TSalesStore.Create;
  Result := GSalesStore;
end;

{ TSalesStore }

constructor TSalesStore.Create;
begin
  inherited Create;
  FMetaMes := 180000.0;
  FNextOrderNum := 8493;
  FSelectedClientIdx := 0;

  // 1. Tentar conectar ao banco SQLite imediatamente
  try
    SalesDB.ConnectAndInitialize;
  except
    on E: Exception do
      LogError('Erro ao inicializar SalesDB: ' + E.Message);
  end;

  // 2. Carregar dados reais do SQLite (ou fallback se indisponível)
  CarregarDadosDoBanco;

  // Adicionar item inicial ao carrinho para demonstração imediata
  if Length(FProducts) > 0 then
  begin
    SetLength(FCartItems, 1);
    FCartItems[0].ProductIdx := 0;
    FCartItems[0].Descricao := FProducts[0].Descricao;
    FCartItems[0].Qtd := 10;
    FCartItems[0].PrecoUnit := FProducts[0].Preco;
    FCartItems[0].Subtotal := 10 * FProducts[0].Preco;
  end;
end;

destructor TSalesStore.Destroy;
begin
  SetLength(FClients, 0);
  SetLength(FProducts, 0);
  SetLength(FCartItems, 0);
  SetLength(FOrders, 0);
  inherited Destroy;
end;

procedure TSalesStore.CarregarDadosDoBanco;
var
  DbClients: TClientDBArray;
  DbProducts: TProductDBArray;
  DbOrders: TOrderDBArray;
  I, Count: Integer;
begin
  LogInfo('>>> [SalesStore] Carregando dados da camada SQLite...');

  // 1. Clientes
  Count := SalesDB.CarregarClientes(DbClients);
  if Count > 0 then
  begin
    SetLength(FClients, Count);
    for I := 0 to Count - 1 do
    begin
      FClients[I].Id := DbClients[I].Id;
      FClients[I].RazaoSocial := DbClients[I].RazaoSocial;
      FClients[I].Fantasia := DbClients[I].Fantasia;
      FClients[I].Cnpj := DbClients[I].Cnpj;
      FClients[I].CidadeUF := DbClients[I].CidadeUF;
      FClients[I].Endereco := DbClients[I].Endereco;
      FClients[I].LimiteCredito := DbClients[I].LimiteCredito;
      FClients[I].SaldoDisponivel := DbClients[I].SaldoDisponivel;
      FClients[I].IsLiberado := DbClients[I].IsLiberado;
      FClients[I].Grau := DbClients[I].Grau;
    end;
    LogInfo(Format('>>> [SalesStore] %d clientes carregados com sucesso do SQLite!', [Count]));
  end;

  // 2. Produtos
  Count := SalesDB.CarregarProdutos(DbProducts);
  if Count > 0 then
  begin
    SetLength(FProducts, Count);
    for I := 0 to Count - 1 do
    begin
      FProducts[I].Id := DbProducts[I].Id;
      FProducts[I].Codigo := DbProducts[I].Codigo;
      FProducts[I].Descricao := DbProducts[I].Descricao;
      FProducts[I].Categoria := DbProducts[I].Categoria;
      FProducts[I].Preco := DbProducts[I].Preco;
      FProducts[I].Unidade := DbProducts[I].Unidade;
      FProducts[I].Estoque := DbProducts[I].Estoque;
    end;
    LogInfo(Format('>>> [SalesStore] %d produtos carregados com sucesso do SQLite!', [Count]));
  end;

  // 3. Pedidos
  Count := SalesDB.CarregarPedidos(DbOrders);
  if Count > 0 then
  begin
    SetLength(FOrders, Count);
    for I := 0 to Count - 1 do
    begin
      FOrders[I].Numero := DbOrders[I].Numero;
      FOrders[I].ClienteNome := DbOrders[I].ClienteNome;
      FOrders[I].DataHora := DbOrders[I].DataHora;
      FOrders[I].QtdItens := DbOrders[I].QtdItens;
      FOrders[I].Total := DbOrders[I].Total;
      FOrders[I].Status := DbOrders[I].Status;
      if FOrders[I].Numero >= FNextOrderNum then
        FNextOrderNum := FOrders[I].Numero + 1;
    end;
    LogInfo(Format('>>> [SalesStore] %d pedidos carregados com sucesso do SQLite!', [Count]));
  end;

  // Se o SQLite não retornou registros, ativar fallback estático
  if Length(FClients) = 0 then
  begin
    LogWarn('>>> [SalesStore] Base SQLite vazia ou inacessivel. Ativando dados de fallback...');
    PopulateFallbackData;
  end;
end;

procedure TSalesStore.PopulateFallbackData;
begin
  FSeller.Id := 101;
  FSeller.Nome := 'Carlos Eduardo Silva';
  FSeller.Usuario := 'carlos';
  FSeller.Senha := '123';
  FSeller.Codigo := 'REP-4029';
  FSeller.Rota := 'Rota Zona Sul - SP';
  FSeller.Empresa := 'VendaForce Distribuidora S/A';
  FSeller.MetaMes := 180000.0;
  FIsLoggedIn := False;

  SetLength(FClients, 4);
  FClients[0].Id := 1;
  FClients[0].RazaoSocial := 'SUPERMERCADO CENTRAL LTDA';
  FClients[0].Fantasia := 'Supermercado Central (Matriz)';
  FClients[0].Cnpj := '14.820.312/0001-95';
  FClients[0].CidadeUF := 'Sao Paulo / SP';
  FClients[0].Endereco := 'Av. Paulista, 1500 - Bela Vista';
  FClients[0].LimiteCredito := 45000.0;
  FClients[0].SaldoDisponivel := 18200.0;
  FClients[0].IsLiberado := True;
  FClients[0].Grau := 'Grau A';

  FClients[1].Id := 2;
  FClients[1].RazaoSocial := 'DISTRIBUIDORA SAO PAULO S/A';
  FClients[1].Fantasia := 'Distribuidora Sao Paulo';
  FClients[1].Cnpj := '23.456.789/0001-12';
  FClients[1].CidadeUF := 'Sao Paulo / SP';
  FClients[1].Endereco := 'Rua Santa Cruz, 1150 - Vila Mariana';
  FClients[1].LimiteCredito := 60000.0;
  FClients[1].SaldoDisponivel := 42500.0;
  FClients[1].IsLiberado := True;
  FClients[1].Grau := 'Grau A';

  FClients[2].Id := 3;
  FClients[2].RazaoSocial := 'MERCEARIA CENTRAL DE PINHEIROS';
  FClients[2].Fantasia := 'Mercearia Pinheiros';
  FClients[2].Cnpj := '34.567.890/0001-23';
  FClients[2].CidadeUF := 'Sao Paulo / SP';
  FClients[2].Endereco := 'Rua dos Pinheiros, 820 - Pinheiros';
  FClients[2].LimiteCredito := 25000.0;
  FClients[2].SaldoDisponivel := 14800.0;
  FClients[2].IsLiberado := True;
  FClients[2].Grau := 'Grau B';

  FClients[3].Id := 4;
  FClients[3].RazaoSocial := 'COMERCIAL BANDEIRANTES LTDA';
  FClients[3].Fantasia := 'Bandeirantes Bebidas';
  FClients[3].Cnpj := '45.123.890/0001-44';
  FClients[3].CidadeUF := 'Santos / SP';
  FClients[3].Endereco := 'Av. Ana Costa, 300 - Gonzaga';
  FClients[3].LimiteCredito := 15000.0;
  FClients[3].SaldoDisponivel := 0.0;
  FClients[3].IsLiberado := False;
  FClients[3].Grau := 'Grau C';

  SetLength(FProducts, 4);
  FProducts[0].Id := 1;
  FProducts[0].Codigo := 'CAF-8802';
  FProducts[0].Descricao := 'Cafe Premium Torrado 500g';
  FProducts[0].Categoria := 'Alimentos';
  FProducts[0].Preco := 14.50;
  FProducts[0].Unidade := 'CX';
  FProducts[0].Estoque := 350;

  FProducts[1].Id := 2;
  FProducts[1].Codigo := 'AZT-2201';
  FProducts[1].Descricao := 'Azeite Extra Virgem 500ml';
  FProducts[1].Categoria := 'Alimentos';
  FProducts[1].Preco := 32.90;
  FProducts[1].Unidade := 'CX';
  FProducts[1].Estoque := 180;

  FProducts[2].Id := 3;
  FProducts[2].Codigo := 'SAB-1044';
  FProducts[2].Descricao := 'Sabao em Po Concentrado 1kg';
  FProducts[2].Categoria := 'Limpeza';
  FProducts[2].Preco := 18.75;
  FProducts[2].Unidade := 'CX';
  FProducts[2].Estoque := 420;

  FProducts[3].Id := 4;
  FProducts[3].Codigo := 'ARR-5001';
  FProducts[3].Descricao := 'Arroz Nobre Tipo 1 5kg';
  FProducts[3].Categoria := 'Alimentos';
  FProducts[3].Preco := 29.90;
  FProducts[3].Unidade := 'FD';
  FProducts[3].Estoque := 600;

  SetLength(FOrders, 2);
  FOrders[0].Numero := 8490;
  FOrders[0].ClienteNome := 'Mercearia Pinheiros';
  FOrders[0].DataHora := '24/10 09:42';
  FOrders[0].QtdItens := 18;
  FOrders[0].Total := 5320.00;
  FOrders[0].Status := 'FATURADO';

  FOrders[1].Numero := 8491;
  FOrders[1].ClienteNome := 'Supermercado Central (Matriz)';
  FOrders[1].DataHora := '24/10 11:15';
  FOrders[1].QtdItens := 24;
  FOrders[1].Total := 7130.00;
  FOrders[1].Status := 'TRANSMITIDO';
end;

function TSalesStore.Login(const AUser, APass: string): Boolean;
var
  DbSeller: TSellerDBRecord;
begin
  // 1. Tenta autenticar na base SQLite integrada
  if SalesDB.AutenticarVendedor(AUser, APass, DbSeller) then
  begin
    FSeller.Id := DbSeller.Id;
    FSeller.Usuario := DbSeller.Usuario;
    FSeller.Senha := DbSeller.Senha;
    FSeller.Nome := DbSeller.Nome;
    FSeller.Codigo := DbSeller.Codigo;
    FSeller.Rota := DbSeller.Rota;
    FSeller.Empresa := DbSeller.Empresa;
    FSeller.MetaMes := DbSeller.MetaMes;
    FMetaMes := DbSeller.MetaMes;
    FIsLoggedIn := True;
    // Atualizar dados do banco SQLite
    CarregarDadosDoBanco;
    Result := True;
  end
  // 2. Fallback local autenticado
  else if (LowerCase(Trim(AUser)) = LowerCase(FSeller.Usuario)) and
          (Trim(APass) = FSeller.Senha) then
  begin
    FIsLoggedIn := True;
    Result := True;
  end
  else
    Result := False;
end;

procedure TSalesStore.Logout;
begin
  FIsLoggedIn := False;
end;

function TSalesStore.ClientCount: Integer;
begin
  Result := Length(FClients);
end;

function TSalesStore.GetClient(Index: Integer): TClientRecord;
begin
  if (Index >= 0) and (Index < Length(FClients)) then
    Result := FClients[Index]
  else
  begin
    FillChar(Result, SizeOf(Result), 0);
    Result.Fantasia := 'Cliente Nao Selecionado';
    Result.RazaoSocial := 'Cliente Nao Selecionado';
  end;
end;

procedure TSalesStore.SelectClient(Index: Integer);
begin
  if (Index >= 0) and (Index < Length(FClients)) then
    FSelectedClientIdx := Index;
end;

function TSalesStore.ProductCount: Integer;
begin
  Result := Length(FProducts);
end;

function TSalesStore.GetProduct(Index: Integer): TProductRecord;
begin
  if (Index >= 0) and (Index < Length(FProducts)) then
    Result := FProducts[Index]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function TSalesStore.CartItemCount: Integer;
begin
  Result := Length(FCartItems);
end;

function TSalesStore.GetCartItem(Index: Integer): TCartItem;
begin
  if (Index >= 0) and (Index < Length(FCartItems)) then
    Result := FCartItems[Index]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

procedure TSalesStore.AddProductToCart(ProductIdx: Integer);
var
  I: Integer;
  Found: Boolean;
begin
  if (ProductIdx < 0) or (ProductIdx >= Length(FProducts)) then Exit;

  Found := False;
  for I := 0 to High(FCartItems) do
  begin
    if FCartItems[I].ProductIdx = ProductIdx then
    begin
      Inc(FCartItems[I].Qtd);
      FCartItems[I].Subtotal := FCartItems[I].Qtd * FCartItems[I].PrecoUnit;
      Found := True;
      Break;
    end;
  end;

  if not Found then
  begin
    SetLength(FCartItems, Length(FCartItems) + 1);
    I := High(FCartItems);
    FCartItems[I].ProductIdx := ProductIdx;
    FCartItems[I].Descricao := FProducts[ProductIdx].Descricao;
    FCartItems[I].Qtd := 1;
    FCartItems[I].PrecoUnit := FProducts[ProductIdx].Preco;
    FCartItems[I].Subtotal := FCartItems[I].PrecoUnit;
  end;
end;

procedure TSalesStore.RemoveProductFromCart(ProductIdx: Integer);
var
  I, J: Integer;
begin
  for I := 0 to High(FCartItems) do
  begin
    if FCartItems[I].ProductIdx = ProductIdx then
    begin
      if FCartItems[I].Qtd > 1 then
      begin
        Dec(FCartItems[I].Qtd);
        FCartItems[I].Subtotal := FCartItems[I].Qtd * FCartItems[I].PrecoUnit;
      end
      else
      begin
        for J := I to High(FCartItems) - 1 do
          FCartItems[J] := FCartItems[J + 1];
        SetLength(FCartItems, Length(FCartItems) - 1);
      end;
      Exit;
    end;
  end;
end;

procedure TSalesStore.ClearCart;
begin
  SetLength(FCartItems, 0);
end;

function TSalesStore.GetCartSubtotal: Double;
var
  I: Integer;
begin
  Result := 0.0;
  for I := 0 to High(FCartItems) do
    Result := Result + FCartItems[I].Subtotal;
end;

function TSalesStore.GetCartDiscount: Double;
begin
  Result := GetCartSubtotal * 0.05; // 5% de desconto comercial
end;

function TSalesStore.GetCartTotal: Double;
begin
  Result := GetCartSubtotal - GetCartDiscount;
end;

function TSalesStore.FinalizeOrder(out ANewOrderNum: Integer): Boolean;
var
  OrderIdx: Integer;
  TotItens: Integer;
  I: Integer;
  Cli: TClientRecord;
begin
  Result := False;
  ANewOrderNum := 0;
  if Length(FCartItems) = 0 then Exit;

  TotItens := 0;
  for I := 0 to High(FCartItems) do
    TotItens := TotItens + FCartItems[I].Qtd;

  ANewOrderNum := FNextOrderNum;
  Inc(FNextOrderNum);

  Cli := GetClient(FSelectedClientIdx);

  // Inserir no topo dos pedidos na memória
  SetLength(FOrders, Length(FOrders) + 1);
  for OrderIdx := High(FOrders) downto 1 do
    FOrders[OrderIdx] := FOrders[OrderIdx - 1];

  FOrders[0].Numero := ANewOrderNum;
  FOrders[0].ClienteNome := Cli.Fantasia;
  FOrders[0].DataHora := FormatDateTime('dd/mm hh:nn', Now);
  FOrders[0].QtdItens := TotItens;
  FOrders[0].Total := GetCartTotal;
  FOrders[0].Status := 'TRANSMITIDO';

  // Gravar novo pedido imediatamente no banco de dados SQLite
  try
    SalesDB.InserirPedido(ANewOrderNum, FOrders[0].ClienteNome,
      FSeller.Usuario, FOrders[0].DataHora, FOrders[0].QtdItens,
      FOrders[0].Total, FOrders[0].Status);
    LogInfo(Format('>>> [SalesStore] Pedido #%d inserido com sucesso no banco SQLite!', [ANewOrderNum]));
  except
    on E: Exception do
      LogError('Erro ao persistir pedido no SQLite: ' + E.Message);
  end;

  ClearCart;
  Result := True;
end;

function TSalesStore.OrderCount: Integer;
begin
  Result := Length(FOrders);
end;

function TSalesStore.GetOrder(Index: Integer): TOrderRecord;
begin
  if (Index >= 0) and (Index < Length(FOrders)) then
    Result := FOrders[Index]
  else
    FillChar(Result, SizeOf(Result), 0);
end;

function TSalesStore.GetTotalVendasMes: Double;
var
  I: Integer;
begin
  Result := 130350.0; // Base faturada do mês acumulada
  for I := 0 to High(FOrders) do
    Result := Result + FOrders[I].Total;
end;

function TSalesStore.GetTotalVendasHoje: Double;
var
  I: Integer;
begin
  Result := 0.0;
  for I := 0 to High(FOrders) do
    Result := Result + FOrders[I].Total;
end;

function TSalesStore.GetPercentMeta: Double;
begin
  if FMetaMes > 0 then
    Result := (GetTotalVendasMes / FMetaMes) * 100.0
  else
    Result := 0.0;
end;

initialization

finalization
  if Assigned(GSalesStore) then
    FreeAndNil(GSalesStore);

end.
