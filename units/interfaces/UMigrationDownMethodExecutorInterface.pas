unit UMigrationDownMethodExecutorInterface;

interface

type
  IMigrationDownMethodExecutor = interface
  ['{9B2DAFE0-7FC3-4AFE-8446-CE2E090F0AC0}']
    function Execute(AClass: TClass; AInstance: TObject): boolean;
  end;

implementation

end.
