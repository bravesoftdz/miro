{Written by David R. Faulkner, June 1996}
{P.O. Box 434, Kula HI, 96790}
{Internet: davef@maui.net}
{This unit implements TBarCode, a components that paints Code 39 barcodes}

unit QRBarcod;

interface                           

uses Messages, Classes, Controls, StdCtrls, BarCodeR, Quickrep;

type
//  TQRBarCode = class(TQRLabel)
  TQRBarCode = class(TQRCustomControl)
  private
    { Private declarations }
    _btType : TBarCodeType;
    _rScale : integer;
    _rNarrowWidth : single;
    _iBarcodeWidth : integer;
    FAngle  : integer;
    FTestoInChiaro : boolean;
    FAlignToBand : Boolean;
    FAutoSize : boolean;
    FTransparent : boolean;
    FOnPrintEvent : TQRLabelOnPrintEvent;
    procedure CaptionChanged(var Message: TMessage); message CM_TEXTCHANGED;

  protected
    { Protected declarations }
    procedure Paint; override;  {override paint so can draw barcode}
    procedure Print(x,y:integer); override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override; {so can set default}
    property Angolo : integer read FAngle write FAngle;

  published
    { Published declarations }
    property Caption;
    property Alignment;
    property NarrowWidth : single read _rNarrowWidth write _rNarrowWidth;
    property BarCodeType : TBarCodeType read _btType write _btType;
    property Scale : integer read _rScale write _rScale default 1;
    property AutoSize Stored true;
    property AlignToBand : Boolean read FAlignToBand write FAlignToBand;
    property Transparent : Boolean read FTransparent write FTransparent;
    property TestoInChiaro : boolean read FTestoInChiaro write FTestoInChiaro default false;
    property BarcodeWidth : integer read _iBarcodeWidth write _iBarcodeWidth;
end;

procedure Register;

implementation

uses WinProcs, printers;

{******************************************************************************}

procedure Register;
begin        {Put TBarCode on Delphi Informant tab of Component Palette}
  RegisterComponents('QReport', [TQRBarCode]);
end;

procedure TQRBarCode.Paint;
var iWidth : integer;
begin
  {TBarCode's canvas is already located at Top,Left on the form, so we send
   0,0 to BarCodePaint}
  BarCodePaint(BarCodeType,Caption,Canvas,0,0,Width,Height,Angolo,
    Alignment,Scale,TestoInchiaro, NarrowWidth, iWidth);
  BarcodeWidth := iWidth;
end;

procedure TQRBarCode.Print(x,y:integer);
var iWidth,ScaleX,ScaleY, nX, nY : integer;
begin
  ScaleX:=WinProcs.GetDeviceCaps(QRPrinter.Canvas.Handle,LOGPIXELSX) div 96;
  ScaleY:=WinProcs.GetDeviceCaps(QRPrinter.Canvas.Handle,LOGPIXELSY) div 96;
  with ParentReport do
    BarCodePaint(BarCodeType,Caption,QRPrinter.Canvas,
                 XPos(x), YPos(y),
                 XPos(x+Width)*ScaleX, YPos((y+Height)*ScaleY), Angolo,
                 Alignment, Scale*ScaleX, TestoInChiaro,
                 NarrowWidth, iWidth);
  BarcodeWidth := iWidth;
{  nX := ParentReport.XPos(x+Left);
  nY := ParentReport.YPos(y+Top);
  BarCodePaint(BarCodeType,Caption,QRPrinter.Canvas,
               nX, nY,
               ParentReport.XPos(Width),   ParentReport.YPos(Height), Angolo,
               Alignment,Ratio,Scale,TestoInChiaro);
 }
end;

constructor TQRBarCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csOpaque]; {let windows draw background}
  Alignment :=taCenter;                      {default to centered barcode}
  Autosize:=false;                           {don't let tCustomLabel change size}
  Height:=50;                                {a reasonable height}
  Width:=200;                                {a reasonable width}
  BarCodeType:=btCode39;  { default code139 }
  Scale:=1;
  Angolo := 0;
end;

procedure TQRBarCode.CaptionChanged(var Message: TMessage);
var
  x:integer;
  CaptionCopy:string;               {will build filtered caption in here}
begin
  CaptionCopy:='';
  for x:=1 to length(Caption) do    {filter out any unsupported characters}
    if (pos(upcase(Caption[x]),cValidCode39Characters)<>0) and
       (Caption[x]<>'*') then
      CaptionCopy:=CaptionCopy+upcase(Caption[x]);
  Caption:=CaptionCopy;
  inherited;                        {tCustomLabel's CMTextChanged will cause repaint}

end;


end.
