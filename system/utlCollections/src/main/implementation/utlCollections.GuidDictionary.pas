(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCollections.GuidDictionary;

interface
uses
  utlCollections
;

type
  TGuidDictionary< V > = class( TInterfacedObject, IReadOnlyGuidDictionary< V >, IGuidDictionary< V > )
  private
    fKeys: IList< TGuid >;
    fValues: IList< V >;
  private
    function FindByKey( const key: TGuid; out FoundIdx: nativeuint ): boolean;
  strict private //- IReadOnlyGuidDictionary< V > -//
    function getValue( const key: TGuid ): V;
    function Count: nativeuint;
    function Keys: IReadOnlyList< TGuid >;
    function Values: IReadOnlyList< V >;
    function KeyExists( const key: TGuid ): boolean;
    function getAsReadOnly: IReadOnlyGuidDictionary< V >;
  strict private //- IGuidDictionary< V > -//
    procedure setValue( const key: TGuid; const value: V );
    procedure Remove( const Key: TGuid );
    procedure Clear;
  public
    constructor Create( const Granularity: nativeuint = 32 ); reintroduce; overload;
    destructor Destroy; override;
  end;

implementation
uses
  utlStatus
, utlTypes
, utlCollections.Enumerator
;

function TGuidDictionary< V >.Count: nativeuint;
begin
  Result := fKeys.Count;
end;

constructor TGuidDictionary< V >.Create( const Granularity: nativeuint = 32 );
begin
  inherited Create;
  fKeys := TList< TGuid >.Create( Granularity );
  fValues := TList< V >.Create( Granularity );
end;

destructor TGuidDictionary< V >.Destroy;
begin
  fKeys := nil;
  fValues := nil;
  inherited Destroy;
end;

function TGuidDictionary< V >.getAsReadOnly: IReadOnlyGuidDictionary< V >;
begin
  Result := Self as IReadOnlyGuidDictionary< V >;
end;

function TGuidDictionary< V >.FindByKey( const key: TGuid; out FoundIdx: nativeuint ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if fKeys.Count = 0 then exit;
  for idx := 0 to pred( fKeys.Count ) do begin
    if fKeys[ idx ].EqualTo( key ) then begin
      FoundIdx := idx;
      exit( true );
    end;
  end;
end;

function TGuidDictionary< V >.getValue( const key: TGuid ): V;
var
  FoundIdx: nativeuint;
begin
  if not FindByKey( key, FoundIdx ) then begin
    raise TStatus.CreateException( stDictionaryKeyNotFound );
  end;
  Result := fValues[ FoundIdx ];
end;

function TGuidDictionary< V >.KeyExists( const key: TGuid ): boolean;
var
  DiscardIdx: nativeuint;
begin
  Result := FindByKey( key, DiscardIdx );
end;

function TGuidDictionary< V >.Keys: IReadOnlyList< TGuid >;
begin
  Result := fKeys.getAsReadOnly;
end;

procedure TGuidDictionary< V >.Remove( const Key: TGuid );
var
  FoundIdx: nativeuint;
begin
  if not FindByKey( key, FoundIdx ) then exit;
  fKeys.RemoveItem( FoundIdx );
  fValues.RemoveItem( FoundIdx );
end;

procedure TGuidDictionary< V >.setValue( const key: TGuid; const value: V );
var
  FoundIdx: nativeuint;
begin
  if FindByKey( key, FoundIdx ) then begin
    fValues[ FoundIdx ] := Value;
  end else begin
    fKeys.Add( Key );
    fValues.Add( Value );
  end;
end;

function TGuidDictionary< V >.Values: IReadOnlyList< V >;
begin
  Result := fValues.getAsReadOnly;
end;

procedure TGuidDictionary< V >.Clear;
begin
  fKeys.Clear;
  fValues.Clear;
end;

end.


