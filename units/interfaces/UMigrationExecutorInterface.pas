{######################################################################################

                                      M4D Framework

Author: Edgar Borges Pav�o
Date of creation: 30/08/2017
Use licence: Free

######################################################################################}

unit UMigrationExecutorInterface;

interface

uses
  UMigrationsInterface, Generics.Collections, UMigrationsHistoryInterface,
  UMigrationsHistoryItem, USetupExecutorInterface, UPropertyClassReader,
  UMigrationUpMethodExecutorInterface, UPropertyClassReaderInterface,
  UMigrationDownMethodExecutorInterface;

type
  {$REGION 'IMigrationExecutor'}
    /// <Description>
    ///  Standard method to execute migrations on a list.
    /// </Description>
    /// <Note>
    ///  This allows you to perform migrations, both forward and backward.
    /// </Note>
  {$ENDREGION}
  IMigrationExecutor = interface
  ['{E348B052-BF8F-4BF0-9347-EC70B252F308}']
    {$REGION 'IMigrationExecutor.ExecuteSetup'}
      /// <Description>
      ///  Execute the setup method of the migration.
      /// </Description>
      /// <InputParameters>
      ///  AClass - The class that will have the setup method executed.
      ///  AInstance - An instance of the class that will have the setup method executed.
      /// </InputParameters>
    {$ENDREGION}
//    procedure ExecuteSetup(AClass: TClass; AInstance: TObject; AMethodSetupExecutor: IMigrationSetupMethodExecutor);
    {$REGION 'IMigrationExecutor.Execute'}
      /// <Description>
      ///  Performs the migration forward.
      /// </Description>
      /// <InputParameters>
      ///  AMigrationsList - The list all the migrations that will be considered for the execution.
      /// </InputParameters>
    {$ENDREGION}
    procedure Execute(AMigrationsList: TList<TClass>;
                      AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                      AReader: IPropertyClassReader;
                      AMethodUpExecutor: IMigrationUpMethodExecutor;
                      AMigrationHistory: IMigrationsHistory);
    {$REGION 'IMigrationExecutor.ExecutePending'}
      /// <Description>
      ///  Performs the execution of pending�s migration.
      /// </Description>
      /// <InputParameters>
      ///  AMigrationsList - The list all the migrations that will be considered for the execution.
      /// </InputParameters>
      /// <Note>
      ///  Pending migrations are those that have not yet been executed based on the execution
      ///  history. The class must identify which executions have not been performed (usually
      ///  based on the sequence of the migrations) and execute them.
      /// </Note>
    {$ENDREGION}
    procedure ExecutePending(AMigrationsList: TList<TClass>;
                             ALastMigration: TMigrationsHistoryItem;
                             AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                             AReader: IPropertyClassReader;
                             AMethodUpExecutor: IMigrationUpMethodExecutor;
                             AMigrationHistory: IMigrationsHistory);
    {$REGION 'IMigrationExecutor.ExecuteUntil'}
      /// <Description>
      ///  Performs the execution until the inputted value.
      /// </Description>
      /// <InputParameters>
      ///  AMigrationsList - The list all the migrations that will be considered for the execution.
      ///  AMigrationSequence - The last sequence value considered to execution.
      /// </InputParameters>
    {$ENDREGION}
    procedure ExecuteUntil(AMigrationsList: TList<TClass>;
                           AMigrationSequence: Integer;
                           AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                           AReader: IPropertyClassReader;
                           AMethodUpExecutor: IMigrationUpMethodExecutor;
                           AMigrationHistory: IMigrationsHistory);
    {$REGION 'IMigrationExecutor.Rollback'}
      /// <Description>
      ///  Performs the migration back.
      /// </Description>
      /// <InputParameters>
      ///  AMigrationsList - The list all the migrations that will be considered for the rollback.
      /// </InputParameters>
    {$ENDREGION}
    procedure Rollback(AMigrationsList: TList<TClass>;
                       AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                       AReader: IPropertyClassReader;
                       AMethodDownExecutor: IMigrationDownMethodExecutor;
                       AMigrationHistory: IMigrationsHistory);
    {$REGION 'IMigrationExecutor.RollbackUntil'}
      /// <Description>
      ///  Performs the migration back until the migration with sequence value equal inputted one.
      /// </Description>
      /// <InputParameters>
      ///  AMigrationsList - The list all the migrations that will be considered for the rollback.
      ///  AMigrationsSequence - Migration sequence value that will be considered as the last to
      ///  be executed in the migration�s rollback.
      /// </InputParameters>
    {$ENDREGION}
    procedure RollbackUntil(AMigrationsList: TList<TClass>;
                            AMigrationSequence: Integer;
                            AMethodSetupExecutor: IMigrationSetupMethodExecutor;
                            AReader: IPropertyClassReader;
                            AMethodDownExecutor: IMigrationDownMethodExecutor;
                            AMigrationHistory: IMigrationsHistory);
    {$REGION 'IMigrationExecutor.getMigrationHistory'}
      /// <Description>
      ///  Get the list of migrations executed.
      /// </Description>
    {$ENDREGION}
    function getMigrationsHistory: IMigrationsHistory;
    {$REGION 'IMigrationExecutor.MigrationHistory'}
      /// <Description>
      ///  Expose information on migration histories.
      /// </Description>
    {$ENDREGION}
    property MigrationHistory: IMigrationsHistory read getMigrationsHistory;
  end;

implementation

end.
