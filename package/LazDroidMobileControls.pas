{
  LazDroid-Deploy: Suíte de Componentes Mobile Nativos para Android
  Unit: LazDroidMobileControls.pas
  Descrição: Paleta de componentes mobile touch-first (AppBar, Button, Edit, Card, Badge, BottomNav, ListView)
             projetados especificamente para telas sensíveis ao toque no Android e no Lazarus Form Designer.
  Licença: MIT
}
unit LazDroidMobileControls;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Types, Graphics, Controls, Forms, StdCtrls, ExtCtrls, LCLType, LCLIntf;

type
  { Enumerações visuais }
  TLazDroidButtonVariant = (bvPrimary, bvSecondary, bvSuccess, bvDanger, bvWarning, bvOutline, bvGhost);
  TLazDroidActionIcon = (aiNone, aiBack, aiPlus, aiMenu, aiSearch, aiFilter, aiClose, aiCheck);
  TLazDroidBadgeStyle = (bsSuccess, bsWarning, bsDanger, bsInfo, bsNeutral, bsPrimary);
  TLazDroidInputKind = (ikText, ikPassword, ikNumber, ikPhone, ikEmail, ikCurrency);

  { Eventos personalizados }
  TLazDroidTabChangeEvent = procedure(Sender: TObject; AIndex: Integer) of object;
  TLazDroidItemClickEvent = procedure(Sender: TObject; AIndex: Integer) of object;

  { ---------------------------------------------------------------------------
    TLazDroidAppBar — Barra superior mobile com título, subtítulo e botões
    --------------------------------------------------------------------------- }
  TLazDroidAppBar = class(TCustomControl)
  private
    FTitle: string;
    FSubtitle: string;
    FShowBack: Boolean;
    FActionIcon: TLazDroidActionIcon;
    FTitleColor: TColor;
    FSubtitleColor: TColor;
    FBarColor: TColor;
    FOnBackClick: TNotifyEvent;
    FOnActionClick: TNotifyEvent;
    FBackHover: Boolean;
    FActionHover: Boolean;

    function GetBackRect: TRect;
    function GetActionRect: TRect;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align default alTop;
    property Height default 56;
    property Title: string read FTitle write FTitle;
    property Subtitle: string read FSubtitle write FSubtitle;
    property ShowBack: Boolean read FShowBack write FShowBack default True;
    property ActionIcon: TLazDroidActionIcon read FActionIcon write FActionIcon default aiMenu;
    property BarColor: TColor read FBarColor write FBarColor default $00241A14; // Dark Navy / Indigo
    property TitleColor: TColor read FTitleColor write FTitleColor default clWhite;
    property SubtitleColor: TColor read FSubtitleColor write FSubtitleColor default $00D0C0B0;
    property OnBackClick: TNotifyEvent read FOnBackClick write FOnBackClick;
    property OnActionClick: TNotifyEvent read FOnActionClick write FOnActionClick;
    property Font;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidButton — Botão touch de alta resposta com cantos arredondados
    --------------------------------------------------------------------------- }
  TLazDroidButton = class(TCustomControl)
  private
    FCaption: string;
    FVariant: TLazDroidButtonVariant;
    FCornerRadius: Integer;
    FIsPressed: Boolean;
    FBadge: string;
    FCustomColor: TColor;
    FCustomTextColor: TColor;
    FIcon: TLazDroidActionIcon;

    function GetBaseColor: TColor;
    function GetTextColor: TColor;
    procedure SetCaption(const AValue: string);
    procedure SetVariant(const AValue: TLazDroidButtonVariant);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption: string read FCaption write SetCaption;
    property Variant: TLazDroidButtonVariant read FVariant write SetVariant default bvPrimary;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 10;
    property Badge: string read FBadge write FBadge;
    property Icon: TLazDroidActionIcon read FIcon write FIcon default aiNone;
    property CustomColor: TColor read FCustomColor write FCustomColor default clNone;
    property CustomTextColor: TColor read FCustomTextColor write FCustomTextColor default clNone;
    property Enabled;
    property Font;
    property OnClick;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidCard — Container de conteúdo mobile estilizado
    --------------------------------------------------------------------------- }
  TLazDroidCard = class(TCustomControl)
  private
    FCornerRadius: Integer;
    FCardColor: TColor;
    FBorderColor: TColor;
    FHeaderTitle: string;
    FHeaderColor: TColor;
    FHeaderTextColor: TColor;
    FShowHeader: Boolean;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 12;
    property CardColor: TColor read FCardColor write FCardColor default clWhite;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00E0E0E0;
    property HeaderTitle: string read FHeaderTitle write FHeaderTitle;
    property HeaderColor: TColor read FHeaderColor write FHeaderColor default $00F8FAFC;
    property HeaderTextColor: TColor read FHeaderTextColor write FHeaderTextColor default $001E293B;
    property ShowHeader: Boolean read FShowHeader write FShowHeader default False;
    property Align;
    property Anchors;
    property Font;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidBadge — Pill/Etiqueta de status com cores semânticas
    --------------------------------------------------------------------------- }
  TLazDroidBadge = class(TGraphicControl)
  private
    FCaption: string;
    FStyle: TLazDroidBadgeStyle;
    procedure SetCaption(const AValue: string);
    procedure SetStyle(const AValue: TLazDroidBadgeStyle);
    function GetBgColor: TColor;
    function GetTextColor: TColor;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption: string read FCaption write SetCaption;
    property Style: TLazDroidBadgeStyle read FStyle write SetStyle default bsPrimary;
    property Font;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidEdit — Campo de texto touch-friendly com teclado virtual automático
    --------------------------------------------------------------------------- }
  TLazDroidEdit = class(TCustomControl)
  private
    FText: string;
    FPlaceholder: string;
    FLabelCaption: string;
    FIsFocused: Boolean;
    FIsPassword: Boolean;
    FInputKind: TLazDroidInputKind;
    FBorderColor: TColor;
    FFocusedColor: TColor;
    FCornerRadius: Integer;
    FCaretPos: Integer;
    FOnChange: TNotifyEvent;

    procedure SetText(const AValue: string);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure UTF8KeyPress(var UTF8Key: TUTF8Char); override;
    procedure DoEnter; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Text: string read FText write SetText;
    property Placeholder: string read FPlaceholder write FPlaceholder;
    property LabelCaption: string read FLabelCaption write FLabelCaption;
    property IsPassword: Boolean read FIsPassword write FIsPassword default False;
    property InputKind: TLazDroidInputKind read FInputKind write FInputKind default ikText;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 8;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00D0D0D0;
    property FocusedColor: TColor read FFocusedColor write FFocusedColor default $00D97706; // Blue/Amber Accent
    property Enabled;
    property Font;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidBottomNav — Barra de navegação inferior mobile (Tabs)
    --------------------------------------------------------------------------- }
  TLazDroidBottomNav = class(TCustomControl)
  private
    FItems: TStrings;
    FActiveIndex: Integer;
    FActiveColor: TColor;
    FInactiveColor: TColor;
    FBarColor: TColor;
    FOnTabSelected: TLazDroidTabChangeEvent;

    procedure SetItems(const AValue: TStrings);
    procedure SetActiveIndex(const AValue: Integer);
    procedure ItemsChanged(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align default alBottom;
    property Height default 56;
    property Items: TStrings read FItems write SetItems;
    property ActiveIndex: Integer read FActiveIndex write SetActiveIndex default 0;
    property ActiveColor: TColor read FActiveColor write FActiveColor default $00D97706;
    property InactiveColor: TColor read FInactiveColor write FInactiveColor default $008E8E93;
    property BarColor: TColor read FBarColor write FBarColor default $0018181B; // Zinc 900
    property OnTabSelected: TLazDroidTabChangeEvent read FOnTabSelected write FOnTabSelected;
    property Font;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidListView — Lista mobile com títulos, subtítulos, badges e toque
    --------------------------------------------------------------------------- }
  TLazDroidListItem = class(TCollectionItem)
  private
    FTitle: string;
    FSubtitle: string;
    FBadge: string;
    FValue: string;
    FTag: Integer;
  published
    property Title: string read FTitle write FTitle;
    property Subtitle: string read FSubtitle write FSubtitle;
    property Badge: string read FBadge write FBadge;
    property Value: string read FValue write FValue;
    property Tag: Integer read FTag write FTag default 0;
  end;

  TLazDroidListItems = class(TCollection)
  private
    FOwnerControl: TCustomControl;
    function GetItem(Index: Integer): TLazDroidListItem;
    procedure SetItem(Index: Integer; const Value: TLazDroidListItem);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TCustomControl);
    function Add: TLazDroidListItem;
    property Items[Index: Integer]: TLazDroidListItem read GetItem write SetItem; default;
  end;

  TLazDroidListView = class(TCustomControl)
  private
    FItems: TLazDroidListItems;
    FItemHeight: Integer;
    FSelectedIndex: Integer;
    FScrollOffset: Integer;
    FStartY: Integer;
    FIsDragging: Boolean;
    FItemBgColor: TColor;
    FAltItemBgColor: TColor;
    FSelectedBgColor: TColor;
    FDividerColor: TColor;
    FOnItemClick: TLazDroidItemClickEvent;

    procedure SetItems(const AValue: TLazDroidListItems);
    procedure SetSelectedIndex(const AValue: Integer);
    function GetTotalContentHeight: Integer;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ScrollToTop;
  published
    property Items: TLazDroidListItems read FItems write SetItems;
    property ItemHeight: Integer read FItemHeight write FItemHeight default 64;
    property SelectedIndex: Integer read FSelectedIndex write SetSelectedIndex default -1;
    property ItemBgColor: TColor read FItemBgColor write FItemBgColor default clWhite;
    property AltItemBgColor: TColor read FAltItemBgColor write FAltItemBgColor default $00F9FAFB;
    property SelectedBgColor: TColor read FSelectedBgColor write FSelectedBgColor default $00E0F2FE;
    property DividerColor: TColor read FDividerColor write FDividerColor default $00E5E7EB;
    property OnItemClick: TLazDroidItemClickEvent read FOnItemClick write FOnItemClick;
    property Align;
    property Anchors;
    property Font;
  end;

