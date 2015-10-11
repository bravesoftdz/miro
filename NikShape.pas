unit NikShape;

// 12.11.98 Proposta(?): aggiungere un wmf interno a NikShape
// fare ogni paint su canvas e anche su questo wmf. In questo modo
// avremo un'immagine gia' pronta del contenuto (potrebbe servire per stampare
// per esempio, senza rigenerare tutto)
// varra' la pena? sara' una sesquipedale cazzata?

interface

uses Messages,Windows,SysUtils,Graphics, Classes, Controls, BarcodeR,
  Menus, Printers, ExtCtrls {TPanel};

type

  TAngledValues = record
    TextWidth, TextHeight,
    GapTextWidth, GapTextHeight,
    TotalWidth, TotalHeight,
    posX, posY: Integer
  end;

  TNikShapeType = (stRectangle, stSquare, stRoundRect, stRoundSquare, stEllipse,
    stCircle, stText, stBarcode, stImage, stSelect, stSetup, stLine);

  TNikPanel = class(TPanel)
  published
    property Canvas;
  end;

  TNikShape = class;

  TNikShape = class(TGraphicControl)
  private
    FWmm,FHmm,FLmm,
    FTmm              : single; // coordinate e dimensioni in mm
    FName             : string;
    FShape            : TNikShapeType;
    FLinkTo,                    // preleva il testo da questo
    FLinkTop,                   // allinea Left e Top
    FLinkLeft         : TNikShape;
    FReserved         : Byte;
    FPen              : TPen;
    FBrush            : TBrush;
    FTesto            : string;
    FSSCC             : string;   // Ean128: SSCC
    FSSCCCD           : char;
    FNarrowWidth      : single;
    FAngle            : integer;
    FBCWidth          : integer;
    FBcType           : TBarcodeType;
    FTestoInChiaro    : boolean;
    FPixelX,FPixelY,FScaleX,FScaleY   : single;
    aValues           : TAngledValues;
    FSelected         : boolean;
    FAlignment        : TAlignment;
    FImage            : TGraphic;
    FImagePath        : string;
    Grabbed           : Boolean;
    Inspected         : boolean;
    Resizing          : Boolean;
    XX,YY             : Integer;
    FFont             : TFont;
    FPop              : TPopupMenu;
    FOrient           : TPrinterOrientation;
    _bPrinting        : boolean;
// Impostazioni foglio stampante
    FPageSize, FPageWidth, FPageHeight : short;
//    function GetCanvasImage : TBitmap;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure SetTesto(Testo: string);
    procedure SetBrush(Value: TBrush);
    procedure SetPen(Value: TPen);
    procedure SetShape(Value: TNikShapeType);
    function MM2Pixel(const scala, mmSize : single) : integer;
    function Pixel2MM(const iPixel : integer; const scala : single) : single;
    procedure SetLinkTo(const nsLink : TNikShape);
    procedure SetLinkTop(const nsLink : TNikShape);
    procedure SetLinkLeft(const nsLink : TNikShape);
    procedure SetSSCC(const sSSCC : string);
  public
    procedure Paint2Canvas(aCanvas : TCanvas);
    procedure SetDriverMode;
    procedure GetPrinterSetup;
    procedure SetImage(const sPath : string);
    property Alignment : TAlignment read FAlignment write FAlignment;
    property Canvas;
    procedure Seleziona(const bStato : boolean);
    procedure Ricalcola(aCanvas : TCanvas);
    procedure Print;
    procedure Paint; override;
    procedure SelectObj(Sender : TObject);
    procedure InspectObject(Sender : TObject);
    constructor Clone(AOwner: TComponent; const nsSrc : TNikShape);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Selected : boolean read FSelected write Seleziona;
    property PagWidth   : short read FPageWidth write FPageWidth;
    property PagHeight  : short read FPageHeight write FPageHeight;
    property PagSize  : short read FPageSize write FPageSize;
    property Wmm : single read FWmm write FWmm;
    property Hmm : single read FHmm write FHmm;
    property Lmm : single read FLmm write FLmm;
    property Tmm : single read FTmm write FTmm;
    property Orient : TPrinterOrientation read FOrient write FOrient;
    property PopupMenu : TPopupMenu read FPop write FPop;
    procedure StyleChanged(Sender: TObject);
    property ScaleX : single read FScaleX write FScaleX;
    property ScaleY : single read FScaleY write FScaleY;
    property Nome : string read FName write FName;
    property Font : TFont read FFont write FFont;
    property BCWidth : integer read FBCWidth write FBCWidth;
    property ImagePath : string read FImagePath write FImagePath;
    property LinkTo : TNikShape read FLinkTo write SetLinkTo;
    property LinkTop : TNikShape read FLinkTop write SetLinkTop;
    property LinkLeft : TNikShape read FLinkLeft write SetLinkLeft;
    property Image : TGraphic read FImage;
    property NarrowWidth : single read FNarrowWidth write FNarrowWidth;
    property Brush: TBrush read FBrush write SetBrush;
    property Barcode : TBarCodeType read FBCtype write FBCType;
    property Angolo : integer read FAngle write FAngle;
    property TestoInChiaro : boolean read FTestoInChiaro write FTestoInChiaro;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ParentShowHint;
    property Pen: TPen read FPen write SetPen;
    property Shape: TNikShapeType read FShape write SetShape default stRectangle;
    property Testo : string read FTesto write SetTesto;
    property SSCC: string read FSSCC write SetSSCC;
    property SSCCCD: char read FSSCCCD write FSSCCCD;
    property ShowHint;
    property Visible;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
  end;

  procedure Register;

