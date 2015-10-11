unit fmTools;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TfrmTools = class(TForm)
    pnlToolbar: TPanel;
    spdSquare: TSpeedButton;
    spdSquareR: TSpeedButton;
    spdRect: TSpeedButton;
    spdRectR: TSpeedButton;
    spdCircle: TSpeedButton;
    spdEllipse: TSpeedButton;
    spdOpenFile: TSpeedButton;
    spdSaveFile: TSpeedButton;
    spdNew: TSpeedButton;
    lblCount: TLabel;
    btnPrint: TSpeedButton;
    btnText: TSpeedButton;
    btnBarcode: TSpeedButton;
    btnImage: TSpeedButton;
    spdSelect: TSpeedButton;
    btnLine: TSpeedButton;
    procedure FormShow(Sender: TObject);
    procedure ShapeSelectClick(Sender: TObject);
    procedure spdNewClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure spdOpenFileClick(Sender: TObject);
    procedure spdSaveFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTools: TfrmTools;

implementation

uses fmMain, NikShape;

{$R *.DFM}

procedure TfrmTools.FormShow(Sender: TObject);
begin
  ClientWidth := pnlToolbar.Width;
end;

procedure TfrmTools.ShapeSelectClick(Sender: TObject);
begin
  frmMain.ObjType := TNikShapeType((Sender as TSpeedButton).Tag);
end;


procedure TfrmTools.spdNewClick(Sender: TObject);
begin
  frmMain.DeleteObjects;
end;

procedure TfrmTools.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  frmMain.mniToolbar.checked :=False;
end;

procedure TfrmTools.spdOpenFileClick(Sender: TObject);
begin
  frmMain.OpenFile(Sender);
end;

procedure TfrmTools.spdSaveFileClick(Sender: TObject);
begin
  frmMain.SaveFile(Sender);
end;

procedure TfrmTools.btnPrintClick(Sender: TObject);
begin
  frmMain.btnPrintClick(Sender);
end;

end.