procedure Register;

implementation

{ Rotina auxiliar de desenho de ícones geométricos limpos }
procedure DrawMobileIcon(Canvas: TCanvas; Icon: TLazDroidActionIcon; const R: TRect; Color: TColor);
var
  cx, cy, s: Integer;
begin
  if Icon = aiNone then Exit;
  Canvas.Pen.Color := Color;
  Canvas.Pen.Width := 2;
  Canvas.Pen.Style := psSolid;
  Canvas.Brush.Style := bsClear;

  cx := (R.Left + R.Right) div 2;
  cy := (R.Top + R.Bottom) div 2;
  s := 7;

  case Icon of
    aiBack:
    begin
      Canvas.Line(cx + s div 2, cy - s, cx - s div 2, cy);
      Canvas.Line(cx - s div 2, cy, cx + s div 2, cy + s);
    end;
    aiPlus:
    begin
      Canvas.Line(cx - s, cy, cx + s, cy);
      Canvas.Line(cx, cy - s, cx, cy + s);
    end;
    aiMenu:
    begin
      Canvas.Line(cx - s, cy - 5, cx + s, cy - 5);
      Canvas.Line(cx - s, cy, cx + s, cy);
      Canvas.Line(cx - s, cy + 5, cx + s, cy + 5);
    end;
    aiClose:
    begin
      Canvas.Line(cx - s, cy - s, cx + s, cy + s);
      Canvas.Line(cx + s, cy - s, cx - s, cy + s);
    end;
    aiCheck:
    begin
      Canvas.Line(cx - s, cy, cx - 1, cy + s - 2);
      Canvas.Line(cx - 1, cy + s - 2, cx + s, cy - s);
    end;
    aiSearch:
    begin
      Canvas.Ellipse(cx - s, cy - s, cx + 2, cy + 2);
      Canvas.Line(cx + 1, cy + 1, cx + s, cy + s);
    end;
    aiFilter:
    begin
      Canvas.Line(cx - s, cy - s + 2, cx + s, cy - s + 2);
      Canvas.Line(cx - s + 3, cy, cx + s - 3, cy);
      Canvas.Line(cx - s + 5, cy + s - 2, cx + s - 5, cy + s - 2);
    end;
  end;
