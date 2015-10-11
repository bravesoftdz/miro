{Written by David R. Faulkner, June 1996}
{P.O. Box 434, Kula HI, 96790}
{Internet: davef@maui.net}

{This file is used by all the other barcode files
 to link in the component pallette icons and general routines}

unit Barcoder;  {Barcode Resourses}

{$IFDEF WIN32}
{$R BARCOD32.DCR}      {Component Palette icons}
{$ELSE}
{$R BARCOD16.DCR}
{$ENDIF}

interface

uses
  WinTypes, WinProcs, Classes, Graphics;

type
  TBarCodeType   = ( btCode39, btInter25, btInter25CD, btCode128, btEan8,
    btEan13, btEan128 );

  TCode128Symbol = array[1..6] of char;
  TCodici128  = array[1..100] of integer;

const
                         {         11111111112222222222333333333344444}
                         {12345678901234567890123456789012345678901234}
  cValidCode39Characters='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. *$/+%';
  {The above string list all the characters supported by Code 39.  The position
   of each character corresponds to an entry in the following table}

  {N=Narrow Bar, W=WideBar}
  BarCode139Table: array[1..44, 1..9] of char = (
    'NNNWWNWNN',  {1 - 0}
    'WNNWNNNNW',  {2 - 1}
    'NNWWNNNNW',  {3 - 2}
    'WNWWNNNNN',  {4 - 3}
    'NNNWWNNNW',  {5 - 4}
    'WNNWWNNNN',  {6 - 5}
    'NNWWWNNNN',  {7 - 6}
    'NNNWNNWNW',  {8 - 7}
    'WNNWNNWNN',  {9 - 8}
    'NNWWNNWNN',  {10 - 9}
    'WNNNNWNNW',  {11 - A}
    'NNWNNWNNW',  {12 - B}
    'WNWNNWNNN',  {13 - C}
    'NNNNWWNNW',  {14 - D}
    'WNNNWWNNN',  {15 - E}
    'NNWNWWNNN',  {16 - F}
    'NNNNNWWNW',  {17 - G}
    'WNNNNWWNN',  {18 - H}
    'NNWNNWWNN',  {19 - I}
    'NNNNWWWNN',  {20 - J}
    'WNNNNNNWW',  {21 - K}
    'NNWNNNNWW',  {22 - L}
    'WNWNNNNWN',  {23 - M}
    'NNNNWNNWW',  {24 - N}
    'WNNNWNNWN',  {25 - O}
    'NNWNWNNWN',  {26 - P}
    'NNNNNNWWW',  {27 - Q}
    'WNNNNNWWN',  {28 - R}
    'NNWNNNWWN',  {29 - S}
    'NNNNWNWWN',  {30 - T}
    'WWNNNNNNW',  {31 - U}
    'NWWNNNNNW',  {32 - V}
    'WWWNNNNNN',  {33 - W}
    'NWNNWNNNW',  {34 - X}
    'WWNNWNNNN',  {35 - Y}
    'NWWNWNNNN',  {36 - Z}
    'NWNNNNWNW',  {37 - -}
    'WWNNNNWNN',  {38 - .}
    'NWWNNNWNN',  {39 - blank space}
    'NWNNWNWNN',  {40 - *}
    'NWNWNWNNN',  {41 - $}
    'NWNWNNNWN',  {42 - /}
    'NWNNNWNWN',  {43 - +}
    'NNNWNWNWN'); {44 - %}

{ Set di caratteri per Interleaved 2/5 }
  cValidInter25Characters = '1234567890';

  BarInt25Table: array[1..10, 1..5] of char = (
  '10001',  {1}
  '01001',  {2}
  '11000',  {3}
  '00101',  {4}
  '10100',  {5}
  '01100',  {6}
  '00011',  {7}
  '10010',  {8}
  '01010',  {9}
  '00110'   {0}
  );

  BarInt25Start = '0000';
  BarInt25Stop  = '100';

