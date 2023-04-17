(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlModels.Reflection;

(*
   This unit provides type information regarding a model instance, which
   may be used to provide additional serialization options, or debugging
   inspection of models.
*)

interface
uses
  utlModels
, utlCollections
, utlIO
;

{$region ' TArchetypeMemberType '}

type
  (*
     An enumeration of the data-types that may be stored by an archetype
     member.
  *)
  // Keep consequtive and do not alter values.
  {$Z2} // minimum two bytes storage.
  TArchetypeMemberType = (
      mtString        = $0001
    , mtInt8          = $0002
    , mtInt16         = $0003
    , mtInt32         = $0004
    , mtInt64         = $0005
    , mtUInt8         = $0006
    , mtUInt16        = $0007
    , mtUInt32        = $0008
    , mtUInt64        = $0009
    , mtSingle        = $000A
    , mtDouble        = $000B
    , mtGUID          = $000C
    , mtReference     = $000D
    , mtBoolean       = $000E
    , mtStringList    = $000F
    , mtUnicodeStream = $0010
    , mtCursor        = $0011
  );

{$endregion}

{$region ' IArchetypeMember '}

type
  (*
     Internally used interface to store information regarding the member
     variables of a given archetype.
  *)
  IArchetypeMember = interface
  ['{8142E35B-9957-487E-876E-A670974254D2}']
    // Returns the offset of the member within the representation instance.
    function Offset: uint64;
    // Returns a constant which enumerate the data type of the member.
    function DataType: TArchetypeMemberType;
    // Returns the display name of the member.
    function DisplayName: string;
    // Used to set the offset of the member during model configuration
    procedure setOffset( const Value: uint64 );
    //
    function AsInt8( const ModelInstance: IModelInstance; const Representation: IInterface ): int8;
    function AsInt16( const ModelInstance: IModelInstance; const Representation: IInterface ): int16;
    function AsInt32( const ModelInstance: IModelInstance; const Representation: IInterface ): int32;
    function AsInt64( const ModelInstance: IModelInstance; const Representation: IInterface ): int64;
    function AsUInt8( const ModelInstance: IModelInstance; const Representation: IInterface ): uint8;
    function AsUInt16( const ModelInstance: IModelInstance; const Representation: IInterface ): uint16;
    function AsUInt32( const ModelInstance: IModelInstance; const Representation: IInterface ): uint32;
    function AsUInt64( const ModelInstance: IModelInstance; const Representation: IInterface ): uint64;
    function AsSingle( const ModelInstance: IModelInstance; const Representation: IInterface ): single;
    function AsDouble( const ModelInstance: IModelInstance; const Representation: IInterface ): double;
    function AsGUID( const ModelInstance: IModelInstance; const Representation: IInterface ): TGUID;
    function AsBoolean( const ModelInstance: IModelInstance; const Representation: IInterface ): boolean;
    function AsStringList( const ModelInstance: IModelInstance; const Representation: IInterface ): IReadOnlyList< string >;
    function AsUnicodeStream( const ModelInstance: IModelInstance; const Representation: IInterface ): IUnicodeStream;
    function AsSingleReference( const ModelInstance: IModelInstance; const Representation: IInterface ): IInterface;
    procedure SetSingleReference( const ModelInstance: IModelInstance; const Representation: IInterface; const Value: IInterface );
    function AsReferenceList( const ModelInstance: IModelInstance; const Representation: IInterface ): IReadOnlyList< IInterface >;
    procedure AddToReferenceList( const ModelInstance: IModelInstance; const Representation: IInterface; const Item: IInterface );
    function AsString( const ModelInstance: IModelInstance; const Representation: IInterface ): string;
    function AsCursor( const ModelInstance: IModelInstance; const Representation: IInterface ): ICursor;
    function IsSingleReference( const ModelInstance: IModelInstance; const Representation: IInterface ): boolean;
    function IsReferenceList( const ModelInstance: IModelInstance; const Representation: IInterface ): boolean;
  end;

{$endregion}

{$region ' IArchetype '}

type
  (*
    Used internally to store the details of an archetype in a dictionary with a GUID key.
    The dictionary is actually in utModels.Model.fArchetypes, but this record is required
    here in order for the instance to be able to create representations based on the
    factory, and for serialization / deserialization purposes.
  *)
  IArchetype = interface
    ['{39056F39-B76B-4DC3-AA1C-3AC90B7BB920}']

    // Returns the guid which identifies this archetype.
    function ArchetypeID: TGUID;

    // Returns the factory method that may be used to instance a representation of the archetype.
    function getFactory: TRepresentationFactory;

    // Returns the display name of the archetype.
    function getDisplayName: string;

    // Retuns true if the archetype member already exists within the archetype.
    function MemberExists( const ArchetypeMember: IArchetypeMember ): boolean;

    // Attempts to add the provided archetype member to the archetype.
    // * Note: There must not be an existing archetype at the same offset.
    procedure AddMember( const ArchetypeMember: IArchetypeMember );

    // Returns a read only list of the archetype members.
    function Members: IReadOnlyList< IArchetypeMember >;
  end;

{$endregion}

type
  ///  <summary>
  ///    Implemented by instances of IModelInstance, provides access to the
  ///    type information for that instance.
  ///  </summary>
  IReflection = interface
    ['{F6AB2464-344C-44E3-A252-DC2128B1D44F}']

    ///  <summary>
    ///  </summary>
    function GetStorage( const Representation: IInterface ): IStorage;

    ///  <summary>
    ///    Returns a read only list of the representation instances in the model.
    ///  </summary>
    function RepresentationInstances: IReadOnlyList< IInterface >;

    ///  <summary>
    ///    Returns a read only list of the internal representation records for
    ///    instances in the model. (Used by TransferRepresentation)
    ///  </summary>
    function Representations: IReadOnlyList< IInterface >;

    function FindRepresentationByObjectReference( const Ref: IInterface; out FoundIdx: uint64 ): boolean;

    ///  <summary>
    ///    Returns the archetype of a given representation. <br/>
    ///    The representation must exist within the model, or else this method
    ///    will return nil.
    ///  </summary>
    function ArchetypeOf( const Representation: IInterface ): IArchetype;

  end;
implementation

end.
