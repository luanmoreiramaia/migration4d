{######################################################################################

                                      M4D Framework

Author: Edgar Borges Pav�o
Date of creation: 29/08/2017
Use licence: Free

######################################################################################}

unit UMigrationsManager;

interface

uses

  {$IF DECLARED(FireMonkeyVersion)}
    FMX.Dialogs,
  {$ELSE}
    Vcl.Dialogs,
  {$ENDIF}

  UMigrationsInterface, URegisterMigrationInterface, UGetterMigrationsInterface,
  UMigrationExecutorInterface, UGetterMigrations, URegisterMigration, UMigrationExecutor,
  UMigrationsHistoryInterface, UMigrationsHistory, UMigrationSerializer, Generics.Collections, 
  System.SysUtils, System.Rtti, UMigrationListOrderInterface,
  UMigrationListOrder, System.Generics.Defaults, UMigrationSerializerInterface,
  UMigrationUpMethodExecutorInterface, UMigrationDownMethodExecutorInterface,
  UMigrationMethodExecutorInterface, USetupExecutorInterface,
  UMigrationsHistoryItem, UPropertyClassReader, UPropertyClassReaderInterface;

type
  {$M+}
  {$REGION 'TMigrationsManager'}
    /// <Description>
    ///  Standard implementation of the migration�s register.
    /// </Description>
    /// <Note>
    ///  A migration register is responsible for registering the migration within
    ///  the migration management class. Thus, the migration becomes known by the
    ///  migration management class and can be used when needed.
    ///
    ///  Information from undocumented methods can be found directly on the interfaces
    ///  from which they come.
    /// </Note>
  {$ENDREGION}
  TMigrationsManager = class
  private
    FDefaultContructorUsed: Boolean;
    FMigrationList: TList<TClass>;

    FGetterMigration: IGetterMigrations;
    FRegisterMigration: IRegisterMigration;
    FMigrationSerializer: IMigrationSerializer;
    FMigrationsHistory: IMigrationsHistory;
    FMigrationExecutor: IMigrationExecutor;

    FMigrationListOrder: TMigrationListOrder;
    FCompare: IComparer<TClass>;

    FMethodExecutor: IMigrationMethodExecutor;
    FMethodUpExecutor: IMigrationUpMethodExecutor;
    FMethodDownExecutor: IMigrationDownMethodExecutor;
    FMethodSetupExecutor: IMigrationSetupMethodExecutor;
    FReader: IPropertyClassReader;

    procedure RegisterMigration(AMigrationList: TList<TClass>; AMigration: TClass); overload;

    function getMigrations(AMigrationsList: TList<TClass>; AStartSeqMigration: Integer): TList<IMigration>; overload;
    function getMigrations(AMigrationsList: TList<TClass>; AStartMigrationDateTime: TDateTime): TList<IMigration>; overload;

    procedure Execute(AMigrationsList: TList<TClass>;
                      AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                      AReader: IPropertyClassReader;
                      AMethodUpExecutor: IMigrationUpMethodExecutor;
                      AMigrationHistory: IMigrationsHistory); overload;
    procedure ExecutePending(AMigrationsList: TList<TClass>;
                             ALastMigration: TMigrationsHistoryItem;
                             AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                             AReader: IPropertyClassReader;
                             AMethodUpExecutor: IMigrationUpMethodExecutor;
                             AMigrationHistory: IMigrationsHistory); overload;
    procedure ExecuteUntil(AMigrationsList: TList<TClass>;
                           AMigrationSequence: Integer;
                           AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                           AReader: IPropertyClassReader;
                           AMethodUpExecutor: IMigrationUpMethodExecutor;
                           AMigrationHistory: IMigrationsHistory); overload;

    procedure Rollback(AMigrationsList: TList<TClass>;
                       AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                       AReader: IPropertyClassReader;
                       AMethodDownExecutor: IMigrationDownMethodExecutor;
                       AMigrationHistory: IMigrationsHistory); overload;
    procedure RollbackUntil(AMigrationsList: TList<TClass>;
                            AMigrationSequence: Integer;
                            AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                            AReader: IPropertyClassReader;
                            AMethodDownExecutor: IMigrationDownMethodExecutor;
                            AMigrationHistory: IMigrationsHistory); overload;

    procedure _Create(AComparison: IMigrationListOrder);
    function getMigrationHistory: IMigrationsHistory;
  public
    constructor Create(AGetterMigration: IGetterMigrations;
                       ARegisterMigration: IRegisterMigration;
                       AMigrationExecutor: IMigrationExecutor;
                       AComparison: IMigrationListOrder;
                       AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                       AReader: IPropertyClassReader;
                       AMethodUpExecutor: IMigrationUpMethodExecutor;
                       AMethodDownExecutor: IMigrationDownMethodExecutor); reintroduce; overload;
    constructor Create; reintroduce; overload;

    destructor Destroy; override;

    {$REGION 'TMigrationsManager.RegisterMigration'}
      /// <Description>
      ///  Migration�s register method.
      /// </Description>
      /// <InputParameters>
      ///  AMigration - The migration that will be registered.
      /// </InputParameters>
      /// <Note>
      ///  This method is just a bridge for the private method RegisterMigration (interfaced).
      /// </Note>
    {$ENDREGION}
    procedure RegisterMigration(AMigration: TClass); overload;

    {$REGION 'IGetMigrations.getMigrations - Sequence'}
      /// <Description>
      ///  Gets a list of all migrations whose sequence is greater than or equal to the
      ///  inputted sequence value.
      /// </Description>
      /// <InputParameters>
      ///  AStartSeqMigration - The initial date time value of the migration that will be
      ///  considered to return. The method will return all migrations after that based on
      ///  the sequence value.
      ///  Return - A list of migrations that has the sequence�s version value greater than
      /// the initial value inputted.
      /// </InputParameters>
      /// <Note>
      ///  This method is just a bridge for the private method RegisterMigration (interfaced).
      /// </Note>
    {$ENDREGION}
    function getMigrations(AStartMigrationSeq: Integer): TList<IMigration>; overload;

    {$REGION 'IGetMigrations.getMigrations - DateTime'}
      /// <Description>
      ///  Gets a list of all migrations whose date time is greater than or equal to the
      ///  inputted date time value.
      /// </Description>
      /// <InputParameters>
      ///  AStartSeqMigration - The initial date time value of the migration that will be
      ///  considered to return. The method will return all migrations after that based on
      ///  the date time value.
      ///  Return - A list of migrations that has the date time�s version value greater than
      /// the initial value inputted.
      /// </InputParameters>
      /// <Note>
      ///  This method is just a bridge for the private method RegisterMigration (interfaced).
      /// </Note>
    {$ENDREGION}
    function getMigrations(AStartMigrationDateTime: TDateTime): TList<IMigration>; overload;

    procedure Execute; overload;
    procedure ExecutePending; overload;
    procedure ExecuteUntil(AMigrationSequence: Integer); overload;

    procedure Rollback; overload;
    procedure RollbackUntil(AMigrationSequence: Integer); overload;

    function MigrationInfo(AClass: TClass; AMethodSetupExecutor: IMigrationSetupMethodExecutor): IMigration;
  published
    property MigrationHistory: IMigrationsHistory read getMigrationHistory;
    property RegisteredMigrations: TList<TClass> read FMigrationList;
  end;

implementation

uses
  UDefs, UMigrationUpMethodExecutor, UMigrationMethodExecutor,
  UMigrationDownMethodExecutor, USetupExecutor;

{ TMigrationsManager }

constructor TMigrationsManager.Create(AGetterMigration: IGetterMigrations;
                                      ARegisterMigration: IRegisterMigration;
                                      AMigrationExecutor: IMigrationExecutor;
                                      AComparison: IMigrationListOrder;
                                      AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                      AReader: IPropertyClassReader;
                                      AMethodUpExecutor: IMigrationUpMethodExecutor;
                                      AMethodDownExecutor: IMigrationDownMethodExecutor);
begin
  if not Assigned(AGetterMigration) then
  begin
    raise Exception.Create('The parameter AGetterMigration must not be nil!');
  end
  else
  begin
    if not Assigned(ARegisterMigration) then
    begin
      raise Exception.Create('The parameter ARegisterMigration must not be nil!');
    end
    else
    begin
      if not Assigned(AMigrationExecutor) then
      begin
        raise Exception.Create('The parameter AMigrationExecutor must not be nil!');
      end
      else
      begin
        if not Assigned(AComparison) then
        begin
          raise Exception.Create('The parameter AComparison must not be nil!');
        end
        else
        begin
          if not Assigned(AMethodSetupExecutor) then
          begin
            raise Exception.Create('The parameter AMethodSetupExecutor must not be nil!');
          end
          else
          begin
            if not Assigned(AReader) then
            begin
              raise Exception.Create('The parameter AReader must not be nil!');
            end
            else
            begin
              if not Assigned(AMethodUpExecutor) then
              begin
                raise Exception.Create('The parameter AMethodUpExecutor must not be nil!');
              end
              else
              begin
                if not Assigned(AMethodDownExecutor) then
                begin
                  raise Exception.Create('The parameter AMethodDownExecutor must not be nil!');
                end
                else
                begin
                  inherited Create;

                  FDefaultContructorUsed := False;

                  FGetterMigration := AGetterMigration;
                  FRegisterMigration := ARegisterMigration;
                  FMigrationExecutor := AMigrationExecutor;
                  FMethodSetupExecutor := AMethodSetupExecutor;
                  FReader := AReader;
                  FMethodUpExecutor := AMethodUpExecutor;
                  FMethodDownExecutor := AMethodDownExecutor;

                  Self._Create(AComparison);
                end;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

constructor TMigrationsManager.Create;
var
  Path: string;
begin
  inherited Create;

  FDefaultContructorUsed := True;

  FGetterMigration := TGetterMigrations.Create;
  FRegisterMigration := TRegisterMigration.Create;

  Path := ExtractFilePath(ParamStr(0)) + CFILE_NAME;
  FMigrationSerializer := TMigrationSerializer.Create;
  FMigrationsHistory := TMigrationsHistory.Create(Path, FMigrationSerializer);

  FMethodExecutor := TMigrationMethodExecutor.Create;
  FMethodUpExecutor := TMigrationUpMethodExecutor.Create(FMethodExecutor);
  FMethodDownExecutor := TMigrationDownMethodExecutor.Create(FMethodExecutor);
  FMethodSetupExecutor := TMigrationSetupMethodExecutor.Create(FMethodExecutor);
  FReader := TPropertyClassReader.Create;

  FMigrationExecutor := TMigrationExecutor.Create(FMigrationsHistory, FMethodUpExecutor, FMethodDownExecutor, FMethodSetupExecutor);

  FMigrationListOrder := TMigrationListOrder.Create(FMethodExecutor);
  Self._Create(FMigrationListOrder);
end;

destructor TMigrationsManager.Destroy;
begin
  if FDefaultContructorUsed then
  begin
//    if Assigned(FMigrationListOrder) then FreeAndNil(FMigrationListOrder);
//    FMigrationExecutor := nil;
//    if Assigned(FMigrationExecutor) then TMigrationExecutor(FMigrationExecutor).Destroy;
//    FMigrationsHistory := nil;
//    if Assigned(FMigrationsHistory) then FreeAndNil(FMigrationsHistory);
//    FMigrationSerializer := nil;
//    if Assigned(FMigrationTest) then FreeAndNil(FMigrationTest);
//    FRegisterMigration := nil;
//    if Assigned(FRegisterMigration) then FreeAndNil(FRegisterMigration);
//    FGetterMigration := nil;
//    if Assigned(FGetterMigration) then FreeAndNil(FGetterMigration);
  end;

  if Assigned(FMigrationList) then FMigrationList.Free;
//  if Assigned(FMigrationListOrder) then FMigrationListOrder.Free;

  inherited;
end;

procedure TMigrationsManager.Execute;
begin
  Self.Execute(FMigrationList, FMethodSetupExecutor, FReader, FMethodUpExecutor, FMigrationsHistory);
end;

procedure TMigrationsManager.ExecutePending(AMigrationsList: TList<TClass>;
                                            ALastMigration: TMigrationsHistoryItem;
                                            AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                            AReader: IPropertyClassReader;
                                            AMethodUpExecutor: IMigrationUpMethodExecutor;
                                            AMigrationHistory: IMigrationsHistory);
begin
  FMigrationExecutor.ExecutePending(AMigrationsList,
                                    ALastMigration,
                                    AMethodSetupExecutor,
                                    AReader,
                                    AMethodUpExecutor,
                                    AMigrationHistory);
end;

procedure TMigrationsManager.ExecutePending;
begin
  Self.ExecutePending(FMigrationList,
                      FMigrationsHistory.LastMigration,
                      FMethodSetupExecutor,
                      FReader,
                      FMethodUpExecutor,
                      FMigrationsHistory);
end;

procedure TMigrationsManager.ExecuteUntil(AMigrationsList: TList<TClass>;
                                          AMigrationSequence: Integer;
                                          AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                          AReader: IPropertyClassReader;
                                          AMethodUpExecutor: IMigrationUpMethodExecutor;
                                          AMigrationHistory: IMigrationsHistory);
begin
  FMigrationExecutor.ExecuteUntil(AMigrationsList,
                                  AMigrationSequence,
                                  AMethodSetupExecutor,
                                  AReader,
                                  AMethodUpExecutor,
                                  AMigrationHistory);
end;

procedure TMigrationsManager.ExecuteUntil(AMigrationSequence: Integer);
begin
  Self.ExecuteUntil(FMigrationList,
                    AMigrationSequence,
                    FMethodSetupExecutor,
                    FReader,
                    FMethodUpExecutor,
                    FMigrationsHistory);
end;

procedure TMigrationsManager.Execute(AMigrationsList: TList<TClass>;
                                     AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                     AReader: IPropertyClassReader;
                                     AMethodUpExecutor: IMigrationUpMethodExecutor;
                                     AMigrationHistory: IMigrationsHistory);
begin
  FMigrationExecutor.Execute(AMigrationsList,
                             AMethodSetupExecutor,
                             AReader,
                             AMethodUpExecutor,
                             AMigrationHistory);
end;

function TMigrationsManager.getMigrationHistory: IMigrationsHistory;
begin
  Result := nil;

  if Assigned(FMigrationExecutor) then
  begin
    Result := Self.FMigrationExecutor.MigrationHistory;
  end;
end;

function TMigrationsManager.getMigrations(AStartMigrationDateTime: TDateTime): TList<IMigration>;
begin
  Result := Self.getMigrations(FMigrationList, AStartMigrationDateTime);
end;

function TMigrationsManager.MigrationInfo(AClass: TClass; AMethodSetupExecutor: IMigrationSetupMethodExecutor): IMigration;
var
  Aux: TObject;
begin
  Result := nil;

  if not Assigned(AClass) then
  begin
    raise Exception.Create('The parameter AClass must not be nil.');
  end
  else
  begin
    Aux := AClass.Create;

    //First, call for setup to load informations
//    FMigrationExecutor.ExecuteSetup(AClass, Aux);
    AMethodSetupExecutor.Execute(AClass, Aux);

    Result := Aux as TInterfacedObject as IMigration;
  end;
end;

procedure TMigrationsManager.RegisterMigration(AMigration: TClass);
begin
  Self.RegisterMigration(FMigrationList, AMigration);
end;

procedure TMigrationsManager.Rollback(AMigrationsList: TList<TClass>;
                                      AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                      AReader: IPropertyClassReader;
                                      AMethodDownExecutor: IMigrationDownMethodExecutor;
                                      AMigrationHistory: IMigrationsHistory);
begin
  FMigrationExecutor.Rollback(AMigrationsList,
                              AMethodSetupExecutor,
                              AReader,
                              AMethodDownExecutor,
                              AMigrationHistory);
end;

procedure TMigrationsManager.Rollback;
begin
  Self.Rollback(FMigrationList,
                FMethodSetupExecutor,
                FReader,
                FMethodDownExecutor,
                FMigrationsHistory);
end;

procedure TMigrationsManager.RollbackUntil(AMigrationsList: TList<TClass>;
                                           AMigrationSequence: Integer;
                                           AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                                           AReader: IPropertyClassReader;
                                           AMethodDownExecutor: IMigrationDownMethodExecutor;
                                           AMigrationHistory: IMigrationsHistory);
begin
  FMigrationExecutor.RollbackUntil(AMigrationsList,
                                   AMigrationSequence,
                                   AMethodSetupExecutor,
                                   AReader,
                                   AMethodDownExecutor,
                                   AMigrationHistory);
end;

procedure TMigrationsManager.RollbackUntil(AMigrationSequence: Integer);
begin
  Self.RollbackUntil(FMigrationList, AMigrationSequence, FMethodSetupExecutor);
end;

function TMigrationsManager.getMigrations(AStartMigrationSeq: Integer): TList<IMigration>;
begin
  Result := Self.getMigrations(FMigrationList, AStartMigrationSeq);
end;

function TMigrationsManager.getMigrations(AMigrationsList: TList<TClass>; AStartMigrationDateTime: TDateTime): TList<IMigration>;
var
  LClass: TClass;
  Aux: TObject;
  LContext: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  DateTimeProp: TRttiProperty;
  LMethod: TRttiMethod;
begin
  Result := nil;

  if Assigned(FMigrationList) then
  begin
    for LClass in FMigrationList do
    begin
      Aux := LClass.Create;
      try
        LType := LContext.GetType(LClass.ClassInfo);

        //Find the props
        DateTimeProp := nil;

        for LProp in LType.GetProperties do
        begin
          if LowerCase(LProp.Name) = LowerCase(PROP_DATETIME) then DateTimeProp := LPRop;
        end;

        if not Assigned(DateTimeProp) then
        begin
          raise Exception.Create('Could not find ' + PROP_DATETIME + ' property of class implementation.');
        end
        else
        begin
          //Find the methods
          for LMethod in LType.GetDeclaredMethods do
          begin
            if LowerCase(LMethod.Name) = LowerCase(METHOD_SETUP) then
            begin
              LMethod.Invoke(Aux, []);
            end;

            if StrToDateTime(DateTimeProp.GetValue(Aux).ToString) >= AStartMigrationDateTime then
            begin
              if not ASsigned(Result) then Result := TList<IMigration>.Create;

              Result.Add(Aux as TInterfacedObject as IMigration);
              
            end;
          end;
        end;
      finally
        FreeAndNil(Aux);
      end
    end;
  end;

  if not Assigned(Result) then Result.Sort;  
end;

procedure TMigrationsManager._Create(AComparison: IMigrationListOrder);
begin
  FCompare := TComparer<TClass>.Construct(AComparison.Comparison) as TDelegatedComparer<TClass>;

  FMigrationList := TList<TClass>.Create(TComparer<TClass>.Construct(AComparison.Comparison));
end;

function TMigrationsManager.getMigrations(AMigrationsList: TList<TClass>; AStartSeqMigration: Integer): TList<IMigration>;
var
  LClass: TClass;
  Aux: TObject;
  LContext: TRttiContext;
  LType: TRttiType;
  LProp: TRttiProperty;
  SequenceProp: TRttiProperty;
  LMethod: TRttiMethod;
begin
  Result := nil;

  if Assigned(FMigrationList) then
  begin
    for LClass in FMigrationList do
    begin
      Aux := LClass.Create;
      try
        LType := LContext.GetType(LClass.ClassInfo);

        //Find the props
        SequenceProp := nil;

        for LProp in LType.GetProperties do
        begin
          if LowerCase(LProp.Name) = LowerCase(PROP_SEQUENCE) then SequenceProp := LPRop;
        end;

        if not Assigned(SequenceProp) then
        begin
          raise Exception.Create('Could not find ' + PROP_SEQUENCE + ' property of class implementation.');
        end
        else
        begin
          //Find the methods
          for LMethod in LType.GetDeclaredMethods do
          begin
            if LowerCase(LMethod.Name) = LowerCase(METHOD_SETUP) then
            begin
              LMethod.Invoke(Aux, []);
            end;

            if SequenceProp.GetValue(Aux).AsInteger >= AStartSeqMigration then
            begin
              if not ASsigned(Result) then Result := TList<IMigration>.Create;

              Result.Add(Aux as TInterfacedObject as IMigration);
              
            end;
          end;
        end;
      finally
        FreeAndNil(Aux);
      end
    end;
  end;

  if not Assigned(Result) then Result.Sort;  
end;

procedure TMigrationsManager.RegisterMigration(AMigrationList: TList<TClass>; AMigration: TClass);
begin
  if Assigned(AMigrationList) then
  begin
    AMigrationList.Add(AMigration);
  end;
end;

end.
