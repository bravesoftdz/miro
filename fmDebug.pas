unit fmDebug;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, NikShape, ExtCtrls {nikShape};

type
  TfrmDebug = class(TForm)
    Label1: TLabel;
    edtTot: TEdit;
    btnDec: TButton;
    btnInspect: TButton;
    btnInc: TButton;
    btnDelete: TButton;
    Label2: TLabel;
    edtCorr: TEdit;
    Label3: TLabel;
    edtNome: TEdit;
    btnAlza: TButton;
    Label4: TLabel;
    edtVal: TEdit;
    btnRicalcola: TButton;
    lstNames: TListBox;
    GroupBox1: TGroupBox;
    btnTop: TButton;
    btnLeft: TButton;
    cbxSegno: TComboBox;
    btnWidth: TButton;
    btnHeight: TButton;
    Bevel1: TBevel;
    btnAzzera: TButton;
    procedure btnInspectClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnIncClick(Sender: TObject);
    procedure btnDecClick(Sender: TObject);
    procedure btnAlzaClick(Sender: TObject);
    procedure btnRicalcolaClick(Sender: TObject);
    procedure btnTopClick(Sender: TObject);
    procedure btnLeftClick(Sender: TObject);
    procedure btnWidthClick(Sender: TObject);
    procedure btnHeightClick(Sender: TObject);
    procedure btnAzzeraClick(Sender: TObject);
  private
    { Private declarations }
    _iLast, _iCorr : integer;
    rVal : single;
    FForm   : TForm;
    procedure DoWork(Sender: TObject);
    procedure Clear;
    function CheckVal : boolean;
  public
    { Public declarations }
    procedure Enter(iLast : integer; aForm : TForm; DelProc : TNotifyEvent);
  end;

var
  frmDebug: TfrmDebug;
  pNiks : array [1..100] of TNikShape;
  pNik : TNikShape;
  FDeleteProc : TNotifyEvent;

implementation

uses Libreria;

{$R *.DFM}

procedure TfrmDebug.Clear;
var i : integer;
begin
  for i:=Low(pNiks) to high(pNiks) do
    pNiks[i] := nil;
end;

procedure TfrmDebug.Enter(iLast : integer; aForm : TForm; DelProc : TNotifyEvent);
var a,b : integer;
begin
  Clear;
  cbxSegno.ItemIndex := 0;
  FDeleteProc := DelProc;
  FForm := aForm;
  b := 0;
  _iLast := iLast;
  edtTot.Text := IntToStr(iLast);
  lstNames.Items.Clear;
  if iLast > 0 then
  begin
    for a := 0 to aForm.ControlCount-1 do
      if aForm.Controls[a] is TNikShape then
      begin
        Inc(b);
        pNiks[b] := aForm.Controls[a] as TNikShape;
        lstNames.Items.Add(pNiks[b].Nome);
      end;
    pNik := pNiks[low(pNiks)];
    _iCorr := 1;
    edtNome.Text := pNik.Nome;
  end;
  edtCorr.Text := IntToStr(_iCorr);
  ShowModal;
end;

procedure TfrmDebug.btnInspectClick(Sender: TObject);
begin
  pNik.InspectObject(pNik);
end;

procedure TfrmDebug.btnDeleteClick(Sender: TObject);
begin
  if not MsgSiNo('Confermi la cancellazione ?') then exit;
  SelectedShape := pNik;
  if Assigned(FDeleteProc) then
    FDeleteProc(Sender);
  Close;
end;

procedure TfrmDebug.btnIncClick(Sender: TObject);
begin
  if _iCorr < _iLast then
  begin
    inc(_iCorr);
    pNik := pNiks[_iCorr];
    edtCorr.Text := IntToStr(_iCorr);
    edtNome.Text := pNik.Nome;
  end;
end;

procedure TfrmDebug.btnDecClick(Sender: TObject);
begin
  if _iCorr > 1 then
  begin
    dec(_iCorr);
    pNik := pNiks[_iCorr];
    edtCorr.Text := IntToStr(_iCorr);
    edtNome.Text := pNik.Nome;
  end;
end;

function TfrmDebug.CheckVal : boolean;
begin
  Result:=True;
  try
    rVal := StrToFloat(edtVal.Text);
  except
    MsgOk('Value empty! exiting');
    Result:=False;
    exit;
  end;
end;

procedure TfrmDebug.btnAlzaClick(Sender: TObject);
var
  iVal, a : integer; aNik : TNikShape;