end;

{ =============================================================================
  TLazDroidAppBar
  ============================================================================= }

constructor TLazDroidAppBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Align := alTop;
  Height := 56;
  FTitle := 'LazDroid Mobile';
  FSubtitle := '';
  FShowBack := True;
  FActionIcon := aiMenu;
  FBarColor := $00241A14; // Dark Navy
  FTitleColor := clWhite;
  FSubtitleColor := $00D0C0B0;
  Font.Name := 'Segoe UI';
  Font.Size := 12;
  Font.Style := [fsBold];
end;

function TLazDroidAppBar.GetBackRect: TRect;
begin
  Result := Rect(8, (Height - 40) div 2, 48, (Height + 40) div 2);
end;

function TLazDroidAppBar.GetActionRect: TRect;
begin
  Result := Rect(Width - 48, (Height - 40) div 2, Width - 8, (Height + 40) div 2);
end;

procedure TLazDroidAppBar.Paint;
var
  R: TRect;
  TextLeft: Integer;
begin
  Canvas.Brush.Color := FBarColor;
  Canvas.FillRect(ClientRect);

  if FShowBack then
  begin
    R := GetBackRect;
    if FBackHover then
    begin
      Canvas.Brush.Color := TColor($003A2A20);
      Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);
    end;
    DrawMobileIcon(Canvas, aiBack, R, FTitleColor);
  end;

  if FActionIcon <> aiNone then
  begin
    R := GetActionRect;
    if FActionHover then
    begin
      Canvas.Brush.Color := TColor($003A2A20);
      Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, 8, 8);
    end;
    DrawMobileIcon(Canvas, FActionIcon, R, FTitleColor);
  end;

  TextLeft := 16;
  if FShowBack then TextLeft := 52;

  Canvas.Brush.Style := bsClear;
  Canvas.Font := Self.Font;
  Canvas.Font.Color := FTitleColor;

  if FSubtitle <> '' then
  begin
    Canvas.TextOut(TextLeft, 8, FTitle);
    Canvas.Font.Size := 9;
    Canvas.Font.Style := [];
    Canvas.Font.Color := FSubtitleColor;
    Canvas.TextOut(TextLeft, 30, FSubtitle);
  end
  else
  begin
    Canvas.TextOut(TextLeft, (Height - Canvas.TextHeight(FTitle)) div 2, FTitle);
  end;
