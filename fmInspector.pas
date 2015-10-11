unit fmInspector;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, DsgnIntf, NikShape, ExtCtrls, OvcBase, OvcNbk;

type
  TfrmInspector = class(TForm)
    FontDialog1: TFontDialog;
    pgeProp: TOvcNotebook;
    OvcController1: TOvcController;
    pnlTop: TPanel;
    Label14: TLabel;
    edtNome: TEdit;
    Label19: TLabel;
    lucTipi: TComboBox;
    Label5: TLabel;
    edtTesto: TEdit;
    Label10: TLabel;
    lucAlign: TComboBox;
    Label20: TLabel;
    Label3: TLabel;
    edtWidth: TEdit;
    Label15: TLabel;
    edtWcm: TEdit;
    Label1: TLabel;
    edtLeft: TEdit;
    Label17: TLabel;
    edtLcm: TEdit;
    Label4: TLabel;
    edtHeight: TEdit;
    Label16: TLabel;
    edtHcm: TEdit;
    Label2: TLabel;
    edtTop: TEdit;
    Label18: TLabel;
    edtTcm: TEdit;
    Label8: TLabel;
    lucBcTipi: TComboBox;
    Label12: TLabel;
    edtNarrow: TEdit;
    chkTesto: TCheckBox;
    Label13: TLabel;
    edtBCW: TEdit;
    Label11: TLabel;
    edtImage: TEdit;
    btnImage: TSpeedButton;
    pnlBot: TPanel;
    btnOk: TBitBtn;
    BitBtn2: TBitBtn;
    lucCampi: TComboBox;
    Label6: TLabel;
    edtFontName: TEdit;
    SpeedButton1: TSpeedButton;
    Label7: TLabel;
    edtFontSize: TEdit;
    Label9: TLabel;
    edtAngle: TEdit;
    btnDisconnect: TBitBtn;
    lucBCRot: TListBox;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    lucCampiL: TComboBox;
    btnDiscL: TBitBtn;
    lucCampiT: TComboBox;
    btnDiscT: TBitBtn;
    edtSSCC: TEdit;
    Label24: TLabel;
    edtSSCCCD: TEdit;
    procedure btnOkClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure btnImageClick(Sender: TObject);
    procedure edtWcmExit(Sender: TObject);
    procedure edtHcmExit(Sender: TObject);
    procedure edtLcmExit(Sender: TObject);
    procedure edtTcmExit(Sender: TObject);
    procedure lucCampiChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lucCampiClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnDiscLClick(Sender: TObject);
    procedure btnDiscTClick(Sender: TObject);
    procedure lucCampiLChange(Sender: TObject);
    procedure lucCampiTChange(Sender: TObject);
  private
    { Private declarations }
    aNikShape : TNikShape;  // Il componente corrente
    _nsLinkTo, _nsLinkLeft, _nsLinkTop : TNikShape;  // Quello a cui e' collegato attualmente
    MyFont : TFont;
    aForm : TForm;          // Il Form "owner"
    FscX, FscY,
    _iRotPrec : integer;    // Rotazione attuale (per sapere se e' stata cambiata)
    fTmp  : single;
    procedure LoadCampi(aForm : TForm; aCombo : TComboBox; aLink : TNikShape);
    procedure Check(var tmp : single; const aEdt : TEdit);
    function CalcPixel(const scala, offset : integer; const sStr : string) : string;
    function MyTrova(const sNome : string) : TComponent;
  public
    { Public declarations }
    FOffsetX, FOffsetY : integer;
    constructor CreateFor(AOwner, Component: TComponent);
  end;

TObjInspector = class(TComponentEditor)
  public
    function GetVerbCount : integer; override;
    function GetVerb(Index : integer): string; override;
    procedure ExecuteVerb(Index : integer); override;
  end;

function CreateLogFont(Angolo : integer; aCanvas : TCanvas) : TFont;
procedure Register;

