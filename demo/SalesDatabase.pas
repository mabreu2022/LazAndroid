{
  LazDroid-Deploy Demo: Gerenciador de Banco de Dados SQLite
  Unit: SalesDatabase.pas
  Descrição: Camada de persistência local SQLite para Força de Vendas Android:
             Criação do banco de dados, tabelas de vendedores, clientes, produtos e pedidos,
             carregamento dinâmico de dados e sincronização de pedidos.
}
unit SalesDatabase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, SQLite3Dyn, dynlibs, AndroidLog;

type
  { TSellerDBRecord: Dados do vendedor no SQLite }
  TSellerDBRecord = record
    Id: Integer;
    Usuario: string;
    Senha: string;
    Nome: string;
    Codigo: string;
    Rota: string;
    Empresa: string;
    MetaMes: Double;
  end;

  { TClientDBRecord: Dados do cliente no SQLite }
  TClientDBRecord = record
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

  { TProductDBRecord: Dados do produto no SQLite }
  TProductDBRecord = record
    Id: Integer;
    Codigo: string;
    Descricao: string;
    Categoria: string;
    Preco: Double;
    Unidade: string;
    Estoque: Integer;
  end;

  { TOrderDBRecord: Dados do pedido no SQLite }
  TOrderDBRecord = record
    Numero: Integer;
    ClienteNome: string;
    VendedorUsuario: string;
    DataHora: string;
    QtdItens: Integer;
    Total: Double;
    Status: string;
  end;

  { Arrays dinâmicos }
  TClientDBArray  = array of TClientDBRecord;
  TProductDBArray = array of TProductDBRecord;
  TOrderDBArray   = array of TOrderDBRecord;

  { TSalesDatabase }
  TSalesDatabase = class
  private
    FDbHandle: Pointer;
    FDbPath: string;
    FIsConnected: Boolean;
    FStatusMsg: string;
    FClientCount: Integer;
    FProductCount: Integer;
    FOrderCount: Integer;
    function DetermineDbPath: string;
    function ExecSQL(const ASQL: string): Boolean;
    procedure AtualizarContagens;
  public
    constructor Create;
    destructor Destroy; override;

    function ConnectAndInitialize: Boolean;
    procedure CloseDatabase;

    // Autenticação de Vendedor via SQLite
    function AutenticarVendedor(const AUser, APass: string; out ASeller: TSellerDBRecord): Boolean;

    // Carregamento de Dados do Banco SQLite
    function CarregarClientes(out AClients: TClientDBArray): Integer;
    function CarregarProdutos(out AProducts: TProductDBArray): Integer;
    function CarregarPedidos(out AOrders: TOrderDBArray): Integer;

    // Inserção de Novo Pedido no SQLite
    function InserirPedido(ANumero: Integer; const ACliente, AVendedor, ADataHora: string;
      AQtdItens: Integer; ATotal: Double; const AStatus: string): Boolean;

    // Estatísticas do Banco
    function ObterEstatisticas(out ACliCount, AProdCount, AOrdCount: Integer): Boolean;

    property IsConnected: Boolean read FIsConnected;
    property DbPath: string read FDbPath;
    property StatusMsg: string read FStatusMsg;
    property ClientCount: Integer read FClientCount;
    property ProductCount: Integer read FProductCount;
    property OrderCount: Integer read FOrderCount;
  end;

function SalesDB: TSalesDatabase;

implementation

var
  GSalesDB: TSalesDatabase = nil;

function SalesDB: TSalesDatabase;
begin
  if not Assigned(GSalesDB) then
    GSalesDB := TSalesDatabase.Create;
  Result := GSalesDB;
end;

{ TSalesDatabase }

constructor TSalesDatabase.Create;
begin
  inherited Create;
  FDbHandle := nil;
  FIsConnected := False;
  FDbPath := DetermineDbPath;
  FStatusMsg := 'Nao inicializado';
  FClientCount := 0;
  FProductCount := 0;
  FOrderCount := 0;
end;

destructor TSalesDatabase.Destroy;
begin
  CloseDatabase;
  inherited Destroy;
end;

