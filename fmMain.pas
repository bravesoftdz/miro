unit fmMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Buttons, ExtCtrls, StdCtrls, Barcoder, NikShape, ListShape,
  IniFiles;

type

  TfrmMain = class(TForm)
    FormatMenu: TPopupMenu;
    mnuDelete: TMenuItem;           // Main popup menu items
    mnuSep1: TMenuItem;
    mnuBrushColor: TMenuItem;
    mnuBrushStyle: TMenuItem;
    mnuSep2: TMenuItem;
    mnuPenColor: TMenuItem;
    mnuPenStyle: TMenuItem;
    mnuPenWidth: TMenuItem;
    mnuBrushBDiag: TMenuItem;       // Brush Style menu items
    mnuBrushClear: TMenuItem;
    mnuBrushCross: TMenuItem;
    mnuBrushDiagCross: TMenuItem;
    mnuBrushFDiag: TMenuItem;
    mnuBrushHorizontal: TMenuItem;
    mnuBrushSolid: TMenuItem;
    mnuBrushVertical: TMenuItem;
    mnuPenClear: TMenuItem;         // Pen Style menu items
    mnuPenDash: TMenuItem;
    mnuPenDashDot: TMenuItem;
    mnuPenDashDotDot: TMenuItem;
    mnuPenDot: TMenuItem;
    mnuPenInsideFrame: TMenuItem;
    mnuPenSolid: TMenuItem;
    Width0: TMenuItem;              // Pen Width menu items
    Width1: TMenuItem;
    Width2: TMenuItem;
    Width3: TMenuItem;
    Width4: TMenuItem;
    Width5: TMenuItem;
    Width6: TMenuItem;
    dlgColor: TColorDialog;
    dlgSave: TSaveDialog;
    dlgOpen: TOpenDialog;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    View1: TMenuItem;
    mniNew: TMenuItem;
    mniOpen: TMenuItem;
    mniSave: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    mniPrint: TMenuItem;
    Bringtofront1: TMenuItem;
    Sendtoback1: TMenuItem;
    N2: TMenuItem;
    mniInspect: TMenuItem;
    PrinterSetupDialog1: TPrinterSetupDialog;
    PrintDialog1: TPrintDialog;
    mniPrintsetup: TMenuItem;
    mniDebug: TMenuItem;
    mniToolbar: TMenuItem;
    mniAbout1: TMenuItem;
    MRU1: TMenuItem;
    MRU2: TMenuItem;
    MRU3: TMenuItem;
    MRU4: TMenuItem;
    MRUSeparator: TMenuItem;
    mniPrint2metafile: TMenuItem;
    mniPreview: TMenuItem;
    mniVisiblemargins: TMenuItem;
    Edit1: TMenuItem;
    mniDuplicate: TMenuItem;
    mniSetbackground: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawGhost;
    procedure ShapeSelectClick(Sender: TObject);
    procedure DeleteClick(Sender: TObject);
    procedure BrushColorClick(Sender: TObject);
    procedure BrushStyleClick(Sender: TObject);
    procedure PenColorClick(Sender: TObject);
    procedure PenStyleClick(Sender: TObject);
    procedure PenWidthClick(Sender: TObject);
    procedure CountObjects;
    procedure DeleteObjects;
    procedure spdNewClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure mniRuler1Click(Sender: TObject);
//    procedure Righello;
    procedure Exit1Click(Sender: TObject);
    procedure Bringtofront1Click(Sender: TObject);
    procedure Sendtoback1Click(Sender: TObject);
    procedure mniInspectClick(Sender: TObject);
    procedure mniPrintsetupClick(Sender: TObject);
