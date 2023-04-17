(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLinker.BinaryImage;

interface
uses
  utlStatus
, utlIO
, utlCollections
, utlLinker
;

{$region ' IStringList (not to be confused with IStringLists) '}

type
  ///  <summary>
  ///    A named list collection of strings.
  ///  </summary>
  IStringList = interface
  ['{1AE5E17E-A07E-45FA-AA63-F2B8666267D9}']

    {$region ' Getters / Setters '}
    ///  <exclude/>
    function getItemByIndex( const Idx: nativeuint ): string;
    ///  <exclude/>
    function getName: string;
    ///  <exclude/>
    procedure setName( const value: string );
    {$endregion}

    ///  <summary>
    ///    Clears the content of this string list.
    ///  </summary>
    procedure Clear;

    ///  <summary>
    ///    Returns the number of items in this list.
    ///  <summary>
    function Count: nativeuint;

    ///  <summary>
    ///    Adds an item to the list
    ///  </summary>
    function Add( const value: string ): nativeuint; overload;

    ///  <summary>
    ///    Performs the same as Add() to add a string to the list, but
    ///    also stores the lower and upper offset values of the string. This
    ///    property put here specifically for use when reading ELF format files
    ///    which often reference strings by their offset within a section of
    ///    the file. You may add the Lower and Upper offsets of the strings
    ///    as the string section is loaded, and then use the IndexFromOffset()
    ///    method to locate a string by its offset.
    ///  </summary>
    function Add( const S: string; const LowerOffset: nativeuint; const UpperOffset: nativeuint ): nativeuint; overload;

    ///  <summary>
    ///    Attempts to locate a string given its offset. <br/>
    ///    This depends on the above Add() overload being used to provide
    ///    the lower and upper offsets for strings as they are added to
    ///    the string list. Strings which are not provided with these
    ///    values will not be returned. This method also returns the first
    ///    matching string, which means that, if Lower and Upper offsets
    ///    overlap, there will still be only one matching result.
    ///  </summary>
    function StringByOffset( const Offset: nativeuint; out S: string ): boolean;

    ///  <summary>
    ///    Returns an item as found by index. <br/>
    ///    Will return a null-string if the item index is out of bounds.
    ///  </summary>
    property Items[ const Idx: nativeuint ]: string read getItemByIndex;

    ///  <summary>
    ///    Allows the string list to be named.
    ///    i.e. If creating a string list during the reading of an elf
    ///    file, it may be named '.strtab' to represent the string table
    ///    used to name symbols.
    ///  </summary>
    property Name: string read getName write setName;

  end;

{$endregion}

{$region ' IStringLists (not to be confused with IStringList) '}

type
  ///  <summary>
  ///    Behaves something like a dictionary of string lists.
  ///    This is useful for storing strings that are required during the
  ///    loading of binary images, or as a place to hold them prior to
  ///    writing them to an image file.
  ///  </summary>
  IStringLists = interface
  ['{853666F3-937D-40C0-965B-2296DFD7C7A5}']

    {$region ' Getters / Setters '}
      ///  <exclude/>
      function getStringListByIndex( const value: nativeuint ): IStringList;
      ///  <exclude/>
      function getStringListByName( const value: string ): IStringList;
    {$endregion}

    ///  <summary>
    ///    Clears all string lists.
    ///  </summary>
    procedure Clear;

    ///  <summary>
    ///    Returns the number of string lists stored within.
    ///  </summary>
    function Count: nativeuint;

    ///  <summary>
    ///    Instances and adds a new string list to the collection, and returns
    ///    a reference to it.
    ///  </summary>
    function Add: IStringList;

    ////  <summary>
    ///    A property for accessing string lists by their index within the
    ///    IStringLists collection.
    ///   </summary>
    property Lists[ const idx: nativeuint ]: IStringList read getStringListByIndex; default;

    ///  <summary>
    ///    A property for accessing string lists by their name within the IStringLists
    ///    collection. (returns the first matching name, even if null-string)
    ///  </summary>
    property Lists[ const name: string ]: IStringList read getStringListByName; default;

  end;

{$endregion}

{$region ' TSectionAttribute / TSectionAttributes '}

type
  ///  <summary>
  ///    Enumerates the attributes which may be associated with a section.
  ///  </summary>
  TSectionAttribute = (

      ///  <summary>
      ///    This section expects to be loaded into a readable memory location.
      ///  </summary>
      saReadable

      ///  <summary>
      ///    This section expects to be loaded into a readable memory location.
      ///  </summary>
    , saWritable

      ///  <summary>
      ///    This section expects to be loaded into a memory location which
      ///    permits it to be executed. Additionally, the presence of this
      ///    attribute indicates a '.text/.code' section.
      ///  </summary>
    , saExecutable

      ///  <summary>
      ///    Used exclusively for linking PE executables, this section is the
      ///    '.idata' section, which contains information regarding DLL imports
      ///    required by the image upon load.
      ///  </summary>
    , saIData

  );

  ///  <summary>
  ///    The set of attributes which may be associated with a section.
  ///  </summary>
  TSectionAttributes = set of TSectionAttribute;

{$endregion}

{$region ' ISection '}

type
  ///  <summary>
  ///    A base interface for all other types of section that may appear
  ///    in a binary image file. <br/>
  ///    Note: An instance of ISection is an in-memory representation of
  ///    a section, not directly attached to file contents. A reader or
  ///    writer of a particular file format is required to either populate
  ///    the section with content from a file, or to write the content of
  ///    the section to a file. This detatches the model of a binary image
  ///    from physical storage. For instance, when loading a section from an
  ///    Elf format file, the section name and content are populated, however,
  ///    if you alter the name, this is not written back to the source file.
  ///    Instead, an elf writer must be used to generate the target file.
  ///  </summary>
  ISection = interface
  ['{85C9830B-E33B-4BE9-A4F3-D5DE5B522247}']

    {$region ' Getters / Setters '}
    /// <exclude/>
    function getName: string;
    /// <exclude/>
    procedure setName( const Value: string );
    /// <exclude/>
    function getRVA: TVirtualAddress;
    /// <exclude/>
    procedure setRVA( const Value: TVirtualAddress );
    /// <exclude/>
    function getAttributes: TSectionAttributes;
    /// <exclude/>
    procedure setAttributes( const value: TSectionAttributes );
    {$endregion}

    ///  <summary>
    ///    Attributes describing the sections protection properties when loaded.
    ///  </summary>
    property Attributes: TSectionAttributes read getAttributes write setAttributes;

    ///  <summary>
    ///    The virtual memory address of the section. <br/>
    ///    By default, this is set to zero. <br/>
    ///    During the process of linking the binary image, the RVA of each
    ///    section is set by the linker after section sorting has taken place.
    ///  </summary>
    property RVA: TVirtualAddress read getRVA write setRVA;

    ///  <summary>
    ///    The name of this section.
    ///  </summary>
    property Name: string read getName write setName;

  end;

{$endregion}

{$region ' TSymbolBindAttribute(s) '}

type
  ///  <summary>
  ///    The bind attributes represent the type of symbol, and provide information
  ///    regarding its visibility when the Visibility property is TSymbolVisbility.svDefault.
  ///  </summary>
  TSymbolBindAttribute = (

      ///  <summary>
      ///    This symbol is of local scope, for use within the image it exists in at link time.
      ///  </summary>
      baLocal

      ///  <summary>
      ///    This symbol is of global scope and can be seen from other images at link time.
      ///  </summary>
    , baGlobal

      ///  <summary>
      ///    This symbol is global, but its definition can be overriden.
      ///  </summary>
    , baWeak

      ///  <summary>
      ///    The item this symbol represents is of unspecified type.
      ///  </summary>
    , baUntyped

      ///  <summary>
      ///    The item this symbol represents is a program variable.
      ///  </summary>
    , baVariableType

      ///  <summary>
      ///    The item this symbol represents is a function.
      ///  </summary>
    , baFunctionType

      ///  <summary>
      ///    The item this symbol represents is a section.
      ///  </summary>
    , baSectionType

      ///  <summary>
      ///    The item this symbol represents is a file.
      ///  </summary>
    , baFileType

      ///  <summary>
      ///    The item this symbol represents an uninitialized global variable
      ///  </summary>
    , baCommonType
  );

  ///  <summary>
  ///  </summary>
  TSymbolBindAttributes = set of TSymbolBindAttribute;

{$endregion}

{$region ' TSymbolVisibility '}

type
  TSymbolVisibility = (

      ///  <summary>
      ///   For symbols of default visibility, its attribute is specified by the symbol’s binding type (see TBindAttributes).
      ///  </summary>
      svDefault

      ///  <summary>
      ///   The symbol is visible by other objects, but cannot be preempted.
      ///  </summary>
    , svProtected

      ///  <summary>
      ///   The symbol is not visible to other objects.
      ///  </summary>
    , svHidden

      ///  <summary>
      ///   The symbol visibility is reserved.
      ///  </summary>
    , svInternal
  );

{$endregion}

{$region ' TSymbolTime '}

type
  ///  <summary>
  ///    Describes the symbol as being static (link-time), or
  ///    dynamic (load-time).
  ///  </summary>
  TSymbolTime = (

      ///  <summary>
      ///    The symbol is static and should be resolved by the linker.
      ///  </summary>
      stStatic

      ///  <summary>
      ///    The symbol is dynamic and should be resolved by the loader.
      ///  </summary>
    , stDynamic

  );

{$endregion}

{$region ' ISymbol '}

type
  ///  <summary>
  ///    A symbolic reference to a target item within the image.
  ///  </summary>
  ISymbol = interface
  ['{F11DD98E-A1CB-4046-9E22-406ADB43DEEF}']

    {$region ' Getters / Setters '}
    /// <exclude/>
    function getName: string;
    /// <exclude/>
    procedure setName( const value: string );
    /// <exclude/>
    function getTime: TSymbolTime;
    /// <exclude/>
    procedure setTime( const value: TSymbolTime );
    /// <exclude/>
    function getBindAttributes: TSymbolBindAttributes;
    /// <exclude/>
    procedure setBindAttributes( const value: TSymbolBindAttributes );
    /// <exclude/>
    function getVisibility: TSymbolVisibility;
    /// <exclude/>
    procedure setVisibility( const value: TSymbolVisibility );
    /// <exclude/>
    function getSection: ISection;
    /// <exclude/>
    procedure setSection( const value: ISection );
    /// <exclude/>
    function getValue: TVirtualAddress;
    /// <exclude/>
    procedure setValue( const value: TVirtualAddress );
    {$endregion}

    ///  <summary>
    ///    The name of this symbol.
    ///  </summary>
    property Name: string read getName write setName;

    ///  <summary>
    ///    Describes the symbol as being static (link-time), or
    ///    dynamic (load-time).
    ///  </summary>
    property Time: TSymbolTime read getTime write setTime;

    ///  <summary>
    ///    The bind attributes represent the type of symbol, and provide information
    ///    regarding its visibility when the Visibility property is TSymbolVisbility.svDefault.
    ///  </summary>
    property BindAttributes: TSymbolBindAttributes read getBindAttributes write setBindAttributes;

    ///  <summary>
    ///    Describes the visibility of the symbol to other image files.
    ///  </summary>
    property Visibility: TSymbolVisibility read getVisibility write setVisibility;

    ///  <summary>
    ///    The symbol references something within a section of the image file or
    ///    image when loaded. This references the section in which the target
    ///    of this symbol resides.
    ///  </summary>
    property Section: ISection read getSection write setSection;

    ///  <summary>
    ///    The symbol value depends on the binary image type and/or state.
    ///    For a linkable image, the value is the offset to the target of the
    ///    symbol within the section specified by the 'Section' property. <br/>
    ///    When the image is executable or dynamically loaded, the value is
    ///    the virtual address of the target.
    ///  </summary>
    property Value: TVirtualAddress read getValue write setValue;
  end;

{$endregion}

{$region ' IVirtualSection '}

type
  ///  <summary>
  ///    Represents a virtual section, such as the .BBS section.
  ///  </summary>
  IVirtualSection = interface( ISection )
  ['{10EC26BA-8AA8-4152-AB46-F9EF916BCE1D}']

    {$region ' Getters / Setters '}
    /// <exclude/>
    function getSize: TVirtualSize;
    /// <exclude/>
    procedure setSize( const Value: TVirtualSize );
    {$endregion}

    ///  <summary>
    ///    The size (virtual address space) to allocate for this section
    ///    when the image is loaded.
    ///  </summary>
    property Size: TVirtualSize read getSize write setSize;

  end;

{$endregion}

{$region ' IRelocation '}

type
  ///  <summary>
  ///  </summary>
  IRelocation = interface
  ['{8D806274-851E-4ECB-A468-5F9DF954F87F}']

    {$region ' Getters / Setters '}
    ///  <exclude/>
    function getOffset: TVirtualAddress;
    ///  <exclude/>
    procedure setOffset( const value: TVirtualAddress );
    ///  <exclude/>
    function getSymbol: ISymbol;
    ///  <exclude/>
    procedure setSymbol( const value: ISymbol );
    ///  <exclude/>
    function getSection: ISection;
    ///  <exclude/>
    procedure setSection( const value: ISection );
    ///  <exclude/>
    function getAddend: int64;
    ///  <exclude/>
    procedure setAddend( const value: int64 );
    ///  <exclude/>
    function getRelocationType: uint32;
    ///  <exlcude/>
    procedure setRelocationType( const Value: uint32 );
    {$endregion}

    ///  <summary>
    ///    The section which contains the value that requires relocating.
    ///  </summary>
    property Section: ISection read getSection write setSection;

    ///  <summary>
    ///    The symbol that this relocation is related to.
    ///  </summary>
    property Symbol: ISymbol read getSymbol write setSymbol;

    ///  <summary>
    ///    The relocation types availabe, varies depending on the target CPU. <br/>
    ///    A loader for a given type of binary image will set this value, and
    ///    an instance of IRelocator will later make use of it to determine
    ///    how the relocation should be performed. <br/>
    ///  </summary>
    property RelocationType: uint32 read getRelocationType write setRelocationType;

    ///  <summary>
    ///    The offset (from the start of 'Section') at which the relocation
    //     needs to be applied.
    ///  </summary>
    property Offset: TVirtualAddress read getOffset write setOffset;

    ///  <summary>
    ///    Provides a displacement for the relocation
    ///  </summary>
    property Addend: int64 read getAddend write setAddend;
  end;

{$endregion}

{$region ' IRelocator '}

type
  ///  <summary>
  ///    CPU specific implementations understand the relocation mechanisms for
  ///    a given ABI, and can be used by writers to perform relocation.
  ///  </summary>
  IRelocator = interface
  ['{993E56C5-B36C-4603-8595-1FE15653208B}']

    ///  <summary>
    ///    The relocations parameter is a list type, but expects a single
    ///    relocation to be provided. The reason for the list is that some
    ///    target architectures use multiple relocation records, which share
    ///    the same target offset, to provide the parameters for calculating
    ///    a single relocation value. In these cases, you may supply all of
    ///    the relocation records, which comprise a single relocation result. <br/>
    ///    <br/>
    ///    Provide a stream into which the relocation should be written, via the
    ///    'TargetStream' parameter. The stream should already be positioned at
    ///    the location at which this relocation should be written. Relocations
    ///    vary in size and type - for instance, some targets / relocation types
    ///    may require a 32-bit unsigned integer to be written, others may
    ///    require a signed integer. The relocator understands which type is
    ///    required and will write precisely that type to the stream. <br/>
    ///  </summary>
    function Relocate( const Relocations: IReadOnlyList< IRelocation >; const TargetStream: IStream ): TStatus;
  end;

{$endregion}

{$region ' IContentSection '}

type
  ///  <summary>
  ///    Represents a section containing data.
  ///  </summary>
  IContentSection = interface( ISection )
  ['{8916A49D-D10D-4E7C-AD05-B0D33A4DC8E5}']

    {$region ' Getters / Setters '}
    /// <exclude/>
    function getContent: IReadOnlyUnicodeStream;
    /// <exclude/>
    procedure setContent( const Value: IReadOnlyUnicodeStream );
    {$endregion}

    ///  <summary>
    ///    Returns a stream containing the content of the section.
    ///  </summary>
    property Content: IReadOnlyUnicodeStream read getContent write setContent;

  end;

{$endregion}

{$region ' IBinaryImage '}

type
  ///  <summary>
  ///    Represents a binary image file such as an Elf32/64 or PE/PE32+ <br/>
  ///  </summary>
  IBinaryImage = interface
  ['{909CA5B7-C73B-4D98-9A65-1EDE82C0F321}']

    {$region ' Getters / Setters '}
      ///  <exclude/>
      function getFilepath: string;
      ///  <exclude/>
      procedure setFilepath( const value: string );
      ///  <exclude/>
      function getEndianness: TEndianness;
      ///  <exclude/>
      procedure setEndianness( const value: TEndianness );
      ///  <exclude/>
      function getBittedness: TBittedness;
      ///  <exclude/>
      procedure setBittedness( const value: TBittedness );
      ///  <exclude/>
      function getPreferredAddress: TVirtualAddress;
      ///  <exclude/>
      procedure setPreferredAddress( const value: TVirtualAddress );
    {$endregion}

    ///  <summary>
    ///     Returns a list of sections contained within the image.
    ///  </summary>
    function Sections: IList< ISection >;

    ///  <summary>
    ///    Convenience method to add a virtual section to the sections list
    ///    and be given back a reference to it.
    ///  </summary>
    function AddVirtualSection( const Size: TVirtualSize ): IVirtualSection;

    ///  <summary>
    ///    Convenience method to add a content section to the sections list
    ///    and be given back a reference to it.
    ///  </summary>
    function AddContentSection( const Content: IReadOnlyUnicodeStream ): IContentSection;

    ///  <summary>
    ///    Stores a list of both static and dynamic symbols for the image.
    ///  </summary>
    function Symbols: IList< ISymbol >;

    ///   <summary>
    ///    Stores a list of relocations.
    ///   </summary>
    function Relocations: IList< IRelocation >;

    ///   <summary>
    ///     Adds an instance of IRelocation to the relocations list.
    ///   </summary>
    function AddRelocation: IRelocation;

    ///  <summary>
    ///    Convenience method to add a symbol to the image. <br/>
    ///    ISymbol is simply a storage container, and as such, symbol
    ///    names may be null-string - but must be resolved before linking.
    ///  </summary>
    function AddSymbol( const Name: string ): ISymbol;

    ///  <summary>
    ///    Essentially ignored during linking, string lists is a dictionary
    ///    of lists of strings. This dictionary may be used by readers or
    ///    writers to provide the string data required to name sections or
    ///    symbols (or anything else).
    ///  </summary>
    function StringLists: IStringLists;

    ///  <summary>
    ///    Writes the contents of a section to the target stream,
    ///    applying relocations as the data is written. <br/>
    ///    Provide a 'TargetStream' to write the data into. <br/>
    ///    Provide an instance of 'IContentSection' to the 'Section' parameter,
    ///    which contains the data to write. <br/>
    ///    Provide a list of relocations to be applied to the stream data. <br/>
    ///    CAUTION: As relocation values are calculated, the calculation depends
    ///    on several values. The section RVA property is added to the relocation
    ///    offset to determine the location at which the relocation should be
    ///    applied, and thus, the section RVA property must have been set. As the
    ///    symbol to be applied may exist in another section, it's RVA must also
    ///    have been set in order that the symbol be located. In addition, some
    ///    relocation calculations may depend on the image base address, thus,
    ///    it must be set also. In short, ensure that the image base address is
    ///    set and that all sections have been aligned to their target virtual
    ///    address space before calling this method to write the section content.
    ///  </summary>
    function WriteSectionContent( const Relocator: IRelocator; const TargetStream: IStream; const Section: IContentSection; const Relocations: IReadOnlyList< IRelocation > ): TStatus;

    ///  <summary>
    ///    The path to a file which this image represents.
    ///  </summary>
    property Filepath: string read getFilepath write setFilepath;

    ///  <summary>
    ///    Does this image represent big-endian or little-endian code?
    ///  </summary>
    property Endianness: TEndianness read getEndianness write setEndianness;

    ///  <summary>
    ///    Does this image represent 32-bit or 64-bit code?
    ///  </summary>
    property Bittedness: TBittedness read getBittedness write setBittedness;

    ///  <summary>
    ///    The preferred base address in virtual memory when the image is
    ///    loaded by a loader.
    ///  </summary>
    property PreferredAddress: TVirtualAddress read getPreferredAddress write setPreferredAddress;
  end;

{$endregion}

{$region ' TBinaryImage (factory) '}

type
  TBinaryImage = record
    class function Create( const Filepath: string ): IBinaryImage; static;
  end;

{$endregion}

implementation
uses
  utlLinker.BinaryImage.Standard
;

class function TBinaryImage.Create( const Filepath: string ): IBinaryImage;
begin
  Result := utlLinker.BinaryImage.Standard.TBinaryImage.Create( Filepath );
end;

end.
