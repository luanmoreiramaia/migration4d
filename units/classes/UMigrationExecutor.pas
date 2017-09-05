{######################################################################################

                                      M4D Framework

Author: Edgar Borges Pav�o
Date of creation: 31/08/2017
Use licence: Free

######################################################################################}

unit UMigrationExecutor;

interface

uses
  UDefs, UMigrationsInterface, UMigrationExecutorInterface, UMigrationsHistoryInterface, UMigrationsHistory,
  UMigrationsHistoryItem, Generics.Collections, System.Rtti,
  UMigrationUpMethodExecutorInterface, UMigrationDownMethodExecutorInterface,
  USetupExecutorInterface, UPropertyClassReaderInterface, UPropertyClassReader;

type
  {$M+}
  {$REGION 'TMigrationExecutor'}
    /// <Description>
    ///  Standard class to execute migrations.
    /// </Description>
    /// <Responsability>
    ///  Performs executions and rollbacks of the migrations.
    /// </Responsability>
    /// <Note>
    ///  Information from undocumented methods can be found directly on the interfaces
    ///  from which they come.
    /// </Note>
  {$ENDREGION}
  TMigrationExecutor = class(TInterfacedObject, IMigrationExecutor)
  private
    FMigrationHistory: IMigrationsHistory;

    FMethodSetupExecutor: IMigrationSetupMethodExecutor;
    FMethodUpExecutor: IMigrationUpMethodExecutor;
    FMethodDownExecutor: IMigrationDownMethodExecutor;

    function getMigrationsHistory: IMigrationsHistory;
  public
    constructor Create(AMigrationHistory: IMigrationsHistory;
                       AMethodUpExecutor: IMigrationUpMethodExecutor;
                       AMethodDownExecutor: IMigrationDownMethodExecutor;
                       AMethodSetupExecutor: IMigrationSetupMethodExecutor); reintroduce;
//    procedure ExecuteSetup(AClass: TClass; AInstance: TObject; AMethodSetupExecutor: IMigrationSetupMethodExecutor);
    procedure Execute(AMigrationsList: TList<TClass>;
                      AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                      AReader: IPropertyClassReader;
                      AMethodUpExecutor: IMigrationUpMethodExecutor;
                      AMigrationHistory: IMigrationsHistory);
    procedure ExecutePending(AMigrationsList: TList<TClass>;
                             ALastMigration: TMigrationsHistoryItem;
                             AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                             AReader: IPropertyClassReader;
                             AMethodUpExecutor: IMigrationUpMethodExecutor;
                             AMigrationHistory: IMigrationsHistory);
    procedure ExecuteUntil(AMigrationsList: TList<TClass>;
                           AMigrationSequence: Integer;
                           AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                           AReader: IPropertyClassReader;
                           AMethodUpExecutor: IMigrationUpMethodExecutor;
                           AMigrationHistory: IMigrationsHistory);
    procedure Rollback(AMigrationsList: TList<TClass>;
                       AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                       AReader: IPropertyClassReader;
                       AMethodDownExecutor: IMigrationDownMethodExecutor;
                       AMigrationHistory: IMigrationsHistory);
    procedure RollbackUntil(AMigrationsList: TList<TClass>;
                            AMigrationSequence: Integer;
                            AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                            AReader: IPropertyClassReader;
                            AMethodDownExecutor: IMigrationDownMethodExecutor;
                            AMigrationHistory: IMigrationsHistory);
  published
    property MigrationHistory: IMigrationsHistory read getMigrationsHistory;
  end;

implementation

uses
  System.SysUtils;

{ TMigrationExecutor }

constructor TMigrationExecutor.Create(AMigrationHistory: IMigrationsHistory; AMethodUpExecutor: IMigrationUpMethodExecutor; AMethodDownExecutor: IMigrationDownMethodExecutor; AMethodSetupExecutor: IMigrationSetupMethodExecutor);
begin
  if not Assigned(AMigrationHistory) then
  begin
    raise Exception.Create('The parameter AMigrationHistory must not be nil.');
  end
  else
  begin
    if not Assigned(AMethodUpExecutor) then
    begin
      raise Exception.Create('The parameter AMethodUpExecutor must not be nil.');
    end
    else
    begin
      if not Assigned(AMethodDownExecutor) then
      begin
        raise Exception.Create('The parameter AMethodDownExecutor must not be nil.');
      end
      else
      begin
        if not Assigned(AMethodSetupExecutor) then
        begin

        end
        else
        begin
          inherited Create;

          FMigrationHistory := AMigrationHistory;
          FMigrationHistory.Load;

          FMethodUpExecutor := AMethodUpExecutor;
          FMethodDownExecutor := AMethodDownExecutor;
          FMethodSetupExecutor := AMethodSetupExecutor;
        end;
      end;
    end;
  end;
end;

procedure TMigrationExecutor.Execute(AMigrationsList: TList<TClass>;
                                     AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                     AReader: IPropertyClassReader;
                                     AMethodUpExecutor: IMigrationUpMethodExecutor;
                                     AMigrationHistory: IMigrationsHistory);
var
  VersionProp: string;
  SequenceProp: Integer;
  DatetimeProp: TDateTime;
  LClass: TClass;
  Item: TMigrationsHistoryItem;
  Aux: TObject;
  HadMigration: Boolean;

//  Reader: IPropertyClassReader;
begin
  HadMigration := False;

  if Assigned(AMigrationsList) and
     Assigned(FMethodUpExecutor) and
     Assigned(AReader) and
     Assigned(AMethodUpExecutor) and
     Assigned(AMigrationHistory)
  then
  begin
    AMigrationsList.Sort;

    for LClass in AMigrationsList do
    begin
      Aux := LClass.Create;
      try
        //First, call for setup to load informations
//        Self.ExecuteSetup(LClass, Aux);
        AMethodSetupExecutor.Execute(LClass, Aux);

        //then, get the info from the props
//        Reader := TPropertyClassReader.Create;

//        VersionProp := Reader.PropertyOfMigrationClass(LClass, Aux, PROP_VERSION).ToString;
//        SequenceProp := Reader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;
//        DatetimeProp := Reader.PropertyOfMigrationClass(LClass, Aux, PROP_DATETIME).AsType<TDateTime>;

        VersionProp := AReader.PropertyOfMigrationClass(LClass, Aux, PROP_VERSION).ToString;
        SequenceProp := AReader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;
        DatetimeProp := AReader.PropertyOfMigrationClass(LClass, Aux, PROP_DATETIME).AsType<TDateTime>;

        Item := TMigrationsHistoryItem.Create;
        try
          Item.MigrationVersion := VersionProp;
          Item.MigrationSeq := SequenceProp;
          Item.MigrationDateTime := DatetimeProp;

          Item.StartOfExecution := Now;

          //Execute the migration
//          FMethodUpExecutor.Execute(LClass, Aux);
          AMethodUpExecutor.Execute(LClass, Aux);

          Item.EndOfExecution := Now;
          Item.DurationOfExecution := Item.EndOfExecution - Item.StartOfExecution;
        finally
//          FMigrationHistory.Add(Item);
          AMigrationHistory.Add(Item);
          HadMigration := True;
        end;
      finally
        FreeAndNil(Aux);
      end;
    end;
  end;

  if HadMigration then
  begin
//    FMigrationHistory.Save;
    AMigrationHistory.Save;
  end;
end;

procedure TMigrationExecutor.ExecuteUntil(AMigrationsList: TList<TClass>;
                                          AMigrationSequence: Integer;
                                          AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                          AReader: IPropertyClassReader;
                                          AMethodUpExecutor: IMigrationUpMethodExecutor;
                                          AMigrationHistory: IMigrationsHistory);
var
  LList: TList<TClass>;
  SequenceProp: Integer;
  LClass: TClass;
  Aux: TObject;
//  Reader: IPropertyClassReader;
begin
  if not Assigned(AMigrationsList) then
  begin
    raise Exception.Create('The parameter AMigrationsList must not be nil.');
  end
  else
  begin
    LList := nil;

    for LClass in AMigrationsList do
    begin
      Aux := LClass.Create;
      try
//        Self.ExecuteSetup(LClass, Aux);
        AMethodSetupExecutor.Execute(LClass, Aux);

//        Reader := TPropertyClassReader.Create;
//        SequenceProp := Reader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;
        SequenceProp := AReader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;

        if SequenceProp <= AMigrationSequence then
        begin
          if not Assigned(LList) then LList := TList<TClass>.Create;
          LList.Add(LClass);
        end;
      finally
        FreeAndNil(Aux);
      end;
    end;

    if Assigned(LList) then
    begin
      if LList.Count > 0 then
      begin
        Self.Execute(LList, AMethodSetupExecutor, AReader, AMethodUpExecutor, AMigrationHistory);
        if Assigned(LList) then FreeAndNil(LList);
      end;
    end;
  end;
end;

function TMigrationExecutor.getMigrationsHistory: IMigrationsHistory;
begin
  Result := Self.FMigrationHistory;
end;

procedure TMigrationExecutor.ExecutePending(AMigrationsList: TList<TClass>;
                                            ALastMigration: TMigrationsHistoryItem;
                                            AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                            AReader: IPropertyClassReader;
                                            AMethodUpExecutor: IMigrationUpMethodExecutor;
                                            AMigrationHistory: IMigrationsHistory);
var
//  LastMigrationHistory: TMigrationsHistoryItem;
  LList: TList<TClass>;
  SequenceProp: Integer;
  LClass: TClass;
  Aux: TObject;
//  Reader: IPropertyClassReader;
begin
  if not Assigned(AMigrationsList) then
  begin
    raise Exception.Create('The parameter AMigrationsList must not be nil.');
  end
  else
  begin
    LList := nil;
//    LastMigrationHistory := FMigrationHistory.LastMigration;

//    if not Assigned(LastMigrationHistory) then
    if not Assigned(ALastMigration) then
    begin
      Self.Execute(AMigrationsList, AMethodSetupExecutor, AReader, AMethodUpExecutor, AMigrationHistory);
    end
    else
    begin
      for LClass in AMigrationsList do
      begin
        Aux := LClass.Create;
        try
//          Self.ExecuteSetup(LClass, Aux);
          AMethodSetupExecutor.Execute(LClass, Aux);

//          Reader := TPropertyClassReader.Create;
//          SequenceProp := Reader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;
          SequenceProp := AReader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;

//          if SequenceProp > LastMigrationHistory.MigrationSeq then
          if SequenceProp > ALastMigration.MigrationSeq then
          begin
            if not Assigned(LList) then LList := TList<TClass>.Create;
            LList.Add(LClass);
          end;
        finally
          FreeAndNil(Aux);
        end;
      end;

      if Assigned(LList) then
      begin
        if LList.Count > 0 then
        begin
          Self.Execute(LList, AMethodSetupExecutor, AReader, AMethodUpExecutor, AMigrationHistory);
          if Assigned(LList) then FreeAndNil(LList);
        end;
      end;
    end;
  end;
end;

//procedure TMigrationExecutor.ExecuteSetup(AClass: TClass; AInstance: TObject; AMethodSetupExecutor: IMigrationSetupMethodExecutor);
//begin
//  if not Assigned(AClass) then
//  begin
//    raise Exception.Create('The parameter AClass must not be nil.');
//  end
//  else
//  begin
//    if not Assigned(AInstance) then
//    begin
//      raise Exception.Create('The parameter AInstance must not be nil.');
//    end
//    else
//    begin
//      if Assigned(FMethodSetupExecutor) then
//      begin
////        FMethodSetupExecutor.Execute(AClass, AInstance);
//        AMethodSetupExecutor.Execute(AClass, AInstance);
//      end;
//    end;
//  end;
//end;

procedure TMigrationExecutor.Rollback(AMigrationsList: TList<TClass>;
                                      AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                      AReader: IPropertyClassReader;
                                      AMethodDownExecutor: IMigrationDownMethodExecutor;
                                      AMigrationHistory: IMigrationsHistory);
var
  I: Integer;
  SequenceProp: Integer;
  LClass: TClass;
  Aux: TObject;
  HadMigration: Boolean;
//  Reader: IPropertyClassReader;
begin
  HadMigration := False;

  if Assigned(AMigrationsList) and Assigned(AMethodDownExecutor)  then
  begin
    AMigrationsList.Sort;

    for I := AMigrationsList.Count - 1 downto 0 do
    begin
      LClass := AMigrationsList[I];

      Aux := LClass.Create;
      try
//        Self.ExecuteSetup(LClass, Aux);
        AMethodSetupExecutor.Execute(LClass, Aux);

//        Reader := TPropertyClassReader.Create;
//        SequenceProp := Reader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;
        SequenceProp := AReader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;

        HadMigration := AMethodDownExecutor.Execute(LClass, Aux);

        if HadMigration and Assigned(AMigrationHistory) then
        begin
          AMigrationHistory.Remove(SequenceProp);
        end;
      finally
        FreeAndNil(Aux);
      end;
    end;
  end;

  if HadMigration then
  begin
    AMigrationHistory.Save;
  end;
end;

procedure TMigrationExecutor.RollbackUntil(AMigrationsList: TList<TClass>;
                                           AMigrationSequence: Integer;
                                           AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                           AReader: IPropertyClassReader;
                                           AMethodDownExecutor: IMigrationDownMethodExecutor;
                                           AMigrationHistory: IMigrationsHistory);
var
  LList: TList<TClass>;
  I: Integer;
  SequenceProp: Integer;
  LClass: TClass;
  Aux: TObject;
//  Reader: IPropertyClassReader;
begin
  if not Assigned(AMigrationsList) then
  begin
    raise Exception.Create('The parameter AMigrationsList must not be nil.');
  end
  else
  begin
    LList := nil;

    for I := AMigrationsList.Count - 1 downto 0 do
    begin
      LClass := AMigrationsList[I];

      Aux := LClass.Create;
      try
//        Self.ExecuteSetup(LClass, Aux);
        AMethodSetupExecutor.Execute(LClass, Aux);

//        Reader := TPropertyClassReader.Create;
//        SequenceProp := Reader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;
        SequenceProp := AReader.PropertyOfMigrationClass(LClass, Aux, PROP_SEQUENCE).AsInteger;

        if SequenceProp >= AMigrationSequence then
        begin
          if not Assigned(LList) then LList := TList<TClass>.Create;
          LList.Add(LClass);
        end;
      finally
        FreeAndNil(Aux);
      end;
    end;

    if Assigned(LList) then
    begin
      if LList.Count > 0 then
      begin
        Self.Rollback(LList, AMethodSetupExecutor, AReader, AMethodDownExecutor, AMigrationHistory);
        if Assigned(LList) then FreeAndNil(LList);
      end;
    end;
  end;
end;

end.