//    procedure pnlToolbarMouseDown(Sender: TObject; Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
    procedure mniDebugClick(Sender: TObject);
    procedure mniToolbarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure OpenFile(Sender: TObject);
    procedure SaveFile(Sender: TObject);
    procedure mniScaleClick(Sender: TObject);
    procedure mniAbout1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OpenMRU(Sender: TObject);
    procedure mniPrint2metafileClick(Sender: TObject);
    procedure mniPreviewClick(Sender: TObject);
    procedure mniVisiblemarginsClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure mniDuplicateClick(Sender: TObject);
    procedure mniSetbackgroundClick(Sender: TObject);
  private
    FBackgroundImage : TBitmap;
    NewObj           : TNikShape;
    _iLast           : integer;
    _bMultiSelect    : boolean;
    aListSelected    : TListShape;
    MRUList          : TStringList;
    FS               : TFileStream;
    AppIni           : TIniFile;
    procedure DrawMargins(const bDraw : boolean);
    procedure ApriFile(const sPath : string);
    procedure ResizeFont;
    procedure Print;
//    function MyGetFormImage : TBitmap;
    procedure Duplica(SelectedShape : TNikShape);
    procedure Nuovo(const X, Y : integer);
    procedure MRUDisplay;
    procedure MRUUpdate(Sender: TObject;const AddFileName: string);
    procedure CreaEMF(bSaveToDisk : boolean);
  public
    Creating : Boolean;
    X1,Y1    : Integer;
    X2,Y2    : Integer;
    ObjType  : TNikShapeType;
  end;

var
  frmMain: TfrmMain;


implementation

uses Libreria, Printers, fmInspector, fmDebug, fmTools, fmAbout, fmPreview, Registry,
  ImageWin;

{$R *.DFM}


procedure AssociaExt(const sExt, sPath : string);
var
  reg: TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  reg.LazyWrite := false;
  {Add Program Support}
  reg.OpenKey(sExt+'\shell\open\command', true);
  {Invoke the program passing the file name as the first parameter}
  reg.WriteString('',sPath+' %1');
  {Add Icon Display}
  reg.CloseKey;
  reg.OpenKey(sExt+'\DefaultIcon',true);
  {Use the first icon in the executable to display}
  reg.WriteString('',sPath+',0');
  reg.CloseKey;
  reg.free;
end;

