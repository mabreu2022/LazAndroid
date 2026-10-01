library project1;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  customdrawnint,
  Interfaces,
  Forms,
  customdrawn_android,
  customdrawndrawers,
  Unit1;

exports
  JNI_OnLoad name 'JNI_OnLoad',
  JNI_OnUnload name 'JNI_OnUnload';

procedure MyActivityOnCreate;
begin
  DefaultStyle := dsAndroid;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  if Assigned(Form1) then
  begin
    Form1.WindowState := wsMaximized;
    Form1.Show;
  end;
  Application.Run;
end;

begin
  CDWidgetset.ActivityClassName := 'com/pascal/lclproject/LCLActivity';
  CDWidgetset.ActivityOnCreate := @MyActivityOnCreate;
end.
