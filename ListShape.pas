unit ListShape;

interface

uses Classes, Sysutils, Dialogs, NikShape;

type

//  ContainedType = Integer;
  ContainedType = TNikShape;

  TContained = class
  protected
    ContainedValue: ContainedType;
  public
    constructor Create(CopyIn: ContainedType);
    procedure ChangeItem(CopyIn: ContainedType);
    function GetValue: ContainedType;
  end;

  TListShape = class
  protected
    TheList : TList;
  public
    constructor Create;
    destructor  Free;
    procedure  SetElement(value: ContainedType; index: integer);
    function   GetElement(index: integer): ContainedType;
    procedure  AddToList(value: ContainedType);
    procedure  KillItem(index: integer);
    function   GetNumItems: integer;
  end;

implementation

// TContained Class Definition

constructor TContained.Create(CopyIn: ContainedType);
begin
  ContainedValue := CopyIn;
end;

procedure TContained.ChangeItem(CopyIn: ContainedType);
begin
  ContainedValue := CopyIn;
end;

function TContained.GetValue: ContainedType;
begin
  result := ContainedValue;
end;

// TListShape Class Definition

constructor TListShape.Create;
begin
  TheList := TList.Create;
end;

destructor TListShape.Free;
var
  LoopCount : integer;
begin
  for LoopCount := 1 to GetNumItems do
    KillItem(0); {successively removes first item to empty list}
  TheList.Free;
end;

procedure TListShape.AddToList(value: ContainedType);
var
  aptr : TContained;
begin
  aptr := TContained.Create(value);
  try
    TheList.Add(aptr);
  except
    on Exception do MessageDlg('Attempt To Add to a Non-Existent List',mtwarning,[mbok],0);
  end;
end;

procedure TListShape.SetElement(value: ContainedType; index: integer);
var
  APtr : TContained;
begin
  APtr := TContained(TheList.Items[index]);
  APtr.ChangeItem(value);
end;

function TListShape.GetElement(index: integer): ContainedType;
var
  APtr : TContained;
begin
  APtr := TContained(TheList.Items[index]);
  Result := APtr.GetValue;
end;

function TListShape.GetNumItems:integer;
begin
  Result := TheList.Count;
end;

procedure TListShape.KillItem(index: Integer);
var
  APtr : TContained;
begin
  try
    APtr := TContained(TheList.Items[index]);
    APtr.free;
    TheList.delete(index);
    TheList.pack;
  except
    On EListError do Messagedlg('Cannot remove item from empty list',mtwarning,[mbok],0);
  end;
end;

end.