function GetProgramAssociation (Ext : string) : string;
var
{$IFDEF WIN32}
 reg: TRegistry;
 s : string;
{$ELSE}
 WinIni : TIniFile;
 WinIniFileName : array[0..MAX_PATH] of char;
 s : string;
{$ENDIF}
begin
{$IFDEF WIN32}
 s := '';
 reg := TRegistry.Create;
 reg.RootKey := HKEY_CLASSES_ROOT;
 if reg.OpenKey('.' + ext + '\shell\open\command',
                false) <> false then begin
 {The open command has been found}
   s := reg.ReadString('');
   reg.CloseKey;
 end else begin
 {perhaps thier is a system file pointer}
   if reg.OpenKey('.' + ext,
                  false) <> false then begin
     s := reg.ReadString('');
     reg.CloseKey;
     if s <> '' then begin
    {A system file pointer was found}
       if reg.OpenKey(s + '\shell\open\command',
                      false) <> false then
    {The open command has been found}
         s := reg.ReadString('');
       reg.CloseKey;
     end;
   end;
 end;
{Delete any command line, quotes and spaces}
 if Pos('%', s) > 0 then
   Delete(s, Pos('%', s), length(s));
 if ((length(s) > 0) and
     (s[1] = '"')) then
   Delete(s, 1, 1);
 if ((length(s) > 0) and
     (s[length(s)] = '"')) then
   Delete(s, Length(s), 1);
 while ((length(s) > 0) and
        ((s[length(s)] = #32) or
         (s[length(s)] = '"'))) do
   Delete(s, Length(s), 1);
{$ELSE}
 GetWindowsDirectory(WinIniFileName, sizeof(WinIniFileName));
 StrCat(WinIniFileName, '\win.ini');
 WinIni := TIniFile.Create(WinIniFileName);
 s := WinIni.ReadString('Extensions',
                         ext,
                         '');
 WinIni.Free;
{Delete any command line}
 if Pos(' ^', s) > 0 then
   Delete(s, Pos(' ^', s), length(s));
{$ENDIF}
 result := s;
end;


procedure TfrmMain.MRUUpdate(Sender: TObject;const AddFileName: string);
var
  Index: Integer;   { Declare index variable }
begin
  Index := 0;
  { Compare AddFileName to MRUList items }
  while Index < (MRUList.count - 1) do
    if AddFileName = MRUList[Index] then
      { If already there, delete each occurrence }
      MRUList.delete(Index)
    else
      { If not, update Index and try next item }
      Index := Index + 1;
  while MRUList.count > 3 do
    MRUList.delete(MRUList.Count - 1);
  while MRUList.count < 3 do
    { Keep MRUList }
    MRUList.add('');
  { Then add fourth item to the top }
  MRUList.Insert(0,AddFilename);
end;

procedure TfrmMain.MRUDisplay;
begin
  MRU1.Caption := '&1 ' + MRUList[0];           {Set MRU menu item caption}
  MRU1.Visible := (MRUList[0] <> '');           {Visible if not blank}
  MRUSeparator.Visible := (MRUList[0] <> '');   {Seperator vis. if not blank}
  MRU2.Caption := '&2 ' + MRUList[1];
  MRU2.Visible := (MRUList[1] <> '');
  MRU3.Caption := '&3 ' + MRUList[2];
  MRU3.Visible := (MRUList[2] <> '');
  MRU4.Caption := '&4 ' + MRUList[3];
  MRU4.Visible := (MRUList[3] <> '');
end;

(*
function TfrmMain.MyGetFormImage: TBitmap;
var
  ScreenDC, PrintDC: HDC;
  OldBits, PrintBits: HBITMAP;
  PaintLParam: Longint;

  procedure PrintHandle(Handle: HWND);
  var
    R: TRect;
    Child: HWND;
    SavedIndex: Integer;
  begin
    if IsWindowVisible(Handle) then
    begin
      SavedIndex := SaveDC(PrintDC);
      Windows.GetClientRect(Handle, R);
      MapWindowPoints(Handle, Self.Handle, R, 2);
      with R do
      begin
        SetWindowOrgEx(PrintDC, -Left, -Top, nil);
        IntersectClipRect(PrintDC, 0, 0, Right - Left, Bottom - (Top-pnlToolbar.Height));
      end;
      SendMessage(Handle, WM_ERASEBKGND, PrintDC, 0);
      SendMessage(Handle, WM_PAINT, PrintDC, PaintLParam);
      Child := GetWindow(Handle, GW_CHILD);
      if Child <> 0 then
      begin
        Child := GetWindow(Child, GW_HWNDLAST);
        while Child <> 0 do
        begin
          PrintHandle(Child);
          Child := GetWindow(Child, GW_HWNDPREV);
        end;
      end;
      RestoreDC(PrintDC, SavedIndex);
    end;
  end;

begin
  Result := nil;
  ScreenDC := GetDC(0);
  PaintLParam := 0;
  try
    PrintDC := CreateCompatibleDC(ScreenDC);
    try
      PrintBits := CreateCompatibleBitmap(ScreenDC, ClientWidth, ClientHeight-pnlToolbar.Height);
      try
        OldBits := SelectObject(PrintDC, PrintBits);
        try
          { Clear the contents of the bitmap }
          FillRect(PrintDC, ClientRect, Brush.Handle);

          { Paint form into a bitmap }
          PrintHandle(Handle);
        finally
          SelectObject(PrintDC, OldBits);
        end;
        Result := TBitmap.Create;
        Result.Handle := PrintBits;
        PrintBits := 0;
      except
        Result.Free;
        if PrintBits <> 0 then DeleteObject(PrintBits);
        raise;
      end;
    finally
      DeleteDC(PrintDC);
    end;
  finally
    ReleaseDC(0, ScreenDC);
  end;
end; *)

procedure TfrmMain.FormCreate(Sender: TObject);
var Index : integer;
begin
//  SetMapMode(Canvas.Handle, MM_LOMETRIC);
  Canvas.Pen.Mode := pmXOr;
  Canvas.Pen.Style := psDot;
  ObjType := stSelect;
  Creating := False;
//  ShapeSelectClick(spdSquare);
//  Righello;
  MRUList := TStringList.Create;        {Create MRUList}
  AppIni:= TIniFile.Create('MIRO.INI');       {Create IniFile}
  for Index := 0 to 3 do                {Loop to read all 4 items from Ini}
    MRUList.Add(AppIni.ReadString('MRU', IntToStr(Index), ''));
  AppIni.Free;                           {Free IniFile variable}
  MRUDisplay;                    {Update MRU menu items}
  FBackgroundImage := nil;
end;

(*procedure TfrmMain.Righello;
begin
  mniRuler1.Checked := not mniRuler1.Checked;
  if mniRuler1.Checked then
  begin
    ClientHeight := Height - ccRuler.Height;
    pnlRuler.Visible := True;
  end
  else
  begin
    pnlRuler.Visible := False;
    ClientHeight := Height;
  end;
end; *)



procedure TfrmMain.Duplica(SelectedShape : TNikShape);
var
  nsNew : TNikShape;
  L,T,W,H : Integer;
begin
  nsNew := TNikShape.Clone(SelectedShape.Owner,SelectedShape);
  with nsNew do
    begin
      Parent := Self;
      PopupMenu := FormatMenu;
      Nome := 'niks'+IntToStr(_iLast+1);
      SelectedShape := nsNew;
    end;
  CountObjects;
end;

procedure TfrmMain.Nuovo(const X, Y : integer);
var
  L,T,W,H : Integer;
begin
  NewObj := TNikShape.Create(Self);
  with NewObj do
    begin
      Parent := Self;
      Shape := ObjType;
      PopupMenu := FormatMenu;
      Nome := 'niks'+IntToStr(_iLast+1);
      if ObjType = stBarcode then
        NewObj.InspectObject(NewObj);
      L := X1; W := X-X1;
      T := Y1; H := Y-Y1;
      if ObjType in [stCircle,stSquare,stRoundSquare] then
        if W < H then H := W else W := H;
      if ObjType = stLine then
        NewObj.Height := 4;
      SetBounds(L,T,W,H);
      SelectedShape := NewObj;
    end;
  CountObjects;
end;

procedure TfrmMain.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Creating) and (Button = mbLeft) and (ObjType <> stSelect) then
  begin
    DrawGhost;
    if (ObjType <> stLine) and ( (X<=X1) or (Y<=Y1) ) then exit;
    Nuovo(X, Y);
    Creating := False;
  end;
