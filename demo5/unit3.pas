unit Unit3;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  LazDroidMobileControls, Unit4;

type

  { TForm2 }

  TForm2 = class(TForm)
    ImageList1: TImageList;
    LazDroidAppBar1: TLazDroidAppBar;
    LazDroidBottomNav1: TLazDroidBottomNav;
    LazDroidButton1: TLazDroidButton;
    LazDroidSearchBar1: TLazDroidSearchBar;
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
    FUsuarioNome: string;
    FUsuarioNivel: string;
    FClienteEditId: Integer;
    FComponentesCriados: Boolean;

    // Botão rápido de Novo Cliente na barra de busca
    btnNovoCliente: TLazDroidButton;

    // Painel de Cadastro CRUD de Clientes
    pnlCadastroCliente: TLazDroidCard;
    edtClienteNome: TLazDroidEdit;
    edtClienteDoc: TLazDroidEdit;
    edtClienteFone: TLazDroidEdit;
    edtClienteEmail: TLazDroidEdit;
    edtClienteCidade: TLazDroidEdit;
    btnSalvarCliente: TLazDroidButton;
    btnExcluirCliente: TLazDroidButton;
    btnVoltarCliente: TLazDroidButton;

    // Menu Lateral (Navigation Drawer)
    pnlDrawer: TLazDroidCard;
    pnlDrawerHeader: TLazDroidCard;
    avDrawerUser: TLazDroidAvatar;
    lblDrawerNome: TLabel;
    lblDrawerSub: TLabel;
    bdgDrawerPerfil: TLazDroidBadge;
    lvDrawerMenu: TLazDroidListView;
    btnFecharDrawer: TLazDroidButton;

    procedure CriarComponentesCRUD;
    procedure AjustarLayoutResponsivo;
    procedure PopularMenuLateral;
    procedure AlternarMenuLateral(AExibir: Boolean);
    procedure AbrirCadastroCliente(AClienteId: Integer);
    procedure FecharCadastroCliente;
    procedure BtnNovoClienteClick(Sender: TObject);
    procedure BtnSalvarClienteClick(Sender: TObject);
    procedure BtnExcluirClienteClick(Sender: TObject);
    procedure BtnVoltarClienteClick(Sender: TObject);
    procedure BtnFecharDrawerClick(Sender: TObject);
    procedure DrawerMenuItemClick(Sender: TObject; AIndex: Integer);
    procedure Panel2Resize(Sender: TObject);
    procedure FormResizeHandler(Sender: TObject);
    procedure SearchBarSearch(Sender: TObject; const ASearchText: string);
  protected
    procedure Loaded; override;
  public
    procedure ConfigurarSessao(const ANome, ANivel: string);
  end;

var
  Form2: TForm2;

implementation

uses
  Unit1;

{$R *.lfm}

{ TForm2 }

procedure TForm2.Loaded;
begin
  inherited Loaded;
  FUsuarioNome := 'Administrador';
  FUsuarioNivel := 'admin';
  CriarComponentesCRUD;
end;

procedure TForm2.ConfigurarSessao(const ANome, ANivel: string);
begin
  if Trim(ANome) <> '' then
    FUsuarioNome := Trim(ANome)
  else
    FUsuarioNome := 'Administrador';

  if Trim(ANivel) <> '' then
    FUsuarioNivel := Trim(ANivel)
  else
    FUsuarioNivel := 'admin';

  DLog('ConfigurarSessao: avatar');
  if Assigned(avDrawerUser) then
    avDrawerUser.FullName := FUsuarioNome;
  DLog('ConfigurarSessao: label');
  if Assigned(lblDrawerNome) then
    lblDrawerNome.Caption := FUsuarioNome;
  DLog('ConfigurarSessao: badge');
  if Assigned(bdgDrawerPerfil) then
    bdgDrawerPerfil.Caption := UpperCase(FUsuarioNivel) + ' • SQLITE';
  DLog('ConfigurarSessao: fim');
end;