end;

procedure TLazDroidAppBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if FShowBack and PtInRect(GetBackRect, Point(X, Y)) then
  begin
    FBackHover := True;
    Invalidate;
  end;
  if (FActionIcon <> aiNone) and PtInRect(GetActionRect, Point(X, Y)) then
  begin
    FActionHover := True;
    Invalidate;
  end;
end;

procedure TLazDroidAppBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if FBackHover then
  begin
    FBackHover := False;
    Invalidate;
    if Assigned(FOnBackClick) then FOnBackClick(Self);
  end;
  if FActionHover then
  begin
    FActionHover := False;
    Invalidate;
    if Assigned(FOnActionClick) then FOnActionClick(Self);
  end;
end;

{ =============================================================================
  TLazDroidButton
  ============================================================================= }

constructor TLazDroidButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 140;
  Height := 48;
  FCaption := 'Botão Touch';
  FVariant := bvPrimary;
  FCornerRadius := 10;
  FCustomColor := clNone;
  FCustomTextColor := clNone;
  FIcon := aiNone;
  Font.Name := 'Segoe UI';
  Font.Size := 11;
  Font.Style := [fsBold];
end;

function TLazDroidButton.GetBaseColor: TColor;
begin
  if FCustomColor <> clNone then Exit(FCustomColor);
  case FVariant of
    bvPrimary:   Result := $00D97706;
    bvSecondary: Result := $0064748B;
    bvSuccess:   Result := $004A6C00;
    bvDanger:    Result := $001F29D9;
    bvWarning:   Result := $000D9488;
    bvOutline:   Result := clWhite;
    bvGhost:     Result := clWhite;
  else
    Result := $00D97706;
  end;
