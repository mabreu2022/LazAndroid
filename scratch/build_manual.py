# -*- coding: utf-8 -*-
"""
Script gerador do Manual Completo de Uso dos Componentes LazDroid em HTML com suporte a exportação para PDF.
"""
import os
import sys

OUTPUT_FILE = r"d:\Projetos AntiGravity\LazarusAndroid\docs\manual_componentes_lazdroid.html"

# Vamos definir os dados estruturados de todos os 29 componentes e utilitários
COMPONENTS = [
    # ---------------- NAVEGAÇÃO & ESTRUTURA ----------------
    {
        "id": "TLazDroidAppBar",
        "name": "TLazDroidAppBar",
        "category": "Navegação & Estrutura",
        "cat_id": "nav",
        "parent": "TCustomControl",
        "tagline": "Barra superior móvel para navegação, título, subtítulo e ações rápidas",
        "desc": "A AppBar é a barra de cabeçalho padrão de aplicativos Android modernos. Ela exibe o título da tela, um subtítulo opcional de contexto (como status de conexão ou usuário ativo), um botão de voltar sensível ao toque e um botão de ação rápida à direita com ícone customizável.",
        "touch_tip": "Alinhe sempre no topo (Align = alTop) com altura mínima recomendada de 56dp para garantir alvos de toque confortáveis aos polegares.",
        "props": [
            ("Title", "string", "'Título'", "Texto principal exibido em destaque no cabeçalho."),
            ("Subtitle", "string", "''", "Texto auxiliar abaixo do título (status, subtítulo)."),
            ("ShowBack", "Boolean", "True", "Exibe ou oculta o botão tátil de retorno (ícone de seta)."),
            ("ActionIcon", "TLazDroidActionIcon", "aiMenu", "Ícone de ação à direita (aiMenu, aiMore, aiSearch, aiClose, etc.)."),
            ("BarColor", "TColor", "$00241A14", "Cor de fundo da barra superior (Indigo escuro padrão)."),
            ("TitleColor", "TColor", "clWhite", "Cor do título principal."),
            ("SubtitleColor", "TColor", "$00D0C0B0", "Cor do subtítulo."),
            ("Align", "TAlign", "alTop", "Alinhamento no formulário."),
            ("Height", "Integer", "56", "Altura tátil da barra.")
        ],
        "events": [
            ("OnBackClick", "TNotifyEvent", "Disparado quando o usuário toca no botão de voltar à esquerda."),
            ("OnActionClick", "TNotifyEvent", "Disparado quando o usuário toca no ícone de ação à direita.")
        ],
        "example": """// Configuração dinâmica da AppBar na abertura da tela
procedure TForm1.FormCreate(Sender: TObject);
begin
  AppBar1.Title := 'Minha Conta';
  AppBar1.Subtitle := 'Conectado como Gerente';
  AppBar1.ShowBack := True;
  AppBar1.ActionIcon := aiMore;
end;

procedure TForm1.AppBar1BackClick(Sender: TObject);
begin
  Close; // Retorna para a tela anterior
end;

procedure TForm1.AppBar1ActionClick(Sender: TObject);
begin
  ShowMobileToast(Self, 'Menu de opções adicionais');
end;""",
        "preview_html": """
        <div class="preview-appbar">
            <div class="appbar-back"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M19 12H5M12 19l-7-7 7-7"/></svg></div>
            <div class="appbar-titles">
                <span class="appbar-title">Minha Conta</span>
                <span class="appbar-subtitle">Conectado como Gerente</span>
            </div>
            <div class="appbar-action"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="5" r="1.5"/><circle cx="12" cy="12" r="1.5"/><circle cx="12" cy="19" r="1.5"/></svg></div>
        </div>
        """
    },
    {
        "id": "TLazDroidBottomNav",
        "name": "TLazDroidBottomNav",
        "category": "Navegação & Estrutura",
        "cat_id": "nav",
        "parent": "TCustomControl",
        "tagline": "Barra de navegação inferior com abas táteis, badges e transição suave",
        "desc": "Componente essencial para arquiteturas móveis baseadas em abas (Bottom Navigation Bar). Posiciona-se na parte inferior da tela, garantindo alcance ergonômico imediato para a mão do usuário, destacando a aba ativa e disparando eventos de troca de contexto.",
        "touch_tip": "Posicione sempre alinhado ao rodapé (Align = alBottom). Para melhor ergonomia, mantenha entre 3 e 5 abas.",
        "props": [
            ("Items", "TStrings", "'Início\\nPedidos\\nProdutos\\nPerfil'", "Lista de títulos das abas que compõem a barra de navegação."),
            ("ActiveIndex", "Integer", "0", "Índice (0-based) da aba atualmente selecionada."),
            ("ActiveColor", "TColor", "$00D97706", "Cor de destaque aplicada no ícone e texto da aba ativa."),
            ("InactiveColor", "TColor", "$008E8E93", "Cor suave para as abas inativas."),
            ("BarColor", "TColor", "$0018181B", "Cor de fundo da barra de navegação inferior."),
            ("Height", "Integer", "56", "Altura padrão mobile da barra.")
        ],
        "events": [
            ("OnTabSelected", "TLazDroidTabChangeEvent", "Disparado ao tocar em qualquer aba: procedure(Sender: TObject; AIndex: Integer).")
        ],
        "example": """procedure TForm1.BottomNav1TabSelected(Sender: TObject; AIndex: Integer);
begin
  case AIndex of
    0: PageControl1.ActivePageIndex := 0; // Início
    1: PageControl1.ActivePageIndex := 1; // Pedidos
    2: PageControl1.ActivePageIndex := 2; // Produtos
    3: PageControl1.ActivePageIndex := 3; // Perfil
  end;
  ShowMobileToast(Self, 'Aba selecionada: ' + BottomNav1.Items[AIndex]);
end;""",
        "preview_html": """
        <div class="preview-bottomnav">
            <div class="bnav-tab active">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
                <span>Início</span>
            </div>
            <div class="bnav-tab">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
                <span>Pedidos</span>
            </div>
            <div class="bnav-tab">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="2" y="7" width="20" height="14" rx="2"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                <span>Produtos</span>
            </div>
            <div class="bnav-tab">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                <span>Perfil</span>
            </div>
        </div>
        """
    },
    {
        "id": "TLazDroidBottomSheet",
        "name": "TLazDroidBottomSheet",
        "category": "Navegação & Estrutura",
        "cat_id": "nav",
        "parent": "TCustomControl",
        "tagline": "Painel deslizante inferior / gaveta de contexto estilo Material You",
        "desc": "Gaveta deslizante que sobe do rodapé da tela para exibir menus de contexto, formulários breves, filtros detalhados ou opções sem cobrir totalmente o conteúdo anterior. Acompanha puxador tátil superior (handle bar) e botão de fechamento.",
        "touch_tip": "Excelente para substituir diálogos pop-up intrusivos em telas mobile, permitindo controle confortável com apenas uma mão.",
        "props": [
            ("Title", "string", "'Opções'", "Título exibido na barra superior da gaveta."),
            ("IsOpen", "Boolean", "True", "Estado visível do painel. Ao alternar, abre ou fecha."),
            ("CornerRadius", "Integer", "16", "Raio dos cantos superiores arredondados da gaveta."),
            ("HeaderColor", "TColor", "$00F8FAFC", "Cor do topo com o indicador de arraste."),
            ("Align", "TAlign", "alBottom", "Alinhamento fixado no rodapé.")
        ],
        "events": [
            ("OnClose", "TNotifyEvent", "Disparado quando o usuário fecha a gaveta tocando no botão fechar.")
        ],
        "example": """// Abrindo a gaveta programaticamente
procedure TForm1.BtnFiltrarClick(Sender: TObject);
begin
  BottomSheet1.OpenSheet;
end;

// Fechando e processando os filtros
procedure TForm1.BtnAplicarClick(Sender: TObject);
begin
  BottomSheet1.CloseSheet;
  CarregarDadosFiltrados;
end;""",
        "preview_html": """
        <div class="preview-bottomsheet">
            <div class="bs-handle"></div>
            <div class="bs-header">
                <span class="bs-title">Opções do Pedido</span>
                <span class="bs-close">&times;</span>
            </div>
            <div class="bs-content">
                <div class="bs-item">📄 Visualizar Cupom Fiscal</div>
                <div class="bs-item">💳 Alterar Forma de Pagamento</div>
                <div class="bs-item text-danger">❌ Cancelar Pedido</div>
            </div>
        </div>
        """
    },
    {
        "id": "TLazDroidSpeedDial",
        "name": "TLazDroidSpeedDial",
        "category": "Navegação & Estrutura",
        "cat_id": "nav",
        "parent": "TCustomControl",
        "tagline": "Botão flutuante expansível com sub-ações verticais em cascata",
        "desc": "O SpeedDial expande a funcionalidade de um botão FAB tradicional. Ao ser tocado, ele desdobra verticalmente uma lista de mini-botões com rótulos descritivos para ações rápidas relacionadas (ex: Adicionar Produto, Novo Cliente, Emitir Venda).",
        "touch_tip": "Posicione na região inferior direita da tela (Anchors = [akRight, akBottom]) com espaçamento seguro de 16dp da borda.",
        "props": [
            ("Items", "TStrings", "'Venda\\nCliente\\nProduto'", "Lista de ações secundárias que desdobram ao tocar."),
            ("IsOpen", "Boolean", "False", "Indica se o leque de botões está expandido ou recolhido."),
            ("ButtonColor", "TColor", "$00D97706", "Cor do botão principal."),
            ("SubButtonColor", "TColor", "$000284C7", "Cor dos botões secundários expandidos."),
            ("IconColor", "TColor", "clWhite", "Cor dos ícones.")
        ],
        "events": [
            ("OnItemClick", "TLazDroidItemClickEvent", "Disparado ao selecionar uma das opções secundárias: procedure(Sender: TObject; AIndex: Integer).")
        ],
        "example": """procedure TForm1.SpeedDial1ItemClick(Sender: TObject; AIndex: Integer);
begin
  case AIndex of
    0: AbrirTelaNovaVenda;
    1: AbrirCadastroCliente;
    2: AbrirCadastroProduto;
  end;
end;""",
        "preview_html": """
        <div class="preview-speeddial">
            <div class="sd-subitem"><span class="sd-label">Novo Produto</span><div class="sd-subbtn">📦</div></div>
            <div class="sd-subitem"><span class="sd-label">Novo Cliente</span><div class="sd-subbtn">👤</div></div>
            <div class="sd-mainbtn"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg></div>
        </div>
        """
    },
    {
        "id": "TLazDroidLayout",
        "name": "TLazDroidLayout",
        "category": "Navegação & Estrutura",
        "cat_id": "nav",
        "parent": "TCustomControl",
        "tagline": "Container flexível com auto-organização de controles (Stack Layout)",
        "desc": "Container inteligente que organiza automaticamente os controles filhos empilhados verticalmente ou enfileirados horizontalmente com espaçamento uniforme (Spacing). Evita sobreposição de componentes ao rotacionar a tela ou ao redimensionar em diferentes aparelhos.",
        "touch_tip": "Ative AutoArrange = True para que o layout reposicione e alinhe todos os campos instantaneamente sem necessidade de código manual de posicionamento.",
        "props": [
            ("Direction", "TLazDroidLayoutDirection", "ldVertical", "Direção do empilhamento: ldVertical (coluna) ou ldHorizontal (linha)."),
            ("Spacing", "Integer", "12", "Espaço em pixels/dp entre os controles filhos."),
            ("AutoArrange", "Boolean", "True", "Reorganiza automaticamente os filhos durante redimensionamento.")
        ],
        "events": [],
        "example": """procedure TForm1.FormCreate(Sender: TObject);
begin
  Layout1.Direction := ldVertical;
  Layout1.Spacing := 16;
  Layout1.AutoArrange := True;
end;""",
        "preview_html": """
        <div class="preview-layout">
            <div class="layout-child">Controle Filho A</div>
            <div class="layout-child">Controle Filho B</div>
            <div class="layout-child">Controle Filho C</div>
        </div>
        """
    },

    # ---------------- ENTRADA DE DADOS & FORMULÁRIOS ----------------
    {
        "id": "TLazDroidEdit",
        "name": "TLazDroidEdit",
        "category": "Entrada de Dados & Formulários",
        "cat_id": "form",
        "parent": "TCustomControl",
        "tagline": "Campo de texto mobile touch-friendly com rótulo e foco dinâmico",
        "desc": "Campo de entrada de texto desenhado especificamente para telas de toque. Oferece bordas arredondadas, indicação de foco com cor de destaque, suporte a modo senha com caracteres mascarados e integração de teclado.",
        "touch_tip": "Utilize altura mínima de 44dp e preencha LabelCaption para que o usuário identifique o campo mesmo durante a digitação.",
        "props": [
            ("Text", "string", "''", "Conteúdo textual do campo."),
            ("Placeholder", "string", "''", "Texto informativo exibido quando o campo está vazio."),
            ("LabelCaption", "string", "''", "Rótulo flutuante superior identificando a finalidade do campo."),
            ("IsPassword", "Boolean", "False", "Se True, mascara os caracteres digitados com círculos de segurança."),
            ("InputKind", "TLazDroidInputKind", "ikText", "Tipo de entrada: ikText, ikNumber, ikEmail, ikPhone."),
            ("CornerRadius", "Integer", "8", "Raio dos cantos da caixa."),
            ("BorderColor", "TColor", "$00D0D0D0", "Cor da borda no estado ocioso."),
            ("FocusedColor", "TColor", "$00D97706", "Cor da borda e realce quando o campo recebe foco.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado sempre que o conteúdo do texto é modificado.")
        ],
        "example": """procedure TForm1.FormCreate(Sender: TObject);
begin
  EditEmail.LabelCaption := 'E-mail Comercial';
  EditEmail.Placeholder := 'exemplo@empresa.com';
  EditEmail.InputKind := ikEmail;

  EditSenha.LabelCaption := 'Senha de Acesso';
  EditSenha.IsPassword := True;
end;""",
        "preview_html": """
        <div class="preview-edit">
            <label class="edit-label">E-mail Comercial</label>
            <div class="edit-box focused">
                <span class="edit-text">gerente@empresa.com</span>
                <span class="edit-cursor"></span>
            </div>
        </div>
        """
    },
    {
        "id": "TLazDroidSearchBar",
        "name": "TLazDroidSearchBar",
        "category": "Entrada de Dados & Formulários",
        "cat_id": "form",
        "parent": "TCustomControl",
        "tagline": "Barra de pesquisa em pílula com ícone de busca e limpeza rápida",
        "desc": "Campo de busca moderno no formato de pílula (estilo Google / iOS). Possui ícone de lupa à esquerda, botão tátil de limpeza (X) sensível ao toque à direita quando há texto e evento OnSearch disparado automaticamente.",
        "touch_tip": "Ative AutoSearch = True para disparar a busca enquanto o usuário digita ou use OnSearch com Enter para listas muito extensas.",
        "props": [
            ("Text", "string", "''", "Termo de busca digitado."),
            ("Placeholder", "string", "'Pesquisar...'", "Texto de instrução quando o campo está vazio."),
            ("CornerRadius", "Integer", "18", "Curvatura dos cantos (estilo pill/cápsula)."),
            ("SearchColor", "TColor", "$00D97706", "Cor do ícone de busca e destaque."),
            ("AutoSearch", "Boolean", "True", "Dispara o evento OnSearch a cada caractere digitado."),
            ("BorderColor", "TColor", "$00CBD5E1", "Cor sutil da borda externa.")
        ],
        "events": [
            ("OnSearch", "TLazDroidSearchEvent", "Disparado ao pesquisar: procedure(Sender: TObject; const AQuery: string).")
        ],
        "example": """procedure TForm1.SearchBar1Search(Sender: TObject; const AQuery: string);
begin
  FiltrarListaProdutos(AQuery);
end;

// Limpando a busca por código
procedure TForm1.BtnResetClick(Sender: TObject);
begin
  SearchBar1.Clear;
end;""",
        "preview_html": """
        <div class="preview-searchbar">
            <svg class="search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            <span class="search-input">Teclado sem fio</span>
            <div class="search-clear">&times;</div>
        </div>
        """
    },
    {
        "id": "TLazDroidOtpBox",
        "name": "TLazDroidOtpBox",
        "category": "Entrada de Dados & Formulários",
        "cat_id": "form",
        "parent": "TCustomControl",
        "tagline": "Caixas de dígitos individuais para PIN, Token SMS e 2FA",
        "desc": "Controle indispensável para fluxos de autenticação em dois fatores, verificação por SMS, confirmação de PIX ou senhas numéricas. Apresenta caixas separadas que avançam e retrocedem o foco automaticamente à medida que os dígitos são preenchidos.",
        "touch_tip": "Configure CodeLength de acordo com o protocolo (geralmente 4 dígitos para PINs de cartão ou 6 dígitos para códigos SMS/Google Authenticator).",
        "props": [
            ("Code", "string", "''", "Código completo atualmente digitado."),
            ("CodeLength", "Integer", "4", "Quantidade de caixas de dígitos (ex: 4 ou 6)."),
            ("BoxSize", "Integer", "48", "Tamanho lateral de cada caixa quadrada em pixels/dp."),
            ("BoxSpacing", "Integer", "10", "Espaçamento entre as caixas de dígitos."),
            ("IsPassword", "Boolean", "False", "Se True, mascara os dígitos com marcadores."),
            ("FocusedColor", "TColor", "$00D97706", "Cor da borda da caixa ativa em foco.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado a cada caractere inserido ou apagado."),
            ("OnComplete", "TNotifyEvent", "Disparado automaticamente assim que todos os dígitos forem preenchidos.")
        ],
        "example": """procedure TForm1.OtpBox1Complete(Sender: TObject);
begin
  if OtpBox1.Code = '8492' then
  begin
    ShowMobileToast(Self, 'Token validado com sucesso!');
    AvancarParaProximaEtapa;
  end
  else
  begin
    ShowMobileToast(Self, 'Código incorreto. Tente novamente.');
    OtpBox1.Clear;
  end;
end;""",
        "preview_html": """
        <div class="preview-otp">
            <div class="otp-box filled">8</div>
            <div class="otp-box filled">4</div>
            <div class="otp-box active">|</div>
            <div class="otp-box"></div>
        </div>
        """
    },
    {
        "id": "TLazDroidDatePicker",
        "name": "TLazDroidDatePicker",
        "category": "Entrada de Dados & Formulários",
        "cat_id": "form",
        "parent": "TCustomControl",
        "tagline": "Campo seletor de data touch com calendário modal e navegação de mês",
        "desc": "Campo touch que exibe a data formatada e, ao ser tocado, abre um calendário mobile modal completo para seleção intuitiva de dia, mês e ano, sem depender de componentes nativos incompatíveis.",
        "touch_tip": "Permite abrir o calendário tanto pelo toque direto no campo quanto via código pelo método OpenPicker.",
        "props": [
            ("Date", "TDateTime", "Date()", "Data selecionada."),
            ("DateFormat", "string", "'DD/MM/YYYY'", "Máscara de exibição da data."),
            ("LabelCaption", "string", "'Data'", "Rótulo informativo do campo."),
            ("Placeholder", "string", "'Selecione uma data'", "Texto exibido quando vazio."),
            ("AccentColor", "TColor", "$00D97706", "Cor dos dias selecionados no calendário."),
            ("CornerRadius", "Integer", "8", "Raio dos cantos do campo.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado assim que uma nova data é confirmada.")
        ],
        "example": """procedure TForm1.DatePicker1Change(Sender: TObject);
begin
  ShowMobileToast(Self, 'Data agendada: ' + FormatDateTime('dd/mm/yyyy', DatePicker1.Date));
end;""",
        "preview_html": """
        <div class="preview-picker">
            <label class="picker-label">Data de Nascimento</label>
            <div class="picker-box">
                <span class="picker-val">15/08/1990</span>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            </div>
        </div>
        """
    },
    {
        "id": "TLazDroidTimePicker",
        "name": "TLazDroidTimePicker",
        "category": "Entrada de Dados & Formulários",
        "cat_id": "form",
        "parent": "TCustomControl",
        "tagline": "Campo seletor de hora touch com relógio circular interativo",
        "desc": "Permite escolher horários de forma ágil através de um diálogo de relógio touch, com seletor de horas e minutos em formato 24h ou 12h.",
        "touch_tip": "Excelente para agendamentos de ordens de serviço, consultas e registros de ponto móvel.",
        "props": [
            ("Time", "TDateTime", "Time()", "Horário atualmente selecionado."),
            ("TimeFormat", "string", "'hh:nn'", "Formato de exibição da hora."),
            ("LabelCaption", "string", "'Horário'", "Rótulo descritivo do campo."),
            ("AccentColor", "TColor", "$00D97706", "Cor do ponteiro e botão de confirmação.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado quando o usuário escolhe um novo horário.")
        ],
        "example": """procedure TForm1.TimePicker1Change(Sender: TObject);
begin
  LabelHorario.Caption := 'Início previsto: ' + FormatDateTime('hh:nn', TimePicker1.Time);
end;""",
        "preview_html": """
        <div class="preview-picker">
            <label class="picker-label">Horário de Entrega</label>
            <div class="picker-box">
                <span class="picker-val">14:30</span>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#D97706" stroke-width="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
            </div>
        </div>
        """
    },
    {
        "id": "TLazDroidCheckBox",
        "name": "TLazDroidCheckBox",
        "category": "Entrada de Dados & Formulários",
        "cat_id": "form",
        "parent": "TCustomControl",
        "tagline": "Caixa de seleção touch com alvo ampliado de 40dp e checagem suave",
        "desc": "Substitui o TCheckBox tradicional por uma caixa de seleção otimizada para dedos humanos. Possui área de toque generosa, cantos arredondados modernos e ícone de 'check' vetorial.",
        "touch_tip": "O toque em qualquer parte do texto ou da caixa alterna o estado de seleção instantaneamente.",
        "props": [
            ("Checked", "Boolean", "False", "Estado atual de marcação do controle."),
            ("Caption", "string", "'Opção'", "Texto descritivo exibido ao lado da caixa."),
            ("BoxColor", "TColor", "$00D97706", "Cor de preenchimento quando marcado."),
            ("CheckColor", "TColor", "clWhite", "Cor do sinal de visto (V)."),
            ("CornerRadius", "Integer", "6", "Raio dos cantos da caixa de seleção.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado quando o estado Checked é alternado.")
        ],
        "example": """procedure TForm1.CheckBoxLembrarChange(Sender: TObject);
begin
  Config.SalvarCredenciais := CheckBoxLembrar.Checked;
end;""",
        "preview_html": """
        <div class="preview-checkbox">
            <div class="chk-box checked"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3.5"><polyline points="20 6 9 17 4 12"/></svg></div>
            <span class="chk-caption">Salvar credenciais neste aparelho</span>
        </div>
        """
    },
    {
        "id": "TLazDroidSwitch",
        "name": "TLazDroidSwitch",
        "category": "Entrada de Dados & Formulários",
        "cat_id": "form",
        "parent": "TGraphicControl",
        "tagline": "Chave de alternância (Toggle Switch) deslizante estilo Android / iOS",
        "desc": "Interruptor deslizante de alta fidelidade visual para preferências liga/desliga (ex: Notificações, Modo Escuro, Conexão Bluetooth). Desenhado para resposta instantânea ao toque com transição de cor.",
        "touch_tip": "Ideal para telas de configurações e parâmetros imediatos onde o usuário não precisa de um botão 'Salvar'.",
        "props": [
            ("Checked", "Boolean", "False", "Estado ligado (True) ou desligado (False)."),
            ("OnColor", "TColor", "$00D97706", "Cor da trilha quando a chave está ligada."),
            ("OffColor", "TColor", "$00E5E7EB", "Cor da trilha quando a chave está desligada."),
            ("ThumbColor", "TColor", "clWhite", "Cor do disco deslizante (thumb).")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado imediatamente após a alternância do estado.")
        ],
        "example": """procedure TForm1.SwitchNotificacoesChange(Sender: TObject);
begin
  if SwitchNotificacoes.Checked then
    AtivarServicoNotificacoes
  else
    PausarServicoNotificacoes;
end;""",
        "preview_html": """
        <div class="preview-switch-row">
            <span>Receber notificações push</span>
            <div class="preview-switch on"><div class="switch-thumb"></div></div>
        </div>
        """
    },
    {
        "id": "TLazDroidRadioGroup",
        "name": "TLazDroidRadioGroup",
        "category": "Entrada de Dados & Formulários",
        "cat_id": "form",
        "parent": "TCustomControl",
        "tagline": "Grupo de opções circulares de seleção única com touch target ampliado",
        "desc": "Apresenta uma lista de itens exclusivos com indicadores circulares mobile de 42dp de altura por linha. Garante facilidade para selecionar apenas uma dentre várias opções sem erros de precisão.",
        "touch_tip": "Perfeito para formas de pagamento (Dinheiro, Cartão, PIX, Boleto) ou escolha de frete.",
        "props": [
            ("Items", "TStrings", "'PIX\\nCartão de Crédito\\nBoleto Bancário'", "Lista de alternativas de escolha."),
            ("ItemIndex", "Integer", "0", "Índice (0-based) da opção selecionada."),
            ("ItemHeight", "Integer", "42", "Altura tátil de cada linha."),
            ("ActiveColor", "TColor", "$00D97706", "Cor do círculo ativo preenchido.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado ao selecionar qualquer opção.")
        ],
        "example": """procedure TForm1.RadioPagamentoChange(Sender: TObject);
begin
  case RadioPagamento.ItemIndex of
    0: PrepararQrCodePix;
    1: SolicitarDadosCartao;
    2: GerarBoletoBancario;
  end;
end;""",
        "preview_html": """
        <div class="preview-radiogroup">
            <div class="radio-row active"><div class="radio-circle"><div class="radio-dot"></div></div><span>PIX (Instantâneo)</span></div>
            <div class="radio-row"><div class="radio-circle"></div><span>Cartão de Crédito</span></div>
            <div class="radio-row"><div class="radio-circle"></div><span>Boleto Bancário</span></div>
        </div>
        """
    },

    # ---------------- SELEÇÃO, TAGS & FILTROS ----------------
    {
        "id": "TLazDroidSegmentedControl",
        "name": "TLazDroidSegmentedControl",
        "category": "Seleção, Tags & Filtros",
        "cat_id": "filter",
        "parent": "TCustomControl",
        "tagline": "Abas horizontais estilo pílula para filtragem rápida de dados",
        "desc": "Controle segmentado moderno que divide o espaço horizontal em botões conectados com cantos externos curvos. A opção ativa é destacada com preenchimento colorido e texto em contraste.",
        "touch_tip": "Mantenha entre 2 e 4 opções curtas (ex: 'Hoje', 'Semana', 'Mês') para caber confortavelmente em qualquer largura de tela.",
        "props": [
            ("Items", "TStrings", "'Todos\\nAtivos\\nPendentes'", "Opções de abas segmentadas."),
            ("ItemIndex", "Integer", "0", "Aba selecionada no momento."),
            ("ActiveColor", "TColor", "$00D97706", "Cor de preenchimento da pílula ativa."),
            ("CornerRadius", "Integer", "8", "Raio de curvatura da cápsula externa.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado ao alternar o segmento selecionado.")
        ],
        "example": """procedure TForm1.SegmentedPeriodoChange(Sender: TObject);
begin
  FiltrarVendasPorPeriodo(SegmentedPeriodo.ItemIndex);
end;""",
        "preview_html": """
        <div class="preview-segmented">
            <div class="seg-item active">Hoje</div>
            <div class="seg-item">7 Dias</div>
            <div class="seg-item">30 Dias</div>
        </div>
        """
    },
    {
        "id": "TLazDroidChipGroup",
        "name": "TLazDroidChipGroup",
        "category": "Seleção, Tags & Filtros",
        "cat_id": "filter",
        "parent": "TCustomControl",
        "tagline": "Chips/tags filtráveis com suporte a seleção única ou múltipla",
        "desc": "Exibe tags e categorias no formato chip. Suporta seleção simples (filtro exclusivo) ou múltipla com máscara de bits (MultiSelect = True), permitindo filtrar por diversas categorias simultâneas.",
        "touch_tip": "Consulte a propriedade Selected[Index] para checar se determinado chip está ativo em modo múltiplo.",
        "props": [
            ("Items", "TStrings", "'Urgente\\nImportante\\nFinanceiro\\nSuporte'", "Lista de tags/chips."),
            ("ItemIndex", "Integer", "-1", "Índice do chip selecionado em modo simples."),
            ("MultiSelect", "Boolean", "False", "Habilita seleção de vários chips simultaneamente."),
            ("ActiveColor", "TColor", "$00D97706", "Cor de fundo dos chips ativados."),
            ("CornerRadius", "Integer", "14", "Arredondamento das bordas dos chips.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado quando a seleção de qualquer chip é alterada.")
        ],
        "example": """// Verificando múltiplos chips selecionados
procedure TForm1.ChipGroup1Change(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to ChipGroup1.Items.Count - 1 do
    if ChipGroup1.Selected[i] then
      LogTagAtiva(ChipGroup1.Items[i]);
end;""",
        "preview_html": """
        <div class="preview-chips">
            <div class="chip active">✓ Urgente</div>
            <div class="chip active">✓ Financeiro</div>
            <div class="chip">Suporte</div>
            <div class="chip">Vendas</div>
        </div>
        """
    },

    # ---------------- LISTAS, CARDS & VISUALIZAÇÃO ----------------
    {
        "id": "TLazDroidListView",
        "name": "TLazDroidListView",
        "category": "Listas, Cards & Visualização",
        "cat_id": "data",
        "parent": "TCustomControl",
        "tagline": "Lista mobile de alto desempenho com toque, rolagem inercial e badges",
        "desc": "Lista desenhada especificamente para smartphones. Cada linha pode conter título em negrito, subtítulo explicativo, valor monetário/texto à direita e badge de status colorido. Suporta rolagem touch contínua e destaque suave da linha tocada.",
        "touch_tip": "Defina ItemHeight com valor de 64dp para garantir espaço suficiente para títulos de duas linhas e leitura nítida.",
        "props": [
            ("Items", "TLazDroidListItems", "(Collection)", "Coleção de itens da lista (Title, Subtitle, Badge, Value, Tag)."),
            ("ItemHeight", "Integer", "64", "Altura de cada linha da lista em pixels/dp."),
            ("SelectedIndex", "Integer", "-1", "Índice do item selecionado."),
            ("SelectedBgColor", "TColor", "$00E0F2FE", "Cor de destaque ao tocar na linha."),
            ("DividerColor", "TColor", "$00E5E7EB", "Cor da linha divisória sutil entre itens.")
        ],
        "events": [
            ("OnItemClick", "TLazDroidItemClickEvent", "Disparado ao tocar em qualquer item: procedure(Sender: TObject; AIndex: Integer).")
        ],
        "example": """// Preenchendo a lista em tempo de execução
procedure TForm1.CarregarClientes;
var
  Item: TLazDroidListItem;
begin
  ListView1.Items.Clear;
  
  Item := ListView1.Items.Add;
  Item.Title := 'Empresa Alfa Ltda';
  Item.Subtitle := 'Última compra há 2 dias';
  Item.Badge := 'VIP';
  Item.Value := 'R$ 4.590,00';
  Item.Tag := 101;
end;

procedure TForm1.ListView1ItemClick(Sender: TObject; AIndex: Integer);
begin
  AbrirDetalhesCliente(ListView1.Items[AIndex].Tag);
end;""",
        "preview_html": """
        <div class="preview-listview">
            <div class="lv-item selected">
                <div class="lv-avatar">AL</div>
                <div class="lv-info"><div class="lv-title">Empresa Alfa Ltda</div><div class="lv-sub">Última compra há 2 dias</div></div>
                <div class="lv-right"><span class="lv-val">R$ 4.590,00</span><span class="lv-badge">VIP</span></div>
            </div>
            <div class="lv-item">
                <div class="lv-avatar">BS</div>
                <div class="lv-info"><div class="lv-title">Beta Suprimentos</div><div class="lv-sub">Fatura em aberto</div></div>
                <div class="lv-right"><span class="lv-val">R$ 1.250,00</span><span class="lv-badge badge-warn">Pendente</span></div>
            </div>
        </div>
        """
    },
    {
        "id": "TLazDroidCard",
        "name": "TLazDroidCard",
        "category": "Listas, Cards & Visualização",
        "cat_id": "data",
        "parent": "TCustomControl",
        "tagline": "Cartão visual para agrupamento de conteúdos com elevação e bordas suaves",
        "desc": "Contêiner em formato de cartão com cantos arredondados, borda elegante e cabeçalho opcional com título. Usado para organizar formulários, seções de resumos e blocos de dados em cartões destacados da tela de fundo.",
        "touch_tip": "Defina CardColor como clWhite e o fundo da tela como uma cor suave de cinza ($00F8FAFC) para criar profundidade visual e hierarquia.",
        "props": [
            ("HeaderTitle", "string", "''", "Título exibido na barra superior do cartão."),
            ("ShowHeader", "Boolean", "False", "Habilita ou oculta o cabeçalho superior do cartão."),
            ("CornerRadius", "Integer", "12", "Raio dos cantos do cartão."),
            ("CardColor", "TColor", "clWhite", "Cor de preenchimento do corpo do cartão."),
            ("BorderColor", "TColor", "$00E0E0E0", "Cor da borda externa suave.")
        ],
        "events": [],
        "example": """procedure TForm1.FormCreate(Sender: TObject);
begin
  CardEndereco.ShowHeader := True;
  CardEndereco.HeaderTitle := 'Endereço de Entrega';
  CardEndereco.CornerRadius := 12;
end;""",
        "preview_html": """
        <div class="preview-card">
            <div class="card-header">Endereço de Entrega</div>
            <div class="card-body">
                <div><strong>Av. Paulista, 1000 - Cj 52</strong></div>
                <div class="text-sub">Bela Vista - São Paulo / SP - CEP 01310-100</div>
            </div>
        </div>
        """
    },
    {
        "id": "TLazDroidSectionHeader",
        "name": "TLazDroidSectionHeader",
        "category": "Listas, Cards & Visualização",
        "cat_id": "data",
        "parent": "TGraphicControl",
        "tagline": "Divisor de seções com título discreto e linha divisória sutil",
        "desc": "Separador visual idêntico ao utilizado nos aplicativos de Ajustes e Configurações do Android. Exibe um subtítulo temático em letras maiúsculas espaçadas e uma linha horizontal suave que divide grupos de campos.",
        "touch_tip": "Alinhe sempre ao topo (Align = alTop) com altura de 36dp entre blocos de formulários.",
        "props": [
            ("Caption", "string", "'SEGURANÇA & PRIVACIDADE'", "Texto do divisor de seção."),
            ("ShowLine", "Boolean", "True", "Exibe ou oculta a linha divisória horizontal."),
            ("TextColor", "TColor", "$0064748B", "Cor da fonte sutil do divisor."),
            ("LineColor", "TColor", "$00E2E8F0", "Cor da linha sutil.")
        ],
        "events": [],
        "example": """procedure TForm1.ConfigurarTelas;
begin
  SectionHeader1.Caption := 'PREFERÊNCIAS DE FATURAMENTO';
  SectionHeader1.ShowLine := True;
end;""",
        "preview_html": """
        <div class="preview-sectionheader">
            <span class="sh-text">SEGURANÇA & PRIVACIDADE</span>
            <div class="sh-line"></div>
        </div>
        """
    },
    {
        "id": "TLazDroidRatingBar",
        "name": "TLazDroidRatingBar",
        "category": "Listas, Cards & Visualização",
        "cat_id": "data",
        "parent": "TCustomControl",
        "tagline": "Barra de avaliação com estrelas táteis interativas e nota numérica",
        "desc": "Permite registrar pontuações e satisfação de clientes tocando nas estrelas (de 1 a 5, ou quantidade customizada). Cada estrela é desenhada de forma vetorial com cores ativas vibrantes.",
        "touch_tip": "Ajuste StarSize entre 16 e 24dp para permitir toques rápidos sem errar a classificação.",
        "props": [
            ("Rating", "Integer", "0", "Nota atual atribuída (ex: de 0 a 5)."),
            ("StarCount", "Integer", "5", "Quantidade total de estrelas da barra."),
            ("StarSize", "Integer", "12", "Tamanho proporcional das estrelas."),
            ("ActiveColor", "TColor", "$0000C0FF", "Cor dourada/âmbar das estrelas ativas.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado quando o usuário toca em uma estrela para alterar a nota.")
        ],
        "example": """procedure TForm1.RatingBar1Change(Sender: TObject);
begin
  LabelNota.Caption := 'Avaliação: ' + IntToStr(RatingBar1.Rating) + ' de 5 estrelas';
end;""",
        "preview_html": """
        <div class="preview-rating">
            <span class="star filled">★</span>
            <span class="star filled">★</span>
            <span class="star filled">★</span>
            <span class="star filled">★</span>
            <span class="star">☆</span>
            <span class="rating-num">4.0 / 5</span>
        </div>
        """
    },

    # ---------------- PRODUTIVIDADE, FINANÇAS & PDV ----------------
    {
        "id": "TLazDroidKeypad",
        "name": "TLazDroidKeypad",
        "category": "Produtividade, Finanças & PDV",
        "cat_id": "pos",
        "parent": "TCustomControl",
        "tagline": "Teclado numérico touch integrado para PDV, valores monetários e caixas",
        "desc": "Teclado numérico tátil completo diretamente na tela, eliminando a dependência do teclado virtual flutuante do sistema operacional Android. Possui dígitos grandes de 0 a 9, tecla '00' para agilidade de centavos, tecla Limpar (C) e Apagar (Backspace), além de integração automática com qualquer TLazDroidEdit.",
        "touch_tip": "Associe a propriedade TargetEdit ao seu campo de valor e o teclado preencherá e formatará o texto automaticamente sem precisar de uma única linha de código!",
        "props": [
            ("TargetEdit", "TLazDroidEdit", "nil", "Campo de texto que receberá automaticamente os dígitos pressionados."),
            ("Value", "string", "''", "Texto atual do buffer numérico interno."),
            ("ShowDoubleZero", "Boolean", "True", "Exibe ou oculta a tecla '00' útil para digitação de centavos em PDV."),
            ("ButtonColor", "TColor", "$00F8FAFC", "Cor dos botões das teclas numéricas."),
            ("ActionColor", "TColor", "$00D97706", "Cor de destaque das teclas de ação.")
        ],
        "events": [
            ("OnKeyPress", "TLazDroidKeyPressEvent", "Disparado ao pressionar qualquer tecla: procedure(Sender: TObject; const AKey: string)."),
            ("OnEnter", "TNotifyEvent", "Disparado quando a tecla de confirmação/enter é acionada.")
        ],
        "example": """// Vinculando o teclado ao campo de valor da venda
procedure TForm1.FormCreate(Sender: TObject);
begin
  Keypad1.TargetEdit := EditValorVenda;
  Keypad1.ShowDoubleZero := True;
end;

procedure TForm1.Keypad1Enter(Sender: TObject);
begin
  ProcessarPagamento(StrToFloatDef(EditValorVenda.Text, 0));
end;""",
        "preview_html": """
        <div class="preview-keypad">
            <div class="kp-grid">
                <div class="kp-btn">1</div><div class="kp-btn">2</div><div class="kp-btn">3</div>
                <div class="kp-btn">4</div><div class="kp-btn">5</div><div class="kp-btn">6</div>
                <div class="kp-btn">7</div><div class="kp-btn">8</div><div class="kp-btn">9</div>
                <div class="kp-btn kp-action">C</div><div class="kp-btn">0</div><div class="kp-btn kp-action">⌫</div>
            </div>
        </div>
        """
    },
    {
        "id": "TLazDroidSignaturePad",
        "name": "TLazDroidSignaturePad",
        "category": "Produtividade, Finanças & PDV",
        "cat_id": "pos",
        "parent": "TCustomControl",
        "tagline": "Canvas touch para captura de assinatura digital de clientes",
        "desc": "Superfície sensível ao toque que registra traços suaves do dedo ou caneta stylus do cliente para comprovação de entrega, aceite de ordens de serviço e autorizações. Conta com linha de guia de assinatura, limpeza instantânea e exportação para arquivo de imagem.",
        "touch_tip": "Verifique a propriedade IsSigned antes de salvar para garantir que o cliente realmente assinou o documento.",
        "props": [
            ("PenColor", "TColor", "clBlack", "Cor da tinta da assinatura."),
            ("PenWidth", "Integer", "3", "Espessura do traço da caneta."),
            ("WatermarkText", "string", "'Assine aqui sobre a linha'", "Texto sutil de orientação no fundo do canvas."),
            ("CornerRadius", "Integer", "8", "Raio dos cantos do painel de assinatura.")
        ],
        "events": [
            ("OnSigned", "TNotifyEvent", "Disparado no momento em que o primeiro traço é completado.")
        ],
        "example": """procedure TForm1.BtnSalvarEntregaClick(Sender: TObject);
begin
  if not SignaturePad1.IsSigned then
  begin
    ShowMobileToast(Self, 'Solicite a assinatura do cliente antes de prosseguir.');
    Exit;
  end;
  
  // Salva no armazenamento do Android
  SignaturePad1.SaveToFile('/sdcard/Download/assinatura_os123.png');
  ShowMobileToast(Self, 'Assinatura salva com sucesso!');
end;

procedure TForm1.BtnLimparClick(Sender: TObject);
begin
  SignaturePad1.Clear;
end;""",
        "preview_html": """
        <div class="preview-signature">
            <svg class="sig-path" viewBox="0 0 260 80"><path d="M 20 50 Q 50 15, 80 40 T 140 30 T 200 60 T 240 25" fill="none" stroke="#1E293B" stroke-width="2.5" stroke-linecap="round"/></svg>
            <div class="sig-line"></div>
            <div class="sig-watermark">Assine aqui sobre a linha</div>
        </div>
        """
    },
    {
        "id": "TLazDroidMetricCard",
        "name": "TLazDroidMetricCard",
        "category": "Produtividade, Finanças & PDV",
        "cat_id": "pos",
        "parent": "TCustomControl",
        "tagline": "Card de indicador / KPI com valor destacado e badge de tendência",
        "desc": "Componente desenhado para painéis de controle e dashboards executivos móveis. Exibe título da métrica, número com tipografia de destaque, ícone ilustrativo e badge percentual indicando se a tendência é de alta (verde) ou queda (vermelho).",
        "touch_tip": "Combine múltiplos MetricCards dentro de um TLazDroidLayout para obter um dashboard financeiro moderno e responsivo.",
        "props": [
            ("Title", "string", "'Vendas Hoje'", "Nome ou rótulo da métrica exibida."),
            ("Value", "string", "'R$ 14.850'", "Valor numérico formatado em fonte ampliada."),
            ("DeltaText", "string", "'+12.5%'", "Variação percentual ou comparativa com o período anterior."),
            ("DeltaIsPositive", "Boolean", "True", "Se True exibe badge em verde (+), se False em vermelho (-)."),
            ("Icon", "TLazDroidActionIcon", "aiTrendingUp", "Ícone representativo (aiDollar, aiTrendingUp, etc.).")
        ],
        "events": [],
        "example": """procedure TForm1.AtualizarDashboard(const AVendas, AMeta: Double);
var
  Crescimento: Double;
begin
  MetricCard1.Title := 'Faturamento Diário';
  MetricCard1.Value := FormatCurr('R$ #,##0.00', AVendas);
  
  Crescimento := ((AVendas - AMeta) / AMeta) * 100;
  MetricCard1.DeltaText := Format('%.1f%%', [Crescimento]);
  MetricCard1.DeltaIsPositive := (Crescimento >= 0);
end;""",
        "preview_html": """
        <div class="preview-metriccard">
            <div class="mc-top">
                <span class="mc-title">Faturamento Diário</span>
                <div class="mc-icon">💰</div>
            </div>
            <div class="mc-val">R$ 14.850,00</div>
            <div class="mc-bottom">
                <span class="mc-delta pos">▲ +12.5%</span>
                <span class="mc-sub">vs. ontem</span>
            </div>
        </div>
        """
    },
    {
        "id": "TLazDroidAvatar",
        "name": "TLazDroidAvatar",
        "category": "Produtividade, Finanças & PDV",
        "cat_id": "pos",
        "parent": "TCustomControl",
        "tagline": "Foto de perfil circular com iniciais automáticas e badge de status",
        "desc": "Exibe avatar do usuário em formato circular. Caso não haja imagem configurada, gera automaticamente as iniciais a partir do nome (ex: 'Carlos Silva' ➔ 'CS') e calcula uma cor de fundo pastel exclusiva e harmoniosa baseada no hash do nome. Inclui ponto de status online/offline.",
        "touch_tip": "Ideal para cabeçalhos de perfil, listas de mensagens e cartões de operadores de caixa.",
        "props": [
            ("FullName", "string", "'Denize Abreu'", "Nome completo do usuário para cálculo de iniciais e cor."),
            ("ShowStatus", "Boolean", "True", "Exibe ou oculta o círculo indicador de status."),
            ("IsOnline", "Boolean", "True", "Define se o status é verde (Online) ou cinza (Offline)."),
            ("AvatarColor", "TColor", "clNone", "Cor customizada (ou clNone para cálculo dinâmico automático).")
        ],
        "events": [],
        "example": """procedure TForm1.CarregarPerfilUsuario(const ANome: string; AConectado: Boolean);
begin
  AvatarUsuario.FullName := ANome;
  AvatarUsuario.ShowStatus := True;
  AvatarUsuario.IsOnline := AConectado;
end;""",
        "preview_html": """
        <div class="preview-avatar-wrap">
            <div class="preview-avatar">
                <span>DA</span>
                <div class="avatar-status online"></div>
            </div>
            <div class="avatar-meta">
                <div class="meta-name">Denize Abreu</div>
                <div class="meta-sub">Online agora</div>
            </div>
        </div>
        """
    },

    # ---------------- AÇÕES, BOTÕES & INDICADORES ----------------
    {
        "id": "TLazDroidButton",
        "name": "TLazDroidButton",
        "category": "Ações, Botões & Indicadores",
        "cat_id": "action",
        "parent": "TCustomControl",
        "tagline": "Botão touch de alta resposta com cantos curvos, badge e feedback visual",
        "desc": "Substitui o TButton do Lazarus por um botão touch de primeira linha. Suporta estilos visuais modernos (Primário, Secundário, Sucesso, Alerta, Perigo), ícones vetoriais embutidos, badges numéricos flutuantes e escurecimento visual ao ser pressionado.",
        "touch_tip": "Mantenha a altura mínima em 48dp para proporcionar facilidade absoluta de clique.",
        "props": [
            ("Caption", "string", "'Confirmar'", "Texto principal do botão."),
            ("Variant", "TLazDroidButtonVariant", "bvPrimary", "Estilo visual: bvPrimary, bvSecondary, bvSuccess, bvWarning, bvDanger, bvOutlined."),
            ("CornerRadius", "Integer", "10", "Raio de curvatura dos cantos."),
            ("Badge", "string", "''", "Pequeno rótulo de alerta ou contador acoplado ao botão."),
            ("Icon", "TLazDroidActionIcon", "aiNone", "Ícone vetorial exibido ao lado do texto.")
        ],
        "events": [
            ("OnClick", "TNotifyEvent", "Disparado quando o botão é pressionado e solto.")
        ],
        "example": """procedure TForm1.FormCreate(Sender: TObject);
begin
  BtnFinalizar.Caption := 'Finalizar Venda';
  BtnFinalizar.Variant := bvSuccess;
  BtnFinalizar.Icon := aiCheck;
  BtnFinalizar.Badge := '3 itens';
end;""",
        "preview_html": """
        <div class="preview-buttons">
            <div class="btn btn-primary"><span>Confirmar Pedido</span><span class="btn-badge">3</span></div>
            <div class="btn btn-success">✓ Finalizar Venda</div>
            <div class="btn btn-outlined">Cancelar</div>
        </div>
        """
    },
    {
        "id": "TLazDroidFAB",
        "name": "TLazDroidFAB",
        "category": "Ações, Botões & Indicadores",
        "cat_id": "action",
        "parent": "TCustomControl",
        "tagline": "Botão de Ação Flutuante (Floating Action Button) circular com elevação",
        "desc": "O famoso botão circular flutuante das diretrizes de Material Design da Google. Utilizado para a ação mais importante e frequente da tela (ex: Novo Pedido, Adicionar Registro, Escanear Código).",
        "touch_tip": "Posicione com Anchors = [akRight, akBottom] e tamanho padrão de 56x56dp com elevação visual de sombra.",
        "props": [
            ("Icon", "TLazDroidActionIcon", "aiAdd", "Ícone exibido no centro do círculo (aiAdd, aiEdit, aiSearch, etc.)."),
            ("ButtonColor", "TColor", "$00D97706", "Cor de preenchimento do botão flutuante."),
            ("IconColor", "TColor", "clWhite", "Cor do ícone desenhado.")
        ],
        "events": [
            ("OnClick", "TNotifyEvent", "Disparado ao tocar no botão flutuante.")
        ],
        "example": """procedure TForm1.FabNovoItemClick(Sender: TObject);
begin
  AbrirDialogoNovoRegistro;
end;""",
        "preview_html": """
        <div class="preview-fab">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </div>
        """
    },
    {
        "id": "TLazDroidBadge",
        "name": "TLazDroidBadge",
        "category": "Ações, Botões & Indicadores",
        "cat_id": "action",
        "parent": "TGraphicControl",
        "tagline": "Pílula / Crachá de status com cores semânticas de informação",
        "desc": "Pequena etiqueta com cantos 100% arredondados utilizada para demonstrar estados operacionais: Ativo, Cancelado, Pendente, Pago, Rascunho. Possui esquemas de cores pré-configurados.",
        "touch_tip": "Ideal para ser inserida em cabeçalhos de pedidos ou colunas de tabelas para comunicação visual instantânea.",
        "props": [
            ("Caption", "string", "'ATIVO'", "Texto curto do status."),
            ("Style", "TLazDroidBadgeStyle", "bsPrimary", "Estilo semântico: bsPrimary, bsSuccess, bsWarning, bsDanger, bsInfo, bsNeutral.")
        ],
        "events": [],
        "example": """procedure TForm1.DefinirStatus(const AStatus: string);
begin
  BadgeStatus.Caption := AStatus;
  if AStatus = 'Aprovado' then
    BadgeStatus.Style := bsSuccess
  else if AStatus = 'Aguardando' then
    BadgeStatus.Style := bsWarning
  else
    BadgeStatus.Style := bsDanger;
end;""",
        "preview_html": """
        <div class="preview-badges">
            <span class="badge badge-success">✓ APROVADO</span>
            <span class="badge badge-warn">⏳ PENDENTE</span>
            <span class="badge badge-danger">✕ CANCELADO</span>
            <span class="badge badge-info">ℹ EM PROCESSAMENTO</span>
        </div>
        """
    },
    {
        "id": "TLazDroidProgressBar",
        "name": "TLazDroidProgressBar",
        "category": "Ações, Botões & Indicadores",
        "cat_id": "action",
        "parent": "TGraphicControl",
        "tagline": "Barra de progresso linear moderna com cantos arredondados",
        "desc": "Indicador gráfico de avanço para downloads de sincronização, upload de fotos, envio de relatórios e preenchimento de cadastros em etapas. Permite exibir a porcentagem calculada automaticamente.",
        "touch_tip": "Defina Height em 12dp para uma barra elegante ou 20dp quando ativar ShowPercentage = True.",
        "props": [
            ("Min", "Integer", "0", "Valor mínimo da escala."),
            ("Max", "Integer", "100", "Valor máximo da escala."),
            ("Position", "Integer", "30", "Posição atual de progresso."),
            ("BarColor", "TColor", "$00D97706", "Cor da barra de preenchimento ativo."),
            ("ShowPercentage", "Boolean", "False", "Desenha a porcentagem em texto no centro da barra.")
        ],
        "events": [],
        "example": """procedure TForm1.SincronizacaoPasso(const APasso, ATotal: Integer);
begin
  ProgressBar1.Max := ATotal;
  ProgressBar1.Position := APasso;
  ProgressBar1.ShowPercentage := True;
end;""",
        "preview_html": """
        <div class="preview-progress">
            <div class="progress-bar" style="width: 68%;"></div>
        </div>
        <div class="progress-label">Sincronizando produtos: 68% concluído</div>
        """
    },
    {
        "id": "TLazDroidSlider",
        "name": "TLazDroidSlider",
        "category": "Ações, Botões & Indicadores",
        "cat_id": "action",
        "parent": "TCustomControl",
        "tagline": "Barra deslizante touch / Seekbar com cursor arrastável",
        "desc": "Controle deslizante contínuo com indicador circular que pode ser arrastado pelo toque para escolher valores numéricos em tempo real (ex: Volume, Brilho, Desconto percentual, Limite de distância em KM).",
        "touch_tip": "O raio do cursor (ThumbRadius = 9dp) foi calculado para facilitar o arraste sem bloquear a visão do usuário.",
        "props": [
            ("Min", "Integer", "0", "Limite mínimo."),
            ("Max", "Integer", "100", "Limite máximo."),
            ("Position", "Integer", "50", "Valor atualmente apontado pelo cursor."),
            ("ActiveTrackColor", "TColor", "$00D97706", "Cor da trilha ativa à esquerda do cursor."),
            ("ThumbColor", "TColor", "$00D97706", "Cor do botão circular arrastável.")
        ],
        "events": [
            ("OnChange", "TNotifyEvent", "Disparado continuamente conforme o cursor é arrastado pelo dedo.")
        ],
        "example": """procedure TForm1.SliderDescontoChange(Sender: TObject);
begin
  LabelDesconto.Caption := 'Desconto Aplicado: ' + IntToStr(SliderDesconto.Position) + '%';
  RecalcularTotalComDesconto(SliderDesconto.Position);
end;""",
        "preview_html": """
        <div class="preview-slider">
            <div class="slider-track-active" style="width: 50%;"></div>
            <div class="slider-thumb" style="left: 50%;"></div>
        </div>
        <div class="slider-label">Desconto: 50%</div>
        """
    },
    {
        "id": "TLazDroidActivityIndicator",
        "name": "TLazDroidActivityIndicator",
        "category": "Ações, Botões & Indicadores",
        "cat_id": "action",
        "parent": "TGraphicControl",
        "tagline": "Indicador circular giratório animado de espera / carregamento",
        "desc": "Spinner circular elegante que gira continuamente para indicar operações em segundo plano (como requisições HTTP, login, emissão de NFC-e ou carga de banco de dados SQLite).",
        "touch_tip": "Defina Active = True para iniciar a animação ou False para ocultar e pausar o temporizador sem gastar bateria.",
        "props": [
            ("Active", "Boolean", "True", "Ativa ou pausa a rotação contínua do spinner."),
            ("Color", "TColor", "$00D97706", "Cor dos traços giratórios do indicador."),
            ("Speed", "Integer", "100", "Velocidade em milissegundos de cada incremento angular.")
        ],
        "events": [],
        "example": """procedure TForm1.IniciarCarregamento;
begin
  ActivityIndicator1.Active := True;
  ActivityIndicator1.Visible := True;
end;

procedure TForm1.FinalizarCarregamento;
begin
  ActivityIndicator1.Active := False;
  ActivityIndicator1.Visible := False;
end;""",
        "preview_html": """
        <div class="preview-spinner-wrap">
            <div class="spinner"></div>
            <span class="spinner-text">Carregando dados da nuvem...</span>
        </div>
        """
    }
]

