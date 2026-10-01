{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidDeviceManager.pas
  Descrição: Detecção, enumeração e inspeção de dispositivos Android via ADB sobre USB.
}
unit LazDroidDeviceManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, LazDroidConfig;

type
  { TAndroidDevice }
  TAndroidDevice = record
    Serial: string;
    State: string;         // 'device', 'offline', 'unauthorized', 'no permissions'
    Model: string;
    Product: string;
    DeviceCode: string;
    TransportId: string;
    PrimaryAbi: string;
    AndroidVersion: string;
    IsReady: Boolean;
  end;

  TAndroidDeviceArray = array of TAndroidDevice;

  { TLazDroidDeviceManager }
  TLazDroidDeviceManager = class
  private
    FAdbPath: string;
    procedure ParseDeviceLine(const ALine: string; out ADev: TAndroidDevice);
  public
    constructor Create(const AAdbPath: string);
    function RunCommandSync(const ACommand: string; const AArgs: array of string; out AOutput: string): Integer;
    function EnumerateDevices: TAndroidDeviceArray;
    function QueryDeviceAbi(const ASerial: string): string;
    function QueryAndroidVersion(const ASerial: string): string;
    function IsDeviceConnected(const ASerial: string): Boolean;
    function GetFirstReadyDevice(out ADev: TAndroidDevice): Boolean;
    function FormatDeviceDescription(const ADev: TAndroidDevice): string;
    function IsPackageInstalled(const ASerial, APackageName: string): Boolean;
  end;

implementation

{ TLazDroidDeviceManager }

constructor TLazDroidDeviceManager.Create(const AAdbPath: string);
begin
  inherited Create;
  FAdbPath := AAdbPath;
  if FAdbPath = '' then
    FAdbPath := 'adb.exe';
end;

function TLazDroidDeviceManager.RunCommandSync(const ACommand: string;
  const AArgs: array of string; out AOutput: string): Integer;
var
  Proc: TProcess;
  Buffer: array[0..4095] of Byte;
  BytesRead: LongInt;
  StrStream: TStringStream;
  I: Integer;
begin
  AOutput := '';
  Proc := TProcess.Create(nil);
  StrStream := TStringStream.Create('');
  try
    Proc.Executable := ACommand;
    for I := Low(AArgs) to High(AArgs) do
      Proc.Parameters.Add(AArgs[I]);

    Proc.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
    Proc.ShowWindow := swoNone;

    try
      Proc.Execute;
    except
      on E: Exception do
      begin
        AOutput := 'Erro ao executar ' + ACommand + ': ' + E.Message;
        Exit(-1);
      end;
    end;

    while Proc.Running or (Proc.Output.NumBytesAvailable > 0) do
    begin
      BytesRead := Proc.Output.Read(Buffer[0], SizeOf(Buffer));
      if BytesRead > 0 then
        StrStream.WriteBuffer(Buffer[0], BytesRead)
      else
        Sleep(10);
    end;

    Result := Proc.ExitCode;
    AOutput := StrStream.DataString;
  finally
    StrStream.Free;
    Proc.Free;
  end;
end;

procedure TLazDroidDeviceManager.ParseDeviceLine(const ALine: string; out ADev: TAndroidDevice);
var
  Tokens: TStringList;
  I: Integer;
  Token, Key, Val: string;
  SepPos: Integer;
begin
  ADev.Serial := '';
  ADev.State := 'unknown';
  ADev.Model := '';
  ADev.Product := '';
  ADev.DeviceCode := '';
  ADev.TransportId := '';
  ADev.PrimaryAbi := '';
  ADev.AndroidVersion := '';
  ADev.IsReady := False;

  Tokens := TStringList.Create;
  try
    Tokens.Delimiter := ' ';
    Tokens.StrictDelimiter := False;
    Tokens.DelimitedText := ALine;

    if Tokens.Count >= 2 then
    begin
      ADev.Serial := Tokens[0];
      ADev.State  := Tokens[1];
      ADev.IsReady := (ADev.State = 'device');

      for I := 2 to Tokens.Count - 1 do
      begin
        Token := Tokens[I];
        SepPos := Pos(':', Token);
        if SepPos > 0 then
        begin
          Key := Copy(Token, 1, SepPos - 1);
          Val := Copy(Token, SepPos + 1, Length(Token));

          if Key = 'model' then ADev.Model := StringReplace(Val, '_', ' ', [rfReplaceAll])
          else if Key = 'product' then ADev.Product := Val
          else if Key = 'device' then ADev.DeviceCode := Val
          else if Key = 'transport_id' then ADev.TransportId := Val;
        end;
      end;

      if ADev.Model = '' then
        ADev.Model := ADev.DeviceCode;
      if ADev.Model = '' then
        ADev.Model := 'Dispositivo Android (' + ADev.Serial + ')';
    end;
  finally
    Tokens.Free;
  end;
