{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit LazDroidDeploy;

{$warn 5023 off : no warning about unused units}
interface

uses
  LazDroidDeploy_Reg, LazDroidConfig, LazDroidConfigFrame, 
  LazDroidDeviceManager, LazDroidDeviceSelectDlg, LazDroidProcessRunner, 
  LazDroidPipeline, LazDroidProjectDescriptor, LazDroidTargetDockWin, 
  LazDroidEditorBar, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('LazDroidDeploy_Reg', @LazDroidDeploy_Reg.Register);
end;

initialization
  RegisterPackage('LazDroidDeploy', @Register);
end.
