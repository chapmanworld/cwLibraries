(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCompile.ModelStorage;

interface
uses
  utlStatus
, utlIO
, utlCollections
, utlCompile
, utlCompile.Serializer
, utlCompile.Deserializer
, utlCompile.Archetype
, utlCompile.ArchetypeMember
, utlCompile.Reflection
;

{$region ' IInternalStorage '}

(*
  These constants are shared by utlModels.Serializer and utlModels.Deserializer.
  Each unit uses this one in order to access IInternalStorage for the purposes
  of serializing or deserializing an IStorage instance. The following constants
  are required during the serialize and deserialize operations, and so this
  seemed like a convenient place to put them. They probably should have a unit
  of their own, and perhaps they'll move later.
*)
const
  cReferenceType_Nil    = $00;
  cReferenceType_List   = $01;
  cReferenceType_sList  = $02;
  cReferenceType_Stream = $03;
  cReferenceType_Rep    = $04;
  cReferenceType_Cursor = $05;

type
  (*
     Used to internally access otherwise private methods of our TStorage
     implementation by the IInstance, ISerializer and IDeserializer implementations.
  *)
  IInternalStorage = interface
    ['{979C3E8F-A31B-4E13-BADE-20FCDB219F27}']
    (*
       Accessed after construction of the representation, to migrate
       cached absolute member offsets, to relative offsets within the archetype.
    *)
    procedure GoRelative( const RepresentationInstance: IInterface );
    (* Returns the base address of the representation *)
    function getBase: nativeuint;
  end;

{$endregion}

{$region ' TStorage '}

type
  TCreateRepresentationCallback = function ( const ArchetypeID: TGUID ): IInterface of object;

type
  TStorage = class( TInterfacedObject, IStorage, IInternalStorage )
  private
    fAbsoluteMembers: IList< IArchetypeMember >;
    fArchetype: IArchetype;
    fBaseAddress: nativeuint;
    fCreateRepresentationCallback: TCreateRepresentationCallback;
  private
    procedure AddArchetypeMember( const MemberOffset: uint64; const DataType: TArchetypeMemberType; const DisplayName: string );
  strict private //- IInternalStorage -//
    procedure GoRelative( const RepresentationInstance: IInterface );
    function getBase: nativeuint;
  strict private //- IStorage -//
    function CreateRepresentation( const ArchetypeID: TGUID ): IInterface;
    procedure AddMember( const [ref] Member: string; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: uint8; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: uint16; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: uInt32; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: uInt64; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: int8; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: int16; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: int32; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: int64; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: TGUID; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: single; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: double; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: boolean; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: IInterface; const DisplayName: string ); overload;
    procedure AddMember( const [ref] Member: IList< string >; const DisplayName: string ); overload;
    procedure AddMember( const [Ref] Member: IUnicodeStream; const DisplayName: string ); overload;
    procedure AddMember( const [Ref] Member: ICursor; const DisplayName: string ); overload;
  public
    constructor Create( const Archetype: IArchetype; const CreateRepresentationCallback: TCreateRepresentationCallback ); reintroduce;
    destructor Destroy; override;
  end;

{$endregion}

implementation
uses
  SysUtils
, utlTypes
;

constructor TStorage.Create( const Archetype: IArchetype; const CreateRepresentationCallback: TCreateRepresentationCallback );
begin
  inherited Create;
  fBaseAddress := 0;
  fArchetype := Archetype;
  fAbsoluteMembers := TList< IArchetypeMember >.Create;
  fCreateRepresentationCallback := CreateRepresentationCallback;
end;

function TStorage.CreateRepresentation( const ArchetypeID: TGUID ): IInterface;
begin
  Result := nil;
  if not assigned( fCreateRepresentationCallback ) then exit;
  Result := fCreateRepresentationCallback( ArchetypeID );
end;

destructor TStorage.Destroy;
begin
  fAbsoluteMembers := nil;
  inherited;
end;

function TStorage.getBase: nativeuint;
begin
  Result := fBaseAddress;
end;

procedure TStorage.AddArchetypeMember( const MemberOffset: uint64; const DataType: TArchetypeMemberType; const DisplayName: string );
var
  AbsoluteMode: boolean;
  ArchetypeMember: IArchetypeMember;
begin
  AbsoluteMode := assigned( fAbsoluteMembers );
  ArchetypeMember := TArchetypeMember.Create( MemberOffset, DataType, DisplayName );
  if AbsoluteMode then begin
    fAbsoluteMembers.Add( ArchetypeMember );
  end else begin
    if not fArchetype.MemberExists( ArchetypeMember ) then begin
      fArchetype.AddMember( ArchetypeMember );
    end;
  end;
end;

procedure TStorage.GoRelative( const RepresentationInstance: IInterface );
var
  Obj: TObject;
  ArchetypeMember: IArchetypeMember;
begin
  if not assigned( fAbsoluteMembers ) then exit;
  // Get object base address and store away.
  RepresentationInstance.QueryInterface( fArchetype.ArchetypeID, Obj );
  if not Assigned( Obj ) then begin
    raise TStatus.CreateException( stArchetypeImplementationMissing, [ fArchetype.ArchetypeID.AsString ] );
  end;
  fBaseAddress := nativeuint.FromPointer( Obj );
  // Convert existing absolute members to relative.
  for ArchetypeMember in fAbsoluteMembers do begin
  // NOTE: Class fields are stored in the negative direction from the Obj reference pointer.
    ArchetypeMember.SetOffset( fBaseAddress - ArchetypeMember.Offset );
  end;
  // Copy absolute members into archetype.
  for ArchetypeMember in fAbsoluteMembers do begin
    if not fArchetype.MemberExists( ArchetypeMember ) then begin
      fArchetype.AddMember( ArchetypeMember );
    end;
  end;
  // Dispose the absolutes.
  fAbsoluteMembers := nil;
end;

procedure TStorage.AddMember( const [ref] Member: uint32; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtUint32, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: uint16; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtUInt16, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: uint8; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtUInt8, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: string; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtString, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: uint64; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtUInt64, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: int64; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtInt64, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: int32; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtInt32, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: int16; const DisplayName: string);
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtInt16, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: int8; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtInt8, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: single; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtSingle, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: double; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtDouble, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: IInterface; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtReference, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: boolean; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtBoolean, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: TGUID; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtGUID, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: IList< string >; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtStringList, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: IUnicodeStream; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtUnicodeStream, DisplayName );
end;

procedure TStorage.AddMember( const [ref] Member: ICursor; const DisplayName: string );
begin
  AddArchetypeMember( nativeuint.FromPointer( @Member ), mtCursor, DisplayName );
end;

end.
