unit Unit4;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, sqldb, sqlite3conn, sqlite3dyn, LazDroidMobileControls
  {$IFDEF ANDROID}, BaseUnix, ctypes{$ENDIF};

type
  TClienteRecord = record
    Id: Integer;
    Nome: string;
    Telefone: string;
    Email: string;
    Cidade: string;
    Documento: string;
  end;

  { TDataModule1 }

  TDataModule1 = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FConn: TSQLite3Connection;
    FTran: TSQLTransaction;
    FMemClientes: array of TClienteRecord;
    FNextMemId: Integer;
    procedure InicializarClientesMemoria;
    function ObterCaminhoBanco: string;
    procedure CriarTabelasSeNecessario;
  public
    function ValidarLogin(const ALogin, ASenha: string; out ANome: string; out ANivel: string): Boolean;
    procedure CarregarProdutos(AListView: TLazDroidListView; const AFiltro: string = '');
    procedure CarregarClientes(AListView: TLazDroidListView; const AFiltro: string = '');
    procedure CarregarPedidos(AListView: TLazDroidListView; const AFiltro: string = '');
    function ObterClientePorId(AId: Integer; out ANome, ATelefone, AEmail, ACidade, ADocumento: string): Boolean;
    function SalvarCliente(var AId: Integer; const ANome, ATelefone, AEmail, ACidade, ADocumento: string): Boolean;
    function ExcluirCliente(AId: Integer): Boolean;
    function TotalClientes: Integer;
  end;

var
  DataModule1: TDataModule1;

procedure DLog(const S: string);

implementation

{$IFDEF ANDROID}
function android_log_write(prio: Integer; tag, text: PChar): Integer; cdecl; external 'log' name '__android_log_write';
{$ENDIF}

procedure DLog(const S: string);
begin
  {$IFDEF ANDROID}
  android_log_write(4, 'DEMO5', PChar(S));
  {$ENDIF}
end;

{$IFDEF ANDROID}
procedure CrashHandler(Sig: cint); cdecl;
var
  Fp, Addr: Pointer;
  i: Integer;
begin
  DLog('CRASH sig=' + IntToStr(Sig) + ' DLog@' + IntToHex(PtrUInt(@DLog), 1));
  Fp := get_frame;
  for i := 0 to 20 do
  begin
    if (Fp = nil) or (PtrUInt(Fp) < $10000) then Break;
    Addr := get_caller_addr(Fp);
    DLog('  BT#' + IntToStr(i) + ' ' + IntToHex(PtrUInt(Addr), 1));
    Fp := get_caller_frame(Fp);
  end;
  Halt(1);
end;

procedure InstalarCrashHandler;
var
  Act: SigActionRec;
begin
  FillChar(Act, SizeOf(Act), 0);
  Act.sa_handler := SigActionHandler(@CrashHandler);
  fpsigaction(SIGBUS, @Act, nil);
  fpsigaction(SIGSEGV, @Act, nil);
end;
{$ENDIF}

{$R *.lfm}

{ TDataModule1 }

procedure TDataModule1.InicializarClientesMemoria;
begin
  SetLength(FMemClientes, 4);
  FMemClientes[0].Id := 1;
  FMemClientes[0].Nome := 'Mercado São José';
  FMemClientes[0].Telefone := '(11) 98765-4321';
  FMemClientes[0].Email := 'contato@saojose.com.br';
  FMemClientes[0].Cidade := 'São Paulo - SP';
  FMemClientes[0].Documento := '12.345.678/0001-90';

  FMemClientes[1].Id := 2;
  FMemClientes[1].Nome := 'Padaria Pão de Mel';
  FMemClientes[1].Telefone := '(19) 97654-3210';
  FMemClientes[1].Email := 'paodemel@gmail.com';
  FMemClientes[1].Cidade := 'Campinas - SP';
  FMemClientes[1].Documento := '98.765.432/0001-10';

  FMemClientes[2].Id := 3;
  FMemClientes[2].Nome := 'Supermercado Estrela';
  FMemClientes[2].Telefone := '(19) 99123-4567';
  FMemClientes[2].Email := 'compras@estrela.com.br';
  FMemClientes[2].Cidade := 'Piracicaba - SP';
  FMemClientes[2].Documento := '45.678.901/0001-23';

  FMemClientes[3].Id := 4;
  FMemClientes[3].Nome := 'Distribuidora Horizonte';
  FMemClientes[3].Telefone := '(21) 99888-1122';
  FMemClientes[3].Email := 'vendas@horizonte.com.br';
  FMemClientes[3].Cidade := 'Rio de Janeiro - RJ';
  FMemClientes[3].Documento := '33.444.555/0001-66';

  FNextMemId := 5;