const
// Ean 128 AI
  _AI_SSCC  = '00';
  _SSCC_LEN = 17;

var
  SelectedShape : TNikShape;
  X2, X1, Y1, Y2 : integer;

  function Min(A,B: Integer): Integer;
  procedure DrawGriglia(nsShape : TNikShape; const bOn : boolean);

implementation


uses fmInspector, Forms, DsgnIntF, VCLUtils;


function Min(A,B: Integer): Integer;
begin
  if A < B then Result := A Else Result := B;
end;

procedure Register;
begin
  RegisterComponents('Nik Controls', [TNikPanel]);
  RegisterComponents('Nik Controls', [TNikShape]);
  RegisterComponentEditor(TNikShape, TObjInspector);
end;

{ TNikShape }
constructor TNikShape.Clone(aOwner : TComponent; const nsSrc : TNikShape);
const _GAP = 10;
begin
  Create(AOwner);
  Width     := nsSrc.Width;
  Height    := nsSrc.Height;
  Alignment := nsSrc.Alignment;
  Pen.Assign(nsSrc.Pen);
  Font.Assign(nsSrc.Font);
  Testo     := nsSrc.Testo;
  Angolo    := nsSrc.Angolo;
  Shape     := nsSrc.Shape;
  Barcode   := nsSrc.Barcode;
  Left      := nsSrc.Left + _GAP;
  Top       := nsSrc.Top + _GAP;
  FNarrowWidth := nsSrc.FNarrowWidth;
end;

constructor TNikShape.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle  := ControlStyle + [csReplicatable];
  Width         := 65;
  Height        := 65;
  FPen          := TPen.Create;
  FPen.OnChange := StyleChanged;
  FBrush        := TBrush.Create;
  FFont         := TFont.Create;
  FFont.Name    := 'Arial';
  FBrush.OnChange := StyleChanged;
  Alignment    := taLeftJustify;
  Testo        := 'Testo';
  FAngle       := 0;
  FSelected    := False;
  FImage       := nil;
  FSSCC        := '';
  FSSCCCD      := ' ';
  OnClick      := SelectObj;
  OnDblClick   := InspectObject;
  Inspected    := False;
  FNarrowWidth := 1.0;
  FLinkTo := nil; FLinkLeft := nil; FLinkTop := nil;
end;

destructor TNikShape.Destroy;
begin
  FPen.Free;
  FPen := nil;
  FBrush.Free;
  FBrush := nil;
  FFont.Free;
  FFont := nil;
  if FImage <> nil then
    FImage.Free;
  FImage := nil;
{  if FBC <> nil then
    FBC.Free;
  FBC := nil; }
  if SelectedShape=Self then
    SelectedShape:=nil;
  inherited Destroy;
end;

