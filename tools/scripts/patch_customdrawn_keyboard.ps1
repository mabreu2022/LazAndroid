$filePath = 'C:\lazarus\lcl\interfaces\customdrawn\customdrawnwsstdctrls.pas'
if (Test-Path $filePath) {
    $content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8)
    $target = "class function TCDWSCustomEdit.CreateHandle(const AWinControl: TWinControl;`r`n  const AParams: TCreateParams): HWND;`r`nvar`r`n  lCDWinControl: TCDWinControl;`r`nbegin`r`n  Result := TCDWSWinControl.CreateHandle(AWinControl, AParams);"
    $replacement = "class function TCDWSCustomEdit.CreateHandle(const AWinControl: TWinControl;`r`n  const AParams: TCreateParams): HWND;`r`nvar`r`n  lCDWinControl: TCDWinControl;`r`nbegin`r`n  if Assigned(AWinControl) then`r`n    AWinControl.ControlStyle := AWinControl.ControlStyle + [csRequiresKeyboardInput];`r`n  Result := TCDWSWinControl.CreateHandle(AWinControl, AParams);"
    
    # Try normalized CR-LF and LF
    if ($content.Contains("Result := TCDWSWinControl.CreateHandle(AWinControl, AParams);")) {
        $newContent = $content.Replace(
            "Result := TCDWSWinControl.CreateHandle(AWinControl, AParams);",
            "if Assigned(AWinControl) then`r`n    AWinControl.ControlStyle := AWinControl.ControlStyle + [csRequiresKeyboardInput];`r`n  Result := TCDWSWinControl.CreateHandle(AWinControl, AParams);"
        )
        [System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)
        Write-Host "PATCH_SUCCESS: csRequiresKeyboardInput added to TCDWSCustomEdit.CreateHandle"
    } else {
        Write-Host "TARGET_NOT_FOUND"
    }
} else {
    Write-Host "FILE_NOT_FOUND: $filePath"
}
