program Miro;

uses
  Forms,
  fmMain in 'fmMain.pas' {frmMain},
  fmInspector in 'fmInspector.pas' {frmInspector},
  ImageWin in 'Imagewin.pas' {ImageForm},
  ViewWin in 'Viewwin.pas' {ViewForm},
  fmDebug in 'fmDebug.pas' {frmDebug},
  NikShape in 'NikShape.pas',
  MiroRep in 'MiroRep.pas',
  fmTools in 'fmTools.pas' {frmTools},
  fmAbout in 'fmAbout.pas' {frmAbout},
  fmPreview in 'fmPreview.pas' {frmPreview};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Miro';
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TImageForm, ImageForm);
  Application.CreateForm(TViewForm, ViewForm);
  Application.CreateForm(TfrmDebug, frmDebug);
  Application.CreateForm(TfrmTools, frmTools);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmPreview, frmPreview);
  Application.Run;
end.
