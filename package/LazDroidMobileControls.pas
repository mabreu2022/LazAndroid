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
  Classes, SysUtils, Types, Math, DateUtils, Graphics, Controls, Forms, StdCtrls, ExtCtrls, ImgList, LCLType, LCLIntf, LResources;

type
  { Enumerações visuais }
  TLazDroidButtonVariant = (bvPrimary, bvSecondary, bvSuccess, bvDanger, bvWarning, bvOutline, bvGhost);
  TLazDroidActionIcon = (aiNone, aiBack, aiPlus, aiMenu, aiSearch, aiFilter, aiClose, aiCheck, aiCalendar, aiClock, aiStar, aiDollar, aiTrendingUp, aiTrendingDown, aiUser, aiLock, aiEdit);
  TLazDroidBadgeStyle = (bsSuccess, bsWarning, bsDanger, bsInfo, bsNeutral, bsPrimary);
  TLazDroidInputKind = (ikText, ikPassword, ikNumber, ikPhone, ikEmail, ikCurrency);
  TLazDroidImageShape = (isRoundedSquare, isCircle, isSquare);

  { Eventos personalizados }
  TLazDroidTabChangeEvent = procedure(Sender: TObject; AIndex: Integer) of object;
  TLazDroidItemClickEvent = procedure(Sender: TObject; AIndex: Integer) of object;
  TLazDroidKeyPressEvent = procedure(Sender: TObject; const AKey: string) of object;
  TLazDroidSearchEvent = procedure(Sender: TObject; const ASearchText: string) of object;

{ Funções utilitárias de densidade e escala mobile (DPI/DP) e diálogos touch }
function GetMobileScale(AControl: TControl = nil): Double;
function MobileDP(const AValue: Integer; AControl: TControl = nil): Integer;
function MobileSP(const AValue: Integer; AControl: TControl = nil): Integer;
procedure AdaptMobileFormLayout(AForm: TCustomForm);
function ShowMobileDatePicker(var ADate: TDateTime; const ATitle: string = 'Selecionar Data'): Boolean;
function ShowMobileTimePicker(var ATime: TDateTime; const ATitle: string = 'Selecionar Horário'): Boolean;
procedure ShowMobileToast(AOwner: TCustomForm; const AMsg: string; ADurationMs: Integer = 2500);
function ShowMobileActionSheet(const ATitle: string; const AOptions: array of string; AOwner: TCustomForm = nil): Integer;