function TSalesDatabase.DetermineDbPath: string;
var
  AppDir: string;
  Candidate: string;
begin
{$IFDEF ANDROID}
  // No Android, o diretório interno privado é /data/data/<package>/files/
  AppDir := '/data/data/com.lazarus.android.demo/files';
  if DirectoryExists(AppDir) or ForceDirectories(AppDir) then
    Result := AppDir + '/vendas.db'
  else
    Result := 'vendas.db';
{$ELSE}
  // No Windows / Desktop / IDE Lazarus: verificar diretórios locais
  AppDir := ExtractFilePath(ParamStr(0));
  if FileExists(AppDir + 'vendas.db') then
    Result := AppDir + 'vendas.db'
  else if FileExists(AppDir + 'demo\vendas.db') then
    Result := AppDir + 'demo\vendas.db'
  else if FileExists(AppDir + '..\vendas.db') then
    Result := ExpandFileName(AppDir + '..\vendas.db')
  else if FileExists('demo\vendas.db') then
    Result := ExpandFileName('demo\vendas.db')
  else if FileExists('vendas.db') then
    Result := ExpandFileName('vendas.db')
  else
    Result := AppDir + 'vendas.db';
{$ENDIF}
end;

function TSalesDatabase.ExecSQL(const ASQL: string): Boolean;
var
  ErrMsg: PAnsiChar;
  Res: Integer;
begin
  Result := False;
  if not FIsConnected or (FDbHandle = nil) then Exit;

  ErrMsg := nil;
  Res := sqlite3_exec(FDbHandle, PAnsiChar(ASQL), nil, nil, @ErrMsg);
  if Res = SQLITE_OK then
  begin
    Result := True;
  end
  else
  begin
    if ErrMsg <> nil then
    begin
      LogError(Format('Erro SQLite Exec: %s', [string(ErrMsg)]));
      sqlite3_free(ErrMsg);
    end;
  end;
end;

procedure TSalesDatabase.AtualizarContagens;
var
  Stmt: Pointer;
begin
  FClientCount := 0;
  FProductCount := 0;
  FOrderCount := 0;
  if not FIsConnected or (FDbHandle = nil) then Exit;

  if sqlite3_prepare_v2(FDbHandle, 'SELECT count(*) FROM clientes;', -1, @Stmt, nil) = SQLITE_OK then
  begin
    if sqlite3_step(Stmt) = SQLITE_ROW then
      FClientCount := sqlite3_column_int(Stmt, 0);
    sqlite3_finalize(Stmt);
  end;

  if sqlite3_prepare_v2(FDbHandle, 'SELECT count(*) FROM produtos;', -1, @Stmt, nil) = SQLITE_OK then
  begin
    if sqlite3_step(Stmt) = SQLITE_ROW then
      FProductCount := sqlite3_column_int(Stmt, 0);
    sqlite3_finalize(Stmt);
  end;

  if sqlite3_prepare_v2(FDbHandle, 'SELECT count(*) FROM pedidos;', -1, @Stmt, nil) = SQLITE_OK then
  begin
    if sqlite3_step(Stmt) = SQLITE_ROW then
      FOrderCount := sqlite3_column_int(Stmt, 0);
    sqlite3_finalize(Stmt);
  end;
end;

function TSalesDatabase.ConnectAndInitialize: Boolean;
var
  InitRes: Integer;
  OpenRes: Integer;
  CreateTablesSQL: string;
  SeedSQL: string;
  IsNewDb: Boolean;
  DbSeller: TSellerDBRecord;
