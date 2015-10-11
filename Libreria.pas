unit Libreria;

interface

uses Classes, SysUtils, DB, DBTables, DBCtrls, StdCtrls, Forms, BDE;

Type
  TTypeSearch = (stContiene, stInizia);

{ public }
// Codifica/Decodifica la stringa S con la chiave KEY vedi Techinfo.hlp
// es. sEncoded := Encrypt('PIPPO', 12345);
  function Encrypt(const S: String; Key: Word): String;
  function Decrypt(const S: String; Key: Word): String;
// Ritorna una data a caso a partire da dtStart
  function CasualData(const dtStart : TDateTime) : TDateTime;
  function IsNumeric(const sStr : string) : boolean;
  procedure MultiPopolaCombo(cbx: TCustomComboBox; dts: TdbDataSet; sFields: String);
  procedure PopolaCombo(lucCombo : TCustomComboBox; tbTab : TDbDataset; const sCampo : string);
  procedure PopolaList(lst : TCustomListBox; tbTab : TTable; const sCampo : string);
// Ritorna la directory di un TDatabase
  function GetDBDir(dbDataBase: TDataBase): String;
  procedure Reindex(AOwner:TComponent;const sAlias,sName : string);
  function RebuildIndexes(AOwner: TComponent; strAlias, strTable: string; var strError: string): Boolean;
  function SeqSearch(AQuery: TQuery; AField, AValue: String; const bRestart : boolean): Boolean;

// Ricerca VALUE nel Campo FIELD del DataSet DATASET
// stType è di tipo TTYPESEARCH "stContiene , stInizia"
// bRestart se deve ripartire dall'inizio
// Torna True se la ricerca ha dato esito negativo
  function SearchIn(DataSet: TDataSet; Field, Value:String; stType:TTypeSearch; bRestart:Boolean):Boolean;

  function Locate(AQuery: TQuery; AField, AValue: String): Boolean;
  procedure DateItaliane;
  procedure Beep;
  function MyFileSize(const sFilePath : string) : longint;
  function MsgOK(Msg: string): Boolean;
  function MsgOKE(Msg: string): Boolean;
  function MsgSINO(Msg: string): Boolean;
  function MsgYESNO(Msg: string): Boolean;
  function Fatal(Msg: string): Boolean;
  procedure GetRecordID(ATable: TTable; var RecID: Longint);
  procedure ScalaFont(frmForm : TForm; lNewW, lOldW : longint);
  procedure Scala(frmForm : TForm);
  function InterTime(T1,T2,U1,U2:TDateTime;Var X1,X2:TDateTime):Boolean;
// Rimesse da nik 25/6/98 12.01
  procedure StampaLog(stRighe : TStrings);
  function BuildInfo : string;
// 3.7.98 nf
  procedure ConnectDrive(const sDrive, sRisorsa, sPassword, sUserName : string);
  function GetMyNetUserName: String;
  function fDbiGetSesInfo(SesInfoList: TStringList): SESInfo;
  
implementation

uses
  Controls,Dialogs, WinTypes, Printers;

type
  TFooClass = class(TControl);

const
  ScreenW : longint = 800;
  ScreenH : longint = 600;
  C1 = 52845;
  C2 = 22719;

function GetMyNetUserName: String;
begin
   SetLength(Result, dbiMaxUserNameLen + 1);
   Check(DbiGetNetUserName(PChar(Result)));
   SetLength(Result, StrLen(PChar(Result)));
end;

function fDbiGetSesInfo(SesInfoList: TStringList): SESInfo;
begin
  Check(DbiGetSesInfo(Result));
  if SesInfoList <> nil then
  begin
    with SesInfoList do
    begin
      Clear;
      Add(Format('SESSION ID=%d', [Result.iSession]));
      Add(Format('SESSION NAME=%s', [Result.szName]));
      Add(Format('DATABASES=%d', [Result.iDatabases]));
      Add(Format('CURSORS=%d', [Result.iCursors]));
      Add(Format('LOCK WAIT=%d', [Result.iLockWait]));
      Add(Format('NET DIR=%s', [Result.szNetDir]));

      Add(Format('PRIVATE DIR=%s', [Result.szPrivDir]));
    end;
  end;
end;

procedure ConnectDrive(const sDrive, sRisorsa, sPassword, sUserName : string);
var
  NRW: TNetResource;