procedure TForm2.CriarComponentesCRUD;
begin
  if FComponentesCriados then Exit;
  FComponentesCriados := True;

  Self.OnResize := @FormResizeHandler;
  Panel2.OnResize := @Panel2Resize;
  Panel2.BevelOuter := bvNone;
  Panel2.Color := $00F8FAFC;
  Panel1.BevelOuter := bvNone;

  LazDroidAppBar1.LeftIcon := aiMenu;
  LazDroidAppBar1.ActionIcon := aiPlus;
  LazDroidSearchBar1.Align := alNone;
  LazDroidSearchBar1.OnSearch := @SearchBarSearch;
  LazDroidButton1.Caption := 'Buscar';

  // Botão "+ Novo" ao lado da busca
  btnNovoCliente := TLazDroidButton.Create(Self);
  btnNovoCliente.Parent := Panel2;
  btnNovoCliente.Caption := '+ Novo';
  btnNovoCliente.Variant := bvSuccess;
  btnNovoCliente.Icon := aiPlus;
  btnNovoCliente.Font.Name := 'Segoe UI';
  btnNovoCliente.Font.Height := -16;
  btnNovoCliente.Font.Style := [fsBold];
  btnNovoCliente.OnClick := @BtnNovoClienteClick;

  // Card de Cadastro Completo de Clientes (CRUD)
  pnlCadastroCliente := TLazDroidCard.Create(Self);
  pnlCadastroCliente.Parent := Self;
  pnlCadastroCliente.Visible := False;
  pnlCadastroCliente.ShowHeader := True;
  pnlCadastroCliente.HeaderTitle := 'Novo Cliente (CRUD)';
  pnlCadastroCliente.HeaderColor := $00241A14;
  pnlCadastroCliente.HeaderTextColor := clWhite;
  pnlCadastroCliente.CardColor := clWhite;
  pnlCadastroCliente.CornerRadius := 12;
  pnlCadastroCliente.Font.Name := 'Segoe UI';
  pnlCadastroCliente.Font.Height := -17;
  pnlCadastroCliente.Font.Style := [fsBold];

  edtClienteNome := TLazDroidEdit.Create(Self);
  edtClienteNome.Parent := pnlCadastroCliente;
  edtClienteNome.LabelCaption := 'Nome / Razão Social *';
  edtClienteNome.Placeholder := 'Ex: Supermercado Central Ltda';
  edtClienteNome.Font.Name := 'Segoe UI';
  edtClienteNome.Font.Height := -16;

  edtClienteDoc := TLazDroidEdit.Create(Self);
  edtClienteDoc.Parent := pnlCadastroCliente;
  edtClienteDoc.LabelCaption := 'CPF / CNPJ';
  edtClienteDoc.Placeholder := 'Ex: 12.345.678/0001-90';
  edtClienteDoc.Font.Name := 'Segoe UI';
  edtClienteDoc.Font.Height := -16;

  edtClienteFone := TLazDroidEdit.Create(Self);
  edtClienteFone.Parent := pnlCadastroCliente;
  edtClienteFone.LabelCaption := 'Telefone / WhatsApp';
  edtClienteFone.Placeholder := 'Ex: (11) 98888-7777';
  edtClienteFone.InputKind := ikPhone;
  edtClienteFone.Font.Name := 'Segoe UI';
  edtClienteFone.Font.Height := -16;

  edtClienteEmail := TLazDroidEdit.Create(Self);
  edtClienteEmail.Parent := pnlCadastroCliente;
  edtClienteEmail.LabelCaption := 'E-mail';
  edtClienteEmail.Placeholder := 'Ex: contato@empresa.com.br';
  edtClienteEmail.InputKind := ikEmail;
  edtClienteEmail.Font.Name := 'Segoe UI';
  edtClienteEmail.Font.Height := -16;

  edtClienteCidade := TLazDroidEdit.Create(Self);
  edtClienteCidade.Parent := pnlCadastroCliente;
  edtClienteCidade.LabelCaption := 'Cidade / UF';
  edtClienteCidade.Placeholder := 'Ex: São Paulo - SP';
  edtClienteCidade.Font.Name := 'Segoe UI';
  edtClienteCidade.Font.Height := -16;

  btnSalvarCliente := TLazDroidButton.Create(Self);
  btnSalvarCliente.Parent := pnlCadastroCliente;
  btnSalvarCliente.Caption := 'Salvar';
  btnSalvarCliente.Variant := bvSuccess;
  btnSalvarCliente.Icon := aiCheck;
  btnSalvarCliente.Font.Name := 'Segoe UI';
  btnSalvarCliente.Font.Height := -16;
  btnSalvarCliente.Font.Style := [fsBold];
  btnSalvarCliente.OnClick := @BtnSalvarClienteClick;

  btnExcluirCliente := TLazDroidButton.Create(Self);
  btnExcluirCliente.Parent := pnlCadastroCliente;
  btnExcluirCliente.Caption := 'Excluir';
  btnExcluirCliente.Variant := bvDanger;
  btnExcluirCliente.Icon := aiClose;
  btnExcluirCliente.Font.Name := 'Segoe UI';
  btnExcluirCliente.Font.Height := -16;
  btnExcluirCliente.Font.Style := [fsBold];
  btnExcluirCliente.OnClick := @BtnExcluirClienteClick;

  btnVoltarCliente := TLazDroidButton.Create(Self);
  btnVoltarCliente.Parent := pnlCadastroCliente;
  btnVoltarCliente.Caption := 'Voltar';
  btnVoltarCliente.Variant := bvSecondary;
  btnVoltarCliente.Icon := aiBack;
  btnVoltarCliente.Font.Name := 'Segoe UI';
  btnVoltarCliente.Font.Height := -16;
  btnVoltarCliente.Font.Style := [fsBold];
  btnVoltarCliente.OnClick := @BtnVoltarClienteClick;

  // Menu Lateral (Navigation Drawer)
  pnlDrawer := TLazDroidCard.Create(Self);
  pnlDrawer.Parent := Self;
  pnlDrawer.Visible := False;
  pnlDrawer.ShowHeader := False;
  pnlDrawer.CardColor := clWhite;
  pnlDrawer.BorderColor := $00CBD5E1;
  pnlDrawer.CornerRadius := 0;

  pnlDrawerHeader := TLazDroidCard.Create(Self);
  pnlDrawerHeader.Parent := pnlDrawer;
  pnlDrawerHeader.ShowHeader := False;
  pnlDrawerHeader.CardColor := $00241A14;
  pnlDrawerHeader.BorderColor := $00241A14;
  pnlDrawerHeader.CornerRadius := 0;

  avDrawerUser := TLazDroidAvatar.Create(Self);
  avDrawerUser.Parent := pnlDrawerHeader;
  avDrawerUser.FullName := FUsuarioNome;
  avDrawerUser.ShowStatus := True;
  avDrawerUser.IsOnline := True;
  avDrawerUser.Font.Name := 'Segoe UI';
  avDrawerUser.Font.Height := -18;
  avDrawerUser.Font.Style := [fsBold];

  lblDrawerNome := TLabel.Create(Self);
  lblDrawerNome.Parent := pnlDrawerHeader;
  lblDrawerNome.Caption := FUsuarioNome;
  lblDrawerNome.Font.Name := 'Segoe UI';
  lblDrawerNome.Font.Height := -17;
  lblDrawerNome.Font.Style := [fsBold];
  lblDrawerNome.Font.Color := clWhite;
  lblDrawerNome.ParentColor := False;

  lblDrawerSub := TLabel.Create(Self);
  lblDrawerSub.Parent := pnlDrawerHeader;
  lblDrawerSub.Caption := 'Gestão Comercial & Clientes';
  lblDrawerSub.Font.Name := 'Segoe UI';
  lblDrawerSub.Font.Height := -13;
  lblDrawerSub.Font.Color := $00D0C0B0;
  lblDrawerSub.ParentColor := False;

  bdgDrawerPerfil := TLazDroidBadge.Create(Self);
  bdgDrawerPerfil.Parent := pnlDrawerHeader;
  bdgDrawerPerfil.Caption := 'ADMIN • SQLITE';
  bdgDrawerPerfil.Style := bsSuccess;
  bdgDrawerPerfil.Font.Name := 'Segoe UI';
  bdgDrawerPerfil.Font.Height := -12;

  lvDrawerMenu := TLazDroidListView.Create(Self);
  lvDrawerMenu.Parent := pnlDrawer;
  lvDrawerMenu.Font.Name := 'Segoe UI';
  lvDrawerMenu.Font.Height := -16;
  lvDrawerMenu.ItemHeight := 60;
  lvDrawerMenu.OnItemClick := @DrawerMenuItemClick;

  btnFecharDrawer := TLazDroidButton.Create(Self);
  btnFecharDrawer.Parent := pnlDrawer;
  btnFecharDrawer.Caption := 'Fechar Menu Lateral';
  btnFecharDrawer.Variant := bvSecondary;
  btnFecharDrawer.Icon := aiClose;
  btnFecharDrawer.Font.Name := 'Segoe UI';
  btnFecharDrawer.Font.Height := -15;
  btnFecharDrawer.Font.Style := [fsBold];
  btnFecharDrawer.OnClick := @BtnFecharDrawerClick;

  PopularMenuLateral;
  AjustarLayoutResponsivo;
