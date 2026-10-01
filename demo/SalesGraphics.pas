{
  LazDroid-Deploy: Módulo Gráfico & Renderizador de Fontes e Ícones Proporcionais
  Unit: SalesGraphics.pas
  Descrição: Motor gráfico de alta fidelidade para ANativeWindow_Buffer do Android.
             Renderiza cards modernos com sombras e cantos arredondados verdadeiros,
             fontes proporcionais com espaçamento dinâmico, paleta de cores corporativa Stitch,
             e ícones vetoriais nítidos em resoluções de alta densidade (FHD+/480dpi).
}
unit SalesGraphics;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, AndroidNativeActivity;

const
  // Paleta de Cores VendaForce Mobile (Stitch Design System - Formato RGBA little-endian)
  COLOR_BG_CANVAS         = $FFFFF8FA; // #FAF8FF Fundo Canvas corporativo suave
  COLOR_BG_CARD           = $FFFFFFFF; // #FFFFFF Card branco puro
  COLOR_SURFACE_LOW       = $FFFFF3F2; // #F2F3FF Superfície suave de input/cards
  COLOR_SURFACE_HIGH      = $FFFFE7E2; // #E2E7FF Superfície destacada
  COLOR_CARD_BORDER       = $FFFDE2DA; // #DAE2FD Borda sutil de card
  COLOR_BORDER_LIGHT      = $FFE0E6F0; // Borda neutra leve
  COLOR_PRIMARY_CORP      = $FF5F3500; // #00355F Azul Marinho Corporativo Principal
  COLOR_PRIMARY_CONTAINER = $FF814C0F; // #0F4C81 Azul Marinho Intenso (Container)
  COLOR_PRIMARY_LIGHT     = $FFFFE4D2; // #D2E4FF Azul suave de seleção
  COLOR_SECONDARY_GREEN   = $FF4A6C00; // #006C4A Verde Esmeralda VendaForce
  COLOR_SECONDARY_FIX     = $FFC4F885; // #85F8C4 Verde claro status pill
  COLOR_SECONDARY_BG      = $FFE0FBEA; // Fundo verde clarinho
  COLOR_TEXT_DARK         = $FF2E1B13; // #131B2E Texto escuro principal de alto contraste
  COLOR_TEXT_SUB          = $FF4F4742; // #42474F Texto secundário
  COLOR_TEXT_MUTED_LIGHT  = $FF807772; // #727780 Texto sutil de legendas
  COLOR_WHITE             = $FFFFFFFF; // Branco puro
  COLOR_AMBER             = $FF0677D9; // #D97706 Alerta / atenção
  COLOR_ERROR_RED         = $FF1A1ABA; // #BA1A1A Vermelho corporativo
  COLOR_ERROR_LIGHT       = $FFD6DAFF; // #FFDAD6 Fundo vermelho claro
  COLOR_DIVIDER           = $FFE0E4EE; // Divisor suave

type
  { TRectArea: Retângulo para detecção de toques }
  TRectArea = record
    X1, Y1, X2, Y2: Integer;
    ActionId: Integer;
    ParamId: Integer;
  end;

  { TClickRegistry: Gerenciador de áreas clicáveis na tela }
  TClickRegistry = class
  private
    FAreas: array of TRectArea;
    FCount: Integer;
  public
    constructor Create;
    procedure Clear;
    procedure RegisterArea(AX1, AY1, AX2, AY2: Integer; AActionId: Integer; AParamId: Integer = 0);
    function FindHit(AX, AY: Integer; out AActionId, AParamId: Integer): Boolean;
  end;

{ Variáveis Globais de Dimensionamento Responsivo }
var
  GScreenWidth: Integer = 1080;
  GScreenHeight: Integer = 2400;
  GDpiScale: Double = 3.0;

{ Funções de Escala DPI Responsiva }
procedure InitScreenMetrics(W, H: Integer);
function DP(Val: Integer): Integer;
function SP(ScaleVal: Integer): Integer;

{ Funções Gráficas Primitivas }
function ColorRGBA(R, G, B, A: Byte): Cardinal;
function BlendPixel(Bg, Fg: Cardinal; Alpha: Byte): Cardinal;
procedure ClearBuffer(var Buffer: TANativeWindow_Buffer; Color: Cardinal);
procedure FillRect(var Buffer: TANativeWindow_Buffer; X, Y, W, H: Integer; Color: Cardinal);
procedure DrawRect(var Buffer: TANativeWindow_Buffer; X, Y, W, H, Thickness: Integer; Color: Cardinal);
procedure DrawHorizontalLine(var Buffer: TANativeWindow_Buffer; X, Y, W: Integer; Color: Cardinal);
procedure DrawVerticalLine(var Buffer: TANativeWindow_Buffer; X, Y, H: Integer; Color: Cardinal);

{ Cards com Cantos Arredondados e Sombra Suave }
procedure DrawSoftShadow(var Buffer: TANativeWindow_Buffer; X, Y, W, H, Radius, BlurOffset: Integer);
procedure DrawRoundedCard(var Buffer: TANativeWindow_Buffer; X, Y, W, H, Radius: Integer;
  FillColor, BorderColor: Cardinal; HasShadow: Boolean = True);
procedure DrawVerticalGradient(var Buffer: TANativeWindow_Buffer; X, Y, W, H: Integer;
  TopColor, BottomColor: Cardinal);
procedure DrawProgressBar(var Buffer: TANativeWindow_Buffer; X, Y, W, H, Radius: Integer;
  Percent: Double; BgColor, FillColor: Cardinal);