type
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
    property Anchors;
    property Visible;
    property Enabled;
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
    property Anchors;
    property Visible;
    property Enabled;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidListView — Lista mobile com títulos, subtítulos, badges, imagens e toque
    --------------------------------------------------------------------------- }
  TLazDroidListItem = class(TCollectionItem)
  private
    FTitle: string;
    FSubtitle: string;
    FBadge: string;
    FValue: string;
    FTag: Integer;
    FPicture: TPicture;
    FImageIndex: Integer;
    FIcon: TLazDroidActionIcon;
    FIconColor: TColor;
    FIconBgColor: TColor;
    FImageShape: TLazDroidImageShape;
    procedure SetTitle(const AValue: string);
    procedure SetSubtitle(const AValue: string);
    procedure SetBadge(const AValue: string);
    procedure SetValue(const AValue: string);
    procedure SetPicture(AValue: TPicture);
    procedure SetImageIndex(const AValue: Integer);
    procedure SetIcon(const AValue: TLazDroidActionIcon);
    procedure SetIconColor(const AValue: TColor);
    procedure SetIconBgColor(const AValue: TColor);
    procedure SetImageShape(const AValue: TLazDroidImageShape);
    procedure PictureChanged(Sender: TObject);
  public
    constructor Create(ACollection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function HasImage: Boolean;
  published
    property Title: string read FTitle write SetTitle;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property Badge: string read FBadge write SetBadge;
    property Value: string read FValue write SetValue;
    property Tag: Integer read FTag write FTag default 0;
    property Picture: TPicture read FPicture write SetPicture;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property Icon: TLazDroidActionIcon read FIcon write SetIcon default aiNone;
    property IconColor: TColor read FIconColor write SetIconColor default clWhite;
    property IconBgColor: TColor read FIconBgColor write SetIconBgColor default $00D97706;
    property ImageShape: TLazDroidImageShape read FImageShape write SetImageShape default isRoundedSquare;
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
    FImages: TCustomImageList;
    FImageSize: Integer;
    FOnItemClick: TLazDroidItemClickEvent;

    procedure SetItems(const AValue: TLazDroidListItems);
    procedure SetSelectedIndex(const AValue: Integer);
    procedure SetImages(const AValue: TCustomImageList);
    procedure SetImageSize(const AValue: Integer);
    function GetTotalContentHeight: Integer;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ScrollToTop;
    procedure Clear;
    function AddItem(const ATitle: string; const ASubtitle: string = ''; const AValue: string = ''): TLazDroidListItem;
  published
    property Items: TLazDroidListItems read FItems write SetItems;
    property Images: TCustomImageList read FImages write SetImages;
    property ImageSize: Integer read FImageSize write SetImageSize default 44;
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

  { ---------------------------------------------------------------------------
    TLazDroidSwitch — Chave de alternância (Toggle Switch) estilo Material/iOS
    --------------------------------------------------------------------------- }
  TLazDroidSwitch = class(TGraphicControl)
  private
    FChecked: Boolean;
    FOnColor: TColor;
    FOffColor: TColor;
    FThumbColor: TColor;
    FOnChange: TNotifyEvent;
    procedure SetChecked(const AValue: Boolean);
  protected
    procedure Paint; override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Checked: Boolean read FChecked write SetChecked default False;
    property OnColor: TColor read FOnColor write FOnColor default $00D97706;
    property OffColor: TColor read FOffColor write FOffColor default $00E5E7EB;
    property ThumbColor: TColor read FThumbColor write FThumbColor default clWhite;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Enabled;
    property Visible;
    property Align;
    property Anchors;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidActivityIndicator — Indicador circular animado de carregamento
    --------------------------------------------------------------------------- }
  TLazDroidActivityIndicator = class(TGraphicControl)
  private
    FActive: Boolean;
    FColor: TColor;
    FSpeed: Integer;
    FStep: Integer;
    FTimer: TTimer;
    procedure SetActive(const AValue: Boolean);
    procedure TimerTick(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Active: Boolean read FActive write SetActive default True;
    property Color: TColor read FColor write FColor default $00D97706;
    property Speed: Integer read FSpeed write FSpeed default 100;
    property Enabled;
    property Visible;
    property Align;
    property Anchors;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidFAB — Botão de Ação Flutuante (Floating Action Button) circular
    --------------------------------------------------------------------------- }
  TLazDroidFAB = class(TCustomControl)
  private
    FIcon: TLazDroidActionIcon;
    FButtonColor: TColor;
    FIconColor: TColor;
    FIsPressed: Boolean;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Icon: TLazDroidActionIcon read FIcon write FIcon default aiPlus;
    property ButtonColor: TColor read FButtonColor write FButtonColor default $00D97706;
    property IconColor: TColor read FIconColor write FIconColor default clWhite;
    property Enabled;
    property Visible;
    property Align;
    property Anchors;
    property OnClick;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidLayout — Contêiner de auto-organização flexível (Stack Layout)
    --------------------------------------------------------------------------- }
  TLazDroidLayoutDirection = (ldVertical, ldHorizontal);

  TLazDroidLayout = class(TCustomControl)
  private
    FDirection: TLazDroidLayoutDirection;
    FSpacing: Integer;
    FAutoArrange: Boolean;
    FArranging: Boolean;
    procedure SetDirection(const AValue: TLazDroidLayoutDirection);
    procedure SetSpacing(const AValue: Integer);
    procedure SetAutoArrange(const AValue: Boolean);
    procedure ArrangeControls;
  protected
    procedure Resize; override;
    procedure Loaded; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Direction: TLazDroidLayoutDirection read FDirection write SetDirection default ldVertical;
    property Spacing: Integer read FSpacing write SetSpacing default 12;
    property AutoArrange: Boolean read FAutoArrange write SetAutoArrange default True;
    property Align;
    property Anchors;
    property Color default clNone;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidDatePicker — Campo seletor de data touch com calendário integrado
    --------------------------------------------------------------------------- }
  TLazDroidDatePicker = class(TCustomControl)
  private
    FDate: TDateTime;
    FDateFormat: string;
    FLabelCaption: string;
    FPlaceholder: string;
    FBorderColor: TColor;
    FAccentColor: TColor;
    FCornerRadius: Integer;
    FOnChange: TNotifyEvent;
    procedure SetDate(const AValue: TDateTime);
    procedure SetDateFormat(const AValue: string);
    procedure SetLabelCaption(const AValue: string);
  protected
    procedure Paint; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    function OpenPicker: Boolean;
  published
    property Date: TDateTime read FDate write SetDate;
    property DateFormat: string read FDateFormat write SetDateFormat;
    property LabelCaption: string read FLabelCaption write SetLabelCaption;
    property Placeholder: string read FPlaceholder write FPlaceholder;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00D0D0D0;
    property AccentColor: TColor read FAccentColor write FAccentColor default $00D97706;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 8;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Font;
    property Color default clWhite;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidTimePicker — Campo seletor de hora touch com relógio integrado
    --------------------------------------------------------------------------- }
  TLazDroidTimePicker = class(TCustomControl)
  private
    FTime: TDateTime;
    FTimeFormat: string;
    FLabelCaption: string;
    FPlaceholder: string;
    FBorderColor: TColor;
    FAccentColor: TColor;
    FCornerRadius: Integer;
    FOnChange: TNotifyEvent;
    procedure SetTime(const AValue: TDateTime);
    procedure SetTimeFormat(const AValue: string);
    procedure SetLabelCaption(const AValue: string);
  protected
    procedure Paint; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    function OpenPicker: Boolean;
  published
    property Time: TDateTime read FTime write SetTime;
    property TimeFormat: string read FTimeFormat write SetTimeFormat;
    property LabelCaption: string read FLabelCaption write SetLabelCaption;
    property Placeholder: string read FPlaceholder write FPlaceholder;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00D0D0D0;
    property AccentColor: TColor read FAccentColor write FAccentColor default $00D97706;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 8;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Font;
    property Color default clWhite;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidProgressBar — Barra de progresso mobile com cantos arredondados
    --------------------------------------------------------------------------- }
  TLazDroidProgressBar = class(TGraphicControl)
  private
    FMin: Integer;
    FMax: Integer;
    FPosition: Integer;
    FBarColor: TColor;
    FTrackColor: TColor;
    FCornerRadius: Integer;
    FShowPercentage: Boolean;
    procedure SetMin(const AValue: Integer);
    procedure SetMax(const AValue: Integer);
    procedure SetPosition(const AValue: Integer);
    procedure SetBarColor(const AValue: TColor);
    procedure SetTrackColor(const AValue: TColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetShowPercentage(const AValue: Boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Min: Integer read FMin write SetMin default 0;
    property Max: Integer read FMax write SetMax default 100;
    property Position: Integer read FPosition write SetPosition default 30;
    property BarColor: TColor read FBarColor write SetBarColor default $00D97706;
    property TrackColor: TColor read FTrackColor write SetTrackColor default $00E5E7EB;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 6;
    property ShowPercentage: Boolean read FShowPercentage write SetShowPercentage default False;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property Font;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidSlider — Barra de rolagem/Seekbar touch com indicador arrastável
    --------------------------------------------------------------------------- }
  TLazDroidSlider = class(TCustomControl)
  private
    FMin: Integer;
    FMax: Integer;
    FPosition: Integer;
    FActiveTrackColor: TColor;
    FInactiveTrackColor: TColor;
    FThumbColor: TColor;
    FThumbRadius: Integer;
    FIsDragging: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetMin(const AValue: Integer);
    procedure SetMax(const AValue: Integer);
    procedure SetPosition(const AValue: Integer);
    procedure UpdatePositionFromX(X: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Min: Integer read FMin write SetMin default 0;
    property Max: Integer read FMax write SetMax default 100;
    property Position: Integer read FPosition write SetPosition default 50;
    property ActiveTrackColor: TColor read FActiveTrackColor write FActiveTrackColor default $00D97706;
    property InactiveTrackColor: TColor read FInactiveTrackColor write FInactiveTrackColor default $00E5E7EB;
    property ThumbColor: TColor read FThumbColor write FThumbColor default $00D97706;
    property ThumbRadius: Integer read FThumbRadius write FThumbRadius default 9;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidSegmentedControl — Abas/Filtros estilo pílula (Pills)
    --------------------------------------------------------------------------- }
  TLazDroidSegmentedControl = class(TCustomControl)
  private
    FItems: TStrings;
    FItemIndex: Integer;
    FActiveColor: TColor;
    FActiveTextColor: TColor;
    FInactiveColor: TColor;
    FInactiveTextColor: TColor;
    FCornerRadius: Integer;
    FOnChange: TNotifyEvent;
    procedure SetItems(const AValue: TStrings);
    procedure SetItemIndex(const AValue: Integer);
    procedure ItemsChanged(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TStrings read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default 0;
    property ActiveColor: TColor read FActiveColor write FActiveColor default $00D97706;
    property ActiveTextColor: TColor read FActiveTextColor write FActiveTextColor default clWhite;
    property InactiveColor: TColor read FInactiveColor write FInactiveColor default $00F1F5F9;
    property InactiveTextColor: TColor read FInactiveTextColor write FInactiveTextColor default $00475569;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 8;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Font;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidCheckBox — CheckBox touch-friendly com área de toque ampla
    --------------------------------------------------------------------------- }
  TLazDroidCheckBox = class(TCustomControl)
  private
    FChecked: Boolean;
    FCaption: string;
    FBoxColor: TColor;
    FCheckColor: TColor;
    FBorderColor: TColor;
    FCornerRadius: Integer;
    FOnChange: TNotifyEvent;
    procedure SetChecked(const AValue: Boolean);
    procedure SetCaption(const AValue: string);
  protected
    procedure Paint; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Checked: Boolean read FChecked write SetChecked default False;
    property Caption: string read FCaption write SetCaption;
    property BoxColor: TColor read FBoxColor write FBoxColor default $00D97706;
    property CheckColor: TColor read FCheckColor write FCheckColor default clWhite;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00CBD5E1;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 6;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Font;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidRatingBar — Barra de avaliação por estrelas (Star Rating)
    --------------------------------------------------------------------------- }
  TLazDroidRatingBar = class(TCustomControl)
  private
    FRating: Integer;
    FStarCount: Integer;
    FActiveColor: TColor;
    FInactiveColor: TColor;
    FStarSize: Integer;
    FOnChange: TNotifyEvent;
    procedure SetRating(const AValue: Integer);
    procedure SetStarCount(const AValue: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Rating: Integer read FRating write SetRating default 0;
    property StarCount: Integer read FStarCount write SetStarCount default 5;
    property ActiveColor: TColor read FActiveColor write FActiveColor default $0000C0FF;
    property InactiveColor: TColor read FInactiveColor write FInactiveColor default $00CBD5E1;
    property StarSize: Integer read FStarSize write FStarSize default 12;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidSearchBar — Barra de pesquisa touch com botão limpar integrado
    --------------------------------------------------------------------------- }
  TLazDroidSearchBar = class(TCustomControl)
  private
    FText: string;
    FPlaceholder: string;
    FSearchColor: TColor;
    FBorderColor: TColor;
    FCornerRadius: Integer;
    FAutoSearch: Boolean;
    FOnSearch: TLazDroidSearchEvent;
    FIsFocused: Boolean;
    procedure SetText(const AValue: string);
    function GetClearRect: TRect;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure UTF8KeyPress(var UTF8Key: TUTF8Char); override;
    procedure DoEnter; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear;
  published
    property Text: string read FText write SetText;
    property Placeholder: string read FPlaceholder write FPlaceholder;
    property SearchColor: TColor read FSearchColor write FSearchColor default $00D97706;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00CBD5E1;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 18;
    property AutoSearch: Boolean read FAutoSearch write FAutoSearch default True;
    property OnSearch: TLazDroidSearchEvent read FOnSearch write FOnSearch;
    property Color default clWhite;
    property Font;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidChipGroup — Barra de etiquetas/chips filtráveis touch
    --------------------------------------------------------------------------- }
  TLazDroidChipGroup = class(TCustomControl)
  private
    FItems: TStrings;
    FItemIndex: Integer;
    FMultiSelect: Boolean;
    FSelectedMask: Cardinal;
    FActiveColor: TColor;
    FActiveTextColor: TColor;
    FInactiveColor: TColor;
    FInactiveTextColor: TColor;
    FCornerRadius: Integer;
    FOnChange: TNotifyEvent;
    procedure SetItems(const AValue: TStrings);
    procedure SetItemIndex(const AValue: Integer);
    procedure ItemsChanged(Sender: TObject);
    function IsSelected(Index: Integer): Boolean;
    procedure ToggleSelected(Index: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Selected[Index: Integer]: Boolean read IsSelected;
  published
    property Items: TStrings read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property MultiSelect: Boolean read FMultiSelect write FMultiSelect default False;
    property ActiveColor: TColor read FActiveColor write FActiveColor default $00D97706;
    property ActiveTextColor: TColor read FActiveTextColor write FActiveTextColor default clWhite;
    property InactiveColor: TColor read FInactiveColor write FInactiveColor default $00F1F5F9;
    property InactiveTextColor: TColor read FInactiveTextColor write FInactiveTextColor default $00475569;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 14;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Font;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidRadioGroup — Grupo de seleção única com alvo de toque ampliado
    --------------------------------------------------------------------------- }
  TLazDroidRadioGroup = class(TCustomControl)
  private
    FItems: TStrings;
    FItemIndex: Integer;
    FItemHeight: Integer;
    FActiveColor: TColor;
    FInactiveColor: TColor;
    FOnChange: TNotifyEvent;
    procedure SetItems(const AValue: TStrings);
    procedure SetItemIndex(const AValue: Integer);
    procedure ItemsChanged(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Items: TStrings read FItems write SetItems;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default 0;
    property ItemHeight: Integer read FItemHeight write FItemHeight default 42;
    property ActiveColor: TColor read FActiveColor write FActiveColor default $00D97706;
    property InactiveColor: TColor read FInactiveColor write FInactiveColor default $0094A3B8;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Font;
    property Color default clWhite;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidOtpBox — Campo para PIN / Token SMS / 2FA com caixas individuais
    --------------------------------------------------------------------------- }
  TLazDroidOtpBox = class(TCustomControl)
  private
    FCode: string;
    FCodeLength: Integer;
    FBoxSize: Integer;
    FBoxSpacing: Integer;
    FBorderColor: TColor;
    FFocusedColor: TColor;
    FCornerRadius: Integer;
    FIsPassword: Boolean;
    FIsFocused: Boolean;
    FOnChange: TNotifyEvent;
    FOnComplete: TNotifyEvent;
    procedure SetCode(const AValue: string);
    procedure SetCodeLength(const AValue: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure UTF8KeyPress(var UTF8Key: TUTF8Char); override;
    procedure DoEnter; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear;
  published
    property Code: string read FCode write SetCode;
    property CodeLength: Integer read FCodeLength write SetCodeLength default 4;
    property BoxSize: Integer read FBoxSize write FBoxSize default 48;
    property BoxSpacing: Integer read FBoxSpacing write FBoxSpacing default 10;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00CBD5E1;
    property FocusedColor: TColor read FFocusedColor write FFocusedColor default $00D97706;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 8;
    property IsPassword: Boolean read FIsPassword write FIsPassword default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnComplete: TNotifyEvent read FOnComplete write FOnComplete;
    property Font;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidSignaturePad — Coletor de assinatura digital touch
    --------------------------------------------------------------------------- }
  TLazDroidSignaturePad = class(TCustomControl)
  private
    FBuffer: TBitmap;
    FPenColor: TColor;
    FPenWidth: Integer;
    FBorderColor: TColor;
    FCornerRadius: Integer;
    FWatermarkText: string;
    FIsDrawing: Boolean;
    FLastPoint: TPoint;
    FIsSigned: Boolean;
    FOnSigned: TNotifyEvent;
    procedure EnsureBuffer;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure SaveToFile(const AFileName: string);
    procedure SaveToStream(AStream: TStream);
    property IsSigned: Boolean read FIsSigned;
  published
    property PenColor: TColor read FPenColor write FPenColor default clBlack;
    property PenWidth: Integer read FPenWidth write FPenWidth default 3;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00CBD5E1;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 8;
    property WatermarkText: string read FWatermarkText write FWatermarkText;
    property OnSigned: TNotifyEvent read FOnSigned write FOnSigned;
    property Color default clWhite;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidKeypad — Teclado numérico touch integrado para PDV / PIN / Caixas
    --------------------------------------------------------------------------- }
  TLazDroidKeypad = class(TCustomControl)
  private
    FTargetEdit: TLazDroidEdit;
    FValue: string;
    FShowDoubleZero: Boolean;
    FButtonColor: TColor;
    FActionColor: TColor;
    FTextColor: TColor;
    FCornerRadius: Integer;
    FOnKeyPress: TLazDroidKeyPressEvent;
    FOnEnter: TNotifyEvent;
    function GetKeyAt(X, Y: Integer): string;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property TargetEdit: TLazDroidEdit read FTargetEdit write FTargetEdit;
    property Value: string read FValue write FValue;
    property ShowDoubleZero: Boolean read FShowDoubleZero write FShowDoubleZero default True;
    property ButtonColor: TColor read FButtonColor write FButtonColor default $00F8FAFC;
    property ActionColor: TColor read FActionColor write FActionColor default $00D97706;
    property TextColor: TColor read FTextColor write FTextColor default $001E293B;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 8;
    property OnKeyPress: TLazDroidKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
    property Font;
    property Color default $00F1F5F9;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidMetricCard — Card de indicador / KPI com tendência para dashboards
    --------------------------------------------------------------------------- }
  TLazDroidMetricCard = class(TCustomControl)
  private
    FTitle: string;
    FValue: string;
    FDeltaText: string;
    FDeltaIsPositive: Boolean;
    FSubtitle: string;
    FCardColor: TColor;
    FBorderColor: TColor;
    FCornerRadius: Integer;
    FIcon: TLazDroidActionIcon;
    FIconColor: TColor;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Title: string read FTitle write FTitle;
    property Value: string read FValue write FValue;
    property DeltaText: string read FDeltaText write FDeltaText;
    property DeltaIsPositive: Boolean read FDeltaIsPositive write FDeltaIsPositive default True;
    property Subtitle: string read FSubtitle write FSubtitle;
    property CardColor: TColor read FCardColor write FCardColor default clWhite;
    property BorderColor: TColor read FBorderColor write FBorderColor default $00E2E8F0;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 12;
    property Icon: TLazDroidActionIcon read FIcon write FIcon default aiTrendingUp;
    property IconColor: TColor read FIconColor write FIconColor default $00D97706;
    property Font;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidBottomSheet — Gaveta deslizante inferior / painel modal touch
    --------------------------------------------------------------------------- }
  TLazDroidBottomSheet = class(TCustomControl)
  private
    FTitle: string;
    FCornerRadius: Integer;
    FHeaderColor: TColor;
    FIsOpen: Boolean;
    FOnClose: TNotifyEvent;
    procedure SetIsOpen(const AValue: Boolean);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure OpenSheet;
    procedure CloseSheet;
  published
    property Title: string read FTitle write FTitle;
    property CornerRadius: Integer read FCornerRadius write FCornerRadius default 16;
    property HeaderColor: TColor read FHeaderColor write FHeaderColor default $00F8FAFC;
    property IsOpen: Boolean read FIsOpen write SetIsOpen default True;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property Color default clWhite;
    property Font;
    property Align default alBottom;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidSpeedDial — Botão FAB expansível em leque com sub-ações
    --------------------------------------------------------------------------- }
  TLazDroidSpeedDial = class(TCustomControl)
  private
    FItems: TStrings;
    FIsOpen: Boolean;
    FButtonColor: TColor;
    FIconColor: TColor;
    FSubButtonColor: TColor;
    FOnItemClick: TLazDroidItemClickEvent;
    procedure SetItems(const AValue: TStrings);
    procedure SetIsOpen(const AValue: Boolean);
    function GetSubButtonRect(Index: Integer): TRect;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Toggle;
  published
    property Items: TStrings read FItems write SetItems;
    property IsOpen: Boolean read FIsOpen write SetIsOpen default False;
    property ButtonColor: TColor read FButtonColor write FButtonColor default $00D97706;
    property IconColor: TColor read FIconColor write FIconColor default clWhite;
    property SubButtonColor: TColor read FSubButtonColor write FSubButtonColor default $000284C7;
    property OnItemClick: TLazDroidItemClickEvent read FOnItemClick write FOnItemClick;
    property Font;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidSectionHeader — Divisor de seções com título estilo Android Settings
    --------------------------------------------------------------------------- }
  TLazDroidSectionHeader = class(TGraphicControl)
  private
    FCaption: string;
    FLineColor: TColor;
    FTextColor: TColor;
    FShowLine: Boolean;
    procedure SetCaption(const AValue: string);
    procedure SetLineColor(const AValue: TColor);
    procedure SetTextColor(const AValue: TColor);
    procedure SetShowLine(const AValue: Boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Caption: string read FCaption write SetCaption;
    property LineColor: TColor read FLineColor write SetLineColor default $00E2E8F0;
    property TextColor: TColor read FTextColor write SetTextColor default $0064748B;
    property ShowLine: Boolean read FShowLine write SetShowLine default True;
    property Font;
    property Align default alTop;
    property Anchors;
    property Enabled;
    property Visible;
  end;

  { ---------------------------------------------------------------------------
    TLazDroidAvatar — Foto de perfil circular com iniciais automáticas e status
    --------------------------------------------------------------------------- }
  TLazDroidAvatar = class(TCustomControl)
  private
    FFullName: string;
    FAvatarColor: TColor;
    FTextColor: TColor;
    FShowStatus: Boolean;
    FIsOnline: Boolean;
    procedure SetFullName(const AValue: string);
    function GetInitials: string;
    function GenerateAvatarColor(const AName: string): TColor;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FullName: string read FFullName write SetFullName;
    property AvatarColor: TColor read FAvatarColor write FAvatarColor default clNone;
    property TextColor: TColor read FTextColor write FTextColor default clWhite;
    property ShowStatus: Boolean read FShowStatus write FShowStatus default False;
    property IsOnline: Boolean read FIsOnline write FIsOnline default True;
    property Font;
    property Align;
    property Anchors;
    property Enabled;
    property Visible;
    property OnClick;
  end;

procedure Register;

implementation

{ Funções utilitárias de densidade e escala mobile (DPI/DP) }
function GetMobileScale(AControl: TControl = nil): Double;
var
  W: Integer;
begin
  Result := 1.0;
  W := Screen.Width;
  if Assigned(AControl) then
  begin
    if Assigned(AControl.Parent) then
    begin
      if AControl.Parent is TCustomForm then
        W := TCustomForm(AControl.Parent).ClientWidth
      else
        W := AControl.Parent.ClientWidth;
    end
    else if AControl is TCustomForm then
      W := TCustomForm(AControl).ClientWidth;
  end;

  // No Android, a largura base de design é 360dp.
  // 1080 / 360 = 3.0x; 720 / 360 = 2.0x; 1440 / 360 = 4.0x
  if W >= 600 then
    Result := W / 360.0
  else if Screen.PixelsPerInch > 120 then
    Result := Screen.PixelsPerInch / 120.0
  else
    Result := 1.0;

  if Result < 1.0 then Result := 1.0;
end;

function MobileDP(const AValue: Integer; AControl: TControl = nil): Integer;
begin
  Result := Round(AValue * GetMobileScale(AControl));
end;

function MobileSP(const AValue: Integer; AControl: TControl = nil): Integer;
begin
  Result := Round(AValue * GetMobileScale(AControl));
end;

procedure AdaptMobileFormLayout(AForm: TCustomForm);
var
  TargetDPI: Integer;
  ScaleFactor: Double;
begin
  if not Assigned(AForm) then Exit;
  if AForm.Tag = 9999 then Exit;
  AForm.Tag := 9999;

  // Calcula a taxa de escala relativa à densidade base móvel (160 DPI ou 360dp)
  ScaleFactor := 1.0;
  if Screen.Width >= 480 then
    ScaleFactor := Screen.Width / 360.0
  else if Screen.PixelsPerInch > 120 then
    ScaleFactor := Screen.PixelsPerInch / 120.0;

  if ScaleFactor > 1.05 then
  begin
    TargetDPI := Round(AForm.DesignTimePPI * ScaleFactor);
    AForm.AutoAdjustLayout(lapAutoAdjustWithoutHorizontalScrolling,
      AForm.DesignTimePPI, TargetDPI, AForm.ClientWidth, Screen.Width);
  end;
end;

{ Rotina auxiliar de desenho de estrela de 5 pontas para avaliação }
procedure DrawMobileStar(Canvas: TCanvas; Center: TPoint; Radius: Integer; Color: TColor; Fill: Boolean);
var
  Pts: array[0..9] of TPoint;
  I: Integer;
  Angle, R: Double;
begin
  for I := 0 to 9 do
  begin
    Angle := -Pi / 2 + (I * Pi / 5);
    if (I mod 2 = 0) then
      R := Radius
    else
      R := Radius * 0.42;
    Pts[I] := Point(Center.X + Round(R * Cos(Angle)), Center.Y + Round(R * Sin(Angle)));
  end;

  Canvas.Pen.Color := Color;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  if Fill then
  begin
    Canvas.Brush.Color := Color;
    Canvas.Brush.Style := bsSolid;
    Canvas.Polygon(Pts);
  end
  else
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Polyline(Pts);
    Canvas.Line(Pts[9], Pts[0]);
  end;
end;

{ Rotina auxiliar de desenho de ícones geométricos limpos }
procedure DrawMobileIcon(Canvas: TCanvas; Icon: TLazDroidActionIcon; const R: TRect; Color: TColor; const AScale: Double = 1.0);
var
  cx, cy, s, penW: Integer;
begin
  if Icon = aiNone then Exit;
  cx := (R.Left + R.Right) div 2;
  cy := (R.Top + R.Bottom) div 2;

  // O tamanho do ícone adapta-se perfeitamente ao retângulo delimitador R
  s := (R.Bottom - R.Top) div 4;
  if s < 6 then s := 6;

  penW := (R.Bottom - R.Top) div 14;
  if penW < 2 then penW := 2;

  Canvas.Pen.Color := Color;
  Canvas.Pen.Width := penW;
  Canvas.Pen.Style := psSolid;
  Canvas.Brush.Style := bsClear;

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
      Canvas.Line(cx - s, cy - (s * 3 div 4), cx + s, cy - (s * 3 div 4));
      Canvas.Line(cx - s, cy, cx + s, cy);
      Canvas.Line(cx - s, cy + (s * 3 div 4), cx + s, cy + (s * 3 div 4));
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
      Canvas.Ellipse(cx - s, cy - s, cx + s div 3, cy + s div 3);
      Canvas.Line(cx + s div 4, cy + s div 4, cx + s, cy + s);
    end;
    aiFilter:
    begin
      Canvas.Line(cx - s, cy - s + 2, cx + s, cy - s + 2);
      Canvas.Line(cx - s + 3, cy, cx + s - 3, cy);
      Canvas.Line(cx - s + 5, cy + s - 2, cx + s - 5, cy + s - 2);
    end;
    aiCalendar:
    begin
      Canvas.RoundRect(cx - s, cy - s + 2, cx + s, cy + s, 3, 3);
      Canvas.Line(cx - s, cy - s div 3, cx + s, cy - s div 3);
      Canvas.Line(cx - s div 2, cy - s - 1, cx - s div 2, cy - s + 2);
      Canvas.Line(cx + s div 2, cy - s - 1, cx + s div 2, cy - s + 2);
      Canvas.Pixels[cx - s div 2, cy + s div 3] := Color;
      Canvas.Pixels[cx, cy + s div 3] := Color;
      Canvas.Pixels[cx + s div 2, cy + s div 3] := Color;
    end;
    aiClock:
    begin
      Canvas.Ellipse(cx - s, cy - s, cx + s, cy + s);
      Canvas.Line(cx, cy, cx, cy - (s * 3 div 5));
      Canvas.Line(cx, cy, cx + (s div 2), cy);
      Canvas.Pixels[cx, cy] := Color;
    end;
    aiStar:
    begin
      DrawMobileStar(Canvas, Point(cx, cy), s, Color, True);
    end;
    aiDollar:
    begin
      Canvas.Line(cx, cy - s - 1, cx, cy + s + 1);
      Canvas.Line(cx + s div 2, cy - s + 1, cx - s div 2, cy - s + 1);
      Canvas.Line(cx - s div 2, cy - s + 1, cx - s div 2, cy);
      Canvas.Line(cx - s div 2, cy, cx + s div 2, cy);
      Canvas.Line(cx + s div 2, cy, cx + s div 2, cy + s - 1);
      Canvas.Line(cx + s div 2, cy + s - 1, cx - s div 2, cy + s - 1);
    end;
    aiTrendingUp:
    begin
      Canvas.Line(cx - s, cy + s div 2, cx - s div 4, cy);
      Canvas.Line(cx - s div 4, cy, cx + s div 4, cy + s div 3);
      Canvas.Line(cx + s div 4, cy + s div 3, cx + s, cy - s div 2);
      Canvas.Line(cx + s, cy - s div 2, cx + s div 2, cy - s div 2);
      Canvas.Line(cx + s, cy - s div 2, cx + s, cy);
    end;
    aiTrendingDown:
    begin
      Canvas.Line(cx - s, cy - s div 2, cx - s div 4, cy);
      Canvas.Line(cx - s div 4, cy, cx + s div 4, cy - s div 3);
      Canvas.Line(cx + s div 4, cy - s div 3, cx + s, cy + s div 2);
      Canvas.Line(cx + s, cy + s div 2, cx + s div 2, cy + s div 2);
      Canvas.Line(cx + s, cy + s div 2, cx + s, cy);
    end;
    aiUser:
    begin
      Canvas.Ellipse(cx - s div 2, cy - s, cx + s div 2, cy);
      Canvas.Arc(cx - s, cy - s div 4, cx + s, cy + s + 2, cx + s, cy + s div 2, cx - s, cy + s div 2);
    end;
    aiLock:
    begin
      Canvas.RoundRect(cx - (s * 3 div 4), cy - s div 4, cx + (s * 3 div 4), cy + s, 2, 2);
      Canvas.Arc(cx - s div 2, cy - s, cx + s div 2, cy, cx - s div 2, cy - s div 4, cx + s div 2, cy - s div 4);
    end;
    aiEdit:
    begin
      Canvas.Line(cx - s, cy + s, cx - s div 2, cy + s);
      Canvas.Line(cx - s, cy + s, cx - s, cy + s div 2);
      Canvas.Line(cx - s, cy + s div 2, cx + s div 2, cy - s);
      Canvas.Line(cx + s div 2, cy - s, cx + s, cy - s div 2);
      Canvas.Line(cx + s, cy - s div 2, cx - s div 2, cy + s);
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
var
  BtnSz, Pad: Integer;
begin
  BtnSz := Round(Height * 0.72);
  Pad := (Height - BtnSz) div 2;
  Result := Rect(Pad, Pad, Pad + BtnSz, Pad + BtnSz);
end;

function TLazDroidAppBar.GetActionRect: TRect;
var
  BtnSz, Pad: Integer;
begin
  BtnSz := Round(Height * 0.72);
  Pad := (Height - BtnSz) div 2;
  Result := Rect(Width - Pad - BtnSz, Pad, Width - Pad, Pad + BtnSz);
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
      Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Height div 8, Height div 8);
    end;
    DrawMobileIcon(Canvas, aiBack, R, FTitleColor);
  end;

  if FActionIcon <> aiNone then
  begin
    R := GetActionRect;
    if FActionHover then
    begin
      Canvas.Brush.Color := TColor($003A2A20);
      Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Height div 8, Height div 8);
    end;
    DrawMobileIcon(Canvas, FActionIcon, R, FTitleColor);
  end;

  TextLeft := Round(Height * 0.3);
  if FShowBack then TextLeft := Height + (Height div 8);

  Canvas.Brush.Style := bsClear;
  Canvas.Font := Self.Font;
  Canvas.Font.Color := FTitleColor;

  if FSubtitle <> '' then
  begin
    Canvas.TextOut(TextLeft, Round(Height * 0.16), FTitle);
    Canvas.Font.Size := Max(8, Round(Self.Font.Size * 0.72));
    Canvas.Font.Style := [];
    Canvas.Font.Color := FSubtitleColor;
    Canvas.TextOut(TextLeft, Round(Height * 0.54), FSubtitle);
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
  BgCol, ParentBg: TColor;
  tx, ty: Integer;
  R: TRect;
  Radius: Integer;
  IconSz, IconPad: Integer;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  BgCol := GetBaseColor;
  if FIsPressed then
    BgCol := TColor(Integer(BgCol) - $00151515);

  R := ClientRect;
  Canvas.Brush.Color := BgCol;
  if (FVariant = bvOutline) then
  begin
    Canvas.Pen.Color := GetTextColor;
    Canvas.Pen.Width := Max(2, Height div 20);
  end
  else
  begin
    Canvas.Pen.Color := BgCol;
    Canvas.Pen.Width := 1;
  end;

  Radius := Max(6, Round(FCornerRadius * (Height / 48.0)));
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, Radius, Radius);

  if FIcon <> aiNone then
  begin
    IconSz := Round(Height * 0.55);
    IconPad := (Height - IconSz) div 2;
    DrawMobileIcon(Canvas, FIcon, Rect(R.Left + IconPad, IconPad, R.Left + IconPad + IconSz, IconPad + IconSz), GetTextColor);
  end;

  Canvas.Brush.Style := bsClear;
  Canvas.Font := Self.Font;
  Canvas.Font.Color := GetTextColor;
  if not Enabled then Canvas.Font.Color := clGray;

  tx := (Width - Canvas.TextWidth(FCaption)) div 2;
  if FIcon <> aiNone then tx := tx + (Height div 4);
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
  ControlStyle := ControlStyle + [csAcceptsControls];
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

