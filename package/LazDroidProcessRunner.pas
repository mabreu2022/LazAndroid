{
  LazDroid-Deploy: Open Tools Package para Lazarus IDE
  Unit: LazDroidProcessRunner.pas
  Descrição: Executor de processos CLI assíncrono em Thread com redirecionamento de logs para o IDEMsgIntf.
}
unit LazDroidProcessRunner;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Process, IDEMsgIntf, IDEExternToolIntf;

type
  { TLazDroidLogUrgency }
  TLazDroidLogUrgency = (luInfo, luSuccess, luWarning, luError, luLogcat);

  TOnProcessLog = procedure(const AText: string; AUrgency: TLazDroidLogUrgency) of object;
  TOnProcessFinished = procedure(AExitCode: Integer; const AErrorMsg: string) of object;

  { TLazDroidProcessThread }
  TLazDroidProcessThread = class(TThread)
  private
    FExecutable: string;
    FParameters: TStringList;
    FWorkingDirectory: string;
    FEnvironment: TStringList;
    FProcess: TProcess;
    FExitCode: Integer;
    FErrorMsg: string;
    FOnLog: TOnProcessLog;
    FOnFinished: TOnProcessFinished;
    FCancelRequested: Boolean;

    FCurLogText: string;
    FCurLogUrgency: TLazDroidLogUrgency;

    procedure DoLog;
    procedure DoFinished;
    procedure SendLog(const AText: string; AUrgency: TLazDroidLogUrgency);
    procedure ProcessBuffer(const ABuffer: string);
  protected
    procedure Execute; override;
  public
    constructor Create(const AExecutable: string; AParameters: TStrings;
      const AWorkingDir: string = ''; AEnv: TStrings = nil);
    destructor Destroy; override;

    procedure RequestCancel;

    property OnLog: TOnProcessLog read FOnLog write FOnLog;
    property OnFinished: TOnProcessFinished read FOnFinished write FOnFinished;
    property ExitCode: Integer read FExitCode;
  end;

  { Utilitário para despachar mensagens direto para o Lazarus IDEMessagesWindow }
  procedure LogToLazarusMessages(const AText: string; AUrgency: TLazDroidLogUrgency;
    const AFileName: string = ''; ALine: Integer = 0; ACol: Integer = 0);

implementation

procedure LogToLazarusMessages(const AText: string; AUrgency: TLazDroidLogUrgency;
  const AFileName: string; ALine: Integer; ACol: Integer);
var
  LazarusUrgency: TMessageLineUrgency;
begin
  case AUrgency of
    luSuccess: LazarusUrgency := mluImportant;
    luWarning: LazarusUrgency := mluWarning;
    luError:   LazarusUrgency := mluError;
    luLogcat:  LazarusUrgency := mluNote;
  else
    LazarusUrgency := mluNone;
  end;

  if Assigned(IDEMessagesWindow) then
  begin
    IDEMessagesWindow.AddCustomMessage(
      LazarusUrgency,
      AText,
      AFileName,
      ALine,
      ACol,
      'LazDroid'
    );
  end;
end;

{ TLazDroidProcessThread }

constructor TLazDroidProcessThread.Create(const AExecutable: string;
  AParameters: TStrings; const AWorkingDir: string; AEnv: TStrings);
begin
  inherited Create(True); // Create suspended
  FreeOnTerminate := False;
  FExecutable := AExecutable;
  FWorkingDirectory := AWorkingDir;
  FCancelRequested := False;
  FExitCode := -1;
  FErrorMsg := '';

  FParameters := TStringList.Create;
  if Assigned(AParameters) then
    FParameters.Assign(AParameters);

  FEnvironment := TStringList.Create;
  if Assigned(AEnv) then
    FEnvironment.Assign(AEnv);
end;

destructor TLazDroidProcessThread.Destroy;
begin
  RequestCancel;
  FParameters.Free;
  FEnvironment.Free;
  inherited Destroy;
end;

procedure TLazDroidProcessThread.RequestCancel;
begin
  FCancelRequested := True;
  if Assigned(FProcess) and FProcess.Running then
  begin
    try
      FProcess.Terminate(1);
    except
      // Processo pode já ter encerrado
    end;
  end;
end;