function CalcolaCD(sTestoBC : string) : char;
var iLen,i,cifra,iTotPari,iTotDispari,iCK,errcode,iUnita : integer;
  sCK : string;
begin
  iTotPari    := 0;
  iTotDispari := 0;
  iLen := Length(sTestoBC);
  for i := iLen downto 1 do
  begin
// 1. somma le cifre nelle posizioni pari
    if i mod 2 <> 0 then
    begin
      val(sTestoBC[i], cifra, errcode);
      iTotPari := iTotPari + cifra;
    end;
  end;
(* 2. moltiplica per 3 il risultato 2. *)
  iTotPari := iTotPari * 3;
(* 3. somma le cifre nelle posizioni dispari *)
  for i := iLen downto 1 do
  begin
    if i mod 2 = 0 then
    begin
      val(sTestoBC[i], cifra, errcode);
      iTotDispari := iTotDispari + cifra;
    end;
  end;
(* 4. somma risultati operazioni 3. e 4. *)
  iCK := iTotDispari + iTotPari;
(* 5. sottrai il valore 5. dalla decina immediatamente successiva *)
  iUnita := iCK mod 10;
(* Fix per i casi di multiplo esatto *)
  if iUnita = 0 then iUnita := 10;
  iCK := 10 - iUnita;
(* Appende il checksum al testo *)
//  str(iCK, sCK);
  Result := chr(iCK+ord('0'));
end;

procedure TNikShape.SetSSCC(const sSSCC : string);
begin
  if Length(sSSCC) <> _SSCC_LEN then ;  // TBI
  if sSSCC<>'' then
  begin
    FSSCCCD := CalcolaCD(sSSCC);
    FSSCC   := sSSCC;
    Testo   := _AI_SSCC + FSSCC + FSSCCCD;
  end;
end;

procedure TNikShape.SetLinkTo(const nsLink : TNikShape);
begin
  FLinkTo := nsLink;
  if nsLink <> nil then
    Testo := nsLink.Testo;
end;

procedure TNikShape.SetLinkTop(const nsLink : TNikShape);
begin
  FLinkTop := nsLink;
  if nsLink <> nil then
    Top := nsLink.Top;
end;

procedure TNikShape.SetLinkLeft(const nsLink : TNikShape);
begin
  FLinkLeft := nsLink;
  if nsLink <> nil then
    Left := nsLink.Left;
end;

function TNikShape.MM2Pixel(const scala, mmSize : single) : integer;
var iW : integer;
begin
  Result := -1;
  iW := round((mmSize / 25.4) *scala);
  Result := iW;
end;

function TNikShape.Pixel2MM(const iPixel : integer; const scala : single) : single;
var iW : single;
begin
  Result := -1;
  iW := (iPixel / scala) * 25.4;
  Result := iW;
end;

procedure TNikShape.SetDriverMode;
var
  aDev, aDriver, aPort : array[0..255] of char;
  aDevHnd : THandle;
  DevMode : PDeviceMode;
begin
  Printer.GetPrinter(aDev,aDriver,aPort,aDevHnd);
  if aDevHnd = 0 then begin
    Printer.PrinterIndex := Printer.PrinterIndex;
    Printer.GetPrinter(aDev,aDriver,aPort,aDevHnd);
  end;
  if aDevHnd = 0 then
    raise Exception.Create('Impossibile inizializzare driver di stampa')
  else
    DevMode := GlobalLock(aDevHnd);

  with DevMode^ do
  begin
    dmFields := dmFields or DM_ORIENTATION;
    case Orient of
      poLandscape:  dmOrientation := DMORIENT_LANDSCAPE;
      poPortrait:   dmOrientation := DMORIENT_PORTRAIT;
    end;
  end;

// papersize=0 se dimensioni foglio personalizzate..
  if PagSize=0 then
    with DevMode^ do
    begin
      dmFields := dmFields or DM_PAPERWIDTH or DM_PAPERLENGTH;
      dmPaperWidth  := PagWidth;
      dmPaperLength := PagHeight;
    end
  else
    with DevMode^ do
    begin
      dmFields    := dmFields or DM_PAPERSIZE;
      dmPaperSize := PagSize;
    end;

  if not aDevHnd = 0 then
    GlobalUnlock(aDevHnd);