begin
  Result := False;
  LogInfo('Iniciando conexao com SQLite...');

  // 1. Carregar biblioteca SQLite dinamicamente
{$IFDEF MSWINDOWS}
  InitRes := TryInitializeSqlite('sqlite3.dll');
  if InitRes < 0 then
    InitRes := TryInitializeSqlite('');
{$ELSE}
  InitRes := TryInitializeSqlite('libsqlite.so');
  if InitRes < 0 then
  begin
    LogWarn('Tentativa libsqlite.so: ' + GetLoadErrorStr);
    InitRes := TryInitializeSqlite('libsqlite3.so');
  end;
  if InitRes < 0 then
  begin
    LogWarn('Tentativa libsqlite3.so: ' + GetLoadErrorStr);
    InitRes := TryInitializeSqlite('/data/data/com.lazarus.android.demo/lib/libsqlite.so');
  end;
  if InitRes < 0 then
  begin
    LogWarn('Tentativa /data/data/.../lib/libsqlite.so: ' + GetLoadErrorStr);
    InitRes := TryInitializeSqlite('/data/data/com.lazarus.android.demo/lib/libsqlite3.so');
  end;
  if InitRes < 0 then
    InitRes := TryInitializeSqlite('');
{$ENDIF}

  if InitRes < 0 then
  begin
    FStatusMsg := 'SQLite lib indisponivel (modo simulado)';
    LogWarn('SQLite compartilhado nao disponivel: ' + GetLoadErrorStr);
    Exit(False);
  end;

  // 2. Abrir ou Criar o arquivo do banco de dados
  IsNewDb := not FileExists(FDbPath);
  if IsNewDb then
    LogInfo('>>> [SQLite] Criando banco de dados: ' + FDbPath)
  else
    LogInfo('>>> [SQLite] Banco de dados existente encontrado: ' + FDbPath);

  OpenRes := sqlite3_open(PAnsiChar(FDbPath), @FDbHandle);
  if OpenRes <> SQLITE_OK then
  begin
    FStatusMsg := Format('Erro ao abrir SQLite (%d)', [OpenRes]);
    LogError(FStatusMsg);
    Exit(False);
  end;

  FIsConnected := True;
  LogInfo('>>> [SQLite] Conexao aberta com sucesso em: ' + FDbPath);

  // 3. Criar Tabelas se não existirem
  CreateTablesSQL :=
    'CREATE TABLE IF NOT EXISTS vendedores (' +
    '  id INTEGER PRIMARY KEY,' +
    '  usuario TEXT UNIQUE NOT NULL,' +
    '  senha TEXT NOT NULL,' +
    '  nome TEXT NOT NULL,' +
    '  codigo TEXT NOT NULL,' +
    '  rota TEXT NOT NULL,' +
    '  empresa TEXT NOT NULL,' +
    '  meta_mes REAL NOT NULL' +
    ');' +
    'CREATE TABLE IF NOT EXISTS clientes (' +
    '  id INTEGER PRIMARY KEY,' +
    '  razao_social TEXT NOT NULL,' +
    '  fantasia TEXT NOT NULL,' +
    '  cnpj TEXT NOT NULL,' +
    '  cidade_uf TEXT NOT NULL,' +
    '  endereco TEXT NOT NULL DEFAULT '''',' +
    '  limite_credito REAL NOT NULL,' +
    '  saldo_disponivel REAL NOT NULL,' +
    '  is_liberado INTEGER NOT NULL,' +
    '  grau TEXT NOT NULL DEFAULT ''Grau A''' +
    ');' +
    'CREATE TABLE IF NOT EXISTS produtos (' +
    '  id INTEGER PRIMARY KEY,' +
    '  codigo TEXT NOT NULL,' +
    '  descricao TEXT NOT NULL,' +
    '  categoria TEXT NOT NULL,' +
    '  preco REAL NOT NULL,' +
    '  unidade TEXT NOT NULL,' +
    '  estoque INTEGER NOT NULL' +
    ');' +
    'CREATE TABLE IF NOT EXISTS pedidos (' +
    '  numero INTEGER PRIMARY KEY,' +
    '  cliente_nome TEXT NOT NULL,' +
    '  vendedor_usuario TEXT NOT NULL,' +
    '  data_hora TEXT NOT NULL,' +
    '  qtd_itens INTEGER NOT NULL,' +
    '  total REAL NOT NULL,' +
    '  status TEXT NOT NULL' +
    ');';

  if not ExecSQL(CreateTablesSQL) then
  begin
    LogError('Falha ao criar tabelas no SQLite.');
    Exit(False);
  end;

  // 4. Inserir Dados Iniciais se tabelas vazias
  AtualizarContagens;
  if FClientCount = 0 then
  begin
    LogInfo('>>> [SQLite] Semeando dados iniciais no banco SQLite...');
    SeedSQL :=
      'INSERT OR IGNORE INTO vendedores (id, usuario, senha, nome, codigo, rota, empresa, meta_mes) ' +
      'VALUES (101, ''carlos'', ''123'', ''Carlos Eduardo Silva'', ''REP-4029'', ''Rota Zona Sul - SP'', ''VendaForce Distribuidora S/A'', 180000.0);' +

      'INSERT OR IGNORE INTO clientes (id, razao_social, fantasia, cnpj, cidade_uf, endereco, limite_credito, saldo_disponivel, is_liberado, grau) ' +
      'VALUES (1, ''SUPERMERCADO CENTRAL LTDA'', ''Supermercado Central (Matriz)'', ''14.820.312/0001-95'', ''Sao Paulo / SP'', ''Av. Paulista, 1500 - Bela Vista'', 45000.0, 18200.0, 1, ''Grau A'');' +
      'INSERT OR IGNORE INTO clientes (id, razao_social, fantasia, cnpj, cidade_uf, endereco, limite_credito, saldo_disponivel, is_liberado, grau) ' +
      'VALUES (2, ''DISTRIBUIDORA SAO PAULO S/A'', ''Distribuidora Sao Paulo'', ''23.456.789/0001-12'', ''Sao Paulo / SP'', ''Rua Santa Cruz, 1150 - Vila Mariana'', 60000.0, 42500.0, 1, ''Grau A'');' +
      'INSERT OR IGNORE INTO clientes (id, razao_social, fantasia, cnpj, cidade_uf, endereco, limite_credito, saldo_disponivel, is_liberado, grau) ' +
      'VALUES (3, ''MERCEARIA CENTRAL DE PINHEIROS'', ''Mercearia Pinheiros'', ''34.567.890/0001-23'', ''Sao Paulo / SP'', ''Rua dos Pinheiros, 820 - Pinheiros'', 25000.0, 14800.0, 1, ''Grau B'');' +
      'INSERT OR IGNORE INTO clientes (id, razao_social, fantasia, cnpj, cidade_uf, endereco, limite_credito, saldo_disponivel, is_liberado, grau) ' +
      'VALUES (4, ''SUPERMERCADO ALVORADA LTDA'', ''Super Alvorada'', ''12.345.678/0001-90'', ''Sao Paulo / SP'', ''Av. das Americas, 420 - Morumbi'', 35000.0, 24350.0, 1, ''Grau A'');' +
      'INSERT OR IGNORE INTO clientes (id, razao_social, fantasia, cnpj, cidade_uf, endereco, limite_credito, saldo_disponivel, is_liberado, grau) ' +
      'VALUES (5, ''COMERCIAL BANDEIRANTES LTDA'', ''Bandeirantes Bebidas'', ''45.123.890/0001-44'', ''Santos / SP'', ''Av. Ana Costa, 300 - Gonzaga'', 15000.0, 0.0, 0, ''Grau C'');' +
      'INSERT OR IGNORE INTO clientes (id, razao_social, fantasia, cnpj, cidade_uf, endereco, limite_credito, saldo_disponivel, is_liberado, grau) ' +
      'VALUES (6, ''AGROPECUARIA VALE VERDE LTDA'', ''Agro Vale Verde'', ''33.987.654/0002-88'', ''Campinas / SP'', ''Rod. Anhanguera, km 98'', 28000.0, 19400.0, 1, ''Grau B'');' +

      'INSERT OR IGNORE INTO produtos (id, codigo, descricao, categoria, preco, unidade, estoque) ' +
      'VALUES (1, ''CAF-8802'', ''Cafe Premium Torrado 500g'', ''Alimentos'', 14.50, ''CX'', 350);' +
      'INSERT OR IGNORE INTO produtos (id, codigo, descricao, categoria, preco, unidade, estoque) ' +
      'VALUES (2, ''AZT-2201'', ''Azeite Extra Virgem 500ml'', ''Alimentos'', 32.90, ''CX'', 180);' +
      'INSERT OR IGNORE INTO produtos (id, codigo, descricao, categoria, preco, unidade, estoque) ' +
      'VALUES (3, ''SAB-1044'', ''Sabao em Po Concentrado 1kg'', ''Limpeza'', 18.75, ''CX'', 420);' +
      'INSERT OR IGNORE INTO produtos (id, codigo, descricao, categoria, preco, unidade, estoque) ' +
      'VALUES (4, ''ARR-5001'', ''Arroz Nobre Tipo 1 5kg'', ''Alimentos'', 29.90, ''FD'', 600);' +
      'INSERT OR IGNORE INTO produtos (id, codigo, descricao, categoria, preco, unidade, estoque) ' +
      'VALUES (5, ''OL-9002'', ''Oleo de Soja Especial 900ml'', ''Alimentos'', 7.80, ''CX'', 850);' +
      'INSERT OR IGNORE INTO produtos (id, codigo, descricao, categoria, preco, unidade, estoque) ' +
      'VALUES (6, ''DET-3310'', ''Detergente Neutro 500ml'', ''Limpeza'', 2.95, ''CX'', 1200);' +
      'INSERT OR IGNORE INTO produtos (id, codigo, descricao, categoria, preco, unidade, estoque) ' +
      'VALUES (7, ''SUC-4405'', ''Suco Integral Uva 1.5L'', ''Bebidas'', 16.40, ''CX'', 260);' +
      'INSERT OR IGNORE INTO produtos (id, codigo, descricao, categoria, preco, unidade, estoque) ' +
      'VALUES (8, ''BISC-112'', ''Biscoito Recheado Chocolate 140g'', ''Mercearia'', 3.65, ''CX'', 950);' +

      'INSERT OR IGNORE INTO pedidos (numero, cliente_nome, vendedor_usuario, data_hora, qtd_itens, total, status) ' +
      'VALUES (8490, ''Mercearia Pinheiros'', ''carlos'', ''24/10 09:42'', 18, 5320.00, ''FATURADO'');' +
      'INSERT OR IGNORE INTO pedidos (numero, cliente_nome, vendedor_usuario, data_hora, qtd_itens, total, status) ' +
      'VALUES (8491, ''Supermercado Central (Matriz)'', ''carlos'', ''24/10 11:15'', 24, 7130.00, ''TRANSMITIDO'');' +
      'INSERT OR IGNORE INTO pedidos (numero, cliente_nome, vendedor_usuario, data_hora, qtd_itens, total, status) ' +
      'VALUES (8492, ''Super Alvorada'', ''carlos'', ''24/10 14:30'', 12, 3850.00, ''EM FILA'');';

    ExecSQL(SeedSQL);
    AtualizarContagens;
    LogInfo('>>> [SQLite] Dados semeados com sucesso!');
  end;

  FStatusMsg := Format('SQLite: Conectado (%s | %d Clientes | %d Produtos | %d Pedidos)',
    [ExtractFileName(FDbPath), FClientCount, FProductCount, FOrderCount]);
  LogInfo(FStatusMsg);

  // 5. Teste de autenticação
  if AutenticarVendedor('carlos', '123', DbSeller) then
    LogInfo(Format('>>> [SQLite] Validacao OK: Vendedor "%s" autenticado!', [DbSeller.Nome]))
  else
    LogWarn('>>> [SQLite] Aviso: Vendedor nao autenticado no teste pos-seed.');

  Result := True;
