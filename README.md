# LazDroid-Deploy — IDE Plugin & Pipeline de Deploy Android para Lazarus

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lazarus: 2.2+](https://img.shields.io/badge/Lazarus-2.2%2B-blue.svg)](https://www.lazarus-ide.org/)
[![Target: Android](https://img.shields.io/badge/Target-Android%205.0%2B%20(API%2021%2B)-green.svg)](https://developer.android.com)
[![Architecture: AArch64](https://img.shields.io/badge/Arch-ARM64%20%7C%20ARMv7-orange.svg)](https://developer.android.com/ndk)

**LazDroid-Deploy** é uma suíte de automação profissional (Open Tools Package) para o **Lazarus IDE / Free Pascal (FPC)** que entrega a experiência *"1-Click Deploy & Run (Ctrl+Shift+F9)"* com suporte a **Formulários Visuais LCL reais (CustomDrawn Android)**, idêntica ao ecossistema Delphi e Android Studio.

---

## 🎯 Funcionalidades Principais

- ⚡ **Deploy em 1-Clique na IDE**: Dispare compilação, empacotamento, instalação e execução com um único atalho (`Ctrl+Shift+F9`) ou botão no menu `Run`.
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
├── tools/                                 # Utilitários, SQLite, Scripts e Instalador
└── docs/                                  # Documentação Técnica e Guias
    ├── ARCHITECTURE.md                    # Arquitetura detalhada e diagramas Mermaid
    └── INSTALL_GUIDE.md                   # Guia passo a passo de instalação e uso
```

---

## 📱 Paleta de Componentes Mobile "LazDroid"

Para acelerar o desenvolvimento de aplicações comerciais e corporativas no Android sem depender apenas de controles de desktop, o LazDroid disponibiliza a paleta **`LazDroid`** no Lazarus Form Designer:

| Componente | Ícone / Tipo | Finalidade Mobile |
| :--- | :---: | :--- |
| **`TLazDroidAppBar`** | 🧭 Top Bar | Barra superior com título, subtítulo, botão Voltar (`OnBackClick`) e ícone de ação/menu (`OnActionClick`). |
| **`TLazDroidButton`** | 🔘 Touch Button | Botão com cantos arredondados, altura mínima para touch (48px), variantes semânticas (*Primary, Success, Danger, Outline*) e ícones geométricos. |
| **`TLazDroidEdit`** | ✏️ Input Field | Campo de entrada com *placeholder*, bordas arredondadas e **acionamento automático do teclado virtual Android**. |
| **`TLazDroidCard`** | 🃏 Card Container | Cartão mobile para métricas, gráficos ou agrupamentos com cantos arredondados e cabeçalho opcional. |
| **`TLazDroidBadge`** | 🏷️ Status Pill | Pílula/etiqueta com cores semânticas (*Ativo, Pendente, Aprovado, R$ Valor*). |
| **`TLazDroidBottomNav`** | 📌 Tab Bar | Barra de navegação inferior com abas táteis, indicador de seleção ativa e evento `OnTabSelected`. |
| **`TLazDroidListView`** | 📋 Card List | Lista de registros touch com título, subtítulo, valor à direita e **rolagem por arrasto (drag scroll)**. |

---

## 🚀 Como Começar em 1-Clique

1. **Execute o Instalador Automático:**
   - Dê um duplo clique no arquivo [`Instalar-LazDroid.cmd`](file:///d:/Projetos%20AntiGravity/LazarusAndroid/Instalar-LazDroid.cmd) na raiz do projeto.
   - Ele detecta o Lazarus, instala os compiladores FPC AArch64, copia as units RTL/FCL, compila o widgetset LCL CustomDrawn para Android, registra a paleta **LazDroid** na IDE e detecta automaticamente o SDK, NDK, ADB e JDK em cerca de 15 segundos!
2. **Crie ou Abra um Projeto:**
   - No Lazarus, crie um novo aplicativo em `Arquivo -> Novo... -> Aplicação Android (LazDroid)`.
   - Ou abra qualquer uma das demos (`demo4/demo4.lpi`, `demo3/demo3.lpi`, `demo/LazAndroidDemo.lpi` ou `demo2/project1.lpi`).
3. **Execute no Dispositivo Físico:**
   - Conecte o aparelho via cabo USB com a *Depuração USB* ativa e pressione **`Ctrl + Shift + F9`**!

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