{ TLazDroidListItem }

constructor TLazDroidListItem.Create(ACollection: TCollection);
begin
  inherited Create(ACollection);
  FPicture := TPicture.Create;
  FPicture.OnChange := @PictureChanged;
  FImageIndex := -1;
  FIcon := aiNone;
  FIconColor := clWhite;
  FIconBgColor := $00D97706; // Amber / Primary
  FImageShape := isRoundedSquare;
end;

destructor TLazDroidListItem.Destroy;
begin
  FPicture.Free;
  inherited Destroy;
end;

procedure TLazDroidListItem.Assign(Source: TPersistent);
begin
  if Source is TLazDroidListItem then
  begin
    FTitle := TLazDroidListItem(Source).Title;
    FSubtitle := TLazDroidListItem(Source).Subtitle;
    FBadge := TLazDroidListItem(Source).Badge;
    FValue := TLazDroidListItem(Source).Value;
    FTag := TLazDroidListItem(Source).Tag;
    FPicture.Assign(TLazDroidListItem(Source).Picture);
    FImageIndex := TLazDroidListItem(Source).ImageIndex;
    FIcon := TLazDroidListItem(Source).Icon;
    FIconColor := TLazDroidListItem(Source).IconColor;
    FIconBgColor := TLazDroidListItem(Source).IconBgColor;
    FImageShape := TLazDroidListItem(Source).ImageShape;
    Changed(False);
  end
  else
    inherited Assign(Source);
end;

procedure TLazDroidListItem.PictureChanged(Sender: TObject);
begin
  Changed(False);
end;

function TLazDroidListItem.HasImage: Boolean;
begin
  Result := (Assigned(FPicture) and Assigned(FPicture.Graphic) and (not FPicture.Graphic.Empty)) or
            (FImageIndex >= 0) or
            (FIcon <> aiNone);
end;

procedure TLazDroidListItem.SetTitle(const AValue: string);
begin
  if FTitle <> AValue then
  begin
    FTitle := AValue;
    Changed(False);
  end;
end;

procedure TLazDroidListItem.SetSubtitle(const AValue: string);
begin
  if FSubtitle <> AValue then
  begin
    FSubtitle := AValue;
    Changed(False);
  end;
end;

procedure TLazDroidListItem.SetBadge(const AValue: string);
begin
  if FBadge <> AValue then
  begin
    FBadge := AValue;
    Changed(False);
  end;
end;

procedure TLazDroidListItem.SetValue(const AValue: string);
begin
  if FValue <> AValue then
  begin
    FValue := AValue;
    Changed(False);
  end;
end;

procedure TLazDroidListItem.SetPicture(AValue: TPicture);
begin
  FPicture.Assign(AValue);
  Changed(False);
end;

procedure TLazDroidListItem.SetImageIndex(const AValue: Integer);
begin
  if FImageIndex <> AValue then
  begin
    FImageIndex := AValue;
    Changed(False);
  end;
end;

procedure TLazDroidListItem.SetIcon(const AValue: TLazDroidActionIcon);
begin
  if FIcon <> AValue then
  begin
    FIcon := AValue;
    Changed(False);
  end;
end;

procedure TLazDroidListItem.SetIconColor(const AValue: TColor);
begin
  if FIconColor <> AValue then
  begin
    FIconColor := AValue;
    Changed(False);
  end;
end;

procedure TLazDroidListItem.SetIconBgColor(const AValue: TColor);
begin
  if FIconBgColor <> AValue then
  begin
    FIconBgColor := AValue;
    Changed(False);
  end;
end;

procedure TLazDroidListItem.SetImageShape(const AValue: TLazDroidImageShape);
begin
  if FImageShape <> AValue then
  begin
    FImageShape := AValue;
    Changed(False);
  end;
end;

{ TLazDroidListItems }

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

{ TLazDroidListView }

constructor TLazDroidListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 300;
  Height := 350;
  FItems := TLazDroidListItems.Create(Self);
  FItemHeight := 64;
  FImageSize := 44;
  FImages := nil;
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

procedure TLazDroidListView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FImages) then
  begin
    FImages := nil;
    Invalidate;
  end;
end;

procedure TLazDroidListView.SetItems(const AValue: TLazDroidListItems);
begin
  FItems.Assign(AValue);
end;

procedure TLazDroidListView.SetImages(const AValue: TCustomImageList);
begin
  if FImages <> AValue then
  begin
    FImages := AValue;
    if Assigned(FImages) then
      FImages.FreeNotification(Self);
    Invalidate;
  end;
end;

procedure TLazDroidListView.SetImageSize(const AValue: Integer);
begin
  if FImageSize <> AValue then
  begin
    FImageSize := AValue;
    Invalidate;
  end;
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

procedure TLazDroidListView.Clear;
begin
  FItems.Clear;
  FSelectedIndex := -1;
  FScrollOffset := 0;
  Invalidate;
end;

function TLazDroidListView.AddItem(const ATitle: string; const ASubtitle: string = ''; const AValue: string = ''): TLazDroidListItem;
begin
  Result := FItems.Add;
  Result.Title := ATitle;
  Result.Subtitle := ASubtitle;
  Result.Value := AValue;
end;

procedure TLazDroidListView.Paint;
var
  i, ItemTop, ItemBottom: Integer;
  R, ImgR, BadgeR: TRect;
  Item: TLazDroidListItem;
  ActualImgSize, ImgLeft, ImgTop, TextLeft, RightBound: Integer;
  HasImg: Boolean;
  ValW, ValTop, ValLeft: Integer;
  BdgW, BdgH, BdgTop, BdgLeft: Integer;
  TitleTop, SubtitleTop: Integer;
  ClipR: HRGN;
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

    Canvas.Pen.Style := psClear;
    Canvas.FillRect(R);

    // Determina se há imagem/ícone configurado
    HasImg := Item.HasImage and (
      (Assigned(Item.Picture.Graphic) and (not Item.Picture.Graphic.Empty)) or
      (Assigned(FImages) and (Item.ImageIndex >= 0) and (Item.ImageIndex < FImages.Count)) or
      (Item.Icon <> aiNone)
    );

    if HasImg then
    begin
      ActualImgSize := FImageSize;
      if ActualImgSize > FItemHeight - 12 then
        ActualImgSize := FItemHeight - 12;
      if ActualImgSize < 16 then
        ActualImgSize := 16;

      ImgLeft := 14;
      ImgTop := ItemTop + (FItemHeight - ActualImgSize) div 2;
      ImgR := Rect(ImgLeft, ImgTop, ImgLeft + ActualImgSize, ImgTop + ActualImgSize);

      // 1. TPicture (PNG, JPG, BMP...)
      if Assigned(Item.Picture.Graphic) and (not Item.Picture.Graphic.Empty) then
      begin
        Canvas.Brush.Color := $00F1F5F9;
        Canvas.Pen.Color := $00E2E8F0;
        Canvas.Pen.Style := psSolid;
        Canvas.Pen.Width := 1;
        case Item.ImageShape of
          isCircle:
          begin
            Canvas.Ellipse(ImgR);
            ClipR := CreateEllipticRgn(ImgR.Left, ImgR.Top, ImgR.Right, ImgR.Bottom);
            SelectClipRgn(Canvas.Handle, ClipR);
            Canvas.StretchDraw(ImgR, Item.Picture.Graphic);
            SelectClipRgn(Canvas.Handle, 0);
            DeleteObject(ClipR);
            Canvas.Brush.Style := bsClear;
            Canvas.Pen.Color := $00CBD5E1;
            Canvas.Ellipse(ImgR);
          end;
          isRoundedSquare:
          begin
            Canvas.RoundRect(ImgR, 14, 14);
            ClipR := CreateRoundRectRgn(ImgR.Left, ImgR.Top, ImgR.Right + 1, ImgR.Bottom + 1, 14, 14);
            SelectClipRgn(Canvas.Handle, ClipR);
            Canvas.StretchDraw(ImgR, Item.Picture.Graphic);
            SelectClipRgn(Canvas.Handle, 0);
            DeleteObject(ClipR);
            Canvas.Brush.Style := bsClear;
            Canvas.Pen.Color := $00CBD5E1;
            Canvas.RoundRect(ImgR, 14, 14);
          end;
          isSquare:
          begin
            Canvas.StretchDraw(ImgR, Item.Picture.Graphic);
            Canvas.Brush.Style := bsClear;
            Canvas.Pen.Color := $00CBD5E1;
            Canvas.Rectangle(ImgR);
          end;
        end;
      end
      // 2. TCustomImageList
      else if Assigned(FImages) and (Item.ImageIndex >= 0) and (Item.ImageIndex < FImages.Count) then
      begin
        if Item.IconBgColor <> clNone then
        begin
          Canvas.Brush.Color := Item.IconBgColor;
          Canvas.Pen.Color := Item.IconBgColor;
          Canvas.Pen.Style := psSolid;
          case Item.ImageShape of
            isCircle: Canvas.Ellipse(ImgR);
            isRoundedSquare: Canvas.RoundRect(ImgR, 14, 14);
            isSquare: Canvas.FillRect(ImgR);
          end;
        end;
        FImages.Draw(Canvas,
          ImgR.Left + (ActualImgSize - FImages.Width) div 2,
          ImgR.Top + (ActualImgSize - FImages.Height) div 2,
          Item.ImageIndex, True);
        Canvas.Brush.Style := bsClear;
        Canvas.Pen.Color := $00E2E8F0;
        Canvas.Pen.Width := 1;
        Canvas.Pen.Style := psSolid;
        case Item.ImageShape of
          isCircle: Canvas.Ellipse(ImgR);
          isRoundedSquare: Canvas.RoundRect(ImgR, 14, 14);
          isSquare: Canvas.Rectangle(ImgR);
        end;
      end
      // 3. Ícone vetorial nativo (TLazDroidActionIcon)
      else if Item.Icon <> aiNone then
      begin
        Canvas.Brush.Color := Item.IconBgColor;
        Canvas.Pen.Color := Item.IconBgColor;
        Canvas.Pen.Style := psSolid;
        case Item.ImageShape of
          isCircle: Canvas.Ellipse(ImgR);
          isRoundedSquare: Canvas.RoundRect(ImgR, 14, 14);
          isSquare: Canvas.FillRect(ImgR);
        end;
        DrawMobileIcon(Canvas, Item.Icon, ImgR, Item.IconColor);
      end;

      TextLeft := ImgR.Right + 12;
    end
    else
      TextLeft := 16;

    // Cálculo da margem direita (Value e Badge)
    RightBound := Width - 16;

    if (Item.Value <> '') and (Item.Badge <> '') then
    begin
      Canvas.Font.Name := 'Segoe UI';
      Canvas.Font.Size := 10;
      Canvas.Font.Style := [fsBold];
      ValW := Canvas.TextWidth(Item.Value);
      ValLeft := Width - 16 - ValW;
      ValTop := ItemTop + 11;
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := $00047857; // Emerald Green
      Canvas.TextOut(ValLeft, ValTop, Item.Value);

      Canvas.Font.Size := 8;
      Canvas.Font.Style := [fsBold];
      BdgW := Canvas.TextWidth(Item.Badge) + 12;
      BdgH := 18;
      BdgLeft := Width - 16 - BdgW;
      BdgTop := ItemTop + 33;
      BadgeR := Rect(BdgLeft, BdgTop, BdgLeft + BdgW, BdgTop + BdgH);
      Canvas.Brush.Color := $00EFF6FF; // Soft Blue
      Canvas.Pen.Color := $0093C5FD;
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Width := 1;
      Canvas.RoundRect(BadgeR, 8, 8);
      Canvas.Font.Color := $001D4ED8;
      Canvas.TextOut(BdgLeft + 6, BdgTop + 2, Item.Badge);

      RightBound := Min(ValLeft, BdgLeft) - 8;
    end
    else if Item.Value <> '' then
    begin
      Canvas.Font.Name := 'Segoe UI';
      Canvas.Font.Size := 11;
      Canvas.Font.Style := [fsBold];
      ValW := Canvas.TextWidth(Item.Value);
      ValLeft := Width - 16 - ValW;
      ValTop := ItemTop + (FItemHeight - Canvas.TextHeight(Item.Value)) div 2;
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := $00047857;
      Canvas.TextOut(ValLeft, ValTop, Item.Value);
      RightBound := ValLeft - 8;
    end
    else if Item.Badge <> '' then
    begin
      Canvas.Font.Name := 'Segoe UI';
      Canvas.Font.Size := 9;
      Canvas.Font.Style := [fsBold];
      BdgW := Canvas.TextWidth(Item.Badge) + 16;
      BdgH := 22;
      BdgLeft := Width - 16 - BdgW;
      BdgTop := ItemTop + (FItemHeight - BdgH) div 2;
      BadgeR := Rect(BdgLeft, BdgTop, BdgLeft + BdgW, BdgTop + BdgH);
      Canvas.Brush.Color := $00EFF6FF;
      Canvas.Pen.Color := $0093C5FD;
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Width := 1;
      Canvas.RoundRect(BadgeR, 10, 10);
      Canvas.Font.Color := $001D4ED8;
      Canvas.TextOut(BdgLeft + 8, BdgTop + 3, Item.Badge);
      RightBound := BdgLeft - 8;
    end;

    // Título e Subtítulo
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Name := 'Segoe UI';
    if Item.Subtitle <> '' then
    begin
      TitleTop := ItemTop + (FItemHeight - 38) div 2;
      SubtitleTop := TitleTop + 20;

      Canvas.Font.Size := 11;
      Canvas.Font.Style := [fsBold];
      Canvas.Font.Color := $00111827; // Slate 900
      Canvas.TextRect(Rect(TextLeft, TitleTop, RightBound, TitleTop + 20), TextLeft, TitleTop, Item.Title);

      Canvas.Font.Size := 9;
      Canvas.Font.Style := [];
      Canvas.Font.Color := $006B7280; // Gray 500
      Canvas.TextRect(Rect(TextLeft, SubtitleTop, RightBound, SubtitleTop + 18), TextLeft, SubtitleTop, Item.Subtitle);
    end
    else
    begin
      TitleTop := ItemTop + (FItemHeight - 20) div 2;
      Canvas.Font.Size := 11;
      Canvas.Font.Style := [fsBold];
      Canvas.Font.Color := $00111827;
      Canvas.TextRect(Rect(TextLeft, TitleTop, RightBound, TitleTop + 20), TextLeft, TitleTop, Item.Title);
    end;

    // Divisor inferior sutil com recuo elegante (inset divider)
    Canvas.Pen.Color := FDividerColor;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 1;
    Canvas.Line(TextLeft, ItemBottom - 1, Width, ItemBottom - 1);
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

{ =============================================================================
  TLazDroidSwitch
  ============================================================================= }

constructor TLazDroidSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 52;
  Height := 30;
  FChecked := False;
  FOnColor := $00D97706;  // Amber / Primary
  FOffColor := $00E5E7EB; // Cool Gray 200
  FThumbColor := clWhite;
end;

procedure TLazDroidSwitch.SetChecked(const AValue: Boolean);
begin
  if FChecked <> AValue then
  begin
    FChecked := AValue;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidSwitch.Click;
begin
  SetChecked(not FChecked);
  inherited Click;
end;

procedure TLazDroidSwitch.Paint;
var
  vDiameter, vLeft, Pad: Integer;
  ParentBg: TColor;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  if FChecked then
    Canvas.Brush.Color := FOnColor
  else
    Canvas.Brush.Color := FOffColor;

  Canvas.Pen.Color := Canvas.Brush.Color;
  Canvas.RoundRect(0, 0, Width, Height, Height, Height);

  Pad := Max(2, Height div 10);
  vDiameter := Height - (Pad * 2);
  if FChecked then
    vLeft := Width - vDiameter - Pad
  else
    vLeft := Pad;

  Canvas.Brush.Color := FThumbColor;
  Canvas.Pen.Color := FThumbColor;
  Canvas.Ellipse(vLeft, Pad, vLeft + vDiameter, Pad + vDiameter);
end;

{ =============================================================================
  TLazDroidActivityIndicator
  ============================================================================= }

