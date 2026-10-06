unit Unit4;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, sqldb, sqlite3conn, LazDroidMobileControls;

type

  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FConn: TSQLite3Connection;
    FTran: TSQLTransaction;
    function ObterCaminhoBanco: string;
    procedure CriarTabelasSeNecessario;
  public
    function ValidarLogin(const ALogin, ASenha: string; out ANome: string; out ANivel: string): Boolean;
    procedure CarregarProdutos(AListView: TLazDroidListView; const AFiltro: string = '');
    procedure CarregarClientes(AListView: TLazDroidListView; const AFiltro: string = '');
    procedure CarregarPedidos(AListView: TLazDroidListView; const AFiltro: string = '');
  end;

var
  DataModule1: TDataModule1;

implementation

{$R *.lfm}

{ TDataModule1 }

function TDataModule1.ObterCaminhoBanco: string;
var
  AppDir: string;
begin
  {$IFDEF ANDROID}
  AppDir := '/data/user/0/com.lazarus.android.demo/files';
  if not DirectoryExists(AppDir) then
    AppDir := '/data/data/com.lazarus.android.demo/files';
  ForceDirectories(AppDir);
  Result := AppDir + '/app.db';
  {$ELSE}
  AppDir := ExtractFilePath(ParamStr(0));
  if FileExists('d:\Fontes Lazarus\Teste LazDroid\database\app.db') then
    Result := 'd:\Fontes Lazarus\Teste LazDroid\database\app.db'
  else if FileExists(AppDir + 'database' + DirectorySeparator + 'app.db') then
    Result := AppDir + 'database' + DirectorySeparator + 'app.db'
  else
  begin
    ForceDirectories(AppDir + 'database');
    Result := AppDir + 'database' + DirectorySeparator + 'app.db';
  end;
  {$ENDIF}
end;

procedure TDataModule1.CriarTabelasSeNecessario;
var
  Qry: TSQLQuery;
begin
  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;

    if not FTran.Active then
      FTran.StartTransaction;

    // Tabela Usuarios
    Qry.SQL.Text := 'CREATE TABLE IF NOT EXISTS usuarios (' +
                    'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                    'nome VARCHAR(100) NOT NULL, ' +
                    'login VARCHAR(50) UNIQUE NOT NULL, ' +
                    'senha VARCHAR(50) NOT NULL, ' +
                    'nivel VARCHAR(20) DEFAULT ''user'');';
    Qry.ExecSQL;

    // Tabela Clientes
    Qry.SQL.Text := 'CREATE TABLE IF NOT EXISTS clientes (' +
                    'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                    'nome VARCHAR(100) NOT NULL, ' +
                    'telefone VARCHAR(20), ' +
                    'email VARCHAR(100), ' +
                    'cidade VARCHAR(60), ' +
                    'documento VARCHAR(20));';
    Qry.ExecSQL;

    // Tabela Produtos
    Qry.SQL.Text := 'CREATE TABLE IF NOT EXISTS produtos (' +
                    'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                    'nome VARCHAR(100) NOT NULL, ' +
                    'descricao VARCHAR(200), ' +
                    'preco REAL NOT NULL, ' +
                    'estoque INTEGER DEFAULT 0, ' +
                    'imagem VARCHAR(100));';
    Qry.ExecSQL;

    // Tabela Pedidos
    Qry.SQL.Text := 'CREATE TABLE IF NOT EXISTS pedidos (' +
                    'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                    'cliente_id INTEGER NOT NULL REFERENCES clientes(id), ' +
                    'data_pedido DATETIME DEFAULT CURRENT_TIMESTAMP, ' +
                    'valor_total REAL DEFAULT 0, ' +
                    'status VARCHAR(20) DEFAULT ''Pendente'');';
    Qry.ExecSQL;

    // Tabela Itens de Pedidos
    Qry.SQL.Text := 'CREATE TABLE IF NOT EXISTS itens_pedidos (' +
                    'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
                    'pedido_id INTEGER NOT NULL REFERENCES pedidos(id), ' +
                    'produto_id INTEGER NOT NULL REFERENCES produtos(id), ' +
                    'quantidade INTEGER NOT NULL, ' +
                    'valor_unitario REAL NOT NULL, ' +
                    'subtotal REAL NOT NULL);';
    Qry.ExecSQL;

    // Dados Iniciais
    Qry.SQL.Text := 'INSERT OR IGNORE INTO usuarios (id, nome, login, senha, nivel) VALUES ' +
                    '(1, ''Administrador'', ''admin'', ''1234'', ''admin''), ' +
                    '(2, ''Vendedor Teste'', ''vendedor'', ''1234'', ''user'');';
    Qry.ExecSQL;

    Qry.SQL.Text := 'INSERT OR IGNORE INTO clientes (id, nome, telefone, email, cidade, documento) VALUES ' +
                    '(1, ''Mercado São José'', ''(11) 98765-4321'', ''contato@saojose.com'', ''São Paulo'', ''12.345.678/0001-90''), ' +
                    '(2, ''Padaria Pão de Mel'', ''(11) 97654-3210'', ''paodemel@gmail.com'', ''Campinas'', ''98.765.432/0001-10''), ' +
                    '(3, ''Supermercado Estrela'', ''(19) 99123-4567'', ''compras@estrela.com.br'', ''Piracicaba'', ''45.678.901/0001-23'');';
    Qry.ExecSQL;

    Qry.SQL.Text := 'INSERT OR IGNORE INTO produtos (id, nome, descricao, preco, estoque, imagem) VALUES ' +
                    '(1, ''Coca-Cola Lata 350ml'', ''Refrigerante de cola lata'', 5.00, 120, ''coca_cola.jpg''), ' +
                    '(2, ''Nescal 500mg'', ''Achocolatado em pó instantâneo'', 7.00, 50, ''nescau.jpg''), ' +
                    '(3, ''Arroz Kicaldo 5kg'', ''Arroz branco tipo 1 nobre'', 28.50, 80, ''arroz_kicaldo.jpg''), ' +
                    '(4, ''Feijão Preto Kicaldo 1kg'', ''Feijão preto carioca selecionado'', 8.90, 65, ''feijao_kikaldo.jpg''), ' +
                    '(5, ''Açúcar União 1kg'', ''Açúcar refinado especial'', 4.80, 100, ''açucar unicao.jpg'');';
    Qry.ExecSQL;

    Qry.SQL.Text := 'INSERT OR IGNORE INTO pedidos (id, cliente_id, data_pedido, valor_total, status) VALUES ' +
                    '(1, 1, ''2026-10-05 14:30:00'', 58.50, ''Concluído''), ' +
                    '(2, 2, ''2026-10-05 16:15:00'', 35.00, ''Em Andamento''), ' +
                    '(3, 3, ''2026-10-05 17:00:00'', 142.50, ''Pendente'');';
    Qry.ExecSQL;

    FTran.Commit;
  finally
    Qry.Free;
  end;