{ Funções de Texto e Fontes Proporcionais }
function CharWidth(Ch: Char): Integer;
function TextWidth(const AText: string; Scale: Integer): Integer;
function TextHeight(Scale: Integer): Integer;
procedure DrawChar(var Buffer: TANativeWindow_Buffer; X, Y: Integer; Ch: Char;
  Color: Cardinal; Scale: Integer);
procedure DrawText(var Buffer: TANativeWindow_Buffer; X, Y: Integer; const AText: string;
  Color: Cardinal; Scale: Integer);
procedure DrawTextCentered(var Buffer: TANativeWindow_Buffer; X, Y, W: Integer;
  const AText: string; Color: Cardinal; Scale: Integer);
procedure DrawTextRight(var Buffer: TANativeWindow_Buffer; RightX, Y: Integer;
  const AText: string; Color: Cardinal; Scale: Integer);
procedure DrawBadge(var Buffer: TANativeWindow_Buffer; X, Y: Integer; const AText: string;
  BgColor, TextColor: Cardinal; Scale: Integer; HasDot: Boolean = False; DotColor: Cardinal = 0);
procedure DrawButton(var Buffer: TANativeWindow_Buffer; X, Y, W, H: Integer;
  const ATitle: string; BgColor, TextColor: Cardinal; Scale: Integer; Radius: Integer = 0);

