{Written by David R. Faulkner, June 1996}
{P.O. Box 434, Kula HI, 96790}
{Internet: davef@maui.net}
{This unit implements TBarCode, a component that paints Code 39 barcodes}

unit Barcode;


interface

uses
  Messages, Classes, Controls, StdCtrls, BarCodeR;

type
  TBarCode = class(TLabel)
  private
    { Private declarations }
    _btType : TBarCodeType;
    _rScale : integer;
    _rNarrowWidth : single;
    _iBarcodeWidth : integer;
    FAngle : integer;
    FTestoInChiaro : boolean;
    procedure CaptionChanged(var Message: TMessage); message CM_TEXTCHANGED;

  protected
    { Protected declarations }
    procedure Paint; override;  {override paint so can draw barcode}

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override; {so can set default}

  published
    { Published declarations }
    property BarcodeWidth : integer read _iBarcodeWidth write _iBarcodeWidth;
    property NarrowWidth : single read _rNarrowWidth write _rNarrowWidth;
    property Angolo : integer read FAngle write FAngle;
    property Caption;
    property Alignment;
    property BarCodeType : TBarCodeType read _btType write _btType;
    property Scale : integer read _rScale write _rScale default 1;
    property TestoInChiaro : boolean read FTestoInChiaro write FTestoInChiaro default false;
end;

procedure Register;

implementation

{******************************************************************************}

procedure Register;
begin        {Put TBarCode on Delphi Informant tab of Component Palette}
  RegisterComponents('Samples', [TBarCode]);
end;

procedure TBarCode.Paint;
var iBcWidth : integer;
begin
  {TBarCode's canvas is already located at Top,Left on the form, so we send
   0,0 to BarCodePaint}
  BarCodePaint(BarCodeType,Caption,Canvas,0,0,Width,Height,Angolo,Alignment,
  Scale,TestoInChiaro, NarrowWidth, iBcWidth );
  BarcodeWidth := iBcWidth;
end;

constructor TBarCode.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csOpaque]; {let windows draw background}
  Alignment :=taCenter;                      {default to centered barcode}
  Autosize:=false;                           {don't let tCustomLabel change size}
  Height:=50;                                {a reasonable height}
  Width:=175;                                {a reasonable width}
  BarCodeType:=btCode39;
  Scale:=1;
  Angolo:=0;
end;

procedure TBarCode.CaptionChanged(var Message: TMessage);
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
