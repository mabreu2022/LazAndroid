# LazDroid-Deploy — IDE Plugin & Pipeline de Deploy Android para Lazarus

## 1. Visão Geral da Arquitetura

O **LazDroid-Deploy** transforma a experiência de desenvolvimento móvel no Lazarus IDE, proporcionando um ciclo *"Edit & Run (F9)"* idêntico ao do Delphi/Android Studio. Ele orquestra o compilador cruzado Free Pascal (FPC), a injeção em scaffolding Android nativo (`NativeActivity`), o empacotador Gradle e o ADB sobre USB.

```mermaid
graph TD
    subgraph LazarusIDE ["Lazarus IDE (Design-Time & Run-Time)"]
        UI["Menu Run & Toolbar Button<br/>'Deploy & Run on Android Device'"]
        Opts["IDE Options Editor<br/>(SDK, NDK, JDK, FPC Paths)"]
        MsgWin["Lazarus Messages Window<br/>(IDEMsgIntf Real-Time Feedback)"]
        DevPick["Device Selector Dialog<br/>(Auto-detect USB Devices)"]
    end

    subgraph LazDroidPackage ["LazDroid-Deploy Package (LazDroidDeploy.lpk)"]
        Reg["LazDroidDeploy_Reg.pas<br/>(IDE Registration)"]
        Cfg["LazDroidConfig.pas<br/>(LazConfigStorage XML)"]
        DevMgr["LazDroidDeviceManager.pas<br/>(ADB Query & ABI Resolver)"]
        Pipe["LazDroidPipeline.pas<br/>(6-Stage Async Orchestrator)"]
        Proc["LazDroidProcessRunner.pas<br/>(Threaded CLI Executor + Pipe Reader)"]
    end

    subgraph ToolchainHost ["Host Toolchain (Windows/Linux/macOS)"]
        FPC["FPC Cross-Compiler<br/>(ppca64 / ppcarm -Tandroid)"]
        Gradle["Gradle Wrapper<br/>(gradlew assembleDebug)"]
        ADB["Android Debug Bridge<br/>(adb.exe)"]
    end

    subgraph AndroidTarget ["Dispositivo Físico Android (USB)"]
        DeviceApp["App Process (PID)<br/>com.lazarus.android.demo"]
        NativeAct["android.app.NativeActivity"]
        SoLib["liblazapp.so<br/>(ANativeActivity_onCreate)"]
        Surface["ANativeWindow Surface & Input Queue"]
        LogcatPipe["Logcat Daemon<br/>(TAG: LazApp / AndroidRuntime)"]
    end

    %% Conexões
    UI -->|Dispara| Pipe
    DevPick -->|Seleciona Alvo| Pipe
    Opts -->|Fornece Paths| Cfg
    Cfg --> Pipe

    Pipe -->|1. Detecta & ABI| DevMgr
    DevMgr -->|adb devices -l| ADB

    Pipe -->|2. Cross-Compile .so| Proc
    Proc -->|fpc -Tandroid -Paarch64| FPC

    Pipe -->|3. Assemble APK| Proc
    Proc -->|./gradlew assembleDebug| Gradle

    Pipe -->|4. Install APK| Proc
    Proc -->|adb -s SERIAL install -r -d| ADB

    Pipe -->|5. Launch Activity| Proc
    Proc -->|adb -s SERIAL shell am start| ADB

    Pipe -->|6. Monitor Logs| Proc
    Proc -->|adb logcat -s LazApp:*| ADB

    ADB -->|Instala & Dispara| DeviceApp
    DeviceApp --> NativeAct
    NativeAct --> SoLib
    SoLib --> Surface
    SoLib -->|__android_log_print| LogcatPipe

    Proc -->|Log Streaming| MsgWin
    LogcatPipe -->|Eventos em Tempo Real| ADB
    ADB -->|Stdout Streaming| Proc
```

---

## 2. Pipeline de Orquestração em 6 Estágios

A esteira de execução implementada em `LazDroidPipeline.pas` opera em background thread não-bloqueante (`TThread` / `TProcess` com pipes assíncronos), emitindo mensagens categorizadas para a IDE:

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
    ADB-->>Pipe: Dispositivo '0A1B2C3D' pronto (ABI: arm64-v8a)
    Pipe-->>IDE: Msg: "Dispositivo ativo: Samsung Galaxy S23 [arm64-v8a]"
    end

    rect rgb(255, 250, 240)
    Note over Pipe,FPC: Estágio 2: Compilação Cruzada Pascal -> .so
    Pipe->>FPC: fpc -Tandroid -Paarch64 -O3 -fPIC -FE<scaffold>/app/src/main/jniLibs/arm64-v8a/
    FPC-->>Pipe: Compilação concluída: liblazapp.so (ExitCode: 0)
    Pipe-->>IDE: Msg: "Binário liblazapp.so gerado com sucesso!"
    end

    rect rgb(240, 255, 240)
    Note over Pipe,Grad: Estágio 3: Empacotamento Debug do APK
    Pipe->>Grad: ./gradlew assembleDebug --parallel
    Grad-->>Pipe: BUILD SUCCESSFUL (app-debug.apk gerado)
    Pipe-->>IDE: Msg: "APK montado: app/build/outputs/apk/debug/app-debug.apk"
    end

    rect rgb(255, 245, 245)
    Note over Pipe,Cel: Estágio 4: Instalação no Celular
    Pipe->>ADB: adb -s 0A1B2C3D install -r -d app-debug.apk
    ADB->>Cel: Transfere e instala APK
    Cel-->>ADB: Success
    ADB-->>Pipe: Install Success (ExitCode: 0)
    Pipe-->>IDE: Msg: "APK instalado no aparelho com sucesso."
    end

    rect rgb(245, 240, 255)
    Note over Pipe,Cel: Estágio 5: Inicialização da Activity
    Pipe->>ADB: adb -s 0A1B2C3D shell am start -n com.lazarus.android.demo/android.app.NativeActivity
    ADB->>Cel: Iniciar Intent
    Cel-->>ADB: Starting: Intent { cmp=... }
    Pipe-->>IDE: Msg: "Aplicação inicializada na tela do celular!"
    end

    rect rgb(235, 255, 255)
    Note over Pipe,Cel: Estágio 6: Streaming de Logcat
    Pipe->>ADB: adb -s 0A1B2C3D logcat -v time -s LazApp:* AndroidRuntime:E
    Cel-->>ADB: Logs em tempo real (__android_log_print)
    ADB-->>Pipe: Linhas de Log
    Pipe-->>IDE: IDEMessagesWindow.AddCustomMessage(LogLine)
    end
```