{ Ícones Vetoriais Nítidos (Baseados no Stitch Design System) }
procedure DrawIconBuilding(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconUser(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconLock(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconEye(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconCheck(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconArrowRight(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconFingerprint(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconSync(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconPhone(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconWhatsApp(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconCart(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconPin(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconShoppingBag(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconInsights(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawIconCloud(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
procedure DrawVendaForceLogo(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer);

implementation

{ Tabela de Caracteres Bitmap 8x8 ASCII }
const
  FONT_DATA: array[32..126, 0..7] of Byte = (
    ($00,$00,$00,$00,$00,$00,$00,$00), // Space
    ($18,$3C,$3C,$18,$18,$00,$18,$00), // !
    ($66,$66,$24,$00,$00,$00,$00,$00), // "
    ($6C,$6C,$FE,$6C,$FE,$6C,$6C,$00), // #
    ($18,$3E,$60,$3C,$06,$7C,$18,$00), // $
    ($00,$66,$6C,$18,$30,$66,$46,$00), // %
    ($38,$6C,$38,$76,$DC,$CC,$76,$00), // &
    ($18,$18,$30,$00,$00,$00,$00,$00), // '
    ($0C,$18,$30,$30,$30,$18,$0C,$00), // (
    ($30,$18,$0C,$0C,$0C,$18,$30,$00), // )
    ($00,$66,$3C,$FF,$3C,$66,$00,$00), // *
    ($00,$18,$18,$7E,$18,$18,$00,$00), // +
    ($00,$00,$00,$00,$00,$18,$18,$30), // ,
    ($00,$00,$00,$7E,$00,$00,$00,$00), // -
    ($00,$00,$00,$00,$00,$18,$18,$00), // .
    ($06,$0C,$18,$30,$60,$C0,$80,$00), // /
    ($3C,$66,$6E,$76,$66,$66,$3C,$00), // 0
    ($18,$38,$18,$18,$18,$18,$7E,$00), // 1
    ($3C,$66,$06,$0C,$18,$30,$7E,$00), // 2
    ($3C,$66,$06,$1C,$06,$66,$3C,$00), // 3
    ($0C,$1C,$3C,$6C,$FE,$0C,$0C,$00), // 4
    ($7E,$60,$7C,$06,$06,$66,$3C,$00), // 5
    ($1C,$30,$60,$7C,$66,$66,$3C,$00), // 6
    ($7E,$06,$0C,$18,$30,$30,$30,$00), // 7
    ($3C,$66,$66,$3C,$66,$66,$3C,$00), // 8
    ($3C,$66,$66,$3E,$06,$0C,$38,$00), // 9
    ($00,$18,$18,$00,$00,$18,$18,$00), // :
    ($00,$18,$18,$00,$00,$18,$18,$30), // ;
    ($0C,$18,$30,$60,$30,$18,$0C,$00), // <
    ($00,$00,$7E,$00,$7E,$00,$00,$00), // =
    ($30,$18,$0C,$06,$0C,$18,$30,$00), // >
    ($3C,$66,$06,$0C,$18,$00,$18,$00), // ?
    ($3C,$66,$6E,$6E,$60,$62,$3C,$00), // @
    ($18,$3C,$66,$66,$7E,$66,$66,$00), // A
    ($7C,$66,$66,$7C,$66,$66,$7C,$00), // B
    ($3C,$66,$60,$60,$60,$66,$3C,$00), // C
    ($78,$6C,$66,$66,$66,$6C,$78,$00), // D
    ($7E,$60,$60,$7C,$60,$60,$7E,$00), // E
    ($7E,$60,$60,$7C,$60,$60,$60,$00), // F
    ($3C,$66,$60,$6E,$66,$66,$3A,$00), // G
    ($66,$66,$66,$7E,$66,$66,$66,$00), // H
    ($3C,$18,$18,$18,$18,$18,$3C,$00), // I
    ($0E,$06,$06,$06,$06,$66,$3C,$00), // J
    ($66,$6C,$78,$70,$78,$6C,$66,$00), // K
    ($60,$60,$60,$60,$60,$60,$7E,$00), // L
    ($63,$77,$7F,$6B,$63,$63,$63,$00), // M
    ($66,$76,$7E,$7E,$6E,$66,$66,$00), // N
    ($3C,$66,$66,$66,$66,$66,$3C,$00), // O
    ($7C,$66,$66,$7C,$60,$60,$60,$00), // P
    ($3C,$66,$66,$66,$6E,$3C,$0E,$00), // Q
    ($7C,$66,$66,$7C,$78,$6C,$66,$00), // R
    ($3C,$66,$60,$3C,$06,$66,$3C,$00), // S
    ($7E,$18,$18,$18,$18,$18,$18,$00), // T
    ($66,$66,$66,$66,$66,$66,$3C,$00), // U
    ($66,$66,$66,$66,$66,$3C,$18,$00), // V
    ($63,$63,$63,$6B,$7F,$77,$63,$00), // W
    ($66,$66,$3C,$18,$3C,$66,$66,$00), // X
    ($66,$66,$66,$3C,$18,$18,$18,$00), // Y
    ($7E,$06,$0C,$18,$30,$60,$7E,$00), // Z
    ($3C,$30,$30,$30,$30,$30,$3C,$00), // [
    ($80,$C0,$60,$30,$18,$0C,$06,$00), // \
    ($3C,$0C,$0C,$0C,$0C,$0C,$3C,$00), // ]
    ($18,$3C,$66,$00,$00,$00,$00,$00), // ^
    ($00,$00,$00,$00,$00,$00,$FF,$00), // _
    ($30,$18,$0C,$00,$00,$00,$00,$00), // `
    ($00,$00,$3C,$06,$3E,$66,$3E,$00), // a
    ($60,$60,$7C,$66,$66,$66,$7C,$00), // b
    ($00,$00,$3C,$66,$60,$66,$3C,$00), // c
    ($06,$06,$3E,$66,$66,$66,$3E,$00), // d
    ($00,$00,$3C,$66,$7E,$60,$3C,$00), // e
    ($0E,$18,$7C,$18,$18,$18,$18,$00), // f
    ($00,$00,$3E,$66,$66,$3E,$06,$3C), // g
    ($60,$60,$7C,$66,$66,$66,$66,$00), // h
    ($18,$00,$38,$18,$18,$18,$3C,$00), // i
    ($06,$00,$0E,$06,$06,$66,$3C,$00), // j
    ($60,$60,$66,$6C,$78,$6C,$66,$00), // k
    ($38,$18,$18,$18,$18,$18,$3C,$00), // l
    ($00,$00,$66,$7F,$7F,$6B,$63,$00), // m
    ($00,$00,$7C,$66,$66,$66,$66,$00), // n
    ($00,$00,$3C,$66,$66,$66,$3C,$00), // o
    ($00,$00,$7C,$66,$66,$7C,$60,$60), // p
    ($00,$00,$3E,$66,$66,$3E,$06,$06), // q
    ($00,$00,$7C,$66,$60,$60,$60,$00), // r
    ($00,$00,$3E,$60,$3C,$06,$7C,$00), // s
    ($18,$18,$7E,$18,$18,$18,$0E,$00), // t
    ($00,$00,$66,$66,$66,$66,$3E,$00), // u
    ($00,$00,$66,$66,$66,$3C,$18,$00), // v
    ($00,$00,$63,$6B,$7F,$3E,$36,$00), // w
    ($00,$00,$66,$3C,$18,$3C,$66,$00), // x
    ($00,$00,$66,$66,$66,$3E,$06,$3C), // y
    ($00,$00,$7E,$0C,$18,$30,$7E,$00), // z
    ($0C,$18,$18,$30,$18,$18,$0C,$00), // {
    ($18,$18,$18,$00,$18,$18,$18,$00), // |
    ($30,$18,$18,$0C,$18,$18,$30,$00), // }
    ($00,$36,$5C,$00,$00,$00,$00,$00)  // ~
  );

{ TClickRegistry }

constructor TClickRegistry.Create;
begin
  inherited Create;
  SetLength(FAreas, 0);
  FCount := 0;
end;

procedure TClickRegistry.Clear;
begin
  FCount := 0;
end;

procedure TClickRegistry.RegisterArea(AX1, AY1, AX2, AY2: Integer; AActionId: Integer; AParamId: Integer);
begin
  if FCount >= Length(FAreas) then
    SetLength(FAreas, FCount + 16);

  FAreas[FCount].X1 := Min(AX1, AX2);
  FAreas[FCount].Y1 := Min(AY1, AY2);
  FAreas[FCount].X2 := Max(AX1, AX2);
  FAreas[FCount].Y2 := Max(AY1, AY2);
  FAreas[FCount].ActionId := AActionId;
  FAreas[FCount].ParamId := AParamId;
  Inc(FCount);
end;

function TClickRegistry.FindHit(AX, AY: Integer; out AActionId, AParamId: Integer): Boolean;
var
  I: Integer;
begin
  AActionId := 0;
  AParamId := 0;
  for I := FCount - 1 downto 0 do
  begin
    if (AX >= FAreas[I].X1) and (AX <= FAreas[I].X2) and
       (AY >= FAreas[I].Y1) and (AY <= FAreas[I].Y2) then
    begin
      AActionId := FAreas[I].ActionId;
      AParamId := FAreas[I].ParamId;
      Exit(True);
    end;
  end;
  Result := False;
end;

{ Funções de Escala DPI Responsiva }

procedure InitScreenMetrics(W, H: Integer);
begin
  GScreenWidth := W;
  GScreenHeight := H;
  if W > 0 then
    GDpiScale := W / 360.0
  else
    GDpiScale := 1.0;
  if GDpiScale < 1.0 then GDpiScale := 1.0;
end;

function DP(Val: Integer): Integer;
begin
  Result := Round(Val * GDpiScale);
end;

function SP(ScaleVal: Integer): Integer;
begin
  Result := Max(1, Round(ScaleVal * (GDpiScale / 3.0)));
end;

{ Funções Gráficas }

function ColorRGBA(R, G, B, A: Byte): Cardinal;
begin
  Result := (Cardinal(A) shl 24) or (Cardinal(B) shl 16) or (Cardinal(G) shl 8) or Cardinal(R);
end;

function BlendPixel(Bg, Fg: Cardinal; Alpha: Byte): Cardinal;
var
  InvAlpha: Byte;
  BgR, BgG, BgB: Byte;
  FgR, FgG, FgB: Byte;
  OutR, OutG, OutB: Byte;
begin
  if Alpha = 255 then Exit(Fg);
  if Alpha = 0 then Exit(Bg);

  InvAlpha := 255 - Alpha;
  BgR := Bg and $FF;
  BgG := (Bg shr 8) and $FF;
  BgB := (Bg shr 16) and $FF;

  FgR := Fg and $FF;
  FgG := (Fg shr 8) and $FF;
  FgB := (Fg shr 16) and $FF;

  OutR := (BgR * InvAlpha + FgR * Alpha) shr 8;
  OutG := (BgG * InvAlpha + FgG * Alpha) shr 8;
  OutB := (BgB * InvAlpha + FgB * Alpha) shr 8;

  Result := (Bg and $FF000000) or (Cardinal(OutB) shl 16) or (Cardinal(OutG) shl 8) or Cardinal(OutR);
end;

procedure ClearBuffer(var Buffer: TANativeWindow_Buffer; Color: Cardinal);
var
  Y, X: Integer;
  RowPtr: PDWord;
begin
  for Y := 0 to Buffer.height - 1 do
  begin
    RowPtr := PDWord(Buffer.bits) + (Y * Buffer.stride);
    for X := 0 to Buffer.width - 1 do
      RowPtr[X] := Color;
  end;
end;

procedure FillRect(var Buffer: TANativeWindow_Buffer; X, Y, W, H: Integer; Color: Cardinal);
var
  PX, PY: Integer;
  RowPtr: PDWord;
  StartX, EndX, StartY, EndY: Integer;
begin
  StartX := Max(0, X);
  StartY := Max(0, Y);
  EndX := Min(Buffer.width - 1, X + W - 1);
  EndY := Min(Buffer.height - 1, Y + H - 1);

  if (StartX > EndX) or (StartY > EndY) then Exit;

  for PY := StartY to EndY do
  begin
    RowPtr := PDWord(Buffer.bits) + (PY * Buffer.stride);
    for PX := StartX to EndX do
      RowPtr[PX] := Color;
  end;
end;

procedure DrawRect(var Buffer: TANativeWindow_Buffer; X, Y, W, H, Thickness: Integer; Color: Cardinal);
begin
  if Thickness <= 1 then
  begin
    FillRect(Buffer, X, Y, W, 1, Color);
    FillRect(Buffer, X, Y + H - 1, W, 1, Color);
    FillRect(Buffer, X, Y, 1, H, Color);
    FillRect(Buffer, X + W - 1, Y, 1, H, Color);
  end
  else
  begin
    FillRect(Buffer, X, Y, W, Thickness, Color);
    FillRect(Buffer, X, Y + H - Thickness, W, Thickness, Color);
    FillRect(Buffer, X, Y, Thickness, H, Color);
    FillRect(Buffer, X + W - Thickness, Y, Thickness, H, Color);
  end;
end;

procedure DrawHorizontalLine(var Buffer: TANativeWindow_Buffer; X, Y, W: Integer; Color: Cardinal);
begin
  FillRect(Buffer, X, Y, W, 1, Color);
end;

procedure DrawVerticalLine(var Buffer: TANativeWindow_Buffer; X, Y, H: Integer; Color: Cardinal);
begin
  FillRect(Buffer, X, Y, 1, H, Color);
end;

{ Cards com Cantos Arredondados e Sombra Suave }

procedure DrawSoftShadow(var Buffer: TANativeWindow_Buffer; X, Y, W, H, Radius, BlurOffset: Integer);
var
  Layer: Integer;
  ShadowColor: Cardinal;
  SX, SY, SW, SH, SRad: Integer;
begin
  // Desenhar 3 camadas de sombra suave translúcida sob o card
  for Layer := 1 to 3 do
  begin
    SX := X - (Layer * BlurOffset div 3);
    SY := Y + (Layer * BlurOffset div 2);
    SW := W + (Layer * BlurOffset * 2 div 3);
    SH := H + Layer;
    SRad := Radius + Layer;
    ShadowColor := ColorRGBA(18, 24, 40, 6 * Layer); // Sombra azul marinho suave

    // Desenha corpo da sombra
    FillRect(Buffer, SX + SRad, SY, SW - (2 * SRad), SH, ShadowColor);
    FillRect(Buffer, SX, SY + SRad, SW, SH - (2 * SRad), ShadowColor);
  end;
end;

procedure DrawRoundedCard(var Buffer: TANativeWindow_Buffer; X, Y, W, H, Radius: Integer;
  FillColor, BorderColor: Cardinal; HasShadow: Boolean);
var
  BorderThick: Integer;
  RowOffset: Integer;
  CornerSpan: Integer;
  DY: Integer;
  R2: Integer;
begin
  if HasShadow then
    DrawSoftShadow(Buffer, X, Y, W, H, Radius, DP(4));

  BorderThick := Max(1, DP(1));
  R2 := Radius * Radius;

  // Corpo central vertical e horizontal do card
  FillRect(Buffer, X + Radius, Y, W - (2 * Radius), H, FillColor);
  FillRect(Buffer, X, Y + Radius, Radius, H - (2 * Radius), FillColor);
  FillRect(Buffer, X + W - Radius, Y + Radius, Radius, H - (2 * Radius), FillColor);

  // Bordas retas
  FillRect(Buffer, X + Radius, Y, W - (2 * Radius), BorderThick, BorderColor); // Top
  FillRect(Buffer, X + Radius, Y + H - BorderThick, W - (2 * Radius), BorderThick, BorderColor); // Bottom
  FillRect(Buffer, X, Y + Radius, BorderThick, H - (2 * Radius), BorderColor); // Left
  FillRect(Buffer, X + W - BorderThick, Y + Radius, BorderThick, H - (2 * Radius), BorderColor); // Right

  // Cantos arredondados geométricos precisos
  for DY := 0 to Radius - 1 do
  begin
    // x = Radius - sqrt(R^2 - (Radius - DY)^2)
    CornerSpan := Radius - Round(Sqrt(Max(0, R2 - Sqr(Radius - DY))));

    // Canto Superior Esquerdo
    FillRect(Buffer, X + CornerSpan, Y + DY, Radius - CornerSpan, 1, FillColor);
    FillRect(Buffer, X + CornerSpan, Y + DY, BorderThick, 1, BorderColor);

    // Canto Superior Direito
    FillRect(Buffer, X + W - Radius, Y + DY, Radius - CornerSpan, 1, FillColor);
    FillRect(Buffer, X + W - CornerSpan - BorderThick, Y + DY, BorderThick, 1, BorderColor);

    // Canto Inferior Esquerdo
    RowOffset := H - 1 - DY;
    FillRect(Buffer, X + CornerSpan, Y + RowOffset, Radius - CornerSpan, 1, FillColor);
    FillRect(Buffer, X + CornerSpan, Y + RowOffset, BorderThick, 1, BorderColor);

    // Canto Inferior Direito
    FillRect(Buffer, X + W - Radius, Y + RowOffset, Radius - CornerSpan, 1, FillColor);
    FillRect(Buffer, X + W - CornerSpan - BorderThick, Y + RowOffset, BorderThick, 1, BorderColor);
  end;
end;

procedure DrawVerticalGradient(var Buffer: TANativeWindow_Buffer; X, Y, W, H: Integer;
  TopColor, BottomColor: Cardinal);
var
  PY, PX: Integer;
  RowPtr: PDWord;
  TR, TG, TB, TA: Byte;
  BR, BG, BB, BA: Byte;
  CR, CG, CB, CA: Byte;
  Factor: Double;
  Color: Cardinal;
  StartX, EndX, StartY, EndY: Integer;
begin
  StartX := Max(0, X);
  StartY := Max(0, Y);
  EndX := Min(Buffer.width - 1, X + W - 1);
  EndY := Min(Buffer.height - 1, Y + H - 1);

  if (StartX > EndX) or (StartY > EndY) or (H <= 0) then Exit;

  TR := TopColor and $FF;
  TG := (TopColor shr 8) and $FF;
  TB := (TopColor shr 16) and $FF;
  TA := (TopColor shr 24) and $FF;

  BR := BottomColor and $FF;
  BG := (BottomColor shr 8) and $FF;
  BB := (BottomColor shr 16) and $FF;
  BA := (BottomColor shr 24) and $FF;

  for PY := StartY to EndY do
  begin
    Factor := (PY - Y) / H;
    CR := Round(TR + Factor * (BR - TR));
    CG := Round(TG + Factor * (BG - TG));
    CB := Round(TB + Factor * (BB - TB));
    CA := Round(TA + Factor * (BA - TA));
    Color := (Cardinal(CA) shl 24) or (Cardinal(CB) shl 16) or (Cardinal(CG) shl 8) or Cardinal(CR);

    RowPtr := PDWord(Buffer.bits) + (PY * Buffer.stride);
    for PX := StartX to EndX do
      RowPtr[PX] := Color;
  end;
end;

procedure DrawProgressBar(var Buffer: TANativeWindow_Buffer; X, Y, W, H, Radius: Integer;
  Percent: Double; BgColor, FillColor: Cardinal);
var
  FillW: Integer;
begin
  // Fundo da barra com cantos arredondados
  DrawRoundedCard(Buffer, X, Y, W, H, Radius, BgColor, BgColor, False);

  if Percent > 100.0 then Percent := 100.0;
  if Percent < 0.0 then Percent := 0.0;
  FillW := Round((W * Percent) / 100.0);

  if FillW > (Radius * 2) then
    DrawRoundedCard(Buffer, X, Y, FillW, H, Radius, FillColor, FillColor, False)
  else if FillW > 0 then
    FillRect(Buffer, X, Y, FillW, H, FillColor);
end;

{ Funções de Texto e Fontes Proporcionais }

function CharWidth(Ch: Char): Integer;
begin
  case Ch of
    ' ', '.', ',', ':', ';', '!', #39, '|', '`': Result := 3;
    'I', 'i', 'l', '1', '[', ']', '(', ')': Result := 4;
    'f', 'r', 't', 'j', '-', '/': Result := 5;
    'c', 's', 'z', 'k', 'v', 'x', 'J', 'L', '?': Result := 6;
    'm', 'w', 'M', 'W', '@', '%', '&', 'Q': Result := 8;
  else
    Result := 7;
  end;
end;

function TextWidth(const AText: string; Scale: Integer): Integer;
var
  I: Integer;
  Total: Integer;
begin
  Total := 0;
  for I := 1 to Length(AText) do
    Inc(Total, (CharWidth(AText[I]) + 1) * Scale);
  Result := Total;
end;

function TextHeight(Scale: Integer): Integer;
begin
  Result := 8 * Scale;
end;

procedure DrawChar(var Buffer: TANativeWindow_Buffer; X, Y: Integer; Ch: Char;
  Color: Cardinal; Scale: Integer);
var
  AsciiVal: Integer;
  Row, Col: Integer;
  BitRow: Byte;
  SX, SY: Integer;
  PX, PY: Integer;
  RowPtr: PDWord;
  CWidth: Integer;
begin
  AsciiVal := Ord(Ch);
  if (AsciiVal < 32) or (AsciiVal > 126) then
    AsciiVal := 32;

  CWidth := CharWidth(Ch);

  for Row := 0 to 7 do
  begin
    BitRow := FONT_DATA[AsciiVal, Row];
    if BitRow = 0 then Continue;

    for Col := 0 to CWidth - 1 do
    begin
      if (BitRow and ($80 shr Col)) <> 0 then
      begin
        for SY := 0 to Scale - 1 do
        begin
          PY := Y + (Row * Scale) + SY;
          if (PY < 0) or (PY >= Buffer.height) then Continue;

          RowPtr := PDWord(Buffer.bits) + (PY * Buffer.stride);
          for SX := 0 to Scale - 1 do
          begin
            PX := X + (Col * Scale) + SX;
            if (PX >= 0) and (PX < Buffer.width) then
              RowPtr[PX] := Color;
          end;
        end;
      end;
    end;
  end;
end;

procedure DrawText(var Buffer: TANativeWindow_Buffer; X, Y: Integer; const AText: string;
  Color: Cardinal; Scale: Integer);
var
  I: Integer;
  CurX: Integer;
begin
  CurX := X;
  for I := 1 to Length(AText) do
  begin
    DrawChar(Buffer, CurX, Y, AText[I], Color, Scale);
    Inc(CurX, (CharWidth(AText[I]) + 1) * Scale);
  end;
end;

procedure DrawTextCentered(var Buffer: TANativeWindow_Buffer; X, Y, W: Integer;
  const AText: string; Color: Cardinal; Scale: Integer);
var
  TotalW: Integer;
  StartX: Integer;
begin
  TotalW := TextWidth(AText, Scale);
  StartX := X + ((W - TotalW) div 2);
  DrawText(Buffer, StartX, Y, AText, Color, Scale);
end;

procedure DrawTextRight(var Buffer: TANativeWindow_Buffer; RightX, Y: Integer;
  const AText: string; Color: Cardinal; Scale: Integer);
var
  TotalW: Integer;
begin
  TotalW := TextWidth(AText, Scale);
  DrawText(Buffer, RightX - TotalW, Y, AText, Color, Scale);
end;

procedure DrawBadge(var Buffer: TANativeWindow_Buffer; X, Y: Integer; const AText: string;
  BgColor, TextColor: Cardinal; Scale: Integer; HasDot: Boolean; DotColor: Cardinal);
var
  W, H: Integer;
  PadX, PadY: Integer;
  DotSize, DotPad: Integer;
  TextStartX: Integer;
begin
  PadX := Scale * 4;
  PadY := Scale * 2;
  DotSize := Scale * 2;
  DotPad := 0;

  if HasDot then
    DotPad := DotSize + Scale * 3;

  W := TextWidth(AText, Scale) + (PadX * 2) + DotPad;
  H := TextHeight(Scale) + (PadY * 2);

  // Fundo com cantos arredondados (estilo Pill do Stitch)
  DrawRoundedCard(Buffer, X, Y, W, H, H div 2, BgColor, BgColor, False);

  // Ponto indicador pulsante (Dot)
  if HasDot then
  begin
    FillRect(Buffer, X + PadX, Y + ((H - DotSize) div 2), DotSize, DotSize, DotColor);
    TextStartX := X + PadX + DotPad;
  end
  else
    TextStartX := X + PadX;

  DrawText(Buffer, TextStartX, Y + PadY, AText, TextColor, Scale);
end;

procedure DrawButton(var Buffer: TANativeWindow_Buffer; X, Y, W, H: Integer;
  const ATitle: string; BgColor, TextColor: Cardinal; Scale: Integer; Radius: Integer);
var
  TextY: Integer;
  BtnRad: Integer;
begin
  if Radius <= 0 then
    BtnRad := DP(8)
  else
    BtnRad := Radius;

  DrawRoundedCard(Buffer, X, Y, W, H, BtnRad, BgColor, BgColor, True);
  TextY := Y + ((H - TextHeight(Scale)) div 2);
  DrawTextCentered(Buffer, X, TextY, W, ATitle, TextColor, Scale);
end;

{ Ícones Vetoriais Nítidos (Stitch Design System) }

procedure DrawIconBuilding(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  W, H: Integer;
begin
  Thick := Max(1, Size div 10);
  W := Size * 4 div 5;
  H := Size;

  // Prédio Principal
  FillRect(Buffer, X, Y + (Size div 4), W, H - (Size div 4), Color);
  FillRect(Buffer, X + Thick, Y + (Size div 4) + Thick, W - (2 * Thick), H - (Size div 4) - Thick, COLOR_SURFACE_LOW);

  // Janelas
  FillRect(Buffer, X + (W div 4), Y + (Size div 2), Thick, Thick, Color);
  FillRect(Buffer, X + (W * 2 div 4), Y + (Size div 2), Thick, Thick, Color);
  FillRect(Buffer, X + (W div 4), Y + (Size * 3 div 4), Thick, Thick, Color);
  FillRect(Buffer, X + (W * 2 div 4), Y + (Size * 3 div 4), Thick, Thick, Color);
end;

procedure DrawIconUser(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  HeadR, HeadCX, HeadCY: Integer;
  BodyW, BodyH, BodyX, BodyY: Integer;
begin
  HeadR := Size div 4;
  HeadCX := X + (Size div 2);
  HeadCY := Y + HeadR;

  // Cabeça
  FillRect(Buffer, HeadCX - HeadR, HeadCY - HeadR, HeadR * 2, HeadR * 2, Color);

  // Ombros / Corpo
  BodyW := Size * 4 div 5;
  BodyH := Size div 3;
  BodyX := X + (Size - BodyW) div 2;
  BodyY := Y + (Size * 2 div 3);
  FillRect(Buffer, BodyX, BodyY, BodyW, BodyH, Color);
end;

procedure DrawIconLock(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  BodyW, BodyH, BodyX, BodyY: Integer;
  ArcW, ArcH, ArcX, ArcY: Integer;
begin
  Thick := Max(1, Size div 10);
  BodyW := Size * 4 div 5;
  BodyH := Size div 2;
  BodyX := X + (Size - BodyW) div 2;
  BodyY := Y + (Size div 2);

  // Corpo do cadeado
  FillRect(Buffer, BodyX, BodyY, BodyW, BodyH, Color);

  // Arco superior
  ArcW := BodyW * 2 div 3;
  ArcH := Size div 3;
  ArcX := X + (Size - ArcW) div 2;
  ArcY := Y + (Size div 6);

  FillRect(Buffer, ArcX, ArcY, ArcW, Thick, Color);
  FillRect(Buffer, ArcX, ArcY, Thick, ArcH, Color);
  FillRect(Buffer, ArcX + ArcW - Thick, ArcY, Thick, ArcH, Color);
end;

procedure DrawIconEye(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  CX, CY, PupilR: Integer;
begin
  Thick := Max(1, Size div 10);
  CX := X + (Size div 2);
  CY := Y + (Size div 2);
  PupilR := Size div 5;

  // Contorno do olho
  FillRect(Buffer, X, CY - Thick, Size, Thick * 2, Color);
  // Pupila central
  FillRect(Buffer, CX - PupilR, CY - PupilR, PupilR * 2, PupilR * 2, Color);
end;

procedure DrawIconCheck(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  I: Integer;
begin
  Thick := Max(2, Size div 7);
  // Traço curto esquerdo
  for I := 0 to (Size div 3) do
    FillRect(Buffer, X + I, Y + (Size div 2) + I, Thick, Thick, Color);
  // Traço longo ascendente direito
  for I := 0 to (Size * 2 div 3) do
    FillRect(Buffer, X + (Size div 3) + I, Y + (Size * 5 div 6) - (I * 5 div 4), Thick, Thick, Color);
end;

procedure DrawIconArrowRight(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  CY, I: Integer;
begin
  Thick := Max(2, Size div 8);
  CY := Y + (Size div 2);

  // Haste horizontal
  FillRect(Buffer, X, CY - (Thick div 2), Size * 3 div 4, Thick, Color);

  // Ponta da seta
  for I := 0 to (Size div 3) do
  begin
    FillRect(Buffer, X + (Size * 3 div 4) - I, CY - I, Thick, Thick, Color);
    FillRect(Buffer, X + (Size * 3 div 4) - I, CY + I, Thick, Thick, Color);
  end;
end;

procedure DrawIconFingerprint(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  CX, CY: Integer;
  R: Integer;
begin
  Thick := Max(1, Size div 12);
  CX := X + (Size div 2);
  CY := Y + (Size div 2);

  for R := 1 to 3 do
  begin
    DrawRect(Buffer, CX - (R * Size div 8), CY - (R * Size div 8),
      (R * Size div 4), (R * Size div 4), Thick, Color);
  end;
end;

procedure DrawIconSync(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  R: Integer;
begin
  Thick := Max(2, Size div 8);
  R := Size * 3 div 8;

  // Arco circular estilizado
  DrawRect(Buffer, X + (Size div 8), Y + (Size div 8), R * 2, R * 2, Thick, Color);
  // Setinha superior
  FillRect(Buffer, X + (Size * 3 div 4), Y, Thick * 2, Thick * 2, Color);
end;

procedure DrawIconPhone(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
begin
  Thick := Max(2, Size div 6);
  FillRect(Buffer, X, Y, Thick, Size, Color);
  FillRect(Buffer, X, Y, Size div 2, Thick, Color);
  FillRect(Buffer, X, Y + Size - Thick, Size div 2, Thick, Color);
end;

procedure DrawIconWhatsApp(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
begin
  Thick := Max(2, Size div 8);
  // Balão de conversa arredondado
  DrawRect(Buffer, X, Y, Size, Size * 4 div 5, Thick, Color);
  // Ponta do balão
  FillRect(Buffer, X + (Size div 4), Y + (Size * 4 div 5), Thick, Size div 5, Color);
end;

procedure DrawIconCart(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  WheelR: Integer;
begin
  Thick := Max(2, Size div 8);
  // Cabo
  FillRect(Buffer, X, Y, Size div 4, Thick, Color);
  // Cesto
  FillRect(Buffer, X + (Size div 5), Y + (Size div 4), Size * 3 div 4, Thick, Color);
  FillRect(Buffer, X + (Size div 4), Y + (Size * 3 div 5), Size * 3 div 5, Thick, Color);
  FillRect(Buffer, X + (Size div 5), Y + (Size div 4), Thick, Size * 2 div 5, Color);
  FillRect(Buffer, X + (Size * 4 div 5), Y + (Size div 4), Thick, Size * 2 div 5, Color);

  // Rodinhas
  WheelR := Max(2, Size div 7);
  FillRect(Buffer, X + (Size div 3), Y + (Size * 3 div 4), WheelR, WheelR, Color);
  FillRect(Buffer, X + (Size * 2 div 3), Y + (Size * 3 div 4), WheelR, WheelR, Color);
end;

procedure DrawIconPin(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  HeadR: Integer;
begin
  Thick := Max(2, Size div 8);
  HeadR := Size div 3;
  // Cabeça do pin
  FillRect(Buffer, X + (Size div 2) - HeadR, Y, HeadR * 2, HeadR * 2, Color);
  // Ponta para baixo
  FillRect(Buffer, X + (Size div 2) - (Thick div 2), Y + (HeadR * 2), Thick, Size - (HeadR * 2), Color);
end;

procedure DrawIconShoppingBag(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  BodyW, BodyH, BodyX, BodyY: Integer;
  HandleW, HandleH, HandleX, HandleY: Integer;
begin
  Thick := Max(2, Size div 8);
  BodyW := Size * 4 div 5;
  BodyH := Size * 3 div 5;
  BodyX := X + (Size - BodyW) div 2;
  BodyY := Y + (Size * 2 div 5);

  // Corpo da sacola
  DrawRect(Buffer, BodyX, BodyY, BodyW, BodyH, Thick, Color);

  // Alça
  HandleW := BodyW div 2;
  HandleH := Size div 3;
  HandleX := X + (Size - HandleW) div 2;
  HandleY := Y + (Size div 10);
  FillRect(Buffer, HandleX, HandleY, HandleW, Thick, Color);
  FillRect(Buffer, HandleX, HandleY, Thick, HandleH, Color);
  FillRect(Buffer, HandleX + HandleW - Thick, HandleY, Thick, HandleH, Color);
end;

procedure DrawIconInsights(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
  BarW: Integer;
begin
  Thick := Max(2, Size div 8);
  BarW := Size div 5;

  FillRect(Buffer, X, Y + (Size * 3 div 5), BarW, Size * 2 div 5, Color);
  FillRect(Buffer, X + (BarW * 3 div 2), Y + (Size div 3), BarW, Size * 2 div 3, Color);
  FillRect(Buffer, X + (BarW * 3), Y, BarW, Size, Color);
end;

procedure DrawIconCloud(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer; Color: Cardinal);
var
  Thick: Integer;
begin
  Thick := Max(2, Size div 8);
  // Base plana
  FillRect(Buffer, X, Y + (Size * 3 div 5), Size, Thick, Color);
  // Cúpulas
  FillRect(Buffer, X + (Size div 4), Y + (Size div 4), Size div 2, Thick, Color);
  FillRect(Buffer, X + (Size div 8), Y + (Size * 2 div 5), Size * 3 div 4, Thick, Color);
end;

procedure DrawVendaForceLogo(var Buffer: TANativeWindow_Buffer; X, Y, Size: Integer);
var
  CornerRad: Integer;
  Thick: Integer;
  AColor: Cardinal;
  ArrowColor: Cardinal;
  BadgeSize: Integer;
  I: Integer;
  AX, AY: Integer;
begin
  CornerRad := Size div 5;
  Thick := Max(3, Size div 9);
  AColor := COLOR_WHITE;
  ArrowColor := COLOR_SECONDARY_FIX;

  // 1. Container Quadrado Arredondado Azul Marinho com Sombra
  DrawRoundedCard(Buffer, X, Y, Size, Size, CornerRad, COLOR_PRIMARY_CONTAINER, COLOR_PRIMARY_CORP, True);

  // 2. Letra 'A' Estilizada no Centro
  AX := X + (Size div 4);
  AY := Y + (Size div 4);

  // Haste esquerda
  for I := 0 to (Size div 2) do
    FillRect(Buffer, AX + (Size div 4) - (I div 2), AY + I, Thick, 1, AColor);

  // Haste direita
  for I := 0 to (Size div 2) do
    FillRect(Buffer, AX + (Size div 4) + (I div 2), AY + I, Thick, 1, AColor);

  // Barra horizontal do 'A'
  FillRect(Buffer, AX + (Size div 8), AY + (Size div 3), Size div 4, Thick, AColor);

  // 3. Seta de Crescimento Verde VendaForce apontando para cima e direita
  for I := 0 to (Size div 3) do
    FillRect(Buffer, X + (Size div 2) + I, Y + (Size div 2) - I, Thick, Thick, ArrowColor);

  // Ponta da seta
  FillRect(Buffer, X + (Size * 5 div 6) - (Size div 6), Y + (Size div 6), Size div 6, Thick, ArrowColor);
  FillRect(Buffer, X + (Size * 5 div 6) - Thick, Y + (Size div 6), Thick, Size div 6, ArrowColor);

  // 4. Badge circular de energia no canto inferior direito
  BadgeSize := Size div 3;
  DrawRoundedCard(Buffer, X + Size - (BadgeSize * 4 div 5), Y + Size - (BadgeSize * 4 div 5),
    BadgeSize, BadgeSize, BadgeSize div 2, COLOR_SECONDARY_FIX, COLOR_SECONDARY_GREEN, False);

  // Raiozinho dentro do badge
  FillRect(Buffer, X + Size - (BadgeSize div 2), Y + Size - (BadgeSize * 2 div 3),
    Max(2, Thick div 2), BadgeSize div 2, COLOR_SECONDARY_GREEN);
end;

end.
