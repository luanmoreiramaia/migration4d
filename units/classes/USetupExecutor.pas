unit USetupExecutor;

interface

uses
  USetupExecutorInterface, UMigrationMethodExecutorInterface;

type
  TMigrationSetupMethodExecutor = class(TInterfacedObject, IMigrationSetupMethodExecutor)
  private
    FExecutor: IMigrationMethodExecutor;
  public
    constructor Create(AExecutor: IMigrationMethodExecutor); reintroduce;

    function Execute(AClass: TClass; AInstance: TObject): boolean;
  end;

implementation

uses
  System.SysUtils, UDefs;

{ TMigrationSetupMethodExecutor }

constructor TMigrationSetupMethodExecutor.Create(AExecutor: IMigrationMethodExecutor);
begin
  inherited Create;

  if not Assigned(AExecutor) then
  begin
    raise Exception.Create('The parameter AExecutor must not be nil.');
  end
  else
  begin
    FExecutor := AExecutor;
  end;
end;

function TMigrationSetupMethodExecutor.Execute(AClass: TClass; AInstance: TObject): boolean;
begin
  Result := FExecutor.Execute(AClass, AInstance, METHOD_SETUP);
end;

end.

