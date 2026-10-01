# LazDroid-Deploy — Arquitetura da Solução e Pipeline Android

## 1. Visão Geral da Arquitetura

O **LazDroid-Deploy** transforma a experiência de desenvolvimento móvel no Lazarus IDE, proporcionando um ciclo *"Edit, Design & Run (Ctrl+Shift+F9)"* com formulários visuais reais da **LCL (Lazarus Component Library)**. Ele orquestra o compilador cruzado Free Pascal (FPC), a injeção na camada host Android com suporte a LCL CustomDrawn (`com.pascal.lclproject.LCLActivity`), o empacotador Gradle e o ADB sobre USB.

```mermaid
graph TD
    subgraph LazarusIDE ["Lazarus IDE (Design-Time & Run-Time)"]
        UI["Menu Run & Botão na Barra de Ferramentas<br/>'Deploy & Run on Android Device'"]
        NewPrj["Menu Arquivo -> Novo...<br/>'Aplicação Android (LazDroid)'"]
        Opts["Editor de Opções da IDE<br/>(Caminhos do SDK, NDK, JDK, FPC)"]
        MsgWin["Janela de Mensagens do Lazarus<br/>(Feedback em Tempo Real)"]
        DevPick["Diálogo Seletor de Aparelhos<br/>(Detecção Automática USB)"]
    end

    subgraph LazDroidPackage ["Pacote LazDroid-Deploy (LazDroidDeploy.lpk)"]
        Reg["LazDroidDeploy_Reg.pas<br/>(Registro de Menus e Comandos)"]
        Desc["LazDroidProjectDescriptor.pas<br/>(Template de Novo Projeto LCL)"]
        Cfg["LazDroidConfig.pas<br/>(Armazenamento em XML)"]
        DevMgr["LazDroidDeviceManager.pas<br/>(ADB Query & Resolução de ABI)"]
        Pipe["LazDroidPipeline.pas<br/>(Orquestrador Assíncrono em 6 Estágios)"]
        Proc["LazDroidProcessRunner.pas<br/>(Thread com Leitura de Pipes)"]
    end

    subgraph ToolchainHost ["Toolchain do Sistema Hospedeiro (Windows)"]
        FPC["Compilador Cruzado FPC ARM64<br/>(ppcrossa64.exe -Tandroid -Paarch64)"]
        Gradle["Gradle Wrapper<br/>(gradlew.bat assembleDebug)"]
        ADB["Android Debug Bridge<br/>(adb.exe)"]
    end

    subgraph AndroidTarget ["Dispositivo Android Físico (USB)"]
        DeviceApp["Processo do Aplicativo<br/>com.lazarus.android.*"]
        JavaHost["Host: com.pascal.lclproject.LCLActivity<br/>(Gerenciamento de Janela, DPI, Lifecycle)"]
        LclSurface["LCLSurface (View)<br/>(Buffer Bitmap ARGB8888 + Touch)"]
        SoLib["liblazapp.so<br/>(LCL CustomDrawn Android + Forms LCL)"]
        SqliteLib["libsqlite.so<br/>(Motor SQLite Nativo)"]
        LogcatPipe["Daemon do Logcat<br/>(TAG: lclapp / AndroidRuntime)"]
    end

    %% Conexões
    UI -->|Dispara| Pipe
    NewPrj -->|Cria Projeto| Desc
    DevPick -->|Seleciona Alvo| Pipe
    Opts -->|Configurações| Cfg
    Cfg --> Pipe

    Pipe -->|1. Detecta & ABI| DevMgr
    DevMgr -->|adb devices -l| ADB

    Pipe -->|2. Compila Binário Pascal| Proc
    Proc -->|ppcrossa64 -fPIC -dLCLcustomdrawn| FPC

    Pipe -->|3. Gera APK| Proc
    Proc -->|gradlew assembleDebug| Gradle

    Pipe -->|4. Instala APK| Proc
    Proc -->|adb -s SERIAL install -r -d| ADB

    Pipe -->|5. Dispara Activity| Proc
    Proc -->|adb -s SERIAL shell am start| ADB

    Pipe -->|6. Monitora Logs| Proc
    Proc -->|adb logcat -s lclapp:*| ADB

    ADB -->|Instala & Executa| DeviceApp
    DeviceApp --> JavaHost
    JavaHost --> LclSurface
    JavaHost -->|JNI_OnLoad / System.loadLibrary| SoLib
    JavaHost -->|System.loadLibrary| SqliteLib
    SoLib -->|LCLDrawToBitmap| LclSurface
    SoLib -->|__android_log_write| LogcatPipe

    Proc -->|Streaming de Mensagens| MsgWin
    LogcatPipe -->|Eventos em Tempo Real| ADB
    ADB -->|Stdout Streaming| Proc
```

