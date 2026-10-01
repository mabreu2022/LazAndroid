{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidProjectDescriptor.pas
  Descrição: Project Descriptor que registra o template "Aplicação Android (LazDroid)"
             no menu Arquivo -> Novo... e Projeto -> Novo Projeto...
}
unit LazDroidProjectDescriptor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, FileUtil,
  // Lazarus IDE Open Tools API
  ProjectIntf, CompOptsIntf, LazIDEIntf, IDEOptionsIntf,
  // Lazarus IdeConfig & IdeProject
  Project, ModeMatrixOpts,
  // LazDroid
  LazDroidConfig;

type
  { TLazDroidProjectDescriptor }

  TLazDroidProjectDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

procedure ConfigureProjectAndroidCustomDrawn(AProject: TLazProject);
procedure RegisterProjectTemplate;

implementation

const
  PROJ_DESC_NAME_ANDROID = 'LazDroidAndroidApp';

{ TLazDroidProjectDescriptor }

constructor TLazDroidProjectDescriptor.Create;
begin
  inherited Create;
  Name := PROJ_DESC_NAME_ANDROID;
  Flags := Flags - [pfMainUnitHasCreateFormStatements, pfMainUnitHasTitleStatement, pfMainUnitHasScaledStatement]
                 + [pfMainUnitHasUsesSectionForAllUnits, pfMainUnitIsPascalSource, pfRunnable];
end;

function TLazDroidProjectDescriptor.GetLocalizedName: string;
begin
  Result := 'Aplicação Android (LazDroid)';
end;

function TLazDroidProjectDescriptor.GetLocalizedDescription: string;
begin
  Result := 'Cria um novo aplicativo nativo para Android com LCL CustomDrawn, biblioteca JNI, ' +
            'exportação JNI_OnLoad, inicialização de Activity e formulário visual prontos para compilação e deploy direto no dispositivo.';
end;

procedure ConfigureProjectAndroidCustomDrawn(AProject: TLazProject);
var
  Proj: TProject;
  MatrixOpt: TBuildMatrixOption;
  i: Integer;
  ModeName: string;
begin
  if not Assigned(AProject) then Exit;

  // 1. Configura a macro LCLWidgetType := customdrawn no BuildModes do Projeto
  // Isto instrui o Lazarus a compilar/vincular a LCL com o widgetset CustomDrawn
  // em vez do GTK2 padrão de Unix, eliminando o erro de gtk2cellrenderer.
  if AProject is TProject then
  begin
    Proj := TProject(AProject);
    MatrixOpt := Proj.BuildModes.SharedMatrixOptions.FindMacro('LCLWidgetType', 'customdrawn');
    if MatrixOpt = nil then
    begin
      MatrixOpt := Proj.BuildModes.SharedMatrixOptions.Add(bmotIDEMacro, '*');
      MatrixOpt.MacroName := 'LCLWidgetType';
      MatrixOpt.Value := 'customdrawn';
    end;

    // Habilita para todos os modos de build do projeto (Default, Debug, Release, etc.)
    if Proj.BuildModes.Count > 0 then
    begin
      for i := 0 to Proj.BuildModes.Count - 1 do
      begin
        ModeName := Proj.BuildModes.BuildModes[i].Identifier;
        MatrixOpt.EnableMode(ModeName);
      end;
    end
    else
      MatrixOpt.EnableMode('default');

    Proj.BuildModes.SharedMatrixOptions.IncreaseChangeStep;
  end;

  // 2. Configurações do compilador FPC para Cross-Compilação Android ARM64
  AProject.LazCompilerOptions.TargetOS := 'android';
  AProject.LazCompilerOptions.TargetCPU := 'aarch64';
  AProject.LazCompilerOptions.ExecutableType := cetLibrary;
  AProject.LazCompilerOptions.RelocatableUnit := True;

  // Habilita símbolos de depuração DWARF 2 e lineinfo para stack traces nítidos
  AProject.LazCompilerOptions.GenerateDebugInfo := True;
  AProject.LazCompilerOptions.DebugInfoType := dsDwarf2Set;
  AProject.LazCompilerOptions.UseLineInfoUnit := True;

  // Caminhos de Units e Diretórios de saída
  AProject.LazCompilerOptions.UnitOutputDirectory := 'lib' + PathDelim + '$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.CustomOptions := '-dLCL -dLCLcustomdrawn';
  AProject.LazCompilerOptions.OtherUnitFiles :=
    '$(LazarusDir)\lcl\units\$(TargetCPU)-$(TargetOS)\customdrawn;' +
    '$(LazarusDir)\lcl\units\$(TargetCPU)-$(TargetOS);' +
    '$(LazarusDir)\components\lazutils\lib\$(TargetCPU)-$(TargetOS);' +
    '$(LazarusDir)\components\freetype\lib\$(TargetCPU)-$(TargetOS);' +
    '$(LazarusDir)\packager\units\$(TargetCPU)-$(TargetOS)';

  // Destino do binário .so
  if (DroidConfig.ScaffoldDirectory <> '') and DirectoryExists(DroidConfig.ScaffoldDirectory) then
    AProject.LazCompilerOptions.TargetFilename := IncludeTrailingPathDelimiter(DroidConfig.ScaffoldDirectory) +
      'app' + PathDelim + 'src' + PathDelim + 'main' + PathDelim + 'jniLibs' + PathDelim + 'arm64-v8a' + PathDelim + 'liblazapp.so'
  else
    AProject.LazCompilerOptions.TargetFilename := '..\scaffold\app\src\main\jniLibs\arm64-v8a\liblazapp.so';

  // 3. Notifica a IDE que o TargetOS e LCLWidgetType mudaram para sincronizar o CodeTools e BuildManager
  LazarusIDE.PrepareBuildTarget(True);
