unit UPropertyClassReader;

interface

uses
  System.Rtti, UPropertyClassReaderInterface;

type
  TPropertyClassReader = class(TInterfacedObject, IPropertyClassReader)
  public
    function PropertyOfMigrationClass(AClass: TClass; AInstance: TObject; APropName: string): TValue;
  end;

implementation

uses
  System.SysUtils;

{ TPropertyClassReader }

function TPropertyClassReader.PropertyOfMigrationClass(AClass: TClass; AInstance: TObject; APropName: string): TValue;
var
  LContext: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
begin
  Result := nil;

  if not Assigned(AClass) then
  begin
    raise Exception.Create('The parameter AClass must not be nil.');
  end
  else
  begin
    if not Assigned(AInstance) then
    begin
      raise Exception.Create('The parameter AInstace must not be nil.');
    end
    else
    begin
      LType := LContext.GetType(AClass.ClassInfo);

      for LProp in LType.GetProperties do
      begin
        if LowerCase(LProp.Name) = LowerCase(APropName) then
        begin
          Result := LPRop.GetValue(AInstance);
          Break;
        end;
      end;
    end;
  end;
end;

end.