constructor TLazDroidActivityIndicator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 36;
  Height := 36;
  FActive := True;
  FColor := $00D97706;
  FSpeed := 100;
  FStep := 0;
  FTimer := TTimer.Create(Self);
  FTimer.Interval := FSpeed;
  FTimer.OnTimer := @TimerTick;
  FTimer.Enabled := FActive and not (csDesigning in ComponentState);
end;

destructor TLazDroidActivityIndicator.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TLazDroidActivityIndicator.SetActive(const AValue: Boolean);
begin
  if FActive <> AValue then
  begin
    FActive := AValue;
    if Assigned(FTimer) then
      FTimer.Enabled := FActive and not (csDesigning in ComponentState);
    Invalidate;
  end;
end;

procedure TLazDroidActivityIndicator.TimerTick(Sender: TObject);
begin
  FStep := (FStep + 1) mod 8;
  Invalidate;
end;

procedure TLazDroidActivityIndicator.Paint;
var
  I, vRadius, vIndex: Integer;
  vCenter: TPoint;
  PenW: Integer;
  ParentBg: TColor;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  vCenter := Point(Width div 2, Height div 2);
  vRadius := Min(Width, Height) div 2;
  vRadius := vRadius - Max(2, vRadius div 6);
  if vRadius < 2 then Exit;

  PenW := Max(2, vRadius div 5);
  Canvas.Pen.Width := PenW;
  Canvas.Brush.Style := bsClear;

  for I := 0 to 7 do
  begin
    vIndex := (I + FStep) mod 8;
    if vIndex < 3 then
      Canvas.Pen.Color := FColor
    else
      Canvas.Pen.Color := $00E5E7EB;

    Canvas.Line(
      vCenter.X + Round(vRadius * Cos(I * Pi / 4) * 0.55),
      vCenter.Y + Round(vRadius * Sin(I * Pi / 4) * 0.55),
      vCenter.X + Round(vRadius * Cos(I * Pi / 4)),
      vCenter.Y + Round(vRadius * Sin(I * Pi / 4))
    );
  end;
end;

{ =============================================================================
  TLazDroidFAB
  ============================================================================= }

constructor TLazDroidFAB.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 56;
  Height := 56;
  FIcon := aiPlus;
  FButtonColor := $00D97706; // Amber
  FIconColor := clWhite;
  FIsPressed := False;
end;

procedure TLazDroidFAB.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FIsPressed := True;
  Invalidate;
end;

procedure TLazDroidFAB.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FIsPressed := False;
  Invalidate;
end;

procedure TLazDroidFAB.Paint;
var
  BgCol, ParentBg: TColor;
  R: TRect;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  BgCol := FButtonColor;
  if FIsPressed then
    BgCol := TColor(Integer(BgCol) - $00151515);

  Canvas.Brush.Color := BgCol;
  Canvas.Pen.Color := BgCol;
  Canvas.Ellipse(0, 0, Width, Height);

  R := Rect(Round(Width * 0.22), Round(Height * 0.22), Round(Width * 0.78), Round(Height * 0.78));
  DrawMobileIcon(Canvas, FIcon, R, FIconColor);
end;

{ =============================================================================
  TLazDroidLayout
  ============================================================================= }

constructor TLazDroidLayout.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls];
  FDirection := ldVertical;
  FSpacing := 12;
  FAutoArrange := True;
  FArranging := False;
  Color := clNone;
  Width := 200;
  Height := 200;
end;

procedure TLazDroidLayout.SetDirection(const AValue: TLazDroidLayoutDirection);
begin
  if FDirection <> AValue then
  begin
    FDirection := AValue;
    ArrangeControls;
  end;
end;

procedure TLazDroidLayout.SetSpacing(const AValue: Integer);
begin
  if FSpacing <> AValue then
  begin
    FSpacing := Max(0, AValue);
    ArrangeControls;
  end;
end;

procedure TLazDroidLayout.SetAutoArrange(const AValue: Boolean);
begin
  if FAutoArrange <> AValue then
  begin
    FAutoArrange := AValue;
    ArrangeControls;
  end;
end;

procedure TLazDroidLayout.ArrangeControls;
var
  I, LPos: Integer;
  C: TControl;
  TargetX, TargetY, TargetW, TargetH: Integer;
begin
  if not FAutoArrange then Exit;
  if csLoading in ComponentState then Exit;
  if FArranging then Exit;

  FArranging := True;
  try
    DisableAlign;
    try
      LPos := FSpacing;
      for I := 0 to ControlCount - 1 do
      begin
        C := Controls[I];
        if not C.Visible then Continue;
        // Controles com alinhamento explícito gerenciado pelo LCL (alTop, alBottom, alClient, etc.)
        // não devem ter Left/Top/Width manipulados pelo layout para evitar loop de ChangeBounds.
        if C.Align <> alNone then Continue;

        if FDirection = ldVertical then
        begin
          TargetX := FSpacing;
          TargetY := LPos;
          // Controles com AutoSize ativo (ex: TLabel, TCheckBox) calculam sua própria largura
          // baseada no texto. Forçar uma largura externa faz o LCL entrar em loop em ChangeBounds.
          if C.AutoSize then
            TargetW := C.Width
          else
            TargetW := Max(10, ClientWidth - (FSpacing * 2));
          TargetH := C.Height;

          if (C.Left <> TargetX) or (C.Top <> TargetY) or (C.Width <> TargetW) or (C.Height <> TargetH) then
            C.SetBounds(TargetX, TargetY, TargetW, TargetH);

          LPos := C.Top + C.Height + FSpacing;
        end
        else
        begin
          TargetX := LPos;
          TargetY := FSpacing;
          TargetW := C.Width;
          if C.AutoSize then
            TargetH := C.Height
          else
            TargetH := Max(10, ClientHeight - (FSpacing * 2));

          if (C.Left <> TargetX) or (C.Top <> TargetY) or (C.Width <> TargetW) or (C.Height <> TargetH) then
            C.SetBounds(TargetX, TargetY, TargetW, TargetH);

          LPos := C.Left + C.Width + FSpacing;
        end;
      end;
    finally
      EnableAlign;
    end;
  finally
    FArranging := False;
  end;
end;

procedure TLazDroidLayout.Resize;
begin
  inherited Resize;
  ArrangeControls;
end;

procedure TLazDroidLayout.Loaded;
begin
  inherited Loaded;
  ArrangeControls;
end;

procedure TLazDroidLayout.Paint;
begin
  inherited Paint;
  if (csDesigning in ComponentState) and (Color = clNone) then
  begin
    Canvas.Pen.Color := $00D0D0D0;
    Canvas.Pen.Style := psDash;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(ClientRect);
  end;
end;

{ =============================================================================
  TLazDroidToast & ShowMobileToast
  ============================================================================= }

type
  TLazDroidToast = class(TPanel)
  private
    FTimer: TTimer;
    procedure TimerTick(Sender: TObject);
  public
    constructor CreateToast(AOwner: TWinControl; const AMsg: string; ADurationMs: Integer);
    destructor Destroy; override;
  end;

constructor TLazDroidToast.CreateToast(AOwner: TWinControl; const AMsg: string; ADurationMs: Integer);
var
  Lbl: TLabel;
  EstW: Integer;
begin
  inherited Create(AOwner);
  Parent := AOwner;
  BevelOuter := bvNone;
  Color := $001F1F1F;
  Height := 44;
  EstW := Max(180, Length(AMsg) * 9 + 48);
  Width := Min(AOwner.ClientWidth - 32, EstW);
  Left := (AOwner.ClientWidth - Width) div 2;
  Top := AOwner.ClientHeight - Height - 32;
  BringToFront;

  Lbl := TLabel.Create(Self);
  Lbl.Parent := Self;
  Lbl.Align := alClient;
  Lbl.Alignment := taCenter;
  Lbl.Layout := tlCenter;
  Lbl.Font.Name := 'Segoe UI';
  Lbl.Font.Size := 10;
  Lbl.Font.Color := clWhite;
  Lbl.Caption := AMsg;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := ADurationMs;
  FTimer.OnTimer := @TimerTick;
  FTimer.Enabled := True;
end;

destructor TLazDroidToast.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TLazDroidToast.TimerTick(Sender: TObject);
begin
  FTimer.Enabled := False;
  Application.ReleaseComponent(Self);
end;

procedure ShowMobileToast(AOwner: TCustomForm; const AMsg: string; ADurationMs: Integer = 2500);
var
  Target: TCustomForm;
begin
  Target := AOwner;
  if Target = nil then Target := Screen.ActiveCustomForm;
  if Target = nil then Target := Application.MainForm;
  if Target = nil then Exit;
  TLazDroidToast.CreateToast(Target, AMsg, ADurationMs);
end;

{ =============================================================================
  TLazDroidDatePickDlg & ShowMobileDatePicker
  ============================================================================= }

type
  TLazDroidDatePickDlg = class(TForm)
  private
    FSelectedDate: TDateTime;
    FViewYear: Word;
    FViewMonth: Word;
    LblYear: TLabel;
    LblDateFull: TLabel;
    LblMonthYear: TLabel;
    PnlGrid: TPanel;
    DayBtns: array[1..31] of TButton;
    procedure UpdateCalendarView;
    procedure PrevMonthClick(Sender: TObject);
    procedure NextMonthClick(Sender: TObject);
    procedure DayClick(Sender: TObject);
    procedure TodayClick(Sender: TObject);
  public
    constructor CreatePicker(AOwner: TComponent; AInitialDate: TDateTime; const ATitle: string);
    property SelectedDate: TDateTime read FSelectedDate;
  end;

constructor TLazDroidDatePickDlg.CreatePicker(AOwner: TComponent; AInitialDate: TDateTime; const ATitle: string);
const
  WeekDays: array[0..6] of string = ('DOM', 'SEG', 'TER', 'QUA', 'QUI', 'SEX', 'SAB');
var
  PnlHeader, PnlNav, PnlWeekdays, PnlActions: TPanel;
  BtnPrev, BtnNext, BtnToday, BtnCancel, BtnOk: TButton;
  WeekdayLbl: TLabel;
  i, DayNum: Integer;
  DummyDay: Word;
begin
  inherited CreateNew(AOwner);
  Caption := ATitle;
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  Width := 330;
  Height := 470;
  Color := clWhite;

  FSelectedDate := AInitialDate;
  DecodeDate(FSelectedDate, FViewYear, FViewMonth, DummyDay);

  // 1. Cabeçalho
  PnlHeader := TPanel.Create(Self);
  PnlHeader.Parent := Self;
  PnlHeader.Align := alTop;
  PnlHeader.Height := 75;
  PnlHeader.BevelOuter := bvNone;
  PnlHeader.Color := $00241A14; // Dark Navy

  LblYear := TLabel.Create(Self);
  LblYear.Parent := PnlHeader;
  LblYear.Left := 18;
  LblYear.Top := 12;
  LblYear.Font.Name := 'Segoe UI';
  LblYear.Font.Size := 9;
  LblYear.Font.Color := $00D0C0B0;

  LblDateFull := TLabel.Create(Self);
  LblDateFull.Parent := PnlHeader;
  LblDateFull.Left := 18;
  LblDateFull.Top := 32;
  LblDateFull.Font.Name := 'Segoe UI';
  LblDateFull.Font.Size := 13;
  LblDateFull.Font.Style := [fsBold];
  LblDateFull.Font.Color := clWhite;

  // 2. Navegação Mês / Ano
  PnlNav := TPanel.Create(Self);
  PnlNav.Parent := Self;
  PnlNav.Align := alTop;
  PnlNav.Height := 44;
  PnlNav.BevelOuter := bvNone;
  PnlNav.Color := clWhite;

  BtnPrev := TButton.Create(Self);
  BtnPrev.Parent := PnlNav;
  BtnPrev.Left := 10;
  BtnPrev.Top := 7;
  BtnPrev.Width := 34;
  BtnPrev.Height := 30;
  BtnPrev.Caption := '<';
  BtnPrev.Font.Style := [fsBold];
  BtnPrev.OnClick := @PrevMonthClick;

  LblMonthYear := TLabel.Create(Self);
  LblMonthYear.Parent := PnlNav;
  LblMonthYear.Left := 50;
  LblMonthYear.Top := 12;
  LblMonthYear.Width := 230;
  LblMonthYear.Alignment := taCenter;
  LblMonthYear.AutoSize := False;
  LblMonthYear.Font.Name := 'Segoe UI';
  LblMonthYear.Font.Size := 11;
  LblMonthYear.Font.Style := [fsBold];
  LblMonthYear.Font.Color := $001E293B;

  BtnNext := TButton.Create(Self);
  BtnNext.Parent := PnlNav;
  BtnNext.Left := 286;
  BtnNext.Top := 7;
  BtnNext.Width := 34;
  BtnNext.Height := 30;
  BtnNext.Caption := '>';
  BtnNext.Font.Style := [fsBold];
  BtnNext.OnClick := @NextMonthClick;

  // 3. Dias da Semana
  PnlWeekdays := TPanel.Create(Self);
  PnlWeekdays.Parent := Self;
  PnlWeekdays.Align := alTop;
  PnlWeekdays.Height := 24;
  PnlWeekdays.BevelOuter := bvNone;
  PnlWeekdays.Color := $00F8FAFC;

  for i := 0 to 6 do
  begin
    WeekdayLbl := TLabel.Create(Self);
    WeekdayLbl.Parent := PnlWeekdays;
    WeekdayLbl.Left := 10 + i * 44;
    WeekdayLbl.Top := 4;
    WeekdayLbl.Width := 44;
    WeekdayLbl.Alignment := taCenter;
    WeekdayLbl.AutoSize := False;
    WeekdayLbl.Font.Name := 'Segoe UI';
    WeekdayLbl.Font.Size := 8;
    WeekdayLbl.Font.Style := [fsBold];
    WeekdayLbl.Font.Color := $0064748B;
    WeekdayLbl.Caption := WeekDays[i];
  end;

  // 4. Rodapé de Ações
  PnlActions := TPanel.Create(Self);
  PnlActions.Parent := Self;
  PnlActions.Align := alBottom;
  PnlActions.Height := 52;
  PnlActions.BevelOuter := bvNone;
  PnlActions.Color := $00F1F5F9;

  BtnToday := TButton.Create(Self);
  BtnToday.Parent := PnlActions;
  BtnToday.Left := 12;
  BtnToday.Top := 10;
  BtnToday.Width := 75;
  BtnToday.Height := 32;
  BtnToday.Caption := 'HOJE';
  BtnToday.OnClick := @TodayClick;

  BtnCancel := TButton.Create(Self);
  BtnCancel.Parent := PnlActions;
  BtnCancel.Left := 142;
  BtnCancel.Top := 10;
  BtnCancel.Width := 85;
  BtnCancel.Height := 32;
  BtnCancel.Caption := 'CANCELAR';
  BtnCancel.ModalResult := mrCancel;

  BtnOk := TButton.Create(Self);
  BtnOk.Parent := PnlActions;
  BtnOk.Left := 233;
  BtnOk.Top := 10;
  BtnOk.Width := 85;
  BtnOk.Height := 32;
  BtnOk.Caption := 'OK';
  BtnOk.ModalResult := mrOk;

  // 5. Grade de Dias
  PnlGrid := TPanel.Create(Self);
  PnlGrid.Parent := Self;
  PnlGrid.Align := alClient;
  PnlGrid.BevelOuter := bvNone;
  PnlGrid.Color := clWhite;

  for DayNum := 1 to 31 do
  begin
    DayBtns[DayNum] := TButton.Create(Self);
    DayBtns[DayNum].Parent := PnlGrid;
    DayBtns[DayNum].Tag := DayNum;
    DayBtns[DayNum].Caption := IntToStr(DayNum);
    DayBtns[DayNum].Font.Name := 'Segoe UI';
    DayBtns[DayNum].Font.Size := 10;
    DayBtns[DayNum].OnClick := @DayClick;
  end;

  UpdateCalendarView;
end;

