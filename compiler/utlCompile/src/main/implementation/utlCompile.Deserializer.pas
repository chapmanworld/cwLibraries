(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCompile.Deserializer;

interface
uses
  utlStatus
, utlIO
, utlCollections
, utlCompile
, utlCompile.Archetype
, utlCompile.ArchetypeMember
, utlCompile.Representation
, utlCompile.Reflection
;

type
  (* Enables the deserializer to instance representations from an archetype. *)
  TCreateRepresentationCallback = function ( const ArchetypeID: TGUID ): IRepresentation of object;

type
  (* Manages the deserialization of a model instance. *)
  IDeserializer = interface
    ['{E49764BA-9F38-44EC-9B29-1A14392EB3D0}']

    (* Used during initialization to insert a pointer to an interface referece,
       and an index, into a list to be resolved after all representations are
       loaded. *)
    procedure AddResolveReference( const PtrReference: pointer; const idx: uint64 );

    (* Same as AddResolveReference, except that this method inserts an index
       to be resolved into a reference list. *)
    procedure AddResolveListItem( const PtrList: pointer; const idx: uint64 );

    (* Returns a string from the string table by index. *)
    function GetString( const Index: uint64; out S: string ): TStatus;

    (* Deserializes an instance using the stream and data provided in the constructor *)
    function Deserialize: TStatus;

    (* Returns a reference to the stream for directly deserializing data, IStorage uses this to deserialize it's self. *)
    function Stream: IStream;
  end;

type
  // Used internally to resolve references after the representations are all loaded
  TResolveType = ( rtReference, rtListItem );
  // Used internally to resolve references after the representations are all loaded
  TResolveRecord = record
    ResolveType: TResolveType;
    ResolvePtr: pointer;
    ResolveIdx: uint64;
  end;
  // Used internally to resolve cursors
  TCursorResolveRecord = record
    Instance: IInterface;
    FilenameIndex: uint64;
    LineNumber: uint64;
    LinePosition: uint64;
  end;

type
  TDeserializer = class( TInterfacedObject, IDeserializer )
  private
    fStream: IStream;
    fCreateRepresentation: TCreateRepresentationCallback;
    fStringTable: IList< string >;
    fArchetypes: IReadOnlyGuidDictionary< IArchetype >;
    fRepresentations: IList< IRepresentation >;
    fResolvers: IList< TResolveRecord >;
    fCursorResolvers: IList< TCursorResolveRecord >;
  private
    function ResolveReferences: TStatus;
    function ResolveCursors: TStatus;
  private
    function DeserializeArchetypes: TStatus;
    function DeserializeStringTable: TStatus;
    function DeserializeHeader: TStatus;
    function DeserializeRepresentations: TStatus;
    function DeserializeArchetype( const ValidateAgainst: IArchetype ): TStatus;
    function DeserializeArchetypeMember( const ValidateAgainst: IArchetypeMember ): TStatus;
    function DeserializeStorage( const Storage: IStorage; const Archetype: IArchetype ): TStatus;
    function DeserializeBooleanMember( const PtrData: pointer ): TStatus;
    function DeserializeReferenceMember( const PtrData: pointer ): TStatus;
    function DeserializeStringMember( const PtrData: pointer ): TStatus;
    function DeserializeListMember( const PtrData: pointer ): TStatus;
    function DeserializeRepresentationMember( const PtrData: pointer ): TStatus;
    function DeserializeStringListMember( const PtrData: pointer ): TStatus;
    function DeserializeStreamMember( const PtrData: pointer ): TStatus;
    function DeserializeCursorMember( const PtrData: pointer ): TStatus;
    function DeserializeCursor( const Representation: IRepresentation ): TStatus;
  strict private //- IDeserializer -//
    procedure AddResolveReference( const PtrReference: pointer; const idx: uint64 );
    procedure AddResolveListItem( const PtrList: pointer; const idx: uint64 );
    function GetString( const Index: uint64; out S: string ): TStatus;
    function DeSerialize: TStatus;
    function Stream: IStream;
  public
    constructor Create( const Stream: IStream; const Archetypes: IReadOnlyGuidDictionary< IArchetype >; const Representations: IList< IRepresentation >; const CreateRepresentation: TCreateRepresentationCallback ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  SysUtils
, utlTypes
, utlCompile.Cursor
, utlCompile.ModelStorage
;

const
  cSignature : uint64 = $cacdabadedabadae;

procedure TDeserializer.AddResolveListItem( const PtrList: pointer; const idx: uint64 );
var
  ResolveRecord: TResolveRecord;
begin
  ResolveRecord.ResolveType := rtListItem;
  ResolveRecord.ResolvePtr := PtrList;
  ResolveRecord.ResolveIdx := idx;
  fResolvers.Add( ResolveRecord );
end;

procedure TDeserializer.AddResolveReference( const PtrReference: pointer; const idx: uint64 );
var
  ResolveRecord: TResolveRecord;
begin
  ResolveRecord.ResolveType := rtReference;
  ResolveRecord.ResolvePtr := PtrReference;
  ResolveRecord.ResolveIdx := idx;
  fResolvers.Add( ResolveRecord );
end;

constructor TDeserializer.Create( const Stream: IStream; const Archetypes: IReadOnlyGuidDictionary< IArchetype >; const Representations: IList< IRepresentation >; const CreateRepresentation: TCreateRepresentationCallback );
begin
  inherited Create;
  fStream := Stream;
  fStringTable := TList< string >.Create;
  fArchetypes := Archetypes;
  fRepresentations := Representations;
  fCreateRepresentation := CreateRepresentation;
  fResolvers := TList< TResolveRecord >.Create;
  fCursorResolvers := TList< TCursorResolveRecord >.Create;
end;

destructor TDeserializer.Destroy;
begin
  fCursorResolvers := nil;
  fResolvers := nil;
  fStringTable := nil;
  fRepresentations := nil;
  fArchetypes := nil;
  fStream := nil;
  inherited Destroy;
end;

function TDeserializer.GetString( const Index: uint64; out S: string ): TStatus;
begin
  S := '';
  if Index >= fStringTable.Count then exit( stInvalidStringIndex );
  S := fStringTable[ Index ];
  Result := stSuccess;
end;

function TDeserializer.ResolveCursors: TStatus;
var
  ResolveRecord: TCursorResolveRecord;
  NewCursor: ICursor;
begin
  for ResolveRecord in fCursorResolvers do begin
    NewCursor := TCursor.Create( fStringTable[ ResolveRecord.FilenameIndex ], ResolveRecord.LineNumber, ResolveRecord.LinePosition );
    ( ResolveRecord.Instance as IHasCursor ).Cursor.Assign( NewCursor );
  end;
end;

function TDeserializer.ResolveReferences: TStatus;
var
  Ref: IInterface;
  ResolveRecord: TResolveRecord;
  Resolved: IInterface;
begin
  if fResolvers.Count = 0 then exit( stSuccess );
  for ResolveRecord in fResolvers do begin
    if ResolveRecord.ResolveIdx >= fRepresentations.Count then exit( stInvalidResolveIndex );
    Resolved := fRepresentations[ ResolveRecord.ResolveIdx ].getRepresentationInstance;
    case ResolveRecord.ResolveType of

      rtReference: begin
        IInterface( ResolveRecord.ResolvePtr^ ) := Resolved;
      end;

      rtListItem: begin
        Ref := IInterface( ResolveRecord.ResolvePtr^ );
        ( Ref as IList< IInterface > ).Add( Resolved );
      end

      else exit( stMalformedResolveTable );
    end;
  end;
end;

function TDeserializer.DeserializeArchetypeMember( const ValidateAgainst: IArchetypeMember ): TStatus;
var
  u16: uint16;
  DisplayName: string;
  DataType: TArchetypeMemberType;
  Offset: uint64;
begin
  // Validate the display name (necessary?)
  Result := fStream.Read( DisplayName );
  if not Result then exit;
  if DisplayName <> ValidateAgainst.DisplayName then exit( stArchetypeMemberDisplayNameMissmatch );
  // Validate the data type.
  Result := fStream.Read( u16 );
  if not Result then exit;
  DataType := TArchetypeMemberType( u16 );
  if DataType <> ValidateAgainst.DataType then exit( stArchetypeMemberDataTypeMissmatch );
  // Validate the offset
  Result := fStream.Read( Offset );
  if not Result then exit;
  if Offset <> ValidateAgainst.Offset then exit( stArchetypeMemberOffsetMissmatch );
end;

function TDeserializer.DeserializeArchetype( const ValidateAgainst: IArchetype ): TStatus;
var
  ArchetypeID: TGUID;
  ArchetypeMemberCount: uint64;
  Member: IArchetypeMember;
  DisplayName: string;
begin
  // Validate the archetype ID
  Result := fStream.Read( ArchetypeID );
  if not Result then exit;
  if not ArchetypeID.EqualTo( ValidateAgainst.ArchetypeID ) then exit( stArchetypeIDMissmatch );
  // Validate the archetype display name
  Result := fStream.Read( DisplayName );
  if not Result then exit;
  if DisplayName <> ValidateAgainst.getDisplayName then exit( stArchetypeDisplayNameMissmatch );
  // Validate the member count.
  Result := fStream.Read( ArchetypeMemberCount );
  if not Result then exit;
  if ArchetypeMemberCount <> ValidateAgainst.Members.Count then exit( stArchetypeMemberCountMissmatch );
  // Loop every member and validate it.
  for Member in ValidateAgainst.Members do begin
    Result := DeserializeArchetypeMember( Member );
    if not Result then exit;
  end;
end;

function TDeserializer.DeserializeArchetypes: TStatus;
var
  ArchetypeCount: uint64;
  Archetype: IArchetype;
begin
  // Read the number of archetypes.
  Result := fStream.Read( ArchetypeCount );
  if not Result then exit;
  if ArchetypeCount <> fArchetypes.Count then exit( stArchetypeCountMissmatch );
  // Validate each archetype.
  for Archetype in fArchetypes.Values do begin
    Result := DeserializeArchetype( Archetype );
    if not Result then exit;
  end;
end;

function TDeserializer.DeserializeHeader: TStatus;
var
  Signature: uint64;
  CurrentLocation: nativeuint;
  StringTableLocation: uint64;
begin
  // Read and validate signature.
  Result := fStream.Read( Signature );
  if not Result then exit;
  if Signature <> cSignature then exit( stSignatureInvalid );
  // Read the string table location, read the string table.
  Result := fStream.Read( StringTableLocation );
  if not Result then exit;
  CurrentLocation := fStream.Position;
  fStream.Position := StringTableLocation;
  Result := DeserializeStringTable;
  if not Result then exit;
  fStream.Position := CurrentLocation;
end;

function TDeserializer.DeserializeBooleanMember( const PtrData: pointer ): TStatus;
var
  i8: int8;
begin
  Result := Stream.Read( i8 );
  if not Result then exit;
  if ( i8 <> 0 ) and ( i8 <> -1 ) then exit( stStorageInvalidBooleanData );
  boolean( PtrData^ ) := i8 = 0;
end;

function TDeserializer.DeserializeRepresentationMember( const PtrData: pointer ): TStatus;
var
  RefIdx: uint64;
  bool: uint8;
begin
  Result := Stream.Read( bool );
  if not Result then exit;
  if bool <> 1 then begin
    IInterface( PtrData^ ) := nil;
    exit( stSuccess );
  end;
  Result := Stream.Read( RefIdx );
  if not Result then exit;
  AddResolveReference( PtrData, RefIdx );
  Result := stSuccess;
end;

function TDeserializer.DeserializeStringListMember( const PtrData: pointer ): TStatus;
var
  ItemCount: uint64;
  StringIndex: uint64;
  SL: IList< string >;
  S: string;
  idx: uint64;
  bool: uint8;
begin
  Result := Stream.Read( bool );
  if not Result then exit;
  if bool <> 1 then begin
    IInterface( PtrData^ ) := nil;
    exit( stSuccess );
  end;
  Result := Stream.Read( ItemCount );
  if not Result then exit;
  if ItemCount = 0 then exit( stSuccess );
  SL := IInterface( PtrData^ ) as IList< string >;
  SL.Clear;
  for idx := 0 to pred( ItemCount ) do begin
    Result := Stream.Read( StringIndex );
    if not Result then exit;
    GetString( StringIndex, S );
    SL.Add( S );
  end;
end;

function TDeserializer.DeserializeListMember( const PtrData: pointer ): TStatus;
var
  RefIdx: uint64;
  ItemCount: uint64;
  idx: uint64;
  bool: uint8;
begin
  Result := Stream.Read( bool );
  if not Result then exit;
  if bool <> 1 then begin
    IInterface( PtrData^ ) := nil;
    exit( stSuccess );
  end;
  Result := Stream.Read( ItemCount );
  if not Result then exit;
  if ItemCount = 0 then exit( stSuccess );
  for idx := 0 to pred( ItemCount ) do begin
    Result := Stream.Read( RefIdx );
    if not Result then exit;
    AddResolveListItem( PtrData, RefIdx );
  end;
end;

function TDeserializer.DeserializeStreamMember( const PtrData: pointer ): TStatus;
var
  Ref: IInterface;
  Size: uint64;
  Remaining: nativeuint;
  MaxBytes: nativeuint;
  ReadBytes: nativeuint;
  Buffer: array[ 0..511 ] of uint8;
  bool: uint8;
begin
  Result := Stream.Read( bool );
  if not Result then exit;
  if bool <> 1 then begin
    IInterface( PtrData^ ) := nil;
    exit( stSuccess );
  end;
  Ref := IInterface( ptrData );
  (Ref as IUnicodeStream).Clear;
  Result := Stream.Read( Size );
  if not Result then exit;
  Remaining := Size;
  repeat
    MaxBytes := Length( Buffer );
    if MaxBytes > Remaining then MaxBytes := Remaining;
    ReadBytes := Stream.Read( @Buffer[ 0 ], MaxBytes );
    if ReadBytes <> MaxBytes then exit( stStreamReadError );
    Remaining := Remaining - ReadBytes;
  until Remaining = 0;
  Result := stSuccess;
end;

function TDeserializer.DeserializeCursorMember( const PtrData: pointer ): TStatus;
var
  Ref: IInterface;
  Filename: string;
  LineNumber: uint64;
  LinePosition: uint64;
  NewCursor: ICursor;
  bool: uint8;
  Index: uint64;
begin
  Result := Stream.Read( bool );
  if not Result then exit;
  if bool <> 1 then begin
    IInterface( PtrData^ ) := nil;
    exit( stSuccess );
  end;
  Result := Stream.Read( Index );
  if not Result then exit;
  Result := GetString( Index, Filename );
  if not Result then exit;
  Result := Stream.Read( LineNumber );
  if not Result then exit;
  Result := Stream.Read( LinePosition );
  if not Result then exit;
  NewCursor := TCursor.Create( FileName, LineNumber, LinePosition );
  try
    ( Ref as ICursor ).Assign( NewCursor );
  finally
    NewCursor := nil;
  end;
end;

function TDeserializer.DeserializeReferenceMember( const PtrData: pointer ): TStatus;
var
  B: uint8;
begin
  // Read in the reference type.
  Result := Stream.Read( B );
  if not Result then exit;
  // Act based on reference type.
  case B of
    cReferenceType_Nil: begin
      pointer( PtrData^ ) := nil;
      Result := stSuccess;
    end;
    cReferenceType_Rep    : Result := DeserializeRepresentationMember( PtrData );
    cReferenceType_Stream : Result := DeserializeStreamMember( PtrData );
    cReferenceType_sList  : Result := DeserializeStringListMember( PtrData );
    cReferenceType_List   : Result := DeserializeListMember( PtrData );
    else Result := stUnidentifiedReferenceMemberType;
  end;
end;

function TDeserializer.DeserializeStringMember( const PtrData: pointer ): TStatus;
var
  Index: uint64;
  S: string;
begin
  Result := Stream.Read( Index );
  if not Result then exit;
  Result := GetString( Index, S );
  if not Result then exit;
  string( PtrData^ ) := S;
end;

function TDeserializer.DeserializeStorage( const Storage: IStorage; const Archetype: IArchetype ): TStatus;
var
  PtrData: pointer;
  ArchetypeMember: IArchetypeMember;
  BaseAddress: nativeuint;
begin
  BaseAddress := ( Storage as IInternalStorage ).getBase;
  for ArchetypeMember in Archetype.Members do begin
    PtrData := nativeuint( BaseAddress - ArchetypeMember.Offset ).AsPointer;
    {$region ' Serialize the data '}

    case ArchetypeMember.DataType of
      mtInt8       : Result := Stream.Read( int8( PtrData^ ) );
      mtInt16      : Result := Stream.Read( int16( PtrData^ ) );
      mtInt32      : Result := Stream.Read( int32( PtrData^ ) );
      mtInt64      : Result := Stream.Read( int64( PtrData^ ) );
      mtUInt8      : Result := Stream.Read( uint8( PtrData^ ) );
      mtUInt16     : Result := Stream.Read( uint16( PtrData^ ) );
      mtUInt32     : Result := Stream.Read( uint32( PtrData^ ) );
      mtUInt64     : Result := Stream.Read( uint64( PtrData^ ) );
      mtSingle     : Result := Stream.Read( single( PtrData^ ) );
      mtDouble     : Result := Stream.Read( double( PtrData^ ) );
      mtGUID       : Result := Stream.Read( TGUID( PtrData^ ) );
      mtBoolean    : Result := DeserializeBooleanMember( PtrData );
      mtReference  : Result := DeserializeReferenceMember( PtrData );
      mtStringList : Result := DeserializeReferenceMember( PtrData ); // stream contains data-type flag.
      mtString     : Result := DeserializeStringMember( PtrData );
      else raise TStatus.CreateException( stUnrecognizedDataTypeInStorage );
    end;

    {$endregion}
    if not Result then exit;
  end;
end;

function TDeserializer.DeserializeCursor( const Representation: IRepresentation ): TStatus;
var
  b: uint8;
  ResolveRecord: TCursorResolveRecord;
  Instance: IInterface;
  FilenameIndex: uint64;
  LineNumber: uint64;
  LinePosition: uint64;
begin
  // Check for the presence of a cursor.
  Result := Stream.Read( b );
  if not Result then exit;
  if b = 0 then exit( stSuccess );
  // Check that the instance supports IHasCursor
  if not Supports( Instance, IHasCursor ) then exit( stCursorFoundButNotSupported );
  // Read the cursor information - note, it needs to be resolved later.
  Result := Stream.Read( FilenameIndex );
  if not Result then exit;
  Result := Stream.Read( LineNumber );
  if not Result then exit;
  Result := Stream.Read( LinePosition );
  if not Result then exit;
  // Add record to resolve cursor after string table is loaded.
  ResolveRecord.Instance := Representation.getRepresentationInstance;
  ResolveRecord.FilenameIndex := FilenameIndex;
  ResolveRecord.LineNumber := LineNumber;
  ResolveRecord.LinePosition := LinePosition;
  fCursorResolvers.Add( ResolveRecord );
  Result := stSuccess;
end;

function TDeserializer.DeserializeRepresentations: TStatus;
var
  ArchetypeID: TGUID;
  RepresentationCount: uint64;
  Representation: IRepresentation;
  idx: uint64;
begin
  fRepresentations.Clear;
  // Deserialize the number of representations
  Result := fStream.Read( RepresentationCount );
  if not Result then exit;
  if RepresentationCount = 0 then exit( stSuccess );
  // Deserialize each representation
  for idx := 0 to pred( RepresentationCount ) do begin
    // Deserialize the archetype ID
    Result := fStream.Read( ArchetypeID );
    if not Result then exit;
    // Instance the archetype as a representation...
    Representation := fCreateRepresentation( ArchetypeID );
    // Deserialize the cursor
    Result := DeserializeCursor( Representation );
    if not Result then exit;
    // Deserialize the storage
    Result := DeserializeStorage( Representation.getStorage, fArchetypes[ Representation.getArchetypeID ] );
    if not Result then exit;
  end;
end;

function TDeserializer.DeserializeStringTable: TStatus;
var
  StringCount: uint64;
  idx: uint64;
  S: string;
begin
  fStringTable.Clear;
  Result := fStream.Read( StringCount );
  if not Result then exit;
  if StringCount = 0 then exit( stSuccess );
  for idx := 0 to pred( StringCount ) do begin
    Result := fStream.Read( S );
    if not Result then exit;
    fStringTable.Add( S );
  end;
end;

function TDeserializer.Deserialize: TStatus;
begin
  // Read header ( validate sig and read string table )
  Result := DeserializeHeader;
  if not Result then exit;
  // Read and validate archetypes
  Result := DeserializeArchetypes;
  if not Result then exit;
  // Deserialize the representations
  Result := DeserializeRepresentations;
  if not Result then exit;
  // Resolve references
  Result := ResolveReferences;
  if not Result then exit;
  // Resolve cursors
  Result := ResolveCursors;
end;

function TDeserializer.Stream: IStream;
begin
  Result := fStream;
end;

end.

