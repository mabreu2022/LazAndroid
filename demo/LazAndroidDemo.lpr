{
  LazDroid-Deploy Demo Application
  Arquivo: LazAndroidDemo.lpr
  Descrição: Biblioteca nativa Android em Object Pascal (Free Pascal) exportando
             o ponto de entrada ANativeActivity_onCreate com renderização de tela e logcat.
}
library LazAndroidDemo;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils,
  AndroidLog,
  AndroidNativeActivity;

type
  { TAppState: Mantém o estado da aplicação enquanto a Activity estiver ativa }
  PAppState = ^TAppState;
  TAppState = record
    Activity: PANativeActivity;
    Window: PANativeWindow;
    RenderFrameCount: Cardinal;
  end;

{ Renderiza um quadro visual moderno direto no Surface da tela (RGBA_8888) }
procedure RenderScreen(State: PAppState);
var
  Buffer: TANativeWindow_Buffer;
  Res: LongInt;
  X, Y: Integer;
  Pixels: PDWord;
  RowPtr: PDWord;
  Color: Cardinal;
  R, G, B: Byte;
  CenterBoxX, CenterBoxY: Integer;
  BoxHalfW, BoxHalfH: Integer;
begin
  if (State = nil) or (State^.Window = nil) then Exit;

  // Ajusta geometria para formato nativo de 32-bit (RGBA_8888)
  ANativeWindow_setBuffersGeometry(State^.Window, 0, 0, WINDOW_FORMAT_RGBA_8888);

  Res := ANativeWindow_lock(State^.Window, @Buffer, nil);
  if Res < 0 then
  begin
    LogError(Format('Falha ao travar o buffer de vídeo nativo (código %d)', [Res]));
    Exit;
  end;

  try
    Inc(State^.RenderFrameCount);
    Pixels := PDWord(Buffer.bits);

    CenterBoxX := Buffer.width div 2;
    CenterBoxY := Buffer.height div 2;
    BoxHalfW   := Buffer.width div 3;
    BoxHalfH   := Buffer.height div 6;

    // Pintar fundo com gradiente vertical escuro (estética premium slate/cyberpunk)
    for Y := 0 to Buffer.height - 1 do
    begin
      RowPtr := Pixels + (Y * Buffer.stride);

      // Gradiente suave de fundo de #0B0F19 para #1E293B
      R := Round(11 + (19 * (Y / Buffer.height)));
      G := Round(15 + (26 * (Y / Buffer.height)));
      B := Round(25 + (34 * (Y / Buffer.height)));

      for X := 0 to Buffer.width - 1 do
      begin
        // Se estiver dentro da caixa central de status (Banner LazDroid)
        if (X >= CenterBoxX - BoxHalfW) and (X <= CenterBoxX + BoxHalfW) and
           (Y >= CenterBoxY - BoxHalfH) and (Y <= CenterBoxY + BoxHalfH) then
        begin
          // Borda ciano brilhante (#06B6D4) ou fundo do card (#0F172A)
          if (X = CenterBoxX - BoxHalfW) or (X = CenterBoxX + BoxHalfW) or
             (Y = CenterBoxY - BoxHalfH) or (Y = CenterBoxY + BoxHalfH) then
            Color := $FFD4B606  // Borda Ciano AABBGGRR
          else
            Color := $FF332314; // Fundo Azul-Petróleo do Card
        end
        else
        begin
          // Cor do gradiente base
          Color := ($FF shl 24) or (Cardinal(B) shl 16) or (Cardinal(G) shl 8) or Cardinal(R);
        end;

        RowPtr[X] := Color;
      end;
    end;

    LogInfo(Format('Quadro renderizado com sucesso #%d (%dx%d, Stride: %d)',
      [State^.RenderFrameCount, Buffer.width, Buffer.height, Buffer.stride]));

  finally
    ANativeWindow_unlockAndPost(State^.Window);
  end;
end;

{ Callbacks do Ciclo de Vida do Android }

