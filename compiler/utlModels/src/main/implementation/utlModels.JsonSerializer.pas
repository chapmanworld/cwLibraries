(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlModels.JsonSerializer;

interface
uses
  utlStatus
, utlIO
, utlCollections
, utlModels
, utlModels.Archetype
, utlModels.ArchetypeMember
, utlModels.Representation
, utlModels.Reflection
;

type
  IJsonSerializer = interface
    ['{71D8E761-ACC9-48CF-AB9D-63B9C971D9D9}']

    (* Serializes the instance to json *)
    function Serialize: TStatus;

    (* Returns a reference to the stream for directly serializing data, IStorage uses this to serialize it's self. *)
    function Stream: IUnicodeStream;

  end;

type
  TJsonSerializer = class( TInterfacedObject, IJsonSerializer )
  private
    fStream: IUnicodeStream;
    fArchetypes: IReadOnlyGuidDictionary< IArchetype >;
    fRepresentations: IList< IRepresentation >;
    fDone: array of boolean;
  private
    procedure StreamWrite( const S: string; const Indent: nativeuint );
    procedure StreamWriteLn( const S: string; const Indent: nativeuint );
    function FindRepresentation( const Ref: IInterface; out FoundIdx: nativeuint ): boolean;
    function SerializeRepresentation( const Representation: IRepresentation; const Index: nativeuint; var Indent: nativeuint ): TStatus;
    function SerializeReferenceMember( const PtrData: pointer; var Indent: nativeuint ): TStatus;
  strict private //- IJsonSerializer -//
    function Stream: IUnicodeStream;
    function Serialize: TStatus;
  public
    constructor Create( const Stream: IUnicodeStream; const Archetypes: IReadOnlyGuidDictionary< IArchetype >; const Representations: IList< IRepresentation > ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  SysUtils
, utlTypes
, utlModels.Storage
;

const
  cIndentSize = 2;

constructor TJsonSerializer.Create( const Stream: IUnicodeStream; const Archetypes: IReadOnlyGuidDictionary<IArchetype>; const Representations: IList<IRepresentation> );
begin
  inherited Create;
  fStream := Stream;
  fArchetypes := Archetypes;
  fRepresentations := Representations;
end;

destructor TJsonSerializer.Destroy;
begin
  fStream := nil;
  fArchetypes := nil;
  fRepresentations := nil;
  inherited Destroy;
end;

function TJsonSerializer.FindRepresentation( const Ref: IInterface; out FoundIdx: nativeuint ): boolean;
var
  idx: uint64;
  Obj: TObject;
  IdentAddress: nativeuint;
begin
  Result := False;
  if fRepresentations.Count = 0 then exit;
  Ref.QueryInterface( IInterface, Obj );
  if not Assigned( Obj ) then begin
    raise TStatus.CreateException( stIdentAddressUnresoved );
  end;
  IdentAddress := nativeuint.FromPointer( Obj );
  for idx := 0 to pred( fRepresentations.Count ) do begin
    if fRepresentations[ idx ].getIdentAddress = IdentAddress then begin
      FoundIdx := Idx;
      exit( true );
    end;
  end;
end;

function TJsonSerializer.SerializeReferenceMember( const PtrData: pointer; var Indent: nativeuint ): TStatus;
var
  Ref: IInterface;
  FoundIdx: nativeuint;
  List: IList< IInterface >;
  ChildIdx: nativeuint;
begin
  Ref := IInterface( ptrData^ );
  if not assigned( Ref ) then begin
    StreamWrite( 'null', 0 );
    exit( stSuccess );
  end;
  if Supports( Ref, IList< IInterface > ) then begin
    List := ( Ref as IList< IInterface > );
    for ChildIdx := 0 to pred( List.Count ) do begin
      if not FindRepresentation( List[ ChildIdx ], FoundIdx ) then exit( stUnidentifiedListItemReference );
      if ChildIdx = 0 then begin
        StreamWriteLn( '{' , 0 );
      end else begin
        StreamWriteLn( '{' , Indent );
      end;
      inc( Indent, cIndentSize );
      Result := SerializeRepresentation( fRepresentations[ FoundIdx ], FoundIdx, Indent );
      if not Result then exit;
      dec( Indent, cIndentSize );
      if ChildIdx < pred( List.Count ) then begin
        StreamWriteLn( '},' , Indent );
      end else begin
        StreamWriteLn( '}' , Indent );
      end;
    end;
  end else begin
    if not FindRepresentation( Ref, FoundIdx ) then exit( stUnidentifiedListItemReference );
    StreamWriteLn( '{' , Indent );
    inc( Indent, cIndentSize );
    Result := SerializeRepresentation( fRepresentations[ FoundIdx ], FoundIdx, Indent );
    if not Result then exit;
    dec( Indent, cIndentSize );
    StreamWriteLn( '}' , Indent );
  end;
end;

function TJsonSerializer.SerializeRepresentation( const Representation: IRepresentation; const Index: nativeuint; var Indent: nativeuint ): TStatus;
var
  Archetype: IArchetype;
  ArchetypeMember: IArchetypeMember;
  BaseAddress: nativeuint;
  PtrData: pointer;
  MemberIdx: nativeuint;
begin
  Archetype := fArchetypes[ Representation.getArchetypeID ];
  BaseAddress := (Representation.getStorage as IInternalStorage).getBase;
  //- Write archetype name
  StreamWriteLn( '"archetype": "' + Archetype.getDisplayName + '"' , Indent );
  //- Write members
  if Archetype.Members.Count = 0 then begin
    StreamWriteLn( '"members": []' , Indent );
    exit( stSuccess );
  end;
  StreamWriteLn( '"members": [' , Indent );
  inc( Indent, cIndentSize );
  for MemberIdx := 0 to pred( Archetype.Members.Count ) do begin
    ArchetypeMember := Archetype.Members[ MemberIdx ];
    StreamWrite( '"' + ArchetypeMember.DisplayName + '": ', Indent );
    PtrData := nativeuint( BaseAddress - ArchetypeMember.Offset ).AsPointer;
    case ArchetypeMember.DataType of
      mtBoolean   : if boolean( PtrData^ ) then StreamWriteLn( 'true', 0 ) else StreamWriteLn( 'false', 0 );
      mtInt8      : StreamWriteLn( int8( PtrData^ ).AsString, 0 );
      mtInt16     : StreamWriteLn( int16( PtrData^ ).AsString, 0 );
      mtInt32     : StreamWriteLn( int32( PtrData^ ).AsString, 0 );
      mtInt64     : StreamWriteLn( int64( PtrData^ ).AsString, 0 );
      mtUInt8     : StreamWriteLn( uint8( PtrData^ ).AsString, 0 );
      mtUInt16    : StreamWriteLn( uint16( PtrData^ ).AsString, 0 );
      mtUInt32    : StreamWriteLn( uint32( PtrData^ ).AsString, 0 );
      mtUInt64    : StreamWriteLn( uint64( PtrData^ ).AsString, 0 );
      mtSingle    : StreamWriteLn( single( PtrData^ ).AsString, 0 );
      mtDouble    : StreamWriteLn( double( PtrData^ ).AsString, 0 );
      mtGUID      : StreamWriteLn( Tguid( PtrData^ ).AsString, 0 );
      mtString    : StreamWriteLn( '"' + string( PtrData^ ) + '"', 0 );
      mtReference : begin
        Result := SerializeReferenceMember( PtrData, Indent );
        if not Result then exit;
      end;
    end;
  end;
  dec( Indent, cIndentSize );
  StreamWriteLn( ']' , Indent );
  fDone[ Index ] := True;
  Result := stSuccess;
end;

function TJsonSerializer.Serialize: TStatus;
var
  Indent: nativeuint;
  idx: nativeuint;
  idy: nativeuint;
  DoneCount: nativeuint;
begin
  if fRepresentations.Count = 0 then begin
    Stream.WriteString( '{' + CR + LF + '}', TUnicodeFormat.utf8, False );
    exit( stSuccess );
  end;
  SetLength( fDone, fRepresentations.Count );
  for idx := 0 to pred( fRepresentations.Count ) do begin
    if fDone[ idx ] then continue;
    StreamWrite( '{', Indent );
    inc( Indent, cIndentSize );
    Result := SerializeRepresentation( fRepresentations[ idx ], Idx, Indent );
    if not Result then exit;
    dec( Indent, cIndentSize );
    DoneCount := 0;
    for idy := 0 to pred( Length( fDone ) ) do begin
      if fDone[ idy ] then inc( DoneCount );
    end;
    if DoneCount < fRepresentations.Count then begin
      StreamWriteLn( '},', Indent );
    end else begin
      StreamWriteLn( '}', Indent );
    end;
  end;
end;

function TJsonSerializer.Stream: IUnicodeStream;
begin
  Result := fStream;
end;

procedure TJsonSerializer.StreamWrite( const S: string; const Indent: nativeuint );
var
  W: string;
  idx: nativeuint;
begin
  W := '';
  if Indent > 0 then begin
    for idx := 0 to pred( Indent ) do W := W + ' ';
  end;
  W := W + S;
  fStream.WriteString( W, TUnicodeFormat.utf8, False );
end;

procedure TJsonSerializer.StreamWriteLn( const S: string; const Indent: nativeuint );
begin
  StreamWrite( S + CR + LF, Indent );
end;

end.
