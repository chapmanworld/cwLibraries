(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlModels.Instance;

interface
uses
  utlStatus
, utlIO
, utlModels
, utlCollections
, utlModels.Archetype
, utlModels.Representation
, utlModels.Reflection
;

type
  TInstance = class( TInterfacedObject, IModelInstance, IReflection )
  private
    fModelName: string;
    fArchetypes: IReadOnlyGuidDictionary< IArchetype >;
    fRepresentations: IList< IRepresentation >;
  private
    function CreateRepresentationInternal( const ArchetypeID: TGUID ): IRepresentation;
    function FindRepresentation( const RepresentationInstance: IInterface; out FoundIdx: nativeuint ): boolean;
    function FindArchetype( const ArchetypeID: TGUID ): IArchetype;
    function FindRepresentationByObjectReference( const Ref: IInterface; out FoundIdx: uint64 ): boolean;
  strict private //- IReflection -//
    function GetStorage( const RepresentationInstance: IInterface ): IStorage;
    function RepresentationInstances: IReadOnlyList< IInterface >;
    function Representations: IReadOnlyList< IInterface >;
    function ArchetypeOf( const Representation: IInterface ): IArchetype;
  strict private //- IModelInstance -//
    function FindFirst( const ArchetypeID: TGUID ): IInterface;
    function ModelName: string;
    function CreateRepresentation( const ArchetypeID: TGUID ): IInterface;
    function TransferRepresentation( const SourceModelInstance: IModelInstance; const RepresentationInstance: IInterface ): IInterface;
    procedure RemoveRepresentation( const RepresentationInstance: IInterface );
    function Serialize( const TargetStream: IStream ): TStatus;
    function Deserialize( const SourceStream: IStream ): TStatus;
    function SerializeJson( const TargetStream: IUnicodeStream ): TStatus;
  public
    constructor Create( const ModelName: string; const Archetypes: IReadOnlyGuidDictionary< IArchetype > ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlTypes
, utlUnicode
, utlModels.Storage
, utlModels.Serializer
, utlModels.Deserializer
, utlModels.JsonSerializer
;

function TInstance.FindRepresentationByObjectReference( const Ref: IInterface; out FoundIdx: uint64 ): boolean;
var
  idx: uint64;
  Obj: TObject;
  IdentAddress: nativeuint;
begin
  Result := False;
  if not assigned( Ref ) then exit;
  if fRepresentations.Count = 0 then exit;
  Ref.QueryInterface( IInterface, Obj );
  if not assigned( Obj ) then begin
    raise TStatus.CreateException( stIdentAddressUnresoved );
  end;
  IdentAddress := nativeuint.FromPointer( Obj );
  for idx := 0 to pred( fRepresentations.Count ) do begin
    if ( fRepresentations[ idx ] as IRepresentation ).getIdentAddress = IdentAddress then begin
      FoundIdx := idx;
      exit( true );
    end;
  end;
end;

function TInstance.ArchetypeOf( const Representation: IInterface ): IArchetype;
var
  FoundIdx: nativeuint;
  ArchetypeID: TGUID;
begin
  if not FindRepresentation( Representation, FoundIdx ) then exit;
  ArchetypeID := fRepresentations[ FoundIdx ].getArchetypeID;
  Result := FindArchetype( ArchetypeID );
end;

constructor TInstance.Create( const ModelName: string; const Archetypes: IReadOnlyGuidDictionary< IArchetype > );
begin
  inherited Create;
  fModelName := ModelName;
  fArchetypes := Archetypes;
  fRepresentations := TList< IRepresentation >.Create;
end;

function TInstance.CreateRepresentationInternal( const ArchetypeID: TGUID ): IRepresentation;
var
  Archetype: IArchetype;
  Storage: IStorage;
  Representation: IRepresentation;
  RepresentationInstance: IInterface;
  Obj: TObject;
begin
  // Check that we're able to look up the archetype record to get its factory.
  Archetype := FindArchetype( ArchetypeID );
  if not assigned( Archetype ) then begin
    raise TStatus.CreateException( stArchetypeNotFound, [ ArchetypeID.AsString ] );
  end;
  try
    // Create an instance of storage, the representation factory, and then create a representation to store them
    Storage := TStorage.Create( Archetype, CreateRepresentation );
    RepresentationInstance := Archetype.getFactory()( Storage );
    if not assigned( RepresentationInstance ) then begin
      raise TStatus.CreateException( stArchetypeFactoryFailed, [ ArchetypeID.AsString ] );
    end;
    RepresentationInstance.QueryInterface( IInterface, Obj );
    if not Assigned( Obj ) then begin
      raise TStatus.CreateException( stIdentAddressUnresoved );
    end;
    Representation := TRepresentation.Create( ArchetypeID, RepresentationInstance, nativeuint.FromPointer( Obj ), Storage );
    fRepresentations.Add( Representation );
    Result := Representation;
    // Storage is initially created in absolute mode, migrate it to relative mode.
    ( Storage as IInternalStorage ).GoRelative( RepresentationInstance );
  finally
    // Clean up dangling references.
    Storage := nil;
    RepresentationInstance := nil;
    Representation := nil;
  end;
end;

function TInstance.CreateRepresentation( const ArchetypeID: TGUID ): IInterface;
var
  Instance: IInterface;
  Representation: IRepresentation;
begin
  Representation := CreateRepresentationInternal( ArchetypeID );
  if not assigned( Representation ) then exit( nil );
  Instance := Representation.getRepresentationInstance();
  Result := Instance;
end;

function TInstance.FindArchetype( const ArchetypeID: TGUID ): IArchetype;
begin
  Result := nil;
  if not assigned( fArchetypes ) then exit;
  Result := fArchetypes.Value[ ArchetypeID ];
end;

function TInstance.FindRepresentation( const RepresentationInstance: IInterface; out FoundIdx: nativeuint ): boolean;
var
  idx: nativeuint;
  ObjA: TObject;
  ObjB: TObject;
begin
  Result := False;
  if fRepresentations.Count = 0 then exit;
  if not assigned( RepresentationInstance ) then exit;
  for idx := 0 to pred( fRepresentations.Count ) do begin
    if not assigned( fRepresentations[ idx ] ) then continue;
    fRepresentations[ idx ].getRepresentationInstance.QueryInterface( IInterface, ObjA );
    RepresentationInstance.QueryInterface( IInterface, ObjB );
    if not assigned( ObjA ) then continue;
    if not assigned( ObjB ) then continue;
    if ObjA = ObjB then begin
      FoundIdx := idx;
      exit( true );
    end;
  end;
end;

function TInstance.GetStorage( const RepresentationInstance: IInterface ): IStorage;
var
  FoundIdx: nativeuint;
begin
  Result := nil;
  if not FindRepresentation( RepresentationInstance, FoundIdx ) then exit;
  Result := fRepresentations[ FoundIdx ].getStorage;
end;

function TInstance.ModelName: string;
begin
  Result := fModelName;
end;

procedure TInstance.RemoveRepresentation( const RepresentationInstance: IInterface );
var
  idx: nativeuint;
begin
  if not FindRepresentation( RepresentationInstance, idx ) then exit;
  fRepresentations.RemoveItem( idx );
end;

function TInstance.RepresentationInstances: IReadOnlyList< IInterface >;
var
  List: IList< IInterface >;
  Representation: IRepresentation;
begin
  List := TList< IInterface >.Create;
  Result := List.getAsReadOnly;
  for Representation in fRepresentations do begin
    List.Add( Representation.getRepresentationInstance );
  end;
end;

function TInstance.Representations: IReadOnlyList< IInterface >;
var
  List: IList< IInterface >;
  Representation: IRepresentation;
begin
  List := TList< IInterface >.Create;
  Result := List.getAsReadOnly;
  for Representation in fRepresentations do begin
    List.Add( Representation );
  end;
end;

function TInstance.FindFirst( const ArchetypeID: TGUID ): IInterface;
var
  Representation: IRepresentation;
begin
  Result := nil;
  for Representation in fRepresentations do begin
    if ArchetypeID.EqualTo( Representation.getArchetypeID ) then exit( Representation.getRepresentationInstance );
  end;
end;

destructor TInstance.Destroy;
begin
  fArchetypes := nil;
  fRepresentations := nil;
  inherited Destroy;
end;

function TInstance.Serialize( const TargetStream: IStream ): TStatus;
var
  Serializer: ISerializer;
begin
  Serializer := TSerializer.Create( TargetStream, fArchetypes, fRepresentations );
  try
    Result := Serializer.Serialize;
  finally
    Serializer := nil;
  end;
end;

function TInstance.SerializeJson( const TargetStream: IUnicodeStream ): TStatus;
var
  Serializer: IJsonSerializer;
begin
  Serializer := TJsonSerializer.Create( TargetStream, fArchetypes, fRepresentations );
  try
    Result := Serializer.Serialize;
  finally
    Serializer := nil;
  end;
end;

function TInstance.TransferRepresentation( const SourceModelInstance: IModelInstance; const RepresentationInstance: IInterface ): IInterface;
var
  SourceArchetypeMember: IArchetypeMember;
  ArchetypeMember: IArchetypeMember;
  Archetype: IArchetype;
  SourceArchetype: IArchetype;
  ArchetypeID: TGUID;
  Reflection: IReflection;
  FoundMember: boolean;
  FoundIdx: uint64;
  Representation: IRepresentation;
  I: IInterface;
begin
  Result := nil;
  if not assigned( SourceModelInstance ) then raise TStatus.CreateException( stModelInstanceNotAssigned, [] );
  if not assigned( RepresentationInstance ) then raise TStatus.CreateException( stRepesentationInstanceNotAssigned, [] );
  // Get ArchetypeID from source reflection
  Reflection := SourceModelInstance as IReflection;
  ArchetypeID := Reflection.ArchetypeOf( RepresentationInstance ).ArchetypeID;
  // Check that we're able to look up the archetype record to get its factory.
  Archetype := FindArchetype( ArchetypeID );
  if not assigned( Archetype ) then raise TStatus.CreateException( stArchetypeNotFound, [ ArchetypeID.AsString ] );
  if not Reflection.FindRepresentationByObjectReference( RepresentationInstance, FoundIdx ) then raise TStatus.CreateException( stRepresentationNotFound, [] );
  // Get the source representation.
  Representation := Reflection.Representations[ FoundIdx ] as IRepresentation;
  // Make sure target archetype shares members of source archetype
  SourceArchetype := Reflection.ArchetypeOf( RepresentationInstance );
  for SourceArchetypeMember in SourceArchetype.Members do begin
    FoundMember := False;
    for ArchetypeMember in Archetype.Members do begin
      if ArchetypeMember.DisplayName = SourceArchetypeMember.DisplayName then begin
        FoundMember := True;
        break;
      end;
    end;
    if FoundMember then continue;
    Archetype.AddMember( SourceArchetypeMember );
  end;
  // Recurse any reference members.
  for ArchetypeMember in Archetype.Members do begin
    if ArchetypeMember.DataType = mtReference then begin
      //- Is it a reference, or a list of references?
      if ArchetypeMember.IsSingleReference( SourceModelInstance, RepresentationInstance ) then begin
        ArchetypeMember.SetSingleReference( Self, RepresentationInstance, TransferRepresentation( SourceModelInstance, ArchetypeMember.AsSingleReference( SourceModelInstance, RepresentationInstance ) ) );
      end;
      if ArchetypeMember.IsReferenceList( SourceModelInstance, RepresentationInstance ) then begin
        for I in ArchetypeMember.AsReferenceList( SourceModelInstance, RepresentationInstance ) do begin
          ArchetypeMember.AddToReferenceList( Self, RepresentationInstance, TransferRepresentation( SourceModelInstance, I ) );
        end;
      end;
    end;
  end;
  // Add the source representation to this instance and we're done
  fRepresentations.Add( Representation );
  Result := RepresentationInstance;
end;

function TInstance.Deserialize( const SourceStream: IStream ): TStatus;
var
  Deserializer: IDeserializer;
begin
  Deserializer := TDeserializer.Create( SourceStream, fArchetypes, fRepresentations, CreateRepresentationInternal );
  try
    Result := Deserializer.Deserialize;
  finally
    Deserializer := nil;
  end;
end;


end.