implementation

uses Barcoder, ImageWin, Printers;

{$R *.DFM}

procedure Register;
begin
  RegisterComponentEditor(TNikShape, TObjInspector);
end;

function TObjInspector.GetVerbCount : integer;
begin
  Result:=1;
end;

function TObjInspector.GetVerb(Index : integer) : string;
begin
  Result := 'Proprie&tà';
end;

procedure TObjInspector.ExecuteVerb(Index : integer);
var frmInspector : TfrmInspector; iLeft,iTop : integer;
begin
  frmInspector := TfrmInspector.Create(Application);
  try
    if frmInspector.Showmodal = mrOK then
    begin
      try
        iLeft := StrToInt(frmInspector.edtLeft.Text);
      except
        iLeft := 0;
      end;
      if iLeft <> 0 then
        TNikShape(Component).Left := iLeft;
      try
        iTop := StrToInt(frmInspector.edtTop.Text);
      except
        iTop := 0;
      end;
      if iTop <> 0 then
        TNikShape(Component).Top  := iTop;
      TNikShape(Component).Testo:= frmInspector.edtTesto.Text;
    end;
  finally
    frmInspector.Free;
  end;
  Designer.Modified;
end;


function TfrmInspector.MyTrova(const sNome : string) : TComponent;
var a : integer;
begin
  Result:=nil;
  with aForm do
  begin
    for a := 0 to aForm.ControlCount-1 do
      if aForm.Controls[a] is TNikShape then
      begin
        if UpperCase((aForm.Controls[a] as TNikShape).Nome) = UpperCase(sNome) then
        begin
          Result := aForm.Controls[a] as TNikShape;
          exit;
        end;
      end;
  end;
end;

procedure TfrmInspector.LoadCampi(aForm: TForm; aCombo : TComboBox; aLink : TNikShape);
var a, iItemLink : integer;
begin
  aCombo.Items.Clear;
  iItemLink := -1;
  with aForm do
  begin
    for a := 0 to aForm.ControlCount-1 do
      if aForm.Controls[a] is TNikShape then
      begin
// Aggiunge solo quelli diversi da se' stesso...
        if (aForm.Controls[a] as TNikShape) <> aNikShape then
          aCombo.Items.Add((aForm.Controls[a] as TNikShape).Nome);

// Determina la posizione del campo a cui e' collegato, se esiste
        if (aLink<>nil) and
          ( (aForm.Controls[a] as TNikShape).Nome = aLink.Nome ) then
          iItemLink := aCombo.Items.Count;
          
      end;
    if iItemLink >=0 then
      aCombo.ItemIndex := iItemLink-1;
  end;
end;

constructor TfrmInspector.CreateFor(AOwner, Component: TComponent);
var iItemLink, a : integer;
begin
  inherited Create(AOwner);
  aNikShape := TNikShape(Component);

  aForm := AOwner as TForm;

  _nsLinkTo   := aNikShape.LinkTo;
  _nsLinkTop  := aNikShape.LinkTop;
  _nsLinkLeft := aNikShape.LinkLeft;

  FOffsetX := (AOwner as TForm).Horzscrollbar.Position;
  FOffsetY := (AOwner as TForm).Vertscrollbar.Position;

// Carica i nomi dei campi
  LoadCampi(aForm, lucCampi, _nsLinkTo);
  LoadCampi(aForm, lucCampiL, _nsLinkLeft);
  LoadCampi(aForm, lucCampiT, _nsLinkTop);

  MyFont    := aNikShape.Canvas.Font;
  with aNikShape do
  begin
    lucTipi.ItemIndex := ord(aNikShape.Shape);
    FscX := GetDeviceCaps(Canvas.Handle, LOGPIXELSX);
    FscY := GetDeviceCaps(Canvas.Handle, LOGPIXELSY);
    edtNome.Text := Nome;
    edtLeft.Text := IntToStr(Left);
    edtTop.Text  := intToStr(Top);
    edtTesto.Text := Testo;
    edtWidth.Text := IntToStr(Width);
    edtHeight.Text := IntToStr(Height);
    if Shape=stImage then
      edtImage.Text := ImagePath;