procedure TLazDroidProcessThread.DoLog;
begin
  if Assigned(FOnLog) then
    FOnLog(FCurLogText, FCurLogUrgency);
  LogToLazarusMessages(FCurLogText, FCurLogUrgency);
end;

procedure TLazDroidProcessThread.DoFinished;
begin
  if Assigned(FOnFinished) then
    FOnFinished(FExitCode, FErrorMsg);
end;

procedure TLazDroidProcessThread.SendLog(const AText: string; AUrgency: TLazDroidLogUrgency);
begin
  FCurLogText := AText;
  FCurLogUrgency := AUrgency;
  Synchronize(@DoLog);
end;

procedure TLazDroidProcessThread.ProcessBuffer(const ABuffer: string);
var
  Lines: TStringList;
  I: Integer;
  Line: string;
  Urgency: TLazDroidLogUrgency;
begin
  if Trim(ABuffer) = '' then Exit;

  Lines := TStringList.Create;
  try
    Lines.Text := ABuffer;
    for I := 0 to Lines.Count - 1 do
    begin
      Line := Lines[I];
      if Trim(Line) = '' then Continue;

      // Dedução de urgência por palavras-chave
      if (Pos('Error:', Line) > 0) or (Pos('FAILURE:', Line) > 0) or (Pos('Fatal:', Line) > 0) then
        Urgency := luError
      else if (Pos('Warning:', Line) > 0) or (Pos('WARN', Line) > 0) then
        Urgency := luWarning
      else if (Pos('BUILD SUCCESSFUL', Line) > 0) or (Pos('Success', Line) > 0) then
        Urgency := luSuccess
      else
        Urgency := luInfo;

      SendLog(Line, Urgency);
    end;
  finally
    Lines.Free;
  end;
end;

procedure TLazDroidProcessThread.Execute;
var
  Buffer: array[0..4095] of Byte;
  BytesRead: LongInt;
  PartialStr: string;
  ChunkStr: string;
  NewLinePos: Integer;
  I: Integer;
begin
  FProcess := TProcess.Create(nil);
  try
    FProcess.Executable := FExecutable;
    FProcess.Parameters.Assign(FParameters);
    if FWorkingDirectory <> '' then
      FProcess.CurrentDirectory := FWorkingDirectory;

    if FEnvironment.Count > 0 then
    begin
      for I := 0 to FEnvironment.Count - 1 do
        FProcess.Environment.Add(FEnvironment[I]);
    end;

    FProcess.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
    FProcess.ShowWindow := swoNone;

    try
      FProcess.Execute;
    except
      on E: Exception do
      begin
        FErrorMsg := 'Falha ao iniciar processo (' + FExecutable + '): ' + E.Message;
        FExitCode := -1;
        SendLog(FErrorMsg, luError);
        Synchronize(@DoFinished);
        Exit;
      end;
    end;

    PartialStr := '';

    while (not FCancelRequested) and (FProcess.Running or (FProcess.Output.NumBytesAvailable > 0)) do
    begin
      if FProcess.Output.NumBytesAvailable > 0 then
      begin
        BytesRead := FProcess.Output.Read(Buffer[0], SizeOf(Buffer));
        if BytesRead > 0 then
        begin
          SetString(ChunkStr, PChar(@Buffer[0]), BytesRead);
          PartialStr := PartialStr + ChunkStr;

          // Processar linhas completas
          repeat
            NewLinePos := Pos(#10, PartialStr);
            if NewLinePos > 0 then
            begin
              ProcessBuffer(Copy(PartialStr, 1, NewLinePos - 1));
              Delete(PartialStr, 1, NewLinePos);
            end;
          until NewLinePos = 0;
        end;
      end
      else
      begin
        Sleep(20);
      end;
    end;

    // Resíduos no buffer final
    if PartialStr <> '' then
      ProcessBuffer(PartialStr);

    if FCancelRequested then
    begin
      FExitCode := -99;
      FErrorMsg := 'Operação cancelada pelo usuário.';
      SendLog('=== PROCESSO INTERROMPIDO PELO USUÁRIO ===', luWarning);
    end
    else
    begin
      FExitCode := FProcess.ExitCode;
    end;

  finally
    FreeAndNil(FProcess);
    Synchronize(@DoFinished);
  end;
end;

end.
