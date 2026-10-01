# Instalador e Configurador Automático do LazDroid-Deploy

Este utilitário automatiza 100% da configuração necessária para transformar uma instalação padrão do **Lazarus IDE (Windows)** em um ambiente profissional de desenvolvimento Android, com suporte a **Formulários Visuais LCL reais (CustomDrawn Android)**.

---

## 🚀 Como Usar (1-Clique)

1. Vá até a raiz do projeto: `d:\Projetos AntiGravity\LazarusAndroid\`
2. Dê um duplo-clique no arquivo:
   ```cmd
   Instalar-LazDroid.cmd
   ```
3. O Windows solicitará privilégios de Administrador (UAC). Clique em **Sim**.
4. O instalador executará os 7 passos em cerca de 15 segundos:
   - ✅ Localização do Lazarus IDE (`C:\lazarus`)
   - ✅ Instalação do compilador cruzado FPC AArch64 (`ppcrossa64.exe` e aliases)
   - ✅ Cópia de todas as units da RTL/FCL para Android (`aarch64-android` e `arm-android`)
   - ✅ Aplicação de suporte a teclado virtual móvel (`csRequiresKeyboardInput`)
   - ✅ Compilação do widgetset LCL CustomDrawn para Android
   - ✅ Registro automático do pacote `LazDroidDeploy.lpk` no Lazarus
   - ✅ Autodetecção do Android SDK, NDK, ADB, JDK e gravação do XML de configuração
5. Ao final, escolha **S** para reconstruir o Lazarus IDE (ou reconstrua manualmente na IDE).

---

## 🛠️ Opções Avançadas via Linha de Comando (PowerShell)

Você também pode executar o script diretamente pelo PowerShell:

```powershell
# Instalação padrão interativa
.\tools\installer\install.ps1

# Instalação apontando para um diretório específico do Lazarus
.\tools\installer\install.ps1 -LazarusDir "D:\LazarusCustom"

# Instalação não-interativa (ideal para scripts / CI)
.\tools\installer\install.ps1 -NonInteractive -RebuildIDE
```

---

## 📱 Testando Após a Instalação

1. Abra o **Lazarus IDE**.
2. Vá em `Arquivo -> Novo... -> Aplicação Android (LazDroid)`.
3. Desenhe seus botões e telas no Form Designer visualmente.
4. Conecte o celular Android via cabo USB (com *Depuração USB* ativada).
5. Tecle **`Ctrl + Shift + F9`**!
