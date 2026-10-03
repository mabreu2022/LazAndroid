<#
.SYNOPSIS
    Script de Restauracao e Organizacao do Layout Docado da IDE do Lazarus.
.DESCRIPTION
    Reorganiza as janelas docadas do Lazarus (AnchorDocking + DockedFormEditor):
      - Lado Esquerdo: Inspetor de Objetos (Componentes, Propriedades e Eventos).
      - Centro Superior: Editor de Codigo e Designer de Formularios.
      - Centro Inferior: Mensagens, Busca, Watches, Pontos de Parada e Assembler (Abas).
      - Lado Direito Superior: Inspetor de Projeto (Arquivos).
      - Lado Direito Inferior: Explorador de Codigo e Lista de Componentes (Abas).
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Restaurador de Layout do Lazarus"

Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host "           Restaurador de Layout Docado - Lazarus IDE                  " -ForegroundColor Cyan
Write-Host "=======================================================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar se o Lazarus esta em execucao
$lazProc = Get-Process -Name "lazarus", "startlazarus" -ErrorAction SilentlyContinue
if ($lazProc) {
    Write-Host "[!] O Lazarus está em execução no momento." -ForegroundColor Yellow
    Write-Host "    Para que as configurações não sejam sobrescritas ao sair, o Lazarus precisa ser fechado."
    $resp = Read-Host "    Deseja fechar o Lazarus agora para continuar? (S/N)"
    if ($resp -match "^[sSyY]") {
        $lazProc | Stop-Process -Force
        Start-Sleep -Seconds 1
        Write-Host "[+] Lazarus fechado com sucesso." -ForegroundColor Green
    } else {
        Write-Host "[-] Operação cancelada. Feche o Lazarus e tente novamente." -ForegroundColor Red
        return
    }
}

# 2. Localizar pasta de configuracao do Lazarus
$configDir = "$env:LOCALAPPDATA\lazarus"
if (-not (Test-Path "$configDir\environmentoptions.xml")) {
    $configDir = "$env:APPDATA\lazarus"
}

if (-not (Test-Path "$configDir\environmentoptions.xml")) {
    Write-Host "[-] Não foi possível localizar o diretório de configurações do Lazarus em:" -ForegroundColor Red
    Write-Host "    $env:LOCALAPPDATA\lazarus nem $env:APPDATA\lazarus"
    return
}

Write-Host "[*] Diretório de configurações encontrado:" -ForegroundColor Gray
Write-Host "    $configDir" -ForegroundColor White
Write-Host ""

# 3. Fazer backup antes de alterar
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = Join-Path $configDir "backup_layout_$timestamp"
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
Copy-Item "$configDir\*.xml" -Destination $backupDir -ErrorAction SilentlyContinue
Write-Host "[+] Backup preventivo criado em:" -ForegroundColor Green
Write-Host "    $backupDir" -ForegroundColor Gray
Write-Host ""