end;

procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  FConn := TSQLite3Connection.Create(Self);
  FTran := TSQLTransaction.Create(Self);

  FConn.Transaction := FTran;
  FTran.DataBase := FConn;

  {$IFDEF ANDROID}
  FConn.HostName := '';
  {$ENDIF}

  FConn.DatabaseName := ObterCaminhoBanco;
  try
    FConn.Open;
    CriarTabelasSeNecessario;
  except
    on E: Exception do
      ;
  end;
end;

procedure TDataModule1.DataModuleDestroy(Sender: TObject);
begin
  if Assigned(FConn) and FConn.Connected then
  begin
    if Assigned(FTran) and FTran.Active then
      FTran.Commit;
    FConn.Close;
  end;
end;

function TDataModule1.ValidarLogin(const ALogin, ASenha: string; out ANome: string; out ANivel: string): Boolean;
var
  Qry: TSQLQuery;
begin
  Result := False;
  ANome := '';
  ANivel := '';

  if not Assigned(FConn) or not FConn.Connected then
  begin
    if ((Trim(ALogin) = 'admin') and (Trim(ASenha) = '1234')) or
       ((Trim(ALogin) = 'vendedor') and (Trim(ASenha) = '1234')) then
    begin
      ANome := 'Administrador';
      ANivel := 'admin';
      Result := True;
    end;
    Exit;
  end;

  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    Qry.SQL.Text := 'SELECT nome, nivel FROM usuarios WHERE LOWER(login) = LOWER(:login) AND senha = :senha LIMIT 1;';
    Qry.Params.ParamByName('login').AsString := Trim(ALogin);
    Qry.Params.ParamByName('senha').AsString := Trim(ASenha);
    Qry.Open;
    if not Qry.EOF then
    begin
      ANome := Qry.FieldByName('nome').AsString;
      ANivel := Qry.FieldByName('nivel').AsString;
      Result := True;
    end;
    Qry.Close;
  finally
    Qry.Free;
  end;
end;

procedure TDataModule1.CarregarProdutos(AListView: TLazDroidListView; const AFiltro: string);
var
  Qry: TSQLQuery;
  Item: TLazDroidListItem;
