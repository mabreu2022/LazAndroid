program MakeDb;
{$mode objfpc}{$H+}
uses
  SysUtils, sqlite3conn, sqldb;
var
  Conn: TSQLite3Connection;
  Tran: TSQLTransaction;
  Qry: TSQLQuery;
begin
  Writeln('Creating database...');
  Conn := TSQLite3Connection.Create(nil);
  Tran := TSQLTransaction.Create(nil);
  Qry := TSQLQuery.Create(nil);
  try
    Conn.DatabaseName := 'd:\Fontes Lazarus\Teste LazDroid\database\app.db';
    Conn.Transaction := Tran;
    Tran.DataBase := Conn;
    Qry.DataBase := Conn;
    Qry.Transaction := Tran;
    
    ForceDirectories('d:\Fontes Lazarus\Teste LazDroid\database');
    Conn.Open;
    Tran.StartTransaction;
    
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

    // Inserir Usuario Admin e Teste
    Qry.SQL.Text := 'INSERT OR IGNORE INTO usuarios (id, nome, login, senha, nivel) VALUES ' +
                    '(1, ''Administrador'', ''admin'', ''1234'', ''admin''), ' +
                    '(2, ''Vendedor Teste'', ''vendedor'', ''1234'', ''user'');';
    Qry.ExecSQL;

    // Inserir Clientes
    Qry.SQL.Text := 'INSERT OR IGNORE INTO clientes (id, nome, telefone, email, cidade, documento) VALUES ' +
                    '(1, ''Mercado São José'', ''(11) 98765-4321'', ''contato@saojose.com'', ''São Paulo'', ''12.345.678/0001-90''), ' +
                    '(2, ''Padaria Pão de Mel'', ''(11) 97654-3210'', ''paodemel@gmail.com'', ''Campinas'', ''98.765.432/0001-10''), ' +
                    '(3, ''Supermercado Estrela'', ''(19) 99123-4567'', ''compras@estrela.com.br'', ''Piracicaba'', ''45.678.901/0001-23'');';
    Qry.ExecSQL;

    // Inserir Produtos
    Qry.SQL.Text := 'INSERT OR IGNORE INTO produtos (id, nome, descricao, preco, estoque, imagem) VALUES ' +
                    '(1, ''Coca-Cola Lata 350ml'', ''Refrigerante de cola lata'', 5.00, 120, ''coca_cola.jpg''), ' +
                    '(2, ''Nescal 500mg'', ''Achocolatado em pó instantâneo'', 7.00, 50, ''nescau.jpg''), ' +
                    '(3, ''Arroz Kicaldo 5kg'', ''Arroz branco tipo 1 nobre'', 28.50, 80, ''arroz_kicaldo.jpg''), ' +
                    '(4, ''Feijão Preto Kicaldo 1kg'', ''Feijão preto carioca selecionado'', 8.90, 65, ''feijao_kikaldo.jpg''), ' +
                    '(5, ''Açúcar União 1kg'', ''Açúcar refinado especial'', 4.80, 100, ''açucar unicao.jpg'');';
    Qry.ExecSQL;

    // Inserir Pedidos de teste
    Qry.SQL.Text := 'INSERT OR IGNORE INTO pedidos (id, cliente_id, data_pedido, valor_total, status) VALUES ' +
                    '(1, 1, ''2026-10-05 14:30:00'', 58.50, ''Concluído''), ' +
                    '(2, 2, ''2026-10-05 16:15:00'', 35.00, ''Em Andamento''), ' +
                    '(3, 3, ''2026-10-05 17:00:00'', 142.50, ''Pendente'');';
    Qry.ExecSQL;

    // Inserir Itens do Pedido 1
    Qry.SQL.Text := 'INSERT OR IGNORE INTO itens_pedidos (id, pedido_id, produto_id, quantidade, valor_unitario, subtotal) VALUES ' +
                    '(1, 1, 1, 2, 5.00, 10.00), ' +
                    '(2, 1, 3, 1, 28.50, 28.50), ' +
                    '(3, 1, 2, 2, 7.00, 14.00), ' +
                    '(4, 1, 5, 1, 4.80, 4.80), ' +
                    '(5, 2, 2, 5, 7.00, 35.00);';
    Qry.ExecSQL;

    Tran.Commit;
    Writeln('Database created successfully at: ' + Conn.DatabaseName);
  finally
    Qry.Free;
    Tran.Free;
    Conn.Free;
  end;
end.