end;

procedure TfrmMain.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    X1 := X; Y1 := Y; X2 := X; Y2 := Y;
    Creating := True;
  end;
end;

procedure TfrmMain.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Creating and (ObjType <> stSelect) then //and (ssLeft in Shift) then
    begin
      if X <= X1 then X := X1+1;
      if (ObjType <> stLine) and (Y <= Y1) then Y := Y1+1;
      DrawGhost;  // Undraw the last image
      X2 := X; Y2 := Y;
      DrawGhost;  // Draw the new image
    end;
end;

procedure TfrmMain.DrawGhost;
var
  S : Integer;
begin
  S := Min(X2-X1,Y2-Y1);
  with Canvas do
    case ObjType of
      stCircle       : Arc(X1,Y1,X1+S,Y1+S,X1,Y1,X1,Y1);
      stEllipse      : Arc(X1,Y1,X2,Y2,X1,Y1,X1,Y1);
      stSquare,
      stRoundSquare  : begin
                         PolyLine([Point(X1,Y1),Point(X1+S,Y1),Point(X1+S,Y1+S)]);
                         PolyLine([Point(X1,Y1),Point(X1,Y1+S),Point(X1+S,Y1+S)]);
                       end;
{      stLine :
        begin
          MoveTo(X1, Y1);
          LineTo(X2, Y2);
        end; }

      stRectangle,
      stRoundRect,
      stText,
      stLine,
      stBarcode,
      stImage      : begin
                       PolyLine([Point(X1,Y1),Point(X2,Y1),Point(X2,Y2)]);
                       PolyLine([Point(X1,Y1),Point(X1,Y2),Point(X2,Y2)]);
                     end;
    end;
end;

