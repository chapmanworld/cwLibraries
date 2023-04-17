(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCollections.StringDictionary;

interface
uses
  utlCollections
;

type
  TStringDictionary< V > = class( TInterfacedObject, IReadOnlyStringDictionary< V >, IStringDictionary< V > )
  private
    fKeys: IList< string >;
    fValues: IList< V >;
  private
    function FindByKey( const key: string; out FoundIdx: nativeuint ): boolean;
  strict private //- IReadOnlyStringDictionary< V > -//
    function getValue( const key: string ): V;
    function Count: nativeuint;
    function Keys: IReadOnlyList< string >;
    function Values: IReadOnlyList< V >;
    function KeyExists( const key: string ): boolean;
    function getAsReadOnly: IReadOnlyStringDictionary< V >;
  strict private //- IStringDictionary< V > -//
    procedure setValue( const key: string; const value: V );
    procedure Remove( const Key: string );
    procedure Clear;
  public
    constructor Create( const Granularity: nativeuint = 32 ); reintroduce; overload;
    destructor Destroy; override;
  end;

implementation
uses
  utlStatus
, utlCollections.Enumerator
;


function TStringDictionary< V >.Count: nativeuint;
begin
  Result := fKeys.Count;
end;

constructor TStringDictionary< V >.Create( const Granularity: nativeuint = 32 );
begin
  inherited Create;
  fKeys := TList< string >.Create( Granularity );
  fValues := TList< V >.Create( Granularity );
end;

destructor TStringDictionary< V >.Destroy;
begin
  fKeys := nil;
  fValues := nil;
  inherited Destroy;
end;

function TStringDictionary< V >.getAsReadOnly: IReadOnlyStringDictionary< V >;
begin
  Result := Self as IReadOnlyStringDictionary< V >;
end;

function TStringDictionary< V >.FindByKey( const key: string; out FoundIdx: nativeuint ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if fKeys.Count = 0 then exit;
  for idx := 0 to pred( fKeys.Count ) do begin
    if fKeys[ idx ] = key then begin
      FoundIdx := idx;
      exit( true );
    end;
  end;
end;

function TStringDictionary< V >.getValue( const key: string ): V;
var
  FoundIdx: nativeuint;
begin
  if not FindByKey( key, FoundIdx ) then begin
    raise TStatus.CreateException( stDictionaryKeyNotFound );
  end;
  Result := fValues[ FoundIdx ];
end;

function TStringDictionary< V >.KeyExists( const key: string ): boolean;
var
  DiscardIdx: nativeuint;
begin
  Result := FindByKey( key, DiscardIdx );
end;

function TStringDictionary< V >.Keys: IReadOnlyList< string >;
begin
  Result := fKeys.getAsReadOnly;
end;

procedure TStringDictionary< V >.Remove( const Key: string );
var
  FoundIdx: nativeuint;
begin
  if not FindByKey( key, FoundIdx ) then exit;
  fKeys.RemoveItem( FoundIdx );
  fValues.RemoveItem( FoundIdx );
end;

procedure TStringDictionary< V >.setValue( const key: string; const value: V );
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

function TStringDictionary< V >.Values: IReadOnlyList< V >;
begin
  Result := fValues.getAsReadOnly;
end;

procedure TStringDictionary< V >.Clear;
begin
  fKeys.Clear;
  fValues.Clear;
end;

end.