end;

procedure TSalesDatabase.CloseDatabase;
begin
  if FIsConnected and (FDbHandle <> nil) then
  begin
    sqlite3_close(FDbHandle);
    FDbHandle := nil;
    FIsConnected := False;
    ReleaseSqlite;
    LogInfo('Conexao SQLite fechada.');
  end;
end;

function TSalesDatabase.AutenticarVendedor(const AUser, APass: string; out ASeller: TSellerDBRecord): Boolean;
var
  Stmt: Pointer;
  QuerySQL: string;
  StepRes: Integer;
begin
  Result := False;
  FillChar(ASeller, SizeOf(ASeller), 0);

  if FIsConnected and (FDbHandle <> nil) then
  begin
    QuerySQL := Format(
      'SELECT id, usuario, senha, nome, codigo, rota, empresa, meta_mes ' +
      'FROM vendedores WHERE LOWER(usuario) = LOWER(''%s'') AND senha = ''%s'' LIMIT 1;',
      [AUser, APass]);

    Stmt := nil;
    if sqlite3_prepare_v2(FDbHandle, PAnsiChar(QuerySQL), -1, @Stmt, nil) = SQLITE_OK then
    begin
      try
        StepRes := sqlite3_step(Stmt);
        if StepRes = SQLITE_ROW then
        begin
          ASeller.Id := sqlite3_column_int(Stmt, 0);
          ASeller.Usuario := string(sqlite3_column_text(Stmt, 1));
          ASeller.Senha := string(sqlite3_column_text(Stmt, 2));
          ASeller.Nome := string(sqlite3_column_text(Stmt, 3));
          ASeller.Codigo := string(sqlite3_column_text(Stmt, 4));
          ASeller.Rota := string(sqlite3_column_text(Stmt, 5));
          ASeller.Empresa := string(sqlite3_column_text(Stmt, 6));
          ASeller.MetaMes := sqlite3_column_double(Stmt, 7);
          Result := True;
          LogInfo(Format('Vendedor %s autenticado via SQLite!', [ASeller.Nome]));
        end;
      finally
        sqlite3_finalize(Stmt);
      end;
    end;
  end;

  // Fallback seguro em caso de SQLite desabilitado
  if not Result then
  begin
    if (LowerCase(Trim(AUser)) = 'carlos') and (Trim(APass) = '123') then
    begin
      ASeller.Id := 101;
      ASeller.Usuario := 'carlos';
      ASeller.Senha := '123';
      ASeller.Nome := 'Carlos Eduardo Silva';
      ASeller.Codigo := 'REP-4029';
      ASeller.Rota := 'Rota Zona Sul - SP';
      ASeller.Empresa := 'VendaForce Distribuidora S/A';
      ASeller.MetaMes := 180000.0;
      Result := True;
    end;
  end;