end;

function TLazDroidButton.GetTextColor: TColor;
begin
  if FCustomTextColor <> clNone then Exit(FCustomTextColor);
  case FVariant of
    bvOutline: Result := $00D97706;
    bvGhost:   Result := $00334155;
  else
    Result := clWhite;
  end;
end;

procedure TLazDroidButton.SetCaption(const AValue: string);
begin
  if FCaption <> AValue then
  begin
    FCaption := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidButton.SetVariant(const AValue: TLazDroidButtonVariant);
begin
  if FVariant <> AValue then
  begin
    FVariant := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidButton.Paint;
var
  BgCol: TColor;
  tx, ty: Integer;
  R: TRect;
begin
  BgCol := GetBaseColor;
  if FIsPressed then
    BgCol := TColor(Integer(BgCol) - $00151515);

  R := ClientRect;
  Canvas.Brush.Color := BgCol;
  if (FVariant = bvOutline) then
  begin
    Canvas.Pen.Color := GetTextColor;
    Canvas.Pen.Width := 2;
  end
  else
  begin
    Canvas.Pen.Color := BgCol;
    Canvas.Pen.Width := 1;
  end;

  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);

  if FIcon <> aiNone then
  begin
    DrawMobileIcon(Canvas, FIcon, Rect(R.Left + 12, R.Top + 12, R.Left + 36, R.Bottom - 12), GetTextColor);
  end;

  Canvas.Brush.Style := bsClear;
  Canvas.Font := Self.Font;
  Canvas.Font.Color := GetTextColor;
  if not Enabled then Canvas.Font.Color := clGray;

  tx := (Width - Canvas.TextWidth(FCaption)) div 2;
  if FIcon <> aiNone then tx := tx + 10;
  ty := (Height - Canvas.TextHeight(FCaption)) div 2;
  Canvas.TextOut(tx, ty, FCaption);
end;

procedure TLazDroidButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FIsPressed := True;
  Invalidate;
end;

procedure TLazDroidButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FIsPressed := False;
  Invalidate;
end;

procedure TLazDroidButton.Click;
begin
  inherited Click;
end;

{ =============================================================================
  TLazDroidCard
  ============================================================================= }

constructor TLazDroidCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 280;
  Height := 160;
  FCornerRadius := 12;
  FCardColor := clWhite;
  FBorderColor := $00E0E0E0;
  FHeaderTitle := 'Título do Cartão';
  FHeaderColor := $00F8FAFC;
  FHeaderTextColor := $001E293B;
  FShowHeader := False;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
end;

procedure TLazDroidCard.Paint;
var
  R: TRect;
begin
  R := ClientRect;
  Canvas.Brush.Color := FCardColor;
  Canvas.Pen.Color := FBorderColor;
  Canvas.Pen.Width := 1;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);

  if FShowHeader and (FHeaderTitle <> '') then
  begin
    Canvas.Brush.Color := FHeaderColor;
    Canvas.Pen.Color := FBorderColor;
    Canvas.RoundRect(R.Left, R.Top, R.Right, R.Top + 36, FCornerRadius, FCornerRadius);
    Canvas.FillRect(Rect(R.Left + 1, R.Top + 20, R.Right - 1, R.Top + 36));

    Canvas.Brush.Style := bsClear;
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Color := FHeaderTextColor;
    Canvas.TextOut(R.Left + 14, R.Top + 9, FHeaderTitle);
  end;
end;

{ =============================================================================
  TLazDroidBadge
  ============================================================================= }

constructor TLazDroidBadge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 75;
  Height := 24;
  FCaption := 'Ativo';
  FStyle := bsSuccess;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  Font.Style := [fsBold];
end;

function TLazDroidBadge.GetBgColor: TColor;
begin
  case FStyle of
    bsSuccess: Result := $00DCFCE7;
    bsWarning: Result := $00FEF3C7;
    bsDanger:  Result := $00FEE2E2;
    bsInfo:    Result := $00E0F2FE;
    bsNeutral: Result := $00F1F5F9;
    bsPrimary: Result := $00EDE9FE;
  else
    Result := $00E0E0E0;
  end;