---

## 2. Pipeline de Orquestração em 6 Estágios

A esteira de execução implementada em [`LazDroidPipeline.pas`](file:///d:/Projetos%20AntiGravity/LazarusAndroid/package/LazDroidPipeline.pas) opera em background thread não-bloqueante (`TThread` / `TProcess` com pipes assíncronos), emitindo mensagens categorizadas para a IDE:

```mermaid
sequenceDiagram
    autonumber
    participant Dev as Desenvolvedor
    participant IDE as Lazarus IDE
    participant Pipe as LazDroid Pipeline Thread
    participant FPC as Free Pascal (FPC)
    participant Grad as Gradle Wrapper
    participant ADB as Android ADB
    participant Cel as Celular Android (USB)

    Dev->>IDE: Clique em "Deploy & Run on Android Device" (Ctrl+Shift+F9)
    IDE->>Pipe: Iniciar Pipeline(ActiveProject, TargetConfig)
    
    rect rgb(240, 248, 255)
    Note over Pipe,ADB: Estágio 1: Pre-Check & Detecção de Dispositivo
    Pipe->>ADB: adb devices -l / getprop ro.product.cpu.abi
    ADB-->>Pipe: Dispositivo conectado e autorizado (ABI: arm64-v8a)
    Pipe-->>IDE: Msg: "Dispositivo ativo: Xiaomi/Samsung [arm64-v8a]"
    end

    rect rgb(255, 250, 240)
    Note over Pipe,FPC: Estágio 2: Compilação Cruzada Pascal -> .so
    Pipe->>FPC: ppcrossa64 -Tandroid -Paarch64 -fPIC -dLCLcustomdrawn -FE<scaffold>/app/src/main/jniLibs/arm64-v8a/
    FPC-->>Pipe: Compilação concluída: liblazapp.so (ExitCode: 0)
    Pipe-->>IDE: Msg: "Binário liblazapp.so gerado com sucesso!"
    end

    rect rgb(240, 255, 240)
    Note over Pipe,Grad: Estágio 3: Empacotamento Debug do APK
    Pipe->>Grad: gradlew.bat assembleDebug --no-daemon
    Grad-->>Pipe: BUILD SUCCESSFUL (app-debug.apk gerado)
    Pipe-->>IDE: Msg: "APK montado: app-debug.apk"
    end

    rect rgb(255, 245, 245)
    Note over Pipe,Cel: Estágio 4: Instalação no Celular
    Pipe->>ADB: adb -s SERIAL install -r -d app-debug.apk
    ADB->>Cel: Transfere e instala APK
    Cel-->>ADB: Success
    ADB-->>Pipe: Install Success (ExitCode: 0)
    Pipe-->>IDE: Msg: "APK instalado no aparelho com sucesso."
    end

    rect rgb(245, 240, 255)
    Note over Pipe,Cel: Estágio 5: Inicialização da Activity
    Pipe->>ADB: adb -s SERIAL shell am start -n com.lazarus.android.*/com.pascal.lclproject.LCLActivity
    ADB->>Cel: Iniciar Intent
    Cel-->>ADB: Starting: Intent { cmp=... }
    Pipe-->>IDE: Msg: "Aplicação LCL inicializada na tela do celular!"
    end

    rect rgb(235, 255, 255)
    Note over Pipe,Cel: Estágio 6: Streaming de Logcat
    Pipe->>ADB: adb -s SERIAL logcat -v time -s lclapp:* AndroidRuntime:E
    Cel-->>ADB: Logs em tempo real (__android_log_write)
    ADB-->>Pipe: Linhas de Log
    Pipe-->>IDE: IDEMessagesWindow.AddCustomMessage(LogLine)
    end
```

---

## 3. Renderização LCL e Integração JNI

1. **Host Android (`LCLActivity.java`)**:
   - Cria uma subclasse de `View` chamada `LCLSurface`.
   - Gerencia a orientação, resolução e densidade DPI da tela.
   - Fornece um bitmap compartilhado em memória (`Bitmap.Config.ARGB_8888`).
2. **Ponte Pascal (`customdrawn_android.pas` / `customdrawnobject_android.inc`)**:
   - Implementa a função nativa `LCLDrawToBitmap(width, height, bitmap)`.
   - A LCL renderiza toda a árvore de componentes visuais (`TForm`, `TButton`, `TPanel`, etc.) diretamente sobre a superfície do bitmap através do drawer `customdrawndrawers`.
   - Os eventos de toque (`MotionEvent`) são interceptados na classe Java e direcionados via JNI para `LCLOnTouch(x, y, action)`, que mapeia para `MouseDown`, `MouseMove` e `MouseUp` da LCL.

---

## 4. Gerenciador de Alvos Android (Target Manager Estilo Delphi)

Implementado em [`LazDroidTargetDockWin.pas`](file:///d:/Projetos%20AntiGravity/LazarusAndroid/package/LazDroidTargetDockWin.pas), o Gerenciador de Alvos reproduz fielmente o comportamento da árvore **Target** do *Project Manager* do Delphi:

```
▼ 📦 MeuProjeto.lpi
   ▼ 🤖 Android 64-bit (aarch64) - LCL CustomDrawn
      ▼ 🎯 Target
         🟢 Samsung SM-G780G [RQ8R70BFZEJ] (arm64-v8a | Android 13) ★ [ATIVO]
      ▼ ⚙️ Configuration
         ● Debug (GDB Remote & Símbolos)
         ○ Release (Otimizado -O3 -Xs)
      ▼ ⚡ Ações Rápidas
         ▶️ Deploy & Executar (Ctrl+Shift+F9)
         🐞 Deploy & Depurar (Ctrl+F9)
         📋 Abrir Terminal Logcat
         🔄 Atualizar Dispositivos USB
         ⚙️ Opções LazDroid...
```

### Características Técnicas:
1. **Dockable Tool Window (Lazarus Open Tools API)**:
   - Registrado via `IDEWindowCreators.Add('TLazDroidTargetDockForm')`, permitindo ser acoplado com **AnchorDocking** em qualquer quadrante da IDE (por exemplo, abaixo ou ao lado do Project Inspector).
2. **Auto-Polling USB (Plug & Play)**:
   - Um timer não-bloqueante de 2.5s consulta `adb devices -l` de forma transparente. Ao plugar ou desplugar o cabo USB, o nó `Target` atualiza em tempo real sem travar a digitação no editor de código.
3. **Inspeção Completa de Hardware via ADB**:
   - Ao clicar com botão direito -> *Propriedades do Aparelho*, inspeciona dinamicamente: fabricante, modelo comercial, resolução de tela (`wm size`), nível de bateria (`dumpsys battery`), versão do Android e nível da API (SDK).
4. **Deploy Direto sem Interrupções**:
   - Quando um alvo está ativo (`★ [ATIVO]`), o acionamento de `Ctrl+Shift+F9` direciona o deploy diretamente para o aparelho selecionado, eliminando caixas de diálogo repetitivas.

