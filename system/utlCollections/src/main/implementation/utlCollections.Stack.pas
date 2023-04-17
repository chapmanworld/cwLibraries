(*
(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCollections.Stack;

interface
uses
  utlCollections
;

type
  TStandardStack< T > = class( TInterfacedObject, IReadOnlyStack< T >, IStack< T > )
  private
    fItems: array of T;
    fCount: nativeuint;
    fCapacity: nativeuint;
    fGranularity: nativeuint;
    fPruned: boolean;
  strict private //- IEnuerable -//
    function GetEnumerator: IEnumerator< T >;
  private //- IReadOnlyStack -//
    function Pull: T;
    function Count: nativeuint;
    function getAsReadOnly: IReadOnlyStack< T >;
  private //- IStack<T> -//
    procedure Push( const Item: T );
  public
    constructor Create( const Granularity: nativeuint = 0; const IsPruned: boolean = false ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlCollections.Enumerator
;

constructor TStandardStack< T >.Create( const Granularity: nativeuint; const IsPruned: boolean );
const
  cDefaultGranularity = 32;
begin
  inherited Create;
  if Granularity>0 then fGranularity := Granularity else fGranularity := cDefaultGranularity;
  fPruned := IsPruned;
  fCapacity := 0;
  fCount := 0;
  SetLength( fItems, fCapacity );
end;

destructor TStandardStack< T >.Destroy;
begin
  SetLength( fItems, 0 );
  inherited Destroy;
end;

function TStandardStack< T >.GetEnumerator: IEnumerator<T>;
begin
  Result := TEnumerator< T >.Create( @fItems, fCount );
end;

function TStandardStack< T >.Pull: T;
begin
  Result := Default( T );
  if fCount > 0 then begin
    Result := fItems[ pred( fCount ) ];
    fItems[ pred( fCount ) ] := Default( T );
    dec( fCount );
    if fPruned then begin
      if fCount < ( fCapacity - fGranularity ) then begin
        fCapacity := fCapacity - fGranularity;
        SetLength( fItems, fCapacity );
      end;
    end;
  end;
end;

function TStandardStack< T >.Count: nativeuint;
begin
  Result := fCount;
end;

procedure TStandardStack< T >.Push( const Item: T );
begin
  if ( fCount = fCapacity ) then begin
    fCapacity := fCapacity + fGranularity;
    SetLength( fItems, fCapacity );
  end;
  fItems[ fCount ] := Item;
  inc( fCount );
end;

function TStandardStack< T >.getAsReadOnly: IReadOnlyStack<T>;
begin
  Result := Self as IReadOnlyStack< T >;
end;

end.


