(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCollections.List;

interface
uses
  utlCollections
;

type
  TStandardList< T > = class( TInterfacedObject, IReadOnlyList< T >, IList< T > )
  private
    type TArrayOfType = array of T;
  private
    fItems: TArrayOfType;
    fCount: nativeuint;
    fGranularity: nativeuint;
    fOrdered: boolean;
    fPruned: boolean;
  strict private //- IEnumerable< T >.GetEnumerator / IReadOnlyList< T >.GetEnumerator-//
    function GetEnumerator: IEnumerator< T >;
  strict private //- IReadOnlyList< T > -//
    function getCount: nativeuint;
    function getItem( const idx: nativeuint ): T;
    function getAsReadOnly: IReadOnlyList< T >;
    function Contains( const Value: T; const Comparer: TCompareFunction< T > ): boolean;
    function Find( const Value: T; out FoundIdx: nativeuint; const Comparer: TCompareFunction< T > ): boolean;
    procedure Sort( const Compare: TCompareFunction< T > );
  strict private //- IList< T > -/
    procedure Copy( const SourceList: IReadOnlyList< T > );
    procedure Clear;
    function Add( const Item: T ): nativeuint;
    procedure setItem( const idx: nativeuint; const item: T );
    procedure Remove( const Item: T; const Comparer: TCompareFunction< T > );
    function RemoveItem( const idx: nativeuint ): boolean;
  private
    function OrderedRemoveItem( const idx: nativeuint ): boolean;
    function UnorderedRemoveItem( const idx: nativeuint ): boolean;
    procedure PruneCapacity;
    procedure Merge( const Compare: TCompareFunction<T>; var A: TArrayOfType; const L: nativeuint; const M: nativeuint; const R: nativeuint );
    procedure MergeSort( const Compare: TCompareFunction<T>; var A: TArrayOfType; const L: nativeuint; const R: nativeuint );
  public
    constructor Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
 utlCollections.Enumerator
;

function TStandardList< T >.Add( const Item: T ): nativeuint;
var
  NewSize: nativeuint;
  L: nativeuint;
begin
  L := Length( fItems );
  if ( fCount = L ) then begin
    NewSize := Length( fItems );
    NewSize := NewSize + fGranularity;
    SetLength( fItems, NewSize );
  end;
  fItems[ fCount ] := Item;
  Result := fCount;
  inc( fCount );
end;

procedure TStandardList< T >.Clear;
begin
  fCount := 0;
  SetLength( fItems, 0 );
end;

constructor TStandardList< T >.Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false );
begin
  inherited Create;
  if Granularity > 0 then fGranularity := Granularity;
  fPruned := isPruned;
  fOrdered := isOrdered;
  fCount := 0;
  SetLength( fItems, 0 );
end;

destructor TStandardList< T >.Destroy;
begin
  SetLength( fItems, 0 );
  inherited Destroy;
end;