procedure TLazDroidDatePickDlg.UpdateCalendarView;
const
  MonthNames: array[1..12] of string = (
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro');
  DayNames: array[1..7] of string = (
    'Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado');
var
  FirstOfMonth: TDateTime;
  StartDayOfWeek, DaysCount, DayNum, DayCol, DayRow: Integer;
  SelY, SelM, SelD: Word;
begin
  DecodeDate(FSelectedDate, SelY, SelM, SelD);
  LblYear.Caption := IntToStr(FViewYear);
  LblDateFull.Caption := Format('%s, %0.2d de %s', [DayNames[DayOfWeek(FSelectedDate)], SelD, MonthNames[SelM]]);
  LblMonthYear.Caption := Format('%s %d', [MonthNames[FViewMonth], FViewYear]);

  FirstOfMonth := EncodeDate(FViewYear, FViewMonth, 1);
  StartDayOfWeek := DayOfWeek(FirstOfMonth);
  DaysCount := DaysInAMonth(FViewYear, FViewMonth);

  for DayNum := 1 to 31 do
  begin
    if DayNum <= DaysCount then
    begin
      DayCol := (StartDayOfWeek - 1 + (DayNum - 1)) mod 7;
      DayRow := (StartDayOfWeek - 1 + (DayNum - 1)) div 7;
      DayBtns[DayNum].Left := 10 + DayCol * 44;
      DayBtns[DayNum].Top := 8 + DayRow * 40;
      DayBtns[DayNum].Width := 40;
      DayBtns[DayNum].Height := 34;
      if (SelY = FViewYear) and (SelM = FViewMonth) and (SelD = DayNum) then
        DayBtns[DayNum].Font.Style := [fsBold]
      else
        DayBtns[DayNum].Font.Style := [];
      DayBtns[DayNum].Visible := True;
    end
    else
      DayBtns[DayNum].Visible := False;
  end;
end;

procedure TLazDroidDatePickDlg.PrevMonthClick(Sender: TObject);
begin
  if FViewMonth = 1 then
  begin
    FViewMonth := 12;
    Dec(FViewYear);
  end
  else
    Dec(FViewMonth);
  UpdateCalendarView;
end;

procedure TLazDroidDatePickDlg.NextMonthClick(Sender: TObject);
begin
  if FViewMonth = 12 then
  begin
    FViewMonth := 1;
    Inc(FViewYear);
  end
  else
    Inc(FViewMonth);
  UpdateCalendarView;
end;

procedure TLazDroidDatePickDlg.DayClick(Sender: TObject);
var
  D: Integer;
begin
  D := TComponent(Sender).Tag;
  FSelectedDate := EncodeDate(FViewYear, FViewMonth, D);
  UpdateCalendarView;
end;

procedure TLazDroidDatePickDlg.TodayClick(Sender: TObject);
var
  Dummy: Word;
begin
  FSelectedDate := SysUtils.Date;
  DecodeDate(FSelectedDate, FViewYear, FViewMonth, Dummy);
  UpdateCalendarView;
end;

function ShowMobileDatePicker(var ADate: TDateTime; const ATitle: string = 'Selecionar Data'): Boolean;
var
  Dlg: TLazDroidDatePickDlg;
  InitialDate: TDateTime;
begin
  Result := False;
  if ADate <= 0 then
    InitialDate := SysUtils.Date
  else
    InitialDate := ADate;

  Dlg := TLazDroidDatePickDlg.CreatePicker(nil, InitialDate, ATitle);
  try
    if Dlg.ShowModal = mrOk then
    begin
      ADate := Dlg.SelectedDate;
      Result := True;
    end;
  finally
    Dlg.Free;
  end;
end;

{ =============================================================================
  TLazDroidTimePickDlg & ShowMobileTimePicker
  ============================================================================= }

type
  TLazDroidTimePickDlg = class(TForm)
  private
    FSelectedHour: Integer;
    FSelectedMinute: Integer;
    LblHH: TLabel;
    LblMM: TLabel;
    procedure UpdateDisplay;
    procedure IncHourClick(Sender: TObject);
    procedure DecHourClick(Sender: TObject);
    procedure IncMinuteClick(Sender: TObject);
    procedure DecMinuteClick(Sender: TObject);
    procedure PresetClick(Sender: TObject);
  public
    constructor CreatePicker(AOwner: TComponent; AInitialTime: TDateTime; const ATitle: string);
    function GetSelectedTime: TDateTime;
  end;

constructor TLazDroidTimePickDlg.CreatePicker(AOwner: TComponent; AInitialTime: TDateTime; const ATitle: string);
var
  PnlHeader, PnlBody, PnlPresets, PnlActions: TPanel;
  LblHeader, LblColon: TLabel;
  BtnIncH, BtnDecH, BtnIncM, BtnDecM: TButton;
  BtnPreset: TButton;
  BtnCancel, BtnOk: TButton;
  H, M, S, MS: Word;
begin
  inherited CreateNew(AOwner);
  Caption := ATitle;
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  Width := 310;
  Height := 390;
  Color := clWhite;

  DecodeTime(AInitialTime, H, M, S, MS);
  FSelectedHour := H;
  FSelectedMinute := M;

  PnlHeader := TPanel.Create(Self);
  PnlHeader.Parent := Self;
  PnlHeader.Align := alTop;
  PnlHeader.Height := 60;
  PnlHeader.BevelOuter := bvNone;
  PnlHeader.Color := $00241A14;

  LblHeader := TLabel.Create(Self);
  LblHeader.Parent := PnlHeader;
  LblHeader.Left := 16;
  LblHeader.Top := 18;
  LblHeader.Font.Name := 'Segoe UI';
  LblHeader.Font.Size := 13;
  LblHeader.Font.Style := [fsBold];
  LblHeader.Font.Color := clWhite;
  LblHeader.Caption := ATitle;

  PnlBody := TPanel.Create(Self);
  PnlBody.Parent := Self;
  PnlBody.Align := alClient;
  PnlBody.BevelOuter := bvNone;
  PnlBody.Color := clWhite;

  BtnIncH := TButton.Create(Self);
  BtnIncH.Parent := PnlBody;
  BtnIncH.Left := 45;
  BtnIncH.Top := 20;
  BtnIncH.Width := 80;
  BtnIncH.Height := 34;
  BtnIncH.Caption := '▲ +1h';
  BtnIncH.Font.Name := 'Segoe UI';
  BtnIncH.Font.Style := [fsBold];
  BtnIncH.OnClick := @IncHourClick;

  LblHH := TLabel.Create(Self);
  LblHH.Parent := PnlBody;
  LblHH.Left := 45;
  LblHH.Top := 62;
  LblHH.Width := 80;
  LblHH.Height := 60;
  LblHH.Alignment := taCenter;
  LblHH.AutoSize := False;
  LblHH.Font.Name := 'Segoe UI';
  LblHH.Font.Size := 36;
  LblHH.Font.Style := [fsBold];
  LblHH.Font.Color := $001E293B;

  BtnDecH := TButton.Create(Self);
  BtnDecH.Parent := PnlBody;
  BtnDecH.Left := 45;
  BtnDecH.Top := 130;
  BtnDecH.Width := 80;
  BtnDecH.Height := 34;
  BtnDecH.Caption := '▼ -1h';
  BtnDecH.Font.Name := 'Segoe UI';
  BtnDecH.Font.Style := [fsBold];
  BtnDecH.OnClick := @DecHourClick;

  LblColon := TLabel.Create(Self);
  LblColon.Parent := PnlBody;
  LblColon.Left := 135;
  LblColon.Top := 62;
  LblColon.Width := 25;
  LblColon.Height := 60;
  LblColon.Alignment := taCenter;
  LblColon.AutoSize := False;
  LblColon.Font.Name := 'Segoe UI';
  LblColon.Font.Size := 36;
  LblColon.Font.Style := [fsBold];
  LblColon.Font.Color := $0094A3B8;
  LblColon.Caption := ':';

  BtnIncM := TButton.Create(Self);
  BtnIncM.Parent := PnlBody;
  BtnIncM.Left := 170;
  BtnIncM.Top := 20;
  BtnIncM.Width := 80;
  BtnIncM.Height := 34;
  BtnIncM.Caption := '▲ +5m';
  BtnIncM.Font.Name := 'Segoe UI';
  BtnIncM.Font.Style := [fsBold];
  BtnIncM.OnClick := @IncMinuteClick;

  LblMM := TLabel.Create(Self);
  LblMM.Parent := PnlBody;
  LblMM.Left := 170;
  LblMM.Top := 62;
  LblMM.Width := 80;
  LblMM.Height := 60;
  LblMM.Alignment := taCenter;
  LblMM.AutoSize := False;
  LblMM.Font.Name := 'Segoe UI';
  LblMM.Font.Size := 36;
  LblMM.Font.Style := [fsBold];
  LblMM.Font.Color := $001E293B;

  BtnDecM := TButton.Create(Self);
  BtnDecM.Parent := PnlBody;
  BtnDecM.Left := 170;
  BtnDecM.Top := 130;
  BtnDecM.Width := 80;
  BtnDecM.Height := 34;
  BtnDecM.Caption := '▼ -5m';
  BtnDecM.Font.Name := 'Segoe UI';
  BtnDecM.Font.Style := [fsBold];
  BtnDecM.OnClick := @DecMinuteClick;

  PnlPresets := TPanel.Create(Self);
  PnlPresets.Parent := PnlBody;
  PnlPresets.Left := 10;
  PnlPresets.Top := 180;
  PnlPresets.Width := 285;
  PnlPresets.Height := 40;
  PnlPresets.BevelOuter := bvNone;
  PnlPresets.Color := clWhite;

  BtnPreset := TButton.Create(Self);
  BtnPreset.Parent := PnlPresets;
  BtnPreset.Left := 5;
  BtnPreset.Top := 4;
  BtnPreset.Width := 62;
  BtnPreset.Height := 30;
  BtnPreset.Tag := -1;
  BtnPreset.Caption := 'Agora';
  BtnPreset.OnClick := @PresetClick;

  BtnPreset := TButton.Create(Self);
  BtnPreset.Parent := PnlPresets;
  BtnPreset.Left := 74;
  BtnPreset.Top := 4;
  BtnPreset.Width := 62;
  BtnPreset.Height := 30;
  BtnPreset.Tag := 800;
  BtnPreset.Caption := '08:00';
  BtnPreset.OnClick := @PresetClick;

  BtnPreset := TButton.Create(Self);
  BtnPreset.Parent := PnlPresets;
  BtnPreset.Left := 143;
  BtnPreset.Top := 4;
  BtnPreset.Width := 62;
  BtnPreset.Height := 30;
  BtnPreset.Tag := 1200;
  BtnPreset.Caption := '12:00';
  BtnPreset.OnClick := @PresetClick;

  BtnPreset := TButton.Create(Self);
  BtnPreset.Parent := PnlPresets;
  BtnPreset.Left := 212;
  BtnPreset.Top := 4;
  BtnPreset.Width := 62;
  BtnPreset.Height := 30;
  BtnPreset.Tag := 1800;
  BtnPreset.Caption := '18:00';
  BtnPreset.OnClick := @PresetClick;

  PnlActions := TPanel.Create(Self);
  PnlActions.Parent := Self;
  PnlActions.Align := alBottom;
  PnlActions.Height := 52;
  PnlActions.BevelOuter := bvNone;
  PnlActions.Color := $00F1F5F9;

  BtnCancel := TButton.Create(Self);
  BtnCancel.Parent := PnlActions;
  BtnCancel.Left := 105;
  BtnCancel.Top := 10;
  BtnCancel.Width := 90;
  BtnCancel.Height := 32;
  BtnCancel.Caption := 'CANCELAR';
  BtnCancel.ModalResult := mrCancel;

  BtnOk := TButton.Create(Self);
  BtnOk.Parent := PnlActions;
  BtnOk.Left := 205;
  BtnOk.Top := 10;
  BtnOk.Width := 90;
  BtnOk.Height := 32;
  BtnOk.Caption := 'OK';
  BtnOk.ModalResult := mrOk;

  UpdateDisplay;
end;

procedure TLazDroidTimePickDlg.UpdateDisplay;
begin
  LblHH.Caption := Format('%.2d', [FSelectedHour]);
  LblMM.Caption := Format('%.2d', [FSelectedMinute]);
end;

procedure TLazDroidTimePickDlg.IncHourClick(Sender: TObject);
begin
  FSelectedHour := (FSelectedHour + 1) mod 24;
  UpdateDisplay;
end;

procedure TLazDroidTimePickDlg.DecHourClick(Sender: TObject);
begin
  if FSelectedHour = 0 then FSelectedHour := 23 else Dec(FSelectedHour);
  UpdateDisplay;
end;

procedure TLazDroidTimePickDlg.IncMinuteClick(Sender: TObject);
begin
  FSelectedMinute := (FSelectedMinute + 5) mod 60;
  UpdateDisplay;
end;

procedure TLazDroidTimePickDlg.DecMinuteClick(Sender: TObject);
begin
  if FSelectedMinute < 5 then FSelectedMinute := 55 else Dec(FSelectedMinute, 5);
  UpdateDisplay;
end;

procedure TLazDroidTimePickDlg.PresetClick(Sender: TObject);
var
  TagVal: Integer;
  H, M, S, MS: Word;
begin
  TagVal := TComponent(Sender).Tag;
  if TagVal = -1 then
  begin
    DecodeTime(SysUtils.Time, H, M, S, MS);
    FSelectedHour := H;
    FSelectedMinute := M;
  end
  else
  begin
    FSelectedHour := TagVal div 100;
    FSelectedMinute := TagVal mod 100;
  end;
  UpdateDisplay;
end;

function TLazDroidTimePickDlg.GetSelectedTime: TDateTime;
begin
  Result := EncodeTime(FSelectedHour, FSelectedMinute, 0, 0);
end;

function ShowMobileTimePicker(var ATime: TDateTime; const ATitle: string = 'Selecionar Horário'): Boolean;
var
  Dlg: TLazDroidTimePickDlg;
  InitialTime: TDateTime;
begin
  Result := False;
  if ATime <= 0 then
    InitialTime := SysUtils.Time
  else
    InitialTime := ATime;

  Dlg := TLazDroidTimePickDlg.CreatePicker(nil, InitialTime, ATitle);
  try
    if Dlg.ShowModal = mrOk then
    begin
      ATime := Dlg.GetSelectedTime;
      Result := True;
    end;
  finally
    Dlg.Free;
  end;
end;

{ =============================================================================
  TLazDroidDatePicker
  ============================================================================= }

constructor TLazDroidDatePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 240;
  Height := 52;
  FDate := SysUtils.Date;
  FDateFormat := 'DD/MM/YYYY';
  FLabelCaption := 'Data';
  FPlaceholder := 'Selecione a data';
  FBorderColor := $00D0D0D0;
  FAccentColor := $00D97706;
  FCornerRadius := 8;
  Color := clWhite;
  Font.Name := 'Segoe UI';
  Font.Size := 11;
end;

procedure TLazDroidDatePicker.SetDate(const AValue: TDateTime);
begin
  if FDate <> AValue then
  begin
    FDate := AValue;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidDatePicker.SetDateFormat(const AValue: string);
begin
  if FDateFormat <> AValue then
  begin
    FDateFormat := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidDatePicker.SetLabelCaption(const AValue: string);
begin
  if FLabelCaption <> AValue then
  begin
    FLabelCaption := AValue;
    Invalidate;
  end;
end;

function TLazDroidDatePicker.OpenPicker: Boolean;
var
  NewDate: TDateTime;
begin
  Result := False;
  NewDate := FDate;
  if ShowMobileDatePicker(NewDate, FLabelCaption) then
  begin
    SetDate(NewDate);
    Result := True;
  end;
end;

procedure TLazDroidDatePicker.Click;
begin
  inherited Click;
  if not (csDesigning in ComponentState) and Enabled then
    OpenPicker;
end;

procedure TLazDroidDatePicker.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TLazDroidDatePicker.Paint;
var
  R, IconRect: TRect;
  YDate: Integer;
begin
  R := ClientRect;
  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := FBorderColor;
  Canvas.Pen.Width := 1;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);

  Canvas.Brush.Style := bsClear;

  if FLabelCaption <> '' then
  begin
    Canvas.Font.Name := 'Segoe UI';
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Color := $0064748B;
    Canvas.TextOut(12, 6, FLabelCaption);
    YDate := 23;
  end
  else
    YDate := (Height - Canvas.TextHeight('Ag')) div 2;

  Canvas.Font := Font;
  if FDate > 0 then
  begin
    Canvas.Font.Color := $001E293B;
    Canvas.TextOut(12, YDate, FormatDateTime(FDateFormat, FDate));
  end
  else
  begin
    Canvas.Font.Color := $009CA3AF;
    Canvas.TextOut(12, YDate, FPlaceholder);
  end;

  // Ícone de calendário à direita
  IconRect := Rect(Width - 36, (Height - 22) div 2, Width - 14, (Height + 22) div 2);
  DrawMobileIcon(Canvas, aiCalendar, IconRect, FAccentColor);
end;

{ =============================================================================
  TLazDroidTimePicker
  ============================================================================= }

constructor TLazDroidTimePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 200;
  Height := 52;
  FTime := SysUtils.Time;
  FTimeFormat := 'HH:NN';
  FLabelCaption := 'Horário';
  FPlaceholder := 'Selecione o horário';
  FBorderColor := $00D0D0D0;
  FAccentColor := $00D97706;
  FCornerRadius := 8;
  Color := clWhite;
  Font.Name := 'Segoe UI';
  Font.Size := 11;
end;

procedure TLazDroidTimePicker.SetTime(const AValue: TDateTime);
begin
  if FTime <> AValue then
  begin
    FTime := AValue;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidTimePicker.SetTimeFormat(const AValue: string);
begin
  if FTimeFormat <> AValue then
  begin
    FTimeFormat := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidTimePicker.SetLabelCaption(const AValue: string);
begin
  if FLabelCaption <> AValue then
  begin
    FLabelCaption := AValue;
    Invalidate;
  end;
end;

function TLazDroidTimePicker.OpenPicker: Boolean;
var
  NewTime: TDateTime;
begin
  Result := False;
  NewTime := FTime;
  if ShowMobileTimePicker(NewTime, FLabelCaption) then
  begin
    SetTime(NewTime);
    Result := True;
  end;
end;

procedure TLazDroidTimePicker.Click;
begin
  inherited Click;
  if not (csDesigning in ComponentState) and Enabled then
    OpenPicker;
end;

procedure TLazDroidTimePicker.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TLazDroidTimePicker.Paint;
var
  R, IconRect: TRect;
  YTime: Integer;
begin
  R := ClientRect;
  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := FBorderColor;
  Canvas.Pen.Width := 1;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);

  Canvas.Brush.Style := bsClear;

  if FLabelCaption <> '' then
  begin
    Canvas.Font.Name := 'Segoe UI';
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Color := $0064748B;
    Canvas.TextOut(12, 6, FLabelCaption);
    YTime := 23;
  end
  else
    YTime := (Height - Canvas.TextHeight('Ag')) div 2;

  Canvas.Font := Font;
  if FTime > 0 then
  begin
    Canvas.Font.Color := $001E293B;
    Canvas.TextOut(12, YTime, FormatDateTime(FTimeFormat, FTime));
  end
  else
  begin
    Canvas.Font.Color := $009CA3AF;
    Canvas.TextOut(12, YTime, FPlaceholder);
  end;

  // Ícone de relógio à direita
  IconRect := Rect(Width - 36, (Height - 22) div 2, Width - 14, (Height + 22) div 2);
  DrawMobileIcon(Canvas, aiClock, IconRect, FAccentColor);
end;

{ =============================================================================
  TLazDroidProgressBar
  ============================================================================= }

constructor TLazDroidProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 200;
  Height := 16;
  FMin := 0;
  FMax := 100;
  FPosition := 30;
  FBarColor := $00D97706;   // Amber / Primary
  FTrackColor := $00E5E7EB; // Slate 200
  FCornerRadius := 6;
  FShowPercentage := False;
  Font.Name := 'Segoe UI';
  Font.Size := 8;
  Font.Style := [fsBold];
end;

procedure TLazDroidProgressBar.SetMin(const AValue: Integer);
begin
  if FMin <> AValue then
  begin
    FMin := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidProgressBar.SetMax(const AValue: Integer);
begin
  if FMax <> AValue then
  begin
    FMax := Math.Max(FMin + 1, AValue);
    Invalidate;
  end;
