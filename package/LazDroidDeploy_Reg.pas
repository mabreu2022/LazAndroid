{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidDeploy_Reg.pas
  Descrição: Registro de comandos, menus, atalhos de teclado e painel de opções no Lazarus IDE.
}
unit LazDroidDeploy_Reg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, LCLType,
  // Lazarus Open Tools API units
  MenuIntf, IDECommands, LazIDEIntf, IDEOptionsIntf, IDEOptEditorIntf, IDEWindowIntf,
  // LazDroid units
  LazDroidConfig, LazDroidConfigFrame, LazDroidDeviceManager,
  LazDroidDeviceSelectDlg, LazDroidPipeline, LazDroidProcessRunner,
  LazDroidProjectDescriptor, LazDroidTargetDockWin, LazDroidEditorBar,
  // Debugger Open Tools
  BaseDebugManager, GDBMIServerDebugger, GDBMIDebugger, IdeDebuggerOpts, ProjectDebugLink
  {$IFDEF WINDOWS}
  , Windows
  {$ENDIF}
  ;

var
  DroidOptionsIndex: Integer = 1050;

procedure Register;
procedure DoDeployAndRun(Sender: TObject);
procedure DoOpenLogcat(Sender: TObject);

implementation

var
  CmdDeployAndRun: TIDECommand = nil;
  CmdDeployAndDebug: TIDECommand = nil;
  CmdCancelDeploy: TIDECommand = nil;
  CmdConfigureProject: TIDECommand = nil;
  CmdViewTarget: TIDECommand = nil;
  GlobalPipeline: TLazDroidPipeline = nil;

type
  TElf64_Ehdr = packed record
    e_ident: array[0..15] of Byte;
    e_type: Word;
    e_machine: Word;
    e_version: Cardinal;
    e_entry: QWord;
    e_phoff: QWord;
    e_shoff: QWord;
    e_flags: Cardinal;
    e_ehsize: Word;
    e_phentsize: Word;
    e_phnum: Word;
    e_shentsize: Word;
    e_shnum: Word;
    e_shstrndx: Word;
  end;

  TElf64_Shdr = packed record
    sh_name: Cardinal;
    sh_type: Cardinal;
    sh_flags: QWord;
    sh_addr: QWord;
    sh_offset: QWord;
    sh_size: QWord;
    sh_link: Cardinal;
    sh_info: Cardinal;
    sh_addralign: QWord;
    sh_entsize: QWord;
  end;

  TElf32_Ehdr = packed record
    e_ident: array[0..15] of Byte;
    e_type: Word;
    e_machine: Word;
    e_version: Cardinal;
    e_entry: Cardinal;
    e_phoff: Cardinal;
    e_shoff: Cardinal;
    e_flags: Cardinal;
    e_ehsize: Word;
    e_phentsize: Word;
    e_phnum: Word;
    e_shentsize: Word;
    e_shnum: Word;
    e_shstrndx: Word;
  end;

  TElf32_Shdr = packed record
    sh_name: Cardinal;
    sh_type: Cardinal;
    sh_flags: Cardinal;
    sh_addr: Cardinal;
    sh_offset: Cardinal;
    sh_size: Cardinal;
    sh_link: Cardinal;
    sh_info: Cardinal;
    sh_addralign: Cardinal;
    sh_entsize: Cardinal;
  end;

function GetElfTextSectionOffset(const AFilename: string): QWord;
var
  FS: TFileStream;
  Ident: array[0..15] of Byte;
  Hdr64: TElf64_Ehdr;
  Shdr64, StrShdr64: TElf64_Shdr;
  Hdr32: TElf32_Ehdr;
  Shdr32, StrShdr32: TElf32_Shdr;
  StrTable: array of Byte;
  i: Integer;
  SecName: string;