end;

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
                    '(1, ''Mercado São José'', ''(11) 98765-4321'', ''contato@saojose.com.br'', ''São Paulo - SP'', ''12.345.678/0001-90''), ' +
                    '(2, ''Padaria Pão de Mel'', ''(19) 97654-3210'', ''paodemel@gmail.com'', ''Campinas - SP'', ''98.765.432/0001-10''), ' +
                    '(3, ''Supermercado Estrela'', ''(19) 99123-4567'', ''compras@estrela.com.br'', ''Piracicaba - SP'', ''45.678.901/0001-23''), ' +
                    '(4, ''Distribuidora Horizonte'', ''(21) 99888-1122'', ''vendas@horizonte.com.br'', ''Rio de Janeiro - RJ'', ''33.444.555/0001-66'');';
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
  InicializarClientesMemoria;
  {$IFDEF ANDROID}
  SQLiteDefaultLibrary := 'libsqlite.so';
  {$ENDIF}
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
    begin
      {$IFDEF ANDROID}
      try
        SQLiteDefaultLibrary := 'libsqlite3.so';
        FConn.Open;
        CriarTabelasSeNecessario;
      except
        on E2: Exception do ;
      end;
      {$ENDIF}
    end;
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
    if ((LowerCase(Trim(ALogin)) = 'admin') and (Trim(ASenha) = '1234')) or
       ((LowerCase(Trim(ALogin)) = 'vendedor') and (Trim(ASenha) = '1234')) then
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
    with AListView.AddItem('Coca-Cola Lata 350ml', 'Refrigerante de cola', 'R$ 5,00') do
    begin
      Icon := aiCart;
      Badge := 'Est: 120';
    end;
    with AListView.AddItem('Nescal 500mg', 'Achocolatado instantâneo', 'R$ 7,00') do
    begin
      Icon := aiCart;
      Badge := 'Est: 50';
    end;
    with AListView.AddItem('Arroz Kicaldo 5kg', 'Arroz branco tipo 1', 'R$ 28,50') do
    begin
      Icon := aiCart;
      Badge := 'Est: 80';
    end;
    with AListView.AddItem('Feijão Preto Kicaldo 1kg', 'Feijão preto carioca', 'R$ 8,90') do
    begin
      Icon := aiCart;
      Badge := 'Est: 65';
    end;
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
  I: Integer;
  FiltroLow: string;
begin
  if not Assigned(AListView) then Exit;
  AListView.Clear;
  FiltroLow := LowerCase(Trim(AFiltro));

  if not Assigned(FConn) or not FConn.Connected then
  begin
    for I := 0 to High(FMemClientes) do
    begin
      if (FiltroLow = '') or
         (Pos(FiltroLow, LowerCase(FMemClientes[I].Nome)) > 0) or
         (Pos(FiltroLow, LowerCase(FMemClientes[I].Cidade)) > 0) or
         (Pos(FiltroLow, LowerCase(FMemClientes[I].Documento)) > 0) then
      begin
        Item := AListView.AddItem(
          FMemClientes[I].Nome,
          FMemClientes[I].Cidade + ' • ' + FMemClientes[I].Telefone,
          FMemClientes[I].Documento
        );
        Item.Icon := aiUser;
        Item.Badge := Format('#%d', [FMemClientes[I].Id]);
        Item.Tag := FMemClientes[I].Id;
      end;
    end;
    Exit;
  end;

  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    if FiltroLow <> '' then
    begin
      Qry.SQL.Text := 'SELECT * FROM clientes WHERE LOWER(nome) LIKE :filtro OR LOWER(cidade) LIKE :filtro OR LOWER(documento) LIKE :filtro ORDER BY id DESC;';
      Qry.Params.ParamByName('filtro').AsString := '%' + FiltroLow + '%';
    end
    else
      Qry.SQL.Text := 'SELECT * FROM clientes ORDER BY id DESC;';

    Qry.Open;
    while not Qry.EOF do
    begin
      Item := AListView.AddItem(
        Qry.FieldByName('nome').AsString,
        Qry.FieldByName('cidade').AsString + ' • ' + Qry.FieldByName('telefone').AsString,
        Qry.FieldByName('documento').AsString
      );
      Item.Icon := aiUser;
      Item.Badge := Format('#%d', [Qry.FieldByName('id').AsInteger]);
      Item.Tag := Qry.FieldByName('id').AsInteger;
      Qry.Next;
    end;
    Qry.Close;
  finally
    Qry.Free;
  end;