end;

procedure TForm2.PopularMenuLateral;
var
  TotalCli: Integer;
begin
  if not Assigned(lvDrawerMenu) then Exit;
  TotalCli := 4;
  if Assigned(DataModule1) then
    TotalCli := DataModule1.TotalClientes;

  lvDrawerMenu.Clear;
  with lvDrawerMenu.AddItem('Cadastro de Clientes', 'Listar, buscar, editar e excluir', '') do
  begin
    Icon := aiUser;
    Badge := Format('%d reg', [TotalCli]);
  end;
  with lvDrawerMenu.AddItem('+ Novo Cliente', 'Incluir novo cliente no SQLite', '') do
  begin
    Icon := aiPlus;
    Badge := 'CRUD';
  end;
  with lvDrawerMenu.AddItem('Catálogo de Produtos', 'Consultar itens e estoque', '') do
  begin
    Icon := aiCart;
  end;
  with lvDrawerMenu.AddItem('Histórico de Pedidos', 'Pedidos e faturamento', '') do
  begin
    Icon := aiDollar;
  end;
  with lvDrawerMenu.AddItem('Ajustes & Banco SQLite', 'Diagnóstico do sistema', '') do
  begin
    Icon := aiSettings;
  end;
  with lvDrawerMenu.AddItem('Sair / Logout', 'Encerrar sessão atual', '') do
  begin
    Icon := aiClose;
  end;