// Code 128
  Code128Cs : array[0..106] of string =
  (
    'NNBNNBBNNBB',      {SPACE SPACE 00 - 0}
    'NNBBNNBNNBB',
    'NNBBNNBBNNB',
    'NBBNBBNNBBB',
    'NBBNBBBNNBB',
    'NBBBNBBNNBB',
    'NBBNNBBNBBB',
    'NBBNNBBBNBB',
    'NBBBNNBBNBB',
    'NNBBNBBNBBB',
    'NNBBNBBBNBB',
    'NNBBBNBBNBB',
    'NBNNBBNNNBB',
    'NBBNNBNNNBB',  { 13 corretto }
    'NBBNNBBNNNB',
    'NBNNNBBNNBB',
    'NBBNNNBNNBB',
    'NBBNNNBBNNB',
    'NNBBNNNBBNB',
    'NNBBNBNNNBB',
    'NNBBNBBNNNB',
    'NNBNNNBBNBB', { 21 }
    'NNBBNNNBNBB',
    'NNNBNNBNNNB',
    'NNNBNBBNNBB',
    'NNNBBNBNNBB',
    'NNNBBNBBNNB',
    'NNNBNNBBNBB',
    'NNNBBNNBNBB',
    'NNNBBNNBBNB',
    'NNBNNBNNBBB',
    'NNBNNBBBNNB',
    'NNBBBNNBNNB',
    'NBNBBBNNBBB',
    'NBBBNBNNBBB', { B B 34 - 34 }
    'NBBBNBBBNNB',
    'NBNNBBBNBBB',
    'NBBBNNBNBBB',
    'NBBBNNBBBNB',
    'NNBNBBBNBBB',
    'NNBBBNBNBBB', { 40 }
    'NNBBBNBBBNB',
    'NBNNBNNNBBB',
    'NBNNBBBNNNB',
    'NBBBNNBNNNB',
    'NBNNNBNNBBB', { 45 }
    'NBNNNBBBNNB',
    'NBBBNNNBNNB',
    'NNNBNNNBNNB',
    'NNBNBBBNNNB',
    'NNBBBNBNNNB', { 50 }
    'NNBNNNBNBBB',
    'NNBNNNBBBNB',
    'NNBNNNBNNNB',
    'NNNBNBNNBBB',
    'NNNBNBBBNNB', { 55 }
    'NNNBBBNBNNB',
    'NNNBNNBNBBB',
    'NNNBNNBBBNB',
    'NNNBBBNNBNB',
    'NNNBNNNNBNB', { 60 }
    'NNBBNBBBBNB',
    'NNNNBBBNBNB',
    'NBNBBNNBBBB',
    'NBNBBBBNNBB',
    'NBBNBNNBBBB', { 65 }
    'NBBNBBBBNNB',
    'NBBBBNBNNBB',
    'NBBBBNBBNNB',
    'NBNNBBNBBBB',
    'NBNNBBBBNBB', { 70 }
    'NBBNNBNBBBB',
    'NBBNNBBBBNB',
    'NBBBBNNBNBB',
    'NBBBBNNBBNB',
    'NNBBBBNBBNB', { 75 }
    'NNBBNBNBBBB',
    'NNNNBNNNBNB',
    'NNBBBBNBNBB',
    'NBBBNNNNBNB',
    'NBNBBNNNNBB', { 80 }
    'NBBNBNNNNBB',
    'NBBNBBNNNNB',
    'NBNNNNBBNBB',
    'NBBNNNNBNBB',
    'NBBNNNNBBNB', { 85 }
    'NNNNBNBBNBB',
    'NNNNBBNBNBB',
    'NNNNBBNBBNB',
    'NNBNNBNNNNB',
    'NNBNNNNBNNB',
    'NNNNBNNBNNB',
    'NBNBNNNNBBB',
    'NBNBBBNNNNB',
    'NBBBNBNNNNB',
    'NBNNNNBNBBB',
    'NBNNNNBBBNB',
    'NNNNBNBNBBB',
    'NNNNBNBBBNB',
    'NBNNNBNNNNB',
    'NBNNNNBNNNB',
    'NNNBNBNNNNB',
    'NNNNBNBNNNB',   { FNC1 - 102 }
    'NNBNBBBBNBB',   { START CODE A - 103 }
    'NNBNBBNBBBB',   { START CODE B - 104 }
    'NNBNBBNNNBB',   { START CODE C - 105 }
    'NNBBBNNNBNBNN'  { STOP - 106 }
  );

  CODEC_CODEB  = 100;
  CODEB_CODEC  = 99;
  FNC1 = 102;
  CODE128_STOP = 106;

  Code128CsB = ' !"#$%&''()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWX'+
    'YZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~';

