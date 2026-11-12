<a id="readme-pt"></a>
# LazDroid-Deploy — IDE Plugin, Paleta Mobile & Suite de Deploy Android para Lazarus

<p align="center">
  <b>🇧🇷 Português</b> &nbsp;|&nbsp; <a href="#readme-en">🇺🇸 English</a>
</p>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lazarus: 2.2+](https://img.shields.io/badge/Lazarus-2.2%2B-blue.svg)](https://www.lazarus-ide.org/)
[![Target: Android](https://img.shields.io/badge/Target-Android%205.0%2B%20(API%2021%2B)-green.svg)](https://developer.android.com)
[![Architecture: AArch64](https://img.shields.io/badge/Arch-ARM64%20%7C%20ARMv7-orange.svg)](https://developer.android.com/ndk)
[![Installer: 1-Click GUI](https://img.shields.io/badge/Installer-1--Click%20GUI%20%2B%20Setup.exe-success.svg)](#-instalação-em-1-clique-novo)

**LazDroid** é uma suíte profissional completa para o **Lazarus IDE / Free Pascal (FPC)** que entrega a experiência *"1-Click Deploy & Run (Ctrl+Shift+F9)"* no celular, suporte a **Formulários Visuais LCL reais (CustomDrawn Android)**, banco de dados **SQLite embarcado**, biblioteca com **30 componentes mobile touch-first** e **novos instaladores automáticos em 1-clique**.

---

## ⚡ Instalação em 1-Clique (Novo!)

O **LazDroid** elimina todas as configurações manuais complexas do Lazarus. Agora você conta com **dois novos instaladores** que preparam todo o ambiente Android em menos de 1 minuto:

| Modo de Instalação | Executável / Local | Para Quem é Recomendado | Principais Vantagens |
| :--- | :---: | :--- | :--- |
| **⚡ Assistente Visual Nativo (1-Clique)** | [`Instalar-LazDroid.exe`](Instalar-LazDroid.exe) *(raiz)* | Desenvolvedores que clonam o repositório ou baixam o `.zip` | • Aplicativo nativo em Pascal/LCL<br/>• Painel de diagnóstico visual em tempo real<br/>• Não depende de PowerShell nem permissões de script<br/>• Configura tudo com 1 clique! |
| **📦 Instalador Tradicional Windows (Setup)** | `dist\Setup-LazAndroid.exe` | Clientes, parceiros e novos desenvolvedores | • Instalador padrão Windows (Inno Setup)<br/>• Traz o compilador cruzado FPC Android offline embarcado<br/>• Atalhos no Menu Iniciar para todas as demos e manuais<br/>• Desinstalador oficial |
| **💻 Modo Linha de Comando (CLI / CI)** | `Instalar-LazDroid.cmd --cli` | Scripts de build, DevOps e servidores CI | • Execução automatizada silenciosa<br/>• Parâmetros para diretório customizado do Lazarus |

```
┌────────────────────────────────────────────────────────────────────────┐
│  LazDroid — Assistente de Instalação e Configuração                    │
├────────────────────────────────────────────────────────────────────────┤
│  1. Instalação do Lazarus IDE                                          │
│     Diretório: [ C:\lazarus                               ] [Procurar] │
│     ✔ Lazarus detectado com sucesso! (FPC 3.2.2)                       │
├────────────────────────────────────────────────────────────────────────┤
│  2. Ferramentas do Android & Java (Diagnóstico em Tempo Real)          │
│     ✔ Java JDK: C:\Users\...\AppData\Local\Android\jdk                 │
│     ✔ Android SDK: C:\Users\...\AppData\Local\Android\Sdk (ADB OK)     │
│     ✔ Android NDK: C:\Users\...\Sdk\ndk\21.4.7075529                   │
│     ✔ Compilador FPC AArch64: ppcrossa64.exe                           │
├────────────────────────────────────────────────────────────────────────┤
│  3. Checklist de Configuração Automatizada                             │
│     [X] Compiladores FPC Android    [X] Units RTL Android              │
│     [X] Patches LCL CustomDrawn     [X] Units LCL CustomDrawn Android  │
│     [X] Paleta LazDroidControls     [X] Plugin LazDroidDeploy          │
│     [X] Configurações XML/Props     [X] Reconstrução Lazarus IDE       │
├────────────────────────────────────────────────────────────────────────┤
│  [ ⚡ Instalar Tudo (1-Clique) ]  [ 🔍 Verificar ]  [ 🎨 Layout Delphi ] │
│  [ 🚀 Abrir IDE ]                 [ 📂 Demos ]                         │
├────────────────────────────────────────────────────────────────────────┤
│  Registro de Atividades:                                               │
│  [15:10:00] SUCESSO: Lazarus IDE reconstruído com LazDroid integrado!  │
└────────────────────────────────────────────────────────────────────────┘
```

### 🚀 Como Usar o Assistente Visual Nativo (`Instalar-LazDroid.exe`)
1. Clone ou baixe o repositório:
   ```cmd
   git clone https://github.com/mabreu2022/LazAndroid.git
   cd LazAndroid
   ```
2. Dê um duplo clique no executável [`Instalar-LazDroid.exe`](Instalar-LazDroid.exe) (ou em [`Instalar-LazDroid.cmd`](Instalar-LazDroid.cmd)).
3. O assistente verifica automaticamente os caminhos instalados do **Lazarus**, **Java JDK**, **Android SDK/NDK** e **FPC AArch64**.
4. Clique no botão **"⚡ Instalar Tudo (1-Clique)"**. Em poucos segundos o instalador executará:
   - ✅ Instalação dos compiladores cruzados FPC (`ppcrossa64.exe` e `ppcrossarm.exe`).
   - ✅ Cópia das units da RTL/FCL para `aarch64-android` e `arm-android`.
   - ✅ Aplicação dos patches na LCL CustomDrawn (teclado virtual `csRequiresKeyboardInput` e proteção de fonte `{$ifndef CD_UseNativeText}`).
   - ✅ Compilação da LCL CustomDrawn para `aarch64-android`.
   - ✅ Registro dos pacotes **`LazDroidControls.lpk`** (paleta de 30 componentes) e **`LazDroidDeploy.lpk`** (deploy e menus).
   - ✅ Gravação dos arquivos `lazdroiddeploy.xml` e `scaffold\local.properties`.
   - ✅ Reconstrução da IDE Lazarus com o LazDroid integrado!
5. Clique em **"🎨 Layout Delphi"** para organizar o Lazarus com janelas acopladas (*AnchorDocking*) e em **"🚀 Abrir IDE"** para começar a programar!

### 📦 Como Usar o Instalador de Distribuição para Clientes (`Setup-LazAndroid.exe`)
Para clientes e pessoas que não utilizam Git:
1. Execute o arquivo `dist\Setup-LazAndroid.exe` como Administrador.
2. Siga o assistente de instalação clássico do Windows escolhendo o diretório (padrão: `C:\LazAndroid`).
3. O instalador descompacta o projeto, inclui a cadeia de compilação cruzada FPC Android offline e cria atalhos no Menu Iniciar.
4. Na tela final, confirme a abertura do **Assistente Visual** para concluir a integração com a sua cópia do Lazarus em 1 clique.

---

## 🎯 Funcionalidades Principais

- ⚡ **Deploy em 1-Clique na IDE**: Dispare compilação, empacotamento, instalação e execução com um único atalho (`Ctrl+Shift+F9`) ou botão no menu `Run`.
- 🎯 **Gerenciador de Alvos Estilo Delphi (Target Manager)**: Janela acoplável com **reconhecimento automático de celular via USB (Plug & Play)**, exibição dinâmica do modelo do aparelho sob o nó `Target`, propriedades completas (bateria, tela, ABI, Android) e deploy direto no alvo ativo!
- 🎨 **Componentes LCL Nativos na Tela**: Crie telas usando o **Form Designer do Lazarus** com `TForm`, `TButton`, `TLabel`, `TPanel`, `TPageControl`, `TEdit`, `TCheckBox`, etc., renderizados via LCL CustomDrawn (`customdrawn_android`).
- 📁 **Novo Projeto em 1-Clique**: Registrado no menu `Arquivo -> Novo... -> Aplicação Android (LazDroid)`, já pré-configurando biblioteca JNI, LCLWidgetType, flags de compilador e form inicial.
- 📱 **Detecção e ABI Inteligente**: Detecta celulares conectados via USB (`adb devices -l`), seleciona automaticamente a arquitetura nativa correta (`arm64-v8a` ou `armeabi-v7a`).
- 🔧 **Compilação Nativa FPC de Alta Performance**: Dispara o compilador cruzado Free Pascal (`ppcrossa64`) gerando código de máquina direto ARM64 (`liblazapp.so`), com desempenho equivalente a C/C++ nativo.
- 🗄️ **Banco de Dados SQLite Embarcado**: Suporte integrado com `libsqlite.so` nativa pré-empacotada, permitindo uso de SQLite offline de altíssima performance.
- 📦 **Scaffold Android Robusto**: Host Java leve (`com.pascal.lclproject.LCLActivity`) com gerenciamento de lifecycle, tela cheia, orientação, DPI e eventos de toque.
- 💬 **Canalização de Logs em Tempo Real**: Captura o `stdout`/`stderr` do build e canaliza os logs do Logcat (`__android_log_print` / `tag: lclapp`) diretamente para a aba **Messages** do Lazarus.
- ⚙️ **Painel de Opções Integrado**: Gerenciador de caminhos do SDK, NDK, ADB, JDK e FPC integrado ao diálogo `Tools -> Options` com botão de autodetecção automática.

---

## 📂 Estrutura do Projeto

```
LazAndroid/
├── Instalar-LazDroid.exe                  # ⚡ Assistente Visual Nativo 1-Clique (LCL)
├── Instalar-LazDroid.cmd                  # Launcher inteligente com elevação de UAC
├── Restaurar-Layout-Lazarus.cmd           # 🎨 Organizador de Layout Docado Estilo Delphi
├── Abrir-Livro-LazDroid.cmd               # 📚 Atalho direto para o Livro Oficial
├── Abrir-Manual-Componentes.cmd           # 📖 Atalho para o Manual de Componentes
│
├── package/                               # Pacotes Lazarus Open Tools (IDE Integration)
│   ├── LazDroidDeploy.lpk                 # Plugin mestre de deploy e gerenciamento de alvos
│   ├── LazDroidControls.lpk               # Paleta com 30 componentes visuais mobile
│   ├── LazDroidDeploy_Reg.pas             # Registro de menus, atalhos e ações na IDE
│   ├── LazDroidConfig.pas                 # Persistência de configurações (XML)
│   ├── LazDroidDeviceManager.pas          # Detecção e consulta de aparelhos via ADB
│   └── LazDroidPipeline.pas               # Orquestrador mestre de build em 6 estágios
│
├── scaffold/                              # Template Android pronto para empacotamento
│   ├── build.gradle                       # Gradle root build script
│   ├── gradlew.bat                        # Gradle Wrapper para Windows
│   └── app/                               # Módulo principal da aplicação Android
│       ├── build.gradle                   # Configurações do SDK (minSdk 21, targetSdk 34)
│       └── src/main/
│           ├── AndroidManifest.xml        # Configurado para com.pascal.lclproject.LCLActivity
│           ├── java/.../LCLActivity.java  # Host Java: Canvas LCL, Touch, JNI bridge
│           └── jniLibs/arm64-v8a/         # liblazapp.so e libsqlite.so (AArch64)
│
├── demo/                                  # Demo 1: Força de Vendas e Telas LCL com SQLite
├── demo2/                                 # Demo 2: Exemplo Minimalista "Hello World" LCL
├── demo3/                                 # Demo 3: Demonstração Multi-Aba com PageControl e CRUD
├── demo4/                                 # Demo 4: Vitrine da Paleta Mobile LazDroid Touch-First
├── demo5/                                 # Demo 5: App Comercial Completo (Login + SQLite + BottomNav)
│
├── tools/                                 # Ferramentas, instaladores e scripts auxiliares
│   ├── installer/                         # Script Inno Setup (Setup-LazAndroid.iss) e install.ps1
│   ├── installer_gui/                     # Código-fonte Pascal/LCL do Assistente Visual
│   └── scripts/                           # Restaurar-Layout-Lazarus.ps1 e geradores
│
├── dist/                                  # Pacotes de distribuição gerados (Setup-LazAndroid.exe)
└── docs/                                  # Documentação Técnica, Manuais e Livro Oficial
    ├── ARCHITECTURE.md                    # Arquitetura detalhada e diagramas Mermaid
    ├── INSTALL_GUIDE.md                   # Guia passo a passo de instalação
    ├── livro_lazdroid_desenvolvimento_mobile.html  # Livro Oficial LazDroid (com exportação PDF)
    └── manual_componentes_lazdroid.html   # Manual Interativo da Paleta de Componentes Mobile
```

---

## 📱 Suíte Completa de Componentes Mobile "LazDroid" (30 Componentes)

O **LazDroid** disponibiliza uma biblioteca completa de **30 componentes mobile touch-first**, projetados especificamente para telas de toque Android (Material Design & iOS look-and-feel), eliminando a limitação dos controles tradicionais de desktop do Lazarus.

Todos os componentes ficam disponíveis na paleta **`LazDroid`** do Form Designer:

### 🧭 Navegação & Estrutura
| Componente | Tipo / Ícone | Descrição & Recursos Mobile |
| :--- | :---: | :--- |
| **`TLazDroidAppBar`** | 🧭 Top Bar | Barra superior mobile com título, subtítulo dinâmico, botão Voltar (`OnBackClick`) e menu de ações (`OnActionClick`). |
| **`TLazDroidBottomNav`** | 📌 Tab Bar | Barra de navegação inferior por abas táteis com suporte a ícones vetoriais automáticos, badges numéricos e evento `OnTabSelected`. |
| **`TLazDroidBottomSheet`** | 📥 Modal Drawer | Painel deslizante inferior (gaveta modal) com puxador tátil, ideal para filtros avançados, opções de compartilhamento e ações. |
| **`TLazDroidSpeedDial`** | ⚡ Floating Menu | Botão de ação flutuante expansível que revela múltiplos sub-botões circulares com rotação de ícone ao toque. |
| **`TLazDroidLayout`** | 📐 Responsive Box | Container responsivo de tela com suporte a preenchimento inteligente, bordas arredondadas e rolagem vertical suave. |

### ✏️ Entrada de Dados & Formulários
| Componente | Tipo / Ícone | Descrição & Recursos Mobile |
| :--- | :---: | :--- |
| **`TLazDroidEdit`** | ✏️ Input Field | Campo de entrada moderno com *placeholder*, cantos arredondados e **acionamento automático do teclado virtual nativo do Android**. |
| **`TLazDroidSearchBar`** | 🔍 Search Bar | Barra de pesquisa com ícone de lupa, botão de limpeza rápida (`X`), cantos em pílula e evento disparado ao digitar (`OnSearch`). |
| **`TLazDroidOtpBox`** | 🔢 PIN / OTP Input | Entrada de código de verificação (PIN/SMS de 4 a 6 dígitos) em caixas individuais com salto automático de foco entre os dígitos. |
| **`TLazDroidDatePicker`** | 📅 Date Picker | Seletor de data mobile moderno com calendário popup touch-friendly e formatação regional brasileira automática. |
| **`TLazDroidTimePicker`** | ⏰ Time Picker | Seletor de hora e minutos com alternância 12h/24h e controles em carrossel tátil. |
| **`TLazDroidCheckBox`** | ☑️ CheckBox | Caixa de seleção touch ampliada com animação de preenchimento, ícone de verificação e texto explicativo. |
| **`TLazDroidSwitch`** | 🎚️ Toggle Switch | Interruptor moderno liga/desliga estilo iOS/Material com transição animada e suporte a cores ativas/inativas. |
| **`TLazDroidRadioGroup`** | 🔘 Radio Group | Grupo de opções com seleção mutuamente exclusiva, layout vertical/horizontal e áreas de toque confortáveis. |
| **`TLazDroidSegmentedControl`** | 📑 Segments | Seletor horizontal segmentado com indicador deslizante, ideal para alternância rápida de visualização ou filtros de status. |
| **`TLazDroidChipGroup`** | 🏷️ Filter Chips | Conjunto dinâmico de tags/chips com seleção única ou múltipla para categorização rápida e filtros de catálogo. |

### 📋 Listas & Exibição de Dados
| Componente | Tipo / Ícone | Descrição & Recursos Mobile |
| :--- | :---: | :--- |
| **`TLazDroidListView`** | 📋 Card List | Lista de registros touch com título, subtítulo, badges, imagens 32-bit, valores monetários à direita e **rolagem por arrasto (drag scroll)**. |
| **`TLazDroidCard`** | 🃏 Surface Card | Cartão com elevação, sombra suave, cabeçalho e cantos arredondados para agrupar blocos de informações. |
| **`TLazDroidMetricCard`** | 📊 KPI Card | Cartão especializado para painéis e dashboards de vendas com indicador numérico, rótulo e badge percentual de variação. |
| **`TLazDroidSectionHeader`** | 📑 Section Header | Separador visual de seções com título em destaque e botão de ação textual à direita (*ex: "Ver todos"*). |
| **`TLazDroidImageList`** | 🖼️ Image Manager | Gerenciador de ícones e fotos móveis com suporte a transparência alfa real de 32-bit (PNG) sem perda de qualidade visual. |

### 🔘 Ações, Botões & Feedback
| Componente | Tipo / Ícone | Descrição & Recursos Mobile |
| :--- | :---: | :--- |
| **`TLazDroidButton`** | 🔘 Action Button | Botão com área de toque mínima de 48px, estilos semânticos (*Primary, Success, Danger, Outline*) e ícones vetoriais. |
| **`TLazDroidFAB`** | ➕ Action Button | Floating Action Button circular elevado com sombra projetada, ideal para a ação principal da tela (*ex: Novo Pedido*). |
| **`TLazDroidBadge`** | 🏷️ Status Pill | Pílula semântica de destaque para status (*Pendente, Concluído, Cancelado*) ou contadores de notificação (*ex: 3*). |
| **`TLazDroidProgressBar`** | ⏳ Progress Bar | Barra de progresso com animação suave, indicador percentual centralizado e cores customizáveis por estado. |
| **`TLazDroidSlider`** | 🎚️ Value Slider | Controle deslizante tátil com indicador numérico flutuante para ajuste contínuo de quantidades, volumes ou faixas de preço. |
| **`TLazDroidActivityIndicator`** | 🔄 Spinner | Indicador de carregamento assíncrono com anel giratório moderno, ideal para feedback de consultas ao SQLite ou APIs. |

### 📱 Recursos Especiais Mobile
| Componente | Tipo / Ícone | Descrição & Recursos Mobile |
| :--- | :---: | :--- |
| **`TLazDroidRatingBar`** | ⭐ Star Rating | Avaliação por estrelas táteis (1 a 5 estrelas) com suporte a meia-estrela e toque direto no celular. |
| **`TLazDroidKeypad`** | ⌨️ Numeric Keypad | Teclado numérico virtual mobile dedicado para aplicações de PDV, Frente de Caixa, comandas e digitação ágil de valores. |
| **`TLazDroidSignaturePad`** | ✍️ Signature Pad | Área de captura de assinatura digital por toque com traço suave e exportação direta para bitmap/imagem. |
| **`TLazDroidAvatar`** | 👤 Avatar | Foto de perfil circular com iniciais automáticas de fallback e badge de status de conexão (*Online / Ausente*). |

> 📖 **Manual Interativo da Paleta de Componentes:**  
> Para consultar a documentação interativa de cada propriedade, evento e exemplo de código Pascal para todos os 30 componentes, abra no seu navegador o arquivo:  
> [`docs/manual_componentes_lazdroid.html`](docs/manual_componentes_lazdroid.html) (ou execute o atalho `Abrir-Manual-Componentes.cmd`).

> 📚 **Livro Oficial Completo (HTML & Exportação para PDF):**  
> Criamos um livro técnico completo e diagramado abordando desde a instalação e blindagem do ambiente até a construção do aplicativo comercial de **Força de Vendas com SQLite**:  
> - **Arquivo:** [`docs/livro_lazdroid_desenvolvimento_mobile.html`](docs/livro_lazdroid_desenvolvimento_mobile.html) (ou execute o atalho `Abrir-Livro-LazDroid.cmd`).  
> - **Exportação para PDF:** O livro conta com botão integrado no topo para gerar/imprimir em PDF instantaneamente em formato A4, com capa profissional, sumário, paginação e quebra limpa de capítulos.

---

## 🚀 Demonstrações Prontas para Uso (Demos 1 a 5)

O repositório já inclui 5 aplicações de teste e homologação:

1. **`demo/` (Demo 1 - Força de Vendas LCL)**: Demonstração de formulários visuais reais (`FormLogin.pas`, `FormVendas.pas`) conectados a banco SQLite local.
2. **`demo2/` (Demo 2 - Hello World Minimalista)**: Exemplo leve com um formulário simples, botões e redimensionamento dinâmico.
3. **`demo3/` (Demo 3 - Múltiplas Abas com CRUD)**: Telas divididas com `TPageControl`, `TTabSheet`, campos de edição e visualizadores.
4. **`demo4/` (Demo 4 - Vitrine Touch-First)**: Exibição prática dos 30 componentes da paleta LazDroid em ação no celular.
5. **`demo5/` (Demo 5 - App Comercial Completo)**: Sistema comercial de Força de Vendas com autenticação no SQLite local (`database/app.db`), navegação inferior moderna (`TLazDroidBottomNav`), cadastro de clientes e catálogo de produtos.

### Como Executar uma Demo no Celular:
1. Abra o **Lazarus IDE**.
2. Conecte seu aparelho celular no cabo USB (com *Depuração USB* ativa).
3. Abra qualquer demo (ex: `demo5/project1.lpi`).
4. Pressione:
   ```
   Ctrl + Shift + F9
   ```
5. O LazDroid compila a biblioteca nativa ARM64 (`liblazapp.so`), empacota o APK e instala diretamente no seu celular em segundos!

---

## 🎨 Organizar a IDE no Estilo Delphi (1-Clique)

Se as janelas do Lazarus estiverem desorganizadas ou flutuantes, você pode aplicar o layout docado estilo Delphi diretamente pelo assistente visual (botão **"🎨 Layout Delphi"**) ou executando:
```cmd
Restaurar-Layout-Lazarus.cmd
```
Ele organiza a interface no layout profissional acoplado (*AnchorDocking*) idêntico ao Delphi:
* **Esquerda:** Inspetor de Objetos (Object Inspector com componentes, propriedades e eventos).
* **Centro:** Editor de Código e Form Designer no topo, mensagens e depuração na base.
* **Direita:** Inspetor de Projetos no topo, gerenciador de alvos móveis LazDroid no meio e paleta de componentes na base.
* *(O layout é protegido contra desconfigurações acidentais).*

---

## 📊 Estado dos Componentes LCL no Android

| Componente LCL | Status no Android | Observações |
| :--- | :---: | :--- |
| **Paleta LazDroid (30 Controles)** | ✅ 100% Mobile | AppBar, BottomNav, Card, Badge, Button, Edit, ListView otimizados para touch |
| **TForm** | ✅ Pronto | Maximizado, redimensionamento dinâmico na rotação de tela |
| **TLabel** | ✅ Pronto | Renderização de fontes, quebras, cores e alinhamento |
| **TButton** | ✅ Pronto | Clique por touch, efeito visual pressionado/solto |
| **TPanel** | ✅ Pronto | Containers, cards estilizados, bordas e cores |
| **TPageControl / TTabSheet** | ✅ Pronto | Múltiplas abas com alternância dinâmica |
| **TCheckBox** | ✅ Pronto | Seleção e alternância de estado visual |
| **TImage / TCanvas** | ✅ Pronto | Desenho em canvas, bitmaps e formas primitivas |
| **TEdit / TMemo** | ✅ Pronto | Teclado virtual Android com `csRequiresKeyboardInput` e `adjustResize` |
| **TComboBox** | 🔄 Em adaptação | Recomenda-se disparar diálogo de seleção nativo (Spinner) |
| **TStringGrid / TDBGrid** | 🔄 Em adaptação | Exibição em grade; rolagem touch precisa de inércia suave |
| **Diálogos (ShowMessage)** | ✅ Pronto | Mapeados para `AlertDialog` nativo do Android |
| **Banco SQLite** | ✅ Pronto | Acesso via `libsqlite.so` compilada nativa |

Para detalhes da arquitetura, consulte [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md). Para o guia de instalação passo a passo, veja [`docs/INSTALL_GUIDE.md`](docs/INSTALL_GUIDE.md).

---

## 🤝 Como Contribuir com o Projeto

Contribuições de toda a comunidade Delphi, Lazarus e Free Pascal são muito bem-vindas! Se você deseja sugerir uma melhoria, corrigir um bug ou criar um novo componente mobile:

1. Faça um **Fork** do repositório ([github.com/mabreu2022/LazAndroid](https://github.com/mabreu2022/LazAndroid)).
2. Crie uma branch para sua funcionalidade (`git checkout -b feat/minha-melhoria`).
3. Desenvolva sua alteração e valide a compilação no Lazarus e cross-compilador AArch64.
4. Abra um **Pull Request (PR)** detalhando as mudanças realizadas.

> 🛡️ **Política de Governança & Aprovação:**  
> A branch principal (`main`) possui proteção ativada. Nenhum commit entra diretamente na branch de produção sem passar por **revisão e aprovação explícita do mantenedor (@mabreu2022)**.
> 
> Consulte nosso [Guia de Contribuição Completo (`CONTRIBUTING.md`)](CONTRIBUTING.md) e o [Código de Conduta (`CODE_OF_CONDUCT.md`)](CODE_OF_CONDUCT.md).

---
<br/>

<a id="readme-en"></a>
# LazDroid-Deploy — IDE Plugin, Mobile Palette & Android Deployment Suite for Lazarus

<p align="center">
  <a href="#readme-pt">🇧🇷 Português</a> &nbsp;|&nbsp; <b>🇺🇸 English</b>
</p>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lazarus: 2.2+](https://img.shields.io/badge/Lazarus-2.2%2B-blue.svg)](https://www.lazarus-ide.org/)
[![Target: Android](https://img.shields.io/badge/Target-Android%205.0%2B%20(API%2021%2B)-green.svg)](https://developer.android.com)
[![Architecture: AArch64](https://img.shields.io/badge/Arch-ARM64%20%7C%20ARMv7-orange.svg)](https://developer.android.com/ndk)
[![Installer: 1-Click GUI](https://img.shields.io/badge/Installer-1--Click%20GUI%20%2B%20Setup.exe-success.svg)](#-1-click-installation-new)

**LazDroid** is a comprehensive professional development suite for **Lazarus IDE / Free Pascal (FPC)** that delivers a true *"1-Click Deploy & Run (Ctrl+Shift+F9)"* mobile experience on real devices, with support for real **LCL Visual Forms (CustomDrawn Android)**, native embedded **SQLite database**, a touch-first **30-component palette**, and **brand-new automated 1-click installers**.

---

## ⚡ 1-Click Installation (New!)

**LazDroid** eliminates all complex manual configurations in Lazarus. You can now use **two new automated installers** to get your full Android environment ready in less than 1 minute:

| Installation Mode | Executable / Location | Recommended For | Key Advantages |
| :--- | :---: | :--- | :--- |
| **⚡ Native GUI Assistant (1-Click)** | [`Instalar-LazDroid.exe`](Instalar-LazDroid.exe) *(repo root)* | Developers cloning the Git repo or downloading `.zip` | • Native Pascal / LCL standalone application<br/>• Real-time visual diagnostic dashboard<br/>• No PowerShell execution policy restrictions<br/>• Configures everything with 1 click! |
| **📦 Traditional Windows Setup** | `dist\Setup-LazAndroid.exe` | Clients, partners, and new team members | • Standard Inno Setup wizard installer<br/>• Bundles offline FPC Android toolchain (no 100 MB download needed)<br/>• Start Menu shortcuts for all demos and manuals<br/>• Clean Windows uninstaller |
| **💻 Command-Line / CI Mode** | `Instalar-LazDroid.cmd --cli` | Build scripts, DevOps, and headless CI | • Non-interactive silent execution<br/>• Command-line flags for custom Lazarus paths |

```
┌────────────────────────────────────────────────────────────────────────┐
│  LazDroid — Installation & Environment Configuration Assistant         │
├────────────────────────────────────────────────────────────────────────┤
│  1. Lazarus IDE Installation Directory                                 │
│     Path:      [ C:\lazarus                               ] [ Browse ] │
│     ✔ Lazarus successfully detected! (FPC 3.2.2)                       │
├────────────────────────────────────────────────────────────────────────┤
│  2. Android & Java Toolchain (Real-Time Diagnostics)                   │
│     ✔ Java JDK: C:\Users\...\AppData\Local\Android\jdk                 │
│     ✔ Android SDK: C:\Users\...\AppData\Local\Android\Sdk (ADB OK)     │
│     ✔ Android NDK: C:\Users\...\Sdk\ndk\21.4.7075529                   │
│     ✔ FPC AArch64 Cross-Compiler: ppcrossa64.exe                       │
├────────────────────────────────────────────────────────────────────────┤
│  3. Automated Configuration Checklist                                  │
│     [X] FPC Android Cross-Compilers [X] Android RTL Units              │
│     [X] LCL CustomDrawn Patches     [X] LCL CustomDrawn Android Units  │
│     [X] LazDroidControls Palette    [X] LazDroidDeploy IDE Plugin      │
│     [X] XML / Properties Configs    [X] Lazarus IDE Rebuild            │
├────────────────────────────────────────────────────────────────────────┤
│  [ ⚡ Install All (1-Click) ]     [ 🔍 Verify ]     [ 🎨 Delphi Layout ] │
│  [ 🚀 Open IDE ]                  [ 📂 Demos ]                         │
├────────────────────────────────────────────────────────────────────────┤
│  Activity Log:                                                         │
│  [15:10:00] SUCCESS: Lazarus IDE rebuilt with LazDroid built-in!       │
└────────────────────────────────────────────────────────────────────────┘
```

### 🚀 How to Use the Native GUI Assistant (`Instalar-LazDroid.exe`)
1. Clone or download the repository:
   ```cmd
   git clone https://github.com/mabreu2022/LazAndroid.git
   cd LazAndroid
   ```
2. Double-click the standalone executable [`Instalar-LazDroid.exe`](Instalar-LazDroid.exe) (or run [`Instalar-LazDroid.cmd`](Instalar-LazDroid.cmd)).
3. The assistant automatically scans and validates your installed **Lazarus IDE**, **Java JDK**, **Android SDK/NDK**, and **FPC AArch64**.
4. Click the prominent **"⚡ Install Everything (1-Click)"** button. In seconds, it executes:
   - ✅ Installs FPC cross-compilers (`ppcrossa64.exe` and `ppcrossarm.exe`).
   - ✅ Copies RTL/FCL units for `aarch64-android` and `arm-android`.
   - ✅ Applies LCL CustomDrawn patches (virtual keyboard `csRequiresKeyboardInput` and font fix `{$ifndef CD_UseNativeText}`).
   - ✅ Compiles LCL CustomDrawn for `aarch64-android`.
   - ✅ Registers packages **`LazDroidControls.lpk`** (30 mobile controls) and **`LazDroidDeploy.lpk`** (menus & deploy pipeline).
   - ✅ Writes configuration files `lazdroiddeploy.xml` and `scaffold\local.properties`.
   - ✅ Rebuilds the Lazarus IDE with LazDroid fully built-in!
5. Click **"🎨 Delphi Layout"** to organize Lazarus into docked single-window tabs (*AnchorDocking*) and click **"🚀 Open IDE"** to start coding!

### 📦 How to Use the Windows Setup Installer (`Setup-LazAndroid.exe`)
For clients, team members, and developers without Git:
1. Run `dist\Setup-LazAndroid.exe` as Administrator.
2. Follow the standard Windows setup wizard and select destination (recommended: `C:\LazAndroid`).
3. The installer extracts the suite, bundles the offline FPC Android toolchain, and creates Start Menu shortcuts.
4. On the final screen, check the box to launch the **Visual Setup Assistant** to finish Lazarus configuration with 1 click.

---

## 🎯 Key Features

- ⚡ **1-Click IDE Deployment**: Trigger compilation, packaging, installation, and execution with a single shortcut (`Ctrl+Shift+F9`) or via the `Run` menu.
- 🎯 **Delphi-Style Target Manager**: Dockable window featuring **automatic USB phone detection (Plug & Play)**, dynamic display of connected devices under the `Target` node, comprehensive hardware/OS inspection (battery, screen resolution, ABI, Android version), and direct deployment to the active target!
- 🎨 **Native On-Screen LCL Components**: Design user interfaces using the **Lazarus Form Designer** with `TForm`, `TButton`, `TLabel`, `TPanel`, `TPageControl`, `TEdit`, `TCheckBox`, and more, rendered via LCL CustomDrawn (`customdrawn_android`).
- 📁 **1-Click New Project Wizard**: Registered under `File -> New... -> Android Application (LazDroid)`, pre-configuring JNI library templates, LCLWidgetType, compiler flags, and the initial form.
- 📱 **Smart ABI & Device Detection**: Scans USB-connected devices (`adb devices -l`) and automatically selects the appropriate target architecture (`arm64-v8a` or `armeabi-v7a`).
- 🔧 **High-Performance Native FPC Compilation**: Drives the Free Pascal cross-compiler (`ppcrossa64`) generating direct ARM64 machine code (`liblazapp.so`), achieving native C/C++ execution performance.
- 🗄️ **Embedded SQLite Database**: Pre-bundled with native `libsqlite.so`, enabling ultra-fast, zero-configuration local offline storage.
- 📦 **Robust Android Scaffold**: Lightweight Java host (`com.pascal.lclproject.LCLActivity`) handling lifecycle, full-screen modes, orientation, display DPI, and multi-touch gestures.
- 💬 **Real-Time Logcat Channeling**: Streams build logs and runtime Logcat (`__android_log_print` / `tag: lclapp`) directly into Lazarus' **Messages** window.
- ⚙️ **Integrated Options Panel**: SDK, NDK, ADB, JDK, and FPC path manager built into the IDE under `Tools -> Options` with automatic path detection.

---

## 📂 Project Structure

```
LazAndroid/
├── Instalar-LazDroid.exe                  # ⚡ 1-Click Native GUI Assistant (LCL)
├── Instalar-LazDroid.cmd                  # Smart launcher with UAC auto-elevation
├── Restaurar-Layout-Lazarus.cmd           # 🎨 Delphi-Style Docked Layout Organizer
├── Abrir-Livro-LazDroid.cmd               # 📚 Direct shortcut to the Official Book
├── Abrir-Manual-Componentes.cmd           # 📖 Direct shortcut to Component Manual
│
├── package/                               # Lazarus Open Tools Packages (IDE Integration)
│   ├── LazDroidDeploy.lpk                 # Main deploy plugin & Target Manager
│   ├── LazDroidControls.lpk               # 30-component touch-first mobile palette
│   ├── LazDroidDeploy_Reg.pas             # Menus, shortcuts, and IDE actions registration
│   ├── LazDroidConfig.pas                 # XML configuration persistence
│   ├── LazDroidDeviceManager.pas          # ADB device discovery & inspection
│   └── LazDroidPipeline.pas               # 6-stage master build orchestrator
│
├── scaffold/                              # Gradle Android packaging scaffold
│   ├── build.gradle                       # Root Gradle script
│   ├── gradlew.bat                        # Windows Gradle Wrapper
│   └── app/                               # Main Android application module
│       ├── build.gradle                   # SDK targets (minSdk 21, targetSdk 34)
│       └── src/main/
│           ├── AndroidManifest.xml        # Preconfigured for LCLActivity
│           ├── java/.../LCLActivity.java  # Java host: LCL canvas, touch, JNI bridge
│           └── jniLibs/arm64-v8a/         # liblazapp.so and libsqlite.so (AArch64)
│
├── demo/                                  # Demo 1: Sales Force & LCL Forms with SQLite
├── demo2/                                 # Demo 2: Minimalist "Hello World" LCL example
├── demo3/                                 # Demo 3: Multi-tab layout with PageControl & CRUD
├── demo4/                                 # Demo 4: LazDroid Touch-First Mobile Palette showcase
├── demo5/                                 # Demo 5: Full Commercial App (Login + SQLite + BottomNav)
│
├── tools/                                 # Tools, installers, and helper scripts
│   ├── installer/                         # Inno Setup script (Setup-LazAndroid.iss) & install.ps1
│   ├── installer_gui/                     # Pascal/LCL source code of the GUI Assistant
│   └── scripts/                           # Restaurar-Layout-Lazarus.ps1 and generators
│
├── dist/                                  # Built distribution packages (Setup-LazAndroid.exe)
└── docs/                                  # Technical Documentation, Manuals & Official Book
    ├── ARCHITECTURE.md                    # Detailed architecture & Mermaid diagrams
    ├── INSTALL_GUIDE.md                   # Step-by-step installation guide
    ├── livro_lazdroid_desenvolvimento_mobile.html  # Official Book (with PDF export)
    └── manual_componentes_lazdroid.html   # Interactive Mobile Palette Manual
```

---

## 📱 "LazDroid" Mobile Component Suite (30 Components)

**LazDroid** features a comprehensive library of **30 touch-first mobile components**, specifically engineered for Android touchscreens (Material Design & iOS look-and-feel), breaking free from desktop-oriented controls.

All controls are available under the **`LazDroid`** palette in the Form Designer:

### 🧭 Navigation & Layout
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidAppBar`** | 🧭 Top Bar | Mobile title bar with dynamic title, subtitle, Back button (`OnBackClick`), and action buttons (`OnActionClick`). |
| **`TLazDroidBottomNav`** | 📌 Tab Bar | Bottom navigation bar with touch tabs, automatic vector icons, notification badges, and `OnTabSelected` event. |
| **`TLazDroidBottomSheet`** | 📥 Modal Drawer | Slide-up modal sheet with touch handle, perfect for contextual options, sharing, and filters. |
| **`TLazDroidSpeedDial`** | ⚡ Floating Menu | Expandable Floating Action Button that unfolds into multiple child action buttons with icon rotation. |
| **`TLazDroidLayout`** | 📐 Responsive Box | Responsive screen container with smart padding, rounded corners, and smooth vertical touch scrolling. |

### ✏️ Data Input & Forms
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidEdit`** | ✏️ Input Field | Touch text input with placeholder support, rounded corners, and **automatic Android virtual keyboard activation**. |
| **`TLazDroidSearchBar`** | 🔍 Search Bar | Search bar with search icon, instant clear button (`X`), pill shape, and real-time typing events (`OnSearch`). |
| **`TLazDroidOtpBox`** | 🔢 PIN / OTP Input | Security PIN / SMS verification code input (4-6 digits) in individual boxes with auto-focus advancing. |
| **`TLazDroidDatePicker`** | 📅 Date Picker | Touch date selector with mobile popup calendar and localized date formatting. |
| **`TLazDroidTimePicker`** | ⏰ Time Picker | Hour and minute selector with 12h/24h toggle and touch carousel controls. |
| **`TLazDroidCheckBox`** | ☑️ CheckBox | Expanded touch checkbox with smooth fill animation, checkmark, and label. |
| **`TLazDroidSwitch`** | 🎚️ Toggle Switch | iOS/Material style on/off toggle switch with animated transitions and active/inactive colors. |
| **`TLazDroidRadioGroup`** | 🔘 Radio Group | Mutually exclusive radio buttons with vertical/horizontal layout and comfortable touch areas. |
| **`TLazDroidSegmentedControl`** | 📑 Segments | Horizontal segmented control with sliding pill indicator for quick view toggling or filters. |
| **`TLazDroidChipGroup`** | 🏷️ Filter Chips | Dynamic chip/tag collection supporting single or multi-selection for categories and filters. |

### 📋 Lists & Data Display
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidListView`** | 📋 Card List | Mobile card list with title, subtitle, badges, 32-bit images, right-aligned currency, and **touch drag scrolling**. |
| **`TLazDroidCard`** | 🃏 Surface Card | Elevated surface card with soft shadow, header, and rounded corners to group related information. |
| **`TLazDroidMetricCard`** | 📊 KPI Card | Specialized dashboard card with key numeric metric, label, and percentage variance badge. |
| **`TLazDroidSectionHeader`** | 📑 Section Header | Visual section divider with bold title and optional action link (*e.g., "See all"*). |
| **`TLazDroidImageList`** | 🖼️ Image Manager | Mobile image and icon manager supporting true 32-bit alpha transparency (PNG) without visual loss. |

### 🔘 Actions, Buttons & Feedback
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidButton`** | 🔘 Action Button | Touch-sized button (min 48px), semantic variants (*Primary, Success, Danger, Outline*), and vector icons. |
| **`TLazDroidFAB`** | ➕ Action Button | Floating Action Button with elevated drop shadow, ideal for primary screen actions (*e.g., New Order*). |
| **`TLazDroidBadge`** | 🏷️ Status Pill | Semantic status badge (*Pending, Completed, Cancelled*) or notification counter pill (*e.g., 3*). |
| **`TLazDroidProgressBar`** | ⏳ Progress Bar | Smooth progress bar with centered percentage label and customizable state colors. |
| **`TLazDroidSlider`** | 🎚️ Value Slider | Touch slider with floating bubble value indicator for continuous adjustments. |
| **`TLazDroidActivityIndicator`** | 🔄 Spinner | Modern circular loading spinner for asynchronous SQLite queries or network requests. |

### 📱 Special Mobile Features
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidRatingBar`** | ⭐ Star Rating | Interactive touch star rating (1 to 5 stars) with half-star precision. |
| **`TLazDroidKeypad`** | ⌨️ Numeric Keypad | Dedicated virtual numeric keypad for POS, order processing, and rapid data entry. |
| **`TLazDroidSignaturePad`** | ✍️ Signature Pad | Touch digital signature capture area with smooth curves and direct bitmap export. |
| **`TLazDroidAvatar`** | 👤 Avatar | Circular user avatar with automatic fallback initials and online/offline status badge. |

> 📖 **Interactive Component Palette Manual:**  
> To explore documentation, properties, events, and Pascal code examples for all 30 components, open in your browser:  
> [`docs/manual_componentes_lazdroid.html`](docs/manual_componentes_lazdroid.html) (or run the shortcut `Abrir-Manual-Componentes.cmd`).

> 📚 **Official Book (HTML & PDF Export):**  
> We wrote a comprehensive technical guide covering environment setup through building a full **Sales Force Application with SQLite**:  
> - **File:** [`docs/livro_lazdroid_desenvolvimento_mobile.html`](docs/livro_lazdroid_desenvolvimento_mobile.html) (or run `Abrir-Livro-LazDroid.cmd`).  
> - **PDF Export:** Includes an instant top button to generate/print an A4-format PDF with professional cover, TOC, pagination, and clean chapter breaks.

---

## 🚀 Ready-to-Run Demos (Demos 1 to 5)

The repository comes with 5 complete, ready-to-run showcase projects:

1. **`demo/` (Demo 1 - LCL Sales Force)**: Real visual forms (`FormLogin.pas`, `FormVendas.pas`) connected to a local SQLite database.
2. **`demo2/` (Demo 2 - Minimalist Hello World)**: Lightweight form demonstrating button clicks, dialogs, and dynamic rotation resizing.
3. **`demo3/` (Demo 3 - Multi-Tab CRUD)**: Multi-tab layout using `TPageControl`, `TTabSheet`, edit controls, and mock CRUD operations.
4. **`demo4/` (Demo 4 - Touch-First Showcase)**: Live gallery of all 30 LazDroid mobile components operating on Android.
5. **`demo5/` (Demo 5 - Full Commercial App)**: Complete Sales Force app with local SQLite authentication (`database/app.db`), bottom tab navigation (`TLazDroidBottomNav`), customer management, and product catalog.

### How to Run a Demo on Your Phone:
1. Open **Lazarus IDE**.
2. Connect your mobile phone via USB cable (with *USB Debugging* enabled).
3. Open any demo project (e.g., `demo5/project1.lpi`).
4. Press:
   ```
   Ctrl + Shift + F9
   ```
5. LazDroid compiles the native ARM64 library (`liblazapp.so`), builds the APK, and deploys it straight to your device in seconds!

---

## 🎨 Organize the IDE in Delphi Style (1-Click)

If Lazarus' windows are floating or disorganized, apply the Delphi-style docked layout directly from the GUI Assistant (**"🎨 Delphi Layout"** button) or by running:
```cmd
Restaurar-Layout-Lazarus.cmd
```
This organizes the interface into a docked layout (*AnchorDocking*) identical to Delphi:
* **Left:** Object Inspector (components, properties, and events).
* **Center:** Code Editor and Form Designer at the top, Messages and Debugging at the bottom.
* **Right:** Project Inspector at the top, LazDroid Mobile Target Manager in the middle, and Component Palette at the bottom.
* *(The layout is locked against accidental rearrangement).*

---

## 📊 LCL Component Status on Android

| LCL Component | Status on Android | Notes |
| :--- | :---: | :--- |
| **LazDroid Palette (30 Controls)** | ✅ 100% Mobile | AppBar, BottomNav, Card, Badge, Button, Edit, ListView optimized for touch |
| **TForm** | ✅ Ready | Maximized, dynamic resizing on screen rotation |
| **TLabel** | ✅ Ready | Font rendering, word wrap, colors, and alignment |
| **TButton** | ✅ Ready | Touch click, pressed/released visual states |
| **TPanel** | ✅ Ready | Containers, styled cards, borders, and colors |
| **TPageControl / TTabSheet** | ✅ Ready | Multiple tabs with dynamic switching |
| **TCheckBox** | ✅ Ready | Selection and visual toggle state |
| **TImage / TCanvas** | ✅ Ready | Canvas drawing, bitmaps, and primitive shapes |
| **TEdit / TMemo** | ✅ Ready | Android virtual keyboard via `csRequiresKeyboardInput` and `adjustResize` |
| **TComboBox** | 🔄 In Adaptation | Native selection dialog (Spinner) recommended |
| **TStringGrid / TDBGrid** | 🔄 In Adaptation | Grid display; touch scrolling requires smooth inertia |
| **Dialogs (ShowMessage)** | ✅ Ready | Mapped to native Android `AlertDialog` |
| **SQLite Database** | ✅ Ready | Direct access via native compiled `libsqlite.so` |

For architectural details, refer to [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md). For step-by-step installation instructions, see [`docs/INSTALL_GUIDE.md`](docs/INSTALL_GUIDE.md).

---

## 🤝 How to Contribute

Contributions from the entire Delphi, Lazarus, and Free Pascal community are warmly welcomed! If you would like to suggest an improvement, report or fix a bug, or create a new mobile component:

1. **Fork** the repository ([github.com/mabreu2022/LazAndroid](https://github.com/mabreu2022/LazAndroid)).
2. Create a branch for your feature (`git checkout -b feat/my-improvement`).
3. Develop your changes and verify compilation in Lazarus and the AArch64 cross-compiler.
4. Open a **Pull Request (PR)** detailing the changes made.

> 🛡️ **Governance & Approval Policy:**  
> The main branch (`main`) has protection enabled. No commits are merged directly into production without **explicit review and approval by the maintainer (@mabreu2022)**.
> 
> Please read our [Full Contribution Guide (`CONTRIBUTING.md`)](CONTRIBUTING.md) and [Code of Conduct (`CODE_OF_CONDUCT.md`)](CODE_OF_CONDUCT.md).