//    Wmm := (Width  / FscX) * 25.4;
    try
      edtWcm.Text := FloatToStr(Wmm);
    except
    end;

//    Hmm := (Height div (FscY)) * 25.4;
    try
      edtHcm.Text := FloatToStr(Hmm);
    except
    end;

//    Lmm := (Left  div (FscX)) * 25.4;
    try
      edtLcm.Text := FloatToStr(Lmm);
    except
    end;

//    Tmm := (Top div (FscY)) * 25.4;
    try
      edtTcm.Text := FloatToStr(Tmm);
    except
    end;

    edtAngle.Text := IntToStr(Angolo);
    edtFontName.Text := Canvas.Font.Name;
    edtFontSize.Text := IntTostr(Canvas.Font.Size);
    edtNarrow.Text   := FloatToStr(NarrowWidth);
    edtBCW.Text      := IntToStr(BCWidth);
    chkTesto.Checked := TestoinChiaro;

    if Shape=stBarcode then
    begin
      case Angolo of
      0:  lucBCRot.ItemIndex := 0;
      90: lucBCRot.ItemIndex := 1;
      end;
      _iRotPrec := lucBCRot.ItemIndex;
    end
    else
      _iRotPrec := -1;

    case aNikShape.Barcode of
    btCode39:    lucBcTipi.ItemIndex:=1;
    btCode128:   lucBcTipi.ItemIndex:=2;
    btInter25:   lucBcTipi.ItemIndex:=3;
    btInter25cd: lucBcTipi.ItemIndex:=4;
    btEan8:      lucBcTipi.ItemIndex:=5;
    btEan13:     lucBcTipi.ItemIndex:=6;
    btEan128:
      begin
        lucBcTipi.ItemIndex:=7;
        edtSSCC.Text   := aNikShape.SSCC;
        edtSSCCCD.Text := aNikShape.SSCCCD;
      end;
    end;
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

procedure TfrmInspector.btnOkClick(Sender: TObject);
var iW,iH,iLeft, iTop, iAng, aTmp : integer; rNW : single;
begin
  aNikShape.Nome := edtNome.Text;

  if edtImage.Text <> '' then
  begin
    aNikShape.SetImage(edtImage.Text);
// Setta width e height uguali a quelli dell'immagine scelta...
    edtWidth.Text := IntToStr(aNikShape.Image.Width);
    edtHeight.Text := IntToStr(aNikShape.Image.Height);
  end;

  try
    iLeft := StrToInt(edtLeft.Text);
  except
    iLeft := 0;
  end;
  if iLeft<>0 then
    aNikShape.Left := iLeft;

  try
    iAng := StrToInt(edtAngle.Text);
  except
    iAng := 0;
  end;

  try
    iW := StrToInt(edtWidth.Text);
  except
    iW := 0;
  end;
  if iW <> 0 then
    aNikShape.Width := iW;

  try
    iH := StrToInt(edtHeight.Text);
  except
    iH := 0;
  end;
  if iH<>0 then
    aNikShape.Height := iH;

  try
    rNW := StrToFloat(edtNarrow.Text);
  except
    rNW := 1;
  end;
  aNikShape.NarrowWidth := rNW;

  if iLeft <> 0 then
    aNikShape.Left := iLeft;
  try
    iTop := StrToInt(edtTop.Text);
  except
    iTop := 0;
  end;
  if iTop <> 0 then
    aNikShape.Top  := iTop;
  aNikShape.Testo:= edtTesto.Text;

  with aNikShape do
  begin
    Tmm := StrToFloat(edtTcm.Text);
    Lmm := StrToFloat(edtLcm.Text);
    Wmm := StrToFloat(edtWcm.Text);
    Hmm := StrToFloat(edtHcm.Text);
  end;

  if aNikShape.Shape=stBarcode then
    case lucBCRot.ItemIndex of
    0:   aNikShape.Angolo := 0;
    1:
      begin
        aNikShape.Angolo := 90;