procedure TfrmMain.ShapeSelectClick(Sender: TObject);
begin
  ObjType := TNikShapeType((Sender as TSpeedButton).Tag);
end;

procedure TfrmMain.DeleteClick(Sender: TObject);
begin
  SelectedShape.Free;
  SelectedShape := nil;
  CountObjects;
end;

procedure TfrmMain.PenColorClick(Sender: TObject);
begin
  dlgColor.Color := SelectedShape.Pen.Color;
  if dlgColor.Execute then SelectedShape.Pen.Color := dlgColor.Color;
end;

procedure TfrmMain.PenStyleClick(Sender: TObject);
begin
  SelectedShape.Pen.Style := TPenStyle((Sender as TMenuItem).Tag);
end;

procedure TfrmMain.PenWidthClick(Sender: TObject);
begin
  SelectedShape.Pen.Width := (Sender as TMenuItem).Tag;
end;

procedure TfrmMain.BrushColorClick(Sender: TObject);
begin
  dlgColor.Color := SelectedShape.Brush.Color;
  if dlgColor.Execute then SelectedShape.Brush.Color := dlgColor.Color;
end;

procedure TfrmMain.BrushStyleClick(Sender: TObject);
begin
  SelectedShape.Brush.Style := TBrushStyle((Sender as TMenuItem).Tag);
end;

procedure TfrmMain.CountObjects;
var
  a,b : Integer;
begin
  b := 0;
  for a := 0 to ControlCount-1 do if Controls[a] is TNikShape then Inc(b);
  frmTools.lblCount.Caption := 'Objects: '+IntToStr(b);
  _iLast := b;
end;

procedure TfrmMain.DeleteObjects;
var
  a : Integer;
  OneDeleted : Boolean;
begin
  Repeat
    OneDeleted := False;
    for a := 0 to ControlCount-1 do
     if Controls[a] is TNikShape then
       begin
         (Controls[a] as TNikShape).Free;
         OneDeleted := True;
         break;
       end;
  until Not OneDeleted;
  CountObjects;
end;

procedure TfrmMain.spdNewClick(Sender: TObject);
begin
  DeleteObjects;
  Caption := 'Miro - Untitled';
end;

procedure TfrmMain.ApriFile(const sPath : string);
begin
  DeleteObjects;
  FS := TFileStream.Create(sPath,fmOpenRead or fmShareDenyWrite);
  try
    while FS.Position < FS.Size do
      begin
        NewObj           := TNikShape.Create(Self);
        NewObj.Parent    := Self;
        NewObj.PopupMenu := FormatMenu;
//        try
          FS.ReadComponent(NewObj);
//        except        end;
        if NewObj.ImagePath <> '' then
          NewObj.SetImage(NewObj.ImagePath);          
// Setta le impostazioni della stampante
        if NewObj.Shape = stSetup then
          NewObj.SetDriverMode;
      end;
  finally
    FS.Free;
  end;
  Caption := 'Miro - '+ExtractFileName(sPath);
{Update MRUList using saved filename}
  MRUUpdate(Self, sPath);
  MRUDisplay;
  CountObjects;
end;

procedure TfrmMain.OpenFile(Sender: TObject);
begin
// TBI Discard changes?
  dlgOpen.FileName := '';
  if dlgOpen.Execute then
    ApriFile(dlgOpen.FileName);
end;

procedure TfrmMain.SaveFile(Sender: TObject);
var
  a : Integer; aSetup : TNikShape; bCreaSetup : boolean;
begin
  if dlgSave.Execute then
  begin
    bCreaSetup := True;
    FS := TFileStream.Create(dlgSave.FileName,fmCreate or fmShareDenyWrite);
    try
      for a := 0 to ControlCount-1 do
        if Controls[a] is TNikShape then
        begin
          if (Controls[a] as TNikShape).Shape = stSetup then
          begin
            bCreaSetup := False;
// stSetup va reinizializzato senno' non tiene i cambiamenti (eventualmente)
// fatti durante questa sessione di lavoro. nf 21.10.98
            (Controls[a] as TNikShape).GetPrinterSetup;
{            (Controls[a] as TNikShape).Orient    := Printer.Orientation;
            (Controls[a] as TNikShape).PagWidth  := Printer.PageWidth;
            (Controls[a] as TNikShape).PagHeight := Printer.PageHeight; }
          end;