begin
  with NRW do
  begin
    dwType := RESOURCETYPE_ANY;
    lpLocalName := PChar(sDrive); // map to this driver letter
//    lpRemoteName := '\\MyServer\MyDirectory';
    lpRemoteName := PChar(sRisorsa);
    // Must be filled in.  If an empty string is used,
    // it will use the lpRemoteName.
    lpProvider := '';
  end;
  WNetAddConnection2(NRW, PChar(sPassword), PChar(sUserName), CONNECT_UPDATE_PROFILE);
end;

// Ritorna giorno data e ora dell'applicazione corrente
function BuildInfo : string;
var hnd : integer; dtData : TDateTime;
begin
  Result := '';
  hnd := FileOpen(Application.ExeName, fmOpenRead or fmShareDenyNone);
  if hnd > 0 then
  begin
    dtData:=FileDateToDateTime(FileGetDate(hnd));
    try
      Result := FormatDateTime('dd/mm/yy hh:mm:ss',dtData);
    except
      Result:='';
    end;
    FileClose(hnd);
  end;
end;

procedure StampaLog(stRighe : TStrings);
var
  MemoText : TextFile;
  i        : integer;
begin
  AssignPrn(MemoText);
  try
    Rewrite(MemoText);
    for i:=0 to stRighe.Count-1 do
      writeln(MemoText, stRighe.Strings[i]);
  finally
    CloseFile(MemoText);
  end;
end;

function InterTime(T1,T2,U1,U2:TDateTime;Var X1,X2:TDateTime):Boolean;
begin
  Result:=False;
  If u2>=u1 Then begin
    If (u1>=t1) And (u1<=t2) Then x1:=u1
    Else If (u2>=t1) And (u2<=t2) Then begin
      x1:=t1;
      x2:=u2;
      Result:=True;
      Exit;
    end
     Else If u2<t1 Then begin
       Result:=False;
       Exit;
     end
      Else If u1<t1 Then begin
        x1:=t1;
        x2:=t2;
        Result:=True;
        Exit;
      end
       Else begin
         Result:=False;
         Exit;
       end;
    If (u2<=t2) Then begin
      x2:=u2;
      Result:=True;
      Exit;
    end
     Else begin
       x2:=t2;
       Result:=true;
       Exit;
     end;
  end;
end;

function SearchIn(DataSet: TDataSet; Field, Value:String; stType:TTypeSearch; bRestart:Boolean):Boolean;
var bTrovato : boolean;
app:String;
begin
  bTrovato := False;
  With DataSet Do Begin
    If Not(Active) Then Open;
    If bRestart  Then First
                 Else Next;
    Case stType Of
      stContiene: begin
        While (Not Eof) and (not bTrovato) do
        begin
          //app:=FieldByName('Bolla').AsString;
          //app:=FieldByName('Data').AsString;
          bTrovato := Pos(Value,UpperCase(FieldByName(Field).AsString))<>0;
          if bTrovato then break;
          Next;
        end;
      end;
      stInizia: Begin
        While (Not Eof) and (not bTrovato) do
        begin
          //app:=FieldByName('Bolla').AsString;
          //app:=FieldByName('Data').AsString;
          bTrovato := Pos(Value,UpperCase(FieldByName(Field).AsString))=1;
          if bTrovato then break;
          Next;
        end;
      end;
    end;
    Result:=bTrovato;
  end;
end;

function CasualData(const dtStart : TDateTime) : TDateTime;
var iCasMon,iCasDay : integer;
  d,m,y    : word;
begin
  //Randomize;
  iCasDay := Random(27)+1;
  iCasMon := Random(12)+1;
  DecodeDate(dtStart,y,m,d);
  Result := EncodeDate(y,iCasMon,iCasDay);
end;

function Encrypt(const S: String; Key: Word): String;
var
  I: byte;
begin
//  Result[0] := S[0];
  SetLength(Result, Length(S));
  for I := 1 to Length(S) do begin
    Result[I] := char(byte(S[I]) xor (Key shr 8));
    Key := (byte(Result[I]) + Key) * C1 + C2;
  end;
end;

function Decrypt(const S: String; Key: Word): String;
var
  I: byte;
begin
//  Result[0] := S[0];
  SetLength(Result,  Length(S));
  for I := 1 to Length(S) do begin
    Result[I] := char(byte(S[I]) xor (Key shr 8));
    Key := (byte(S[I]) + Key) * C1 + C2;
  end;