end;

function TLazDroidBadge.GetTextColor: TColor;
begin
  case FStyle of
    bsSuccess: Result := $00166534;
    bsWarning: Result := $0092400E;
    bsDanger:  Result := $00991B1B;
    bsInfo:    Result := $00075985;
    bsNeutral: Result := $00475569;
    bsPrimary: Result := $005B21B6;
  else
    Result := clBlack;
  end;
end;

procedure TLazDroidBadge.SetCaption(const AValue: string);
begin
  if FCaption <> AValue then
  begin
    FCaption := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidBadge.SetStyle(const AValue: TLazDroidBadgeStyle);
begin
  if FStyle <> AValue then
  begin
    FStyle := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidBadge.Paint;
var
  R: TRect;
  tx, ty: Integer;
begin
  R := ClientRect;
  Canvas.Brush.Color := GetBgColor;
  Canvas.Pen.Color := GetBgColor;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Height, Height);

  Canvas.Brush.Style := bsClear;
  Canvas.Font := Self.Font;
  Canvas.Font.Color := GetTextColor;
  tx := (Width - Canvas.TextWidth(FCaption)) div 2;
  ty := (Height - Canvas.TextHeight(FCaption)) div 2;
  Canvas.TextOut(tx, ty, FCaption);
end;

{ =============================================================================
  TLazDroidEdit
  ============================================================================= }

constructor TLazDroidEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csRequiresKeyboardInput, csOpaque];
  TabStop := True;
  Width := 240;
  Height := 48;
  FText := '';
  FPlaceholder := 'Digite aqui...';
  FLabelCaption := '';
  FCornerRadius := 8;
  FBorderColor := $00D0D0D0;
  FFocusedColor := $00D97706;
  FIsFocused := False;
  FIsPassword := False;
  FInputKind := ikText;
  FCaretPos := 0;
  Font.Name := 'Segoe UI';
  Font.Size := 11;
end;

procedure TLazDroidEdit.SetText(const AValue: string);
begin
  if FText <> AValue then
  begin
    FText := AValue;
    FCaretPos := Length(FText);
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidEdit.DoEnter;
begin
  inherited DoEnter;
  FIsFocused := True;
  Invalidate;
end;

procedure TLazDroidEdit.DoExit;
begin
  inherited DoExit;
  FIsFocused := False;
  Invalidate;
end;

procedure TLazDroidEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if CanFocus then SetFocus;
end;

procedure TLazDroidEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key = VK_BACK then
  begin
    if Length(FText) > 0 then
    begin
      Delete(FText, Length(FText), 1);
      FCaretPos := Length(FText);
      Invalidate;
      if Assigned(FOnChange) then FOnChange(Self);
    end;
  end;
end;

procedure TLazDroidEdit.UTF8KeyPress(var UTF8Key: TUTF8Char);
begin
  inherited UTF8KeyPress(UTF8Key);
  if (UTF8Key >= ' ') then
  begin
    FText := FText + UTF8Key;
    FCaretPos := Length(FText);
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidEdit.Paint;
var
  R: TRect;
  DisplayText: string;
  tx, ty: Integer;
begin
  R := ClientRect;
  Canvas.Brush.Color := clWhite;
  if FIsFocused then
  begin
    Canvas.Pen.Color := FFocusedColor;
    Canvas.Pen.Width := 2;
  end
  else
  begin
    Canvas.Pen.Color := FBorderColor;
    Canvas.Pen.Width := 1;
  end;

  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);

  Canvas.Brush.Style := bsClear;
  Canvas.Font := Self.Font;
  ty := (Height - Canvas.TextHeight('Ag')) div 2;
  tx := 12;

  if FText <> '' then
  begin
    Canvas.Font.Color := clBlack;
    if FIsPassword then
      DisplayText := StringOfChar('*', Length(FText))
    else
      DisplayText := FText;
    Canvas.TextOut(tx, ty, DisplayText);

    if FIsFocused then
    begin
      Canvas.Pen.Color := FFocusedColor;
      Canvas.Line(tx + Canvas.TextWidth(DisplayText) + 2, ty,
                  tx + Canvas.TextWidth(DisplayText) + 2, ty + Canvas.TextHeight('Ag'));
    end;
  end
  else
  begin
    Canvas.Font.Color := $009CA3AF;
    Canvas.TextOut(tx, ty, FPlaceholder);
  end;
