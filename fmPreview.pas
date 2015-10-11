unit fmPreview;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TfrmPreview = class(TForm)
    pbxPreview: TPaintBox;
    procedure pbxPreviewPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    _Wmf : TMetaFile;
  end;

var
  frmPreview: TfrmPreview;

implementation

{$R *.DFM}

procedure TfrmPreview.pbxPreviewPaint(Sender: TObject);
begin
  pbxPreview.Canvas.StretchDraw (pbxPreview.Canvas.ClipRect, _Wmf);
end;

procedure TfrmPreview.FormCreate(Sender: TObject);
begin
  _Wmf := TMetaFile.Create;
end;

procedure TfrmPreview.FormDestroy(Sender: TObject);
begin
  _Wmf.Free;
end;

end.