end;

procedure TForm2.Panel2Resize(Sender: TObject);
var
  Pad, BtnW, SearchW, H: Integer;
begin
  if not Assigned(btnNovoCliente) then Exit;
  Pad := Max(4, Panel2.ClientWidth div 80);
  H := Max(36, Panel2.ClientHeight - (Pad * 2));

  if btnNovoCliente.Visible then
  begin
    BtnW := Round(Panel2.ClientWidth * 0.22);
    SearchW := Panel2.ClientWidth - (BtnW * 2) - (Pad * 4);
    LazDroidSearchBar1.SetBounds(Pad, Pad, SearchW, H);
    LazDroidButton1.SetBounds(Pad * 2 + SearchW, Pad, BtnW, H);
    btnNovoCliente.SetBounds(Pad * 3 + SearchW + BtnW, Pad, BtnW, H);
  end
  else
  begin
    BtnW := Round(Panel2.ClientWidth * 0.24);
    SearchW := Panel2.ClientWidth - BtnW - (Pad * 3);
    LazDroidSearchBar1.SetBounds(Pad, Pad, SearchW, H);
    LazDroidButton1.SetBounds(Pad * 2 + SearchW, Pad, BtnW, H);
  end;
end;

procedure TForm2.AjustarLayoutResponsivo;
var
  AppBarH, NavH, ContentTop, ContentH, Pad, FieldH, Gap, BtnY, BtnH, W3, W, H, Panel2H: Integer;
  DrawerW, HeaderH, FooterH: Integer;
