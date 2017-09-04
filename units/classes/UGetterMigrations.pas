unit UGetterMigrations;

interface

uses
  UGetterMigrationsInterface, UMigrationsInterface, Generics.Collections,
  System.SysUtils;

type
  {$REGION 'TGetterMigrations'}
    /// <Description>
    ///  Standard class to get a list of registeredīs migration.
    /// </Description>
    /// <Responsability>
    ///  Get a subset os items from a inputted list, based on the start parameter.
    /// </Responsability>
    /// <Note>
    ///  Information from undocumented methods can be found directly on the interfaces
    ///  from which they come.
    /// </Note>
  {$ENDREGION}
  TGetterMigrations = class(TInterfacedObject, IGetterMigrations)
  private
    function getMigrations(AMigrationsList: TList<IMigration>; APredicate: TPredicate<IMigration>): TList<IMigration>; overload;
  public
    function getMigrations(AMigrationsList: TList<IMigration>; AStartMigrationSeq: Integer): TList<IMigration>; overload;
    function getMigrations(AMigrationsList: TList<IMigration>; AStartMigrationDateTime: TDateTime): TList<IMigration>; overload;
  end;

implementation

{ TGetterMigrations }

function TGetterMigrations.getMigrations(AMigrationsList: TList<IMigration>; AStartMigrationSeq: Integer): TList<IMigration>;
begin
  Result := Self.getMigrations(AMigrationsList, function(AMigration: IMigration): Boolean
                                                begin
                                                  Result := AMigration.SeqVersion >= AStartMigrationSeq;
                                                end);
end;

function TGetterMigrations.getMigrations(AMigrationsList: TList<IMigration>; AStartMigrationDateTime: TDateTime): TList<IMigration>;
begin
  Result := Self.getMigrations(AMigrationsList, function(AMigration: IMigration): Boolean
                                                begin
                                                  Result := AMigration.DateTime >= AStartMigrationDateTime;
                                                end);
end;

function TGetterMigrations.getMigrations(AMigrationsList: TList<IMigration>; APredicate: TPredicate<IMigration>): TList<IMigration>;
var
  I: Integer;
begin
  Result := nil;

  if Assigned(AMigrationsList) then
  begin
    for I := 0 to AMigrationsList.Count - 1 do
    begin
      if APredicate(AMigrationsList[I]) then
      begin

//      if AMigrationsList[I].SeqVersion >= AStartMigrationSeq then
//      begin
        if not Assigned(Result) then Result := TList<IMigration>.Create;

        Result.Add(AMigrationsList[I]);
      end;
    end;
  end;
end;

end.
