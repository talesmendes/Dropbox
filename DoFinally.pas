unit DoFinally;

interface

uses
  Contnrs;

type
  IDoFinally = interface
    ['{C1B90772-6755-4F4A-9FEC-B1CE3342F2F7}']
    function Add(O: TObject): TObject;

  end;

  TDoFinally = class(TInterfacedObject, IDoFinally)
  private
    FreeList: TObjectList;
  public
    constructor Create;
    destructor Destroy; override;
    function Add(O: TObject): TObject;
    class function Guard<T: class>(O: T; var DF: IDoFinally): T;
    class function New: IDoFinally;
  end;

implementation

{ TDoFinally }

function TDoFinally.Add(O: TObject): TObject;
begin
  FreeList.Add(O);
  Result := O;
end;

constructor TDoFinally.Create;
begin
  FreeList := TObjectList.Create(True);
end;

destructor TDoFinally.Destroy;
begin
  FreeList.Free;
  inherited;
end;

class function TDoFinally.Guard<T>(O: T; var DF: IDoFinally): T;
begin
  if not Assigned(DF) then
    DF := TDoFinally.Create;
  Result := DF.Add(O) as T;
end;

class function TDoFinally.New: IDoFinally;
begin
  Result := TDoFinally.Create;
end;

end.
