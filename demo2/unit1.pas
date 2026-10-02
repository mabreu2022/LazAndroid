unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, LazDroidMobileControls;

type

  { TForm1 }

  TForm1 = class(TForm)
    LazDroidAppBar1: TLazDroidAppBar;
    LazDroidButton1: TLazDroidButton;
    LazDroidSwitch1: TLazDroidSwitch;
    LazDroidActivityIndicator1: TLazDroidActivityIndicator;
    LazDroidFAB1: TLazDroidFAB;
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

end.