end;

function TDataModule1.ObterClientePorId(AId: Integer; out ANome, ATelefone, AEmail, ACidade, ADocumento: string): Boolean;
var
  Qry: TSQLQuery;
  I: Integer;
begin
  Result := False;
  ANome := '';
  ATelefone := '';
  AEmail := '';
  ACidade := '';
  ADocumento := '';

  if not Assigned(FConn) or not FConn.Connected then
  begin
    for I := 0 to High(FMemClientes) do
      if FMemClientes[I].Id = AId then
      begin
        ANome := FMemClientes[I].Nome;
        ATelefone := FMemClientes[I].Telefone;
        AEmail := FMemClientes[I].Email;
        ACidade := FMemClientes[I].Cidade;
        ADocumento := FMemClientes[I].Documento;
        Exit(True);
      end;
    Exit;
  end;

  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    Qry.SQL.Text := 'SELECT * FROM clientes WHERE id = :id LIMIT 1;';
    Qry.Params.ParamByName('id').AsInteger := AId;
    Qry.Open;
    if not Qry.EOF then
    begin
      ANome := Qry.FieldByName('nome').AsString;
      ATelefone := Qry.FieldByName('telefone').AsString;
      AEmail := Qry.FieldByName('email').AsString;
      ACidade := Qry.FieldByName('cidade').AsString;
      ADocumento := Qry.FieldByName('documento').AsString;
      Result := True;
    end;
    Qry.Close;
  finally
    Qry.Free;
  end;
end;

function TDataModule1.SalvarCliente(var AId: Integer; const ANome, ATelefone, AEmail, ACidade, ADocumento: string): Boolean;
var
  Qry: TSQLQuery;
  I, Len: Integer;