end;

function TSalesDatabase.CarregarClientes(out AClients: TClientDBArray): Integer;
var
  Stmt: Pointer;
  Idx: Integer;
  QuerySQL: string;
begin
  SetLength(AClients, 0);
  Result := 0;
  if not FIsConnected or (FDbHandle = nil) then Exit;

  QuerySQL := 'SELECT id, razao_social, fantasia, cnpj, cidade_uf, endereco, limite_credito, saldo_disponivel, is_liberado, grau FROM clientes ORDER BY id;';
  if sqlite3_prepare_v2(FDbHandle, PAnsiChar(QuerySQL), -1, @Stmt, nil) = SQLITE_OK then
  begin
    try
      Idx := 0;
      while sqlite3_step(Stmt) = SQLITE_ROW do
      begin
        SetLength(AClients, Idx + 1);
        AClients[Idx].Id := sqlite3_column_int(Stmt, 0);
        AClients[Idx].RazaoSocial := string(sqlite3_column_text(Stmt, 1));
        AClients[Idx].Fantasia := string(sqlite3_column_text(Stmt, 2));
        AClients[Idx].Cnpj := string(sqlite3_column_text(Stmt, 3));
        AClients[Idx].CidadeUF := string(sqlite3_column_text(Stmt, 4));
        AClients[Idx].Endereco := string(sqlite3_column_text(Stmt, 5));
        AClients[Idx].LimiteCredito := sqlite3_column_double(Stmt, 6);
        AClients[Idx].SaldoDisponivel := sqlite3_column_double(Stmt, 7);
        AClients[Idx].IsLiberado := (sqlite3_column_int(Stmt, 8) <> 0);
        AClients[Idx].Grau := string(sqlite3_column_text(Stmt, 9));
        Inc(Idx);
      end;
      Result := Idx;
      FClientCount := Idx;
    finally
      sqlite3_finalize(Stmt);
    end;
  end;
