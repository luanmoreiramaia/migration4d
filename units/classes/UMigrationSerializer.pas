{######################################################################################

                                      M4D Framework

Author: Edgar Borges Pav�o
Date of creation: 31/08/2017
Use licence: Free

######################################################################################}

unit UMigrationSerializer;

interface

uses
  UMigrationSerializerInterface, UMigrationsHistoryItem, Data.DBXJSONReflect;

type
  {$REGION 'TMigrationSerializer'}
    /// <Description>
    ///  Standard class to convert between string values and history items.
    /// </Description>
    /// <Responsability>
    ///  Performs converters between string values and history items.
    /// </Responsability>
    /// <Note>
    ///  Information from undocumented methods can be found directly on the interfaces
    ///  from which they come.
    /// </Note>
  {$ENDREGION}
  TMigrationSerializer = class(TInterfacedObject, IMigrationSerializer)
  public
    function HistoryToText(AItem: TMigrationsHistoryItem): string;
    function TextToHistory(AValue: string): TMigrationsHistoryItem;
  end;

implementation

uses
  System.JSON, System.SysUtils;

{ TMigrationSerializer }

function TMigrationSerializer.HistoryToText(AItem: TMigrationsHistoryItem): string;
var
  Marshal: TJSONMarshal;
  Aux: TJSONObject;
begin
  Result := '';

  if Assigned(AItem) then
  begin
    Marshal := TJSONMarshal.Create(TJSONConverter.Create);
    try
      Aux := Marshal.Marshal(AItem) as TJSONObject;
      try
        Result := Aux.ToString;
      finally
        Aux.Free;
      end;
    finally
      Marshal.Free;
    end;
  end;
end;

function TMigrationSerializer.TextToHistory(AValue: string): TMigrationsHistoryItem;
var
  Marshal: TJSONUnMarshal;
  Aux: TJSONObject;
begin
  if AValue = '' then
  begin
    raise Exception.Create('Invalid value to TMigrationSerializer.TextToHistory.');
  end
  else
  begin
    Marshal := TJSONUnMarshal.Create;
    try
      Aux := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(AValue), 0) as TJSONObject;
      try
         Result := Marshal.UnMarshal(Aux) as TMigrationsHistoryItem;
      finally
        Aux.Free;
      end;
    finally
      Marshal.Free;
    end;
  end;
end;

end.