begin
  Result := 0;
  if not FileExists(AFilename) then Exit;
  try
    FS := TFileStream.Create(AFilename, fmOpenRead or fmShareDenyNone);
    try
      if FS.Read(Ident, 16) < 16 then Exit;
      if (Ident[0] <> $7F) or (Ident[1] <> Byte('E')) or (Ident[2] <> Byte('L')) or (Ident[3] <> Byte('F')) then Exit;
      FS.Position := 0;
      if Ident[4] = 2 then // 64-bit ELF
      begin
        if FS.Read(Hdr64, SizeOf(Hdr64)) < SizeOf(Hdr64) then Exit;
        if (Hdr64.e_shoff = 0) or (Hdr64.e_shnum = 0) or (Hdr64.e_shstrndx >= Hdr64.e_shnum) then Exit;
        FS.Position := Int64(Hdr64.e_shoff) + Int64(Hdr64.e_shstrndx) * Int64(Hdr64.e_shentsize);
        if FS.Read(StrShdr64, SizeOf(StrShdr64)) < SizeOf(StrShdr64) then Exit;
        SetLength(StrTable, StrShdr64.sh_size);
        FS.Position := Int64(StrShdr64.sh_offset);
        FS.Read(StrTable[0], StrShdr64.sh_size);
        for i := 0 to Hdr64.e_shnum - 1 do
        begin
          FS.Position := Int64(Hdr64.e_shoff) + Int64(i) * Int64(Hdr64.e_shentsize);
          if FS.Read(Shdr64, SizeOf(Shdr64)) = SizeOf(Shdr64) then
          begin
            if (Shdr64.sh_name < StrShdr64.sh_size) then
            begin
              SecName := PChar(@StrTable[Shdr64.sh_name]);
              if SecName = '.text' then
              begin
                Result := Shdr64.sh_addr;
                if Result = 0 then Result := Shdr64.sh_offset;
                Exit;
              end;
            end;
          end;
        end;
      end
      else if Ident[4] = 1 then // 32-bit ELF
      begin
        if FS.Read(Hdr32, SizeOf(Hdr32)) < SizeOf(Hdr32) then Exit;
        if (Hdr32.e_shoff = 0) or (Hdr32.e_shnum = 0) or (Hdr32.e_shstrndx >= Hdr32.e_shnum) then Exit;
        FS.Position := Int64(Hdr32.e_shoff) + Int64(Hdr32.e_shstrndx) * Int64(Hdr32.e_shentsize);
        if FS.Read(StrShdr32, SizeOf(StrShdr32)) < SizeOf(StrShdr32) then Exit;
        SetLength(StrTable, StrShdr32.sh_size);
        FS.Position := Int64(StrShdr32.sh_offset);
        FS.Read(StrTable[0], StrShdr32.sh_size);
        for i := 0 to Hdr32.e_shnum - 1 do
        begin
          FS.Position := Int64(Hdr32.e_shoff) + Int64(i) * Int64(Hdr32.e_shentsize);
          if FS.Read(Shdr32, SizeOf(Shdr32)) = SizeOf(Shdr32) then
          begin
            if (Shdr32.sh_name < StrShdr32.sh_size) then
            begin
              SecName := PChar(@StrTable[Shdr32.sh_name]);
              if SecName = '.text' then
              begin
                Result := Shdr32.sh_addr;
                if Result = 0 then Result := Shdr32.sh_offset;
                Exit;
              end;
            end;
          end;
        end;
      end;
    finally
      FS.Free;
    end;
  except
    Result := 0;
  end;
end;

function QueryLibLazAppTextAddress(const AAdbPath, ASerial, APackage, ALocalModule: string): string;
var
  DevMgr: TLazDroidDeviceManager;
  TargetPid: string;
  OutMaps: string;
  Lines: TStringList;
  i, Attempt: Integer;
  Line: string;
  DashPos: Integer;
  BaseHexStr: string;
  BaseAddr: QWord;
  TextOffset: QWord;
  ValCode: Integer;
