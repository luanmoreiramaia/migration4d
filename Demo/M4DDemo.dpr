program M4DDemo;

uses
  Vcl.Forms,
  M4D,
  UFrmMain in 'UFrmMain.pas' {Form2},
  MDescription1 in 'Migrations\MDescription1.pas',
  MDescription2 in 'Migrations\MDescription2.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
