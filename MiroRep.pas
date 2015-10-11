{*******************************************************}
{                                                       }
{         Delphi Miro Utilities                         }
{                                                       }
{         Copyright (c) 1997, 1998 IT LOGISTICA Srl     }
{                                                       }
{*******************************************************}
{ 10/11/98 Aggiunta Preview                             }
{*******************************************************}
unit MiroRep;

interface

uses Classes, NikShape,Controls, ListShape, Graphics;

type
  TMiroRep = class(TComponent)
  private
    _iCount  : integer; // conta i componenti presenti
    NewObj   : TNikShape;
    FS       : TFileStream;
    aColl    : TListShape;
    bStartedDoc : boolean;
    procedure ClearList;
  public
    procedure Preview(aCanvas : TCanvas);
    constructor Create(AOwner : TComponent); overload;
    constructor Create(AOwner : TComponent; const sPath : string); overload;
    destructor Destroy; override;
    function FindComponent(const sName : string) : TNikShape;
    procedure Setta(const sName, sVal : string);
    procedure Load(const sPath : string);
    procedure Print;
    procedure StartJob;
    procedure EndJob;
  end;

implementation

uses Printers, SysUtils{fmOpenRead};

procedure TMiroRep.Preview(aCanvas : TCanvas);
var
  WmfCanvas: TMetafileCanvas;
  Wmf      : TMetafile;
  a        : integer;
  aNik     : TNikShape;
begin
  if _iCount = 0 then exit;
  try
    Wmf := TMetafile.Create;
    Wmf.Enhanced := True {False} ;
    Wmf.Width  := 800;
    Wmf.Height := 600;
    Wmf.MMWidth  := 29600;
    Wmf.MMHeight := 21000;
    Wmf.Inch   := 96;

    // create the virtual canvas
    WmfCanvas := TMetafileCanvas.CreateWithComment(Wmf, 0, 'MiroRep', 'Miro metafile');

    try
      for a := 0 to aColl.GetNumItems-1 do
      begin
        aNik := aColl.GetElement(a) as TNikShape;
        if aNik <> nil then
          (aNik as TNikShape).Paint2Canvas(WmfCanvas);
      end;
    finally
      WmfCanvas.Free;
    end;

// NB nel TMetaFile il contenuto e' trasferito solo dopo la TMetaFileCanvas.free!
    aCanvas.StretchDraw (aCanvas.ClipRect, Wmf);
  finally
    Wmf.Free;
  end;
end;

constructor TMiroRep.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  aColl := TListShape.Create;
  bStartedDoc := False;
end;

constructor TMiroRep.Create(AOwner : TComponent; const sPath : string);
begin
  inherited Create(AOwner);
  aColl := TListShape.Create;
  bStartedDoc := False;
  Load(sPath);
end;

destructor TMiroRep.Destroy;
begin
  aColl.Free;
  inherited Destroy;
end;

procedure TMiroRep.Setta(const sName, sVal : string);
var aSh : TNikShape;
begin
  aSh := FindComponent(sName);
  if aSh = nil then exit;
  aSh.Testo := sVal;
end;

function TMiroRep.FindComponent(const sName : string) : TNikShape;
var i : integer;   aSh : TNikShape;
begin
  Result:=nil;
  for i:=1 to aColl.GetNumItems do
  begin
    aSh := aColl.GetElement(i);
    if UpperCase(aSh.Nome) = UpperCase(sName) then
    begin
      Result := aSh;
      exit;
    end;
  end;
  if Result = nil then
    raise Exception.Create('Campo non trovato '+sName);
end;

procedure TMiroRep.ClearList;
var i : integer;
begin
  for i := 1 to aColl.GetNumItems do
    aColl.KillItem(0); {successively removes first item to empty list}
end;

procedure TMiroRep.Load(const sPath : string);
var NewObj : TNikShape;
begin
// Pulisce la lista se c'era gia'
  ClearList;
  _iCount := 0;
  try
    FS := TFileStream.Create(sPath,fmOpenRead or fmShareDenyWrite);
  except
    raise Exception.Create('Fallita apertura file '+sPath);
  end;
  try
    while FS.Position < FS.Size do
    begin
      NewObj           := TNikShape.Create(Self);
      FS.ReadComponent(NewObj);
      inc(_iCount);
      if NewObj.ImagePath <> '' then
        NewObj.SetImage(NewObj.ImagePath);
// Setta le impostazioni della stampante
      if NewObj.Shape = stSetup then
        NewObj.SetDriverMode
      else
        aColl.AddToList(NewObj);
    end;
  finally
    FS.Free;
  end;
end;

procedure TMiroRep.StartJob;
begin
  if not bStartedDoc then
  begin
    Printer.BeginDoc;
    bStartedDoc := True;
  end
  else
    Printer.NewPage;
end;

procedure TMiroRep.EndJob;
begin
  bStartedDoc := False;
  Printer.EndDoc;
end;

procedure TMiroRep.Print;
var
  a : Integer; aNik : TNikShape;
begin
  StartJob;
  for a := 0 to aColl.GetNumItems-1 do
  begin
    aNik := aColl.GetElement(a) as TNikShape;
    if aNik <> nil then
      aNik.Print;
  end;
//  Printer.EndDoc;
end;

end.
