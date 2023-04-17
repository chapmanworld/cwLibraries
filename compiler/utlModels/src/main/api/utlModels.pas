(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlModels;

interface
uses
  utlStatus
, utlCollections
, utlIO
, utlLexers
;

{$region ' Usage information '}
(*

  utlModels is intended for storing abstract representations of source
  code (AST's or Abstract Syntax Trees), however, its use extends beyond
  the AST to more arbitrary representations of structured data.

  As an abstract concept, it can be challenging to understand or even to
  explain without a frame of reference. For that reason, we'll stick to the
  AST example for the sake of this explanation. If you do not understand what
  an AST is, please read up on Abstract Syntax Trees first, before continuing
  to read this.

  Consider the following snippet of pascal code, and how it might be stored
  in an AST...

    const
      MyConstant = 6;

  The code represents a constant declaration. We start with the keyword "const",
  and then provide an identifier for the constant. After an equate operator,
  the constant value is provided. As our compiler parses this constant
  declaration, consider the information that it must store in order to pass
  on the declaration to later parts of the compiler.

  The keyword 'const' is not important to store, but rather, it tells our
  parser that a constant declaration is coming, and so the parser should
  generate a structure for storing the declaration information.
  The first thing that must be stored in this declaration struture is an
  identifier, that is, a string to identify the constant.
  The operator also need not be stored, it's there to tell the parser that
  the identifier is done, and that the constant value comes next.
  The second piece of information to store then, is the constant value.

  In our example, we need to store two pieces of information then, an identifier,
  and a value. We store these two pieces of information into a structure that
  is specifically designed to store constant declarations. We'll refer to this
  structure as an archetype.

  In order to define an archetype for use with utlModels, we must define an
  interface to represent the data to be stored.
  Consider the following example for a constant declaration....

  IConstantDeclaration = interface
  ['{A6FC1FF0-839A-4FE6-8E60-AAF8FDBFBF47}']

    {$region ' Getters / Setters '}
    function getIdentifier: string;
    procedure setIdentifier( const Value: string );
    function getValue: int32;
    procedure setValue( const Value: int32 );
    {$endregion}

    property Identifier: string read getIdentifier write setIdentifier;
    property Value: int32 read getValue write setValue;

  end;

  This interface, combined with an implementing class, is the archetype for
  a constant declaration. When we instance a class which implements this
  interface, we refer to the instance as a 'representation', in that it is
  an instance that represents a constant declaration.

  To summise the above: A "model" is a collection of archetypes which define
  the data structure for our syntax tree. An "archetype" is an interface which
  represents a node in our syntax tree, and it's accompanying class.
  A "representation" is an "instance" of an archetype. Armed with this
  information, lets look at how we can define a model using utlModels.

  The utlModels system is able to work with multiple models at a time. For
  this reason, there is a global function named "Models" which returns a
  singleton instance of the IModels interface. This interface is merely a
  container collection, which allows a model to be created and stored in
  a dictionary against a given name.  So lets start by telling utlModels
  that we want to define a model named "PascalAST", for storing parsed
  pascal source-code.

  PascalModel := Models.RegisterModel( "PascalAST" );

  Now that we have a model, lets add our constant declaration archetype to it.

  PascalModel.RegisterArchetype( IConstantDeclaration, TConstantDeclaration.Factory, 'Constant-Declaration' );

  The above line of code uses our IConstantDeclaration archetype as we defined
  earlier. It then introduces a class "TConstantDeclaration" which implements
  the interface, and which has a factory method. We'll come back to look at the
  factory method more closely in a moment. Finally, we have a "display name"
  parameter, which is simply a string that describes the archetype. This display
  name will appear when a model is serialized as text, for instance, using the
  serialize to Json functionality.

  Now lets take a look at the implementation for this constant declaration.
  All that is needed is a class which implements the IConstantDeclaration
  interface, however, the utlModels library needs a means of instancing
  the class when it is required, and needs to connect to the class members
  for the sake of accessing its internal storage. Lets start with a simple
  implementation of the interface, and add futher requirements from there.

  type
    TConstantDeclaration = class( TInterfacedObject, IConstantDeclaration )
    private
      fIdentifier: string;
      fValue: int32;
    strict private //- IConstantDeclaration -//
      function getIdentifier: string;
      procedure setIdentifier( const Value: string );
      function getValue: int32;
      procedure setValue( const Value: int32 );
    end;

  As you can see, we are simply implementing the getter and setter methods
  of the IConstantDeclaration interface, and providing two local storage
  variables named "fIdentifier" and "fValue" for storing the data.

  We need to tell utlModel how to find those internal variables, so we'll add
  the following constructor to our class...

  constructor TConstantDeclaration.Create( const Storage: TStorage );
  begin
    inherited Create;
    Storage.AddMember( fIdentifier, 'Identifier' );
    Storage.AddMember( fValue, 'Value' );
  end;

  Our constructor must be passed an instance of Storage, which it uses
  to register the two internal variables via calls to AddMember(). This
  AddMember() method takes two parameters. First it takes the storage
  variable, and then a display name string for that variable when serialized
  as text.

  In order for the model to instance this representation, we passed a factory
  into our earlier call to "PascalModel.RegisterArchetype()". This factory
  may be a global function, or it may be a class-method on the implementation.
  I opted to go with the later, so lets see how to implement that...

  class function TConstantDeclaration.Factory( const Storage: TStorage ): IInterface;
  begin
    Result := TConstantDeclaration.Create( Storage );
  end;

  When our model is used to instance a representation, the model will call this
  factory and provide an instance of storage. This factory method then simply
  calls the TConstantDeclaration class constructor, forwarding in the storage
  instance, and returning the new instance of the class.

  Now we're ready. We have created a model for storing parsed pascal code.
  Okay, we have only told it about a single source code structure, the constant
  declaration, but we could at least write a parser to generate a representation
  of a constant declaration. So how do we do it?

  Well thus far, we've used utlModels to define a model called "PascalAST", but
  we've not yet created an instance of that model. Earlier we called the
  Models.RegisterModel() method to begin defining our model, and we took a
  reference to it named PascalModel which we used to register the constant
  definition archetype.  Now, we'll use that reference again to create
  a new instance of our model.

  AST := PascalModel.CreateInstance;

  This line of code returns a reference to an IModelInstance. The IModelInstance
  interface is another collection-type interface, which simply stores a
  collection of "representations" - which you'll remember from our earlier
  definition, are instances of archetypes.

  So lets make the very first item in our new AST instance, a representation
  of a constant declaration...

  ConstDecl := AST.CreateRepresentation( IConstantDeclaration ) as IConstantDeclaration;

  And now, lets store the data that was parsed by the parser...

  ConstDecl.Identifier := 'SomeIdentifier';
  ConstDecl.Value := 6;

  That's it! We now have an in-memory instance of an AST representing parsed
  pascal code... albeit, a very simple one which represents only constant
  declarations.

  ------------------------------------------------------------------------------

*)
{$endregion}

{$region ' Status messages '}

const
  stModelAlreadyRegistered              : TGUID = '{61B01C84-27AD-48B1-95CD-1B20E2624775}';
  stArchetypeNotFound                   : TGUID = '{62F89E1B-B7D7-4A1D-A9ED-1E3BD2CABB63}';
  stArchetypeAlreadyRegistered          : TGUID = '{0CACBA6C-5D15-4154-BE1F-B020830213CE}';
  stArchetypeFactoryFailed              : TGUID = '{B17BE2D6-EE56-4791-AECE-AB3078E64BE1}';
  stArchetypeImplementationMissing      : TGUID = '{056DDA0F-FAEF-4460-A898-E8CA867440C6}';
  stArchetypeMemberClash                : TGUID = '{9BAC266A-4C78-4269-A87F-04EFC7E5AC4F}';
  stSerializationError                  : TGUID = '{DA34BE78-0798-46B5-979C-A2207B5C19A2}';
  stUnrecognizedDataTypeInStorage       : TGUID = '{ECF7DC73-B10F-46C7-BEA3-0161F7244093}';
  stArchetypeMemberDisplayNameMissmatch : TGUID = '{805A172B-632B-465A-8B5A-E653B139A776}';
  stArchetypeMemberDataTypeMissmatch    : TGUID = '{0FF9E748-0C6D-4668-BE0A-A84CB333BF5B}';
  stArchetypeMemberOffsetMissmatch      : TGUID = '{E53C8540-A41E-4C34-9491-663C10B8A039}';
  stArchetypeIDMissmatch                : TGUID = '{26B29DE9-5229-480D-B87D-176FDE6E4EEE}';
  stArchetypeMemberCountMissmatch       : TGUID = '{0D93DBA2-0AE9-4999-8FFA-4A40299E110B}';
  stArchetypeCountMissmatch             : TGUID = '{92307D05-62BE-4A73-ABB8-26A3D6D3873D}';
  stSignatureInvalid                    : TGUID = '{D3FABFE6-279E-4483-A752-B828ECF1B468}';
  stArchetypeDisplayNameMissmatch       : TGUID = '{8C68EFE7-C0F4-462A-9119-7224632AFDC9}';
  stStorageInvalidBooleanData           : TGUID = '{8F6E584C-DBF9-42AC-B982-38CA69FB52D5}';
  stInvalidStringIndex                  : TGUID = '{C57853EF-9B22-49F2-B84A-00F4E34394E4}';
  stUnidentifiedReference               : TGUID = '{A0B908F6-4374-4365-B433-C48382BB4FE1}';
  stUnidentifiedListItemReference       : TGUID = '{C0884C97-1661-40DB-B006-CC8C25E7B8EE}';
  stUnidentifiedReferenceMemberType     : TGUID = '{E0FB55B0-7246-4849-B8E1-804A687106BC}';
  stInvalidResolveIndex                 : TGUID = '{40A78124-EBCA-471F-973B-F66EF10AE433}';
  stMalformedResolveTable               : TGUID = '{72D48A88-7564-4DE9-A15F-F07DAF7D7F7C}';
  stIdentAddressUnresoved               : TGUID = '{845E08F9-E98C-4C0E-B34A-23EE6A136EFF}';
  stCursorFoundButNotSupported          : TGUID = '{813FD8F1-BD2B-4C88-BCBA-644AD0A44092}';
  stModelInstanceNotAssigned            : TGUID = '{3CBEAE0A-49E9-4FEE-9EBC-01245D649BFD}';
  stRepesentationInstanceNotAssigned    : TGUID = '{46E43E8D-F4E3-44D2-B434-23B7C11D7466}';
  stRepresentationNotFound              : TGUID = '{8481282C-81B9-4D51-BF99-7D5917A0B325}';

{$endregion}

{$region ' IHasCursor '}

type
  ///  <summary>
  ///    This interface is merely a convenience. <br/>
  ///    Many archetypes will want to track a lexer cursor in order to provide
  ///    filename / line number and line position information for error logging
  ///    or debugging purposes. This interface may be used as a base interface
  ///    for those archetypes, providing a consistent way to address a cursor
  ///    over multiple models. <br/>
  ///    If your archetype supports this interface, the serialize and
  ///    deserialize features of utlModels will automatically account for the
  ///    cursor.
  ///  </summary>
  IHasCursor = interface
    ['{9244C5EA-A28C-41BF-ADB0-85F8E0FCAFDC}']

    ///  <summary>
    ///    Returns an instance of ICursor. <br/>
    ///    Note: When you create a representation from an archetype which
    ///    implements IHasCursor, you are responsible for setting the cursor
    ///    information, which must be done via the ICursor.Assign() method.
    ///  </summary>
    function Cursor: ICursor;
  end;

{$endregion}

{$region ' TCursor (factory) '}

type
  /// <exclude/>
  ICursor = utlLexers.ICursor;

type
  ///  <summary>
  ///    Provided here as a convenience so that models do not need to uses the
  ///    lexer unit, this record provides a factory method for instancing
  ///    ICursor.
  ///  </summary>
  TCursor = record

    ///  <summary>
    ///    A factory method for instancing ICursor.
    ///  </summary>
    class function Create( const Filename: string; const LineNumber: nativeuint; const LinePosition: nativeuint ): ICursor; static;
  end;

{$endregion}

{$region ' IStorage '}

type
  ///  <summary>
  ///    Used to store the instance data for a representation node.
  ///  </summary>
  IStorage = interface
    ['{B26411A2-2343-425B-9895-B72D66DEF74C}']

    ///  <summary>
    ///    May be used by a representation to call-back to the instance which
    ///    provides this storage, and create another representation by
    ///    archetype. This enables representations to pre-instance reference
    ///    members if required.
    ///  </summary>
    function CreateRepresentation( const ArchetypeID: TGUID ): IInterface;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a string member.
    ///  </summary>
    procedure AddMember( const [ref] Member: string; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a uint8 member.
    ///  </summary>
    procedure AddMember( const [ref] Member: uint8; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a uint16 member.
    ///  </summary>
    procedure AddMember( const [ref] Member: uint16; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a uint32 member.
    ///  </summary>
    procedure AddMember( const [ref] Member: uint32; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a uint64 member.
    ///  </summary>
    procedure AddMember( const [ref] Member: uint64; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a int8 member.
    ///  </summary>
    procedure AddMember( const [ref] Member: int8; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a int16 member.
    ///  </summary>
    procedure AddMember( const [ref] Member: int16; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a int32 member.
    ///  </summary>
    procedure AddMember( const [ref] Member: int32; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a int64 member.
    ///  </summary>
    procedure AddMember( const [ref] Member: int64; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a TGUID member.
    ///  </summary>
    procedure AddMember( const [ref] Member: TGUID; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a single-precision member.
    ///  </summary>
    procedure AddMember( const [ref] Member: single; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a double-precision member.
    ///  </summary>
    procedure AddMember( const [ref] Member: double; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds a boolean member.
    ///  </summary>
    procedure AddMember( const [ref] Member: boolean; const DisplayName: string ); overload;

    ///  <summary>
    ///    AddMember() is used to register an internal member variable from an archetype,
    ///    with the model storage system, allowing a representation to serialize or
    ///    deserialize that data. <br/>
    ///    This overload adds an interface reference member. <br/>
    ///    This overload supports five types of reference as follows. <br/>
    ///    <br/>
    ///    1) An interface reference to any other representation - it must be a
    ///       representation that is registered with the model, in order that it
    ///       be serialized / deserialized. <br/>
    ///    <br/>
    ///    2) An IList< IInterface >, where IInterface in this case must be
    ///       substituted with the interface of a registered archetype. This
    ///       allows lists of 'child' representations to be serialized / deserialzied. <br/>
    ///    <br/>
    ///    3) An IList< string >, allowing representations to store multiple
    ///       items in array-style storage, so long as they can be represented
    ///       as strings. <br/>
    ///    <br/>
    ///    4) An IUnicodeStream, allowing representations to store arbitrary
    ///    data items. <br/>
    ///    <br/>
    ///    5) An ICursor from utlLexers, for tracking the parsing cursor used
    ///    to generate the model. <br/>
    ///    <br/>
    ///    Using an interface reference to something other than a registered
    ///    archetype, a list of registered archetype, or list of string, will
    ///    result in an exception upon serialization or deserialization. <br/>
    ///    References of any type, which are set to nil, are serialized and
    ///    deserialized regardless. <br/>
    ///    Note that IList< string > is actually handled by another,
    ///    undocumented overload, as the Supports() method in Delphi appears to
    ///    be unable to distinguish between IList< IInterface > and
    ///    IList< string >. This is probably just another case of Delphi's poor
    ///    generics implementation. <br/>
    ///  </summary>
    procedure AddMember( const [ref] Member: IInterface; const DisplayName: string ); overload;
    ///  <exclude/>  - If you found this, see notes on the Member: IInterface overload above.
    procedure AddMember( const [ref] Member: IList< string >; const DisplayName: string ); overload;
    ///  <exclude/>  - If you found this, see notes on the Member: IInterface overload above.
    procedure AddMember( const [Ref] Member: IUnicodeStream; const DisplayName: string ); overload;
///  <exclude/>  - If you found this, see notes on the Member: IInterface overload above.
    procedure AddMember( const [Ref] Member: ICursor; const DisplayName: string ); overload;
  end;

{$endregion}

{$region ' Representation Factory '}

type
  ///  <summary>
  ///    In order to instance the nodes of a representation,
  ///    the IRepresentation.Create() method requires that a factory
  ///    method be provided.
  ///  </summary>
  TRepresentationFactory = function( const Storage: IStorage ): IInterface;

{$endregion}

{$region ' IModelInstance '}

type
  ///  <summary>
  ///    Represents an instance of a defined model. <br/>
  ///  </summary>
  IModelInstance = interface
    ['{83A277E2-2A32-4528-876D-BA63AA066A00}']

    ///  <summary>
    ///    Creates an instance of an archetype that is registered with
    ///    the model for this instance. We refer to the instance of an
    ///    archetype as a representatoin. <br/>
    ///    The archetype is looked up using its guid, and the appropriate
    ///    representation factory called. The return value
    ///    from this method may then be cast to an interface for the
    ///    archetype accordingly.  f.x. <br/>
    ///    <br/>
    ///    ConstantDeclaration := MyAST.Instance( IConstantDeclaration ) as IConstantDeclaration; <br/>
    ///    <br/>
    ///    This instance retains a reference to the representation, keeping
    ///    it active so long as the instance is active, and therefore making it
    ///    possible to serialize / deserialize the entire instance. <br/>
    ///  </summary>
    function CreateRepresentation( const ArchetypeID: TGUID ): IInterface;

    ///  <summary>
    ///    Some archetypes are shared across multiple models, and it is often
    ///    necessary during transitioning from one model to another, to pass
    ///    representations of these shared archetypes from the source model to
    ///    the target model. This cannot be done simply by reference, because a
    ///    model instance must maintain an internal list of representations for
    ///    serialization / deserialization purposes. This method allows the
    ///    caller to pass in a representation from another model, only if, the
    ///    current model is able to recognize the archetype.
    ///  </summary>
    function TransferRepresentation( const SourceModelInstance: IModelInstance; const RepresentationInstance: IInterface ): IInterface;

    ///  <summary>
    ///    Disposes a representation created by a call to CreateRepresentation(). <br/>
    ///    Note: If the representation does not exist within the instance, this method
    ///    will do nothing and silently return. <br/>
    ///  </summary>
    procedure RemoveRepresentation( const RepresentationInstance: IInterface );

    ///  <summary>
    ///    Finds the first instance which supports the specified archetype.
    ///  </summary>
    function FindFirst( const ArchetypeID: TGUID ): IInterface;

    ///  <summary>
    ///    Returns the string that was used to register the model from which
    ///    this instance was created. This may be used to confirm that the
    ///    instance contains the correct model.
    ///  </summary>
    function ModelName: string;

    ///  <summary>
    ///    A method which serializes this instance to a stream in binary form. <br/>
    ///    A binary file serialized by a call to serialize() may be
    ///    deserialized with a call to deserialize().
    ///  </summary>
    function Serialize( const TargetStream: IStream ): TStatus;

    ///  <summary>
    ///    A method which deserialzies this instance from a stream which
    ///    was previously serialized using the 'Serialize()' method.
    ///  </summary>
    function Deserialize( const SourceStream: IStream ): TStatus;

    ///  <summary>
    ///    Serializes the model to the target stream in json format for
    ///    debugging purposes. ( utf8encoded without BOM ).
    ///  </summary>
    function SerializeJson( const TargetStream: IUnicodeStream ): TStatus;

  end;

{$endregion}

{$region ' IModel '}

type
  ///  <summary>
  ///    IModel represents the definition of a model for storing arbitrary
  ///    data. It is essentially a container with which you may register
  ///    an interface GUID and a factory method for creating an instance
  ///    to satisty that interface.
  ///  </summary>
  IModel = interface
  ['{39698DC2-FF9F-4B34-992F-DBB2CA9C9E71}']

    ///  <summary>
    ///    An Archetype is a 'type-of-node' within your abstraction model. <br/>
    ///    For instance, in a syntax tree with a node for storing constant
    ///    declarations, there would be a 'constant declaration' archetype. <br/>
    ///    In code, your archetype can be any class which implements an interface.
    ///    You should register that archetype with a call to this method. <br/>
    ///    You should provide a unique identifier for your archetype in the form
    ///    of a GUID. This is typically the guid of an interface which represents
    ///    the archetype. You should also provide a factory method which, when
    ///    called, creates an object instance which implements the interface.
    ///    Finally, you may *should* supply a display name which will be used
    ///    to represent the archetype when serializing to any text format, such
    ///    as XML serialization for instance. <br/>
    ///    An example call to RegisterArchetype might look like this: <br/>
    ///    <br/>
    ///    Model.RegisterArchetype( IConstantDeclaration, TConstantDeclaration.Factory, 'Constant-Declaration' ); <br/>
    ///    <br/>
    ///    If registration of the archetype fails for any reason, such as a non-unique identifier
    ///    for instance, an exception will be raised.
    ///  </summary>
    procedure RegisterArchetype( const ArchetypeID: TGUID; const Factory: TRepresentationFactory; const DisplayName: string );

    ///  <summary>
    ///    Creates an instance of IModelInstance, that-is, an instance of this
    ///    model. The IModelInstance reference may be considered as
    ///    the root node of a model instance, and may be used to futher create
    ///    instances of archetypes registered with the model.
    ///  </summary>
    function CreateInstance: IModelInstance;
  end;

{$endregion}

{$region ' IModels '}

type
  ///  <summary>
  ///    A container for storing and retrieving models. <br/>
  ///  </summary>
  IModels = interface
    ['{31A48D22-2A88-470F-9E73-F55867A522ED}']

     {$region ' Getters / Setters '}
     ///  <exclude/> - Getter for 'Models' property.
     function getModel( const Name: string ): IModel;
     {$endregion}

    ///  <summary>
    ///    Register a new model. <br/>
    ///    Your model must be given a unique name, which may later
    ///    be used to retrieve its instance when required. <br/>
    ///  </summary>
    function RegisterModel( const Name: string ): IModel;

    ///  <summary>
    ///    Provides array-style access to registered models using
    ///    the unique identifier of a model as its index. <br/>
    ///  </summary>
    property Models[ const Name: string ]: IModel read getModel; default;
  end;

{$endregion}

///  <summary>
///    Provides access to a global singleton instance of IModels.
///  </summary>
function Models: IModels;

implementation
uses
  utlLexers.Cursor
, utlModels.Storage
, utlModels.Models
;

var
  SingletonModels: IModels = nil;

function Models: IModels;
begin
  if not assigned( SingletonModels ) then begin
    SingletonModels := TModels.Create;
  end;
  Result := SingletonModels;
end;

class function TCursor.Create( const Filename: string; const LineNumber: nativeuint; const LinePosition: nativeuint ): ICursor;
begin
  Result := utlLexers.Cursor.TCursor.Create( Filename, LineNumber, LinePosition );
end;

initialization
  SingletonModels := nil;
  TStatus.Register( stModelAlreadyRegistered              , 'Model already registered by name: "(%%)"' );
  TStatus.Register( stArchetypeNotFound                   , 'Archetype could not be found by GUID: "(%%)"' );
  TStatus.Register( stArchetypeAlreadyRegistered          , 'Archetype already registered: "(%%)"' );
  TStatus.Register( stArchetypeFactoryFailed              , 'The factory method failed when attempting to instance archetype "(%%)"' );
  TStatus.Register( stArchetypeImplementationMissing      , 'Archetype implementation missing: "(%%)"' );
  TStatus.Register( stArchetypeMemberClash                , 'Cannot add member "(%%)" to archetype "(%%)" due to member offset clash."' );
  TStatus.Register( stSerializationError                  , 'Stream write error while attempting to serialize model instance.' );
  TStatus.Register( stUnrecognizedDataTypeInStorage       , 'The storage class encountered an unknown data-type in the model instance.' );
  TStatus.Register( stArchetypeMemberDisplayNameMissmatch , 'Stream does not match model: Archetype member display name missmatch.' );
  TStatus.Register( stArchetypeMemberDataTypeMissmatch    , 'Stream does not match model: Archetype member data-type missmatch.' );
  TStatus.Register( stArchetypeMemberOffsetMissmatch      , 'Stream does not match model: Archetype member offset missmatch.' );
  TStatus.Register( stArchetypeIDMissmatch                , 'Stream does not match model: Archetype ID missmatch.' );
  TStatus.Register( stArchetypeMemberCountMissmatch       , 'Stream does not match model: Archetype member count missmatch.' );
  TStatus.Register( stArchetypeCountMissmatch             , 'Stream does not match model: Archetype count missmatch.' );
  TStatus.Register( stSignatureInvalid                    , 'Stream does not match model: Invalid signature.' );
  TStatus.Register( stArchetypeDisplayNameMissmatch       , 'Stream does not match model: Archetype display name missmatch.' );
  TStatus.Register( stStorageInvalidBooleanData           , 'Stream contains invalid data for boolean member.' );
  TStatus.Register( stInvalidStringIndex                  , 'Stream contains invalid data for string member.'  );
  TStatus.Register( stUnidentifiedReference               , 'Encountered reference which is not a valid representation.' );
  TStatus.Register( stUnidentifiedListItemReference       , 'Encountered reference within list which is not a valid representation.' );
  TStatus.Register( stUnidentifiedReferenceMemberType     , 'Cannot resolve reference as type is unknown. ' );
  TStatus.Register( stInvalidResolveIndex                 , 'Cannot resolve reference as index is invalid. ' );
  TStatus.Register( stMalformedResolveTable               , 'Cannot resolve reference as resolver table is invalid. ');
  TStatus.Register( stIdentAddressUnresoved               , 'Unable to resolve ident address for representation. ' );
  TStatus.Register( stCursorFoundButNotSupported          , 'Cursor information was found in the stream during deserialization, but representation does not support a cursor. Corrupt stream?' );
  TStatus.Register( stModelInstanceNotAssigned            , 'Model instance not assigned.' );
  TStatus.Register( stRepesentationInstanceNotAssigned    , 'Representation instance not assigned.' );
  TStatus.Register( stRepresentationNotFound              , 'Representation not found.' );

finalization
  SingletonModels := nil;

end.