end;

function IsNumeric(const sStr : string) : boolean;
var iTmp : integer;
begin
  Result:=True;
  try
    iTmp:=StrToInt(Trim(sStr));
  except
    Result:=False;
  end;
end;

procedure ScalaFont(frmForm : TForm; lNewW, lOldW : longint);
var i : integer;
begin
  with frmForm do
    for i:= ControlCount-1 downto 0 do
      TFooClass(Controls[i]).Font.Size := (lNewW div lOldW) * TFooClass(Controls[i]).Font.Size;
end;

procedure Scala(frmForm : TForm);
var OldW, OldH : longint;
begin
  with frmForm do begin
    Scaled := True;
    OldW := Width;
    OldH := Height;
    if Screen.Width <> ScreenW then
    begin
      Height := longint(Height) * longint(Screen.Height) div ScreenH;
      Width  := longint(Width)  * longint(Screen.Width)  div ScreenW;
      ScaleBy(Screen.Width, ScreenW);
      ScalaFont(frmForm, Width, OldW);
    end;
  end;
end;

function MyFileSize(const sFilePath : string) : longint;
var f : file of byte;
begin
  Result := 0;
  if sFilePath = '' then exit;
  AssignFile(f, sFilePath);
  try
    Reset(f);
    Result := FileSize(f);
    CloseFile(f);
  except
  end;

end;

procedure MultiPopolaCombo(cbx: TCustomComboBox;
  dts: TdbDataSet; sFields: String);

Const
  Sep = ';';
Var
  LOF : TStringList;
  Str : String;
  i, NField : Integer;
begin
  //Viene salvata in una Stringlist la lista dei Campi
  Lof := TStringList.Create;
  If (Trim(sFields)='') Or (sFields[1]=Sep) Or (sFields[Length(sFields)]=Sep)Then begin
    MsgOk('Non sono stati indicati i campi da utilizzare!');
    Exit;
  end;
  i:=1;
  Str:='';
  While (i<=Length(sFields)) Do begin
    If (sFields[i] <> Sep) And (i<=Length(sFields)) Then Str:=Str+sFields[i]
    Else begin
      LOF.Add(Str);
      Str:='';
    end;
    Inc(i);
  end;
  LOF.Add(Str);
  NField:=LOF.Count;
  //Viene Aperto in DataSet
  with dts do begin
    DisableControls;
    try
      Open;
    Except
      MsgOk('Problemi durante l''apertura del DataSet!');
      Lof.Free;
      Exit;
    end;
    Try
      First;
      while Not(EOF) do begin
        Str:='';
        For i:=0 to NField-1 Do begin
          If Str<>'' Then Str:=Str+' - ';
          Str:=Str+FieldByName(Lof.Strings[i]).AsString;
        end;
        cbx.Items.Add(Trim(str));
        next;
      end;
    Except
      MsgOk('Problemi durante la composizione del ComboBox!');
      Lof.Free;
      Exit;
    end;
    EnableControls;
    Screen.Cursor := crDefault;
    Application.ProcessMessages;
  end;
end;


procedure PopolaCombo(lucCombo : TCustomComboBox; tbTab : TDbDataset; const sCampo : string);
begin
// Resetta gli items del combobox senno' a ogni 'show' aggiunge ai precedente
  lucCombo.Items.Clear;
  with tbTab do begin
    DisableControls;
    try
      open;
      first;
      while not EOF do begin
        lucCombo.Items.Add(FieldByName(sCampo).AsString);
        next;
      end;
    finally
      EnableControls;
    end;
    Screen.Cursor := crDefault;
    Application.ProcessMessages;
  end;
end;

procedure PopolaList(lst : TCustomListBox; tbTab : TTable; const sCampo : string);
begin
  lst.Items.Clear;
  with tbTab do begin
    DisableControls;
    open;
    first;
    while not EOF do begin
      lst.Items.Add(FieldByName(sCampo).AsString);
      next;
    end;
    EnableControls;
  end;
end;


function GetDBDir(dbDataBase: TDataBase): String;
var
  hDB: hDbiDb;
  Dir: String;
begin
  hDB:=dbDataBase.Handle;
  SetLength(Dir, dbiMaxPathLen + 1);
  Check(DbiGetDirectory(hDB, False, PChar(Dir)));
  SetLength(Dir, StrLen(PChar(Dir)));
  Result:= Dir;