begin
  if not Assigned(AListView) then Exit;
  AListView.Clear;

  if not Assigned(FConn) or not FConn.Connected then
  begin
    with AListView.AddItem('Coca-Cola Lata 350ml', 'Refrigerante de cola', 'R$ 5,00') do Icon := aiCart;
    with AListView.AddItem('Nescal 500mg', 'Achocolatado instantâneo', 'R$ 7,00') do Icon := aiCart;
    with AListView.AddItem('Arroz Kicaldo 5kg', 'Arroz branco tipo 1', 'R$ 28,50') do Icon := aiCart;
    Exit;
  end;

  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    if Trim(AFiltro) <> '' then
    begin
      Qry.SQL.Text := 'SELECT * FROM produtos WHERE LOWER(nome) LIKE :filtro ORDER BY nome;';
      Qry.Params.ParamByName('filtro').AsString := '%' + LowerCase(Trim(AFiltro)) + '%';
    end
    else
      Qry.SQL.Text := 'SELECT * FROM produtos ORDER BY nome;';

    Qry.Open;
    while not Qry.EOF do
    begin
      Item := AListView.AddItem(
        Qry.FieldByName('nome').AsString,
        Qry.FieldByName('descricao').AsString,
        Format('R$ %.2f', [Qry.FieldByName('preco').AsFloat])
      );
      Item.Icon := aiCart;
      Item.Badge := Format('Est: %d', [Qry.FieldByName('estoque').AsInteger]);
      Item.Tag := Qry.FieldByName('id').AsInteger;
      Qry.Next;
    end;
    Qry.Close;
  finally
    Qry.Free;
  end;
end;

procedure TDataModule1.CarregarClientes(AListView: TLazDroidListView; const AFiltro: string);
var
  Qry: TSQLQuery;
  Item: TLazDroidListItem;
begin
  if not Assigned(AListView) then Exit;
  AListView.Clear;

  if not Assigned(FConn) or not FConn.Connected then
  begin
    with AListView.AddItem('Mercado São José', 'São Paulo - (11) 98765-4321', 'CNPJ') do Icon := aiUser;
    with AListView.AddItem('Padaria Pão de Mel', 'Campinas - (11) 97654-3210', 'CNPJ') do Icon := aiUser;
    Exit;
  end;

  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    if Trim(AFiltro) <> '' then
    begin
      Qry.SQL.Text := 'SELECT * FROM clientes WHERE LOWER(nome) LIKE :filtro OR LOWER(cidade) LIKE :filtro ORDER BY nome;';
      Qry.Params.ParamByName('filtro').AsString := '%' + LowerCase(Trim(AFiltro)) + '%';
    end
    else
      Qry.SQL.Text := 'SELECT * FROM clientes ORDER BY nome;';

    Qry.Open;
    while not Qry.EOF do
    begin
      Item := AListView.AddItem(
        Qry.FieldByName('nome').AsString,
        Qry.FieldByName('cidade').AsString + ' • ' + Qry.FieldByName('telefone').AsString,
        Qry.FieldByName('documento').AsString
      );
      Item.Icon := aiUser;
      Item.Tag := Qry.FieldByName('id').AsInteger;
      Qry.Next;
    end;
    Qry.Close;
  finally
    Qry.Free;
  end;
end;

procedure TDataModule1.CarregarPedidos(AListView: TLazDroidListView; const AFiltro: string);
var
  Qry: TSQLQuery;
  Item: TLazDroidListItem;
begin
  if not Assigned(AListView) then Exit;
  AListView.Clear;

  if not Assigned(FConn) or not FConn.Connected then
  begin
    with AListView.AddItem('Pedido #001', 'Mercado São José • 05/10/2026', 'R$ 58,50') do Icon := aiDollar;
    Exit;
  end;

  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    Qry.SQL.Text := 'SELECT p.id, c.nome as cliente_nome, p.data_pedido, p.valor_total, p.status ' +
                    'FROM pedidos p ' +
                    'JOIN clientes c ON c.id = p.cliente_id ' +
                    'ORDER BY p.id DESC;';
    Qry.Open;
    while not Qry.EOF do
    begin
      Item := AListView.AddItem(
        Format('Pedido #%03d - %s', [Qry.FieldByName('id').AsInteger, Qry.FieldByName('cliente_nome').AsString]),
        Qry.FieldByName('data_pedido').AsString,
        Format('R$ %.2f', [Qry.FieldByName('valor_total').AsFloat])
      );
      Item.Icon := aiDollar;
      Item.Badge := Qry.FieldByName('status').AsString;
      Item.Tag := Qry.FieldByName('id').AsInteger;
      Qry.Next;
    end;
    Qry.Close;
  finally
    Qry.Free;
  end;
end;

end.
