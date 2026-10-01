{
  LazDroid Mobile Showcase: Demonstração da Paleta de Componentes Mobile LazDroid
  Arquivo: demo4.lpr
}
library demo4;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  SysUtils,
  customdrawnint,
  Interfaces,
  Forms,
  customdrawn_android,
  customdrawndrawers,
  LazDroidMobileControls,
  Unit1;

exports
  JNI_OnLoad name 'JNI_OnLoad',
  JNI_OnUnload name 'JNI_OnUnload';

function __android_log_write(prio: Integer; tag: PChar; text: PChar): Integer; cdecl; external 'liblog.so' name '__android_log_write';

procedure MyActivityOnCreate;
begin
  __android_log_write(4, 'lclapp', 'MyActivityOnCreate demo4: Iniciando demonstrativo LazDroid Mobile...');
  try
    DefaultStyle := dsAndroid;
    Application.Initialize;
    Application.CreateForm(TForm1, Form1);
    if Assigned(Form1) then
      Form1.Show;
    Application.Run;
    __android_log_write(4, 'lclapp', 'MyActivityOnCreate demo4: Concluido com sucesso');
  except
    on E: Exception do
    begin
      __android_log_write(6, 'lclapp', PChar('ERRO em MyActivityOnCreate demo4: [' + E.ClassName + '] ' + E.Message));
    end;
  end;
end;

begin
  CDWidgetset.ActivityClassName := 'com/pascal/lclproject/LCLActivity';
  CDWidgetset.ActivityOnCreate := @MyActivityOnCreate;
end.