end;

procedure Reindex(AOwner:TComponent;const sAlias,sName : string);
var sError : string;
begin
  if not MsgSiNo('Conferma il ripristino indici per la tabella '+sName+' ?') then
    exit;
  if not RebuildIndexes(AOwner, sAlias, sName, sError) then
    MsgOk(sError)
  else
    MsgOk('Ripristino completato');
end;


function RebuildIndexes(AOwner: TComponent; strAlias, strTable: string;
  var strError: string): Boolean;
var
   bdeResult: DBIResult;
   tblIndex: TTable;
begin
  tblIndex := TTable.Create(AOwner);
  Result := False;
  if tblIndex.Active then
    tblIndex.Active := False;

  tblIndex.DatabaseName := strAlias;
  tblIndex.TableName := strTable;
  tblIndex.Exclusive := True;

  Screen.Cursor := crHourglass;
  try
    tblIndex.Open;
  finally
    Screen.Cursor := crDefault;
  end;

  if not tblIndex.Active then
    strError := 'Impossibile aprire in modo esclusivo ' +
                'tabella gia'' in uso da un altro programma o utente.'
  else begin
    Screen.Cursor := crHourglass;
    try
      bdeResult := DbiRegenIndexes(tblIndex.Handle);
      case bdeResult of
        DBIERR_NONE:               Result := True;
        DBIERR_INVALIDHNDL:        strError := 'Possibile errore nome tabella.';
        DBIERR_NEEDEXCLACCESS:     strError := 'Tabella aperta in modo condiviso.';
        DBIERR_NOTSUPPORTED:       strError := 'Indici non supportati.';
      else
        strError := 'Unexpected Error Returned by BDE.';
      end;
    finally
      Screen.Cursor := crDefault;
    end;
  end;
  tblIndex.Free;
end;

procedure Beep;
begin
  MessageBeep(MB_ICONEXCLAMATION);
end;

function Fatal(Msg: string): Boolean;
var Button : integer;
  str : array [0..155] of Char;
begin
  MessageBeep(MB_ICONEXCLAMATION);
  StrPCopy(str, Msg);
  Button := Application.MessageBox(str, 'ERRORE FATALE!', mb_IconInformation + mb_OK +
      mb_DefButton1);
  Result := Button = IDOK;
end;


function MsgOK(Msg: string): Boolean;
var Button : integer;
  str : array [0..155] of Char;
begin
  MessageBeep(MB_ICONEXCLAMATION);
  StrPCopy(str, Msg);
  Button := Application.MessageBox(str, 'Attenzione!', mb_IconInformation + mb_OK +
      mb_DefButton1);
  Result := Button = IDOK;
end;

// MsgOk versione inglese...
function MsgOKE(Msg: string): Boolean;
var Button : integer;
  str : array [0..155] of Char;
begin
  MessageBeep(MB_ICONEXCLAMATION);
  StrPCopy(str, Msg);
  Button := Application.MessageBox(str, 'Warning!', mb_IconInformation + mb_OK +
      mb_DefButton1);
  Result := Button = IDOK;
end;

function MsgSINO(Msg: string): Boolean;
var Button : integer;
  str : array [0..155] of Char; rc : word;
begin
//  MessageBeep(MB_ICONEXCLAMATION);
  StrPCopy(str, Msg);          
  rc := MessageDlg(str, mtConfirmation, [mbYes, mbNo], 0);
  Result := rc = mrYes;
end;

// MsgSiNo versione inglese
function MsgYESNO(Msg: string): Boolean;
var Button : integer;
  str : array [0..155] of Char;
begin
//  MessageBeep(MB_ICONEXCLAMATION);
  StrPCopy(str, Msg);
  Button := Application.MessageBox(str, 'Warning!', mb_IconQuestion + mb_OKCancel +
      mb_DefButton1);
  Result := Button = IDOK;
end;