begin
  if not FComponentesCriados then Exit;

  // No CustomDrawn/Android o tamanho do TForm nao acompanha a tela (AutoAdjustLayout reduz
  // as medidas de design); por isso o layout e calculado pelo tamanho real da tela.
  W := Screen.Width;
  H := Screen.Height;
  AppBarH := Max(60, H div 11);
  NavH := Max(56, H div 12);
  Panel2H := Max(52, H div 13);
  LazDroidAppBar1.SetBounds(0, 0, W, AppBarH);
  LazDroidBottomNav1.SetBounds(0, H - NavH, W, NavH);

  if Panel2.Visible then
  begin
    Panel2.SetBounds(0, AppBarH, W, Panel2H);
    Panel2Resize(Panel2);
    ContentTop := AppBarH + Panel2H;
  end
  else
    ContentTop := AppBarH;

  ContentH := Max(100, H - ContentTop - NavH);
  Panel1.SetBounds(0, ContentTop, W, ContentH);

  // Dimensiona o Card de Cadastro de Clientes (CRUD) ocupando a área útil
  Pad := Max(8, W div 36);
  pnlCadastroCliente.SetBounds(Pad div 2, AppBarH + (Pad div 2),
    W - Pad, H - AppBarH - NavH - Pad);

  HeaderH := Max(40, pnlCadastroCliente.Height div 11);
  BtnH := Max(42, pnlCadastroCliente.Height div 11);
  BtnY := pnlCadastroCliente.Height - BtnH - Pad;
  Gap := Max(6, (BtnY - HeaderH - Pad) div 32);
  FieldH := Max(44, ((BtnY - HeaderH - Pad) - (Gap * 6)) div 5);

  edtClienteNome.SetBounds(Pad, HeaderH + Gap, pnlCadastroCliente.Width - (Pad * 2), FieldH);
  edtClienteDoc.SetBounds(Pad, edtClienteNome.Top + FieldH + Gap, pnlCadastroCliente.Width - (Pad * 2), FieldH);
  edtClienteFone.SetBounds(Pad, edtClienteDoc.Top + FieldH + Gap, pnlCadastroCliente.Width - (Pad * 2), FieldH);
  edtClienteEmail.SetBounds(Pad, edtClienteFone.Top + FieldH + Gap, pnlCadastroCliente.Width - (Pad * 2), FieldH);
  edtClienteCidade.SetBounds(Pad, edtClienteEmail.Top + FieldH + Gap, pnlCadastroCliente.Width - (Pad * 2), FieldH);

  if btnExcluirCliente.Visible then
  begin
    W3 := (pnlCadastroCliente.Width - (Pad * 4)) div 3;
    btnSalvarCliente.SetBounds(Pad, BtnY, W3 + (W3 div 6), BtnH);
    btnExcluirCliente.SetBounds(btnSalvarCliente.Left + btnSalvarCliente.Width + Pad, BtnY, W3 - (W3 div 12), BtnH);
    btnVoltarCliente.SetBounds(btnExcluirCliente.Left + btnExcluirCliente.Width + Pad, BtnY,
      pnlCadastroCliente.Width - Pad - (btnExcluirCliente.Left + btnExcluirCliente.Width + Pad), BtnH);
  end
  else
  begin
    W3 := (pnlCadastroCliente.Width - (Pad * 3)) div 2;
    btnSalvarCliente.SetBounds(Pad, BtnY, W3 + (W3 div 5), BtnH);
    btnVoltarCliente.SetBounds(btnSalvarCliente.Left + btnSalvarCliente.Width + Pad, BtnY,
      pnlCadastroCliente.Width - Pad - (btnSalvarCliente.Left + btnSalvarCliente.Width + Pad), BtnH);
  end;

  // Dimensiona o Menu Lateral (Drawer)
  DrawerW := Round(W * 0.80);
  pnlDrawer.SetBounds(0, AppBarH, DrawerW, H - AppBarH);
  HeaderH := Max(105, pnlDrawer.Height div 5);
  FooterH := Max(46, pnlDrawer.Height div 12);
  pnlDrawerHeader.SetBounds(0, 0, DrawerW, HeaderH);

  avDrawerUser.SetBounds(Pad, (HeaderH - (HeaderH div 2)) div 2, HeaderH div 2, HeaderH div 2);
  lblDrawerNome.SetBounds(avDrawerUser.Left + avDrawerUser.Width + Pad, Pad, DrawerW - avDrawerUser.Width - (Pad * 3), HeaderH div 4);
  lblDrawerSub.SetBounds(lblDrawerNome.Left, lblDrawerNome.Top + (HeaderH div 4) + 2, lblDrawerNome.Width, HeaderH div 5);
  bdgDrawerPerfil.SetBounds(lblDrawerNome.Left, HeaderH - (HeaderH div 4) - (Pad div 2), Round(DrawerW * 0.45), Max(22, HeaderH div 5));

  lvDrawerMenu.ItemHeight := Max(54, (pnlDrawer.Height - HeaderH - FooterH - (Pad * 3)) div 6);
  lvDrawerMenu.SetBounds(2, HeaderH + 4, DrawerW - 4, pnlDrawer.Height - HeaderH - FooterH - (Pad * 2) - 4);
  btnFecharDrawer.SetBounds(Pad, pnlDrawer.Height - FooterH - Pad, DrawerW - (Pad * 2), FooterH);
