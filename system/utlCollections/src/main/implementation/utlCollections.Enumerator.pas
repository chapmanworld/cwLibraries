(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCollections.Enumerator;

interface
uses
  utlCollections
;

type
  TEnumerator< T > = class( TInterfacedObject, IEnumerator, IEnumerator< T > )
  type
    arrItems = array of T;
    ptrItems = ^arrItems;
  private
    fItems: ptrItems;
    fCount: nativeuint;
    fStarted: boolean;
    fItemIndex: nativeuint;
  strict private //- IEnumerator< T > -//
    function GenericGetCurrent: T;
    function GetCurrent: TObject;
    function IEnumerator<T>.GetCurrent = GenericGetCurrent;
    function MoveNext: boolean;
    procedure Reset;
  public
    constructor Create( const Items: pointer; const Count: nativeuint );
  end;

implementation

function TEnumerator< T >.GenericGetCurrent: T;
begin
  Result := fItems^[ fItemIndex ];
end;

function TEnumerator< T >.GetCurrent: TObject;
begin
  Result := TEnumerator< TObject >( Self ).GenericGetCurrent;
end;

function TEnumerator< T >.MoveNext: boolean;
begin
  Result := False;
  if fStarted then begin
    if succ( fItemIndex ) >= fCount then exit;
    inc( fItemIndex );
  end else begin
    if fCount = 0 then exit;
    fStarted := True;
  end;
  Result := True;
end;

procedure TEnumerator< T >.Reset;
begin
  fStarted   := False;
  fItemIndex := 0;
end;

constructor TEnumerator< T >.Create( const Items: pointer; const Count: nativeuint );
begin
  inherited Create;
  fItems     := Items;
  fCount     := Count;
  Reset;
end;

end.