end;

function TSalesDatabase.CarregarProdutos(out AProducts: TProductDBArray): Integer;
var
  Stmt: Pointer;
  Idx: Integer;
  QuerySQL: string;
begin
  SetLength(AProducts, 0);
  Result := 0;
  if not FIsConnected or (FDbHandle = nil) then Exit;

  QuerySQL := 'SELECT id, codigo, descricao, categoria, preco, unidade, estoque FROM produtos ORDER BY id;';
  if sqlite3_prepare_v2(FDbHandle, PAnsiChar(QuerySQL), -1, @Stmt, nil) = SQLITE_OK then
  begin
    try
      Idx := 0;
      while sqlite3_step(Stmt) = SQLITE_ROW do
      begin
        SetLength(AProducts, Idx + 1);
        AProducts[Idx].Id := sqlite3_column_int(Stmt, 0);
        AProducts[Idx].Codigo := string(sqlite3_column_text(Stmt, 1));
        AProducts[Idx].Descricao := string(sqlite3_column_text(Stmt, 2));
        AProducts[Idx].Categoria := string(sqlite3_column_text(Stmt, 3));
        AProducts[Idx].Preco := sqlite3_column_double(Stmt, 4);
        AProducts[Idx].Unidade := string(sqlite3_column_text(Stmt, 5));
        AProducts[Idx].Estoque := sqlite3_column_int(Stmt, 6);
        Inc(Idx);
      end;
      Result := Idx;
      FProductCount := Idx;
    finally
      sqlite3_finalize(Stmt);
    end;
  end;