# 4. XML da estrutura docada padrão
$dockInnerXml = @"
  <Version Value="1" />
  <MainConfig>
    <Nodes ChildCount="1">
      <Item1 Name="MainIDE" Type="CustomSite" WindowState="Maximized" Monitor="0" ChildCount="1" PixelsPerInch="120">
        <Bounds Left="-9" Top="-9" Width="1920" Height="966">
          <WorkArea>
            <Rect Right="1920" Bottom="1020" />
          </WorkArea>
        </Bounds>
        <Item1 Name="AnchorDockSite10" Type="Layout" WindowState="Maximized" Monitor="0" ChildCount="5" PixelsPerInch="120">
          <Bounds Top="100" Width="1920" Height="866" SplitterPos="98" />
          <Anchors Align="Bottom" />
          <Item1 Name="AnchorDockSite12" Type="Layout" WindowState="Maximized" Monitor="0" ChildCount="3" PixelsPerInch="120">
            <Bounds Left="329" Width="1223" Height="866" />
            <Anchors Left="AnchorDockSplitter4" Right="AnchorDockSplitter3" />
            <Item1 Name="SourceNotebook" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
              <Bounds Width="1223" Height="620" />
              <Anchors Bottom="AnchorDockSplitter2" />
            </Item1>
            <Item2 Name="AnchorDockSplitter2" Type="SplitterHorizontal" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
              <Bounds Top="620" Width="1223" Height="5" />
            </Item2>
            <Item3 Name="AnchorDockSite11" Type="Pages" WindowState="Maximized" Monitor="0" ChildCount="5" PixelsPerInch="120">
              <Bounds Top="625" Width="1223" Height="241" />
              <Anchors Top="AnchorDockSplitter2" />
              <Header PageIndex="0" />
              <Item1 Name="MessagesView" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item1>
              <Item2 Name="SearchResults" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item2>
              <Item3 Name="Watches" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item3>
              <Item4 Name="BreakPoints" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item4>
              <Item5 Name="Assembler" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="1193" Height="215" />
                <Anchors Align="Client" />
              </Item5>
            </Item3>
          </Item1>
          <Item2 Name="AnchorDockSplitter3" Type="SplitterVertical" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
            <Bounds Left="1552" Width="11" Height="866" />
          </Item2>
          <Item3 Name="AnchorDockSite14" Type="Layout" WindowState="Maximized" Monitor="0" ChildCount="3" PixelsPerInch="120">
            <Bounds Left="1563" Width="357" Height="866" />
            <Anchors Left="AnchorDockSplitter3" />
            <Item1 Name="ProjectInspector" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
              <Bounds Width="357" Height="450" />
              <Anchors Bottom="AnchorDockSplitter5" />
            </Item1>
            <Item2 Name="AnchorDockSplitter5" Type="SplitterHorizontal" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
              <Bounds Top="450" Width="357" Height="5" />
            </Item2>
            <Item3 Name="AnchorDockSite15" Type="Pages" WindowState="Maximized" Monitor="0" ChildCount="2" PixelsPerInch="120">
              <Bounds Top="455" Width="357" Height="411" />
              <Anchors Top="AnchorDockSplitter5" />
              <Header PageIndex="0" />
              <Item1 Name="CodeExplorerView" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="327" Height="375" />
                <Anchors Align="Client" />
              </Item1>
              <Item2 Name="ComponentList" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
                <Bounds Width="327" Height="375" />
                <Anchors Align="Client" />
              </Item2>
            </Item3>
          </Item3>
          <Item4 Name="ObjectInspectorDlg" Type="Control" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
            <Bounds Width="324" Height="866" />
            <Anchors Right="AnchorDockSplitter4" />
          </Item4>
          <Item5 Name="AnchorDockSplitter4" Type="SplitterVertical" WindowState="Maximized" Monitor="0" PixelsPerInch="120">
            <Bounds Left="324" Width="5" Height="866" />
          </Item5>
        </Item1>
      </Item1>
    </Nodes>
  </MainConfig>
  <Settings FloatingWindowsOnTop="True" HeaderStyle="Line" />
"@

$anchorDockLayoutFileContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<CONFIG>
$dockInnerXml
</CONFIG>
"@

$anchorDockingElementXml = @"
<AnchorDocking>
$dockInnerXml
</AnchorDocking>
"@

# 5. Garantir opções de ativação do AnchorDocking e DockedFormEditor
$anchorOptPath = Join-Path $configDir "anchordockingoptions.xml"
$anchorOptXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<CONFIG>
  <EnableAnchorDock Value="True"/>
  <DoneAskUserEnableAnchorDock Value="True"/>
</CONFIG>
"@
[System.IO.File]::WriteAllText($anchorOptPath, $anchorOptXml, [System.Text.Encoding]::UTF8)

$dockedFormOptPath = Join-Path $configDir "dockedformeditoroptions.xml"
$dockedFormOptXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<CONFIG>
  <EnableDockedDesigner Value="True"/>
  <DoneAskUserEnableDockedDesigner Value="True"/>
</CONFIG>
"@
[System.IO.File]::WriteAllText($dockedFormOptPath, $dockedFormOptXml, [System.Text.Encoding]::UTF8)

# 6. Atualizar anchordocklayout.xml
$layoutFilePath = Join-Path $configDir "anchordocklayout.xml"
[System.IO.File]::WriteAllText($layoutFilePath, $anchorDockLayoutFileContent, [System.Text.Encoding]::UTF8)
Write-Host "[+] Arquivo 'anchordocklayout.xml' gerado com sucesso." -ForegroundColor Green