// EAN 13
  Ean13CarEncod : array[0..9] of string[6] =
  (
  'AAAAAA',  {0}
  'AABABB',  {1}
  'AABBAB',  {2}
  'AABBBA',  {3}
  'ABAABB',  {4}
  'ABBAAB',  {5}
  'ABBBAA',  {6}
  'ABABAB',  {7}
  'ABABBA',  {8}
  'ABBABA'   {9}
  );

  Ean13TabA : array[0..9] of string[7] =
  (
    '0001101',
    '0011001',
    '0010011',
    '0111101',
    '0100011',
    '0110001',
    '0101111',
    '0111011',
    '0110111',
    '0001011'
  );

  Ean13TabB : array[0..9] of string[7] =
  (
    '0100111',
    '0110011',
    '0011011',
    '0100001',
    '0011101',
    '0111001',
    '0000101',
    '0010001',
    '0001001',
    '0010111'
  );

  Ean13TabC : array[0..9] of string[7] =
  (
    '1110010',
    '1100110',
    '1101100',
    '1000010',
    '1011100',
    '1001110',
    '1010000',
    '1000100',
    '1001000',
    '1110100'
  );

  Ean13Lat = '101';
  Ean13Cen = '01010';

procedure BarCodePaint(BarCodeType: TBarCodeType;
                       Caption:String;                 {barcode value to paint}
                       Canvas:TCanvas;                {canvas to paint it on}
                       left,top,width,height,angle:integer;  {rectangle to paint it in}
                       Alignment:tAlignment;            {taLeftJustify,taRightJustify,taCenter}
                       Scale:integer;
                       TestoInChiaro : boolean;
                       rNarrowWidth  : single;
                       var BarcodeWidth : integer
                       );


implementation

uses SysUtils, Forms {per Screen};

var
  _nBar : integer;
  work : TCodici128;     // stringa di lavoro
  PixelsPerInch:integer; {measure of pixels/inch for canvas being painted on}

(* Calcola il checksum del barcode I2/5 dal libro "Codici a Barre" *)
function sCalcolaChecksumI25(sTestoBC : string) : string;
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
  str(iCK, sCK);
  Result := sTestoBC + sCK;
end;

procedure PaintABar(WideOrNarrow:char;ThisBarIsBlack:boolean;Acanvas:tcanvas;
                    var LeftEdge,TopEdge : integer;
                    Height,NarrowWidth,WideWidth : Integer;
                    Angle,cWidth :integer); // cWidth e' del componente
var
  //sz,T,CurrentWidth:integer;  fn : string;
  CurrentWidth:integer;
