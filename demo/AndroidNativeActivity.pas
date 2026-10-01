{
  LazDroid-Deploy Demo: Android Native Activity Bindings
  Unit: AndroidNativeActivity.pas
  Descrição: Bindings FPC completos para a API de NativeActivity e NativeWindow do Android NDK (libandroid.so).
}
unit AndroidNativeActivity;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const
  LIB_ANDROID = 'android';

  // Formatos de pixel para ANativeWindow
  WINDOW_FORMAT_RGBA_8888    = 1;
  WINDOW_FORMAT_RGBX_8888    = 2;
  WINDOW_FORMAT_RGB_565      = 4;

  // Window flags (Android WindowManager.LayoutParams)
  AWINDOW_FLAG_FULLSCREEN    = $00000400;
  AWINDOW_FLAG_KEEP_SCREEN_ON= $00000080;

type
  size_t = PtrUInt;
  Psize_t = ^size_t;

  { TARect: Retângulo retornado / passado nas operações de janela }
  TARect = record
    left: LongInt;
    top: LongInt;
    right: LongInt;
    bottom: LongInt;
  end;
  PARect = ^TARect;

  { Opaque ANativeWindow pointer }
  PANativeWindow = Pointer;
  PANativeActivity = ^TANativeActivity;

  { ANativeWindow_Buffer: descritor do buffer de vídeo mapeado }
  TANativeWindow_Buffer = record
    width: LongInt;
    height: LongInt;
    stride: LongInt;
    format: LongInt;
    bits: Pointer;
    reserved: array[0..5] of Cardinal;
  end;
  PANativeWindow_Buffer = ^TANativeWindow_Buffer;

  { Callbacks de ciclo de vida emitidos pelo Android para a NativeActivity }
  TANativeActivityCallbacks = record
    onStart: procedure(activity: PANativeActivity); cdecl;
    onResume: procedure(activity: PANativeActivity); cdecl;
    onSaveInstanceState: function(activity: PANativeActivity; outLen: Psize_t): Pointer; cdecl;
    onPause: procedure(activity: PANativeActivity); cdecl;
    onStop: procedure(activity: PANativeActivity); cdecl;
    onDestroy: procedure(activity: PANativeActivity); cdecl;
    onWindowFocusChanged: procedure(activity: PANativeActivity; hasFocus: Integer); cdecl;
    onNativeWindowCreated: procedure(activity: PANativeActivity; window: PANativeWindow); cdecl;
    onNativeWindowResized: procedure(activity: PANativeActivity; window: PANativeWindow); cdecl;
    onNativeWindowRedrawNeeded: procedure(activity: PANativeActivity; window: PANativeWindow); cdecl;
    onNativeWindowDestroyed: procedure(activity: PANativeActivity; window: PANativeWindow); cdecl;
    onInputQueueCreated: procedure(activity: PANativeActivity; queue: Pointer); cdecl;
    onInputQueueDestroyed: procedure(activity: PANativeActivity; queue: Pointer); cdecl;
    onContentRectChanged: procedure(activity: PANativeActivity; const rect: PARect); cdecl;
    onConfigurationChanged: procedure(activity: PANativeActivity); cdecl;
    onLowMemory: procedure(activity: PANativeActivity); cdecl;
  end;
  PANativeActivityCallbacks = ^TANativeActivityCallbacks;

  { Estrutura principal da ANativeActivity fornecida na inicialização }
  TANativeActivity = record
    callbacks: PANativeActivityCallbacks;
    vm: Pointer;
    env: Pointer;
    clazz: Pointer;
    internalDataPath: PChar;
    externalDataPath: PChar;
    sdkVersion: Integer;
    instance: Pointer;
    assetManager: Pointer;
    obbPath: PChar;
  end;

{ Declarações de funções externas da biblioteca nativa libandroid.so }

function ANativeWindow_setBuffersGeometry(window: PANativeWindow;
  width, height, format: LongInt): LongInt; cdecl;
  external LIB_ANDROID name 'ANativeWindow_setBuffersGeometry';

function ANativeWindow_lock(window: PANativeWindow;
  outBuffer: PANativeWindow_Buffer; inOutDirtyBounds: PARect): LongInt; cdecl;
  external LIB_ANDROID name 'ANativeWindow_lock';

function ANativeWindow_unlockAndPost(window: PANativeWindow): LongInt; cdecl;
  external LIB_ANDROID name 'ANativeWindow_unlockAndPost';

procedure ANativeActivity_finish(activity: PANativeActivity); cdecl;
  external LIB_ANDROID name 'ANativeActivity_finish';

procedure ANativeActivity_setWindowFlags(activity: PANativeActivity;
  addFlags, removeFlags: Cardinal); cdecl;
  external LIB_ANDROID name 'ANativeActivity_setWindowFlags';

const
  // Tipos de Eventos de Entrada
  AINPUT_EVENT_TYPE_KEY    = 1;
  AINPUT_EVENT_TYPE_MOTION = 2;

  // Ações de Toque (Motion)
  AMOTION_EVENT_ACTION_MASK         = $ff;
  AMOTION_EVENT_ACTION_DOWN         = 0;
  AMOTION_EVENT_ACTION_UP           = 1;
  AMOTION_EVENT_ACTION_MOVE         = 2;
  AMOTION_EVENT_ACTION_CANCEL       = 3;
  AMOTION_EVENT_ACTION_POINTER_DOWN = 5;
  AMOTION_EVENT_ACTION_POINTER_UP   = 6;

type
  PAInputQueue = Pointer;
  PAInputEvent = Pointer;
  PPAInputEvent = ^PAInputEvent;

function AInputQueue_hasEvents(queue: PAInputQueue): LongInt; cdecl;
  external LIB_ANDROID name 'AInputQueue_hasEvents';

function AInputQueue_getEvent(queue: PAInputQueue; outEvent: PPAInputEvent): LongInt; cdecl;
  external LIB_ANDROID name 'AInputQueue_getEvent';

function AInputQueue_preDispatchEvent(queue: PAInputQueue; event: PAInputEvent): LongInt; cdecl;
  external LIB_ANDROID name 'AInputQueue_preDispatchEvent';

procedure AInputQueue_finishEvent(queue: PAInputQueue; event: PAInputEvent; handled: LongInt); cdecl;
  external LIB_ANDROID name 'AInputQueue_finishEvent';

function AInputEvent_getType(event: PAInputEvent): LongInt; cdecl;
  external LIB_ANDROID name 'AInputEvent_getType';

function AMotionEvent_getAction(event: PAInputEvent): LongInt; cdecl;
  external LIB_ANDROID name 'AMotionEvent_getAction';

function AMotionEvent_getX(event: PAInputEvent; pointer_index: size_t): Single; cdecl;
  external LIB_ANDROID name 'AMotionEvent_getX';

function AMotionEvent_getY(event: PAInputEvent; pointer_index: size_t): Single; cdecl;
  external LIB_ANDROID name 'AMotionEvent_getY';

implementation

end.