end;

procedure TForm2.FormResizeHandler(Sender: TObject);
begin
  AjustarLayoutResponsivo;
end;

procedure TForm2.AlternarMenuLateral(AExibir: Boolean);
begin
  if not Assigned(pnlDrawer) then Exit;
  if AExibir then
  begin
    PopularMenuLateral;
    AjustarLayoutResponsivo;
    pnlDrawer.Visible := True;
    pnlDrawer.BringToFront;
  end
  else
  begin
    pnlDrawer.Visible := False;
  end;
  Invalidate;
end;

procedure TForm2.AbrirCadastroCliente(AClienteId: Integer);
var
  Nome, Fone, Email, Cidade, Doc: string;
begin
  AlternarMenuLateral(False);
  FClienteEditId := AClienteId;

  if (AClienteId > 0) and Assigned(DataModule1) and
     DataModule1.ObterClientePorId(AClienteId, Nome, Fone, Email, Cidade, Doc) then
  begin
    pnlCadastroCliente.HeaderTitle := Format('Editar Cliente #%d', [AClienteId]);
    LazDroidAppBar1.Title := Format('Editar Cliente #%d', [AClienteId]);
    LazDroidAppBar1.Subtitle := Nome;
    edtClienteNome.Text := Nome;
    edtClienteDoc.Text := Doc;
    edtClienteFone.Text := Fone;
    edtClienteEmail.Text := Email;
    edtClienteCidade.Text := Cidade;
    btnExcluirCliente.Visible := True;
  end
  else
  begin
    FClienteEditId := 0;
    pnlCadastroCliente.HeaderTitle := 'Novo Cliente (Cadastro CRUD)';
    LazDroidAppBar1.Title := 'Novo Cliente';
    LazDroidAppBar1.Subtitle := 'Preencha os dados para salvar';
    edtClienteNome.Text := '';
    edtClienteDoc.Text := '';
    edtClienteFone.Text := '';
    edtClienteEmail.Text := '';
    edtClienteCidade.Text := '';
    btnExcluirCliente.Visible := False;
  end;

  LazDroidAppBar1.LeftIcon := aiBack;
  LazDroidAppBar1.ActionIcon := aiMenu;
  Panel2.Visible := False;
  Panel1.Visible := False;
  AjustarLayoutResponsivo;
  pnlCadastroCliente.Visible := True;
  pnlCadastroCliente.BringToFront;
  Invalidate;
end;

procedure TForm2.FecharCadastroCliente;
begin
  if Assigned(pnlCadastroCliente) then
    pnlCadastroCliente.Visible := False;
  Panel1.Visible := True;
  LazDroidAppBar1.LeftIcon := aiMenu;
  LazDroidAppBar1.ActionIcon := aiPlus;
  LazDroidBottomNav1.ActiveIndex := 2;
  LazDroidBottomNav1TabSelected(LazDroidBottomNav1, 2);
  AjustarLayoutResponsivo;
  Invalidate;
end;

procedure TForm2.BtnNovoClienteClick(Sender: TObject);
begin
  AbrirCadastroCliente(0);
end;

procedure TForm2.BtnSalvarClienteClick(Sender: TObject);
var
  IdSalvo: Integer;
begin
  if Trim(edtClienteNome.Text) = '' then
  begin
    ShowMobileToast(Self, 'Informe o Nome / Razão Social do cliente.');
    Exit;
  end;

  IdSalvo := FClienteEditId;
  if Assigned(DataModule1) and DataModule1.SalvarCliente(
       IdSalvo,
       edtClienteNome.Text,
       edtClienteFone.Text,
       edtClienteEmail.Text,
       edtClienteCidade.Text,
       edtClienteDoc.Text) then
  begin
    FecharCadastroCliente;
    ShowMobileToast(Self, Format('Cliente #%d salvo com sucesso!', [IdSalvo]));
  end
  else
    ShowMobileToast(Self, 'Erro ao salvar cliente no banco de dados.');
end;

procedure TForm2.BtnExcluirClienteClick(Sender: TObject);
var
  IdExcluido: Integer;
