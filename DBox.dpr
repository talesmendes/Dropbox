program DBox;

uses
  Vcl.Forms,
  Main in 'Main.pas' {fMain},
  Dropbox in 'Dropbox.pas',
  DoFinally in 'DoFinally.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfMain, fMain);
  Application.Run;
end.