// Correzione necessaria se scrollato!
           if VertScrollbar.Position > 0 then
             (Controls[a] as TNikShape).Top := (Controls[a] as TNikShape).Top +
              VertScrollbar.Position;
           if HorzScrollbar.Position > 0 then
             (Controls[a] as TNikShape).Left := (Controls[a] as TNikShape).Left +
              HorzScrollbar.Position;
          FS.WriteComponent(Controls[a] as TNikShape);
        end;
// Crea il componente per salvare impostazioni di stampa
      if bCreaSetup then
      begin
        try
          aSetup := TNikShape.Create(Self);
          aSetup.Shape := stSetup;
          aSetup.GetPrinterSetup;
//          aSetup.Orient := Printer.Orientation;
          FS.WriteComponent(aSetup);
        finally
          aSetup.Free;
        end;
      end;
    finally
      FS.Free;
    end;
    Caption := 'Miro - '+ExtractFileName(dlgSave.FileName);
{Update MRUList using saved filename}
    MRUUpdate(Self, dlgSave.FileName);
    MRUDisplay;
  end;
end;

procedure TfrmMain.btnPrintClick(Sender: TObject);
begin
  if PrintDialog1.Execute then
    Print;
end;

procedure TfrmMain.mniRuler1Click(Sender: TObject);
begin
//  Righello;
end;

procedure TfrmMain.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TfrmMain.Bringtofront1Click(Sender: TObject);
begin
  SelectedShape.BringToFront;
end;

procedure TfrmMain.Sendtoback1Click(Sender: TObject);
begin
  SelectedShape.SendToBack;
end;

procedure TfrmMain.mniInspectClick(Sender: TObject);
begin
  SelectedShape.InspectObject(SelectedShape);
end;

procedure TfrmMain.mniPrintsetupClick(Sender: TObject);
begin
  PrinterSetupDialog1.Execute;
end;

(*
procedure TfrmMain.pnlToolbarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  SC_DragMove = $F012;   //a magic number
begin
  ReleaseCapture;
  pnlToolbar.perform(WM_SysCommand, SC_DragMove, 0);
end;
*)

procedure TfrmMain.mniDebugClick(Sender: TObject);
begin
  frmDebug.Enter(_iLast, Self, DeleteClick);
end;

procedure TfrmMain.mniToolbarClick(Sender: TObject);
begin
  if mniToolbar.checked then
  begin
    mniToolbar.Checked := False;
    frmTools.Hide
  end
  else
  begin
    mniToolbar.Checked := True;
    frmTools.Show;
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  SelectedShape := nil;
  CountObjects;
  frmTools.Show;
  if GetProgramAssociation('mir') = '' then
    if MsgSiNo('Miro non e'' associato ai file .mir. Lo associo?') then
      AssociaExt('.mir', Application.ExeName);
  if ParamCount>0 then ApriFile(ParamStr(1));
end;

procedure TfrmMain.ResizeFont;
var a : integer;
begin
 for a := 0 to ControlCount-1 do
    if Controls[a] is TNikShape then
      Font.Size := Font.Size * (50 div 100)
end;

procedure TfrmMain.mniScaleClick(Sender: TObject);
var a, scale : integer;
begin
  scale := (Sender as TMenuItem).Tag;
  ScaleBy(scale,100);
  ResizeFont;
{  for a := 0 to ControlCount-1 do
    if Controls[a] is TNikShape then
      ScaleBy(100,150); }
end;

procedure TfrmMain.mniAbout1Click(Sender: TObject);
begin
  frmAbout.ShowModal;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
var Index : integer;
begin
  AppIni := TIniFile.Create('MIRO.INI');       {Create IniFile}
  for Index := 0 to 3 do                 {Loop to write all 4 items to Ini}
    AppIni.WriteString('MRU', IntToStr(Index), MRUList[Index]);    {Save MRUList}
  AppIni.Free;
  if FBackgroundImage <> nil then
    FBackgroundImage.Free;