// Scambia altezza e larghezza se variato angolo
        if lucBCRot.ItemIndex<>_iRotPrec then
        begin
          aTmp := Width;
          Width := Height;
          Height := aTmp;
        end;
      end;
    end
  else
    aNikShape.Angolo := iAng;

  aNikShape.TestoinChiaro := chkTesto.Checked;
  case lucBcTipi.ItemIndex of
  1: aNikShape.Barcode := btCode39;
  2: aNikShape.Barcode := btCode128;
  3: aNikShape.Barcode := btInter25;
  4: aNikShape.Barcode := btInter25cd;
  5: aNikShape.Barcode := btEan8;
  6: aNikShape.Barcode := btEan13;
  7: aNikShape.Barcode := btEan128;
  end;
  if aNikShape.Barcode = btEan128 then
    if edtSSCC.Text <> '' then
      aNikShape.SSCC := edtSSCC.Text;
end;

procedure TfrmInspector.SpeedButton1Click(Sender: TObject);
begin
  with FontDialog1 do
  begin
// Posiziona la dialog sul font corrente  
    Font := MyFont;
    if Execute then
    begin
      MyFont := Font;
      aNikShape.Font.Assign(MyFont);
      aNikShape.Canvas.Font.Assign(MyFont);
      edtFontName.Text := Font.Name;
      edtFontSize.Text := IntToStr(Font.Size);
    end;
  end;
end;

procedure TfrmInspector.btnImageClick(Sender: TObject);
begin
  with ImageForm do
   if ShowModal = mrOk then
     edtImage.Text := FileListBox1.Filename;
end;

function TfrmInspector.CalcPixel(const scala, Offset : integer; const sStr : string) : string;
var aTmp : real; iW : integer;
begin
  Result := '';
  try
    aTmp := StrToFloat(sStr);
  except
    exit;
  end;
  iW := round((aTmp / 25.4) *scala);
  iW := iW - Offset;
  Result := FloatToStr(iW);
end;

procedure TfrmInspector.Check(var tmp : single; const aEdt : TEdit);
begin
  try
    tmp := StrToFloat(aEdt.Text);
  except
    tmp:=0;
  end;
end;

procedure TfrmInspector.edtWcmExit(Sender: TObject);
begin
  Check(fTmp, edtWcm);
  if fTmp <> aNikShape.Wmm then
    edtWidth.Text := CalcPixel(FscX, FOffsetX, edtWcm.Text);
end;

procedure TfrmInspector.edtHcmExit(Sender: TObject);
begin
  Check(fTmp, edtHcm);
  if fTMp <> aNikShape.Hmm then
    edtHeight.Text := CalcPixel(FscY, FOffsetY, edtHcm.Text);
end;

procedure TfrmInspector.edtLcmExit(Sender: TObject);
begin
  Check(fTmp, edtLcm);
  if fTmp <> aNikShape.Lmm then
    edtLeft.Text := CalcPixel(FscX,  FOffsetX, edtLcm.Text);
end;

procedure TfrmInspector.edtTcmExit(Sender: TObject);
begin
  Check(fTmp, edtTcm);
  if fTmp <> aNikShape.Tmm then
    edtTop.Text := CalcPixel(FscY,  0{FOffsetY}, edtTcm.Text);
end;

procedure TfrmInspector.lucCampiChange(Sender: TObject);
var sNome : string; aComp : TComponent;
begin
  sNome := lucCampi.Items[lucCampi.ItemIndex];
