{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
}

unit LazDroidControls;

{$warn 5023 off : no warning about unused units}
interface

uses
  LazDroidMobileControls, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('LazDroidMobileControls', @LazDroidMobileControls.Register);
end;

initialization
  RegisterPackage('LazDroidControls', @Register);
end.
