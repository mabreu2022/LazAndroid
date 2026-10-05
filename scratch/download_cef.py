# -*- coding: utf-8 -*-
"""
Script para download e extração dos binários do Chromium Embedded Framework (CEF 90.5.4)
diretamente na pasta C:\cef para uso com o CEF4Delphi no Lazarus.
"""
import os
import sys
import urllib.request
import tarfile
import shutil
import time

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

CEF_BASE_DIR = r"C:\cef"
WIN64_URL = "https://cef-builds.spotifycdn.com/cef_binary_90.5.4%2Bgc6a4331%2Bchromium-90.0.4430.72_windows64.tar.bz2"
WIN32_URL = "https://cef-builds.spotifycdn.com/cef_binary_90.5.4%2Bgc6a4331%2Bchromium-90.0.4430.72_windows32.tar.bz2"

def download_with_progress(url, dest_path):
    print(f"\n>>> Baixando: {os.path.basename(dest_path)}...")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp, open(dest_path, 'wb') as out_file:
        total_size = int(resp.getheader('Content-Length', 0))
        downloaded = 0
        block_size = 1024 * 1024  # 1MB
        start_time = time.time()
        last_print = 0

        while True:
            chunk = resp.read(block_size)
            if not chunk:
                break
            out_file.write(chunk)
            downloaded += len(chunk)
            
            # Printa progresso a cada 10MB ou 2 segundos
            now = time.time()
            if now - last_print > 1.5 or downloaded == total_size:
                elapsed = max(0.1, now - start_time)
                speed_mb = (downloaded / (1024 * 1024)) / elapsed
                percent = (downloaded / total_size * 100) if total_size > 0 else 0
                mb_down = downloaded / (1024 * 1024)
                mb_total = total_size / (1024 * 1024)
                print(f"    Progresso: {mb_down:.1f} MB / {mb_total:.1f} MB ({percent:.1f}%) - {speed_mb:.1f} MB/s", flush=True)
                last_print = now

    print(f"[OK] Download concluido: {dest_path} ({os.path.getsize(dest_path)} bytes)")

def extract_cef_archive(tar_path, target_dir):
    print(f"\n>>> Extraindo {os.path.basename(tar_path)}...")
    temp_extract = os.path.join(CEF_BASE_DIR, "_temp_extract")
    os.makedirs(temp_extract, exist_ok=True)
    
    with tarfile.open(tar_path, "r:bz2") as tar:
        # Extrai seletivamente apenas Release e Resources para economizar tempo e espaço
        members = []
        for m in tar.getmembers():
            parts = m.name.split("/")
            if len(parts) > 1 and parts[1] in ("Release", "Resources"):
                members.append(m)
        print(f"    Total de arquivos essenciais (Release + Resources): {len(members)}")
        tar.extractall(path=temp_extract, members=members)

    # Identifica a pasta raiz extraída
    subdirs = [d for d in os.listdir(temp_extract) if os.path.isdir(os.path.join(temp_extract, d))]
    if not subdirs:
        raise RuntimeError("Pasta extraída não encontrada")
    root_extracted = os.path.join(temp_extract, subdirs[0])
    
    # Copia Release e Resources para target_dir
    os.makedirs(target_dir, exist_ok=True)
    release_dir = os.path.join(root_extracted, "Release")
    resources_dir = os.path.join(root_extracted, "Resources")

    print(f"    Copiando binários para {target_dir}...")
    if os.path.exists(release_dir):
        for item in os.listdir(release_dir):
            s = os.path.join(release_dir, item)
            d = os.path.join(target_dir, item)
            if os.path.isdir(s):
                shutil.copytree(s, d, dirs_exist_ok=True)
            else:
                shutil.copy2(s, d)

    if os.path.exists(resources_dir):
        for item in os.listdir(resources_dir):
            s = os.path.join(resources_dir, item)
            d = os.path.join(target_dir, item)
            if os.path.isdir(s):
                shutil.copytree(s, d, dirs_exist_ok=True)
            else:
                shutil.copy2(s, d)

    # Limpa temporários
    shutil.rmtree(temp_extract, ignore_errors=True)
    print(f"[OK] Binarios organizados com sucesso em: {target_dir}")

