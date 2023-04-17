(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCollections.RingBuffer;

interface
uses
  utlCollections
;

type
  TStandardRingBuffer< T > = class( TInterfacedObject, IReadOnlyRingBuffer< T >, IRingBuffer< T > )
  private
    fPushIndex: nativeuint;
    fPullIndex: nativeuint;
    fItems: array of T;
  strict private //- IReadOnlyRingBuffer< T > -//
    function Pull( out item: T ): boolean;
    function IsEmpty: boolean;
    function getAsReadOnly: IReadOnlyRingBuffer< T >;
  strict private //- IRingBuffer< T > -//
    function Push( const item: T ): boolean;
  public
    constructor Create( const ItemCount: nativeuint = 128 ); reintroduce;
  end;

implementation

constructor TStandardRingBuffer< T >.Create( const ItemCount: nativeuint );
begin
  inherited Create;
  fPushIndex := 0;
  fPullIndex := 0;
  SetLength( fItems, ItemCount );
end;

function TStandardRingBuffer< T >.IsEmpty: boolean;
begin
  Result := True;
  if fPullIndex = fPushIndex then exit;
  Result := False;
end;

function TStandardRingBuffer< T >.Pull( out item: T ): boolean;
var
  NewIndex: nativeuint;
  L: nativeuint;
begin
  Result := False;
  if fPullIndex=fPushIndex then exit;
  Item := Default( T );
  Move( fItems[ fPullIndex ], item, sizeof( T ) );
  NewIndex := succ( fPullIndex );
  L := Length( fItems );
  if NewIndex>=L then NewIndex := 0;
  fPullIndex := NewIndex;
  Result := True;
end;

function TStandardRingBuffer< T >.Push( const item: T ): boolean;
var
  NewIndex: nativeuint;
  L: nativeuint;
begin
  Result := False;
  NewIndex := succ( fPushIndex );
  L := Length( fItems );
  if ( NewIndex >= L ) then NewIndex := 0;
  if NewIndex = fPullIndex then exit;
  Move( item, fItems[ fPushIndex ], sizeof( T ) );
  fPushIndex := NewIndex;
  Result := True;
end;

function TStandardRingBuffer< T >.getAsReadOnly: IReadOnlyRingBuffer<T>;
begin
  Result := self as IReadOnlyRingBuffer< T >;
end;

end.