# Funções utilitárias globais
UTILS = [
    {
        "name": "ShowMobileToast",
        "signature": "procedure ShowMobileToast(AOwner: TCustomForm; const AMsg: string; ADurationMs: Integer = 2500);",
        "desc": "Exibe uma notificação flutuante temporária (estilo Android Toast) na parte inferior da tela, que surge com cantos arredondados, fundo escuro e desaparece automaticamente após o tempo determinado.",
        "example": "ShowMobileToast(Self, 'Item adicionado ao carrinho com sucesso!');"
    },
    {
        "name": "ShowMobileActionSheet",
        "signature": "function ShowMobileActionSheet(const ATitle: string; const AOptions: array of string; AOwner: TCustomForm = nil): Integer;",
        "desc": "Abre um menu modal deslizante inferior (Bottom Action Sheet) com opções de toque. Retorna o índice (0-based) da opção clicada ou -1 caso o usuário tenha tocado em Cancelar ou fora.",
        "example": """var
  Opcao: Integer;
begin
  Opcao := ShowMobileActionSheet('Gerenciar Pedido', ['Imprimir Comprovante', 'Enviar por WhatsApp', 'Cancelar Pedido'], Self);
  if Opcao = 0 then Imprimir;
  if Opcao = 1 then EnviarWhats;
end;"""
    },
    {
        "name": "ShowMobileDatePicker",
        "signature": "function ShowMobileDatePicker(var ADate: TDateTime; const ATitle: string = 'Selecionar Data'): Boolean;",
        "desc": "Abre diretamente o diálogo modal do calendário tátil para seleção de uma data. Retorna True se o usuário confirmou a nova data.",
        "example": """var
  DataSel: TDateTime;
begin
  DataSel := Date;
  if ShowMobileDatePicker(DataSel, 'Data da Venda') then
    ShowMobileToast(Self, 'Data escolhida: ' + DateToStr(DataSel));
end;"""
    },
    {
        "name": "ShowMobileTimePicker",
        "signature": "function ShowMobileTimePicker(var ATime: TDateTime; const ATitle: string = 'Selecionar Horário'): Boolean;",
        "desc": "Abre o diálogo de relógio touch para seleção de horas e minutos. Retorna True com o novo horário gravado na variável.",
        "example": """var
  HoraSel: TDateTime;
begin
  HoraSel := Time;
  if ShowMobileTimePicker(HoraSel, 'Horário da Visita') then
    ShowMobileToast(Self, 'Horário: ' + TimeToStr(HoraSel));
end;"""
    },
    {
        "name": "MobileDP & MobileSP",
        "signature": "function MobileDP(const AValue: Integer; AControl: TControl = nil): Integer;\nfunction MobileSP(const AValue: Integer; AControl: TControl = nil): Integer;",
        "desc": "Converte valores lógicos de densidade de tela (dp para componentes e sp para fontes) em pixels físicos reais de acordo com o DPI e escala da tela do aparelho Android conectado.",
        "example": "Button1.Height := MobileDP(48, Button1); // Garante 48dp exatos em qualquer tela"
    },
    {
        "name": "AdaptMobileFormLayout",
        "signature": "procedure AdaptMobileFormLayout(AForm: TCustomForm);",
        "desc": "Ajusta as dimensões, fontes e alinhamentos de todos os controles do formulário para se adequarem perfeitamente à resolução nativa do aparelho ao ser executado no Android.",
        "example": """procedure TForm1.FormCreate(Sender: TObject);
begin
  AdaptMobileFormLayout(Self);
end;"""
    }
]