def main():
    os.makedirs(CEF_BASE_DIR, exist_ok=True)
    win64_dir = os.path.join(CEF_BASE_DIR, "win64")
    win32_dir = os.path.join(CEF_BASE_DIR, "win32")

    tar_win64 = os.path.join(CEF_BASE_DIR, "cef_win64.tar.bz2")
    tar_win32 = os.path.join(CEF_BASE_DIR, "cef_win32.tar.bz2")

    # 1. Download e extração do Windows 64-bit (padrão principal)
    if not os.path.exists(tar_win64) or os.path.getsize(tar_win64) < 1000000:
        download_with_progress(WIN64_URL, tar_win64)
    
    extract_cef_archive(tar_win64, win64_dir)

    # Copia também diretamente para a raiz C:\cef para acesso imediato pelos projetos
    print(f"\n>>> Replicando binários 64-bit na raiz C:\\cef...")
    for item in os.listdir(win64_dir):
        s = os.path.join(win64_dir, item)
        d = os.path.join(CEF_BASE_DIR, item)
        if s in (win64_dir, win32_dir) or item in ("win64", "win32", "cef_win64.tar.bz2", "cef_win32.tar.bz2"):
            continue
        if os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)
        else:
            shutil.copy2(s, d)

    # 2. Download e extração do Windows 32-bit (para compilação em 32-bit)
    if not os.path.exists(tar_win32) or os.path.getsize(tar_win32) < 1000000:
        download_with_progress(WIN32_URL, tar_win32)
    
    extract_cef_archive(tar_win32, win32_dir)

    # Cria arquivo LEIAME informativo em C:\cef
    readme_path = os.path.join(CEF_BASE_DIR, "LEIAME_COMO_USAR.txt")
    with open(readme_path, "w", encoding="utf-8") as f:
        f.write("""=============================================================================
BINÁRIOS DO CHROMIUM EMBEDDED FRAMEWORK (CEF 90.5.4) PARA CEF4DELPHI / LAZARUS
=============================================================================

Esta pasta contém todos os binários oficiais do Chromium compilados e prontos
para utilização com os componentes CEF4Delphi no Lazarus IDE.

ESTRUTURA DE PASTAS:
- C:\\cef\\            -> Binários para aplicações Windows 64-bits (prontos na raiz).
- C:\\cef\\win64\\      -> Cópia isolada dos binários 64-bits (libcef.dll, chrome_elf.dll, locales, etc.).
- C:\\cef\\win32\\      -> Binários para aplicações Windows 32-bits (i386-win32).

ARQUIVOS PRINCIPAIS:
- libcef.dll          : Núcleo do navegador Chromium Embedded Framework.
- chrome_elf.dll      : Camada de suporte de crash e logging.
- d3dcompiler_47.dll  : Compilador de shaders DirectX para aceleração gráfica.
- icudtl.dat          : Biblioteca de internacionalização e fontes Unicode.
- snapshot_blob.bin   : Imagem do motor JavaScript V8.
- v8_context_snapshot.bin : Contexto inicial do V8.
- cef.pak, cef_*.pak  : Recursos visuais, ícones e páginas padrão do Chromium.
- locales\\            : Pacotes de idiomas (incluindo pt-BR.pak).

COMO UTILIZAR NO SEU PROJETO PASCAL NO LAZARUS:

No arquivo .lpr (código principal do projeto), antes de Application.Initialize:

```pascal
uses
  uCEFApplication, ...;

begin
  GlobalCEFApp := TCefApplication.Create;
  // Aponta para esta pasta C:\\cef ou copie os arquivos para a pasta do seu .exe:
  GlobalCEFApp.FrameworkDirPath     := 'C:\\cef';
  GlobalCEFApp.ResourcesDirPath     := 'C:\\cef';
  GlobalCEFApp.LocalesDirPath       := 'C:\\cef\\locales';
  
  if GlobalCEFApp.StartMainProcess then
  begin
    Application.Initialize;
    Application.CreateForm(TForm1, Form1);
    Application.Run;
  end;
  GlobalCEFApp.Free;
end.
```
=============================================================================
""")

    # Remove os arquivos tar.bz2 para liberar ~430MB de espaço em disco
    if os.path.exists(tar_win64):
        os.remove(tar_win64)
    if os.path.exists(tar_win32):
        os.remove(tar_win32)

    print("\n" + "=" * 60)
    print("[OK] SUCESSO! Todos os binarios do CEF 90 foram baixados e organizados em C:\\cef")
    print("=" * 60)

if __name__ == "__main__":
    main()