end;

procedure TNikShape.GetPrinterSetup;
var
  aDev, aDriver, aPort : array[0..255] of char;
  aDevHnd : THandle;
  DevMode : PDeviceMode;
begin
  Printer.GetPrinter(aDev,aDriver,aPort,aDevHnd);
  if aDevHnd = 0 then begin
    Printer.PrinterIndex := Printer.PrinterIndex;
    Printer.GetPrinter(aDev,aDriver,aPort,aDevHnd);
  end;
  if aDevHnd = 0 then
    raise Exception.Create('Impossibile inizializzare driver di stampa')
  else
    DevMode := GlobalLock(aDevHnd);

// Setta orientazione, paper size, width, height
  with DevMode^ do
  begin
    if dmOrientation = DMORIENT_LANDSCAPE then
      Orient := poLandscape
    else
      if dmOrientation = DMORIENT_PORTRAIT then
        Orient := poPortrait;
    PagWidth  := dmPaperWidth;
    PagHeight := dmPaperLength;
    PagSize   := dmPaperSize;
  end;

  if not aDevHnd = 0 then
    GlobalUnlock(aDevHnd);
end;

procedure TNikShape.Seleziona(const bStato : boolean);
begin
  FSelected := bStato;
  if (SelectedShape<>nil) and (SelectedShape <> self) then DrawGriglia(SelectedShape,False);
  DrawGriglia(Self,True);
  SelectedShape := Self;
  Invalidate;
end;

function DegToRad(pDegrees: Real): Real;
begin
  Result := (pDegrees * PI / 180);
end;

procedure SetTextAngle(pCanvas: TCanvas; pAngle: Integer);
{This procedure was writen by Keith Wood}
var
  FntLogRec: TLogFont { Storage area for font information } ;
