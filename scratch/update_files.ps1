# 1. Copiar unit4.pas e unit4.lfm
Copy-Item 'scratch\unit4.pas' 'd:\Fontes Lazarus\Teste LazDroid\unit4.pas' -Force
Copy-Item 'scratch\unit4.lfm' 'd:\Fontes Lazarus\Teste LazDroid\unit4.lfm' -Force

# 2. Copiar unit1.pas
Copy-Item 'scratch\unit1.pas' 'd:\Fontes Lazarus\Teste LazDroid\unit1.pas' -Force

# 3. Atualizar unit1.lfm com eventos OnCreate e OnClick
$lfm1 = [System.IO.File]::ReadAllText('d:\Fontes Lazarus\Teste LazDroid\unit1.lfm', [System.Text.Encoding]::UTF8)
if (-not $lfm1.Contains('OnCreate = FormCreate')) {
    $lfm1 = $lfm1.Replace("Caption = 'Form1'", "Caption = 'Login'`r`n  OnCreate = FormCreate")
}
if (-not $lfm1.Contains('OnClick = LazDroidButton1Click')) {
    $targetBtn = "    object LazDroidButton1: TLazDroidButton`r`n      Left = 12`r`n      Height = 60`r`n      Top = 358`r`n      Width = 372`r`n      Caption = 'Login'`r`n      Font.Height = -18`r`n      Font.Name = 'Segoe UI'`r`n      Font.Style = [fsBold]`r`n    end"
    $replaceBtn = "    object LazDroidButton1: TLazDroidButton`r`n      Left = 12`r`n      Height = 60`r`n      Top = 358`r`n      Width = 372`r`n      Caption = 'Entrar'`r`n      Font.Height = -18`r`n      Font.Name = 'Segoe UI'`r`n      Font.Style = [fsBold]`r`n      OnClick = LazDroidButton1Click`r`n    end"
    if ($lfm1.Contains($targetBtn)) {
        $lfm1 = $lfm1.Replace($targetBtn, $replaceBtn)
    } else {
        $lfm1 = $lfm1.Replace("Caption = 'Login'", "Caption = 'Entrar'`r`n      OnClick = LazDroidButton1Click")
    }
}
[System.IO.File]::WriteAllText('d:\Fontes Lazarus\Teste LazDroid\unit1.lfm', $lfm1, [System.Text.Encoding]::UTF8)

# 4. Copiar unit3.pas
Copy-Item 'scratch\unit3.pas' 'd:\Fontes Lazarus\Teste LazDroid\unit3.pas' -Force

# 5. Copiar project1.lpr
Copy-Item 'scratch\project1.lpr' 'd:\Fontes Lazarus\Teste LazDroid\project1.lpr' -Force

Write-Host 'Arquivos atualizados com sucesso.'