begin
  Result := False;
  if Trim(ANome) = '' then Exit;

  // Atualiza também lista em memória como espelho
  if AId <= 0 then
  begin
    Len := Length(FMemClientes);
    SetLength(FMemClientes, Len + 1);
    FMemClientes[Len].Id := FNextMemId;
    FMemClientes[Len].Nome := Trim(ANome);
    FMemClientes[Len].Telefone := Trim(ATelefone);
    FMemClientes[Len].Email := Trim(AEmail);
    FMemClientes[Len].Cidade := Trim(ACidade);
    FMemClientes[Len].Documento := Trim(ADocumento);
    if not Assigned(FConn) or not FConn.Connected then
    begin
      AId := FNextMemId;
      Inc(FNextMemId);
      Exit(True);
    end;
    Inc(FNextMemId);
  end
  else
  begin
    for I := 0 to High(FMemClientes) do
      if FMemClientes[I].Id = AId then
      begin
        FMemClientes[I].Nome := Trim(ANome);
        FMemClientes[I].Telefone := Trim(ATelefone);
        FMemClientes[I].Email := Trim(AEmail);
        FMemClientes[I].Cidade := Trim(ACidade);
        FMemClientes[I].Documento := Trim(ADocumento);
        Break;
      end;
    if not Assigned(FConn) or not FConn.Connected then
      Exit(True);
  end;

  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    if not FTran.Active then
      FTran.StartTransaction;

    if AId <= 0 then
    begin
      Qry.SQL.Text := 'INSERT INTO clientes (nome, telefone, email, cidade, documento) ' +
                      'VALUES (:nome, :telefone, :email, :cidade, :documento);';
      Qry.Params.ParamByName('nome').AsString := Trim(ANome);
      Qry.Params.ParamByName('telefone').AsString := Trim(ATelefone);
      Qry.Params.ParamByName('email').AsString := Trim(AEmail);
      Qry.Params.ParamByName('cidade').AsString := Trim(ACidade);
      Qry.Params.ParamByName('documento').AsString := Trim(ADocumento);
      Qry.ExecSQL;
      FTran.Commit;

      Qry.SQL.Text := 'SELECT last_insert_rowid() AS novo_id;';
      Qry.Open;
      if not Qry.EOF then
        AId := Qry.FieldByName('novo_id').AsInteger;
      Qry.Close;
    end
    else
    begin
      Qry.SQL.Text := 'UPDATE clientes SET nome = :nome, telefone = :telefone, ' +
                      'email = :email, cidade = :cidade, documento = :documento ' +
                      'WHERE id = :id;';
      Qry.Params.ParamByName('nome').AsString := Trim(ANome);
      Qry.Params.ParamByName('telefone').AsString := Trim(ATelefone);
      Qry.Params.ParamByName('email').AsString := Trim(AEmail);
      Qry.Params.ParamByName('cidade').AsString := Trim(ACidade);
      Qry.Params.ParamByName('documento').AsString := Trim(ADocumento);
      Qry.Params.ParamByName('id').AsInteger := AId;
      Qry.ExecSQL;
      FTran.Commit;
    end;
    Result := True;
  finally
    Qry.Free;
  end;
end;

function TDataModule1.ExcluirCliente(AId: Integer): Boolean;
var
  Qry: TSQLQuery;
  I, J: Integer;
begin
  Result := False;
  if AId <= 0 then Exit;

  for I := 0 to High(FMemClientes) do
    if FMemClientes[I].Id = AId then
    begin
      for J := I to High(FMemClientes) - 1 do
        FMemClientes[J] := FMemClientes[J + 1];
      SetLength(FMemClientes, Length(FMemClientes) - 1);
      Break;
    end;

  if not Assigned(FConn) or not FConn.Connected then
    Exit(True);

  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    if not FTran.Active then
      FTran.StartTransaction;
    Qry.SQL.Text := 'DELETE FROM clientes WHERE id = :id;';
    Qry.Params.ParamByName('id').AsInteger := AId;
    Qry.ExecSQL;
    FTran.Commit;
    Result := True;
  finally
    Qry.Free;
  end;
end;

function TDataModule1.TotalClientes: Integer;
var
  Qry: TSQLQuery;
begin
  if not Assigned(FConn) or not FConn.Connected then
    Exit(Length(FMemClientes));

  Result := 0;
  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    Qry.SQL.Text := 'SELECT COUNT(*) AS total FROM clientes;';
    Qry.Open;
    if not Qry.EOF then
      Result := Qry.FieldByName('total').AsInteger;
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
    with AListView.AddItem('Pedido #001 - Mercado São José', '05/10/2026 14:30', 'R$ 58,50') do
    begin
      Icon := aiDollar;
      Badge := 'Concluído';
    end;
    with AListView.AddItem('Pedido #002 - Padaria Pão de Mel', '05/10/2026 16:15', 'R$ 35,00') do
    begin
      Icon := aiDollar;
      Badge := 'Em Andamento';
    end;
    Exit;
  end;

  Qry := TSQLQuery.Create(nil);
  try
    Qry.DataBase := FConn;
    Qry.Transaction := FTran;
    Qry.SQL.Text := 'SELECT p.id, c.nome as cliente_nome, p.data_pedido, p.valor_total, p.status ' +
                    'FROM pedidos p ' +
                    'LEFT JOIN clientes c ON c.id = p.cliente_id ' +
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

{$IFDEF ANDROID}
initialization
  InstalarCrashHandler;
{$ENDIF}

end.
