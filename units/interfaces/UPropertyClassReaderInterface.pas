unit UPropertyClassReaderInterface;

interface

uses
  System.Rtti;

type
  {$REGION 'IPropertyClassReader'}
    /// <Description>
    ///  Standard method to get property information of a class.
    /// </Description>
  {$ENDREGION}
  IPropertyClassReader = interface
  ['{62B6FF9A-08D4-48D2-BAEA-94E2C8268B0F}']
    {$REGION 'IPropertyClassReader.PropertyOfMigrationClass'}
      /// <Description>
      ///  Gets a property value.
      /// </Description>
      /// <InputParameters>
      ///  AClass - The class type to be inspected.
      ///  AInstance - A instance of the class type inputted. Must not be nil.
      ///  APropName - The property name that will be returned.
      /// </InputParameters>
    {$ENDREGION}
    function PropertyOfMigrationClass(AClass: TClass; AInstance: TObject; APropName: string): TValue;
  end;

implementation

end.