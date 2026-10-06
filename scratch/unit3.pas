unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  LazDroidMobileControls, Unit4;

type

  { TForm2 }

  TForm2 = class(TForm)
    ImageList1: TImageList;
    LazDroidAppBar1: TLazDroidAppBar;
    LazDroidBottomNav1: TLazDroidBottomNav;
    LazDroidButton1: TLazDroidButton;
    LazDroidEdit1: TLazDroidEdit;
    LazDroidListView1: TLazDroidListView;
    Panel1: TPanel;
    Panel2: TPanel;
    procedure FormShow(Sender: TObject);
    procedure LazDroidAppBar1ActionClick(Sender: TObject);
    procedure LazDroidAppBar1BackClick(Sender: TObject);
    procedure LazDroidBottomNav1TabSelected(Sender: TObject; AIndex: Integer);
    procedure LazDroidButton1Click(Sender: TObject);
    procedure LazDroidListView1ItemClick(Sender: TObject; AIndex: Integer);
  private

  public

  end;

var
  Form2: TForm2;

implementation

uses
  Unit1;

{$R *.lfm}

{ TForm2 }

procedure TForm2.FormShow(Sender: TObject);
begin
  LazDroidBottomNav1.ActiveIndex := 0;
  LazDroidBottomNav1TabSelected(LazDroidBottomNav1, 0);
end;

procedure TForm2.LazDroidAppBar1ActionClick(Sender: TObject);
begin
  ShowMessage('Menu de ações rápidas');
end;

procedure TForm2.LazDroidAppBar1BackClick(Sender: TObject);
begin
  // Se estiver em outra aba, volta para Início
  if LazDroidBottomNav1.ActiveIndex <> 0 then
  begin
    LazDroidBottomNav1.ActiveIndex := 0;
    LazDroidBottomNav1TabSelected(LazDroidBottomNav1, 0);
  end
  else
  begin
    // Na aba Início, realiza Logout e volta para Login
    if Assigned(Form1) then
    begin
      Form1.Show;
      Self.Hide;
    end;
  end;
end;

procedure TForm2.LazDroidBottomNav1TabSelected(Sender: TObject; AIndex: Integer);
begin
  case AIndex of
    0: // Início / Produtos
    begin
      LazDroidAppBar1.Title := 'Início / Produtos';
      LazDroidAppBar1.Subtitle := 'Catálogo de Itens';
      LazDroidEdit1.Text := '';
      LazDroidEdit1.Placeholder := 'Pesquisar produto...';
      Panel2.Visible := True;
      if Assigned(DataModule1) then
        DataModule1.CarregarProdutos(LazDroidListView1);
    end;

    1: // Pedidos
    begin
      LazDroidAppBar1.Title := 'Pedidos';
      LazDroidAppBar1.Subtitle := 'Histórico e Vendas';
      LazDroidEdit1.Text := '';
      LazDroidEdit1.Placeholder := 'Pesquisar pedido...';
      Panel2.Visible := True;
      if Assigned(DataModule1) then
        DataModule1.CarregarPedidos(LazDroidListView1);
    end;

    2: // Clientes
    begin
      LazDroidAppBar1.Title := 'Clientes';
      LazDroidAppBar1.Subtitle := 'Carteira de Clientes';
      LazDroidEdit1.Text := '';
      LazDroidEdit1.Placeholder := 'Pesquisar cliente...';
      Panel2.Visible := True;
      if Assigned(DataModule1) then
        DataModule1.CarregarClientes(LazDroidListView1);
    end;

    3: // Ajustes
    begin
      LazDroidAppBar1.Title := 'Ajustes & Sistema';
      LazDroidAppBar1.Subtitle := 'Configurações e Logout';
      Panel2.Visible := False;
      LazDroidListView1.Clear;
      with LazDroidListView1.AddItem('Usuário Conectado', 'Administrador (Nível: admin)', 'Online') do
        Icon := aiUser;
      with LazDroidListView1.AddItem('Banco de Dados SQLite', 'database/app.db', 'Conectado') do
        Icon := aiCheck;
      with LazDroidListView1.AddItem('Tabelas Ativas', 'usuarios, clientes, produtos, pedidos, itens', '5 Tabelas') do
        Icon := aiCheck;
      with LazDroidListView1.AddItem('Sincronização', 'Armazenamento local persistente', 'OK') do
        Icon := aiStar;
      with LazDroidListView1.AddItem('Desconectar / Sair', 'Toque para encerrar a sessão', 'Sair') do
        Icon := aiClose;
    end;
  end;
end;

procedure TForm2.LazDroidButton1Click(Sender: TObject);
var
  Termo: string;
begin
  Termo := Trim(LazDroidEdit1.Text);
  case LazDroidBottomNav1.ActiveIndex of
    0: if Assigned(DataModule1) then DataModule1.CarregarProdutos(LazDroidListView1, Termo);
    1: if Assigned(DataModule1) then DataModule1.CarregarPedidos(LazDroidListView1, Termo);
    2: if Assigned(DataModule1) then DataModule1.CarregarClientes(LazDroidListView1, Termo);
  end;
end;

procedure TForm2.LazDroidListView1ItemClick(Sender: TObject; AIndex: Integer);
var
  Item: TLazDroidListItem;
begin
  if (AIndex >= 0) and (AIndex < LazDroidListView1.Items.Count) then
  begin
    Item := LazDroidListView1.Items[AIndex];
    if (LazDroidBottomNav1.ActiveIndex = 3) and (Item.Value = 'Sair') then
    begin
      LazDroidAppBar1BackClick(nil);
    end
    else
    begin
      ShowMessage('Selecionado: ' + Item.Title + sLineBreak + Item.Subtitle + ' ' + Item.Value);
    end;
  end;
end;

end.
