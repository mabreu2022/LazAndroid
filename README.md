<a id="readme-pt"></a>
# LazDroid-Deploy — IDE Plugin & Pipeline de Deploy Android para Lazarus

<p align="center">
  <b>🇧🇷 Português</b> &nbsp;|&nbsp; <a href="#readme-en">🇺🇸 English</a>
</p>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lazarus: 2.2+](https://img.shields.io/badge/Lazarus-2.2%2B-blue.svg)](https://www.lazarus-ide.org/)
[![Target: Android](https://img.shields.io/badge/Target-Android%205.0%2B%20(API%2021%2B)-green.svg)](https://developer.android.com)
[![Architecture: AArch64](https://img.shields.io/badge/Arch-ARM64%20%7C%20ARMv7-orange.svg)](https://developer.android.com/ndk)

**LazDroid-Deploy** é uma suíte de automação profissional (Open Tools Package) para o **Lazarus IDE / Free Pascal (FPC)** que entrega a experiência *"1-Click Deploy & Run (Ctrl+Shift+F9)"* com suporte a **Formulários Visuais LCL reais (CustomDrawn Android)**, idêntica ao ecossistema Delphi e Android Studio.

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
d:\Projetos AntiGravity\LazarusAndroid\
├── package/                                # Pacote Lazarus Open Tools (IDE Integration)
│   ├── LazDroidDeploy.lpk                 # Pacote principal para instalar na IDE
│   ├── LazDroidDeploy_Reg.pas             # Registro de menus, atalhos e ações na IDE
│   ├── LazDroidConfig.pas                 # Persistência de configurações (XML)
│   ├── LazDroidConfigFrame.pas/.lfm       # Frame de configuração em Tools -> Options
│   ├── LazDroidDeviceManager.pas          # Detecção e consulta de aparelhos via ADB
│   ├── LazDroidDeviceSelectDlg.pas/.lfm   # Diálogo modal de seleção de aparelho USB
│   ├── LazDroidProcessRunner.pas          # Executor assíncrono multithread com pipes
│   ├── LazDroidProjectDescriptor.pas      # Assistente de Novo Projeto Android na IDE
│   └── LazDroidPipeline.pas               # Orquestrador mestre em 6 estágios
│
├── scaffold/                              # Template Android pronto para empacotamento
│   ├── build.gradle                       # Gradle root build script
│   ├── gradlew.bat                        # Gradle Wrapper para Windows
│   └── app/                               # Módulo principal da aplicação Android
│       ├── build.gradle                   # Configurações do SDK (minSdk 21, targetSdk 34)
│       └── src/main/
│           ├── AndroidManifest.xml        # Configurado para com.pascal.lclproject.LCLActivity
│           ├── java/.../LCLActivity.java  # Host Java: Canvas LCL, Touch, JNI bridge
│           └── jniLibs/                   # Injeção das bibliotecas compiladas
│               └── arm64-v8a/             # liblazapp.so e libsqlite.so (AArch64)
│
├── demo/                                  # Aplicação Completa de Força de Vendas (SQLite)
│   ├── LazAndroidDemo.lpr                 # Ponto de entrada JNI
│   ├── FormLogin.pas/.lfm                 # Formulário LCL de Login
│   ├── FormVendas.pas/.lfm                # Formulário LCL de Painel e Vendas
│   ├── SalesDatabase.pas                  # Conexão e queries SQLite
│   └── vendas.db                          # Banco de dados de exemplo
│
├── demo2/                                 # Exemplo Minimalista "Hello World" LCL
│   ├── project1.lpr                       # Inicialização LCL
│   └── unit1.pas/.lfm                     # TForm1 com TButton e diálogo modal
│
├── demo3/                                 # Demonstração Avançada Multi-Aba (CRUD Mock)
│   ├── demo3.lpr                          # Inicialização LCL com Activity
│   └── unit1.pas/.lfm                     # TPageControl, TTabSheet, TPanel, TEdit, TLabel
│
├── demo4/                                 # Demonstração da Paleta Mobile LazDroid
│   ├── demo4.lpr                          # Ponto de entrada JNI
│   └── unit1.pas/.lfm                     # AppBar, BottomNav, Card, Badge, Edit, Button, ListView
│
├── demo5/                                 # App Comercial Completo (Login + SQLite + BottomNav)
│   ├── project1.lpr                       # Ponto de entrada JNI com Activity
│   ├── unit1.pas/.lfm                     # Tela de Login autenticando no SQLite
│   ├── unit3.pas/.lfm                     # Tela Principal com BottomNav (Produtos, Pedidos, Clientes, Config)
│   ├── unit4.pas/.lfm                     # DataModule com TSQLite3Connection e queries
│   ├── database/app.db                    # Banco de dados SQLite com 5 tabelas e dados de teste
│   └── imagens/                           # Catálogo de imagens e ícones PNG
│
├── tools/                                 # Utilitários, SQLite, Scripts e Instalador
└── docs/                                  # Documentação Técnica e Guias
    ├── ARCHITECTURE.md                    # Arquitetura detalhada e diagramas Mermaid
    ├── INSTALL_GUIDE.md                   # Guia passo a passo de instalação e uso
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

> 📖 **Manual de Referência Rápida da Paleta:**  
> Para consultar a documentação interativa de cada propriedade, evento e exemplo de código Pascal para todos os 30 componentes, abra no seu navegador o arquivo:  
> [`docs/manual_componentes_lazdroid.html`](docs/manual_componentes_lazdroid.html) (ou execute o atalho `Abrir-Manual-Componentes.cmd`).

> 📚 **Livro Oficial Completo (HTML & Exportação para PDF):**  
> Criamos um livro técnico completo e diagramado abordando desde a instalação e blindagem do ambiente até a construção do aplicativo comercial de **Força de Vendas com SQLite**:  
> - **Arquivo:** [`docs/livro_lazdroid_desenvolvimento_mobile.html`](docs/livro_lazdroid_desenvolvimento_mobile.html) (ou execute o atalho `Abrir-Livro-LazDroid.cmd`).  
> - **Exportação para PDF:** O livro conta com botão integrado no topo para gerar/imprimir em PDF instantaneamente em formato A4, com capa profissional, sumário, paginação e quebra limpa de capítulos.


---

## 🛠️ Guia de Instalação e Configuração

O **LazDroid** oferece três formas práticas de instalação e configuração para atender desde usuários finais e iniciantes até ambientes corporativos e integração contínua (CI):

### 📦 Opção 1: Instalador Windows para Clientes (`Setup-LazAndroid.exe`)
Ideal para distribuição para clientes, novos desenvolvedores ou quem prefere o padrão tradicional de instalação do Windows:
1. Baixe ou execute o instalador `dist\Setup-LazAndroid.exe` (ou da aba *Releases* do GitHub).
2. Execute o instalador como Administrador.
3. Escolha o diretório de destino (padrão recomendado: `C:\LazAndroid`).
4. O instalador descompacta o projeto, inclui a toolchain FPC Android offline, cria atalhos no Menu Iniciar para todas as demos, manuais e ferramentas.
5. Na última tela, marque a opção para executar o **Assistente Visual LazDroid** e concluir a configuração do Lazarus com 1 clique!

---

### ⚡ Opção 2: Assistente Visual Nativo 1-Clique (`Instalar-LazDroid.exe`)
Ideal para quem clonou o repositório ou baixou o `.zip`:
1. Abra a raiz do projeto clonado:
   ```cmd
   git clone https://github.com/mabreu2022/LazAndroid.git
   cd LazAndroid
   ```
2. Dê um duplo clique em:
   ```cmd
   Instalar-LazDroid.exe
   ```
   *(ou execute `Instalar-LazDroid.cmd`, que solicita elevação de administrador automaticamente).*
3. Uma interface gráfica nativa desenvolvida em Pascal/LCL é aberta:
   - Exibe em tempo real o status de detecção do **Lazarus IDE**, **Java JDK**, **Android SDK/NDK** e compilador cruzado **FPC AArch64**.
   - Permite verificar o ambiente a qualquer momento pelo botão **"🔍 Verificar"**.
   - Clique no botão principal **"⚡ Instalar Tudo (1-Clique)"** para executar automaticamente:
     - ✅ Instalação dos compiladores cruzados FPC (`ppcrossa64.exe` e `ppcrossarm.exe`).
     - ✅ Cópia das units da RTL Android (`aarch64-android` e `arm-android`).
     - ✅ Aplicação dos patches LCL CustomDrawn (teclado virtual móvel e compatibilidade de fontes).
     - ✅ Compilação da LCL CustomDrawn para `aarch64-android`.
     - ✅ Registro dos pacotes `LazDroidControls.lpk` (29 componentes) e `LazDroidDeploy.lpk` (pipeline IDE).
     - ✅ Autodetecção das ferramentas Android e gravação de `lazdroiddeploy.xml` e `local.properties`.
     - ✅ Reconstrução da IDE Lazarus com o LazDroid integrado.
   - Oferece botões auxiliares para **"🎨 Layout Delphi"** (acopla as janelas da IDE em abas) e **"🚀 Abrir IDE"**.

---

### 💻 Opção 3: Modo Linha de Comando / CI (`Instalar-LazDroid.cmd --cli`)
Para scripts automatizados, DevOps ou quem prefere terminal:
```cmd
Instalar-LazDroid.cmd --cli
```
Ou diretamente pelo PowerShell:
```powershell
.\tools\installer\install.ps1 -NonInteractive -RebuildIDE
```

---

### 🎨 Organizar a IDE no Estilo Delphi (Opcional, porém Recomendado)

Se as janelas do Lazarus estiverem desorganizadas ou flutuantes, você pode aplicar o layout docado estilo Delphi diretamente pelo assistente visual (botão **"🎨 Layout Delphi"**) ou executando:
```cmd
Restaurar-Layout-Lazarus.cmd
```
Ele organiza a interface no layout profissional acoplado (*AnchorDocking*) idêntico ao Delphi:
* **Esquerda:** Inspetor de Objetos (Object Inspector com componentes, propriedades e eventos).
* **Centro:** Editor de Código e Form Designer no topo, mensagens e depuração na base.
* **Direita:** Inspetor de Projetos no topo, gerenciador de alvos móveis LazDroid no meio e paleta de componentes na base.
* *(O layout é bloqueado como somente leitura contra desconfigurações acidentais).*

---

### 4. Como Testar e Executar seu Primeiro Deploy

1. Abra o **Lazarus IDE**.
2. Conecte seu aparelho celular no cabo USB (com *Depuração USB* ativa).
3. Abra qualquer um dos projetos de demonstração prontos:
   * **`demo5/project1.lpi`**: Aplicativo completo de vendas com **Login**, banco **SQLite local (`database/app.db`)** e navegação por abas (**`TLazDroidBottomNav`**).
   * **`demo4/demo4.lpi`**: Demonstração de botões, cards, badges, inputs e listview touch-first.
   * **`demo/LazAndroidDemo.lpi`**: Força de vendas com formulários visuais LCL.
4. Pressione o atalho:
   ```
   Ctrl + Shift + F9
   ```
   *(Ou clique no menu `Run -> Deploy & Run on Android Device`)*.
5. O LazDroid compilará a biblioteca nativa ARM64 (`liblazapp.so`), empacotará o APK com o Gradle e instalará o aplicativo direto no seu celular em segundos!

---

## 📊 Estado dos Componentes LCL no Android

| Componente LCL | Status no Android | Observações |
| :--- | :---: | :--- |
| **Paleta LazDroid** | ✅ 100% Mobile | AppBar, BottomNav, Card, Badge, Button, Edit, ListView otimizados para touch |
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
# LazDroid-Deploy — IDE Plugin & Android Deployment Pipeline for Lazarus

<p align="center">
  <a href="#readme-pt">🇧🇷 Português</a> &nbsp;|&nbsp; <b>🇺🇸 English</b>
</p>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lazarus: 2.2+](https://img.shields.io/badge/Lazarus-2.2%2B-blue.svg)](https://www.lazarus-ide.org/)
[![Target: Android](https://img.shields.io/badge/Target-Android%205.0%2B%20(API%2021%2B)-green.svg)](https://developer.android.com)
[![Architecture: AArch64](https://img.shields.io/badge/Arch-ARM64%20%7C%20ARMv7-orange.svg)](https://developer.android.com/ndk)

**LazDroid-Deploy** is a professional automation suite (Open Tools Package) for **Lazarus IDE / Free Pascal (FPC)** that provides a *"1-Click Deploy & Run (Ctrl+Shift+F9)"* experience with support for real **LCL Visual Forms (CustomDrawn Android)**, identical to the Delphi and Android Studio ecosystems.

---

## 🎯 Key Features

- ⚡ **1-Click IDE Deployment**: Trigger compilation, packaging, installation, and execution with a single shortcut (`Ctrl+Shift+F9`) or via the `Run` menu.
- 🎯 **Delphi-Style Target Manager**: Dockable window featuring **automatic USB phone detection (Plug & Play)**, dynamic display of connected devices under the `Target` node, comprehensive hardware/OS inspection (battery, screen resolution, ABI, Android version), and direct deployment to the active target!
- 🎨 **Native On-Screen LCL Components**: Design user interfaces using the **Lazarus Form Designer** with `TForm`, `TButton`, `TLabel`, `TPanel`, `TPageControl`, `TEdit`, `TCheckBox`, and more, rendered via LCL CustomDrawn (`customdrawn_android`).
- 📁 **1-Click New Project Wizard**: Registered under `File -> New... -> Android Application (LazDroid)`, pre-configuring JNI library templates, LCLWidgetType, compiler flags, and the initial form.
- 📱 **Smart ABI & Device Detection**: Scans USB-connected devices (`adb devices -l`) and automatically selects the appropriate target architecture (`arm64-v8a` or `armeabi-v7a`).
- 🔧 **High-Performance Native FPC Compilation**: Drives the Free Pascal cross-compiler (`ppcrossa64`) generating direct ARM64 machine code (`liblazapp.so`), matching native C/C++ speed and efficiency.
- 🗄️ **Embedded SQLite Database**: Built-in support with pre-packaged native `libsqlite.so`, enabling lightning-fast offline SQLite operations out of the box.
- 📦 **Robust Android Scaffold**: Lightweight Java host (`com.pascal.lclproject.LCLActivity`) managing lifecycle, fullscreen mode, display orientation, DPI scaling, and touch event dispatching.
- 💬 **Real-Time Log Streaming**: Captures build `stdout`/`stderr` and streams Logcat output (`__android_log_print` / `tag: lclapp`) directly to Lazarus' **Messages** window.
- ⚙️ **Integrated Settings Panel**: SDK, NDK, ADB, JDK, and FPC path manager embedded into `Tools -> Options` with one-click automatic detection.

---

## 📂 Project Structure

```
LazAndroid/
├── package/                                # Lazarus Open Tools Package (IDE Integration)
│   ├── LazDroidDeploy.lpk                 # Main package to install into the IDE
│   ├── LazDroidDeploy_Reg.pas             # IDE menu, shortcut, and action registration
│   ├── LazDroidConfig.pas                 # Configuration persistence (XML)
│   ├── LazDroidConfigFrame.pas/.lfm       # Configuration frame in Tools -> Options
│   ├── LazDroidDeviceManager.pas          # ADB device detection and status inspection
│   ├── LazDroidDeviceSelectDlg.pas/.lfm   # USB device modal selection dialog
│   ├── LazDroidProcessRunner.pas          # Async multithreaded process runner with pipes
│   ├── LazDroidProjectDescriptor.pas      # Android New Project Wizard in the IDE
│   └── LazDroidPipeline.pas               # Master 6-stage build orchestrator
│
├── scaffold/                              # Ready-to-package Android template
│   ├── build.gradle                       # Root Gradle build script
│   ├── gradlew.bat                        # Gradle Wrapper for Windows
│   └── app/                               # Main Android application module
│       ├── build.gradle                   # SDK settings (minSdk 21, targetSdk 34)
│       └── src/main/
│           ├── AndroidManifest.xml        # Configured for com.pascal.lclproject.LCLActivity
│           ├── java/.../LCLActivity.java  # Java Host: LCL Canvas, Touch, JNI bridge
│           └── jniLibs/                   # Injected compiled native shared libraries
│               └── arm64-v8a/             # liblazapp.so and libsqlite.so (AArch64)
│
├── demo/                                  # Full Sales Force Application (SQLite)
│   ├── LazAndroidDemo.lpr                 # JNI entry point
│   ├── FormLogin.pas/.lfm                 # LCL Login Form
│   ├── FormVendas.pas/.lfm                # LCL Dashboard and Sales Form
│   ├── SalesDatabase.pas                  # SQLite connection and queries
│   └── vendas.db                          # Sample SQLite database
│
├── demo2/                                 # Minimalist "Hello World" LCL Example
│   ├── project1.lpr                       # LCL initialization
│   └── unit1.pas/.lfm                     # TForm1 with TButton and modal dialog
│
├── demo3/                                 # Advanced Multi-Tab Demo (CRUD Mock)
│   ├── demo3.lpr                          # LCL initialization with Activity
│   └── unit1.pas/.lfm                     # TPageControl, TTabSheet, TPanel, TEdit, TLabel
│
├── demo4/                                 # LazDroid Mobile Palette Showcase
│   ├── demo4.lpr                          # JNI entry point
│   └── unit1.pas/.lfm                     # AppBar, BottomNav, Card, Badge, Edit, Button, ListView
│
├── demo5/                                 # Complete Commercial App (Login + SQLite + BottomNav)
│   ├── project1.lpr                       # JNI entry point with Activity
│   ├── unit1.pas/.lfm                     # Login screen authenticating against SQLite
│   ├── unit3.pas/.lfm                     # Main screen with BottomNav (Products, Orders, Clients, Settings)
│   ├── unit4.pas/.lfm                     # DataModule with TSQLite3Connection and queries
│   ├── database/app.db                    # SQLite database with 5 tables and sample data
│   └── imagens/                           # Catalog of PNG images and icons
│
├── tools/                                 # Utilities, SQLite binaries, scripts, and installer
└── docs/                                  # Technical Documentation and Guides
    ├── ARCHITECTURE.md                    # Detailed architecture and Mermaid diagrams
    ├── INSTALL_GUIDE.md                   # Step-by-step installation and usage guide
    └── manual_componentes_lazdroid.html   # Interactive Mobile Component Palette Manual
```

---

## 📱 Complete "LazDroid" Mobile Component Suite (30 Components)

**LazDroid** delivers a comprehensive library of **30 touch-first mobile components**, engineered specifically for Android touchscreens (Material Design & iOS look-and-feel), breaking past the limitations of traditional desktop controls in Lazarus.

All components are instantly available in the **`LazDroid`** palette within the Form Designer:

### 🧭 Navigation & Layout
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidAppBar`** | 🧭 Top Bar | Mobile top app bar with title, dynamic subtitle, Back button (`OnBackClick`), and action buttons (`OnActionClick`). |
| **`TLazDroidBottomNav`** | 📌 Tab Bar | Touch bottom navigation bar with automatic vector icons, numeric badges, and `OnTabSelected` event. |
| **`TLazDroidBottomSheet`** | 📥 Modal Drawer | Bottom sliding panel (modal drawer) with grab handle, ideal for advanced filters, share options, and action sheets. |
| **`TLazDroidSpeedDial`** | ⚡ Floating Menu | Expandable Floating Action Button that unfolds into multiple circular action buttons with touch icon rotation. |
| **`TLazDroidLayout`** | 📐 Responsive Box | Responsive screen container supporting smart padding, rounded corners, and smooth vertical scrolling. |

### ✏️ Data Input & Forms
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidEdit`** | ✏️ Input Field | Modern text field with placeholder, rounded corners, and **automatic native Android virtual keyboard invocation**. |
| **`TLazDroidSearchBar`** | 🔍 Search Bar | Search bar featuring magnifying glass icon, quick-clear button (`X`), pill shape, and live typing event (`OnSearch`). |
| **`TLazDroidOtpBox`** | 🔢 PIN / OTP Input | Verification code input (4 to 6-digit PIN/SMS) in separate boxes with automatic focus advancement between digits. |
| **`TLazDroidDatePicker`** | 📅 Date Picker | Modern mobile date picker with a touch-friendly popup calendar and regional formatting. |
| **`TLazDroidTimePicker`** | ⏰ Time Picker | Hour and minute selector with 12h/24h toggle and touch carousel controls. |
| **`TLazDroidCheckBox`** | ☑️ CheckBox | Enlarged touch checkbox with animated fill, checkmark icon, and descriptive label. |
| **`TLazDroidSwitch`** | 🎚️ Toggle Switch | Modern iOS/Material-style on/off toggle switch with smooth animated transitions and custom active/inactive colors. |
| **`TLazDroidRadioGroup`** | 🔘 Radio Group | Mutually exclusive option group with vertical/horizontal layouts and comfortable touch targets. |
| **`TLazDroidSegmentedControl`** | 📑 Segments | Horizontal segmented selector with sliding indicator, ideal for quick view switching or status filters. |
| **`TLazDroidChipGroup`** | 🏷️ Filter Chips | Dynamic collection of tags/chips with single or multi-selection for fast categorization and catalog filtering. |

### 📋 Lists & Data Display
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidListView`** | 📋 Card List | Touch record list with title, subtitle, badges, 32-bit images, right-aligned currency amounts, and **drag-to-scroll**. |
| **`TLazDroidCard`** | 🃏 Surface Card | Card container with elevation, soft shadow, header, and rounded corners for grouping content blocks. |
| **`TLazDroidMetricCard`** | 📊 KPI Card | Specialized card for sales dashboards and KPI summaries featuring numeric value, label, and percentage variance badge. |
| **`TLazDroidSectionHeader`** | 📑 Section Header | Visual section divider with emphasized title and right-aligned action button (*e.g., "See all"*). |
| **`TLazDroidImageList`** | 🖼️ Image Manager | Mobile icon and photo manager with full 32-bit alpha transparency (PNG) support without quality degradation. |

### 🔘 Actions, Buttons & Feedback
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidButton`** | 🔘 Action Button | Button with a minimum 48px touch target, semantic styles (*Primary, Success, Danger, Outline*), and vector icons. |
| **`TLazDroidFAB`** | ➕ Action Button | Elevated circular Floating Action Button with drop shadow, ideal for the primary screen action (*e.g., New Order*). |
| **`TLazDroidBadge`** | 🏷️ Status Pill | Semantic pill badge for statuses (*Pending, Completed, Cancelled*) or notification counters (*e.g., 3*). |
| **`TLazDroidProgressBar`** | ⏳ Progress Bar | Progress bar with smooth animations, centered percentage label, and state-specific colors. |
| **`TLazDroidSlider`** | 🎚️ Value Slider | Touch slider control with floating numeric value callout for continuous adjustments of quantities, volumes, or price ranges. |
| **`TLazDroidActivityIndicator`** | 🔄 Spinner | Asynchronous loading indicator with a modern spinning ring, ideal for SQLite queries or network activity. |

### 📱 Special Mobile Features
| Component | Type / Icon | Description & Mobile Features |
| :--- | :---: | :--- |
| **`TLazDroidRatingBar`** | ⭐ Star Rating | Touch star rating (1 to 5 stars) with half-star support and direct touch selection. |
| **`TLazDroidKeypad`** | ⌨️ Numeric Keypad | Dedicated virtual numeric keypad for POS, cashier checkout, order tickets, and rapid number entry. |
| **`TLazDroidSignaturePad`** | ✍️ Signature Pad | Digital touch signature capture canvas with smooth strokes and direct export to bitmap/image. |
| **`TLazDroidAvatar`** | 👤 Avatar | Circular profile picture with automatic initial fallback and connection status badge (*Online / Away*). |

> 📖 **Palette Quick Reference Manual:**  
> To view interactive documentation for every property, event, and Pascal code example across all 30 components, open in your browser:  
> [`docs/manual_componentes_lazdroid.html`](docs/manual_componentes_lazdroid.html) (or run the shortcut `Abrir-Manual-Componentes.cmd`).

> 📚 **Complete Official Book (HTML & PDF Export):**  
> We have created a comprehensive, formatted technical book covering everything from environment setup and hardening to building a commercial **Sales Force application with SQLite**:  
> - **File:** [`docs/livro_lazdroid_desenvolvimento_mobile.html`](docs/livro_lazdroid_desenvolvimento_mobile.html) (or run the shortcut `Abrir-Livro-LazDroid.cmd`).  
> - **PDF Export:** The book features a built-in top button to instantly generate/print an A4-format PDF with a professional cover, table of contents, page numbers, and clean chapter breaks.

---

## 🛠️ Installation & Setup Guide

**LazDroid** offers three convenient installation options to support everyone from end users and beginners to enterprise CI/CD pipelines:

### 📦 Option 1: Windows Client Setup Installer (`Setup-LazAndroid.exe`)
Ideal for clients, new team members, and developers who prefer a standard Windows installer experience (Inno Setup wizard):
1. Download or run `dist\Setup-LazAndroid.exe` (or from GitHub Releases).
2. Run the installer as Administrator.
3. Choose the destination directory (recommended default: `C:\LazAndroid`).
4. The installer unpacks the suite, includes the offline FPC Android toolchain, and creates Start Menu shortcuts for all demos, manuals, and tools.
5. On the final step, check the box to launch the **LazDroid Visual Setup Assistant** to finish Lazarus configuration in 1 click!

---

### ⚡ Option 2: Native 1-Click GUI Assistant (`Instalar-LazDroid.exe`)
Ideal for developers cloning the repository or downloading the `.zip`:
1. Open the cloned repository directory:
   ```cmd
   git clone https://github.com/mabreu2022/LazAndroid.git
   cd LazAndroid
   ```
2. Double-click:
   ```cmd
   Instalar-LazDroid.exe
   ```
   *(or run `Instalar-LazDroid.cmd`, which automatically requests UAC Administrator privileges).*
3. A sleek, native Free Pascal / LCL GUI window opens:
   - Displays real-time detection status of **Lazarus IDE**, **Java JDK**, **Android SDK/NDK**, and **FPC AArch64 Cross-Compiler**.
   - Lets you re-verify paths and status anytime with the **"🔍 Verify"** button.
   - Click the bold **"⚡ Install Everything (1-Click)"** button to run all configuration steps automatically:
     - ✅ Installs FPC cross-compilers (`ppcrossa64.exe` and `ppcrossarm.exe`).
     - ✅ Installs Android RTL units (`aarch64-android` and `arm-android`).
     - ✅ Applies LCL CustomDrawn patches (virtual keyboard activation and font compatibility).
     - ✅ Compiles LCL CustomDrawn for `aarch64-android`.
     - ✅ Registers `LazDroidControls.lpk` (29 mobile controls) and `LazDroidDeploy.lpk` (IDE integration).
     - ✅ Autodetects Android tools and generates `lazdroiddeploy.xml` and `local.properties`.
     - ✅ Rebuilds the Lazarus IDE with LazDroid fully integrated.
   - Provides quick action buttons for **"🎨 Delphi Layout"** (docks IDE windows into modern tabs) and **"🚀 Open IDE"**.

---

### 💻 Option 3: Command-Line / CI Mode (`Instalar-LazDroid.cmd --cli`)
For automated scripts, DevOps, or developers who prefer the command line:
```cmd
Instalar-LazDroid.cmd --cli
```
Or directly in PowerShell:
```powershell
.\tools\installer\install.ps1 -NonInteractive -RebuildIDE
```

---

### 🎨 Organize the IDE in Delphi Style (Optional, Recommended)

If Lazarus' windows are floating or disorganized, you can apply the docked Delphi-style layout directly from the GUI Assistant (**"🎨 Delphi Layout"** button) or by double-clicking:
```cmd
Restaurar-Layout-Lazarus.cmd
```
This arranges the interface into a professional docked layout (*AnchorDocking*) identical to Delphi:
* **Left:** Object Inspector (components, properties, and events).
* **Center:** Code Editor and Form Designer at the top, Messages and Debugging at the bottom.
* **Right:** Project Inspector at the top, LazDroid Mobile Target Manager in the middle, and Component Palette at the bottom.
* *(The layout is locked as read-only to prevent accidental rearrangement).*

---

### 4. How to Test and Run Your First Deployment

1. Open **Lazarus IDE**.
2. Connect your mobile phone via USB (with *USB Debugging* enabled).
3. Open any of the included ready-to-run demo projects:
   * **`demo5/project1.lpi`**: Full sales application with **Login**, local **SQLite database (`database/app.db`)**, and tab navigation (**`TLazDroidBottomNav`**).
   * **`demo4/demo4.lpi`**: Showcase of touch-first buttons, cards, badges, inputs, and list views.
   * **`demo/LazAndroidDemo.lpi`**: Sales force demo with LCL visual forms.
4. Press the shortcut:
   ```
   Ctrl + Shift + F9
   ```
   *(Or click the menu `Run -> Deploy & Run on Android Device`)*.
5. LazDroid compiles the native ARM64 library (`liblazapp.so`), packages the APK with Gradle, and installs/launches the app on your phone in seconds!

---

## 📊 LCL Component Status on Android

| LCL Component | Status on Android | Notes |
| :--- | :---: | :--- |
| **LazDroid Palette** | ✅ 100% Mobile | AppBar, BottomNav, Card, Badge, Button, Edit, ListView optimized for touch |
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