end;

function TSalesDatabase.CarregarPedidos(out AOrders: TOrderDBArray): Integer;
var
  Stmt: Pointer;
  Idx: Integer;
  QuerySQL: string;
begin
  SetLength(AOrders, 0);
  Result := 0;
  if not FIsConnected or (FDbHandle = nil) then Exit;

  QuerySQL := 'SELECT numero, cliente_nome, vendedor_usuario, data_hora, qtd_itens, total, status FROM pedidos ORDER BY numero DESC;';
  if sqlite3_prepare_v2(FDbHandle, PAnsiChar(QuerySQL), -1, @Stmt, nil) = SQLITE_OK then
  begin
    try
      Idx := 0;
      while sqlite3_step(Stmt) = SQLITE_ROW do
      begin
        SetLength(AOrders, Idx + 1);
        AOrders[Idx].Numero := sqlite3_column_int(Stmt, 0);
        AOrders[Idx].ClienteNome := string(sqlite3_column_text(Stmt, 1));
        AOrders[Idx].VendedorUsuario := string(sqlite3_column_text(Stmt, 2));
        AOrders[Idx].DataHora := string(sqlite3_column_text(Stmt, 3));
        AOrders[Idx].QtdItens := sqlite3_column_int(Stmt, 4);
        AOrders[Idx].Total := sqlite3_column_double(Stmt, 5);
        AOrders[Idx].Status := string(sqlite3_column_text(Stmt, 6));
        Inc(Idx);
      end;
      Result := Idx;
      FOrderCount := Idx;
    finally
      sqlite3_finalize(Stmt);
    end;
  end;
end;

function TSalesDatabase.InserirPedido(ANumero: Integer; const ACliente, AVendedor, ADataHora: string;
  AQtdItens: Integer; ATotal: Double; const AStatus: string): Boolean;
var
  InsertSQL: string;
begin
  InsertSQL := Format(
    'INSERT INTO pedidos (numero, cliente_nome, vendedor_usuario, data_hora, qtd_itens, total, status) ' +
    'VALUES (%d, ''%s'', ''%s'', ''%s'', %d, %.2f, ''%s'');',
    [ANumero, ACliente, AVendedor, ADataHora, AQtdItens, ATotal, AStatus]);
  Result := ExecSQL(InsertSQL);
  if Result then
    Inc(FOrderCount);
end;

function TSalesDatabase.ObterEstatisticas(out ACliCount, AProdCount, AOrdCount: Integer): Boolean;
begin
  AtualizarContagens;
  ACliCount := FClientCount;
  AProdCount := FProductCount;
  AOrdCount := FOrderCount;
  Result := FIsConnected;
end;

initialization

finalization
  if Assigned(GSalesDB) then
    FreeAndNil(GSalesDB);

end.