end;

{ =============================================================================
  TLazDroidBottomNav
  ============================================================================= }

constructor TLazDroidBottomNav.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Align := alBottom;
  Height := 56;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := @ItemsChanged;
  FActiveIndex := 0;
  FActiveColor := $00D97706;
  FInactiveColor := $008E8E93;
  FBarColor := $0018181B;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  Font.Style := [fsBold];

  FItems.Add('Início');
  FItems.Add('Vendas');
  FItems.Add('Clientes');
  FItems.Add('Ajustes');
end;

destructor TLazDroidBottomNav.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TLazDroidBottomNav.SetItems(const AValue: TStrings);
begin
  FItems.Assign(AValue);
end;

procedure TLazDroidBottomNav.SetActiveIndex(const AValue: Integer);
begin
  if FActiveIndex <> AValue then
  begin
    FActiveIndex := AValue;
    Invalidate;
    if Assigned(FOnTabSelected) then FOnTabSelected(Self, FActiveIndex);
  end;
end;

procedure TLazDroidBottomNav.ItemsChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TLazDroidBottomNav.Paint;
var
  i, TabCount, TabW, x, y: Integer;
  CaptionStr: string;
begin
  Canvas.Brush.Color := FBarColor;
  Canvas.FillRect(ClientRect);

  TabCount := FItems.Count;
  if TabCount = 0 then Exit;
  TabW := Width div TabCount;

  Canvas.Brush.Style := bsClear;

  for i := 0 to TabCount - 1 do
  begin
    CaptionStr := FItems[i];
    x := i * TabW + (TabW - Canvas.TextWidth(CaptionStr)) div 2;
    y := Height - Canvas.TextHeight(CaptionStr) - 8;

    Canvas.Font := Self.Font;
    if i = FActiveIndex then
    begin
      Canvas.Font.Color := FActiveColor;
      Canvas.Pen.Color := FActiveColor;
      Canvas.Pen.Width := 3;
      Canvas.Line(i * TabW + 16, 2, (i + 1) * TabW - 16, 2);
    end
    else
    begin
      Canvas.Font.Color := FInactiveColor;
    end;

    Canvas.TextOut(x, y, CaptionStr);
  end;
end;

procedure TLazDroidBottomNav.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  TabCount, TabW, ClickedIndex: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  TabCount := FItems.Count;
  if TabCount = 0 then Exit;
  TabW := Width div TabCount;
  ClickedIndex := X div TabW;
  if (ClickedIndex >= 0) and (ClickedIndex < TabCount) then
    SetActiveIndex(ClickedIndex);
end;

{ =============================================================================
  TLazDroidListView
  ============================================================================= }

constructor TLazDroidListItems.Create(AOwner: TCustomControl);
begin
  inherited Create(TLazDroidListItem);
  FOwnerControl := AOwner;
end;

function TLazDroidListItems.GetItem(Index: Integer): TLazDroidListItem;
begin
  Result := TLazDroidListItem(inherited GetItem(Index));
end;

procedure TLazDroidListItems.SetItem(Index: Integer; const Value: TLazDroidListItem);
begin
  inherited SetItem(Index, Value);
end;

function TLazDroidListItems.Add: TLazDroidListItem;
begin
  Result := TLazDroidListItem(inherited Add);
end;

procedure TLazDroidListItems.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOwnerControl) then FOwnerControl.Invalidate;
end;

constructor TLazDroidListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 300;
  Height := 350;
  FItems := TLazDroidListItems.Create(Self);
  FItemHeight := 64;
  FSelectedIndex := -1;
  FScrollOffset := 0;
  FItemBgColor := clWhite;
  FAltItemBgColor := $00F9FAFB;
  FSelectedBgColor := $00E0F2FE;
  FDividerColor := $00E5E7EB;
  Font.Name := 'Segoe UI';
  Font.Size := 11;