function TStandardList< T >.Find( const Value: T; out FoundIdx: nativeuint; const Comparer: TCompareFunction< T > ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if fCount = 0 then exit;
  for idx := 0 to pred( fCount ) do begin
    if Comparer( fItems[ idx ], Value ) = crEqual then begin
      FoundIdx := Idx;
      exit( true );
    end;
  end;
end;

function TStandardList< T >.GetEnumerator: IEnumerator< T >;
begin
  Result := TEnumerator< T >.Create( @fItems, fCount );
end;

function TStandardList< T >.getCount: nativeuint;
begin
  Result := fCount;
end;

function TStandardList< T >.getItem( const idx: nativeuint ): T;
begin
  Result := fItems[ idx ];
end;

function TStandardList< T >.OrderedRemoveItem( const idx: nativeuint ): boolean;
var
  idy: nativeuint;
begin
  Result := False;
  if fCount = 0 then exit;
  if idx < pred( fCount ) then begin
    for idy := idx to pred( pred( fCount ) ) do fItems[ idy ] := fItems[ succ( idy ) ];
    fItems[ pred( fCount ) ] := Default( T );
    dec( fCount );
    Result := True;
  end else if idx = pred( fCount ) then begin
    fItems[ idx ] := Default( T );
    dec( fCount );
    Result := True;
  end;
end;

function TStandardList< T >.UnorderedRemoveItem( const idx: nativeuint ): boolean;
begin
  Result := False;
  if fCount > 0 then begin
    if idx < pred( fCount ) then begin
      fItems[ idx ] := fItems[ pred( fCount ) ];
      fItems[ pred( fCount ) ] := Default( T );
      dec( fCount );
      Result := True;
    end else if idx = pred( fCount ) then begin
      fItems[ idx ] := Default( T );
      dec( fCount );
      Result := True;
    end;
  end;
end;

procedure TStandardList< T >.PruneCapacity;
var
  Blocks: nativeuint;
  Remainder: nativeuint;
  TargetSize: nativeuint;
  L: nativeuint;
begin
  TargetSize := 0;
  Remainder := 0;
  Blocks := fCount div fGranularity;
  Remainder := fCount - Blocks;
  if Remainder>0 then inc( Blocks );
  TargetSize := Blocks * fGranularity;
  L := Length( fItems );
  if L > TargetSize then SetLength( fItems, TargetSize );
end;

procedure TStandardList< T >.Remove( const Item: T; const Comparer: TCompareFunction< T > );
var
  FoundIdx: nativeuint;
begin
  if not Find( Item, FoundIdx, Comparer ) then exit;
  RemoveItem( FoundIdx );
end;

function TStandardList< T >.RemoveItem( const idx: nativeuint ): boolean;
begin
  if fOrdered then Result := OrderedRemoveItem( idx ) else Result := UnorderedRemoveItem( idx );
  if fPruned then PruneCapacity;
end;

procedure TStandardList< T >.setItem( const idx: nativeuint; const item: T);
begin
  fItems[ idx ] := item;
end;

procedure TStandardList<T>.Merge( const Compare: TCompareFunction<T>; var A: TArrayOfType; const L: nativeuint; const M: nativeuint; const R: nativeuint );
var
  CR: TCompareResult;
  LeftSize, RightSize, i, j, k: nativeuint;
  LeftPart, RightPart: TArrayOfType;
begin
  LeftSize := M - L + 1;
  RightSize := R - M;
  SetLength( LeftPart, LeftSize );
  SetLength( RightPart, RightSize );
  for i := 0 to LeftSize - 1 do begin
    LeftPart[ i ] := A[ L + i ];
  end;
  for j := 0 to RightSize - 1 do begin
    RightPart[ j ] := A[ M + 1 + j ];
  end;
  i := 0;
  j := 0;
  k := L;
  while ( i < LeftSize ) and ( j < RightSize ) do begin
    CR := Compare( LeftPart[ i ], RightPart[ j ] );
    if ( CR = crAIsLess ) or ( CR = crEqual ) then begin
      A[ k ] := LeftPart[ i ];
      inc( i );
    end else begin
      A[ k ] := RightPart[ j ];
      inc( j );
    end;
    inc( k );
  end;
  while i < LeftSize do begin
    A[ k ] := LeftPart[ i ];
    inc( i );
    inc( k );
  end;
  while j < RightSize do begin
    A[ k ] := RightPart[ j ];
    inc( j );
    inc( k );
  end;
end;

procedure TStandardList<T>.MergeSort( const Compare: TCompareFunction<T>; var A: TArrayOfType; const L: nativeuint; const R: nativeuint );
var
  M: nativeuint;
begin
  if L < R then
  begin
    M := ( L + R ) div 2;
    MergeSort( Compare, A, L, M );
    MergeSort( Compare, A, succ( M ), R );
    Merge( Compare, A, L, M, R );
  end;
end;


procedure TStandardList<T>.Sort( const Compare: TCompareFunction<T> );
var
  idx: nativeuint;
begin
  if fCount <= 1 then exit;
  // Start by setting the length of the items array to count
  SetLength( fItems, fCount );
  MergeSort( Compare, fItems, 0, pred( Length( fItems ) ) );
end;


function TStandardList< T >.getAsReadOnly: IReadOnlyList<T>;
begin
  Result := Self as IReadOnlyList< T >;
end;

function TStandardList< T >.Contains( const Value: T; const Comparer: TCompareFunction< T > ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if fCount = 0 then exit;
  for idx := 0 to pred( fCount ) do begin
    if Comparer( Value, fItems[ idx ] ) = crEqual then begin
      Result := True;
      exit;
    end;
  end;
end;

procedure TStandardList< T >.Copy( const SourceList: IReadOnlyList< T > );
var
  idx: nativeuint;
begin
  if SourceList.Count = 0 then exit;
  for idx := 0 to pred( SourceList.Count ) do Add( SourceList[ idx ] );
end;

end.