end;

procedure TLazDroidProgressBar.SetPosition(const AValue: Integer);
begin
  if FPosition <> AValue then
  begin
    FPosition := Math.Max(FMin, Math.Min(FMax, AValue));
    Invalidate;
  end;
end;

procedure TLazDroidProgressBar.SetBarColor(const AValue: TColor);
begin
  if FBarColor <> AValue then
  begin
    FBarColor := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidProgressBar.SetTrackColor(const AValue: TColor);
begin
  if FTrackColor <> AValue then
  begin
    FTrackColor := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidProgressBar.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius <> AValue then
  begin
    FCornerRadius := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidProgressBar.SetShowPercentage(const AValue: Boolean);
begin
  if FShowPercentage <> AValue then
  begin
    FShowPercentage := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidProgressBar.Paint;
var
  ParentBg: TColor;
  FillW: Integer;
  Ratio: Double;
  PctStr: string;
  tx, ty: Integer;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  // Trilho de fundo
  Canvas.Brush.Color := FTrackColor;
  Canvas.Pen.Color := FTrackColor;
  Canvas.RoundRect(0, 0, Width, Height, FCornerRadius, FCornerRadius);

  // Barra de progresso preenchida
  Ratio := (FPosition - FMin) / Math.Max(1, FMax - FMin);
  FillW := Round(Width * Math.Max(0.0, Math.Min(1.0, Ratio)));
  if FillW > 2 then
  begin
    Canvas.Brush.Color := FBarColor;
    Canvas.Pen.Color := FBarColor;
    Canvas.RoundRect(0, 0, FillW, Height, FCornerRadius, FCornerRadius);
  end;

  if FShowPercentage then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Font := Font;
    Canvas.Font.Color := $001F2937;
    PctStr := Format('%d%%', [Round(Math.Max(0.0, Math.Min(1.0, Ratio)) * 100)]);
    tx := (Width - Canvas.TextWidth(PctStr)) div 2;
    ty := (Height - Canvas.TextHeight(PctStr)) div 2;
    Canvas.TextOut(tx, ty, PctStr);
  end;
end;

{ =============================================================================
  TLazDroidSlider
  ============================================================================= }

constructor TLazDroidSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 220;
  Height := 36;
  FMin := 0;
  FMax := 100;
  FPosition := 50;
  FActiveTrackColor := $00D97706;
  FInactiveTrackColor := $00E5E7EB;
  FThumbColor := $00D97706;
  FThumbRadius := 9;
  FIsDragging := False;
end;

procedure TLazDroidSlider.SetMin(const AValue: Integer);
begin
  if FMin <> AValue then
  begin
    FMin := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidSlider.SetMax(const AValue: Integer);
begin
  if FMax <> AValue then
  begin
    FMax := Math.Max(FMin + 1, AValue);
    Invalidate;
  end;
end;

procedure TLazDroidSlider.SetPosition(const AValue: Integer);
var
  Clamped: Integer;
begin
  Clamped := Math.Max(FMin, Math.Min(FMax, AValue));
  if FPosition <> Clamped then
  begin
    FPosition := Clamped;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidSlider.UpdatePositionFromX(X: Integer);
var
  Pad, TrackW, NewVal: Integer;
  Ratio: Double;
begin
  Pad := FThumbRadius + 4;
  TrackW := Width - (Pad * 2);
  if TrackW <= 0 then Exit;

  Ratio := (X - Pad) / TrackW;
  Ratio := Math.Max(0.0, Math.Min(1.0, Ratio));
  NewVal := FMin + Round(Ratio * (FMax - FMin));
  SetPosition(NewVal);
end;

procedure TLazDroidSlider.Paint;
var
  ParentBg: TColor;
  Pad, TrackW, TrackY, ThumbX: Integer;
  Ratio: Double;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  Pad := FThumbRadius + 4;
  TrackW := Width - (Pad * 2);
  TrackY := Height div 2;

  Ratio := (FPosition - FMin) / Math.Max(1, FMax - FMin);
  ThumbX := Pad + Round(TrackW * Math.Max(0.0, Math.Min(1.0, Ratio)));

  // Trilho inativo (cinza)
  Canvas.Pen.Color := FInactiveTrackColor;
  Canvas.Pen.Width := 4;
  Canvas.Pen.Style := psSolid;
  Canvas.Line(Pad, TrackY, Width - Pad, TrackY);

  // Trilho ativo (cor tema)
  if ThumbX > Pad then
  begin
    Canvas.Pen.Color := FActiveTrackColor;
    Canvas.Pen.Width := 4;
    Canvas.Line(Pad, TrackY, ThumbX, TrackY);
  end;

  // Thumb do cursor deslizante com anel branco externo
  Canvas.Brush.Color := clWhite;
  Canvas.Pen.Color := $00CBD5E1;
  Canvas.Pen.Width := 1;
  Canvas.Ellipse(ThumbX - FThumbRadius - 2, TrackY - FThumbRadius - 2,
                 ThumbX + FThumbRadius + 2, TrackY + FThumbRadius + 2);

  Canvas.Brush.Color := FThumbColor;
  Canvas.Pen.Color := FThumbColor;
  Canvas.Ellipse(ThumbX - FThumbRadius, TrackY - FThumbRadius,
                 ThumbX + FThumbRadius, TrackY + FThumbRadius);
end;

procedure TLazDroidSlider.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FIsDragging := True;
  UpdatePositionFromX(X);
end;

procedure TLazDroidSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if FIsDragging then UpdatePositionFromX(X);
end;

procedure TLazDroidSlider.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FIsDragging := False;
end;

{ =============================================================================
  TLazDroidSegmentedControl
  ============================================================================= }

constructor TLazDroidSegmentedControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 270;
  Height := 40;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := @ItemsChanged;
  FItems.Add('Todos');
  FItems.Add('Ativos');
  FItems.Add('Pendentes');
  FItemIndex := 0;
  FActiveColor := $00D97706;      // Amber / Primary
  FActiveTextColor := clWhite;
  FInactiveColor := $00F1F5F9;    // Slate 100
  FInactiveTextColor := $00475569;  // Slate 600
  FCornerRadius := 8;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  Font.Style := [fsBold];
end;

destructor TLazDroidSegmentedControl.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TLazDroidSegmentedControl.SetItems(const AValue: TStrings);
begin
  FItems.Assign(AValue);
end;

procedure TLazDroidSegmentedControl.SetItemIndex(const AValue: Integer);
begin
  if (AValue >= 0) and (AValue < FItems.Count) and (FItemIndex <> AValue) then
  begin
    FItemIndex := AValue;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidSegmentedControl.ItemsChanged(Sender: TObject);
begin
  if FItemIndex >= FItems.Count then
    FItemIndex := Math.Max(0, FItems.Count - 1);
  Invalidate;
end;

procedure TLazDroidSegmentedControl.Paint;
var
  i, ItemCount, SegW, Pad, SegLeft, SegRight: Integer;
  ParentBg: TColor;
  Txt: string;
  tx, ty: Integer;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  // Fundo externo da barra
  Canvas.Brush.Color := FInactiveColor;
  Canvas.Pen.Color := $00E2E8F0;
  Canvas.Pen.Width := 1;
  Canvas.RoundRect(0, 0, Width, Height, FCornerRadius, FCornerRadius);

  ItemCount := FItems.Count;
  if ItemCount = 0 then Exit;

  Pad := 3;
  SegW := (Width - (Pad * 2)) div ItemCount;

  // Pílula ativa (Active Pill)
  if (FItemIndex >= 0) and (FItemIndex < ItemCount) then
  begin
    SegLeft := Pad + (FItemIndex * SegW);
    SegRight := SegLeft + SegW;
    Canvas.Brush.Color := FActiveColor;
    Canvas.Pen.Color := FActiveColor;
    Canvas.RoundRect(SegLeft, Pad, SegRight, Height - Pad, Math.Max(4, FCornerRadius - 2), Math.Max(4, FCornerRadius - 2));
  end;

  // Textos das abas
  Canvas.Brush.Style := bsClear;
  Canvas.Font := Font;

  for i := 0 to ItemCount - 1 do
  begin
    Txt := FItems[i];
    SegLeft := Pad + (i * SegW);
    tx := SegLeft + (SegW - Canvas.TextWidth(Txt)) div 2;
    ty := (Height - Canvas.TextHeight(Txt)) div 2;

    if i = FItemIndex then
      Canvas.Font.Color := FActiveTextColor
    else
      Canvas.Font.Color := FInactiveTextColor;

    Canvas.TextOut(tx, ty, Txt);
  end;
end;

procedure TLazDroidSegmentedControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ItemCount, Pad, SegW, ClickedIdx: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  ItemCount := FItems.Count;
  if ItemCount = 0 then Exit;

  Pad := 3;
  SegW := (Width - (Pad * 2)) div ItemCount;
  if SegW <= 0 then Exit;

  ClickedIdx := (X - Pad) div SegW;
  if (ClickedIdx >= 0) and (ClickedIdx < ItemCount) then
    SetItemIndex(ClickedIdx);
end;

{ =============================================================================
  TLazDroidCheckBox
  ============================================================================= }

constructor TLazDroidCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 180;
  Height := 36;
  FChecked := False;
  FCaption := 'Opção';
  FBoxColor := $00D97706;      // Amber / Primary
  FCheckColor := clWhite;
  FBorderColor := $00CBD5E1;   // Slate 300
  FCornerRadius := 6;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
end;

procedure TLazDroidCheckBox.SetChecked(const AValue: Boolean);
begin
  if FChecked <> AValue then
  begin
    FChecked := AValue;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidCheckBox.SetCaption(const AValue: string);
begin
  if FCaption <> AValue then
  begin
    FCaption := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidCheckBox.Click;
begin
  SetChecked(not FChecked);
  inherited Click;
end;

procedure TLazDroidCheckBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TLazDroidCheckBox.Paint;
var
  ParentBg: TColor;
  BoxSz, BoxLeft, BoxTop, TextY: Integer;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  BoxSz := 22;
  BoxLeft := 4;
  BoxTop := (Height - BoxSz) div 2;

  if FChecked then
  begin
    Canvas.Brush.Color := FBoxColor;
    Canvas.Pen.Color := FBoxColor;
    Canvas.RoundRect(BoxLeft, BoxTop, BoxLeft + BoxSz, BoxTop + BoxSz, FCornerRadius, FCornerRadius);
    DrawMobileIcon(Canvas, aiCheck, Rect(BoxLeft + 1, BoxTop + 1, BoxLeft + BoxSz - 1, BoxTop + BoxSz - 1), FCheckColor);
  end
  else
  begin
    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := FBorderColor;
    Canvas.Pen.Width := 2;
    Canvas.RoundRect(BoxLeft, BoxTop, BoxLeft + BoxSz, BoxTop + BoxSz, FCornerRadius, FCornerRadius);
  end;

  if FCaption <> '' then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Font := Font;
    Canvas.Font.Color := $001E293B;
    TextY := (Height - Canvas.TextHeight(FCaption)) div 2;
    Canvas.TextOut(BoxLeft + BoxSz + 10, TextY, FCaption);
  end;
end;

{ =============================================================================
  TLazDroidRatingBar
  ============================================================================= }

constructor TLazDroidRatingBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 160;
  Height := 36;
  FRating := 0;
  FStarCount := 5;
  FActiveColor := $0000C0FF;    // Amber / Gold
  FInactiveColor := $00CBD5E1;  // Slate 300
  FStarSize := 12;
end;

procedure TLazDroidRatingBar.SetRating(const AValue: Integer);
var
  Clamped: Integer;
begin
  Clamped := Math.Max(0, Math.Min(FStarCount, AValue));
  if FRating <> Clamped then
  begin
    FRating := Clamped;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidRatingBar.SetStarCount(const AValue: Integer);
begin
  if (AValue >= 1) and (FStarCount <> AValue) then
  begin
    FStarCount := AValue;
    if FRating > FStarCount then FRating := FStarCount;
    Invalidate;
  end;
end;

procedure TLazDroidRatingBar.Paint;
var
  ParentBg: TColor;
  i, SlotW: Integer;
  CenterPt: TPoint;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  SlotW := Width div Math.Max(1, FStarCount);

  for i := 1 to FStarCount do
  begin
    CenterPt := Point((i - 1) * SlotW + SlotW div 2, Height div 2);
    if i <= FRating then
      DrawMobileStar(Canvas, CenterPt, FStarSize, FActiveColor, True)
    else
      DrawMobileStar(Canvas, CenterPt, FStarSize, FInactiveColor, False);
  end;
end;

procedure TLazDroidRatingBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SlotW, ClickedStar: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  SlotW := Width div Math.Max(1, FStarCount);
  if SlotW <= 0 then Exit;

  ClickedStar := (X div SlotW) + 1;
  if ClickedStar = FRating then
    SetRating(0)
  else
    SetRating(ClickedStar);
end;

{ =============================================================================
  ShowMobileActionSheet
  ============================================================================= }

type
  TLazDroidActionSheetDlg = class(TForm)
  private
    FSelectedIdx: Integer;
    procedure OptionClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
  public
    constructor CreateSheet(AOwner: TComponent; const ATitle: string; const AOptions: array of string);
    property SelectedIndex: Integer read FSelectedIdx;
  end;

constructor TLazDroidActionSheetDlg.CreateSheet(AOwner: TComponent; const ATitle: string; const AOptions: array of string);
var
  OptCount, i, SheetH: Integer;
  PnlHeader, PnlBody, PnlCancel: TPanel;
  BtnOpt, BtnCancel: TButton;
  LblTitle: TLabel;
begin
  inherited CreateNew(AOwner);
  Caption := ATitle;
  BorderStyle := bsNone;
  Position := poScreenCenter;
  Color := $00F1F5F9;
  FSelectedIdx := -1;

  OptCount := Length(AOptions);
  SheetH := 50 + (OptCount * 46) + 60;
  Width := 320;
  Height := SheetH;

  PnlHeader := TPanel.Create(Self);
  PnlHeader.Parent := Self;
  PnlHeader.Align := alTop;
  PnlHeader.Height := 44;
  PnlHeader.BevelOuter := bvNone;
  PnlHeader.Color := clWhite;

  LblTitle := TLabel.Create(Self);
  LblTitle.Parent := PnlHeader;
  LblTitle.Align := alClient;
  LblTitle.Alignment := taCenter;
  LblTitle.Layout := tlCenter;
  LblTitle.Font.Name := 'Segoe UI';
  LblTitle.Font.Size := 10;
  LblTitle.Font.Style := [fsBold];
  LblTitle.Font.Color := $00475569;
  LblTitle.Caption := ATitle;

  PnlCancel := TPanel.Create(Self);
  PnlCancel.Parent := Self;
  PnlCancel.Align := alBottom;
  PnlCancel.Height := 54;
  PnlCancel.BevelOuter := bvNone;
  PnlCancel.Color := $00F1F5F9;

  BtnCancel := TButton.Create(Self);
  BtnCancel.Parent := PnlCancel;
  BtnCancel.Left := 16;
  BtnCancel.Top := 8;
  BtnCancel.Width := Width - 32;
  BtnCancel.Height := 38;
  BtnCancel.Caption := 'CANCELAR';
  BtnCancel.Font.Name := 'Segoe UI';
  BtnCancel.Font.Style := [fsBold];
  BtnCancel.OnClick := @CancelClick;

  PnlBody := TPanel.Create(Self);
  PnlBody.Parent := Self;
  PnlBody.Align := alClient;
  PnlBody.BevelOuter := bvNone;
  PnlBody.Color := clWhite;

  for i := 0 to OptCount - 1 do
  begin
    BtnOpt := TButton.Create(Self);
    BtnOpt.Parent := PnlBody;
    BtnOpt.Left := 12;
    BtnOpt.Top := 4 + (i * 44);
    BtnOpt.Width := Width - 24;
    BtnOpt.Height := 40;
    BtnOpt.Tag := i;
    BtnOpt.Caption := AOptions[i];
    BtnOpt.Font.Name := 'Segoe UI';
    BtnOpt.Font.Size := 10;
    BtnOpt.OnClick := @OptionClick;
  end;
end;

procedure TLazDroidActionSheetDlg.OptionClick(Sender: TObject);
begin
  FSelectedIdx := TComponent(Sender).Tag;
  ModalResult := mrOk;
end;

procedure TLazDroidActionSheetDlg.CancelClick(Sender: TObject);
begin
  FSelectedIdx := -1;
  ModalResult := mrCancel;
end;

function ShowMobileActionSheet(const ATitle: string; const AOptions: array of string; AOwner: TCustomForm = nil): Integer;
var
  Dlg: TLazDroidActionSheetDlg;
  Target: TCustomForm;
begin
  Result := -1;
  Target := AOwner;
  if Target = nil then Target := Screen.ActiveCustomForm;
  if Target = nil then Target := Application.MainForm;

  Dlg := TLazDroidActionSheetDlg.CreateSheet(Target, ATitle, AOptions);
  try
    if Dlg.ShowModal = mrOk then
      Result := Dlg.SelectedIndex;
  finally
    Dlg.Free;
  end;
end;

{ =============================================================================
  TLazDroidSearchBar
  ============================================================================= }

constructor TLazDroidSearchBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csRequiresKeyboardInput, csOpaque];
  TabStop := True;
  Width := 260;
  Height := 44;
  FText := '';
  FPlaceholder := 'Pesquisar...';
  FSearchColor := $00D97706;
  FBorderColor := $00CBD5E1;
  FCornerRadius := 18;
  FAutoSearch := True;
  FIsFocused := False;
  Color := clWhite;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
end;

procedure TLazDroidSearchBar.SetText(const AValue: string);
begin
  if FText <> AValue then
  begin
    FText := AValue;
    Invalidate;
    if FAutoSearch and Assigned(FOnSearch) then FOnSearch(Self, FText);
  end;
end;

procedure TLazDroidSearchBar.Clear;
begin
  SetText('');
end;

function TLazDroidSearchBar.GetClearRect: TRect;
begin
  Result := Rect(Width - 36, (Height - 24) div 2, Width - 12, (Height + 24) div 2);
end;

procedure TLazDroidSearchBar.DoEnter;
begin
  inherited DoEnter;
  FIsFocused := True;
  Invalidate;