# 7. Atualizar environmentoptions.xml
$envOptPath = Join-Path $configDir "environmentoptions.xml"
if (Test-Path $envOptPath) {
    try {
        $envDoc = New-Object System.Xml.XmlDocument
        $envDoc.Load($envOptPath)

        $tempDoc = New-Object System.Xml.XmlDocument
        $tempDoc.LoadXml($anchorDockingElementXml)

        $desktops = $envDoc.SelectSingleNode("//Desktops")
        if ($desktops) {
            $desktops.SetAttribute("ActiveDesktop", "default docked")

            foreach ($desktopNode in $desktops.ChildNodes) {
                if ($desktopNode.NodeType -ne [System.Xml.XmlNodeType]::Element) { continue }
                
                $name = $desktopNode.GetAttribute("Name")
                $dockMaster = $desktopNode.GetAttribute("DockMaster")

                if ($dockMaster -eq "TIDEAnchorDockMaster" -or $name -match "dock|mauricio") {
                    $desktopNode.SetAttribute("DockMaster", "TIDEAnchorDockMaster")

                    # Atualizar MainIDE
                    $mainIDE = $desktopNode.SelectSingleNode("MainIDE")
                    if ($mainIDE) {
                        $custPos = $mainIDE.SelectSingleNode("CustomPosition")
                        if ($custPos) {
                            $custPos.SetAttribute("Left", "-9")
                            $custPos.SetAttribute("Top", "-9")
                            $custPos.SetAttribute("Width", "1920")
                            $custPos.SetAttribute("Height", "966")
                        }
                        $winState = $mainIDE.SelectSingleNode("WindowState")
                        if ($winState) { $winState.SetAttribute("Value", "Maximized") }
                        $vis = $mainIDE.SelectSingleNode("Visible")
                        if (-not $vis) {
                            $vis = $envDoc.CreateElement("Visible")
                            [void]$mainIDE.AppendChild($vis)
                        }
                        $vis.SetAttribute("Value", "True")
                    }

                    # Garantir que as janelas essenciais estejam com Visible=True
                    foreach ($formName in @("SourceNotebook", "MessagesView", "ObjectInspectorDlg", "ProjectInspector")) {
                        $formElem = $desktopNode.SelectSingleNode($formName)
                        if ($formElem) {
                            $vis = $formElem.SelectSingleNode("Visible")
                            if (-not $vis) {
                                $vis = $envDoc.CreateElement("Visible")
                                [void]$formElem.AppendChild($vis)
                            }
                            $vis.SetAttribute("Value", "True")
                        }
                    }

                    # Substituir o AnchorDocking pelo layout corrigido
                    $oldAnchor = $desktopNode.SelectSingleNode("AnchorDocking")
                    if ($oldAnchor) {
                        [void]$desktopNode.RemoveChild($oldAnchor)
                    }

                    $importedNode = $envDoc.ImportNode($tempDoc.DocumentElement, $true)
                    [void]$desktopNode.AppendChild($importedNode)
                }
            }
        }

        # Salvar com UTF-8 limpo
        $settings = New-Object System.Xml.XmlWriterSettings
        $settings.Indent = $true
        $settings.IndentChars = "  "
        $settings.Encoding = [System.Text.UTF8Encoding]::new($false)
        $writer = [System.Xml.XmlWriter]::Create($envOptPath, $settings)
        $envDoc.Save($writer)
        $writer.Dispose()

        Write-Host "[+] Configurações em 'environmentoptions.xml' atualizadas com sucesso." -ForegroundColor Green
    }
    catch {
        Write-Host "[-] Aviso ao processar environmentoptions.xml: $_" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host "         Layout Docado Restaurado e Organizado com Sucesso!           " -ForegroundColor Green
Write-Host "=======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Resumo do layout aplicado:"
Write-Host "  * Esquerda:   Inspetor de Objetos (Object Inspector)" -ForegroundColor Cyan
Write-Host "  * Centro Sup: Editor de Código + Designer (SourceNotebook + Form Designer)" -ForegroundColor Cyan
Write-Host "  * Centro Inf: Mensagens, Busca, Watches, BreakPoints e Assembler" -ForegroundColor Cyan
Write-Host "  * Direita:    Inspetor de Projeto (Topo) e Explorador de Código (Base)" -ForegroundColor Cyan
Write-Host ""

$lazarusExe = "C:\lazarus\lazarus.exe"
if (-not (Test-Path $lazarusExe)) {
    $lazarusExe = "D:\lazarus\lazarus.exe"
}

if (Test-Path $lazarusExe) {
    $abrir = Read-Host "Deseja abrir o Lazarus agora? (S/N)"
    if ($abrir -match "^[sSyY]") {
        Write-Host "[*] Iniciando o Lazarus..." -ForegroundColor Green
        Start-Process $lazarusExe
    }
}