function Locate(AQuery: TQuery; AField, AValue: String): Boolean;
  var
    Hi, Lo: Integer;
  begin
    with AQuery do begin
      First;
      {Set high end of range of rows}
      Hi := RecordCount;
      {Set low end of range of rows}
      Lo := 0;
      {Move to point half way between high and low ends of range}
      MoveBy(RecordCount div 2);
      while (Hi - Lo) > 1 do begin
        {Search field greater than search value, value in first half}
        if (FieldByName(AField).AsString > AValue) then begin
          {Lower high end of range by half of total range}
          Hi := Hi - ((Hi - Lo) div 2);
          MoveBy(((Hi - Lo) div 2) * -1);
        end
        {Search field less than search value, value in far half}
        else begin
          {Raise low end of range by half of total range}
           Lo := Lo + ((Hi - Lo) div 2);
          MoveBy((Hi - Lo) div 2);
        end;
      end;
      {Fudge for odd numbered rows}
      if (FieldByName(AField).AsString > AValue)
      then
        Prior;
      Result := (FieldByName(AField).AsString = AValue);
    end;
  end;

(**********************************************
  This function takes three parameters:

  1. AQuery: type TQuery; the TQuery component in which the search is to
             be executed.
  2. AField: type String; the name of the field against which the search
             value will be compared.
  3. AValue: type String; the value being searched for. If the field is of
             a data type other than String, this search value should be
             changed to the same data type.
**************************************************)
function SeqSearch(AQuery: TQuery; AField, AValue: String; const bRestart : boolean): Boolean;
begin
    with AQuery do begin
      if bRestart then
        First;
      while (not Eof) and (not (FieldByName(AField).AsString = AValue)) do
        Next;
      SeqSearch := not Eof;
    end;
end;

procedure DateItaliane;
begin
  ShortDayNames[1] := 'Dom';
  ShortDayNames[2] := 'Lun';
  ShortDayNames[3] := 'Mar';
  ShortDayNames[4] := 'Mer';
  ShortDayNames[5] := 'Gio';
  ShortDayNames[6] := 'Ven';
  ShortDayNames[7] := 'Sab';
  LongDayNames[1] := 'Domenica';
  LongDayNames[2] := 'Lunedì';
  LongDayNames[3] := 'Martedì';
  LongDayNames[4] := 'Mercoledì';
  LongDayNames[5] := 'Giovedì';
  LongDayNames[6] := 'Venerdì';
  LongDayNames[7] := 'Sabato';
  LongMonthNames[1]  := 'Gennaio';
  LongMonthNames[2]  := 'Febbraio';
  LongMonthNames[3]  := 'Marzo';
  LongMonthNames[4]  := 'Aprile';
  LongMonthNames[5]  := 'Maggio';
  LongMonthNames[6]  := 'Giugno';
  LongMonthNames[7]  := 'Luglio';
  LongMonthNames[8]  := 'Agosto';
  LongMonthNames[9]  := 'Settembre';
  LongMonthNames[10] := 'Ottobre';
  LongMonthNames[11] := 'Novembre';
  LongMonthNames[12] := 'Dicembre';
  ShortMonthNames[1]  := 'Gen';
  ShortMonthNames[2]  := 'Feb';
  ShortMonthNames[3]  := 'Mar';
  ShortMonthNames[4]  := 'Apr';
  ShortMonthNames[5]  := 'Mag';
  ShortMonthNames[6]  := 'Giu';
  ShortMonthNames[7]  := 'Lug';
  ShortMonthNames[8]  := 'Ago';
  ShortMonthNames[9]  := 'Set';
  ShortMonthNames[10] := 'Ott';
  ShortMonthNames[11] := 'Nov';
  ShortMonthNames[12] := 'Dic';
  DateSeparator := '/';
  ShortDateFormat := 'dd/mm/yy';

end;

procedure GetRecordID(ATable: TTable; var RecID: Longint);
var
  CP: CURProps;
  RP: RECProps;
begin
  with ATable do begin
    { Make sure it is a Paradox table! }
    UpdateCursorPos;                // sync BDE with Delphi
    { Find out if table support Seq nums or Physical Rec nums }
    Check(dbiGetCursorProps(Handle, CP));
    case CP.iSeqNums of
      0 : begin           // dBASE tables support Phy Rec Nums
        Check(DbiGetRecord(Handle, dbiNOLOCK, Nil, @RP));

        RecID := RP.iPhyRecNum;
      end;
      1 : Check(DbiGetSeqNo(Handle, RecID)); // Paradox tables support Seq Nums
     else
      { raise exception if it's not a Paradox or dBASE table }
      raise EDatabaseError.Create('Not a Paradox or dBASE table');
    end;
    CursorPosChanged;               // sync Delphi with BDE
  end;
end;

end.
