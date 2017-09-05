{######################################################################################

                                      M4D Framework

Author: Edgar Borges Pav�o
Date of creation: 31/08/2017
Use licence: Free

######################################################################################}

unit UMigrationsHistory;

interface

uses
  UMigrationsHistoryInterface, UMigrationsHistoryItem, Generics.Collections,
  UMigrationSerializer, UMigrationSerializerInterface, UMigrationsInterface,
  System.Classes, System.SysUtils, UGetterMigrationsInterface;

type
  {$M+}
  {$REGION 'TMigrationsHistory'}
    /// <Description>
    ///  Standard class for handling information about the history of migrations�s executions.
    /// </Description>
    /// <Responsability>
    ///  Handle informations about the history of migrations�s executions.
    /// </Responsability>
    /// <Note>
    ///  Information from undocumented methods can be found directly on the interfaces
    ///  from which they come.
    /// </Note>
  {$ENDREGION}
  TMigrationsHistory = class(TInterfacedObject, IMigrationsHistory)
  private
    FHistoryList: TObjectList<TMigrationsHistoryItem>;
    FPath: string;
    FFile: TStringList;
    FSerializer: IMigrationSerializer;
    FLoaded: Boolean;

    function getHistory(APredicate: TPredicate<TMigrationsHistoryItem>): TList<TMigrationsHistoryItem>; overload;
  public
    constructor Create(APath: string; ASerializer: IMigrationSerializer); reintroduce;
    destructor Destroy; override;

    procedure Clear;
    procedure Load;
    procedure UnLoad;
    procedure Add(AItem: TMigrationsHistoryItem);
    procedure Remove(AMigrationSequence: Integer);
//    procedure Update(AList: TList<TMigrationsHistoryItem>);
    function getHistory: TList<TMigrationsHistoryItem>; overload;
    function getHistory(AStartMigrationSeq: Integer): TList<TMigrationsHistoryItem>; overload;
    function getHistory(AStartMigrationDateTime: TDateTime): TList<TMigrationsHistoryItem>; overload;
    function getHistory(AMigrationVersion: string): TList<TMigrationsHistoryItem>; overload;
    procedure Save;
    function LastMigration: TMigrationsHistoryItem;
  published
    property Path: string read FPath;
    property HistoryList: TList<TMigrationsHistoryItem> read getHistory;
  end;

implementation

{ TMigrationsHistory }

procedure TMigrationsHistory.Add(AItem: TMigrationsHistoryItem);
begin
  if not Assigned(AItem) then
  begin
    raise Exception.Create('The parameter AItem must not be nil.');
  end
  else
  begin
    FHistoryList.Add(AItem);
    FHistoryList.Sort;
  end;
end;

procedure TMigrationsHistory.Clear;
begin
  FHistoryList.Clear;
  FFile.Clear;
  if FileExists(FPath) then
  begin
    if not DeleteFile(FPath) then
    begin
      raise Exception.Create('Could not delete file ' + FPath);
    end;
  end;
end;

constructor TMigrationsHistory.Create(APath: string; ASerializer: IMigrationSerializer);
begin
  if APath = '' then
  begin
    raise Exception.Create('The parameter APath must not be empty.');
  end
  else
  begin
    if not Assigned(ASerializer) then
    begin
      raise Exception.Create('Invalida parametrer ASerializer. The parameter must no be nil.');
    end
    else
    begin
      inherited Create;
      Self.FLoaded := False;

      FPath := APath;
      FHistoryList := TObjectList<TMigrationsHistoryItem>.Create;

      FSerializer := ASerializer;
    end;
  end;
end;

destructor TMigrationsHistory.Destroy;
begin
  Self.UnLoad;

  if Assigned(FHistoryList) then FreeAndNil(FHistoryList);

  inherited;
end;

function TMigrationsHistory.getHistory(AStartMigrationDateTime: TDateTime): TList<TMigrationsHistoryItem>;
begin
  Result := Self.getHistory(function(Item: TMigrationsHistoryItem): boolean
                            begin
                              Result := Item.MigrationDateTime >= AStartMigrationDateTime;
                            end);
end;

function TMigrationsHistory.getHistory(AStartMigrationSeq: Integer): TList<TMigrationsHistoryItem>;
begin
  Result := Self.getHistory(function(Item: TMigrationsHistoryItem): boolean
                            begin
                              Result := Item.MigrationSeq >= AStartMigrationSeq;
                            end);
end;

function TMigrationsHistory.getHistory: TList<TMigrationsHistoryItem>;
begin
  if not Self.FLoaded then Self.Load;
  
  Result := FHistoryList;
end;

function TMigrationsHistory.LastMigration: TMigrationsHistoryItem;
begin
  Result := nil;

  if Assigned(FHistoryList) then
  begin
    if FHistoryList.Count > 0 then
    begin
      FHistoryList.Sort;
      Result := FHistoryList.Last;
    end;
  end;
end;

procedure TMigrationsHistory.Load;
var
  I: Integer;
  Aux: string;
begin
  FFile := TStringList.Create;
  FFile.Clear;
  if FileExists(FPath) then FFile.LoadFromFile(FPAth);

  FHistoryList.Clear;
  for I := 0 to FFile.Count - 1 do
  begin
    Aux := FFile.Strings[I];
    FHistoryList.Add(FSerializer.TextToHistory(Aux));
  end;

  Self.FLoaded := True;
end;

procedure TMigrationsHistory.Remove(AMigrationSequence: Integer);
var
  Item: TMigrationsHistoryItem;
begin
  for Item in FHistoryList do
  begin
    if Item.MigrationSeq = AMigrationSequence then
    begin
      FHistoryList.Remove(Item);
      FHistoryList.Sort;
      Break;
    end;
  end;
end;

procedure TMigrationsHistory.Save;
var
  Item: TMigrationsHistoryItem;
  Continue: Boolean;
begin
  FFile.Clear;

  for Item in FHistoryList do
  begin
    FFile.Add(FSerializer.HistoryToText(Item));
  end;

  Continue := True;

  if FileExists(FPAth) then
  begin
    Continue := DeleteFile(FPath);
    if not Continue then
    begin
      raise Exception.Create('An error occurred while trying to delete the file ' + FPath);
    end
  end;

  if Continue then
  begin
    FFile.SaveToFile(FPath);
  end;
end;

procedure TMigrationsHistory.UnLoad;
begin
  if Assigned(FFile) then FreeAndNil(FFile);
  Self.FLoaded := False;
end;

//procedure TMigrationsHistory.Update(AList: TList<TMigrationsHistoryItem>);
//begin
//  if not Assigned(AList) then
//  begin
//    raise Exception.Create('The parameter AList must not be nil.');
//  end
//  else
//  begin
//    FHistoryList := AList;
//  end;
//end;

function TMigrationsHistory.getHistory(AMigrationVersion: string): TList<TMigrationsHistoryItem>;
begin
  Result := Self.getHistory(function(Item: TMigrationsHistoryItem): boolean
                            begin
                              Result := Item.MigrationVersion = AMigrationVersion;
                            end);
end;

function TMigrationsHistory.getHistory(APredicate: TPredicate<TMigrationsHistoryItem>): TList<TMigrationsHistoryItem>;
var
  Item: TMigrationsHistoryItem;
begin
  Result := nil;

  if not Self.FLoaded then Self.Load;

  for Item in FHistoryList do
  begin
    if APredicate(Item) then
    begin
      if not Assigned(Result) then Result := TList<TMigrationsHistoryItem>.Create;

      Result.Add(Item);
    end;
  end;
end;

end.