# LazDroid-Deploy — IDE Plugin & Pipeline de Deploy Android para Lazarus

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

> 📖 **Manual Completo com Exemplos de Código:**  
> Para consultar a documentação interativa de cada propriedade, evento e exemplo de código Pascal para todos os 30 componentes, abra no seu navegador o arquivo:  
> [`docs/manual_componentes_lazdroid.html`](docs/manual_componentes_lazdroid.html) (ou execute o atalho `Abrir-Manual-Componentes.cmd`).

---

## 🛠️ Guia de Instalação Passo a Passo (Para quem baixou do GitHub)

Se você acabou de clonar ou baixar o repositório do GitHub, siga o passo a passo abaixo para configurar o ambiente em poucos minutos:

### 1. Pré-Requisitos do Sistema
Antes de rodar o instalador, certifique-se de possuir instalado no Windows:
* **Lazarus IDE (v2.2, 3.x ou 4.x)**: instalado (ex: `C:\lazarus`).
* **Android SDK & ADB**: instalado via Android Studio ou standalone em `%LOCALAPPDATA%\Android\Sdk` (com a pasta `platform-tools` contendo o `adb.exe`).
* **Android NDK**: versões r21 a r26 (instalado pelo Android Studio em *SDK Tools* -> *NDK (Side by side)*).
* **Java JDK 17 ou superior**: instalado (ex: Eclipse Adoptium JDK ou o `jbr` do Android Studio).
* **Celular Android**: conectado via cabo USB com a **Depuração USB** ativada nas *Opções do Desenvolvedor*.

---

### 2. Instalação Automática em 1-Clique

1. Abra a pasta do projeto clonado:
   ```cmd
   git clone https://github.com/mabreu2022/LazAndroid.git
   cd LazAndroid
   ```
2. Dê um duplo-clique no arquivo:
   ```cmd
   Instalar-LazDroid.cmd
   ```
3. O Windows solicitará privilégios de Administrador (UAC). Clique em **Sim**.
4. O instalador executará automaticamente todas as etapas:
   - ✅ Localiza o Lazarus IDE instalado (`C:\lazarus`).
   - ✅ Baixa e extrai automaticamente o compilador cruzado FPC AArch64 e as units da RTL Android.
   - ✅ Copia os binários `ppcrossa64.exe` e units `aarch64-android` e `arm-android` para o FPC.
   - ✅ Aplica o patch móvel para acionamento do teclado virtual na LCL CustomDrawn.
   - ✅ Compila a LCL CustomDrawn e os pacotes para Android AArch64.
   - ✅ Registra os pacotes **`LazDroidControls.lpk`** (29 componentes mobile) e **`LazDroidDeploy.lpk`** (Deploy e Target Manager) no Lazarus.
   - ✅ Autodetecta o Android SDK, NDK, ADB, JDK e grava o arquivo de configuração `lazdroiddeploy.xml`.
5. Ao final, digite **`S`** para autorizar a reconstrução da IDE. O Lazarus será compilado com o LazDroid integrado!

---

### 3. Organizar a IDE no Estilo Delphi (Opcional, porém Recomendado)

Se as janelas do Lazarus estiverem desorganizadas ou flutuantes, dê um duplo clique no arquivo:
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