end;

procedure TLazDroidSearchBar.DoExit;
begin
  inherited DoExit;
  FIsFocused := False;
  Invalidate;
end;

procedure TLazDroidSearchBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (FText <> '') and PtInRect(GetClearRect, Point(X, Y)) then
  begin
    Clear;
    Exit;
  end;
  if CanFocus then SetFocus;
end;

procedure TLazDroidSearchBar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key = VK_BACK then
  begin
    if Length(FText) > 0 then
    begin
      Delete(FText, Length(FText), 1);
      Invalidate;
      if FAutoSearch and Assigned(FOnSearch) then FOnSearch(Self, FText);
    end;
  end
  else if Key = VK_RETURN then
  begin
    if Assigned(FOnSearch) then FOnSearch(Self, FText);
  end;
end;

procedure TLazDroidSearchBar.UTF8KeyPress(var UTF8Key: TUTF8Char);
begin
  inherited UTF8KeyPress(UTF8Key);
  if UTF8Key >= ' ' then
  begin
    FText := FText + UTF8Key;
    Invalidate;
    if FAutoSearch and Assigned(FOnSearch) then FOnSearch(Self, FText);
  end;
end;

procedure TLazDroidSearchBar.Paint;
var
  ParentBg: TColor;
  R, SearchIconRect, ClearRect: TRect;
  ty: Integer;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  R := ClientRect;
  Canvas.Brush.Color := Color;
  if FIsFocused then
  begin
    Canvas.Pen.Color := FSearchColor;
    Canvas.Pen.Width := 2;
  end
  else
  begin
    Canvas.Pen.Color := FBorderColor;
    Canvas.Pen.Width := 1;
  end;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);

  // Ícone de Lupa à esquerda
  SearchIconRect := Rect(10, (Height - 20) div 2, 30, (Height + 20) div 2);
  DrawMobileIcon(Canvas, aiSearch, SearchIconRect, FSearchColor);

  // Texto ou Placeholder
  Canvas.Brush.Style := bsClear;
  Canvas.Font := Font;
  ty := (Height - Canvas.TextHeight('Ag')) div 2;

  if FText <> '' then
  begin
    Canvas.Font.Color := $001E293B;
    Canvas.TextOut(34, ty, FText);

    // Botão Limpar 'X' à direita
    ClearRect := GetClearRect;
    DrawMobileIcon(Canvas, aiClose, ClearRect, $0094A3B8);
  end
  else
  begin
    Canvas.Font.Color := $0094A3B8;
    Canvas.TextOut(34, ty, FPlaceholder);
  end;
end;

{ =============================================================================
  TLazDroidChipGroup
  ============================================================================= }

constructor TLazDroidChipGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 280;
  Height := 38;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := @ItemsChanged;
  FItems.Add('Todos');
  FItems.Add('Em Aberto');
  FItems.Add('Entregue');
  FItemIndex := 0;
  FMultiSelect := False;
  FSelectedMask := 1;
  FActiveColor := $00D97706;
  FActiveTextColor := clWhite;
  FInactiveColor := $00F1F5F9;
  FInactiveTextColor := $00475569;
  FCornerRadius := 14;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  Font.Style := [fsBold];
end;

destructor TLazDroidChipGroup.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TLazDroidChipGroup.SetItems(const AValue: TStrings);
begin
  FItems.Assign(AValue);
end;

function TLazDroidChipGroup.IsSelected(Index: Integer): Boolean;
begin
  if FMultiSelect then
    Result := (FSelectedMask and (1 shl Index)) <> 0
  else
    Result := (FItemIndex = Index);
end;

procedure TLazDroidChipGroup.ToggleSelected(Index: Integer);
begin
  if (Index >= 0) and (Index < FItems.Count) then
  begin
    if FMultiSelect then
      FSelectedMask := FSelectedMask xor (1 shl Index)
    else
      FItemIndex := Index;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidChipGroup.SetItemIndex(const AValue: Integer);
begin
  if (AValue >= -1) and (AValue < FItems.Count) and (FItemIndex <> AValue) then
  begin
    FItemIndex := AValue;
    if FItemIndex >= 0 then
      FSelectedMask := (1 shl FItemIndex)
    else
      FSelectedMask := 0;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidChipGroup.ItemsChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TLazDroidChipGroup.Paint;
var
  ParentBg, ChipBg, ChipTxtCol: TColor;
  i, x, ChipW, Pad: Integer;
  Txt: string;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  x := 4;
  Pad := 12;

  Canvas.Font := Font;

  for i := 0 to FItems.Count - 1 do
  begin
    Txt := FItems[i];
    ChipW := Canvas.TextWidth(Txt) + (Pad * 2);

    if IsSelected(i) then
    begin
      ChipBg := FActiveColor;
      ChipTxtCol := FActiveTextColor;
    end
    else
    begin
      ChipBg := FInactiveColor;
      ChipTxtCol := FInactiveTextColor;
    end;

    Canvas.Brush.Color := ChipBg;
    Canvas.Pen.Color := ChipBg;
    Canvas.RoundRect(x, 4, x + ChipW, Height - 4, FCornerRadius, FCornerRadius);

    Canvas.Brush.Style := bsClear;
    Canvas.Font.Color := ChipTxtCol;
    Canvas.TextOut(x + Pad, (Height - Canvas.TextHeight(Txt)) div 2, Txt);

    x := x + ChipW + 8;
  end;
end;

procedure TLazDroidChipGroup.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, CurX, ChipW, Pad: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  Canvas.Font := Font;
  CurX := 4;
  Pad := 12;

  for i := 0 to FItems.Count - 1 do
  begin
    ChipW := Canvas.TextWidth(FItems[i]) + (Pad * 2);
    if (X >= CurX) and (X <= CurX + ChipW) then
    begin
      ToggleSelected(i);
      Exit;
    end;
    CurX := CurX + ChipW + 8;
  end;
end;

{ =============================================================================
  TLazDroidRadioGroup
  ============================================================================= }

constructor TLazDroidRadioGroup.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 220;
  Height := 140;
  FItems := TStringList.Create;
  TStringList(FItems).OnChange := @ItemsChanged;
  FItems.Add('Dinheiro / À Vista');
  FItems.Add('Cartão de Débito');
  FItems.Add('Cartão de Crédito');
  FItems.Add('Pix');
  FItemIndex := 0;
  FItemHeight := 34;
  FActiveColor := $00D97706;
  FInactiveColor := $0094A3B8;
  Color := clWhite;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
end;

destructor TLazDroidRadioGroup.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TLazDroidRadioGroup.SetItems(const AValue: TStrings);
begin
  FItems.Assign(AValue);
end;

procedure TLazDroidRadioGroup.SetItemIndex(const AValue: Integer);
begin
  if (AValue >= -1) and (AValue < FItems.Count) and (FItemIndex <> AValue) then
  begin
    FItemIndex := AValue;
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

procedure TLazDroidRadioGroup.ItemsChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TLazDroidRadioGroup.Paint;
var
  ParentBg: TColor;
  i, RowTop, CircleX, CircleY, RadioR: Integer;
  Txt: string;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  RadioR := 9;
  Canvas.Font := Font;

  for i := 0 to FItems.Count - 1 do
  begin
    RowTop := i * FItemHeight;
    CircleX := 16;
    CircleY := RowTop + (FItemHeight div 2);

    if i = FItemIndex then
    begin
      Canvas.Brush.Color := clWhite;
      Canvas.Pen.Color := FActiveColor;
      Canvas.Pen.Width := 2;
      Canvas.Ellipse(CircleX - RadioR, CircleY - RadioR, CircleX + RadioR, CircleY + RadioR);

      Canvas.Brush.Color := FActiveColor;
      Canvas.Pen.Color := FActiveColor;
      Canvas.Ellipse(CircleX - 4, CircleY - 4, CircleX + 4, CircleY + 4);
    end
    else
    begin
      Canvas.Brush.Color := clWhite;
      Canvas.Pen.Color := FInactiveColor;
      Canvas.Pen.Width := 2;
      Canvas.Ellipse(CircleX - RadioR, CircleY - RadioR, CircleX + RadioR, CircleY + RadioR);
    end;

    Txt := FItems[i];
    Canvas.Brush.Style := bsClear;
    Canvas.Font.Color := $001E293B;
    Canvas.TextOut(CircleX + RadioR + 12, CircleY - (Canvas.TextHeight(Txt) div 2), Txt);
  end;
end;

procedure TLazDroidRadioGroup.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ClickedIdx: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  if FItemHeight <= 0 then Exit;
  ClickedIdx := Y div FItemHeight;
  if (ClickedIdx >= 0) and (ClickedIdx < FItems.Count) then
    SetItemIndex(ClickedIdx);
end;

{ =============================================================================
  TLazDroidOtpBox
  ============================================================================= }

constructor TLazDroidOtpBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csRequiresKeyboardInput, csOpaque];
  TabStop := True;
  Width := 240;
  Height := 56;
  FCode := '';
  FCodeLength := 4;
  FBoxSize := 48;
  FBoxSpacing := 10;
  FBorderColor := $00CBD5E1;
  FFocusedColor := $00D97706;
  FCornerRadius := 8;
  FIsPassword := False;
  FIsFocused := False;
  Font.Name := 'Segoe UI';
  Font.Size := 16;
  Font.Style := [fsBold];
end;

procedure TLazDroidOtpBox.SetCode(const AValue: string);
begin
  if FCode <> AValue then
  begin
    FCode := Copy(AValue, 1, FCodeLength);
    Invalidate;
    if Assigned(FOnChange) then FOnChange(Self);
    if (Length(FCode) = FCodeLength) and Assigned(FOnComplete) then FOnComplete(Self);
  end;
end;

procedure TLazDroidOtpBox.SetCodeLength(const AValue: Integer);
begin
  if (AValue >= 3) and (AValue <= 8) and (FCodeLength <> AValue) then
  begin
    FCodeLength := AValue;
    if Length(FCode) > FCodeLength then
      FCode := Copy(FCode, 1, FCodeLength);
    Invalidate;
  end;
end;

procedure TLazDroidOtpBox.Clear;
begin
  SetCode('');
end;

procedure TLazDroidOtpBox.DoEnter;
begin
  inherited DoEnter;
  FIsFocused := True;
  Invalidate;
end;

procedure TLazDroidOtpBox.DoExit;
begin
  inherited DoExit;
  FIsFocused := False;
  Invalidate;
end;

procedure TLazDroidOtpBox.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if CanFocus then SetFocus;
end;

procedure TLazDroidOtpBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if Key = VK_BACK then
  begin
    if Length(FCode) > 0 then
    begin
      Delete(FCode, Length(FCode), 1);
      Invalidate;
      if Assigned(FOnChange) then FOnChange(Self);
    end;
  end;
end;

procedure TLazDroidOtpBox.UTF8KeyPress(var UTF8Key: TUTF8Char);
begin
  inherited UTF8KeyPress(UTF8Key);
  if (UTF8Key >= '0') and (UTF8Key <= '9') then
  begin
    if Length(FCode) < FCodeLength then
    begin
      FCode := FCode + UTF8Key;
      Invalidate;
      if Assigned(FOnChange) then FOnChange(Self);
      if (Length(FCode) = FCodeLength) and Assigned(FOnComplete) then
        FOnComplete(Self);
    end;
  end;
end;

procedure TLazDroidOtpBox.Paint;
var
  ParentBg: TColor;
  i, TotalW, StartX, BoxLeft, BoxTop: Integer;
  DigitChar: Char;
  tx, ty: Integer;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  TotalW := (FCodeLength * FBoxSize) + ((FCodeLength - 1) * FBoxSpacing);
  StartX := (Width - TotalW) div 2;
  BoxTop := (Height - FBoxSize) div 2;

  Canvas.Font := Font;

  for i := 0 to FCodeLength - 1 do
  begin
    BoxLeft := StartX + (i * (FBoxSize + FBoxSpacing));

    Canvas.Brush.Color := clWhite;

    if FIsFocused and (i = Length(FCode)) then
    begin
      Canvas.Pen.Color := FFocusedColor;
      Canvas.Pen.Width := 2;
    end
    else
    begin
      Canvas.Pen.Color := FBorderColor;
      Canvas.Pen.Width := 1;
    end;

    Canvas.RoundRect(BoxLeft, BoxTop, BoxLeft + FBoxSize, BoxTop + FBoxSize, FCornerRadius, FCornerRadius);

    if i < Length(FCode) then
    begin
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := $001E293B;

      if FIsPassword then
      begin
        Canvas.Brush.Color := $001E293B;
        Canvas.Ellipse(BoxLeft + (FBoxSize div 2) - 4, BoxTop + (FBoxSize div 2) - 4,
                       BoxLeft + (FBoxSize div 2) + 4, BoxTop + (FBoxSize div 2) + 4);
      end
      else
      begin
        DigitChar := FCode[i + 1];
        tx := BoxLeft + (FBoxSize - Canvas.TextWidth(DigitChar)) div 2;
        ty := BoxTop + (FBoxSize - Canvas.TextHeight(DigitChar)) div 2;
        Canvas.TextOut(tx, ty, DigitChar);
      end;
    end;
  end;
end;

{ =============================================================================
  TLazDroidSignaturePad
  ============================================================================= }

constructor TLazDroidSignaturePad.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 300;
  Height := 160;
  FBuffer := TBitmap.Create;
  FPenColor := clBlack;
  FPenWidth := 3;
  FBorderColor := $00CBD5E1;
  FCornerRadius := 8;
  FWatermarkText := 'Assine aqui com o dedo';
  FIsDrawing := False;
  FIsSigned := False;
  Color := clWhite;
  Font.Name := 'Segoe UI';
  Font.Size := 11;
end;

destructor TLazDroidSignaturePad.Destroy;
begin
  FBuffer.Free;
  inherited Destroy;
end;

procedure TLazDroidSignaturePad.EnsureBuffer;
begin
  if (FBuffer.Width <> Width) or (FBuffer.Height <> Height) then
  begin
    FBuffer.SetSize(Width, Height);
    FBuffer.Canvas.Brush.Color := clWhite;
    FBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));
  end;
end;

procedure TLazDroidSignaturePad.Resize;
begin
  inherited Resize;
  EnsureBuffer;
end;

procedure TLazDroidSignaturePad.Clear;
begin
  FBuffer.Canvas.Brush.Color := clWhite;
  FBuffer.Canvas.FillRect(Rect(0, 0, Width, Height));
  FIsSigned := False;
  Invalidate;
end;

procedure TLazDroidSignaturePad.SaveToFile(const AFileName: string);
begin
  EnsureBuffer;
  FBuffer.SaveToFile(AFileName);
end;

procedure TLazDroidSignaturePad.SaveToStream(AStream: TStream);
begin
  EnsureBuffer;
  FBuffer.SaveToStream(AStream);
end;

procedure TLazDroidSignaturePad.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  EnsureBuffer;
  FIsDrawing := True;
  FLastPoint := Point(X, Y);
  FIsSigned := True;
  if Assigned(FOnSigned) then FOnSigned(Self);
end;

procedure TLazDroidSignaturePad.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  if FIsDrawing then
  begin
    FBuffer.Canvas.Pen.Color := FPenColor;
    FBuffer.Canvas.Pen.Width := FPenWidth;
    FBuffer.Canvas.Pen.Style := psSolid;
    FBuffer.Canvas.Line(FLastPoint.X, FLastPoint.Y, X, Y);
    FLastPoint := Point(X, Y);
    Invalidate;
  end;
end;

procedure TLazDroidSignaturePad.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  FIsDrawing := False;
end;

procedure TLazDroidSignaturePad.Paint;
var
  R: TRect;
  tx, ty, BaselineY: Integer;
begin
  EnsureBuffer;
  R := ClientRect;

  Canvas.Draw(0, 0, FBuffer);

  if not FIsSigned then
  begin
    BaselineY := Height - 36;
    Canvas.Pen.Color := $00E2E8F0;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Style := psDot;
    Canvas.Line(20, BaselineY, Width - 20, BaselineY);

    if FWatermarkText <> '' then
    begin
      Canvas.Brush.Style := bsClear;
      Canvas.Font := Font;
      Canvas.Font.Color := $0094A3B8;
      tx := (Width - Canvas.TextWidth(FWatermarkText)) div 2;
      ty := BaselineY - Canvas.TextHeight(FWatermarkText) - 8;
      Canvas.TextOut(tx, ty, FWatermarkText);
    end;
  end;

  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Color := FBorderColor;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Style := psSolid;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);
end;

{ =============================================================================
  TLazDroidKeypad
  ============================================================================= }

constructor TLazDroidKeypad.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 260;
  Height := 240;
  FTargetEdit := nil;
  FValue := '';
  FShowDoubleZero := True;
  FButtonColor := $00F8FAFC;
  FActionColor := $00D97706;
  FTextColor := $001E293B;
  FCornerRadius := 8;
  Color := $00F1F5F9;
  Font.Name := 'Segoe UI';
  Font.Size := 14;
  Font.Style := [fsBold];
end;

procedure TLazDroidKeypad.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FTargetEdit) then
    FTargetEdit := nil;
end;

function TLazDroidKeypad.GetKeyAt(X, Y: Integer): string;
var
  ColW, RowH, Col, Row: Integer;
  const KeyMap: array[0..3, 0..2] of string = (
    ('1', '2', '3'),
    ('4', '5', '6'),
    ('7', '8', '9'),
    ('00', '0', 'DEL')
  );
begin
  Result := '';
  ColW := Width div 3;
  RowH := Height div 4;
  if (ColW <= 0) or (RowH <= 0) then Exit;
  Col := X div ColW;
  Row := Y div RowH;
  if (Row >= 0) and (Row <= 3) and (Col >= 0) and (Col <= 2) then
  begin
    Result := KeyMap[Row, Col];
    if (Result = '00') and not FShowDoubleZero then
      Result := 'C';
  end;
end;