end;

destructor TLazDroidListView.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TLazDroidListView.SetItems(const AValue: TLazDroidListItems);
begin
  FItems.Assign(AValue);
end;

procedure TLazDroidListView.SetSelectedIndex(const AValue: Integer);
begin
  if FSelectedIndex <> AValue then
  begin
    FSelectedIndex := AValue;
    Invalidate;
    if Assigned(FOnItemClick) and (FSelectedIndex >= 0) then
      FOnItemClick(Self, FSelectedIndex);
  end;
end;

function TLazDroidListView.GetTotalContentHeight: Integer;
begin
  Result := FItems.Count * FItemHeight;
end;

procedure TLazDroidListView.ScrollToTop;
begin
  FScrollOffset := 0;
  Invalidate;
end;

procedure TLazDroidListView.Paint;
var
  i, ItemTop, ItemBottom: Integer;
  R: TRect;
  Item: TLazDroidListItem;
begin
  Canvas.Brush.Color := FItemBgColor;
  Canvas.FillRect(ClientRect);

  for i := 0 to FItems.Count - 1 do
  begin
    Item := FItems[i];
    ItemTop := i * FItemHeight - FScrollOffset;
    ItemBottom := ItemTop + FItemHeight;

    if (ItemBottom < 0) or (ItemTop > Height) then Continue;

    R := Rect(0, ItemTop, Width, ItemBottom);

    if i = FSelectedIndex then
      Canvas.Brush.Color := FSelectedBgColor
    else if (i mod 2 = 1) then
      Canvas.Brush.Color := FAltItemBgColor
    else
      Canvas.Brush.Color := FItemBgColor;

    Canvas.FillRect(R);

    Canvas.Brush.Style := bsClear;
    Canvas.Font.Name := 'Segoe UI';
    Canvas.Font.Size := 11;
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Color := $00111827;
    Canvas.TextOut(16, ItemTop + 10, Item.Title);

    if Item.Subtitle <> '' then
    begin
      Canvas.Font.Size := 9;
      Canvas.Font.Style := [];
      Canvas.Font.Color := $006B7280;
      Canvas.TextOut(16, ItemTop + 34, Item.Subtitle);
    end;

    if Item.Value <> '' then
    begin
      Canvas.Font.Size := 11;
      Canvas.Font.Style := [fsBold];
      Canvas.Font.Color := $00047857;
      Canvas.TextOut(Width - Canvas.TextWidth(Item.Value) - 16, ItemTop + 20, Item.Value);
    end;

    Canvas.Pen.Color := FDividerColor;
    Canvas.Pen.Width := 1;
    Canvas.Line(16, ItemBottom - 1, Width, ItemBottom - 1);
  end;
end;

procedure TLazDroidListView.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FStartY := Y;
  FIsDragging := True;
end;

procedure TLazDroidListView.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  DeltaY, MaxScroll: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if FIsDragging then
  begin
    DeltaY := FStartY - Y;
    FStartY := Y;
    MaxScroll := GetTotalContentHeight - Height;
    if MaxScroll < 0 then MaxScroll := 0;

    FScrollOffset := FScrollOffset + DeltaY;
    if FScrollOffset < 0 then FScrollOffset := 0;
    if FScrollOffset > MaxScroll then FScrollOffset := MaxScroll;
    Invalidate;
  end;
end;

procedure TLazDroidListView.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ClickedIndex: Integer;
begin
  inherited MouseUp(Button, Shift, X, Y);
  FIsDragging := False;

  ClickedIndex := (Y + FScrollOffset) div FItemHeight;
  if (ClickedIndex >= 0) and (ClickedIndex < FItems.Count) then
    SetSelectedIndex(ClickedIndex);
end;

procedure Register;
begin
  RegisterComponents('LazDroid', [
    TLazDroidAppBar,
    TLazDroidButton,
    TLazDroidEdit,
    TLazDroidCard,
    TLazDroidBadge,
    TLazDroidBottomNav,
    TLazDroidListView
  ]);
end;

end.