procedure OnStart(activity: PANativeActivity); cdecl;
begin
  LogInfo('>>> [Lifecycle] onStart disparado pelo Android.');
end;

procedure OnResume(activity: PANativeActivity); cdecl;
var
  State: PAppState;
begin
  LogInfo('>>> [Lifecycle] onResume: aplicação em primeiro plano.');
  State := PAppState(activity^.instance);
  if Assigned(State) and Assigned(State^.Window) then
    RenderScreen(State);
end;

procedure OnPause(activity: PANativeActivity); cdecl;
begin
  LogInfo('>>> [Lifecycle] onPause: aplicação pausada.');
end;

procedure OnStop(activity: PANativeActivity); cdecl;
begin
  LogInfo('>>> [Lifecycle] onStop: aplicação em segundo plano.');
end;

procedure OnDestroy(activity: PANativeActivity); cdecl;
var
  State: PAppState;
begin
  LogInfo('>>> [Lifecycle] onDestroy: liberando recursos da NativeActivity.');
  State := PAppState(activity^.instance);
  if Assigned(State) then
    Dispose(State);
  activity^.instance := nil;
end;

procedure OnNativeWindowCreated(activity: PANativeActivity; window: PANativeWindow); cdecl;
var
  State: PAppState;
begin
  LogInfo('>>> [Window] onNativeWindowCreated: Superfície de exibição disponível!');
  State := PAppState(activity^.instance);
  if Assigned(State) then
  begin
    State^.Window := window;
    RenderScreen(State);
  end;
end;

procedure OnNativeWindowDestroyed(activity: PANativeActivity; window: PANativeWindow); cdecl;
var
  State: PAppState;
begin
  LogInfo('>>> [Window] onNativeWindowDestroyed: Superfície destruída.');
  State := PAppState(activity^.instance);
  if Assigned(State) then
    State^.Window := nil;
end;

procedure OnNativeWindowRedrawNeeded(activity: PANativeActivity; window: PANativeWindow); cdecl;
var
  State: PAppState;
begin
  LogInfo('>>> [Window] onNativeWindowRedrawNeeded: Atualização de tela requerida.');
  State := PAppState(activity^.instance);
  if Assigned(State) then
  begin
    State^.Window := window;
    RenderScreen(State);
  end;
end;

{ Ponto de entrada nativo do Android NDK }
procedure ANativeActivity_onCreate(activity: PANativeActivity;
  savedState: Pointer; savedStateSize: size_t); cdecl;
var
  State: PAppState;
begin
  LogInfo('========================================================');
  LogInfo('  LAZDROID-DEPLOY DEMO: ANativeActivity_onCreate INICIADO');
  LogInfo('  Compilado com Free Pascal (FPC) para Android Nativo   ');
  LogInfo('========================================================');

  // Habilita tela cheia e impede desligamento de tela durante o teste
  ANativeActivity_setWindowFlags(activity,
    AWINDOW_FLAG_FULLSCREEN or AWINDOW_FLAG_KEEP_SCREEN_ON, 0);

  // Instancia estado do app
  New(State);
  State^.Activity := activity;
  State^.Window := nil;
  State^.RenderFrameCount := 0;
  activity^.instance := State;

  // Conecta callbacks de ciclo de vida
  activity^.callbacks^.onStart                    := @OnStart;
  activity^.callbacks^.onResume                   := @OnResume;
  activity^.callbacks^.onPause                    := @OnPause;
  activity^.callbacks^.onStop                     := @OnStop;
  activity^.callbacks^.onDestroy                  := @OnDestroy;
  activity^.callbacks^.onNativeWindowCreated      := @OnNativeWindowCreated;
  activity^.callbacks^.onNativeWindowDestroyed    := @OnNativeWindowDestroyed;
  activity^.callbacks^.onNativeWindowRedrawNeeded := @OnNativeWindowRedrawNeeded;

  LogInfo('Callbacks da NativeActivity registrados com sucesso.');
end;

exports
  ANativeActivity_onCreate;

begin
end.