procedure TLazDroidKeypad.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  K: string;
begin
  inherited MouseDown(Button, Shift, X, Y);
  K := GetKeyAt(X, Y);
  if K = '' then Exit;

  if K = 'DEL' then
  begin
    if Length(FValue) > 0 then
      Delete(FValue, Length(FValue), 1);
    if Assigned(FTargetEdit) then
      FTargetEdit.Text := FValue;
  end
  else if K = 'C' then
  begin
    FValue := '';
    if Assigned(FTargetEdit) then
      FTargetEdit.Text := '';
  end
  else
  begin
    FValue := FValue + K;
    if Assigned(FTargetEdit) then
      FTargetEdit.Text := FValue;
  end;

  if Assigned(FOnKeyPress) then FOnKeyPress(Self, K);
end;

procedure TLazDroidKeypad.Paint;
var
  ColW, RowH, r, c, kx, ky, kw, kh, Pad: Integer;
  KeyLabel: string;
  const KeyMap: array[0..3, 0..2] of string = (
    ('1', '2', '3'),
    ('4', '5', '6'),
    ('7', '8', '9'),
    ('00', '0', '⌫')
  );
begin
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);

  ColW := Width div 3;
  RowH := Height div 4;
  Pad := 3;

  Canvas.Font := Font;

  for r := 0 to 3 do
  begin
    for c := 0 to 2 do
    begin
      kx := c * ColW + Pad;
      ky := r * RowH + Pad;
      kw := ColW - (Pad * 2);
      kh := RowH - (Pad * 2);

      KeyLabel := KeyMap[r, c];
      if (KeyLabel = '00') and not FShowDoubleZero then
        KeyLabel := 'C';

      if (r = 3) and (c = 2) then
      begin
        Canvas.Brush.Color := $00FEE2E2;
        Canvas.Pen.Color := $00FECACA;
        Canvas.RoundRect(kx, ky, kx + kw, ky + kh, FCornerRadius, FCornerRadius);
        Canvas.Font.Color := $00B91C1C;
      end
      else
      begin
        Canvas.Brush.Color := FButtonColor;
        Canvas.Pen.Color := $00E2E8F0;
        Canvas.RoundRect(kx, ky, kx + kw, ky + kh, FCornerRadius, FCornerRadius);
        Canvas.Font.Color := FTextColor;
      end;

      Canvas.Brush.Style := bsClear;
      Canvas.TextOut(kx + (kw - Canvas.TextWidth(KeyLabel)) div 2,
                     ky + (kh - Canvas.TextHeight(KeyLabel)) div 2,
                     KeyLabel);
    end;
  end;
end;

{ =============================================================================
  TLazDroidMetricCard
  ============================================================================= }

constructor TLazDroidMetricCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 200;
  Height := 105;
  FTitle := 'Vendas Hoje';
  FValue := 'R$ 4.850,00';
  FDeltaText := '+12.5%';
  FDeltaIsPositive := True;
  FSubtitle := 'vs ontem';
  FCardColor := clWhite;
  FBorderColor := $00E2E8F0;
  FCornerRadius := 12;
  FIcon := aiTrendingUp;
  FIconColor := $00D97706;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
end;

procedure TLazDroidMetricCard.Paint;
var
  ParentBg, BadgeBg, BadgeTxt: TColor;
  R, BadgeRect, IconRect: TRect;
  BadgeW: Integer;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  R := ClientRect;
  Canvas.Brush.Color := FCardColor;
  Canvas.Pen.Color := FBorderColor;
  Canvas.Pen.Width := 1;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, FCornerRadius, FCornerRadius);

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Name := 'Segoe UI';
  Canvas.Font.Size := 8;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := $0064748B;
  Canvas.TextOut(14, 12, UpperCase(FTitle));

  if FIcon <> aiNone then
  begin
    IconRect := Rect(Width - 36, 10, Width - 14, 32);
    DrawMobileIcon(Canvas, FIcon, IconRect, FIconColor);
  end;

  Canvas.Font.Size := 15;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := $000F172A;
  Canvas.TextOut(14, 34, FValue);

  if FDeltaText <> '' then
  begin
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [fsBold];
    BadgeW := Canvas.TextWidth(FDeltaText) + 12;
    BadgeRect := Rect(14, Height - 30, 14 + BadgeW, Height - 12);

    if FDeltaIsPositive then
    begin
      BadgeBg := $00DCFCE7;
      BadgeTxt := $0015803D;
    end
    else
    begin
      BadgeBg := $00FEE2E2;
      BadgeTxt := $00B91C1C;
    end;

    Canvas.Brush.Color := BadgeBg;
    Canvas.Pen.Color := BadgeBg;
    Canvas.RoundRect(BadgeRect.Left, BadgeRect.Top, BadgeRect.Right, BadgeRect.Bottom, 6, 6);

    Canvas.Brush.Style := bsClear;
    Canvas.Font.Color := BadgeTxt;
    Canvas.TextOut(BadgeRect.Left + 6, BadgeRect.Top + 2, FDeltaText);

    if FSubtitle <> '' then
    begin
      Canvas.Font.Style := [];
      Canvas.Font.Color := $0094A3B8;
      Canvas.TextOut(BadgeRect.Right + 8, BadgeRect.Top + 2, FSubtitle);
    end;
  end;
end;

{ =============================================================================
  TLazDroidBottomSheet
  ============================================================================= }

constructor TLazDroidBottomSheet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls];
  Align := alBottom;
  Height := 180;
  FTitle := 'Opções';
  FCornerRadius := 16;
  FHeaderColor := $00F8FAFC;
  FIsOpen := True;
  Color := clWhite;
  Font.Name := 'Segoe UI';
  Font.Size := 10;
end;

procedure TLazDroidBottomSheet.SetIsOpen(const AValue: Boolean);
begin
  if FIsOpen <> AValue then
  begin
    FIsOpen := AValue;
    Visible := FIsOpen;
    if not FIsOpen and Assigned(FOnClose) then FOnClose(Self);
  end;
end;

procedure TLazDroidBottomSheet.OpenSheet;
begin
  SetIsOpen(True);
end;

procedure TLazDroidBottomSheet.CloseSheet;
begin
  SetIsOpen(False);
end;

procedure TLazDroidBottomSheet.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  if (X >= Width - 36) and (Y <= 36) then
    CloseSheet;
end;

procedure TLazDroidBottomSheet.Paint;
var
  R, CloseRect: TRect;
  HandleW, HandleLeft: Integer;
begin
  R := ClientRect;

  Canvas.Brush.Color := Color;
  Canvas.Pen.Color := $00CBD5E1;
  Canvas.Pen.Width := 1;
  Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom + FCornerRadius, FCornerRadius, FCornerRadius);

  HandleW := 36;
  HandleLeft := (Width - HandleW) div 2;
  Canvas.Brush.Color := $00CBD5E1;
  Canvas.Pen.Color := $00CBD5E1;
  Canvas.RoundRect(HandleLeft, 6, HandleLeft + HandleW, 10, 3, 3);

  if FTitle <> '' then
  begin
    Canvas.Brush.Style := bsClear;
    Canvas.Font := Font;
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Color := $001E293B;
    Canvas.TextOut(16, 16, FTitle);

    CloseRect := Rect(Width - 32, 12, Width - 14, 30);
    DrawMobileIcon(Canvas, aiClose, CloseRect, $0064748B);

    Canvas.Pen.Color := $00F1F5F9;
    Canvas.Line(0, 40, Width, 40);
  end;
end;

{ =============================================================================
  TLazDroidSpeedDial
  ============================================================================= }

constructor TLazDroidSpeedDial.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 56;
  Height := 56;
  FItems := TStringList.Create;
  FIsOpen := False;
  FButtonColor := $00D97706;
  FIconColor := clWhite;
  FSubButtonColor := $000284C7;
  Font.Name := 'Segoe UI';
  Font.Size := 9;
  Font.Style := [fsBold];

  FItems.Add('Novo Pedido');
  FItems.Add('Novo Cliente');
end;

destructor TLazDroidSpeedDial.Destroy;
begin
  FItems.Free;
  inherited Destroy;
end;

procedure TLazDroidSpeedDial.SetItems(const AValue: TStrings);
begin
  FItems.Assign(AValue);
end;

procedure TLazDroidSpeedDial.SetIsOpen(const AValue: Boolean);
var
  TargetH: Integer;
begin
  if FIsOpen <> AValue then
  begin
    FIsOpen := AValue;
    if FIsOpen then
    begin
      TargetH := 56 + (FItems.Count * 50);
      Top := Top - (TargetH - Height);
      Height := TargetH;
    end
    else
    begin
      Top := Top + (Height - 56);
      Height := 56;
    end;
    Invalidate;
  end;
end;

procedure TLazDroidSpeedDial.Toggle;
begin
  SetIsOpen(not FIsOpen);
end;

function TLazDroidSpeedDial.GetSubButtonRect(Index: Integer): TRect;
var
  BtnTop, BtnLeft: Integer;
begin
  BtnTop := Height - 56 - ((Index + 1) * 48);
  BtnLeft := (Width - 42) div 2;
  Result := Rect(BtnLeft, BtnTop, BtnLeft + 42, BtnTop + 42);
end;

procedure TLazDroidSpeedDial.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  MainRect: TRect;
  i: Integer;
begin
  inherited MouseDown(Button, Shift, X, Y);
  MainRect := Rect(0, Height - 56, Width, Height);

  if PtInRect(MainRect, Point(X, Y)) then
  begin
    Toggle;
    Exit;
  end;

  if FIsOpen then
  begin
    for i := 0 to FItems.Count - 1 do
    begin
      if PtInRect(GetSubButtonRect(i), Point(X, Y)) then
      begin
        Toggle;
        if Assigned(FOnItemClick) then FOnItemClick(Self, i);
        Exit;
      end;
    end;
  end;
end;

procedure TLazDroidSpeedDial.Paint;
var
  ParentBg: TColor;
  MainTop, i: Integer;
  SubR, MainIconRect: TRect;
  IconToDraw: TLazDroidActionIcon;
  Txt: string;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  MainTop := Height - 56;

  if FIsOpen then
  begin
    Canvas.Font := Font;
    for i := 0 to FItems.Count - 1 do
    begin
      SubR := GetSubButtonRect(i);
      Canvas.Brush.Color := FSubButtonColor;
      Canvas.Pen.Color := FSubButtonColor;
      Canvas.Ellipse(SubR.Left, SubR.Top, SubR.Right, SubR.Bottom);

      DrawMobileIcon(Canvas, aiPlus, Rect(SubR.Left + 8, SubR.Top + 8, SubR.Right - 8, SubR.Bottom - 8), clWhite);

      Txt := FItems[i];
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := $001E293B;
      Canvas.TextOut(SubR.Right + 8, SubR.Top + 12, Txt);
    end;
  end;

  Canvas.Brush.Color := FButtonColor;
  Canvas.Pen.Color := FButtonColor;
  Canvas.Ellipse(0, MainTop, Width, Height);

  if FIsOpen then
    IconToDraw := aiClose
  else
    IconToDraw := aiPlus;

  MainIconRect := Rect(Round(Width * 0.22), MainTop + Round(56 * 0.22),
                       Round(Width * 0.78), MainTop + Round(56 * 0.78));
  DrawMobileIcon(Canvas, IconToDraw, MainIconRect, FIconColor);
end;

{ =============================================================================
  TLazDroidSectionHeader
  ============================================================================= }

constructor TLazDroidSectionHeader.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align := alTop;
  Height := 28;
  FCaption := 'SEÇÃO';
  FLineColor := $00E2E8F0;
  FTextColor := $0064748B;
  FShowLine := True;
  Font.Name := 'Segoe UI';
  Font.Size := 8;
  Font.Style := [fsBold];
end;

procedure TLazDroidSectionHeader.SetCaption(const AValue: string);
begin
  if FCaption <> AValue then
  begin
    FCaption := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidSectionHeader.SetLineColor(const AValue: TColor);
begin
  if FLineColor <> AValue then
  begin
    FLineColor := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidSectionHeader.SetTextColor(const AValue: TColor);
begin
  if FTextColor <> AValue then
  begin
    FTextColor := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidSectionHeader.SetShowLine(const AValue: Boolean);
begin
  if FShowLine <> AValue then
  begin
    FShowLine := AValue;
    Invalidate;
  end;
end;

procedure TLazDroidSectionHeader.Paint;
var
  TextW, TextY, LineY: Integer;
begin
  Canvas.Font := Font;
  Canvas.Font.Color := FTextColor;
  Canvas.Brush.Style := bsClear;

  TextY := (Height - Canvas.TextHeight(FCaption)) div 2;
  Canvas.TextOut(8, TextY, FCaption);

  if FShowLine then
  begin
    TextW := Canvas.TextWidth(FCaption);
    LineY := Height div 2;
    Canvas.Pen.Color := FLineColor;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Style := psSolid;
    Canvas.Line(TextW + 18, LineY, Width - 8, LineY);
  end;
end;

{ =============================================================================
  TLazDroidAvatar
  ============================================================================= }

constructor TLazDroidAvatar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 48;
  Height := 48;
  FFullName := 'User';
  FAvatarColor := clNone;
  FTextColor := clWhite;
  FShowStatus := False;
  FIsOnline := True;
  Font.Name := 'Segoe UI';
  Font.Size := 12;
  Font.Style := [fsBold];
end;

procedure TLazDroidAvatar.SetFullName(const AValue: string);
begin
  if FFullName <> AValue then
  begin
    FFullName := AValue;
    Invalidate;
  end;
end;

function TLazDroidAvatar.GenerateAvatarColor(const AName: string): TColor;
var
  Hash, i: Integer;
  const Palette: array[0..5] of TColor = (
    $00D97706,
    $000284C7,
    $00059669,
    $007C3AED,
    $00DB2777,
    $00EA580C
  );
begin
  if AName = '' then
  begin
    Result := Palette[0];
    Exit;
  end;
  Hash := 0;
  for i := 1 to Length(AName) do
    Hash := (Hash + Ord(AName[i])) mod 6;
  Result := Palette[Hash];
end;

function TLazDroidAvatar.GetInitials: string;
var
  SpacePos: Integer;
  FirstChar, SecondChar: Char;
begin
  Result := '';
  if Length(FFullName) = 0 then
  begin
    Result := '?';
    Exit;
  end;
  FirstChar := FFullName[1];
  SpacePos := Pos(' ', FFullName);
  if (SpacePos > 0) and (SpacePos < Length(FFullName)) then
    SecondChar := FFullName[SpacePos + 1]
  else
    SecondChar := ' ';

  Result := UpperCase(FirstChar);
  if SecondChar <> ' ' then
    Result := Result + UpperCase(SecondChar);
end;

procedure TLazDroidAvatar.Paint;
var
  ParentBg, CircleCol, StatusCol: TColor;
  Initials: string;
  tx, ty, StatusSize: Integer;
begin
  ParentBg := GetRGBColorResolvingParent;
  Canvas.Brush.Color := ParentBg;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(ClientRect);

  if FAvatarColor = clNone then
    CircleCol := GenerateAvatarColor(FFullName)
  else
    CircleCol := FAvatarColor;

  Canvas.Brush.Color := CircleCol;
  Canvas.Pen.Color := CircleCol;
  Canvas.Ellipse(0, 0, Width, Height);

  Initials := GetInitials;
  Canvas.Brush.Style := bsClear;
  Canvas.Font := Font;
  Canvas.Font.Color := FTextColor;
  tx := (Width - Canvas.TextWidth(Initials)) div 2;
  ty := (Height - Canvas.TextHeight(Initials)) div 2;
  Canvas.TextOut(tx, ty, Initials);

  if FShowStatus then
  begin
    StatusSize := Math.Max(8, Width div 5);
    if FIsOnline then
      StatusCol := $0022C55E
    else
      StatusCol := $0094A3B8;

    Canvas.Brush.Color := clWhite;
    Canvas.Pen.Color := clWhite;
    Canvas.Ellipse(Width - StatusSize - 3, Height - StatusSize - 3, Width, Height);

    Canvas.Brush.Color := StatusCol;
    Canvas.Pen.Color := StatusCol;
    Canvas.Ellipse(Width - StatusSize - 1, Height - StatusSize - 1, Width - 1, Height - 1);
  end;
end;

{ =============================================================================
  Registro de Componentes no Lazarus
  ============================================================================= }

procedure Register;
begin
  RegisterComponents('LazDroid', [
    TLazDroidAppBar,
    TLazDroidButton,
    TLazDroidEdit,
    TLazDroidCard,
    TLazDroidBadge,
    TLazDroidSwitch,
    TLazDroidActivityIndicator,
    TLazDroidFAB,
    TLazDroidLayout,
    TLazDroidBottomNav,
    TLazDroidListView,
    TLazDroidDatePicker,
    TLazDroidTimePicker,
    TLazDroidProgressBar,
    TLazDroidSlider,
    TLazDroidSegmentedControl,
    TLazDroidCheckBox,
    TLazDroidRatingBar,
    TLazDroidSearchBar,
    TLazDroidChipGroup,
    TLazDroidRadioGroup,
    TLazDroidOtpBox,
    TLazDroidSignaturePad,
    TLazDroidKeypad,
    TLazDroidMetricCard,
    TLazDroidBottomSheet,
    TLazDroidSpeedDial,
    TLazDroidSectionHeader,
    TLazDroidAvatar
  ]);
  RegisterClasses([
    TLazDroidAppBar,
    TLazDroidButton,
    TLazDroidEdit,
    TLazDroidCard,
    TLazDroidBadge,
    TLazDroidSwitch,
    TLazDroidActivityIndicator,
    TLazDroidFAB,
    TLazDroidLayout,
    TLazDroidBottomNav,
    TLazDroidListView,
    TLazDroidDatePicker,
    TLazDroidTimePicker,
    TLazDroidProgressBar,
    TLazDroidSlider,
    TLazDroidSegmentedControl,
    TLazDroidCheckBox,
    TLazDroidRatingBar,
    TLazDroidSearchBar,
    TLazDroidChipGroup,
    TLazDroidRadioGroup,
    TLazDroidOtpBox,
    TLazDroidSignaturePad,
    TLazDroidKeypad,
    TLazDroidMetricCard,
    TLazDroidBottomSheet,
    TLazDroidSpeedDial,
    TLazDroidSectionHeader,
    TLazDroidAvatar,
    TLazDroidListItem
  ]);
end;

initialization
  {$I LazDroidControls.lrs}

end.