begin
  inc(_nBar);
  if (WideOrNarrow='W') or (WideOrNarrow='1') then
    CurrentWidth:=WideWidth
  else
    CurrentWidth:=NarrowWidth;

  {$ifdef _DEBUG}
  if ThisBarIsBlack then
  begin
    aCanvas.TextOut(LeftEdge,10,'N');
    aCanvas.TextOut(LeftEdge,Height-aCanvas.TextHeight('N'),IntToStr(_nBar));
  end
  else
  begin
    aCanvas.TextOut(LeftEdge,20,'B');
    aCanvas.TextOut(LeftEdge,20+aCanvas.TextHeight('N'),IntToStr(_nBar));
  end;
  {$endif}

  case Angle of
  0:
    begin
      if ThisBarIsBlack then       {don't paint a rectangle if bar is white}
        aCanvas.Rectangle(LeftEdge,TopEdge,LeftEdge+CurrentWidth,TopEdge+Height);
      inc(LeftEdge,CurrentWidth);  {setup LeftEdge for next bar}
    end;
  90:
    begin
      if ThisBarIsBlack then       {don't paint a rectangle if bar is white}
        aCanvas.Rectangle(LeftEdge, TopEdge, LeftEdge+{Height}cWidth, TopEdge+CurrentWidth);
      inc(TopEdge,CurrentWidth);
    end;
  end;


end;

///////////////////////////////////////////////////////////////////////////////
// Interleaved 2 su 5
///////////////////////////////////////////////////////////////////////////////
procedure BarCodePaintI25(BarCodeType: TBarCodeType;     { tipo di barcode }
                       var Caption:String;              {barcode value to paint}
                       Canvas:TCanvas;                 {canvas to paint it on}
                       left,top,width,height,Angle,
                       NarrowWidth,WideWidth :integer;  {rectangle to paint it in}
                       Alignment:tAlignment;    {how to align it}
                       TestoInChiaro : boolean;
                       var BarcodeWidth : integer
                       );

function BuildInterleaved(const Caption : string) : string;
var x,y, index1, index2 : integer;
begin
  Result:=BarInt25Start;
  for x:=1 to Length(Caption)-1 do begin
{ Salto le posizioni pari perche' elaboro i car. a coppie }
    if not odd(x) then continue;
    index1 := Pos(Caption[x],cValidInter25Characters);
    index2 := Pos(Caption[x+1],cValidInter25Characters);
    for y:=1 to 5 do begin
      Result := Result + BarInt25Table[index1][y];
      Result := Result + BarInt25Table[index2][y];
    end;
  end;
  Result:=Result+BarInt25Stop;
end;

var i, iCapLen, iBarCodeLen : integer;
  sInterleaved, sWork : string;
  bBlack : boolean;
  TopEdge, LeftEdge:integer; { left edge of barcode, increases with each bar }
begin
  sWork := Caption;
  iCapLen:=Length(sWork);
{ Esce se c'e' qualche carattere non valido (=non numerico) }
  for i:=1 to iCapLen do
    if (pos(sWork[i],cValidInter25Characters)=0) then
      exit;

  if BarcodeType = btInter25CD then begin
// Se num.di cifre pari aggiungo uno zero davanti + CD
    if not odd(iCapLen) then
      sWork:='0'+sWork;
// Senno' aggiunge solo il CD
    sWork := sCalcolaChecksumI25(sWork);
  end;

  iCapLen:=Length(sWork);

{ Interleave 2/5 accetta solo un numero di cifre pari: se dispari esce }
  if odd(iCapLen) then
    exit;

{ Calcola larghezza: num.di car. * barre + barre start + barre stop }
  BarCodeWidth := (iCapLen * (2*WideWidth + 3*NarrowWidth)) + 4*NarrowWidth
    + 2*NarrowWidth + WideWidth ;

  if Angle=0 then
    if BarCodeWidth < Width then
      BarCodeWidth := Width;

  if Angle=90 then
    if Height < BarcodeWidth then
      Height := BarcodeWidth;

  {set LeftEdge according to Alignment}
  case Alignment of
    taLeftJustify:  LeftEdge:=Left;
    taCenter:       LeftEdge:=Left+((Width-BarCodeWidth) div 2);
    taRightJustify: LeftEdge:=Left+Width-BarCodeWidth;
  end;

  TopEdge := Top;
{ Codifica secondo lo standard 2/5 }
  sInterleaved := BuildInterleaved(sWork);
  iBarCodeLen := Length(sInterleaved);

{ Si comincia con una barra nera }
  bBlack := True;
  for i:=1 to iBarCodeLen do begin
    PaintABar(sInterleaved[i],bBlack,Canvas,LeftEdge,TopEdge,Height,NarrowWidth,
      WideWidth,Angle,Width);
    bBlack := not bBlack;
  end;

// Riscrivo Caption perche' potrebbe essere cambiato (aggiunta CD e 0)!
  Caption := sWork;
end;

///////////////////////////////////////////////////////////////////////////////
// CODE 39
///////////////////////////////////////////////////////////////////////////////
procedure BarCodePaint139(Caption:String;              {barcode value to paint}
                       Canvas:TCanvas;                 {canvas to paint it on}
                       left,top,width,height,
                       Angle,NarrowWidth,WideWidth:integer;  {rectangle to paint it in}
                       Alignment:tAlignment;           {how to align it}
                       TestoInChiaro : boolean;
                       var BarcodeWidth : integer
                       );
var
  x,y:integer;
  TopEdge,LeftEdge:integer;               {left edge of barcode, increases with each bar}
  Index:integer;                  {index in BarCode139Table for current char}
begin

  {Code 39 wants an '*' as the start and stop character}
  Caption:='*'+Caption+'*';

  {for each character in caption need 3 wide bars, 6 narrow bar + 1 narrow for white space}
  BarCodeWidth:=Length(Caption)*(3*WideWidth + 7*NarrowWidth);
//  if BarCodeWidth > Width then exit; {if we can't fit the whole thing then give up}

  {set LeftEdge according to Alignment}
  case Alignment of
    taLeftJustify:  LeftEdge:=Left;
    taCenter:       LeftEdge:=Left+((Width-BarCodeWidth) div 2);
    taRightJustify: LeftEdge:=Left+Width-BarCodeWidth;
  end;

  TopEdge := Top;
  {Now print a series of 9 bars for each character in caption}
  for x:=1 to length(Caption) do begin
    Index:=pos(Caption[x],cValidCode39Characters); {make sure this is a printable character}
    if Index=0 then continue;  {if not printable character then don't print it}
    for y:=1 to 9 do
      PaintABar(BarCode139Table[Index][y],odd(y),Canvas,LeftEdge,TopEdge,Height,
        NarrowWidth,WideWidth,Angle,Width);
    case Angle of
    0:  inc(LeftEdge,NarrowWidth);  {white space between characters}
    90: inc(TopEdge, NarrowWidth);
    end;
  end;
end;


procedure SetFontDim(pCanvas: TCanvas; iWidth,iHeight: Integer);
{This procedure was writen by Keith Wood}
var
  FntLogRec: TLogFont { Storage area for font information } ;
begin
  { Get the current font information. We only want to modify the angle }
  GetObject(pCanvas.Font.Handle, SizeOf(FntLogRec), Addr(FntLogRec));

  FntLogRec.lfHeight := -MulDiv(iHeight, GetDeviceCaps(pCanvas.Handle, LOGPIXELSY), 72);
  FntLogRec.lfWidth  := -MulDiv(iWidth, GetDeviceCaps(pCanvas.Handle, LOGPIXELSX), 96);
//  FntLogRec.lfWidth  := iWidth;
  FntLogRec.lfOutPrecision := OUT_TT_ONLY_PRECIS;

  { Delphi will handle the deallocation of the old font handle }
  pCanvas.Font.Handle := CreateFontIndirect(FntLogRec);
end;


///////////////////////////////////////////////////////////////////////////////
// EAN 13
///////////////////////////////////////////////////////////////////////////////
procedure BarCodePaintEan13(Caption:String;              {barcode value to paint}
                       Canvas:TCanvas;                 {canvas to paint it on}
                       left,top,width,height,
                       Angle,NarrowWidth,WideWidth:integer;  {rectangle to paint it in}
                       Alignment:tAlignment;           {how to align it}
                       TestoInChiaro : boolean;
                       var BarcodeWidth : integer
                       );

function CalcolaCD(const sMsg : string) : integer;
var i, iTmp,iPari,iDispari : integer;
begin
  iTmp := 0; iPari := 0; iDispari := 0;
  for i:=12 downto 1 do
  begin
    if i mod 2 <> 0 then  // perche' il 12° va considerato DISPARI
      inc(iPari, ord(sMsg[i])-ord('0') )
    else
      inc(iDispari, ord(sMsg[i])-ord('0') );
  end;
  iTmp := (iDispari*3)+iPari;
  iTmp := iTmp mod 10;
  if iTmp = 0 then iTmp := 10;
  Result := 10 - iTmp;
end;

var
  iCD,x,y,iCentr,iStep:integer;
  sABconf,sBitImage : string;
  iAltezzaFont,iAltezza,LeftEdge,
  TopEdge :integer;{left edge of barcode, increases with each bar}
  Index:integer;            {index in BarCode139Table for current char}
  R : TRect; MyOutText : PChar;
  rScala : single;
begin

// Solo 12 + CD caratteri permessi
  if Length(Caption) <> 12 then exit;
  rScala := (PixelsPerInch / 96);
{  Canvas.Font.Size := Width div 13;
  Canvas.Font.Height := NarrowWidth * 5;
  Canvas.Font.Name := 'Courier New'; }
//  SetFontDim(Canvas, (Width div 14), (NarrowWidth*5));
  Canvas.Font.Size := round((Width / (13*rScala)));
  iAltezzaFont := Height-Canvas.TextHeight('A');
  iStep := Canvas.TextWidth('A');

// Larghezza barcode + lettera per primo carattere in chiaro
  BarCodeWidth:=(NarrowWidth*7*13) + (11*NarrowWidth) +iStep;

  {set LeftEdge according to Alignment}
// Lascia lo spazio per il primo carattere
  case Alignment of
    taLeftJustify:  LeftEdge:=Left + iStep;
    taCenter:       LeftEdge:=Left+((Width-BarCodeWidth) div 2) + iStep;
    taRightJustify: LeftEdge:=Left+Width-BarCodeWidth +iStep;
  end;

  iCd := CalcolaCD(Caption);
  sBitImage := Ean13Lat;
  sABConf   := Ean13CarEncod[ord(Caption[1])-ord('0')];

  for x:=2 to 7 do
  begin
// Usa tabella A o B a seconda di sABConf
    if sAbConf[x-1]='A' then
      sBitImage := sBitImage + Ean13TabA[ord(Caption[x])-ord('0')]
    else
      sBitImage := sBitImage + Ean13TabB[ord(Caption[x])-ord('0')]
  end;

// Aggiunge barre centrali
  sBitImage := sBitImage + Ean13Cen;

// Tutto tabC
  for x:=8 to 12 do
  begin
    sBitImage := sBitImage + Ean13TabC[ord(Caption[x])-ord('0')]
  end;
// Aggiunge CD (sempre come tabC) e barre finali
  sBitImage := sBitImage + Ean13TabC[iCd] + Ean13Lat;

  for x:=1 to length(sBitImage) do begin
    if not ( (x <= 3) or ( (x>=42) and (x<=47) ) or (x>=93) ) then
//      iAltezza := Height - (5 * NarrowWidth)
      iAltezza := (Height - Canvas.TextHeight('A'))  // Per sembrar piu' preciso
    else
      iAltezza := Height;
// Marca la fine delle barre centrali
    if (x>=42) and (x<=47) then iCentr := LeftEdge+5;

  TopEdge := Top;
// Disegna tutte barre Narrow accostate
    PaintABar('N', sBitImage[x]='1', Canvas, LeftEdge, TopEdge, iAltezza,
        NarrowWidth,WideWidth,Angle,Width);
  end;

  Canvas.Brush.Color := 16777215;
  Canvas.TextOut(Left, Top+iAltezzaFont, Caption[1]);

  MyOutText := StrNew(PCHAR(Copy(Caption,2,6)));
  R := Rect(Left+iStep+(3*NarrowWidth), Top+iAltezzaFont,
            Left+iStep+(3*NarrowWidth)+iStep*6, Top+(iAltezzaFont*2));
  DrawText(Canvas.Handle, MyOutText, -1, R, dt_Center);
  StrDispose(MyOutText);              { Free the string }

  MyOutText := StrNew(PCHAR(Copy(Caption,8,6) + chr(iCd+ord('0')) ));
  R := Rect(iCentr, Top+iAltezzaFont,
            iCentr+(iStep*6), Top+(iAltezzaFont*2));
  DrawText(Canvas.Handle, MyOutText, -1, R, dt_Center);

  StrDispose(MyOutText);              { Free the string }
  Canvas.Brush.Color := clBlack;
end;

///////////////////////////////////////////////////////////////////////////////
// CODE 128
///////////////////////////////////////////////////////////////////////////////
procedure BarCodePaint128(Caption:String;              {barcode value to paint}
                       Canvas:TCanvas;                 {canvas to paint it on}
                       left,top,width,height,
                       Angle,NarrowWidth,WideWidth:integer;  {rectangle to paint it in}
                       Alignment:tAlignment;              {how to align it}
                       TestoInChiaro : boolean;
                       var BarcodeWidth : integer;
                       bEan128 : boolean = False);

var
  last,y:integer;
  TopEdge,LeftEdge:integer;               {left edge of barcode, increases with each bar}
  sPrintString : string;
  WorkH,i,iEntry, iCd : integer;
  iPtr : integer;        // puntatore nella stringa di lavoro

  procedure Resetta;
  var i : integer;
  begin
    for i:=low(Work) to high(Work) do
      Work[i] := 0;
  end;

  procedure Add2Work(const iCode : integer);
  begin
    inc(iPtr);
    work[iPtr] := iCode;
  end;

  function CalcPrintString(const sCaption : string) : TCodici128;

  type
    TStato = (none, CodeA, CodeB, CodeC);

  const
    Code128Start : array [1..3] of integer = ( 103, 104, 105 );

  var
    ctr_int, ascii_code,i,j : integer;
    stato : TStato;
    sCoppia : string;
    coppia,iCoppia : integer;

  procedure AddStartCode(statCorrente, statNuovo : TStato; bE128 : boolean = False);
  begin
    if iPtr=0 then
    begin
      Add2Work(Code128Start[ord(statNuovo)]);
      if bE128 then
        Add2Work(FNC1)
    end
    else
      case statNuovo of
      CodeA:  ;
      CodeB:
        if statCorrente=CodeC then
          Add2Work(CODEC_CODEB);
      CodeC:
        if statCorrente=CodeB then
          Add2Work(CODEB_CODEC);
      end;
  end;

  function BuildCoppia(const sStr : string; const iStart : integer) : string;
  begin
    Result := sStr[iStart+1]+sCaption[iStart+2];
  end;

  begin
    Resetta;
    stato := none;
    iPtr := 0;
    ctr_int := 0;
    for i:=1 to Length(sCaption) do
    begin
      ascii_code := ord(sCaption[i]);
      if (ascii_code >= ord('0')) and (ascii_code <= ord('9')) then
      begin
        inc(ctr_int);
  // Codifica come Code C a gruppi di 4 (gli ultimi 4 letti)
        if ctr_int = 4 then
        begin
          AddStartCode(stato,CodeC,bEan128);
          stato := CodeC;
          for coppia:=2 downto 1 do
          begin
            sCoppia := BuildCoppia(sCaption,i-(2*coppia));
  //          sCoppia := sCaption[i-(2*coppia)+1]+sCaption[i-(2*coppia)+2];
            try
              iCoppia := StrToInt(sCoppia);
            except
            end;
            Add2Work(iCoppia);
          end;
          ctr_int := 0;
        end;
      end
      else  // Trovato alfanumerico => codifica come Code B
      begin

  // Se pendono piu' di due interi aggiunge con CodeC
        if ctr_int >= 2 then
        begin
          while ctr_int >= 2 do  // se rimangono pendenti degli interi usa tutto code b
          begin
            sCoppia := BuildCoppia(sCaption, i-ctr_int-1);
            try
              iCoppia := StrToInt(sCoppia);
            except
            end;
            if stato <> CodeC then
            begin
              AddStartCode(stato, CodeC, bEan128);
              stato := CodeC;
            end;
            Add2Work(iCoppia);
            ctr_int := ctr_int-2;
          end;
        end;

  // Se rimane solo un intero aggiunge come CodeB
        if ctr_int = 1 then
        begin
          if stato = CodeC then
            AddStartCode(stato, CodeB, bEan128);
          if sCaption[i-ctr_int] <> #0 then
            Add2Work(Pos(sCaption[i-ctr_int], Code128CsB)-1);
          ctr_int := 0;
        end;

        AddStartCode(stato, CodeB, bEan128);
        stato := CodeB;
        Add2Work(Pos(sCaption[i], Code128CsB)-1);
      end;
    end;

  // Se pendono piu' di due interi aggiunge con CodeC
    if ctr_int >= 2 then
    begin
      while ctr_int >= 2 do  // se rimangono pendenti degli interi usa tutto code b
      begin
        sCoppia := BuildCoppia(sCaption, i-ctr_int-1);
        try
          iCoppia := StrToInt(sCoppia);
        except
        end;
        if stato <> CodeC then
        begin
          AddStartCode(stato, CodeC, bEan128);
          stato := CodeC;
        end;
        Add2Work(iCoppia);
        ctr_int := ctr_int-2;
      end;
    end;

  // Se rimane solo un intero aggiunge come CodeB
    if ctr_int = 1 then
    begin
      if stato = CodeC then
        AddStartCode(stato, CodeB, bEan128);
      if sCaption[i-ctr_int] <> #0 then
        Add2Work(Pos(sCaption[i-ctr_int], Code128CsB)-1);
      ctr_int := 0;
    end;
  end;

  function CalcCD : integer;
  var i, hold : integer;
  begin
  // Mette lo start
    hold := work[1];
  // Somma tutti gli altri moltiplicati per la posizione
    for i:=2 to iPtr do
      hold := hold + (work[i] * (i-1));
    Result := hold mod 103;
  end;

begin

// for each character in caption need 11 moduli + stop (7) + cd (6) + start(6)
// poi moltiplico per NarrowWidth che e' la larghezza del modulus base
  BarCodeWidth:= ((Length(Caption)*11) + 7 + 12) * NarrowWidth;
//  if BarCodeWidth > Width then exit; {if we can't fit the whole thing then give up}

  {set LeftEdge according to Alignment}
  case Alignment of
    taLeftJustify:  LeftEdge:=Left;
    taCenter:       LeftEdge:=Left+((Width-BarCodeWidth) div 2);
    taRightJustify: LeftEdge:=Left+Width-BarCodeWidth;
  end;

  CalcPrintString(Caption);
  iCd := CalcCD;
  Add2Work(iCd);
  Add2Work(CODE128_STOP);

  WorkH := Height - Canvas.TextHeight('A');
  if TestoInChiaro then
  begin
    Canvas.Brush.Color := 16777215;
    Canvas.TextOut(LeftEdge,Height-(Height-WorkH),Caption);
    Canvas.Brush.Color := clBlack;
  end;

  TopEdge := Top;
  for i:=1 to iPtr do
  begin
    if i = iPtr then
      Last := 14 // was   12
    else
      Last := 11;
    sPrintstring := Code128CS[Work[i]];
    for y:=1 to Last do
    begin
      PaintABar('N',sPrintstring[y]='N',Canvas,LeftEdge,TopEdge,WorkH,
        NarrowWidth,WideWidth,Angle,Width);
    end;
  end;
end;

{This routine is global in any project that uses this unit}
procedure BarCodePaint(BarCodeType: TBarCodeType;     { tipo di barcode }
                       Caption:String;                 {barcode value to paint}
                       Canvas:TCanvas;                 {canvas to paint it on}
                       left,top,width,height,angle:integer;  {rectangle to paint it in}
                       Alignment:tAlignment;           {how to align it}
                       Scale:integer;
                       TestoInChiaro : boolean;
                       rNarrowWidth  : single;
                       var BarcodeWidth : integer
                       );
var
  NarrowWidth,WideWidth:integer;  {width of narrow & wide bars}
  OldBrush : TBrush;
  OldPen   : TPen;
begin
  if Caption='' then exit;        {nothing to do}

  _nBar := 0;
  PixelsPerInch := GetDeviceCaps(Canvas.Handle, LOGPIXELSX);
//  if PixelsPerInch = 600 then PixelsPerInch := 480;
//  PixelsPerInch :=  PixelsPerInch div Screen.PixelsPerInch;

  {Calculate widths of bars, take into account Pixels per inch, i.e. on the
   screen NarrowWidth=1, on a 600dpi printer, NarrowWidth=6}
//  NarrowWidth:=trunc(1.0*PixelsPerInch/96.0)*Scale;

{ nf: calcolo larghezza barra stretta:
  Pixel = mm * Pollici/mm * Pixel/Pollice }

  NarrowWidth := trunc(rNarrowWidth * (1 / 25.4) * (PixelsPerInch) );
  if NarrowWidth = 0 then NarrowWidth := 1;
  WideWidth   := NarrowWidth * Scale;

  {set Brush and Pen for printing}
  {$ifndef _DEBUG}
  try
    OldBrush := TBrush.Create;
    OldBrush.Assign(Canvas.Brush);
    OldPen := TPen.Create;
    OldPen.Assign(Canvas.Pen);

    Canvas.Brush.color:=clBlack;
    Canvas.Brush.style:=bsSolid;
    Canvas.Pen.color  :=clBlack;
    Canvas.Pen.style  :=psSolid;
    Canvas.Pen.width  :=0;
    {$endif}

    case BarCodeType of

    btCode39:
      BarCodePaint139(Caption,Canvas,left,top,width,height,angle,
        NarrowWidth,WideWidth,Alignment,TestoInChiaro,BarcodeWidth);

    btInter25, btInter25CD:
      BarCodePaintI25(BarCodeType,Caption,Canvas,left,top,width,height,angle,
        NarrowWidth,WideWidth,Alignment,TestoInChiaro,BarcodeWidth);

    btCode128:
      BarCodePaint128(Caption,Canvas,left,top,width,height,angle,
        NarrowWidth,WideWidth,Alignment,TestoInchiaro,BarcodeWidth);

    btEan128:
      BarCodePaint128(Caption,Canvas,left,top,width,height,angle,
        NarrowWidth,WideWidth,Alignment,TestoInchiaro,BarcodeWidth,True);

    btEan13:
      BarCodePaintEan13(Caption,Canvas,left,top,width,height,angle,
        NarrowWidth,WideWidth,Alignment,TestoInchiaro,BarcodeWidth);

    else
      raise Exception.Create('Tipo di barcode sconosciuto');
    end;

    Canvas.Pen.Assign(OldPen);
    Canvas.Brush.Assign(OldBrush);
  finally
    OldPen.Free;
    OldBrush.Free;
  end;
end;

end.
