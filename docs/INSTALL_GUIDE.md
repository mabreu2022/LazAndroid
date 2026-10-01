# Guia de Instalação e Teste Rápido — LazDroid-Deploy

Este guia descreve o passo a passo completo para instalar o pacote **LazDroid-Deploy** no Lazarus IDE, configurar a cadeia de ferramentas (toolchain) e realizar seu primeiro deploy em um aparelho Android físico conectado via USB.

---

## 1. Pré-Requisitos do Sistema

Para executar a esteira de compilação cruzada e deploy, certifique-se de possuir:

1. **Lazarus IDE (v2.2, 3.0 ou superior)** com Free Pascal (FPC 3.2.2+).
2. **FPC Cross-Compiler para Android**:
   - Binário `ppca64.exe` (para AArch64 / `arm64-v8a`) e/ou `ppcarm.exe` (para ARMv7 / `armeabi-v7a`).
   - *Dica:* A forma mais rápida e confiável de obter o compilador cruzado Android no Lazarus Windows/Linux é através do **[fpcupdeluxe](https://github.com/LongDirtyAnimElf/fpcupdeluxe/releases)**, selecionando CPU `aarch64` e OS `android`.
3. **Android SDK & Platform-Tools**:
   - `adb.exe` funcional no `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe` ou adicionado ao `PATH`.
4. **Android NDK (r21b a r26c+)**:
   - Disponível no `%LOCALAPPDATA%\Android\Sdk\ndk\<versão>` ou pasta customizada.
5. **Java JDK 17 / Android Studio JBR**:
   - Java Development Kit versão 17 ou superior para o Gradle 8.2+.

---

## 2. Instalação do Pacote na IDE Lazarus

Siga os passos abaixo para integrar o LazDroid-Deploy nativamente à interface do Lazarus:

1. Abra a IDE **Lazarus**.
2. No menu superior, clique em:
   ```
   Package  ->  Open Package File (.lpk)...
   ```
3. Navegue até o diretório do projeto e selecione:
   ```
   d:\Projetos AntiGravity\LazarusAndroid\package\LazDroidDeploy.lpk
   ```
4. Na janela do Gerenciador de Pacotes que se abrirá:
   - Clique em **Compile** (Compilar) para validar que todas as units compilaram sem erros.
   - Em seguida, clique em **Use** -> **Install** (Instalar).
5. O Lazarus exibirá a mensagem de confirmação para reconstruir a IDE. Confirme com **Yes**.
6. A IDE será recompilada e reiniciada automaticamente com o plugin ativado.

---

## 3. Configuração dos Caminhos da Toolchain

Após reiniciar a IDE, configure os diretórios dos compiladores e ferramentas:

1. Acesse o menu:
   ```
   Tools  ->  Options...  (Ferramentas -> Opções)
   ```
2. Na árvore lateral à esquerda, expanda o grupo **Environment** e clique em:
   ```
   LazDroid Android Deploy
   ```
3. Clique no botão superior **"Autodetectar Ferramentas"**:
   - O LazDroid irá varrer o sistema e preencher os caminhos do Android SDK, NDK, ADB e FPC instalados.
4. Se necessário, ajuste os campos manualmente:
   - **Android SDK Root**: `C:\Users\<SeuUsuario>\AppData\Local\Android\Sdk`
   - **Android NDK Root**: `C:\Users\<SeuUsuario>\AppData\Local\Android\Sdk\ndk\21.4.7075529`
   - **Executável ADB**: `C:\Users\<SeuUsuario>\AppData\Local\Android\Sdk\platform-tools\adb.exe`
   - **Java Home**: `C:\Program Files\Eclipse Adoptium\jdk-21.0.7.6-hotspot` (ou `jbr`)
   - **Compilador AArch64**: `C:\lazarus\fpc\3.2.2\bin\i386-win32\ppcrossa64.exe` (ou `ppca64.exe`)
   - **Compilador ARMv7**: `C:\lazarus\fpc\3.2.2\bin\i386-win32\ppcrossarm.exe` (ou `ppcarm.exe`)
   - **Diretório do Scaffold**: `d:\Projetos AntiGravity\LazarusAndroid\scaffold`
5. Clique em **OK** para salvar as configurações no `lazdroiddeploy.xml`.

---

## 4. Preparação do Aparelho Android (USB)

1. No celular Android, ative o **Modo Desenvolvedor**:
   - Vá em *Configurações* -> *Sobre o telefone* -> Toque 7 vezes em *Número da Versão*.
2. Em *Opções do desenvolvedor*, ative:
   - **Depuração USB** (USB Debugging).
   - **Instalar via USB** (se aplicável ao fabricante, ex.: Xiaomi/MIUI).
3. Conecte o cabo USB ao computador.
4. Quando surgir a janela *"Permitir depuração USB?"* no celular, marque *"Sempre permitir a partir deste computador"* e clique em **Permitir**.
5. Teste a conexão abrindo o terminal e digitando:
   ```cmd
   adb devices -l
   ```
   O dispositivo deve aparecer com status `device` (não `unauthorized` ou `offline`).

---

## 5. Primeiro Deploy em 1-Clique

1. No Lazarus, abra qualquer um dos projetos de demonstração:
   - `demo/LazAndroidDemo.lpi` — Aplicação comercial completa (Login + Vendas + SQLite)
   - `demo2/project1.lpi` — Exemplo minimalista com botão e diálogo
   - `demo3/demo3.lpi` — Exemplo multi-aba com TPageControl, TTabSheet, TPanel, TEdit, TLabel
2. Inicie o deploy de qualquer uma das três formas:
   - Pressione o atalho: **`Ctrl + Shift + F9`**
   - Acesse o menu: **`Run  ->  Deploy & Run on Android Device (USB)`**
   - Ou clique no botão dedicado na barra de ferramentas da IDE.
3. Se mais de um aparelho estiver conectado, o diálogo **"Selecionar Dispositivo Android"** surgirá mostrando Modelo, Serial e ABI (CPU). Selecione o aparelho desejado e clique em **Deploy & Run**.
4. Observe a aba **Messages** no rodapé do Lazarus:
   - **Estágio 1/6**: Pre-Check & Resolução de ABI.
   - **Estágio 2/6**: O compilador FPC compila `liblazapp.so` diretamente para `app/src/main/jniLibs/arm64-v8a/`.
   - **Estágio 3/6**: Gradle Wrapper compila e assina o APK em modo Debug (`app-debug.apk`).
   - **Estágio 4/6**: ADB transfere e instala o pacote no celular (`adb install -r -d`).
   - **Estágio 5/6**: ADB dispara a Intent da Activity (`am start`).
   - **Estágio 6/6**: O console de logs do Logcat canaliza as mensagens `lclapp` diretamente para a janela de mensagens da IDE!
5. Olhe para a tela do seu celular: a aplicação Pascal nativa inicializará em tela cheia com a interface renderizada diretamente no buffer de vídeo!

---

## 6. Criando um Novo Aplicativo Android do Zero

Com o pacote instalado, você pode criar projetos Android visuais diretamente pelo assistente do Lazarus:

1. Acesse o menu:
   ```
   Arquivo  ->  Novo...  (ou Projeto -> Novo Projeto...)
   ```
2. Na lista de tipos de projeto, selecione:
   ```
   Aplicação Android (LazDroid)
   ```
3. A IDE criará automaticamente:
   - O arquivo `.lpr` configurado como biblioteca (`library`), exportando `JNI_OnLoad` e configurando `CDWidgetset.ActivityClassName`.
   - O formulário visual inicial `Unit1.pas` (`TForm1`) aberto no Form Designer.
   - O `LCLWidgetType` configurado como `customdrawn` e arquitetura alvo `aarch64-android`.
4. Desenhe seus botões, caixas de texto e painéis no Form Designer normalmente.
5. Salve o projeto em uma pasta de sua preferência e pressione **`Ctrl + Shift + F9`**!