begin
  if FClienteEditId <= 0 then Exit;
  IdExcluido := FClienteEditId;
  if Assigned(DataModule1) and DataModule1.ExcluirCliente(IdExcluido) then
  begin
    FecharCadastroCliente;
    ShowMobileToast(Self, Format('Cliente #%d excluído com sucesso!', [IdExcluido]));
  end
  else
    ShowMobileToast(Self, 'Não foi possível excluir o cliente.');
end;

procedure TForm2.BtnVoltarClienteClick(Sender: TObject);
begin
  FecharCadastroCliente;
end;

procedure TForm2.BtnFecharDrawerClick(Sender: TObject);
begin
  AlternarMenuLateral(False);
end;

procedure TForm2.DrawerMenuItemClick(Sender: TObject; AIndex: Integer);
begin
  AlternarMenuLateral(False);
  case AIndex of
    0: // Clientes (Lista CRUD)
    begin
      FecharCadastroCliente;
    end;
    1: // + Novo Cliente
    begin
      AbrirCadastroCliente(0);
    end;
    2: // Catálogo de Produtos
    begin
      if Assigned(pnlCadastroCliente) then pnlCadastroCliente.Visible := False;
      Panel1.Visible := True;
      LazDroidBottomNav1.ActiveIndex := 0;
      LazDroidBottomNav1TabSelected(LazDroidBottomNav1, 0);
    end;
    3: // Histórico de Pedidos
    begin
      if Assigned(pnlCadastroCliente) then pnlCadastroCliente.Visible := False;
      Panel1.Visible := True;
      LazDroidBottomNav1.ActiveIndex := 1;
      LazDroidBottomNav1TabSelected(LazDroidBottomNav1, 1);
    end;
    4: // Ajustes & Sistema
    begin
      if Assigned(pnlCadastroCliente) then pnlCadastroCliente.Visible := False;
      Panel1.Visible := True;
      LazDroidBottomNav1.ActiveIndex := 3;
      LazDroidBottomNav1TabSelected(LazDroidBottomNav1, 3);
    end;
    5: // Sair / Logout
    begin
      if Assigned(Form1) then
      begin
        Form1.Show;
        Self.Hide;
      end;
    end;
  end;
end;

procedure TForm2.SearchBarSearch(Sender: TObject; const ASearchText: string);
begin
  LazDroidButton1Click(Sender);
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  DLog('FormShow: inicio');
  CriarComponentesCRUD;
  DLog('FormShow: componentes ok');
  // Abre após o login diretamente no Cadastro de Clientes (CRUD) com Menu Lateral acessível
  LazDroidBottomNav1.ActiveIndex := 2;
  DLog('FormShow: activeindex ok');
  LazDroidBottomNav1TabSelected(LazDroidBottomNav1, 2);
  DLog('FormShow: tabselected ok');
  AjustarLayoutResponsivo;
  DLog('FormShow: layout ok');
end;

procedure TForm2.LazDroidAppBar1ActionClick(Sender: TObject);
begin
  // Se estiver no formulário de cadastro, o botão da direita abre o Menu Lateral;
  // se estiver na listagem, abre direto "+ Novo Cliente"
  if Assigned(pnlCadastroCliente) and pnlCadastroCliente.Visible then
    AlternarMenuLateral(not pnlDrawer.Visible)
  else
    AbrirCadastroCliente(0);
end;

procedure TForm2.LazDroidAppBar1BackClick(Sender: TObject);
begin
  // Se o Menu Lateral estiver aberto, fecha o Menu Lateral
  if Assigned(pnlDrawer) and pnlDrawer.Visible then
  begin
    AlternarMenuLateral(False);
    Exit;
  end;

  // Se o formulário CRUD de cliente estiver aberto, volta para a lista de clientes
  if Assigned(pnlCadastroCliente) and pnlCadastroCliente.Visible then
  begin
    FecharCadastroCliente;
    Exit;
  end;

  // Na tela principal, o ícone de menu (hambúrguer) à esquerda abre o Menu Lateral (Drawer)!
  AlternarMenuLateral(True);
end;