end;

function TLazDroidDeviceManager.EnumerateDevices: TAndroidDeviceArray;
var
  RawOutput: string;
  ExitCode: Integer;
  Lines: TStringList;
  I, Count: Integer;
  Line: string;
  Dev: TAndroidDevice;
begin
  Result := nil;
  SetLength(Result, 0);
  ExitCode := RunCommandSync(FAdbPath, ['devices', '-l'], RawOutput);
  if ExitCode <> 0 then
    Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := RawOutput;
    Count := 0;

    for I := 0 to Lines.Count - 1 do
    begin
      Line := Trim(Lines[I]);
      if (Line = '') or (Pos('List of devices attached', Line) > 0) or
         (Pos('* daemon', Line) > 0) then
        Continue;

      ParseDeviceLine(Line, Dev);
      if Dev.Serial <> '' then
      begin
        Inc(Count);
        SetLength(Result, Count);
        Result[Count - 1] := Dev;
      end;
    end;
  finally
    Lines.Free;
  end;
end;

function TLazDroidDeviceManager.QueryDeviceAbi(const ASerial: string): string;
var
  Output: string;
begin
  Result := 'arm64-v8a'; // Padrão seguro moderno
  if RunCommandSync(FAdbPath, ['-s', ASerial, 'shell', 'getprop', 'ro.product.cpu.abi'], Output) = 0 then
  begin
    Output := Trim(Output);
    if Output <> '' then
      Result := Output;
  end;
end;

function TLazDroidDeviceManager.QueryAndroidVersion(const ASerial: string): string;
var
  Output: string;
begin
  Result := 'Android';
  if RunCommandSync(FAdbPath, ['-s', ASerial, 'shell', 'getprop', 'ro.build.version.release'], Output) = 0 then
  begin
    Output := Trim(Output);
    if Output <> '' then
      Result := 'Android ' + Output;
  end;
end;

function TLazDroidDeviceManager.IsDeviceConnected(const ASerial: string): Boolean;
var
  List: TAndroidDeviceArray;
  I: Integer;
begin
  Result := False;
  List := EnumerateDevices;
  for I := Low(List) to High(List) do
  begin
    if (List[I].Serial = ASerial) and List[I].IsReady then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TLazDroidDeviceManager.GetFirstReadyDevice(out ADev: TAndroidDevice): Boolean;
var
  List: TAndroidDeviceArray;
  I: Integer;
begin
  Result := False;
  List := EnumerateDevices;
  for I := Low(List) to High(List) do
  begin
    if List[I].IsReady then
    begin
      ADev := List[I];
      ADev.PrimaryAbi := QueryDeviceAbi(ADev.Serial);
      ADev.AndroidVersion := QueryAndroidVersion(ADev.Serial);
      Result := True;
      Exit;
    end;
  end;
end;

function TLazDroidDeviceManager.FormatDeviceDescription(const ADev: TAndroidDevice): string;
begin
  Result := Format('%s (%s) [%s] - %s', [ADev.Model, ADev.Serial, ADev.PrimaryAbi, ADev.State]);
end;

function TLazDroidDeviceManager.IsPackageInstalled(const ASerial, APackageName: string): Boolean;
var
  OutStr: string;
  Code: Integer;
begin
  Result := False;
  if (ASerial = '') or (APackageName = '') then Exit;

  // 1. Tenta pm list packages com --user 0 (compatível com Samsung Knox / Dual App / Secure Folder)
  Code := RunCommandSync(FAdbPath, ['-s', ASerial, 'shell', 'pm', 'list', 'packages', '--user', '0', APackageName], OutStr);
  if (Code = 0) and (Pos('package:' + APackageName, OutStr) > 0) then
    Exit(True);

  // 2. Fallback pm list packages padrão (caso o dispositivo não suporte ou não necessite de --user 0)
  Code := RunCommandSync(FAdbPath, ['-s', ASerial, 'shell', 'pm', 'list', 'packages', APackageName], OutStr);
  if (Code = 0) and (Pos('package:' + APackageName, OutStr) > 0) then
    Exit(True);

  // 3. Fallback pm path
  Code := RunCommandSync(FAdbPath, ['-s', ASerial, 'shell', 'pm', 'path', '--user', '0', APackageName], OutStr);
  if (Code = 0) and (Pos('package:', OutStr) > 0) then
    Exit(True);

  Code := RunCommandSync(FAdbPath, ['-s', ASerial, 'shell', 'pm', 'path', APackageName], OutStr);
  if (Code = 0) and (Pos('package:', OutStr) > 0) then
    Exit(True);
end;

end.