end;

procedure TfrmMain.OpenMRU(Sender: TObject);
var Index : integer;
begin
  Index := TMenuItem(Sender).Tag;               {Set Index using Sender.Tag}
  if MRUList[Index] <> '' then
    begin
      ApriFile(MRUList[Index]);
      MRUDisplay;      {Update MRU menu items}
    end;
end;

procedure TfrmMain.Print;
var
  a : Integer;
begin
  Printer.BeginDoc;
  for a := 0 to ControlCount-1 do
    if Controls[a] is TNikShape then
      (Controls[a] as TNikShape).Print;
  Printer.EndDoc;
end;

procedure TfrmMain.CreaEMF(bSaveToDisk : boolean);
const
  sFileName = 'miro.wmf';
var
  WmfCanvas: TMetafileCanvas;
  Wmf      : TMetafile;
  a        : integer;
begin
  if ControlCount = 0 then
  begin
    MsgOk('Nothing to print!');
    exit;
  end;

  try
    Wmf := TMetafile.Create;
    Wmf.Enhanced := { True } False ;
    Wmf.Width  := 800;
    Wmf.Height := 600;
    Wmf.MMWidth  := 29600;
    Wmf.MMHeight := 21000;
    Wmf.Inch   := 96;

    // create the virtual canvas
    WmfCanvas := TMetafileCanvas.CreateWithComment(Wmf, 0, 'Miro', 'Miro metafile');

    try
      for a := 0 to ControlCount-1 do
        if Controls[a] is TNikShape then
          (Controls[a] as TNikShape).Paint2Canvas(WmfCanvas);
    finally
      WmfCanvas.Free;
    end;

    if bSaveToDisk then
    begin
// NB nel TMetaFile il contenuto e' trasferito solo dopo la TMetaFileCanvas.free!
      Wmf.SaveToFile (ExtractFilePath(Application.ExeName)+sFileName);
      MsgOk('File saved');
    end
    else
    with frmPreview do
    begin
      _Wmf.Assign(Wmf);
      Show;
      WindowState := wsNormal;
      pbxPreview.Canvas.StretchDraw (pbxPreview.Canvas.ClipRect, Wmf);
    end;
  finally
    Wmf.Free;
  end;
end;

procedure TfrmMain.mniPrint2metafileClick(Sender: TObject);
begin
  CreaEMF(True);
end;

procedure TfrmMain.mniPreviewClick(Sender: TObject);
begin
  CreaEMF(False);
end;

procedure TfrmMain.DrawMargins(const bDraw : boolean);
var h, w : integer;
begin
  with Canvas, Printer do
  begin
    h := PageHeight div 6;
    w := PageWidth div 6;
    if bDraw then
      Pen.Style := psDot
    else
      Pen.Style := psClear;
    MoveTo(w, 0);
    LineTo(w, h);
//    MoveTo(0, h);
//    LineTo(w, h);
  end;
end;

procedure TfrmMain.mniVisiblemarginsClick(Sender: TObject);
begin
  if mniVisibleMargins.Checked then
  begin
    mniVisibleMargins.Checked := False;
    DrawMargins(False);
    Invalidate;
  end
  else
  begin
    mniVisibleMargins.Checked := True;
    DrawMargins(True);
  end;
end;

procedure TfrmMain.FormPaint(Sender: TObject);
begin
  DrawMargins(mniVisibleMargins.Checked);
  if FBackgroundImage<> nil then
    Canvas.StretchDraw(ClientRect,FBackgroundImage);
end;

procedure TfrmMain.mniDuplicateClick(Sender: TObject);
begin
  if SelectedShape=nil then exit;
  Duplica(SelectedShape);
end;

procedure TfrmMain.mniSetbackgroundClick(Sender: TObject);
begin
  with ImageForm do
    if ShowModal = mrOk then
    begin
      FBackgroundImage := Graphics.TBitmap.Create;
      FBackgroundImage.LoadFromFile(FileListBox1.Filename);
    end;
end;

end.