// Scollega se era collegato..
  if (sNome='') and (_nsLinkTo<>nil) then
  begin
    aNikShape.LinkTo:=nil;
    exit;
  end;
//  aComp := aForm.FindComponent(sNome);
  aComp := MyTrova(sNome);
// Controlla di aver trovato il componente
  if aComp=nil then exit;
// Controlla che sia un NikShape
  if not (aComp is TNikShape) then exit;
// Controlla che sia uno di quelli con il testo
  if (aComp as TNikShape).Shape in [stBarcode, stText] then
// Se tutto ok setta il link...
    aNikShape.LinkTo := aComp as TNikShape;
end;

procedure TfrmInspector.FormShow(Sender: TObject);
begin
  edtTesto.SetFocus;
end;

procedure TfrmInspector.lucCampiClick(Sender: TObject);
var sNome : string; aComp : TComponent;
begin
  sNome := lucCampi.Items[lucCampi.ItemIndex];
  aComp := aForm.FindComponent(sNome);
// Controlla di aver trovato il componente
  if aComp=nil then exit;
// Controlla che sia un NikShape
  if not (aComp is TNikShape) then exit;
// Controlla che sia uno di quelli con il testo 
  if (aComp as TNikShape).Shape in [stBarcode, stText] then
// Se tutto ok setta il link...
    aNikShape.LinkTo := aComp as TNikShape;
end;


procedure TfrmInspector.btnDisconnectClick(Sender: TObject);
begin
  lucCampi.ItemIndex := -1;
  if _nsLinkTo<>nil then
  begin
    _nsLinkTo:=nil;
    aNikShape.LinkTo:=nil;
  end;
end;

procedure TfrmInspector.btnDiscLClick(Sender: TObject);
begin
  lucCampiL.ItemIndex := -1;
  if _nsLinkLeft<>nil then
  begin
    _nsLinkLeft:=nil;
    aNikShape.LinkLeft:=nil;
  end;
end;

procedure TfrmInspector.btnDiscTClick(Sender: TObject);
begin
  lucCampiT.ItemIndex := -1;
  if _nsLinkTop<>nil then
  begin
    _nsLinkTop:=nil;
    aNikShape.LinkTop:=nil;
  end;
end;

procedure TfrmInspector.lucCampiLChange(Sender: TObject);
var sNome : string; aComp : TComponent;
begin
  with (Sender as TComboBox) do
    sNome := Items[ItemIndex];
// Scollega se era collegato..
  if (sNome='') and (_nsLinkLeft<>nil) then
  begin
    aNikShape.LinkLeft:=nil;
    exit;
  end;
//  aComp := aForm.FindComponent(sNome);
  aComp := MyTrova(sNome);
// Controlla di aver trovato il componente
  if aComp=nil then exit;
// Controlla che sia un NikShape
  if not (aComp is TNikShape) then exit;
// Controlla che sia uno di quelli con il testo
  if (aComp as TNikShape).Shape in [stBarcode, stText] then
// Se tutto ok setta il link...
    aNikShape.LinkLeft := aComp as TNikShape;
end;

procedure TfrmInspector.lucCampiTChange(Sender: TObject);
var sNome : string; aComp : TComponent;
begin
  with (Sender as TComboBox) do
    sNome := Items[ItemIndex];
// Scollega se era collegato..
  if (sNome='') and (_nsLinkTop<>nil) then
  begin
    aNikShape.LinkTop:=nil;
    exit;
  end;
//  aComp := aForm.FindComponent(sNome);
  aComp := MyTrova(sNome);
// Controlla di aver trovato il componente
  if aComp=nil then exit;
// Controlla che sia un NikShape
  if not (aComp is TNikShape) then exit;
// Controlla che sia uno di quelli con il testo
  if (aComp as TNikShape).Shape in [stBarcode, stText] then
// Se tutto ok setta il link...
    aNikShape.LinkTop := aComp as TNikShape;
end;

end.