end;

function TLazDroidProjectDescriptor.InitProject(AProject: TLazProject): TModalResult;
var
  NewSource: string;
  MainFile: TLazProjectFile;
begin
  Result := inherited InitProject(AProject);

  MainFile := AProject.CreateProjectFile('project1.lpr');
  MainFile.IsPartOfProject := True;
  AProject.AddFile(MainFile, False);
  AProject.MainFileID := 0;
  AProject.UseAppBundle := False;
  AProject.Scaled := True;

  // Código inicial do .lpr pronto para Android JNI
  NewSource :=
    'library project1;' + LineEnding +
    LineEnding +
    '{$mode objfpc}{$H+}' + LineEnding +
    LineEnding +
    'uses' + LineEnding +
    '  {$IFDEF UNIX}' + LineEnding +
    '  cthreads,' + LineEnding +
    '  {$ENDIF}' + LineEnding +
    '  customdrawnint,' + LineEnding +
    '  Interfaces,' + LineEnding +
    '  Forms,' + LineEnding +
    '  customdrawn_android,' + LineEnding +
    '  customdrawndrawers,' + LineEnding +
    '  Unit1;' + LineEnding +
    LineEnding +
    'exports' + LineEnding +
    '  JNI_OnLoad name ''JNI_OnLoad'',' + LineEnding +
    '  JNI_OnUnload name ''JNI_OnUnload'';' + LineEnding +
    LineEnding +
    'procedure MyActivityOnCreate;' + LineEnding +
    'begin' + LineEnding +
    '  DefaultStyle := dsAndroid;' + LineEnding +
    '  Application.Initialize;' + LineEnding +
    '  Application.CreateForm(TForm1, Form1);' + LineEnding +
    '  if Assigned(Form1) then' + LineEnding +
    '  begin' + LineEnding +
    '    Form1.WindowState := wsMaximized;' + LineEnding +
    '    Form1.Show;' + LineEnding +
    '  end;' + LineEnding +
    '  Application.Run;' + LineEnding +
    'end;' + LineEnding +
    LineEnding +
    'begin' + LineEnding +
    '  CDWidgetset.ActivityClassName := ''com/pascal/lclproject/LCLActivity'';' + LineEnding +
    '  CDWidgetset.ActivityOnCreate := @MyActivityOnCreate;' + LineEnding +
    'end.' + LineEnding;

  AProject.MainFile.SetSourceText(NewSource, True);

  // Vincula a dependência da LCL e dos componentes mobile LazDroid
  AProject.AddPackageDependency('LCL');
  AProject.AddPackageDependency('LazDroidControls');

  // Configura todas as opções de compilador, widgetset CustomDrawn e build target
  ConfigureProjectAndroidCustomDrawn(AProject);
end;

function TLazDroidProjectDescriptor.CreateStartFiles(AProject: TLazProject): TModalResult;
begin
  // Cria automaticamente Unit1.pas com Form1: TForm1 e abre no Form Designer
  Result := LazarusIDE.DoNewEditorFile(FileDescriptorForm, '', '',
                         [nfIsPartOfProject, nfOpenInEditor, nfCreateDefaultSrc]);
end;

procedure EnsureFpcAarch64Aliases;
var
  FpcBinDir: string;
begin
  FpcBinDir := 'C:\lazarus\fpc\3.2.2\bin\i386-win32\';
  if DirectoryExists(FpcBinDir) then
  begin
    if FileExists(FpcBinDir + 'ppcrossa64.exe') and not FileExists(FpcBinDir + 'ppcrossaarch64.exe') then
      CopyFile(FpcBinDir + 'ppcrossa64.exe', FpcBinDir + 'ppcrossaarch64.exe', False);
    if FileExists(FpcBinDir + 'ppca64.exe') and not FileExists(FpcBinDir + 'ppcaarch64.exe') then
      CopyFile(FpcBinDir + 'ppca64.exe', FpcBinDir + 'ppcaarch64.exe', False);
  end;
end;

procedure RegisterProjectTemplate;
begin
  EnsureFpcAarch64Aliases;
  RegisterProjectDescriptor(TLazDroidProjectDescriptor.Create);
end;

end.