procedure TForm2.LazDroidBottomNav1TabSelected(Sender: TObject; AIndex: Integer);
begin
  AlternarMenuLateral(False);
  if Assigned(pnlCadastroCliente) then
    pnlCadastroCliente.Visible := False;
  Panel1.Visible := True;
  LazDroidAppBar1.LeftIcon := aiMenu;

  case AIndex of
    0: // Início / Produtos
    begin
      LazDroidAppBar1.Title := 'Catálogo de Produtos';
      LazDroidAppBar1.Subtitle := 'Toque no menu ≡ ou pesquise';
      LazDroidAppBar1.ActionIcon := aiMenu;
      LazDroidSearchBar1.Text := '';
      LazDroidSearchBar1.Placeholder := 'Pesquisar produto...';
      Panel2.Visible := True;
      if Assigned(btnNovoCliente) then btnNovoCliente.Visible := False;
      if Assigned(DataModule1) then
        DataModule1.CarregarProdutos(LazDroidListView1);
    end;

    1: // Pedidos
    begin
      LazDroidAppBar1.Title := 'Pedidos & Vendas';
      LazDroidAppBar1.Subtitle := 'Histórico de pedidos SQLite';
      LazDroidAppBar1.ActionIcon := aiMenu;
      LazDroidSearchBar1.Text := '';
      LazDroidSearchBar1.Placeholder := 'Pesquisar pedido...';
      Panel2.Visible := True;
      if Assigned(btnNovoCliente) then btnNovoCliente.Visible := False;
      if Assigned(DataModule1) then
        DataModule1.CarregarPedidos(LazDroidListView1);
    end;

    2: // Clientes (CRUD Completo)
    begin
      DLog('Tab2: titulo');
      LazDroidAppBar1.Title := 'Clientes (CRUD)';
      LazDroidAppBar1.Subtitle := 'Toque p/ editar ou + Novo p/ incluir';
      LazDroidAppBar1.ActionIcon := aiPlus;
      LazDroidSearchBar1.Text := '';
      LazDroidSearchBar1.Placeholder := 'Buscar cliente...';
      Panel2.Visible := True;
      if Assigned(btnNovoCliente) then btnNovoCliente.Visible := True;
      DLog('Tab2: carregando clientes');
      if Assigned(DataModule1) then
        DataModule1.CarregarClientes(LazDroidListView1);
      DLog('Tab2: clientes ok');
    end;

    3: // Ajustes
    begin
      LazDroidAppBar1.Title := 'Ajustes & Sistema';
      LazDroidAppBar1.Subtitle := 'Configurações e Logout';
      LazDroidAppBar1.ActionIcon := aiMenu;
      Panel2.Visible := False;
      LazDroidListView1.Clear;
      with LazDroidListView1.AddItem('Abrir Menu Lateral (Drawer)', 'Navegação rápida entre módulos', 'Abrir') do
        Icon := aiMenu;
      with LazDroidListView1.AddItem('Usuário Conectado', FUsuarioNome + ' (' + FUsuarioNivel + ')', 'Online') do
        Icon := aiUser;
      with LazDroidListView1.AddItem('Banco de Dados SQLite', 'database/app.db (CRUD Clientes)', 'Ativo') do
        Icon := aiCheck;
      with LazDroidListView1.AddItem('Total de Clientes', 'Registros salvos na tabela clientes',
        Format('%d clientes', [DataModule1.TotalClientes])) do
        Icon := aiStar;
      with LazDroidListView1.AddItem('Desconectar / Sair', 'Toque para encerrar a sessão', 'Sair') do
        Icon := aiClose;
    end;
  end;

  AjustarLayoutResponsivo;
end;

procedure TForm2.LazDroidButton1Click(Sender: TObject);
var
  Termo: string;
begin
  Termo := Trim(LazDroidSearchBar1.Text);
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

    // Na aba Clientes (2), tocar em um cliente abre o formulário de Edição/Exclusão (CRUD)!
    if LazDroidBottomNav1.ActiveIndex = 2 then
    begin
      AbrirCadastroCliente(Item.Tag);
      Exit;
    end;

    if LazDroidBottomNav1.ActiveIndex = 3 then
    begin
      if Item.Value = 'Abrir' then
        AlternarMenuLateral(True)
      else if Item.Value = 'Sair' then
      begin
        if Assigned(Form1) then
        begin
          Form1.Show;
          Self.Hide;
        end;
      end
      else
        ShowMobileToast(Self, Item.Title + ': ' + Item.Subtitle);
      Exit;
    end;

    ShowMobileToast(Self, Item.Title + ' • ' + Item.Value);
  end;
end;

end.
