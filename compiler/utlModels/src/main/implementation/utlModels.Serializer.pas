(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlModels.Serializer;

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
  (* Manages the serialization of a model instance. *)
  ISerializer = interface
    ['{0788F47D-7DDF-408F-AB37-3805E88D255E}']

    (* Finds the index for a representation when given it's reference *)
    function FindRepresentation( const Ref: IInterface; out FoundIdx: uint64 ): boolean;

    (* Serializes an instance using the stream and data provided in the constructor *)
    function Serialize: TStatus;

    (* Returns a reference to the stream for directly serializing data, IStorage uses this to serialize it's self. *)
    function Stream: IStream;

    (* Adds a string to the serializers internal string table, and returns the string index. *)
    function AddString( const value: string ): uint64;
  end;

type
  TSerializer = class( TInterfacedObject, ISerializer )
  private
    fStream: IStream;
    fArchetypes: IReadOnlyGuidDictionary< IArchetype >;
    fRepresentations: IList< IRepresentation >;
    fStringTable: IList< string >;
    fStringTableOffsetLocation: nativeuint; // not the offset of the string table, but the offset of the header field for it.
  private //- String table -//
    function FindString( const Value: string; out FoundIdx: uint64 ): boolean;
  private //- Serializing -//
    function SerializeArchetypeMember( const ArchetypeMember: IArchetypeMember ): TStatus;
    function SerializeArchetype( const Archetype: IArchetype ): TStatus;
    function SerializeArchetypes(): TStatus;
    function SerializeRepresentations(): TStatus;
    function SerializeHeader: TStatus;
    function SerializeStringTable: TStatus;
    function SerializeStorage( const Storage: IStorage; const Archetype: IArchetype ): TStatus;
    function SerializeBooleanMember( const PtrData: pointer ): TStatus;
    function SerializeReferenceMember( const PtrData: pointer; const MemberType: TArchetypeMemberType ): TStatus;
    function SerializeStringMember( const PtrData: pointer ): TStatus;
    function SerializeReferenceListMember( const PtrData: pointer ): TStatus;
    function SerializeStringListMember( const PtrData: pointer ): TStatus;
    function SerializeStreamMember( const PtrData: pointer ): TStatus;
    function SerializeCursorMember( const PtrData: pointer ): TStatus;
    function SerializeCursor( const Representation: IRepresentation ): TStatus;
  strict private //- ISerializer -//
    function Stream: IStream;
    function Serialize: TStatus;
    function AddString( const value: string ): uint64;
    function FindRepresentation( const Ref: IInterface; out FoundIdx: uint64 ): boolean;
  public
    constructor Create( const Stream: IStream; const Archetypes: IReadOnlyGuidDictionary< IArchetype >; const Representations: IList< IRepresentation > ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  SysUtils
, utlTypes
, utlLexers
, utlModels.Storage
;

const
  cSignature : uint64 = $cacdabadedabadae;

function TSerializer.FindRepresentation( const Ref: IInterface; out FoundIdx: uint64 ): boolean;
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
      FoundIdx := idx;
      exit( true );
    end;
  end;
end;

function TSerializer.FindString( const Value: string; out FoundIdx: uint64 ): boolean;
var
  idx: uint64;
begin
  Result := False;
  if fStringTable.Count = 0 then exit;
  for idx := 0 to pred( fStringTable.Count ) do begin
    if fStringTable[ idx ] = Value then begin
      FoundIdx := idx;
      exit( true );
    end;
  end;
end;
function TSerializer.AddString( const value: string ): uint64;
var
  FoundIdx: uint64;
begin
  if FindString( value, FoundIdx ) then exit( FoundIdx );
  FoundIdx := fStringTable.Count;
  fStringTable.Add( value );
  Result := FoundIdx;
end;

function TSerializer.SerializeStringMember( const PtrData: pointer ): TStatus;
var
  Index: uint64;
begin
  Index := AddString( string( PtrData^ ) );
  Result := Stream.Write( Index );
end;

function TSerializer.SerializeBooleanMember( const PtrData: pointer ): TStatus;
var
  i8: int8;
begin
  if boolean( PtrData^ ) then i8 := 0 else i8 := -1;
  Result := Stream.Write( i8 );
end;

function TSerializer.SerializeStringListMember( const PtrData: pointer ): TStatus;
var
  idx: uint64;
  ItemCount: uint64;
  StringIndex: uint64;
  SL: IList< string >;
  bool: uint8;
begin
  SL := IList< string >( ptrData^ );
  if assigned( SL ) then bool := 1 else bool := 0;
  Result := Stream.Write( bool );
  if not Result then exit;
  ItemCount := SL.Count;
  Result := Stream.Write( ItemCount );
  if not Result then exit;
  if ItemCount = 0 then exit( stSuccess );
  for idx := 0 to pred( SL.Count ) do begin
    StringIndex := AddString( SL[idx] );
    Result := Stream.Write( StringIndex );
    if not Result then exit;
  end;
end;

function TSerializer.SerializeReferenceListMember( const PtrData: pointer ): TStatus;
var
  idx: uint64;
  ItemCount: uint64;
  FoundIdx: uint64;
  Ref: IInterface;
  Item: IInterface;
  bool: uint8;
begin
  Ref := IInterface( ptrData^ );
  if assigned( Ref ) then bool := 1 else bool := 0;
  Result := Stream.Write( bool );
  if not Result then exit;
  ItemCount := ( Ref as IList< IInterface > ).Count;
  Result := Stream.Write( ItemCount );
  if not Result then exit;
  if ItemCount = 0 then exit( stSuccess );
  for idx := 0 to pred( ItemCount ) do begin
    Item := ( Ref as IList< IInterface > )[ idx ];
    if not FindRepresentation( Item, FoundIdx ) then exit( stUnidentifiedListItemReference );
    Result := Stream.Write( FoundIdx );
    if not Result then exit;
  end;
end;

function TSerializer.SerializeStreamMember( const PtrData: pointer ): TStatus;
var
  StorePos: nativeuint;
  Ref: IInterface;
  Size: uint64;
  bool: uint8;
begin
  Ref := IInterface( ptrData );
  if assigned( Ref ) then bool := 1 else bool := 0;
  Result := Stream.Write( bool );
  if not Result then exit;
  StorePos := (Ref as IUnicodeStream).Position;
  try
    (Ref as IUnicodeStream).Position := 0;
    Size := (Ref as IUnicodeStream).Size;
    Result := Stream.Write( Size );
    if not Result then exit;
    Stream.CopyFrom( (Ref as IUnicodeStream ) );
    Result := stSuccess;
  finally
    (Ref as IUnicodeStream).Position := StorePos;
  end;
end;

function TSerializer.SerializeCursorMember( const PtrData: pointer ): TStatus;
var
  Ref: IInterface;
  Index: uint64;
  Value: uint64;
  bool: uint8;
begin
  Ref := IInterface( ptrData );
  if assigned( Ref ) then bool := 1 else bool := 0;
  Result := Stream.Write( bool );
  if not Result then exit;
  Index := AddString( ( Ref as ICursor ).Filename );
  Result := Stream.Write( Index );
  if not Result then exit;
  Value := ( Ref as ICursor ).LineNumber;
  Result := Stream.Write( Value );
  if not Result then exit;
  Value := ( Ref as ICursor ).LinePosition;
  Result := Stream.Write( Value );
  if not Result then exit;
end;

function TSerializer.SerializeReferenceMember( const PtrData: pointer; const MemberType: TArchetypeMemberType ): TStatus;
var
  Ref: IInterface;
  FoundIdx: uint64;
  B: uint8;
begin
  // Determine the type of reference member and write a type flag.
  Ref := IInterface( ptrData^ );
  if not assigned( Ref ) then begin
    B := cReferenceType_Nil;
  end else if MemberType = mtStringList then begin
    B := cReferenceType_sList;
  end else if MemberType = mtCursor then begin
    B := cReferenceType_Cursor;
  end else if MemberType = mtUnicodeStream then begin
    B := cReferenceType_Stream
  end else if Supports( Ref, IList< IInterface > ) then begin
    B := cReferenceType_List;
  end else if FindRepresentation( Ref, FoundIdx ) then begin
    B := cReferenceType_Rep;
  end else begin
    exit( stUnidentifiedReference );
  end;
  Result := Stream.Write( B );
  if not Result then exit;
  //- Based on the reference type, write what needs to be written.
  case B of
    cReferenceType_Rep    : Result := Stream.Write( FoundIdx );
    cReferenceType_Stream : Result := SerializeStreamMember( ptrData );
    cReferenceType_sList  : Result := SerializeStringListMember( ptrData );
    cReferenceType_List   : Result := SerializeReferenceListMember( ptrData );
    cReferenceType_Cursor : Result := SerializeCursorMember( ptrData );
  end;
end;

function TSerializer.SerializeStorage( const Storage: IStorage; const Archetype: IArchetype ): TStatus;
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
      mtInt8          : Result := Stream.Write( int8( PtrData^ ) );
      mtInt16         : Result := Stream.Write( int16( PtrData^ ) );
      mtInt32         : Result := Stream.Write( int32( PtrData^ ) );
      mtInt64         : Result := Stream.Write( int64( PtrData^ ) );
      mtUInt8         : Result := Stream.Write( uint8( PtrData^ ) );
      mtUInt16        : Result := Stream.Write( uint16( PtrData^ ) );
      mtUInt32        : Result := Stream.Write( uint32( PtrData^ ) );
      mtUInt64        : Result := Stream.Write( uint64( PtrData^ ) );
      mtSingle        : Result := Stream.Write( single( PtrData^ ) );
      mtDouble        : Result := Stream.Write( double( PtrData^ ) );
      mtGUID          : Result := Stream.Write( TGUID( PtrData^ ) );
      mtBoolean       : Result := SerializeBooleanMember( PtrData );
      mtStringList    : Result := SerializeReferenceMember( PtrData, mtStringList );
      mtUnicodeStream : Result := SerializereferenceMember( PtrData, mtUnicodeStream );
      mtReference     : Result := SerializeReferenceMember( PtrData, mtReference );
      mtString        : Result := SerializeStringMember( PtrData );
      else raise TStatus.CreateException( stUnrecognizedDataTypeInStorage );
    end;
    {$endregion}
    if not Result then exit;
  end;
end;

constructor TSerializer.Create( const Stream: IStream; const Archetypes: IReadOnlyGuidDictionary< IArchetype >; const Representations: IList< IRepresentation > );
begin
  inherited Create;
  fStream := Stream;
  fArchetypes := Archetypes;
  fRepresentations := Representations;
  fStringTable := TList< string >.Create;
end;

destructor TSerializer.Destroy;
begin
  fStringTable := nil;
  fRepresentations := nil;
  fArchetypes := nil;
  fStream := nil;
  inherited Destroy;
end;

function TSerializer.SerializeHeader: TStatus;
var
  StringTableOffset: uint64;
begin
  // Write header signature.
  Result := fStream.Write( cSignature );
  if not Result then exit;
  // Write space for string table offset.
  fStringTableOffsetLocation := fStream.Position;
  StringTableOffset := 0;
  Result := fStream.Write( StringTableOffset );
end;

function TSerializer.Serialize: TStatus;
begin
  // Write a simple header
  Result := SerializeHeader;
  if not Result then exit;
  // Write the Archetypes.
  Result := SerializeArchetypes;
  if not Result then exit;
  // Write Representations
  Result := SerializeRepresentations;
  if not Result then exit;
  // Now serialize the string table.
  Result := SerializeStringTable;
end;

function TSerializer.SerializeArchetypeMember( const ArchetypeMember: IArchetypeMember ): TStatus;
begin
  // Write the display name of this member
  Result := fStream.Write( ArchetypeMember.DisplayName );
  if not Result then exit;
  // Write the data-type of this member.
  Result := fStream.Write( uint16( ArchetypeMember.DataType ) );
  if not Result then exit;
  // Write the offset of this member.
  Result := fStream.Write( ArchetypeMember.Offset );
end;

function TSerializer.SerializeArchetype( const Archetype: IArchetype ): TStatus;
var
  Member: IArchetypeMember;
begin
  // Write the Archetype ID
  Result := fStream.Write( Archetype.ArchetypeID );
  if not Result then exit;
  // Write the display name of the archetype.
  Result := fStream.Write( Archetype.getDisplayName );
  if not Result then exit;
  // Write the number of Archetype members.
  Result := fStream.Write( Archetype.Members.Count );
  if not Result then exit;
  // Write each member
  for Member in Archetype.Members do begin
    Result := SerializeArchetypeMember( Member );
    if not Result then exit;
  end;
end;

function TSerializer.SerializeArchetypes: TStatus;
var
  Archetype: IArchetype;
begin
  // Write the number of archetypes.
  Result := fStream.Write( fArchetypes.Count );
  if not Result then exit;
  // Write the archetypes
  for Archetype in fArchetypes.Values do begin
    Result := SerializeArchetype( Archetype );
    if not Result then exit;
  end;
end;

function TSerializer.SerializeCursor( const Representation: IRepresentation ): TStatus;
var
  b: uint8;
  Instance: IInterface;
  Index: uint64;
  Value: uint64;
begin
  Instance := Representation.getRepresentationInstance;
  // For representations that do not support a cursor, write a zero and exit.
  if not Supports( Instance, IHasCursor ) then begin
    b := 0;
    Result := Stream.Write( b );
    exit( stSuccess );
  end;
  // If we do support the cursor, write a 1 to indicate its presence.
  b := 1;
  Result := Stream.Write( b );
  if not Result then exit;
  // Add the cursor filename string to the stringlist.
  Index := AddString( ( Instance as IHasCursor ).Cursor.Filename );
  Result := Stream.Write( Index );
  if not Result then exit;
  // Now add the line number / line position.
  Value := ( Instance as IHasCursor ).Cursor.LineNumber;
  Result := Stream.Write( Value );
  if not Result then exit;
  Value := ( Instance as IHasCursor ).Cursor.LinePosition;
  Result := Stream.Write( Value );
end;

function TSerializer.SerializeRepresentations: TStatus;
var
  Representation: IRepresentation;
begin
  // Serialize number of representations
  Result := fStream.Write( fRepresentations.Count );
  if not Result then exit;
  // For each representation, serialize the archetype ID, then its storage.
  for Representation in fRepresentations do begin
    // Archetype first
    Result := fStream.Write( Representation.getArchetypeID );
    if not Result then exit;
    // Serialize the cursor information.
    Result := SerializeCursor( Representation );
    if not Result then exit;
    // Now serialize storage
    Result := SerializeStorage( Representation.getStorage, fArchetypes[ Representation.getArchetypeID ] );
    if not Result then exit;
  end;
end;

function TSerializer.SerializeStringTable: TStatus;
var
  StringTableOffset: uint64;
  StringCount: uint64;
  S: string;
begin
  // First take offset to string table, we need to return to the
  // header to replace it.
  StringTableOffset := fStream.Position;
  // Now serialize number of strings.
  StringCount := fStringTable.Count;
  Result := fStream.Write( StringCount );
  if not Result then exit;
  // And serialize the strings.
  if StringCount > 0 then begin
    for S in fStringTable do begin
      Result := fStream.Write( S );
      if not Result then exit;
    end;
  end;
  // Finally, return to the string-table-offset location in the header,
  // and write the offset to the string table there.
  fStream.Position := fStringTableOffsetLocation;
  fStream.Write( StringTableOffset );
end;

function TSerializer.Stream: IStream;
begin
  Result := fStream;
end;

end.
