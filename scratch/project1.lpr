{$IFDEF ANDROID}
library project1;
{$ELSE}
program project1;
{$ENDIF}

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF ANDROID}
  customdrawnint,
  customdrawn_android,
  customdrawndrawers,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, Unit1, Unit2, Unit3, Unit4;

{$IFDEF ANDROID}
exports
  JNI_OnLoad name 'JNI_OnLoad',
  JNI_OnUnload name 'JNI_OnUnload';

procedure MyActivityOnCreate;
begin
  DefaultStyle := dsAndroid;
  Application.Initialize;
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  if Assigned(Form1) then
  begin
    Form1.WindowState := wsMaximized;
    Form1.Show;
  end;
  Application.Run;
end;
{$ENDIF}

{$R *.res}

begin
  {$IFDEF ANDROID}
  CDWidgetset.ActivityClassName := 'com/pascal/lclproject/LCLActivity';
  CDWidgetset.ActivityOnCreate := @MyActivityOnCreate;
  {$ELSE}
  RequireDerivedFormResource := True;
  Application.Scaled := True;
  {$PUSH}{$WARN 5044 OFF}
  Application.MainFormOnTaskbar := True;
  {$POP}
  Application.Initialize;
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.Run;
  {$ENDIF}
end.
