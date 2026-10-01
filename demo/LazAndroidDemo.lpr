{
  LazDroid-Deploy: Aplicação LCL CustomDrawn Real para Android
  Arquivo: LazAndroidDemo.lpr
  Descrição: Aplicação nativa com Forms Visuais LCL reais (TForm, TButton, TEdit, TLabel)
             integrada ao LCL CustomDrawn WidgetSet e SQLite (vendas.db).
}
library LazAndroidDemo;

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
  FormLogin,
  FormVendas,
  SalesDatabase,
  SalesData;

exports
  JNI_OnLoad name 'JNI_OnLoad',
  JNI_OnUnload name 'JNI_OnUnload';

procedure MyActivityOnCreate;
begin
  DefaultStyle := dsAndroid;
  Application.Initialize;
  Application.CreateForm(TFormVendas, frmVendas);
  Application.CreateForm(TFormLogin, frmLogin);
  if Assigned(frmVendas) then
    frmVendas.Show;
  if Assigned(frmLogin) then
  begin
    frmLogin.Show;
    frmLogin.BringToFront;
  end;
  Application.Run;
end;

begin
  CDWidgetset.ActivityClassName := 'com/pascal/lclproject/LCLActivity';
  CDWidgetset.ActivityOnCreate := @MyActivityOnCreate;
end.