begin
  if MsgSiNo('Uso pixel ?') then
  begin
    try
      iVal := StrToInt(edtVal.Text);
    except
      MsgOk('Valore non valido!');
      exit;
    end;
    for a := 0 to FForm.ControlCount-1 do
      if FForm.Controls[a] is TNikShape then
      begin
        aNik := FForm.Controls[a] as TNikShape;
        aNik.Top := aNik.Top - iVal;
      end;
  end
  else
  begin
    if not CheckVal then exit;
    for a := 0 to FForm.ControlCount-1 do
      if FForm.Controls[a] is TNikShape then
      begin
        aNik := FForm.Controls[a] as TNikShape;
        aNik.Tmm := aNik.Tmm - rVal;
      end;
  end;
end;

procedure TfrmDebug.btnRicalcolaClick(Sender: TObject);
var
  a, Scale : integer;
  aNik : TNikShape;
begin
  if not MsgSiNo('Confermi il ricalcolo di tutte le coordinate?') then exit;
  Scale := FForm.PixelsPerInch;
  for a := 0 to FForm.ControlCount-1 do
    if FForm.Controls[a] is TNikShape then
    begin
      aNik := FForm.Controls[a] as TNikShape;
      if aNik.Lmm <> 0 then
        aNik.Left := round((aNik.Lmm / 25.4) * scale);
      if aNik.Tmm <> 0 then
        aNik.Top  := round((aNik.Tmm / 25.4) * scale);
    end;
end;

procedure TfrmDebug.btnTopClick(Sender: TObject);
begin
  DoWork(Sender);
end;

procedure TfrmDebug.DoWork(Sender: TObject);
var i,a : integer; aNik : TNikShape; bPiu : boolean;
begin
  if not CheckVal then exit;
  if lstNames.SelCount=0 then
  begin
    MsgOk('None selected!');
    exit;
  end;
  bPiu := cbxSegno.ItemIndex=0;

  for i:=0 to lstNames.Items.Count-1 do
  begin
    if lstNames.Selected[i] then
      for a := 0 to FForm.ControlCount-1 do
        if FForm.Controls[a] is TNikShape then
        begin
          aNik := FForm.Controls[a] as TNikShape;
          if aNik.Nome = lstNames.Items[i] then
          begin
// Alza / Abbassa
            if (Sender as TButton).Name = 'btnTop' then
              case cbxSegno.ItemIndex of
              0 : {bPiu}
                aNik.Tmm := aNik.Tmm + rVal;
              1 :  {meno}
                aNik.Tmm := aNik.Tmm - rVal;
              2 : {Set}
                aNik.Tmm := rVal;
              end;
// Destra / sinistra
            if (Sender as TButton).Name = 'btnLeft' then
              case cbxSegno.ItemIndex of
              0:
                aNik.Lmm := aNik.Lmm + rVal;
              1:
                aNik.Lmm := aNik.Lmm - rVal;
              2:
                aNik.Lmm := rVal;
              end;
// WidthMM
            if (Sender as TButton).Name = 'btnWidth' then
              case cbxSegno.ItemIndex of
              0:
                aNik.Wmm := aNik.Wmm + rVal;
              1:
                aNik.Wmm := aNik.Wmm - rVal;
              2:
                aNik.Wmm := rVal;
              end;
// HeightMM
            if (Sender as TButton).Name = 'btnHeight' then
              case cbxSegno.ItemIndex of
              0:
                aNik.Hmm := aNik.Hmm + rVal;
              1:
                aNik.Hmm := aNik.Hmm - rVal;
              2:
                aNik.Hmm := rVal;
              end;
          end;
        end;
  end;
end;

procedure TfrmDebug.btnLeftClick(Sender: TObject);
begin
  DoWork(Sender);
end;

procedure TfrmDebug.btnWidthClick(Sender: TObject);
begin
  DoWork(Sender);
end;

procedure TfrmDebug.btnHeightClick(Sender: TObject);
begin
  DoWork(Sender);
end;

procedure TfrmDebug.btnAzzeraClick(Sender: TObject);
var a : integer; aNik : TNikShape;
begin
  if not MsgSiNo('Confermi l''azzeramento delle coordinate in mm?') then exit;
  for a := 0 to FForm.ControlCount-1 do
    if FForm.Controls[a] is TNikShape then
    begin
      aNik := FForm.Controls[a] as TNikShape;
      aNik.Wmm := 0;
      aNik.Hmm := 0;
      aNik.Tmm := 0;
      aNik.Lmm := 0;                  
    end;
end;

end.