def generate_html():
    total_components = len(COMPONENTS)
    categories = sorted(list(set(c["category"] for c in COMPONENTS)))
    
    html = f"""<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Manual de Referência Completo da Suíte LazDroid - 29 Componentes Mobile Nativos Touch-First para Lazarus e Free Pascal">
    <title>Manual de Referência LazDroid - Componentes Mobile para Lazarus</title>
    <style>
        /* ==========================================================================
           DESIGN SYSTEM & CSS RESET
           ========================================================================== */
        :root {{
            --primary: #d97706;
            --primary-dark: #b45309;
            --primary-light: #fef3c7;
            --primary-rgb: 217, 119, 6;
            --accent: #2563eb;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --dark: #0f172a;
            --slate-800: #1e293b;
            --slate-700: #334155;
            --slate-600: #475569;
            --slate-400: #94a3b8;
            --slate-200: #e2e8f0;
            --slate-100: #f1f5f9;
            --slate-50: #f8fafc;
            --card-bg: #ffffff;
            --border-color: #cbd5e1;
            --code-bg: #1e293b;
            --code-text: #f8fafc;
            --radius-sm: 6px;
            --radius-md: 10px;
            --radius-lg: 16px;
            --radius-full: 9999px;
            --shadow-sm: 0 1px 3px rgba(0,0,0,0.06);
            --shadow-md: 0 4px 12px -2px rgba(0,0,0,0.08);
            --shadow-lg: 0 10px 25px -5px rgba(0,0,0,0.1);
        }}

        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}

        body {{
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: var(--slate-50);
            color: var(--slate-800);
            line-height: 1.6;
            -webkit-font-smoothing: antialiased;
        }}

        /* ==========================================================================
           TOP HEADER & NAVIGATION (TELA WEB)
           ========================================================================== */
        .top-navbar {{
            position: sticky;
            top: 0;
            z-index: 1000;
            background: rgba(15, 23, 42, 0.95);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(255,255,255,0.1);
            color: #ffffff;
            padding: 12px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.15);
        }}

        .nav-brand {{
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: #ffffff;
        }}

        .brand-logo {{
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, #d97706, #f59e0b);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 800;
            font-size: 20px;
            color: #ffffff;
            box-shadow: 0 2px 8px rgba(217,119,6,0.5);
        }}

        .brand-text h1 {{
            font-size: 18px;
            font-weight: 700;
            letter-spacing: -0.5px;
            line-height: 1.2;
        }}

        .brand-text span {{
            font-size: 11px;
            color: var(--slate-400);
            text-transform: uppercase;
            letter-spacing: 1px;
        }}

        .nav-controls {{
            display: flex;
            align-items: center;
            gap: 12px;
            flex: 1;
            max-width: 650px;
            justify-content: flex-end;
        }}

        .search-box-wrap {{
            position: relative;
            flex: 1;
            max-width: 380px;
        }}

        .search-box-wrap input {{
            width: 100%;
            background: rgba(255,255,255,0.12);
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: var(--radius-full);
            padding: 8px 16px 8px 38px;
            color: #ffffff;
            font-size: 13px;
            outline: none;
            transition: all 0.2s ease;
        }}

        .search-box-wrap input:focus {{
            background: rgba(255,255,255,0.2);
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(217,119,6,0.3);
        }}

        .search-box-wrap input::placeholder {{
            color: rgba(255,255,255,0.6);
        }}

        .search-box-wrap svg {{
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            stroke: rgba(255,255,255,0.6);
            pointer-events: none;
        }}

        .btn-pdf {{
            background: linear-gradient(135deg, #d97706, #b45309);
            color: #ffffff;
            border: none;
            padding: 9px 18px;
            border-radius: var(--radius-full);
            font-weight: 600;
            font-size: 13px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: all 0.2s;
            box-shadow: 0 4px 12px rgba(217,119,6,0.3);
            white-space: nowrap;
        }}

        .btn-pdf:hover {{
            background: linear-gradient(135deg, #f59e0b, #d97706);
            transform: translateY(-1px);
            box-shadow: 0 6px 16px rgba(217,119,6,0.4);
        }}

        .btn-pdf:active {{
            transform: translateY(0);
        }}

        /* ==========================================================================
           CONTAINER & LAYOUT
           ========================================================================== */
        .page-container {{
            max-width: 1400px;
            margin: 0 auto;
            padding: 24px;
            display: grid;
            grid-template-columns: 280px 1fr;
            gap: 32px;
        }}

        /* ==========================================================================
           SIDEBAR DE NAVEGAÇÃO
           ========================================================================== */
        .sidebar {{
            position: sticky;
            top: 80px;
            height: calc(100vh - 100px);
            overflow-y: auto;
            padding-right: 8px;
        }}

        .sidebar::-webkit-scrollbar {{
            width: 4px;
        }}

        .sidebar::-webkit-scrollbar-thumb {{
            background: var(--slate-200);
            border-radius: 4px;
        }}

        .sidebar-card {{
            background: #ffffff;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-color);
            padding: 20px;
            box-shadow: var(--shadow-sm);
        }}

        .sidebar-title {{
            font-size: 13px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--slate-400);
            margin-bottom: 12px;
            padding-left: 8px;
        }}

        .cat-group {{
            margin-bottom: 16px;
        }}

        .cat-group-title {{
            font-size: 12px;
            font-weight: 700;
            color: var(--slate-600);
            padding: 6px 8px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }}

        .cat-count {{
            background: var(--slate-100);
            color: var(--slate-600);
            font-size: 10px;
            padding: 2px 6px;
            border-radius: 10px;
        }}

        .sidebar-links {{
            list-style: none;
            margin-top: 4px;
        }}

        .sidebar-links li a {{
            display: block;
            padding: 5px 10px;
            font-size: 13px;
            color: var(--slate-700);
            text-decoration: none;
            border-radius: var(--radius-sm);
            transition: all 0.15s;
        }}

        .sidebar-links li a:hover {{
            background: var(--slate-100);
            color: var(--primary);
            padding-left: 14px;
        }}

        /* ==========================================================================
           MAIN CONTENT & BANNER
           ========================================================================== */
        .main-content {{
            min-width: 0;
        }}

        .hero-banner {{
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            color: #ffffff;
            border-radius: var(--radius-lg);
            padding: 36px 40px;
            margin-bottom: 32px;
            position: relative;
            overflow: hidden;
            box-shadow: var(--shadow-md);
            border: 1px solid rgba(255,255,255,0.08);
        }}

        .hero-banner::after {{
            content: "";
            position: absolute;
            top: -50px;
            right: -50px;
            width: 250px;
            height: 250px;
            background: radial-gradient(circle, rgba(217,119,6,0.25) 0%, rgba(217,119,6,0) 70%);
            border-radius: 50%;
            pointer-events: none;
        }}

        .hero-tag {{
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: rgba(217,119,6,0.2);
            color: #fbbf24;
            border: 1px solid rgba(217,119,6,0.4);
            padding: 4px 12px;
            border-radius: var(--radius-full);
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 16px;
        }}

        .hero-banner h2 {{
            font-size: 32px;
            font-weight: 800;
            letter-spacing: -0.8px;
            margin-bottom: 12px;
            line-height: 1.2;
        }}

        .hero-banner p {{
            font-size: 15px;
            color: #cbd5e1;
            max-width: 760px;
            margin-bottom: 24px;
        }}

        .hero-stats {{
            display: flex;
            gap: 24px;
            flex-wrap: wrap;
            border-top: 1px solid rgba(255,255,255,0.1);
            padding-top: 20px;
        }}

        .stat-item {{
            display: flex;
            flex-direction: column;
        }}

        .stat-number {{
            font-size: 24px;
            font-weight: 800;
            color: #fbbf24;
        }}

        .stat-label {{
            font-size: 12px;
            color: #94a3b8;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }}

        .pdf-instruction-box {{
            background: rgba(254, 243, 199, 0.9);
            border: 1px solid #fde68a;
            border-left: 4px solid var(--primary);
            border-radius: var(--radius-md);
            padding: 14px 18px;
            margin-bottom: 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            color: #78350f;
            font-size: 13.5px;
        }}

        .pdf-instruction-box strong {{
            color: #451a03;
        }}

        /* Filtros por Categoria Pills */
        .category-filter-bar {{
            display: flex;
            gap: 8px;
            overflow-x: auto;
            padding-bottom: 12px;
            margin-bottom: 24px;
        }}

        .cat-pill {{
            background: #ffffff;
            border: 1px solid var(--border-color);
            color: var(--slate-700);
            padding: 6px 14px;
            border-radius: var(--radius-full);
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
            transition: all 0.15s;
        }}

        .cat-pill:hover {{
            background: var(--slate-100);
            border-color: var(--slate-400);
        }}

        .cat-pill.active {{
            background: var(--dark);
            color: #ffffff;
            border-color: var(--dark);
        }}

        /* ==========================================================================
           SEÇÃO INTRODUTÓRIA E DENSIDADE MOBILE
           ========================================================================== */
        .guide-section {{
            background: #ffffff;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-color);
            padding: 28px;
            margin-bottom: 32px;
            box-shadow: var(--shadow-sm);
        }}

        .guide-section h3 {{
            font-size: 20px;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 10px;
        }}

        .guide-section p {{
            font-size: 14px;
            color: var(--slate-600);
            margin-bottom: 16px;
        }}

        .grid-principles {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 16px;
            margin-top: 16px;
        }}

        .principle-card {{
            background: var(--slate-50);
            border: 1px solid var(--slate-200);
            border-radius: var(--radius-md);
            padding: 16px;
        }}

        .principle-card h4 {{
            font-size: 14px;
            font-weight: 700;
            color: var(--slate-800);
            margin-bottom: 6px;
            display: flex;
            align-items: center;
            gap: 6px;
        }}

        .principle-card p {{
            font-size: 12.5px;
            color: var(--slate-600);
            margin-bottom: 0;
        }}

        /* ==========================================================================
           CARD INDIVIDUAL DO COMPONENTE
           ========================================================================== */
        .component-card {{
            background: #ffffff;
            border-radius: var(--radius-lg);
            border: 1px solid var(--border-color);
            margin-bottom: 36px;
            box-shadow: var(--shadow-sm);
            overflow: hidden;
            transition: border-color 0.2s;
        }}

        .component-card:hover {{
            border-color: var(--slate-400);
        }}

        .component-header {{
            background: #ffffff;
            border-bottom: 1px solid var(--slate-200);
            padding: 22px 28px;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 16px;
            flex-wrap: wrap;
        }}

        .comp-title-group h3 {{
            font-size: 22px;
            font-weight: 800;
            color: var(--dark);
            letter-spacing: -0.5px;
            display: flex;
            align-items: center;
            gap: 10px;
        }}

        .comp-heritage {{
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 12px;
            color: var(--slate-400);
            margin-top: 4px;
        }}

        .comp-badge-cat {{
            background: rgba(217,119,6,0.1);
            color: var(--primary-dark);
            border: 1px solid rgba(217,119,6,0.3);
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            padding: 4px 10px;
            border-radius: var(--radius-full);
            letter-spacing: 0.5px;
        }}

        .component-body {{
            padding: 24px 28px;
        }}

        .comp-tagline {{
            font-size: 15px;
            font-weight: 600;
            color: var(--slate-700);
            margin-bottom: 8px;
        }}

        .comp-desc {{
            font-size: 14px;
            color: var(--slate-600);
            margin-bottom: 20px;
        }}

        .comp-touch-tip {{
            background: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-left: 4px solid var(--success);
            padding: 10px 14px;
            border-radius: var(--radius-sm);
            font-size: 12.5px;
            color: #166534;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 8px;
        }}

        /* Simulador / Preview Visual */
        .preview-container {{
            background: #f8fafc;
            border: 1px solid var(--slate-200);
            border-radius: var(--radius-md);
            padding: 24px;
            margin-bottom: 24px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 120px;
        }}

        .preview-title {{
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--slate-400);
            margin-bottom: 14px;
            align-self: flex-start;
        }}

        /* ==========================================================================
           CSS MOCKUPS DOS COMPONENTES (LIVE PREVIEWS)
           ========================================================================== */
        /* AppBar */
        .preview-appbar {{
            width: 100%;
            max-width: 360px;
            height: 56px;
            background: #1e1b4b;
            color: white;
            border-radius: 8px;
            display: flex;
            align-items: center;
            padding: 0 16px;
            gap: 14px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15);
        }}
        .appbar-titles {{
            display: flex;
            flex-direction: column;
            flex: 1;
        }}
        .appbar-title {{
            font-size: 15px;
            font-weight: 700;
            line-height: 1.2;
        }}
        .appbar-subtitle {{
            font-size: 11px;
            color: #cbd5e1;
        }}
        .appbar-back, .appbar-action {{
            cursor: pointer;
            opacity: 0.9;
        }}

        /* BottomNav */
        .preview-bottomnav {{
            width: 100%;
            max-width: 360px;
            height: 56px;
            background: #18181b;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: space-around;
            color: #8e8e93;
            box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
        }}
        .bnav-tab {{
            display: flex;
            flex-direction: column;
            align-items: center;
            font-size: 10px;
            gap: 3px;
            cursor: pointer;
        }}
        .bnav-tab.active {{
            color: #d97706;
            font-weight: 700;
        }}

        /* BottomSheet */
        .preview-bottomsheet {{
            width: 100%;
            max-width: 340px;
            background: #ffffff;
            border-radius: 16px 16px 0 0;
            border: 1px solid var(--slate-200);
            box-shadow: 0 -8px 24px rgba(0,0,0,0.12);
            padding: 12px 16px 16px;
        }}
        .bs-handle {{
            width: 40px;
            height: 4px;
            background: #cbd5e1;
            border-radius: 2px;
            margin: 0 auto 12px;
        }}
        .bs-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-weight: 700;
            font-size: 14px;
            border-bottom: 1px solid var(--slate-100);
            padding-bottom: 8px;
            margin-bottom: 10px;
        }}
        .bs-close {{
            font-size: 20px;
            color: #94a3b8;
            cursor: pointer;
        }}
        .bs-content {{
            display: flex;
            flex-direction: column;
            gap: 8px;
            font-size: 13px;
        }}
        .bs-item {{
            padding: 8px 10px;
            border-radius: 6px;
            background: #f8fafc;
            cursor: pointer;
        }}
        .bs-item.text-danger {{
            color: #dc2626;
            background: #fef2f2;
        }}

        /* SpeedDial */
        .preview-speeddial {{
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 10px;
            width: 100%;
            max-width: 220px;
        }}
        .sd-subitem {{
            display: flex;
            align-items: center;
            gap: 8px;
        }}
        .sd-label {{
            background: #1e293b;
            color: white;
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 11px;
            box-shadow: var(--shadow-sm);
        }}
        .sd-subbtn {{
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: #0284c7;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: var(--shadow-md);
        }}
        .sd-mainbtn {{
            width: 52px;
            height: 52px;
            border-radius: 50%;
            background: #d97706;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 4px 14px rgba(217,119,6,0.5);
            cursor: pointer;
        }}

        /* Layout */
        .preview-layout {{
            width: 100%;
            max-width: 340px;
            display: flex;
            flex-direction: column;
            gap: 8px;
            border: 2px dashed #cbd5e1;
            padding: 12px;
            border-radius: 8px;
        }}
        .layout-child {{
            background: #ffffff;
            border: 1px solid #e2e8f0;
            padding: 10px;
            border-radius: 6px;
            text-align: center;
            font-size: 12px;
            font-weight: 600;
            color: var(--slate-700);
            box-shadow: var(--shadow-sm);
        }}

        /* Edit */
        .preview-edit {{
            width: 100%;
            max-width: 320px;
        }}
        .edit-label {{
            font-size: 11px;
            font-weight: 700;
            color: #d97706;
            display: block;
            margin-bottom: 4px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }}
        .edit-box {{
            background: #ffffff;
            border: 1.5px solid #d0d0d0;
            border-radius: 8px;
            height: 44px;
            padding: 0 12px;
            display: flex;
            align-items: center;
            gap: 4px;
        }}
        .edit-box.focused {{
            border-color: #d97706;
            box-shadow: 0 0 0 3px rgba(217,119,6,0.15);
        }}
        .edit-text {{
            font-size: 13.5px;
            color: var(--slate-800);
        }}
        .edit-cursor {{
            width: 2px;
            height: 18px;
            background: #d97706;
            animation: blink 1s infinite;
        }}
        @keyframes blink {{ 0%, 100% {{ opacity: 1; }} 50% {{ opacity: 0; }} }}

        /* SearchBar */
        .preview-searchbar {{
            width: 100%;
            max-width: 340px;
            height: 44px;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 22px;
            padding: 0 16px;
            display: flex;
            align-items: center;
            gap: 10px;
            box-shadow: var(--shadow-sm);
        }}
        .search-input {{
            flex: 1;
            font-size: 13.5px;
            color: var(--slate-800);
        }}
        .search-clear {{
            width: 20px;
            height: 20px;
            background: #e2e8f0;
            color: #64748b;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
            cursor: pointer;
        }}

        /* OtpBox */
        .preview-otp {{
            display: flex;
            gap: 10px;
            justify-content: center;
        }}
        .otp-box {{
            width: 48px;
            height: 48px;
            border: 2px solid #cbd5e1;
            border-radius: 8px;
            background: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            font-weight: 700;
            color: var(--slate-800);
        }}
        .otp-box.filled {{
            border-color: #94a3b8;
            background: #f8fafc;
        }}
        .otp-box.active {{
            border-color: #d97706;
            color: #d97706;
            box-shadow: 0 0 0 3px rgba(217,119,6,0.15);
        }}

        /* Pickers */
        .preview-picker {{
            width: 100%;
            max-width: 300px;
        }}
        .picker-label {{
            font-size: 11px;
            font-weight: 700;
            color: var(--slate-600);
            display: block;
            margin-bottom: 4px;
        }}
        .picker-box {{
            background: #ffffff;
            border: 1px solid #d0d0d0;
            border-radius: 8px;
            height: 44px;
            padding: 0 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }}
        .picker-val {{
            font-size: 14px;
            font-weight: 600;
            color: var(--slate-800);
        }}

        /* Checkbox */
        .preview-checkbox {{
            display: flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
            padding: 8px 12px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
        }}
        .chk-box {{
            width: 22px;
            height: 22px;
            border: 2px solid #cbd5e1;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        .chk-box.checked {{
            background: #d97706;
            border-color: #d97706;
        }}
        .chk-caption {{
            font-size: 13.5px;
            color: var(--slate-800);
        }}

        /* Switch */
        .preview-switch-row {{
            width: 100%;
            max-width: 320px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            padding: 10px 16px;
            border-radius: 8px;
            font-size: 13.5px;
            color: var(--slate-800);
        }}
        .preview-switch {{
            width: 48px;
            height: 26px;
            background: #e5e7eb;
            border-radius: 13px;
            padding: 2px;
            transition: background 0.2s;
            cursor: pointer;
        }}
        .preview-switch.on {{
            background: #d97706;
        }}
        .switch-thumb {{
            width: 22px;
            height: 22px;
            background: #ffffff;
            border-radius: 50%;
            box-shadow: var(--shadow-sm);
            transform: translateX(0);
            transition: transform 0.2s;
        }}
        .preview-switch.on .switch-thumb {{
            transform: translateX(22px);
        }}

        /* RadioGroup */
        .preview-radiogroup {{
            width: 100%;
            max-width: 320px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            overflow: hidden;
        }}
        .radio-row {{
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 14px;
            font-size: 13.5px;
            border-bottom: 1px solid #f1f5f9;
            cursor: pointer;
        }}
        .radio-row:last-child {{
            border-bottom: none;
        }}
        .radio-row.active {{
            background: #fffbeb;
            color: #b45309;
            font-weight: 600;
        }}
        .radio-circle {{
            width: 20px;
            height: 20px;
            border: 2px solid #94a3b8;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }}
        .radio-row.active .radio-circle {{
            border-color: #d97706;
        }}
        .radio-dot {{
            width: 10px;
            height: 10px;
            background: #d97706;
            border-radius: 50%;
        }}

        /* Segmented */
        .preview-segmented {{
            display: flex;
            background: #f1f5f9;
            padding: 3px;
            border-radius: 8px;
            width: 100%;
            max-width: 320px;
        }}
        .seg-item {{
            flex: 1;
            text-align: center;
            padding: 7px 12px;
            font-size: 13px;
            font-weight: 600;
            color: #475569;
            border-radius: 6px;
            cursor: pointer;
        }}
        .seg-item.active {{
            background: #d97706;
            color: #ffffff;
            box-shadow: var(--shadow-sm);
        }}

        /* Chips */
        .preview-chips {{
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            justify-content: center;
        }}
        .chip {{
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #e2e8f0;
            padding: 6px 14px;
            border-radius: 14px;
            font-size: 12.5px;
            font-weight: 600;
            cursor: pointer;
        }}
        .chip.active {{
            background: #d97706;
            color: #ffffff;
            border-color: #d97706;
        }}

        /* ListView */
        .preview-listview {{
            width: 100%;
            max-width: 340px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            overflow: hidden;
        }}
        .lv-item {{
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 14px;
            border-bottom: 1px solid #f1f5f9;
        }}
        .lv-item.selected {{
            background: #e0f2fe;
        }}
        .lv-avatar {{
            width: 38px;
            height: 38px;
            background: #0284c7;
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: 700;
        }}
        .lv-info {{
            flex: 1;
        }}
        .lv-title {{
            font-size: 13.5px;
            font-weight: 700;
            color: var(--slate-800);
        }}
        .lv-sub {{
            font-size: 11.5px;
            color: var(--slate-600);
        }}
        .lv-right {{
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 4px;
        }}
        .lv-val {{
            font-size: 13px;
            font-weight: 700;
            color: #059669;
        }}
        .lv-badge {{
            font-size: 9.5px;
            font-weight: 700;
            background: #fef3c7;
            color: #b45309;
            padding: 2px 6px;
            border-radius: 4px;
        }}
        .lv-badge.badge-warn {{
            background: #fee2e2;
            color: #b91c1c;
        }}

        /* Card */
        .preview-card {{
            width: 100%;
            max-width: 340px;
            background: #ffffff;
            border: 1px solid #e0e0e0;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: var(--shadow-sm);
        }}
        .card-header {{
            background: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
            padding: 10px 16px;
            font-size: 13px;
            font-weight: 700;
            color: #1e293b;
        }}
        .card-body {{
            padding: 14px 16px;
            font-size: 13px;
            color: #334155;
        }}
        .text-sub {{
            font-size: 11.5px;
            color: #64748b;
            margin-top: 3px;
        }}

        /* SectionHeader */
        .preview-sectionheader {{
            width: 100%;
            max-width: 340px;
            display: flex;
            align-items: center;
            gap: 12px;
        }}
        .sh-text {{
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0.8px;
            color: #64748b;
            white-space: nowrap;
        }}
        .sh-line {{
            flex: 1;
            height: 1px;
            background: #e2e8f0;
        }}

        /* Rating */
        .preview-rating {{
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 24px;
        }}
        .star {{
            color: #cbd5e1;
            cursor: pointer;
        }}
        .star.filled {{
            color: #f59e0b;
        }}
        .rating-num {{
            font-size: 14px;
            font-weight: 700;
            color: #64748b;
            margin-left: 8px;
        }}

        /* Keypad */
        .preview-keypad {{
            width: 100%;
            max-width: 260px;
            background: #f1f5f9;
            border-radius: 12px;
            padding: 12px;
            box-shadow: var(--shadow-sm);
        }}
        .kp-grid {{
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 8px;
        }}
        .kp-btn {{
            background: #ffffff;
            height: 48px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 18px;
            font-weight: 700;
            color: #1e293b;
            box-shadow: 0 1px 2px rgba(0,0,0,0.06);
            cursor: pointer;
        }}
        .kp-btn.kp-action {{
            background: #e2e8f0;
            color: #d97706;
        }}

        /* Signature */
        .preview-signature {{
            width: 100%;
            max-width: 320px;
            height: 120px;
            background: #ffffff;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            position: relative;
            display: flex;
            align-items: flex-end;
            padding: 12px;
            overflow: hidden;
        }}
        .sig-path {{
            position: absolute;
            top: 10px;
            left: 20px;
            width: 260px;
            height: 80px;
        }}
        .sig-line {{
            width: 100%;
            height: 1.5px;
            background: #cbd5e1;
            position: absolute;
            bottom: 30px;
            left: 0;
        }}
        .sig-watermark {{
            font-size: 11px;
            color: #94a3b8;
            width: 100%;
            text-align: center;
            z-index: 1;
        }}

        /* MetricCard */
        .preview-metriccard {{
            width: 100%;
            max-width: 280px;
            background: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 16px;
            box-shadow: var(--shadow-sm);
        }}
        .mc-top {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
        }}
        .mc-title {{
            font-size: 12px;
            font-weight: 600;
            color: #64748b;
        }}
        .mc-icon {{
            font-size: 18px;
        }}
        .mc-val {{
            font-size: 22px;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 8px;
        }}
        .mc-bottom {{
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 11.5px;
        }}
        .mc-delta.pos {{
            background: #dcfce7;
            color: #15803d;
            font-weight: 700;
            padding: 2px 6px;
            border-radius: 4px;
        }}
        .mc-sub {{
            color: #94a3b8;
        }}

        /* Avatar */
        .preview-avatar-wrap {{
            display: flex;
            align-items: center;
            gap: 14px;
        }}
        .preview-avatar {{
            width: 48px;
            height: 48px;
            background: linear-gradient(135deg, #0284c7, #0369a1);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 16px;
            position: relative;
            box-shadow: var(--shadow-sm);
        }}
        .avatar-status {{
            width: 12px;
            height: 12px;
            border-radius: 50%;
            border: 2px solid #ffffff;
            position: absolute;
            bottom: 0;
            right: 0;
        }}
        .avatar-status.online {{
            background: #10b981;
        }}
        .meta-name {{
            font-size: 14px;
            font-weight: 700;
            color: #0f172a;
        }}
        .meta-sub {{
            font-size: 12px;
            color: #10b981;
        }}

        /* Buttons & Badges */
        .preview-buttons {{
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: center;
        }}
        .btn {{
            padding: 10px 18px;
            border-radius: 10px;
            font-size: 13.5px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            box-shadow: var(--shadow-sm);
        }}
        .btn-primary {{
            background: #d97706;
            color: white;
        }}
        .btn-success {{
            background: #10b981;
            color: white;
        }}
        .btn-outlined {{
            background: white;
            border: 1.5px solid #cbd5e1;
            color: #475569;
        }}
        .btn-badge {{
            background: rgba(0,0,0,0.25);
            padding: 1px 6px;
            border-radius: 10px;
            font-size: 11px;
        }}

        .preview-fab {{
            width: 56px;
            height: 56px;
            background: #d97706;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 6px 16px rgba(217,119,6,0.4);
            cursor: pointer;
        }}

        .preview-badges {{
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            justify-content: center;
        }}
        .badge {{
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
        }}
        .badge-success {{ background: #dcfce7; color: #166534; }}
        .badge-warn {{ background: #fef3c7; color: #92400e; }}
        .badge-danger {{ background: #fee2e2; color: #991b1b; }}
        .badge-info {{ background: #e0f2fe; color: #075985; }}

        /* Progress & Slider */
        .preview-progress {{
            width: 100%;
            max-width: 320px;
            height: 12px;
            background: #e5e7eb;
            border-radius: 6px;
            overflow: hidden;
        }}
        .progress-bar {{
            height: 100%;
            background: #d97706;
            border-radius: 6px;
        }}
        .progress-label {{
            font-size: 12px;
            color: #64748b;
            margin-top: 6px;
        }}

        .preview-slider {{
            width: 100%;
            max-width: 320px;
            height: 6px;
            background: #e5e7eb;
            border-radius: 3px;
            position: relative;
            margin: 14px 0 6px;
        }}
        .slider-track-active {{
            height: 100%;
            background: #d97706;
            border-radius: 3px;
        }}
        .slider-thumb {{
            width: 20px;
            height: 20px;
            background: #d97706;
            border: 2px solid #ffffff;
            border-radius: 50%;
            position: absolute;
            top: 50%;
            transform: translate(-50%, -50%);
            box-shadow: var(--shadow-sm);
        }}
        .slider-label {{
            font-size: 12px;
            color: #64748b;
        }}

        /* Spinner */
        .preview-spinner-wrap {{
            display: flex;
            align-items: center;
            gap: 12px;
        }}
        .spinner {{
            width: 26px;
            height: 26px;
            border: 3px solid #e2e8f0;
            border-top: 3px solid #d97706;
            border-radius: 50%;
            animation: spin 0.8s linear infinite;
        }}
        @keyframes spin {{ 0% {{ transform: rotate(0deg); }} 100% {{ transform: rotate(360deg); }} }}
        .spinner-text {{
            font-size: 13px;
            color: #64748b;
        }}

        /* ==========================================================================
           TABELAS DE PROPRIEDADES E EVENTOS
           ========================================================================== */
        .table-wrap {{
            overflow-x: auto;
            margin-bottom: 22px;
            border: 1px solid var(--slate-200);
            border-radius: var(--radius-md);
        }}

        .data-table {{
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
            text-align: left;
        }}

        .data-table th {{
            background: #f8fafc;
            color: var(--slate-700);
            font-weight: 700;
            padding: 10px 14px;
            border-bottom: 1px solid var(--slate-200);
        }}

        .data-table td {{
            padding: 10px 14px;
            border-bottom: 1px solid var(--slate-100);
            color: var(--slate-700);
            vertical-align: top;
        }}

        .data-table tr:last-child td {{
            border-bottom: none;
        }}

        .data-table tr:hover td {{
            background: #fafafa;
        }}

        .prop-name {{
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-weight: 700;
            color: #d97706;
        }}

        .prop-type {{
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 11.5px;
            color: #2563eb;
            background: #eff6ff;
            padding: 2px 6px;
            border-radius: 4px;
            display: inline-block;
        }}

        .prop-default {{
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 11px;
            color: #64748b;
        }}

        /* ==========================================================================
           BLOCOS DE CÓDIGO PASCAL
           ========================================================================== */
        .code-block-wrap {{
            background: var(--code-bg);
            border-radius: var(--radius-md);
            overflow: hidden;
            margin-top: 16px;
            border: 1px solid var(--slate-700);
        }}

        .code-header {{
            background: #111827;
            padding: 8px 16px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 11.5px;
            color: #94a3b8;
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            border-bottom: 1px solid rgba(255,255,255,0.06);
        }}

        .code-header span {{
            display: flex;
            align-items: center;
            gap: 6px;
        }}

        .code-header span::before {{
            content: "";
            width: 8px;
            height: 8px;
            background: #10b981;
            border-radius: 50%;
            display: inline-block;
        }}

        pre.code-content {{
            padding: 16px;
            color: var(--code-text);
            font-family: "JetBrains Mono", Consolas, Menlo, Monaco, "Courier New", monospace;
            font-size: 12.5px;
            line-height: 1.5;
            overflow-x: auto;
            white-space: pre;
        }}

        /* ==========================================================================
           UTILITÁRIOS GLOBAIS
           ========================================================================== */
        .util-card {{
            background: #ffffff;
            border: 1px solid var(--slate-200);
            border-left: 4px solid var(--accent);
            border-radius: var(--radius-md);
            padding: 18px;
            margin-bottom: 16px;
        }}

        .util-name {{
            font-size: 16px;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 4px;
        }}

        .util-sig {{
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 12px;
            color: #2563eb;
            background: #eff6ff;
            padding: 6px 10px;
            border-radius: 6px;
            margin-bottom: 10px;
            display: block;
            overflow-x: auto;
        }}

        /* ==========================================================================
           FOOTER
           ========================================================================== */
        .page-footer {{
            background: #0f172a;
            color: #94a3b8;
            padding: 32px 24px;
            text-align: center;
            font-size: 13px;
            border-top: 1px solid var(--slate-800);
            margin-top: 60px;
        }}

        .page-footer strong {{
            color: #ffffff;
        }}

        /* Floating PDF FAB */
        .fab-pdf-float {{
            position: fixed;
            bottom: 24px;
            right: 24px;
            background: linear-gradient(135deg, #d97706, #b45309);
            color: white;
            border: none;
            width: 56px;
            height: 56px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 6px 20px rgba(217,119,6,0.5);
            cursor: pointer;
            z-index: 999;
            transition: transform 0.2s;
        }}

        .fab-pdf-float:hover {{
            transform: scale(1.08);
        }}

        /* ==========================================================================
           ESTILOS DE IMPRESSÃO / CONVERSÃO EM PDF (@MEDIA PRINT)
           ========================================================================== */
        @media print {{
            @page {{
                size: A4;
                margin: 12mm 10mm 15mm 10mm;
            }}

            /* Ocultar elementos de navegação e botões interativos na folha */
            .top-navbar,
            .sidebar,
            .category-filter-bar,
            .pdf-instruction-box,
            .fab-pdf-float,
            .btn-pdf {{
                display: none !important;
            }}

            body {{
                background: #ffffff !important;
                color: #0f172a !important;
                font-size: 11pt;
            }}

            .page-container {{
                display: block !important;
                max-width: 100% !important;
                padding: 0 !important;
                margin: 0 !important;
            }}

            .hero-banner {{
                background: #0f172a !important;
                color: #ffffff !important;
                page-break-after: avoid;
                margin-bottom: 25px;
                padding: 24px !important;
                border: 1px solid #000 !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }}

            .hero-banner h2 {{
                color: #ffffff !important;
            }}

            .hero-tag, .stat-number {{
                color: #fbbf24 !important;
            }}

            /* Quebra e paginação dos componentes */
            .component-card {{
                break-inside: avoid !important;
                page-break-inside: avoid !important;
                border: 1px solid #cbd5e1 !important;
                box-shadow: none !important;
                margin-bottom: 24px !important;
                background: #ffffff !important;
            }}

            .preview-container {{
                background: #f8fafc !important;
                border: 1px solid #e2e8f0 !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }}

            .component-header {{
                background: #f8fafc !important;
                border-bottom: 1px solid #cbd5e1 !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }}

            .data-table th {{
                background: #f1f5f9 !important;
                color: #0f172a !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }}

            .data-table td {{
                border-bottom: 1px solid #e2e8f0 !important;
            }}

            .code-block-wrap {{
                background: #1e293b !important;
                color: #ffffff !important;
                border: 1px solid #334155 !important;
                break-inside: avoid !important;
                page-break-inside: avoid !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }}

            .code-header {{
                background: #0f172a !important;
                color: #94a3b8 !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }}

            pre.code-content {{
                color: #f8fafc !important;
                font-size: 9.5pt !important;
            }}

            .guide-section {{
                break-inside: avoid !important;
                page-break-inside: avoid !important;
                border: 1px solid #cbd5e1 !important;
                box-shadow: none !important;
            }}

            /* Forçar impressão de fundos e cores */
            * {{
                -webkit-print-color-adjust: exact !important;
                print-color-adjust: exact !important;
            }}
        }}

        @media (max-width: 900px) {{
            .page-container {{
                grid-template-columns: 1fr;
            }}
            .sidebar {{
                display: none;
            }}
        }}
    </style>
</head>
<body>

    <!-- TOPBAR STICKY -->
    <header class="top-navbar">
        <a href="#" class="nav-brand">
            <div class="brand-logo">L</div>
            <div class="brand-text">
                <h1>LazDroid Suite</h1>
                <span>Manual de Referência v1.2</span>
            </div>
        </a>

        <div class="nav-controls">
            <div class="search-box-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
                <input type="text" id="searchInput" placeholder="Pesquisar componentes (ex: Keypad, Edit, Signature)..." oninput="filtrarComponentes()">
            </div>
            <button class="btn-pdf" onclick="window.print()" title="Imprimir ou Salvar em PDF">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 9V2h12v7"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
                Exportar para PDF
            </button>
        </div>
    </header>

    <!-- FLOATING PDF BUTTON -->
    <button class="fab-pdf-float" onclick="window.print()" title="Salvar em PDF / Imprimir Manual">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M6 9V2h12v7"/><path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"/><rect x="6" y="14" width="12" height="8"/></svg>
    </button>

    <div class="page-container">

        <!-- SIDEBAR DE NAVEGAÇÃO RÁPIDA -->
        <aside class="sidebar">
            <div class="sidebar-card">
                <div class="sidebar-title">Índice do Manual</div>
                
                <div class="cat-group">
                    <div class="cat-group-title">
                        <span>Fundamentos</span>
                    </div>
                    <ul class="sidebar-links">
                        <li><a href="#arquitetura">Arquitetura Mobile & DPI</a></li>
                        <li><a href="#utilitarios">Funções Utilitárias & Toasts</a></li>
                    </ul>
                </div>

                <div class="cat-group">
                    <div class="cat-group-title">
                        <span>Componentes ({total_components})</span>
                    </div>
                    <ul class="sidebar-links">
"""

    for comp in COMPONENTS:
        html += f"""                        <li><a href="#{comp['id']}">{comp['name']}</a></li>\n"""

    html += f"""                    </ul>
                </div>
            </div>
        </aside>

        <!-- CONTEÚDO PRINCIPAL -->
        <main class="main-content">

            <!-- BANNER PRINCIPAL / CAPA DO MANUAL -->
            <section class="hero-banner">
                <div class="hero-tag">Android Touch-First Component Suite</div>
                <h2>Manual de Uso dos Componentes LazDroid</h2>
                <p>Guia de referência técnica, propriedades, eventos, boas práticas ergonômicas de toque e snippets prontos em Free Pascal para desenvolvimento de aplicativos modernos de alta performance para Android no Lazarus IDE.</p>
                <div class="hero-stats">
                    <div class="stat-item">
                        <span class="stat-number">{total_components}</span>
                        <span class="stat-label">Componentes Nativos</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">100%</span>
                        <span class="stat-label">Touch-First Nativo</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">Arm64 / v7a</span>
                        <span class="stat-label">Cross-Compilation</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-number">v1.2.0</span>
                        <span class="stat-label">Versão da Suíte</span>
                    </div>
                </div>
            </section>

            <!-- CAIXA DE DICAS DE EXPORTAÇÃO EM PDF -->
            <div class="pdf-instruction-box">
                <div>
                    <strong>📄 Como salvar este manual em PDF:</strong> Clique no botão <em>"Exportar para PDF"</em> no topo ou aperte <kbd>Ctrl+P</kbd>. Na janela de impressão, escolha a impressora <strong>"Salvar como PDF"</strong>, marque a opção <strong>"Gráficos de segundo plano"</strong> e margens <strong>"Padrão"</strong> para obter um documento editorial perfeito e paginado.
                </div>
                <button class="btn-pdf" onclick="window.print()" style="padding: 6px 14px; font-size: 12px;">Gerar PDF Agora</button>
            </div>

            <!-- FILTRO DE CATEGORIAS POR PILLS -->
            <div class="category-filter-bar">
                <button class="cat-pill active" onclick="filtrarCategoria('todas', this)">Todas as Categorias ({total_components})</button>
"""

    for cat in categories:
        count = sum(1 for c in COMPONENTS if c["category"] == cat)
        html += f"""                <button class="cat-pill" onclick="filtrarCategoria('{cat}', this)">{cat} ({count})</button>\n"""

    html += f"""            </div>

            <!-- SEÇÃO DE FUNDAMENTOS E DENSIDADE MOBILE -->
            <section id="arquitetura" class="guide-section">
                <h3>📱 1. Arquitetura Mobile, Densidade (DPI) e Touch Targets</h3>
                <p>O desenvolvimento para smartphones exige cuidados essenciais de ergonomia e variedade de telas. O LazDroid inclui um motor de escala que converte automaticamente valores lógicos de <strong>DP (Density-independent Pixels)</strong> e <strong>SP (Scale-independent Pixels para fontes)</strong> para os pixels físicos do aparelho.</p>
                
                <div class="grid-principles">
                    <div class="principle-card">
                        <h4>🎯 Alvo de Toque de 48dp</h4>
                        <p>Dedos humanos precisam de alvos de no mínimo 48x48dp para evitar cliques acidentais. Todos os controles LazDroid respeitam essa ergonomia por padrão.</p>
                    </div>
                    <div class="principle-card">
                        <h4>📐 Escala Dinâmica DP/SP</h4>
                        <p>Use a função <code>MobileDP(valor, Self)</code> para calcular tamanhos em tempo de execução proporcionalmente à densidade da tela do dispositivo conectado.</p>
                    </div>
                    <div class="principle-card">
                        <h4>⚡ Renderização Vetorial</h4>
                        <p>Ícones e botões são renderizados de maneira vetorial direto no Canvas, garantindo nitidez cristalina em telas FullHD+, 2K e 4K sem distorções.</p>
                    </div>
                </div>
            </section>

            <!-- LISTAGEM DE TODOS OS COMPONENTES -->
"""

    for idx, comp in enumerate(COMPONENTS, 1):
        html += f"""
            <!-- COMPONENTE {idx}: {comp['name']} -->
            <article id="{comp['id']}" class="component-card" data-category="{comp['category']}" data-name="{comp['name'].lower()} {comp['tagline'].lower()}">
                <header class="component-header">
                    <div class="comp-title-group">
                        <h3>
                            <span>{idx}. {comp['name']}</span>
                        </h3>
                        <div class="comp-heritage">Herança: {comp['parent']} | Paleta: 'LazDroid'</div>
                    </div>
                    <div class="comp-badge-cat">{comp['category']}</div>
                </header>

                <div class="component-body">
                    <div class="comp-tagline">{comp['tagline']}</div>
                    <p class="comp-desc">{comp['desc']}</p>
                    
                    <div class="comp-touch-tip">
                        <strong>💡 Dica Touch:</strong> {comp['touch_tip']}
                    </div>

                    <!-- PREVIEW VISUAL DO COMPONENTE -->
                    <div class="preview-container">
                        <div class="preview-title">Visualização / Live Preview Mobile</div>
                        {comp['preview_html']}
                    </div>

                    <!-- TABELA DE PROPRIEDADES -->
                    <h4 style="font-size: 14px; font-weight: 700; margin-bottom: 8px; color: var(--slate-800);">Propriedades Principais (Inspector de Objetos)</h4>
                    <div class="table-wrap">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="width: 25%;">Propriedade</th>
                                    <th style="width: 20%;">Tipo</th>
                                    <th style="width: 15%;">Padrão</th>
                                    <th>Finalidade & Descrição</th>
                                </tr>
                            </thead>
                            <tbody>
"""
        for p in comp["props"]:
            html += f"""                                <tr>
                                    <td><span class="prop-name">{p[0]}</span></td>
                                    <td><span class="prop-type">{p[1]}</span></td>
                                    <td><span class="prop-default">{p[2]}</span></td>
                                    <td>{p[3]}</td>
                                </tr>\n"""

        html += f"""                            </tbody>
                        </table>
                    </div>
"""

        if comp["events"]:
            html += f"""
                    <!-- TABELA DE EVENTOS -->
                    <h4 style="font-size: 14px; font-weight: 700; margin-bottom: 8px; color: var(--slate-800);">Eventos Específicos</h4>
                    <div class="table-wrap">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th style="width: 30%;">Evento</th>
                                    <th style="width: 25%;">Assinatura</th>
                                    <th>Quando Ocorre</th>
                                </tr>
                            </thead>
                            <tbody>
"""
            for ev in comp["events"]:
                html += f"""                                <tr>
                                    <td><span class="prop-name">{ev[0]}</span></td>
                                    <td><span class="prop-type">{ev[1]}</span></td>
                                    <td>{ev[2]}</td>
                                </tr>\n"""
            html += f"""                            </tbody>
                        </table>
                    </div>
"""

        html += f"""
                    <!-- SNIPPET PASCAL -->
                    <h4 style="font-size: 14px; font-weight: 700; margin-bottom: 6px; color: var(--slate-800);">Exemplo de Código em Free Pascal / Lazarus</h4>
                    <div class="code-block-wrap">
                        <div class="code-header">
                            <span>Exemplo de Implementação — {comp['name']}</span>
                            <div>Pascal (ObjFPC)</div>
                        </div>
                        <pre class="code-content"><code>{comp['example']}</code></pre>
                    </div>
                </div>
            </article>
"""

    # SEÇÃO DE FUNÇÕES UTILITÁRIAS
    html += f"""
            <!-- SEÇÃO DE FUNÇÕES UTILITÁRIAS -->
            <section id="utilitarios" class="guide-section">
                <h3>🛠️ 2. Funções Utilitárias Globais & Diálogos Touch</h3>
                <p>A biblioteca <code>LazDroidMobileControls.pas</code> disponibiliza rotinas prontas para invocação direta no código, sem necessidade de instanciar componentes na tela:</p>
"""

    for u in UTILS:
        html += f"""
                <div class="util-card">
                    <div class="util-name">{u['name']}</div>
                    <code class="util-sig">{u['signature']}</code>
                    <p style="font-size: 13.5px; color: var(--slate-700); margin-bottom: 8px;">{u['desc']}</p>
                    <div class="code-block-wrap" style="margin-top: 8px;">
                        <pre class="code-content" style="padding: 10px 14px; font-size: 12px;"><code>{u['example']}</code></pre>
                    </div>
                </div>
"""

    html += f"""
            </section>
        </main>
    </div>

    <!-- RODAPÉ -->
    <footer class="page-footer">
        <p><strong>LazDroid Component Suite</strong> — Suíte de Componentes Mobile Nativos para Lazarus e Free Pascal.</p>
        <p style="margin-top: 6px; font-size: 12px;">Desenvolvido para criar aplicações Android de alta performance e visual estonteante.</p>
    </footer>

    <!-- JAVASCRIPT DE FILTRAGEM E INTERATIVIDADE -->
    <script>
        function filtrarComponentes() {{
            const query = document.getElementById('searchInput').value.toLowerCase().trim();
            const cards = document.querySelectorAll('.component-card');
            
            cards.forEach(card => {{
                const name = card.getAttribute('data-name');
                if (!query || name.includes(query)) {{
                    card.style.display = 'block';
                }} else {{
                    card.style.display = 'none';
                }}
            }});
        }}

        function filtrarCategoria(categoria, btn) {{
            // Atualiza botões
            document.querySelectorAll('.cat-pill').forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            
            const cards = document.querySelectorAll('.component-card');
            cards.forEach(card => {{
                const cat = card.getAttribute('data-category');
                if (categoria === 'todas' || cat === categoria) {{
                    card.style.display = 'block';
                }} else {{
                    card.style.display = 'none';
                }}
            }});
        }}
    </script>
</body>
</html>
"""

    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        f.write(html)
    
    print(f"Sucesso! Manual gerado em: {OUTPUT_FILE}")
    print(f"Tamanho do arquivo: {os.path.getsize(OUTPUT_FILE)} bytes")

if __name__ == "__main__":
    generate_html()