begin
  Result := '';
  DevMgr := TLazDroidDeviceManager.Create(AAdbPath);
  Lines := TStringList.Create;
  try
    for Attempt := 1 to 10 do
    begin
      if DevMgr.RunCommandSync(AAdbPath, ['-s', ASerial, 'shell', 'pidof', APackage], TargetPid) = 0 then
      begin
        TargetPid := StringReplace(StringReplace(TargetPid, #13, '', [rfReplaceAll]), #10, '', [rfReplaceAll]);
        TargetPid := Trim(TargetPid);
        if Pos(' ', TargetPid) > 0 then
          TargetPid := Copy(TargetPid, 1, Pos(' ', TargetPid) - 1);
        if TargetPid <> '' then
        begin
          if DevMgr.RunCommandSync(AAdbPath, ['-s', ASerial, 'shell', 'run-as', APackage, 'grep', 'liblazapp', '/proc/' + TargetPid + '/maps'], OutMaps) = 0 then
          begin
            Lines.Text := OutMaps;
            for i := 0 to Lines.Count - 1 do
            begin
              Line := Lines[i];
              if (Pos('r-xp', Line) > 0) and (Pos('liblazapp.so', Line) > 0) then
              begin
                DashPos := Pos('-', Line);
                if DashPos > 1 then
                begin
                  BaseHexStr := Trim(Copy(Line, 1, DashPos - 1));
                  Val('$' + BaseHexStr, BaseAddr, ValCode);
                  if (ValCode = 0) and (BaseAddr > 0) then
                  begin
                    TextOffset := GetElfTextSectionOffset(ALocalModule);
                    Result := '0x' + LowerCase(IntToHex(BaseAddr + TextOffset, 8));
                    Exit;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
      Sleep(200);
    end;
  finally
    Lines.Free;
    DevMgr.Free;
  end;
end;

procedure ConfigureGdbServerDebugger(const ANDKRoot, ALocalModule: string; APort: Integer; const AArchitecture, ATextAddrHex: string);
var
  GdbExe: string;
  PythonDir: string;
  vList: TDebuggerPropertiesConfigList;
  vConfig: TDebuggerPropertiesConfig;
  vProps: TGDBMIServerDebuggerProperties;
  ModuleFile: string;
begin
  // 1. Localiza o executável gdb-orig.exe ou gdb.exe do NDK
  GdbExe := IncludeTrailingPathDelimiter(ANDKRoot) + 'prebuilt' + DirectorySeparator +
            'windows-x86_64' + DirectorySeparator + 'bin' + DirectorySeparator + 'gdb-orig.exe';
  if not FileExists(GdbExe) then
    GdbExe := IncludeTrailingPathDelimiter(ANDKRoot) + 'prebuilt' + DirectorySeparator +
              'windows-x86_64' + DirectorySeparator + 'bin' + DirectorySeparator + 'gdb.exe';

  // 2. Define PYTHONHOME para o Python 2.7 do NDK (necessário para o gdb do NDK)
  PythonDir := IncludeTrailingPathDelimiter(ANDKRoot) + 'prebuilt' + DirectorySeparator + 'windows-x86_64';
  {$IFDEF WINDOWS}
  Windows.SetEnvironmentVariable('PYTHONHOME', PChar(PythonDir));
  {$ELSE}
  SetEnvironmentVariable('PYTHONHOME', PythonDir);
  {$ENDIF}

  ModuleFile := StringReplace(ALocalModule, '\', '/', [rfReplaceAll]);

  // 3. Configura no DbgProjectLink (opções do projeto atual)
  vList := DbgProjectLink.DebuggerPropertiesConfigList;
  if Assigned(vList) then
  begin
    vConfig := vList.EntryByName('LazDroid GDBServer', TGDBMIServerDebugger.ClassName);
    if not Assigned(vConfig) then
    begin
      vConfig := TDebuggerPropertiesConfig.CreateForDebuggerClass(TGDBMIServerDebugger, True);
      vConfig.ConfigName := 'LazDroid GDBServer';
    end;
    vConfig.Active := True;
    vConfig.DebuggerFilename := GdbExe;

    if Assigned(vConfig.DebuggerProperties) and (vConfig.DebuggerProperties is TGDBMIServerDebuggerProperties) then
    begin
      vProps := TGDBMIServerDebuggerProperties(vConfig.DebuggerProperties);
      vProps.Debugger_Remote_Hostname := '127.0.0.1';
      vProps.Debugger_Remote_Port := IntToStr(APort);
      vProps.Architecture := AArchitecture;
      vProps.RemoteTimeout := 15;
      vProps.SkipSettingLocalExeName := True;
      vProps.InternalStartBreak := gdbsNone;
      vProps.InternalExceptionBreakPoints := [];
      vProps.WarnOnSetBreakpointError := gdbwNone;
      vProps.WarnOnInternalError := TGDBMIDebuggerShowWarning.False;

      vProps.EventProperties.AfterInit.Clear;
      vProps.EventProperties.AfterInit.Add('set confirm off');
      vProps.EventProperties.AfterInit.Add('set sysroot');
      vProps.EventProperties.AfterInit.Add('set auto-solib-add off');

      vProps.EventProperties.AfterConnect.Clear;
      vProps.EventProperties.AfterConnect.Add('file');
      if (ATextAddrHex <> '') and (ATextAddrHex <> '0x0') then
        vProps.EventProperties.AfterConnect.Add('add-symbol-file "' + ModuleFile + '" ' + ATextAddrHex);
      vProps.EventProperties.AfterConnect.Add('handle SIGSEGV nostop noprint pass');
      vProps.EventProperties.AfterConnect.Add('handle SIGBUS nostop noprint pass');
      vProps.EventProperties.AfterConnect.Add('handle SIG35 nostop noprint pass');
      vProps.EventProperties.AfterConnect.Add('handle SIG36 nostop noprint pass');
    end;

    vList.CurrentDebuggerPropertiesConfig := vConfig;
  end;

  DbgProjectLink.DebuggerBackend := '';
  DbgProjectLink.MarkDebuggerClassConfAsModified;

  // 4. Configura também no DebuggerOptions (global da IDE)
  if Assigned(DebuggerOptions.DebuggerPropertiesConfigList) then
  begin
    vConfig := DebuggerOptions.DebuggerPropertiesConfigList.EntryByName('LazDroid GDBServer', TGDBMIServerDebugger.ClassName);
    if not Assigned(vConfig) then
    begin
      vConfig := TDebuggerPropertiesConfig.CreateForDebuggerClass(TGDBMIServerDebugger, True);
      vConfig.ConfigName := 'LazDroid GDBServer';
    end;
    vConfig.Active := True;
    vConfig.DebuggerFilename := GdbExe;

    if Assigned(vConfig.DebuggerProperties) and (vConfig.DebuggerProperties is TGDBMIServerDebuggerProperties) then
    begin
      vProps := TGDBMIServerDebuggerProperties(vConfig.DebuggerProperties);
      vProps.Debugger_Remote_Hostname := '127.0.0.1';
      vProps.Debugger_Remote_Port := IntToStr(APort);
      vProps.Architecture := AArchitecture;
      vProps.RemoteTimeout := 15;
      vProps.SkipSettingLocalExeName := True;
      vProps.InternalStartBreak := gdbsNone;
      vProps.InternalExceptionBreakPoints := [];
      vProps.WarnOnSetBreakpointError := gdbwNone;
      vProps.WarnOnInternalError := TGDBMIDebuggerShowWarning.False;

      vProps.EventProperties.AfterInit.Clear;
      vProps.EventProperties.AfterInit.Add('set confirm off');
      vProps.EventProperties.AfterInit.Add('set sysroot');
      vProps.EventProperties.AfterInit.Add('set auto-solib-add off');

      vProps.EventProperties.AfterConnect.Clear;
      vProps.EventProperties.AfterConnect.Add('file');
      if (ATextAddrHex <> '') and (ATextAddrHex <> '0x0') then
        vProps.EventProperties.AfterConnect.Add('add-symbol-file "' + ModuleFile + '" ' + ATextAddrHex);
      vProps.EventProperties.AfterConnect.Add('handle SIGSEGV nostop noprint pass');
      vProps.EventProperties.AfterConnect.Add('handle SIGBUS nostop noprint pass');
      vProps.EventProperties.AfterConnect.Add('handle SIG35 nostop noprint pass');
      vProps.EventProperties.AfterConnect.Add('handle SIG36 nostop noprint pass');
    end;

    DebuggerOptions.CurrentDebuggerPropertiesConfig := vConfig;
    DebuggerOptions.SaveDebuggerPropertiesList;
  end;
end;

procedure HandleDebugReady(Sender: TObject; const ANDKRoot, ALocalModule, ASerial, APackage: string; APort: Integer);
var
  Arch: string;
  TextAddrHex: string;
begin
  LogToLazarusMessages('>>> [LAZDROID-DEBUG] Calibrando depurador nativo GDBServer no Lazarus IDE...', luSuccess);

  if Pos('arm64', LowerCase(ALocalModule)) > 0 then
    Arch := 'aarch64'
  else
    Arch := 'arm';

  // Obtém o endereço real de carregamento em memória da biblioteca .so no Android
  TextAddrHex := QueryLibLazAppTextAddress(DroidConfig.AdbPath, ASerial, APackage, ALocalModule);
  if TextAddrHex <> '' then
    LogToLazarusMessages('>>> [LAZDROID-DEBUG] Símbolos de ' + ExtractFileName(ALocalModule) + ' realocados em memória no endereço: ' + TextAddrHex, luSuccess)
  else
    LogToLazarusMessages('AVISO: Endereço de memória de ' + ExtractFileName(ALocalModule) + ' não detectado. Depuração usando mapa padrão.', luWarning);

  ConfigureGdbServerDebugger(ANDKRoot, ALocalModule, APort, Arch, TextAddrHex);

  // Inicializa o depurador
  if not DebugBoss.InitDebugger then
  begin
    LogToLazarusMessages('ERRO: Falha ao inicializar o depurador GDBServer do Lazarus.', luError);
    Exit;
  end;

  LazarusIDE.ToolStatus := itDebugger;
  DebugBoss.UpdateButtonsAndMenuItems;

  LogToLazarusMessages('>>> [LAZDROID-DEBUG] Depurador GDB engatado! Conectando e enviando Continue...', luSuccess);
  DebugBoss.RunDebugger;
end;

procedure EnsurePipeline;
begin
  if not Assigned(GlobalPipeline) then
  begin
    GlobalPipeline := TLazDroidPipeline.Create(DroidConfig);
    GlobalPipeline.OnDebugReady := @HandleDebugReady;
  end;
end;

procedure DoConfigureProject(Sender: TObject);
begin
  if Assigned(LazarusIDE.ActiveProject) then
  begin
    ConfigureProjectAndroidCustomDrawn(LazarusIDE.ActiveProject);
    ShowMessage('Projeto configurado com sucesso para Android (aarch64 / LCL CustomDrawn)!' + LineEnding +
                'A macro LCLWidgetType foi definida para "customdrawn".');
  end
  else
    ShowMessage('Nenhum projeto ativo no momento para configurar.');
end;

procedure DoDeployAndRun(Sender: TObject);
var
  TargetDevice: TAndroidDevice;
  HasTarget: Boolean;
begin
  EnsurePipeline;

  // Garante que o projeto ativo esteja calibrado com LCLWidgetType=customdrawn
  if Assigned(LazarusIDE.ActiveProject) then
    ConfigureProjectAndroidCustomDrawn(LazarusIDE.ActiveProject);

  if GlobalPipeline.IsRunning then
  begin
    if MessageDlg('LazDroid-Deploy',
      'O pipeline de deploy Android já está em execução.' + LineEnding +
      'Deseja cancelar o processo atual?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      GlobalPipeline.Cancel;
    end;
    Exit;
  end;

  // 1. Tenta obter o dispositivo ativo selecionado na janela Target (estilo Delphi)
  HasTarget := GetActiveTargetDevice(TargetDevice);

  // 2. Se não achou na janela aberta, tenta consultar o serial salvo no DroidConfig
  if not HasTarget and (DroidConfig.TargetDeviceSerial <> '') then
  begin
    TargetDevice.Serial := DroidConfig.TargetDeviceSerial;
    if DroidConfig.AdbPath <> '' then
    begin
      with TLazDroidDeviceManager.Create(DroidConfig.AdbPath) do
      try
        if IsDeviceConnected(TargetDevice.Serial) then
        begin
          TargetDevice.PrimaryAbi := QueryDeviceAbi(TargetDevice.Serial);
          TargetDevice.AndroidVersion := QueryAndroidVersion(TargetDevice.Serial);
          TargetDevice.IsReady := True;
          HasTarget := True;
        end;
      finally
        Free;
      end;
    end;
  end;

  // 3. Se ainda não há dispositivo alvo selecionado, exibe diálogo
  if not HasTarget then
  begin
    if not ShowSelectDeviceDialog(TargetDevice) then
      Exit; // Usuário cancelou ou nenhum aparelho pronto
  end;

  // Dispara esteira de compilação, empacotamento e deploy
  GlobalPipeline.Start(TargetDevice.Serial, False);
end;

procedure DoDeployAndDebug(Sender: TObject);
var
  TargetDevice: TAndroidDevice;
  HasTarget: Boolean;
begin
  EnsurePipeline;

  // Garante que o projeto ativo esteja calibrado com LCLWidgetType=customdrawn
  if Assigned(LazarusIDE.ActiveProject) then
    ConfigureProjectAndroidCustomDrawn(LazarusIDE.ActiveProject);

  if GlobalPipeline.IsRunning then
  begin
    if MessageDlg('LazDroid-Deploy',
      'O pipeline de deploy Android já está em execução.' + LineEnding +
      'Deseja cancelar o processo atual?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      GlobalPipeline.Cancel;
    end;
    Exit;
  end;

  HasTarget := GetActiveTargetDevice(TargetDevice);
  if not HasTarget and (DroidConfig.TargetDeviceSerial <> '') then
  begin
    TargetDevice.Serial := DroidConfig.TargetDeviceSerial;
    if DroidConfig.AdbPath <> '' then
    begin
      with TLazDroidDeviceManager.Create(DroidConfig.AdbPath) do
      try
        if IsDeviceConnected(TargetDevice.Serial) then
        begin
          TargetDevice.PrimaryAbi := QueryDeviceAbi(TargetDevice.Serial);
          TargetDevice.AndroidVersion := QueryAndroidVersion(TargetDevice.Serial);
          TargetDevice.IsReady := True;
          HasTarget := True;
        end;
      finally
        Free;
      end;
    end;
  end;

  if not HasTarget then
  begin
    if not ShowSelectDeviceDialog(TargetDevice) then
      Exit;
  end;

  // Dispara esteira em modo depuração GDB Remote
  GlobalPipeline.Start(TargetDevice.Serial, True);
end;

procedure DoCancelDeploy(Sender: TObject);
begin
  if Assigned(GlobalPipeline) and GlobalPipeline.IsRunning then
  begin
    GlobalPipeline.Cancel;
    LogToLazarusMessages('Cancelamento manual do pipeline acionado pelo usuário.', luWarning);
  end
  else
  begin
    ShowMessage('Nenhum pipeline LazDroid em execução no momento.');
  end;
end;

procedure Register;
var
  CmdCategory: TIDECommandCategory;
  RunSection: TIDEMenuSection;
  ShortcutDeploy, ShortcutDebug, ShortcutCancel: TIDEShortCut;
begin
  // 1. Registrar Project Descriptor (Template de Novo Projeto Android na IDE)
  RegisterProjectTemplate;

  // 2. Registrar Categoria de Comandos no IDECommands
  CmdCategory := IDECommandList.CreateCategory(nil, 'LazDroid', 'LazDroid Android Automation');

  ShortcutDeploy := IDEShortCut(VK_F9, [ssCtrl, ssShift]);
  ShortcutDebug  := IDEShortCut(VK_F9, [ssCtrl]);
  ShortcutCancel := IDEShortCut(VK_CANCEL, [ssCtrl, ssShift]);

  // 3. Registrar Comandos IDE com Atalhos
  CmdDeployAndRun := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidDeployAndRun',
    'Deploy & Run on Android Device',
    ShortcutDeploy,
    nil,
    @DoDeployAndRun
  );

  CmdDeployAndDebug := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidDeployAndDebug',
    'Deploy & Debug on Android Device (GDB Remote)',
    ShortcutDebug,
    nil,
    @DoDeployAndDebug
  );

  CmdCancelDeploy := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidCancelDeploy',
    'Cancel Android Deployment',
    ShortcutCancel,
    nil,
    @DoCancelDeploy
  );

  CmdConfigureProject := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidConfigureProject',
    'Configurar Projeto Atual para Android (LCL CustomDrawn)',
    CleanIDEShortCut,
    nil,
    @DoConfigureProject
  );

  CmdViewTarget := RegisterIDECommand(
    CmdCategory,
    'ecLazDroidViewTarget',
    'Dispositivos Alvo Android (Target)',
    CleanIDEShortCut,
    nil,
    @ShowLazDroidTargetWindow
  );

  // 4. Registrar Janela Acoplável (Dockable Window estilo Delphi Target)
  LazDroidTargetDockCreator := IDEWindowCreators.Add(
    'TLazDroidTargetDockForm',
    @CreateLazDroidTargetWindow, nil,
    '700', '150', '1060', '650'
  );

  // Registrar item no menu Exibir (View)
  RegisterIDEMenuCommand(
    itmViewMainWindows,
    'itmLazDroidViewTarget',
    'Dispositivos Alvo Android (Target)',
    nil,
    @ShowLazDroidTargetWindow,
    CmdViewTarget
  );

  // 4. Registrar Itens no Menu 'Run' (Executar) da IDE
  RunSection := itmRunBuilding;
  if RunSection = nil then
    RunSection := mnuRun;

  RegisterIDEMenuCommand(
    RunSection,
    'itmLazDroidConfigProject',
    'Configurar Projeto Atual para Android (LCL CustomDrawn)',
    nil,
    @DoConfigureProject,
    CmdConfigureProject
  );

  RegisterIDEMenuCommand(
    RunSection,
    'itmLazDroidDeployRun',
    'Deploy & Run on Android Device (USB)',
    nil,
    @DoDeployAndRun,
    CmdDeployAndRun
  );

  RegisterIDEMenuCommand(
    RunSection,
    'itmLazDroidDeployDebug',
    'Deploy & Debug on Android Device (GDB Remote)',
    nil,
    @DoDeployAndDebug,
    CmdDeployAndDebug
  );

  RegisterIDEMenuCommand(
    RunSection,
    'itmLazDroidCancel',
    'Cancelar Deploy Android',
    nil,
    @DoCancelDeploy,
    CmdCancelDeploy
  );

  RegisterIDEMenuCommand(
    RunSection,
    'itmLazDroidTargetManager',
    'Dispositivos Alvo Android (Target)...',
    nil,
    @ShowLazDroidTargetWindow,
    CmdViewTarget
  );

  // 5. Registrar Página nas Opções da IDE (Tools -> Options -> Environment)
  DroidOptionsIndex := RegisterIDEOptionsEditor(
    GroupEnvironment,
    TLazDroidOptionsFrame,
    DroidOptionsIndex
  )^.Index;

  // 6. Instalar Barra Rápida no Editor de Código
  InstallLazDroidEditorBar;
  if Assigned(LazDroidEditorBarInstance) then
  begin
    LazDroidEditorBarInstance.OnDeploy := @DoDeployAndRun;
    LazDroidEditorBarInstance.OnDebug  := @DoDeployAndDebug;
    LazDroidEditorBarInstance.OnLogcat := @DoOpenLogcat;
  end;
end;

procedure DoOpenLogcat(Sender: TObject);
var
  Serial: string;
  Dev: TAndroidDevice;
begin
  Serial := DroidConfig.TargetDeviceSerial;
  if (Serial = '') and GetActiveTargetDevice(Dev) then
    Serial := Dev.Serial;

  if Serial <> '' then
  begin
    with TLazDroidDeviceManager.Create(DroidConfig.AdbPath) do
    try
      OpenLogcatConsole(Serial, DroidConfig.LogcatFilter);
    finally
      Free;
    end;
  end
  else
    ShowMessage('Nenhum dispositivo Android selecionado para abrir o Logcat.');
end;

initialization

finalization
  UninstallLazDroidEditorBar;
  if Assigned(GlobalPipeline) then
    FreeAndNil(GlobalPipeline);

end.
