# LazDroid-Deploy — IDE Plugin & Pipeline de Deploy Android para Lazarus

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lazarus: 2.2+](https://img.shields.io/badge/Lazarus-2.2%2B-blue.svg)](https://www.lazarus-ide.org/)
[![Target: Android](https://img.shields.io/badge/Target-Android%205.0%2B%20(API%2021%2B)-green.svg)](https://developer.android.com)

**LazDroid-Deploy** é uma suíte de automação profissional (Open Tools Package) para o **Lazarus IDE / Free Pascal (FPC)** que entrega a experiência *"1-Click Deploy & Run (Ctrl+Shift+F9)"* idêntica ao ecossistema Delphi e Android Studio.

---

## 🎯 Funcionalidades Principais

- ⚡ **Deploy em 1-Clique na IDE**: Dispare compilação, empacotamento, instalação e execução com um único atalho (`Ctrl+Shift+F9`) ou botão no menu `Run`.
- 📱 **Detecção e ABI Inteligente**: Detecta celulares conectados via USB (`adb devices -l`), seleciona automaticamente a arquitetura nativa correta (`arm64-v8a` ou `armeabi-v7a`).
- 🔧 **Invocação Transparente do FPC**: Dispara o compilador cruzado Free Pascal com `-Tandroid -Paarch64 -O3 -fPIC` gerando a biblioteca nativa `liblazapp.so`.
- 📦 **Scaffold Android Leve**: Integração direta com Gradle Wrapper e `android.app.NativeActivity`, sem necessidade de escrever código Java/Kotlin ou criar centenas de wrappers JNI manuais.
- 💬 **Canalização de Logs em Tempo Real**: Captura o `stdout`/`stderr` do build e canaliza os logs de execução do Logcat (`__android_log_print`) diretamente para a aba **Messages** do Lazarus.
- ⚙️ **Painel de Opções Integrado**: Gerenciador de caminhos do SDK, NDK, ADB, JDK e FPC integrado ao diálogo `Tools -> Options` com botão de autodetecção automática.

---

## 📂 Estrutura de Diretórios do Projeto

```
d:\Projetos AntiGravity\LazarusAndroid\
├── package/                                # Lazarus Open Tools Package
│   ├── LazDroidDeploy.lpk                 # Arquivo de definição do pacote Lazarus
│   ├── LazDroidDeploy_Reg.pas             # Registro de menus, comandos e atalhos de teclado
│   ├── LazDroidConfig.pas                 # Persistência via LazConfigStorage (XML)
│   ├── LazDroidConfigFrame.pas            # Frame de configuração em Tools -> Options
│   ├── LazDroidConfigFrame.lfm            # Layout LFM das configurações da IDE
│   ├── LazDroidDeviceManager.pas          # Detecção de dispositivos via ADB (adb devices -l)
│   ├── LazDroidDeviceSelectDlg.pas        # Diálogo modal de seleção de aparelho USB
│   ├── LazDroidDeviceSelectDlg.lfm        # Layout LFM da seleção de dispositivos
│   ├── LazDroidProcessRunner.pas          # Executor assíncrono (TThread + TProcess + Pipes)
│   └── LazDroidPipeline.pas               # Orquestrador mestre em 6 estágios
│
├── scaffold/                              # Template Android minimalista pronto
│   ├── build.gradle                       # Gradle root build script
│   ├── settings.gradle                    # Gradle settings
│   ├── gradle.properties                  # Parâmetros JVM & AndroidX
│   ├── gradlew.bat                        # Gradle Wrapper para Windows
│   ├── gradle/wrapper/                    # Gradle Wrapper properties
│   │   └── gradle-wrapper.properties
│   └── app/                               # Módulo principal da aplicação
│       ├── build.gradle                   # Gradle app script (minSdk 21, targetSdk 34)
│       └── src/main/
│           ├── AndroidManifest.xml        # Configurado para android.app.NativeActivity
│           ├── res/values/strings.xml     # Recursos de string
│           └── jniLibs/                   # Diretório de injeção das bibliotecas compiladas
│               ├── arm64-v8a/             # Alvo AArch64 (64-bit)
│               └── armeabi-v7a/           # Alvo ARMv7 (32-bit)
│
├── demo/                                  # Aplicação Pascal de Demonstração
│   ├── LazAndroidDemo.lpi                 # Arquivo de projeto Lazarus
│   ├── LazAndroidDemo.lpr                 # Biblioteca Pascal exportando ANativeActivity_onCreate
│   ├── AndroidNativeActivity.pas          # Bindings FPC para NativeActivity & NativeWindow
│   └── AndroidLog.pas                     # Wrapper de Logcat nativo (__android_log_print)
│
└── docs/                                  # Documentação de Arquitetura e Uso
    ├── ARCHITECTURE.md                    # Diagramas Mermaid e detalhes da arquitetura
    └── INSTALL_GUIDE.md                   # Guia passo a passo de instalação e teste USB
```

---

## 🚀 Como Usar em 3 Passos

1. **Instale o Pacote na IDE:**
   - No Lazarus, abra `package/LazDroidDeploy.lpk`, clique em **Compile** e depois em **Use -> Install**.
2. **Configure suas Ferramentas:**
   - Acesse `Tools -> Options -> Environment -> LazDroid Android Deploy` e clique em **Autodetectar Ferramentas**.
3. **Execute:**
   - Conecte seu smartphone via USB com a *Depuração USB* ativada.
   - Abra `demo/LazAndroidDemo.lpi` e tecle **`Ctrl + Shift + F9`**!

Para detalhes aprofundados, consulte a documentação técnica em [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) e o guia passo a passo em [`docs/INSTALL_GUIDE.md`](docs/INSTALL_GUIDE.md).
