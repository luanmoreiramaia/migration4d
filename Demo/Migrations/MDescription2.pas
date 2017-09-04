unit MDescription2;

interface

uses
  {$IF DECLARED(FireMonkeyVersion)}
    FMX.Dialogs,
  {$ELSE}
    Vcl.Dialogs,
  {$ENDIF}
  UMigrations,
  M4D;

type
  TMDescription2 = class(TMigrations)
  public
    procedure Setup;
    procedure Up;
    procedure Down;
  end;

implementation

uses
  System.SysUtils;

{ TMDescription1 }

procedure TMDescription2.Setup;
begin
  Self.Version := '1.01';
  Self.SeqVersion := 2;
  Self.DateTime := StrToDateTime('01/09/2017 07:15:00');
end;

procedure TMDescription2.Down;
begin
  ShowMessage('Executing down sequence version 2!');
end;

procedure TMDescription2.Up;
begin
  ShowMessage('Executing up sequence version 2!');
end;

initialization
  RegisterMigration(TMDescription2);

end.
