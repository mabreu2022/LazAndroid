{
  LazDroid-Deploy Demo: Android Logging Unit
  Unit: AndroidLog.pas
  Descrição: Wrapper para a API nativa de logcat do Android (liblog.so).
}
unit AndroidLog;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  android_LogPriority = (
    ANDROID_LOG_UNKNOWN = 0,
    ANDROID_LOG_DEFAULT = 1,
    ANDROID_LOG_VERBOSE = 2,
    ANDROID_LOG_DEBUG   = 3,
    ANDROID_LOG_INFO    = 4,
    ANDROID_LOG_WARN    = 5,
    ANDROID_LOG_ERROR   = 6,
    ANDROID_LOG_FATAL   = 7,
    ANDROID_LOG_SILENT  = 8
  );

const
  LIB_LOG = 'log';
  DEFAULT_LOG_TAG = 'LazApp';

{ Importação da função C nativa do NDK }
function __android_log_print(prio: Integer; tag, fmt: PChar): Integer; cdecl;
  varargs; external LIB_LOG name '__android_log_print';

{ Utilitários de alto nível }
procedure LogVerbose(const AText: string; const ATag: string = DEFAULT_LOG_TAG);
procedure LogDebug(const AText: string; const ATag: string = DEFAULT_LOG_TAG);
procedure LogInfo(const AText: string; const ATag: string = DEFAULT_LOG_TAG);
procedure LogWarn(const AText: string; const ATag: string = DEFAULT_LOG_TAG);
procedure LogError(const AText: string; const ATag: string = DEFAULT_LOG_TAG);

implementation

procedure LogVerbose(const AText: string; const ATag: string);
begin
  __android_log_print(Ord(ANDROID_LOG_VERBOSE), PChar(ATag), PChar('%s'), PChar(AText));
end;

procedure LogDebug(const AText: string; const ATag: string);
begin
  __android_log_print(Ord(ANDROID_LOG_DEBUG), PChar(ATag), PChar('%s'), PChar(AText));
end;

procedure LogInfo(const AText: string; const ATag: string);
begin
  __android_log_print(Ord(ANDROID_LOG_INFO), PChar(ATag), PChar('%s'), PChar(AText));
end;

procedure LogWarn(const AText: string; const ATag: string);
begin
  __android_log_print(Ord(ANDROID_LOG_WARN), PChar(ATag), PChar('%s'), PChar(AText));
end;

procedure LogError(const AText: string; const ATag: string);
begin
  __android_log_print(Ord(ANDROID_LOG_ERROR), PChar(ATag), PChar('%s'), PChar(AText));
end;

end.
