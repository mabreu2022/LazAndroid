# Instaladores e Configuradores Automáticos do LazDroid

Este diretório contém os scripts, recursos e fontes dos instaladores do **LazDroid**, projetados para automatizar 100% da configuração necessária para transformar uma instalação padrão do **Lazarus IDE (Windows)** em um ambiente profissional de desenvolvimento Android, com suporte a **Formulários Visuais LCL reais (CustomDrawn Android)**.

O projeto disponibiliza duas opções de instaladores prontos:

---

## 📦 1. Instalador Executável do Windows (`Setup-LazAndroid.exe`)

Ideal para distribuição para clientes, novos membros da equipe e desenvolvedores que desejam um instalador tradicional do Windows com assistente passo a passo (*Inno Setup*):

* **Localização do executável gerado:** `dist\Setup-LazAndroid.exe`
* **Código-fonte do script:** `tools\installer\Setup-LazAndroid.iss`
* **Compilação:** Compilável com `ISCC.exe` (Inno Setup 6).
* **Recursos incluídos:**
  - Instalação limpa no diretório escolhido (padrão: `C:\LazAndroid`).
  - Inclui binários do compilador cruzado FPC AArch64 e units RTL Android completas (instalação offline).
  - Cria atalhos no Menu Iniciar:
    * *LazDroid - Assistente de Instalação e Configuração*
    * *LazDroid - Restaurar Layout Delphi na IDE*
    * *LazDroid - Manual de Componentes Mobile (HTML)*
    * *LazDroid - Livro Oficial LazDroid (HTML)*
    * *LazDroid - Manual em PDF*
    * *Demos 1 a 5*
    * *Desinstalador oficial*
  - Ao término, oferece a execução imediata do **Assistente Visual LazDroid** para configurar o Lazarus com 1 clique.

---

## ⚡ 2. Assistente Visual Nativo 1-Clique (`Instalar-LazDroid.exe`)

Ideal para quem clonou o repositório Git ou extraiu o pacote `.zip`:

* **Localização:** Raiz do projeto (`Instalar-LazDroid.exe` ou através de `Instalar-LazDroid.cmd`).
* **Código-fonte:** Projeto LCL em Pascal localizado em `tools\installer_gui\LazDroidInstaller.lpi`.
* **Vantagens:**
  - Executável nativo compilado em Free Pascal / LCL (sem dependências externas de scripts ou permissões de política de execução do PowerShell).
  - Detecção visual e em tempo real de caminhos: Lazarus IDE, FPC, Java JDK, Android SDK, ADB, Android NDK.
  - Checklist visual interativo com status de cada componente.
  - Log detalhado em tempo real da compilação e registros.
  - Botão **"⚡ Instalar Tudo (1-Clique)"** que executa:
    1. Instalação do compilador cruzado FPC AArch64 (`ppcrossa64.exe`).
    2. Cópia das units da RTL/FCL para `aarch64-android` e `arm-android`.
    3. Aplicação dos patches LCL CustomDrawn (teclado virtual móvel `csRequiresKeyboardInput` e proteção de fonte `{$ifndef CD_UseNativeText}`).
    4. Compilação da LCL CustomDrawn para Android AArch64.
    5. Registro dos pacotes `LazDroidControls.lpk` e `LazDroidDeploy.lpk`.
    6. Autodetecção de ferramentas Android/Java e gravação de `lazdroiddeploy.xml` e `local.properties`.
    7. Reconstrução da IDE Lazarus com LazDroid integrado.
  - Botão **"🎨 Layout Delphi"** para organizar as janelas do Lazarus no estilo docked do Delphi.
  - Botão **"🚀 Abrir IDE"** para iniciar o Lazarus imediatamente.

---

## 🛠️ 3. Script PowerShell para CI/CD e Terminal (`install.ps1`)

Para quem prefere linha de comando ou automações de build (CI/CD):

```cmd
:: Executa em modo CLI via prompt de comando
Instalar-LazDroid.cmd --cli
```

Ou diretamente pelo PowerShell:

```powershell
# Instalação padrão interativa
.\tools\installer\install.ps1

# Instalação apontando para um diretório específico do Lazarus
.\tools\installer\install.ps1 -LazarusDir "D:\LazarusCustom"

# Instalação não-interativa silenciosa (ideal para scripts / CI)
.\tools\installer\install.ps1 -NonInteractive -RebuildIDE
```

---

## 📱 Testando Após a Instalação

1. Abra o **Lazarus IDE**.
2. Vá em `Arquivo -> Novo... -> Aplicação Android (LazDroid)`.
3. Desenhe seus botões e telas no Form Designer visualmente.
4. Conecte o celular Android via cabo USB (com *Depuração USB* ativada).
5. Tecle **`Ctrl + Shift + F9`**!