begin
  { Get the current font information. We only want to modify the angle }
  GetObject(pCanvas.Font.Handle, SizeOf(FntLogRec), Addr(FntLogRec));

  { Modify the angle. "The angle, in tenths of a degrees, between the base
    line of a character and the x-axis." (Windows API Help file.) }
  FntLogRec.lfEscapement := (pAngle * 10);
  FntLogRec.lfOutPrecision := OUT_TT_ONLY_PRECIS;  { Request TrueType precision }

  { Delphi will handle the deallocation of the old font handle }
  pCanvas.Font.Handle := CreateFontIndirect(FntLogRec);
end;

procedure CalculatePositions(pCanvas: TCanvas; pAngle: Integer;
  pCaption: string; var pValues: TAngledValues);
var
  fntWdt, fntHgt: Integer;
  angB: Real;
begin
  with pCanvas do
  begin
    SetTextAngle(pCanvas, pAngle) { Adjust font } ;

    { Calculate intermediate values }
    case pAngle of
      0..89   : angB := DegToRad(90 - pAngle);
      90..179 : angB := DegToRad(pAngle - 90);
      180..269: angB := DegToRad(270 - pAngle);
    else {270..359}
      angB := DegToRad(pAngle - 270);
    end;
    fntWdt := TextWidth(pCaption);
    fntHgt := TextHeight(pCaption);
    pValues.TextWidth     := Round(sin(angB) * fntWdt);
    pValues.GapTextWidth  := Round(cos(angB) * fntHgt);
    pValues.TextHeight    := Round(cos(angB) * fntWdt);
    pValues.GapTextHeight := Round(sin(angB) * fntHgt);

    { Calculate new sizes of component }
    pValues.TotalWidth  := (pValues.TextWidth + pValues.GaptextWidth);
    pValues.TotalHeight := (pValues.TextHeight + pValues.GapTextHeight);

    { Calculate draw position of text }
    case pAngle of
      0..89:
      begin
        pValues.posX := 0;
        pValues.posY := pValues.TextHeight
      end;
      90..179:
      begin
        pValues.posX := pValues.TextWidth;
        pValues.posY := pValues.TotalHeight
      end;
      180..269:
      begin
        pValues.posX := pValues.TotalWidth;
        pValues.posY := pValues.GapTextHeight
      end;
    else {270..359}
      begin
        pValues.posX := pValues.GapTextWidth;
        pValues.posY := 0
      end;
    end;
  end;
end;


procedure TNikShape.Ricalcola(aCanvas : TCanvas);
begin
  CalculatePositions(aCanvas, Angolo, Testo, aValues);
  if (Width<>aValues.TotalWidth) or (Height<>aValues.TotalHeight) then
    SetBounds(Left, Top, aValues.TotalWidth, aValues.TotalHeight);
end;

procedure TNikShape.Paint;
begin
  Paint2Canvas(Self.Canvas);
end;

// Disegna 4 quadratini intorno al componente
procedure DrawGriglia(nsShape : TNikShape; const bOn : boolean);
const
  iWidth = 10; // larghezza quadratino
var
  OldColor  : TColor;
  OldpStyle : TPenStyle; OldbStyle : TBrushStyle;
  OldWidth  : integer;
  i1        : integer;
  X,Y,W,H   : integer;
begin
  with nsShape do
  begin
    X := Left; Y := Top; W := Width; H := Height;
  end;
  with nsShape.Canvas do
  begin
    OldpStyle := Pen.Style;
    OldWidth  := Pen.Width;
    OldbStyle := Brush.Style;
    OldColor  := Brush.Color;

    if bOn then
    begin
      Brush.Style := bsClear;
      Brush.Color := clWhite;
    end
    else
    begin
      Brush.Style := bsClear;
      Pen.Style   := psClear;
    end;

// Top e Bottom
    i1 := X+(W div 2);
    Application.MainForm.Canvas.Rectangle(i1-(iWidth div 2), Y-iWidth, i1+(iWidth div 2), Y);
    Application.MainForm.Canvas.Rectangle(i1-(iWidth div 2), Y+H, i1+(iWidth div 2), Y+H+iWidth);

// Left e right
    i1 := Y+(H div 2);
    Application.MainForm.Canvas.Rectangle(X-iWidth,i1-(iWidth div 2), X, i1+(iWidth div 2));
    Application.MainForm.Canvas.Rectangle(X+W,     i1-(iWidth div 2), X+W+iWidth, i1+(iWidth div 2));

    Pen.Style   := OldpStyle;
    Pen.Width   := OldWidth;
    Brush.Style := OldbStyle;
    Brush.Color := OldColor;
  end;
end;

procedure TNikShape.Paint2Canvas(aCanvas : TCanvas);
var
  iBcW, X, Y, W, H, S, eX, eY, sX, sY: Integer;
  Y1, Y2 : integer;
  R : TRect;
  OldColor : TColor;
  OldpStyle : TPenStyle; OldbStyle : TBrushStyle;

begin
  if FShape = stSetup then exit; // Setup e' invisibile
  if ( (Assigned(FLinkTo)) and (FLinkTo<>nil) ) then  Testo := FLinkTo.Testo;
  if ( (Assigned(FLinkTop)) and (FLinkTop<>nil) ) and (FLinkTop.Top <> Top) then Top := FLinkTop.Top;
  if ( (Assigned(FLinkLeft)) and (FLinkLeft<>nil) ) and (FLinkLeft.Left <> Left) then Left := FLinkLeft.Left;

  if not _bPrinting then
  begin
    FScaleX := 1.0;
    FScaleY := 1.0;
  end
  else
  begin
    FPixelX      := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
    FPixelY      := GetDeviceCaps(Printer.Handle, LOGPIXELSY);
    FScaleX      := FPixelX / 96;
    FScaleY      := FPixelY / 96;
  end;

  with aCanvas do
  begin
    if Assigned(FFont) then
      aCanvas.Font.Assign(FFont);
    Pen := FPen;
    Brush := FBrush;

// Se il canvas di destinazione e' diverso da quello locale del componente
// includi left e top
    if aCanvas <> Self.Canvas then // print o metafile
    begin
      if Lmm = 0 then
        X := round(Left * FScaleX)      // era X := Left
      else
        X := MM2Pixel(FPixelX,Lmm);
      if Tmm = 0 then
        Y := round(Top * FScaleY)        // era Y := Top
      else
        Y := MM2Pixel(FPixelY,Tmm);
    end
    else  // paint "normale"
    begin
      X := Pen.Width div 2;
      Y := X;
    end;

    W := Width - Pen.Width + 1;
    H := Height - Pen.Width + 1;

    W := round(W*FScaleX);
    H := round(H*FScaleY);

    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;
    if W < H then S := W else S := H;
    if FShape in [stSquare, stRoundSquare, stCircle] then
    begin
      Inc(X, (W - S) div 2);
      Inc(Y, (H - S) div 2);
      W := S;
      H := S;
    end;

    (* if not _bPrinting then
      if FSelected and (FShape in [stBarcode, stText, stLine]) then
      begin
        OldpStyle := Pen.Style;
        OldbStyle := Brush.Style;
        Brush.Style := bsClear;
        Pen.Style := psDot;
        Rectangle(X+1,Y+1,X+W-1, Y+H-1);
        Pen.Style := OldpStyle;
        Brush.Style := OldbStyle;
      end; *)

    case FShape of
      stRectangle, stSquare:
        begin
          aCanvas.Rectangle(X, Y, X + W, Y + H);
  //        SendToBack;
        end;
      stRoundRect, stRoundSquare:
        begin
          aCanvas.RoundRect(X, Y, X + W, Y + H, S div 4, S div 4);
    //      SendToBack;
        end;
      stLine:
        begin
          if W < H then // linea verticale
          begin
            sX := X + (W div 2);
            sY := Y;
            eX := sX;
            eY := Y + H
          end
          else
          begin
            sX := X;
            sY := Y+(H div 2);
            eX := X + W;
            eY := sY
          end;
          aCanvas.MoveTo(sX, sY);
          aCanvas.LineTo(eX, eY);
        end;
      stCircle, stEllipse:
        begin
          aCanvas.Ellipse(X, Y, X + W, Y + H);
//          SendToBack;
        end;

      stText: begin
{  _______W______
  |     _gH_     |
  |-gW-|    |    |  H                   nf
  |    |____|    |
  |______________|
}
          FFont.Handle := CreateRotatedFont(FFont, Angolo);
          Ricalcola(aCanvas);
          with aValues do
          begin
// IL rettangolo deve avere origine in (X,Y)
// R := Rect(X, Y, X+round(TotalWidth*FScaleX), Y+round(TotalHeight*FScaleY)); cosi' print non corretto!
            R := Rect(X, Y, X+round(TotalWidth), Y+round(TotalHeight));
// il testo deve avere origine nel punto calcolato (cambia secondo la rotazione)
            aCanvas.TextRect(R, X+aValues.posX, Y+aValues.posY, Testo);
          end;
        end;

      stBarcode:
        begin
          BarcodePaint(FBcType,Testo,aCanvas,X,Y,W,H,Angolo,Alignment,2,
            TestoInChiaro,NarrowWidth,iBcW);
          BCWidth := iBcW;
          if Angolo=0 then
            if (not _bPrinting) and (BCWidth <> round(Width * FScaleX)) then
            begin
              Width := BCWidth;
              Invalidate
            end;
          if Angolo=90 then
            if (not _bPrinting) and (BCWidth<>round(Height*FScaleY)) then
            begin
//              Width := Height;
              Height:=BCWidth;
              Invalidate;
            end;
        end;

      stImage:
        begin
          R := Rect(X,Y,X+W,Y+H);
          aCanvas.StretchDraw(R, FImage);
        end;
    end;
  end;
//  if _bPrinting then _bPrinting := False;
end;

procedure TNikShape.StyleChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TNikShape.SetImage(const sPath : string);
begin
  FImage := Graphics.TBitmap.Create;
  FImage.LoadFromFile(sPath);
  ImagePath := sPath;
end;

procedure TNikShape.SetTesto(Testo: string);
begin
  FTesto := Testo;
end;

procedure TNikShape.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TNikShape.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TNikShape.SetShape(Value: TNikShapeType);
begin
  if FShape <> Value then
  begin
    FShape := Value;
    Invalidate;
  end;
end;

function CreateLogFont(Angolo : integer; aCanvas : TCanvas) : TFont;
var LogFont : TLogFont;
begin
  with aCanvas do begin
    with LogFont do begin
      lfHeight := Font.Height;
      lfWidth  := 0;
//      lfEscapement  := 0; // 900 per 90 gradi
      lfEscapement := Angolo*10;
      lfOrientation := 0; // non gestito da Windows
      lfWeight    := FW_NORMAL; // Default
      lfItalic    := 0;
      lfUnderline := 0;
      lfStrikeOut := 0;
      lfCharSet := ANSI_CHARSET;
      StrPCopy(lfFaceName, Font.Name);
      lfQuality := PROOF_QUALITY;
      lfOutPrecision  := OUT_TT_ONLY_PRECIS; // forza TrueType
      lfClipPrecision := CLIP_DEFAULT_PRECIS; // default
      lfPitchAndFamily := Variable_Pitch; // default
    end;
  end;
  aCanvas.Font.Handle := CreateFontIndirect(LogFont);
  Result := aCanvas.Font;
end;


procedure TNikShape.Print;
begin
  _bPrinting := True;
  Paint2Canvas(Printer.Canvas);
  _bPrinting := False;
end;

procedure TNikShape.SelectObj(Sender : TObject);
begin
  if FShape = stSetup then exit; // Setup e' invisibile
// TBC
//  Owner.Creating := False;
  Grabbed  := False;
  Selected := True;
  Invalidate;
end;

procedure TNikShape.InspectObject(Sender : TObject);
begin
  if FShape = stSetup then exit; // Setup e' invisibile
  Inspected := True;
  with TfrmInspector.CreateFor(Parent as TForm, Self) do
    try
      if ShowModal = mrOk then
        Invalidate;
    finally
      Free;
    end;
end;

procedure TNikShape.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FShape = stSetup then exit; // Setup e' invisibile
  Grabbed := False;
end;

procedure TNikShape.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if FShape = stSetup then exit; // Setup e' invisibile
  BringToFront;
  if Button = mbRight then
  begin
    if Assigned(PopupMenu) then
      PopupMenu.Popup(X+Left,Y+Top)
  end
  else
  begin
    XX := X; YY := Y;
    if not Inspected then
      Grabbed := True
    else
      Inspected := False;
  end;
end;

(*procedure TNikShape.DrawGhost;
var
  xX2,xX1,xY2,xY1 : integer;
  S : Integer;
begin
// TBU
  with Parent as TForm do
  begin
    xX2 := X2;
    xX1 := X1;
    xY1 := Y1;
    xY2 := Y2;
  end;

  S := Min(xX2-xX1,xY2-xY1);
// TBU
  with (Parent as TForm).Canvas do
    case FShape of
      stCircle       : Arc(xX1,xY1,xX1+S,xY1+S,xX1,xY1,xX1,xY1);
      stEllipse      : Arc(xX1,xY1,xX2,xY2,xX1,xY1,xX1,xY1);
      stSquare,
      stRoundSquare  : begin
                         PolyLine([Point(xX1,xY1),Point(xX1+S,xY1),Point(xX1+S,xY1+S)]);
                         PolyLine([Point(xX1,xY1),Point(xX1,xY1+S),Point(xX1+S,xY1+S)]);
                       end;
      stLine :
        begin
          MoveTo(xX1, xY1);
          LineTo(xX1+s, xY1+s);
        end;
      stRectangle,
      stRoundRect,
      stText,
      stBarcode,
      stImage      : begin
                       PolyLine([Point(xX1,xY1),Point(xX2,xY1),Point(xX2,xY2)]);
                       PolyLine([Point(xX1,xY1),Point(xX1,xY2),Point(xX2,xY2)]);
                     end;
    end;
end;
*)
procedure TNikShape.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if FShape = stSetup then exit; // Setup e' invisibile
  if (Y <= 2) or (Y >= Height-2)
  then
  begin
    Grabbed := False;
    Resizing := True;
    Cursor := crSizeNS
  end
  else
    if (X <= 2) or (X >= Width-2) then
      Cursor := crSizeWE
    else
    begin
      Resizing := False;
      Cursor := crDrag;
    end;

{ TBI: resize con il mouse
   if Resizing then
    DrawGhost; }

  if Grabbed then
    SetBounds(Left+X-XX,Top+Y-YY,Width,Height);
end;


end.
