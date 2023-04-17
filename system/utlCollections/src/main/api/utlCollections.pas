(*
  @author Craig Chapman for ChapmanWorld LLC.
  Property of ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCollections;

interface

{$region ' Status messages '}

const
  stDictionaryKeyNotFound: TGUID = '{BF72E82F-7A9C-4200-9B27-31C96659D1C0}';

{$endregion}

{$region ' TCompareFunction '}

type
  TCompareResult = (
      crEqual
    , crAIsLess
    , crBIsLess
  );

type
  ///  <summary>
  ///    Because Delphi's implementation of generics is particularly stupid,
  ///    it is necessary to provide a comparison function to some methods of
  ///    collections in order to compare two values of the same type. <br/>
  ///  </summary>
  TCompareFunction< T > = reference to function ( const A: T; const B: T ): TCompareResult;

{$endregion}

{$region ' IReadOnlyRingBuffer< T > '}

type
  /// <summary>
  ///   A ring buffer is a FIFO buffer of pre-determined size. <br />This
  ///   interface represents the read-only methods of a ring buffer, and may
  ///   therefore be used as a read-only property on another object/interface.
  /// </summary>
  /// <typeparam name="T">
  ///   The data-type of the items to be stored within the buffer.
  /// </typeparam>
  /// <remarks>
  ///   ** Note: Unlike other read-only collection interfaces, the Pull()
  ///   method on a read-only ring buffer is destructive, in-that it removes an
  ///   item from the buffer.
  /// </remarks>
  IReadOnlyRingBuffer< T > = interface
    ['{B26BFBD9-7293-48F0-9C04-CCF07E902924}']

    /// <summary>
    ///   Returns true if the buffer is empty, else returns false.
    /// </summary>
    /// <returns>
    ///   Returns true if the ring buffer not empty, else returns false.
    /// </returns>
    function IsEmpty: boolean;

    /// <summary>
    ///   Retrieves and removes an item from the ring buffer.
    /// </summary>
    /// <param name="Item">
    ///   Out parameter to be populated with the item extracted from the
    ///   buffer.
    /// </param>
    /// <returns>
    ///   Returns true if the item was extracted from the buffer, else returns
    ///   false.
    /// </returns>
    /// <remarks>
    ///   ** Note: Unlike other read-only collection interfaces, the
    ///   Pull()method on a read-only ring buffer is destructive, in-that it
    ///   removes an itemfrom the buffer.
    /// </remarks>
    function Pull( out Item: T ): boolean;

  end;
{$endregion}

{$region ' IRingBuffer<T> '}

type
  /// <summary>
  ///   A ring buffer is a FIFO buffer of pre-determined size.
  /// </summary>
  /// <typeparam name="T">
  ///   The data-type of the items to be stored within the buffer.
  /// </typeparam>
  IRingBuffer< T > = interface( IReadOnlyRingBuffer< T > )
    ['{44A78B5E-440D-4BC1-97E7-3C3DAB74DBB8}']

    /// <summary>
    ///   Pushes a new item into the buffer, assuming there is space to do so. <br />
    ///   If there is no space, returns false.
    /// </summary>
    /// <param name="Item">
    ///   The item to insert into the buffer.
    /// </param>
    /// <returns>
    ///   Returns true if the item was added, else returns false to indicate
    ///   that the buffer is full.
    /// </returns>
    function Push( const Item: T ): boolean;

    /// <summary>
    ///   Returns the ring buffer cast as IReadOnlyRingBuffer.
    /// </summary>
    function getAsReadOnly: IReadOnlyRingBuffer< T >;

  end;

{$endregion}

{$region ' IReadOnlyStack< T > '}

type
  /// <summary>
  ///   A stack is a FILO buffer of pre-determined size. <br />This interface
  ///   represents the read-only methods of a stack, and may therefore be used
  ///   as a read-only property on another object/interface.
  /// </summary>
  /// <typeparam name="T">
  ///   The data-type of the items to be stored in the stack.
  /// </typeparam>
  /// <remarks>
  ///   The typical behavior for a stack is for it to grow as required by the
  ///   inserted data. This behavior may differ in low-memory situations, you
  ///   should check the documentation for the stack implementation if other
  ///   than the standard implementation. <br /><br />** Note: Unlike other
  ///   read-only collection interfaces, the Pull() method on a read-only stack
  ///   is destructive, in-that it removes an item from the stack.
  /// </remarks>
  IReadOnlyStack< T > = interface
    ['{8FB4DD73-3D52-4781-9C82-0B09721CDD16}']

    ///  <summary>
    ///    Returns the number of items currently on the stack.
    ///  </summary>
    function Count: nativeuint;

    /// <summary>
    ///   Retrieves and removes an item from the top of the stack.
    /// </summary>
    /// <returns>
    ///   The item returned from the stack, or nil if no items remain.
    /// </returns>
    /// <remarks>
    ///   ** Note: Unlike other read-only collection interfaces, the
    ///   Pull()method on a read-only stack is destructive, in-that it removes
    ///   an itemfrom the stack.
    /// </remarks>
    function Pull: T;

  end;

{$endregion}

{$region ' IStack< T > '}

type
  /// <summary>
  ///   A stack is a FILO buffer.
  /// </summary>
  /// <typeparam name="T">
  ///   The data-type of the items to be stored in the stack.
  /// </typeparam>
  /// <remarks>
  ///   The typical behavior for a stack is for it to grow as required by the
  ///   inserted data. This behavior may differ in low-memory situations, you
  ///   should check the documentation for the stack implementation if other
  ///   than the standard implementation.
  /// </remarks>
  IStack< T > = interface( IReadOnlyStack< T > )
    ['{36648989-4580-4003-B773-4563F186A2B1}']

    /// <summary>
    ///   Pushes an item onto the top of the stack.
    /// </summary>
    /// <param name="Item">
    ///   The item to push onto the stack.
    /// </param>
    procedure Push( const Item: T );

    /// <summary>
    ///   Returns the ring buffer cast as IReadOnlyStack.
    /// </summary>
    function getAsReadOnly: IReadOnlyStack< T >;

  end;

{$endregion}

{$region ' IReadOnlyList< T > '}

type
  /// <summary>
  ///   Represents a list collection. <br/> Lists provide array style access to
  ///   the items within the collection. This interface represents a read-only
  ///   list by providing only the methods for read access.
  /// </summary>
  /// <typeparam name="T">
  ///   The data type of the items stored within the list.
  /// </typeparam>
  IReadOnlyList< T > = interface
    ['{88A742C2-E45E-4B4D-826E-24EEF4CF0F18}']

    ///  <summary>
    ///    This method is provided to enable the for-in syntax to be used to
    ///    iterate over items in the collection. <br/>
    ///    Note: Delphi's 'compiler-magic' handling of IEnumerable and
    ///    IEnumerable<T> is incredibly stupid.
    ///  </summary>
    function GetEnumerator: IEnumerator< T >;

    /// <summary>
    ///   Returns the number of items currently stored in the list.
    /// </summary>
    /// <returns>
    ///   The number of items currently stored in the list.
    /// </returns>
    function getCount: nativeuint;

    /// <summary>
    ///   Returns an item from the list, specified by it's index.
    /// </summary>
    /// <param name="idx">
    ///   An index into the list of items, specifying which item should be
    ///   returned.
    /// </param>
    /// <returns>
    ///   Returns an item, or else nil if the index was out of range.
    /// </returns>
    function getItem( const idx: nativeuint ): T;

    /// <summary>
    ///   Returns the list as a read-only IReadOnlyList.
    /// </summary>
    /// <returns>
    ///   A reference to the list cast as an IReadOnlyList&lt;T&gt;
    /// </returns>
    function getAsReadOnly: IReadOnlyList< T >;

    ///  <summary>
    ///    Returns true if the list contains an item which
    ///    matches the value provided.
    ///  </summary>
    function Contains( const Value: T; const Comparer: TCompareFunction< T > ): boolean;

    ///  <summary>
    ///    Searches for an item within the list, returning true if the item is found,
    ///    and false if not. If the item is found, the "FoundIdx" out parameter will
    ///    be set to the item index within the list.
    ///  </summary>
    function Find( const Value: T; out FoundIdx: nativeuint; const Comparer: TCompareFunction< T > ): boolean;

    /// <summary>
    ///   Returns the number of items within the list.
    /// </summary>
    /// <value>
    ///   The number of items within the list.
    /// </value>
    property Count: nativeuint read getCount;

    /// <summary>
    ///   Array style access to the items within the list.
    /// </summary>
    /// <param name="idx">
    ///   The index of the list item to be returned.
    /// </param>
    /// <value>
    ///   The requested item from the list, or else nil if something goes wrong
    ///   (such as index out of bounds)
    /// </value>
    property Items[ const idx: nativeuint ]: T read getItem; default;

  end;

{$endregion}

{$region ' IList< T > '}

type
  /// <summary>
  ///   Represents a list collection. <br />Lists provide array style access to
  ///   the items within the collection.
  /// </summary>
  /// <typeparam name="T">
  ///   The data-type of the items within the list, must be interface.
  /// </typeparam>
  IList< T > = interface( IReadOnlyList< T > )
    ['{2F7708B6-39A9-41CC-980A-AA653AF016D8}']

    ///  <summary>
    //     Copies all items from a compatible list to this one.
    ///  </summary>
    procedure Copy( const SourceList: IReadOnlyList< T > );

    ///  <summary>
    ///    Sorts the content of the list <br/>
    ///    Currently a merge sort algorithm.
    ///  </summary>
    procedure Sort( const Compare: TCompareFunction< T > );

    ///  <summary>
    ///    Removes all items from the list.
    ///  </summary>
    procedure Clear;

    /// <summary>
    ///   Adds an item to the list and returns it's index within the list.
    /// </summary>
    /// <param name="item">
    ///   The item to add to the list.
    /// </param>
    /// <returns>
    ///   The index of the item now added to the list.
    /// </returns>
    function Add( const item: T ): nativeuint;

    /// <summary>
    ///   Replaces the item at idx with the new item.
    /// </summary>
    /// <param name="idx">
    ///   The index of the item to be replaced.
    /// </param>
    /// <param name="item">
    ///   The new item to replace the existing item in the list.
    /// </param>
    procedure setItem( const idx: nativeuint; const item: T );

    ///  <summary>
    ///    Removes and item from the list by reference.
    ///  </summary>
    procedure Remove( const Item: T; const Comparer: TCompareFunction< T > );

    /// <summary>
    ///   Removes an item from the list as specified by it's index.
    /// </summary>
    /// <param name="idx">
    ///   The index of the item to remove from the list.
    /// </param>
    function RemoveItem( const idx: nativeuint ): boolean;

    /// <summary>
    ///   Returns the number of items currently stored in the list.
    /// </summary>
    /// <value>
    ///   The number of items in the list.
    /// </value>
    property Count: nativeuint read getCount;

    /// <summary>
    ///   Provides array style access to the items in the list.
    /// </summary>
    /// <param name="idx">
    ///   The index of an item in the list.
    /// </param>
    /// <value>
    ///   The requested item in the list, or nil if an error state occurs (such
    ///   as index out of bounds).
    /// </value>
    property Items[ const idx: nativeuint ]: T read getItem write setItem; default;

  end;

{$endregion}

{$region ' IReadOnlyStringDictionary< V > '}

type
  /// <summary>
  ///   A dictionary is a collection of key-value pairs. <br />
  ///   This interface represents a read-only dictionary in which the keys
  ///   are strings.
  /// </summary>
  /// <typeparam name="V">
  ///   Data type for the value part of each key/value pair.
  /// </typeparam>
  IReadOnlyStringDictionary< V > = interface
    ['{3E208C75-6B22-4A1E-A788-B362D001B3AB}']

    /// <exclude/> - Getter for 'Value' property.
    function getValue( const key: string ): V;

    /// <summary>
    ///   Returns the total number of items in the dictionary.
    /// </summary>
    /// <returns>
    ///   The number of items in the dictionary.
    /// </returns>
    function Count: nativeuint;

    ///  <summary>
    ///    Returns a read-only list of the keys in the dictionary.
    ///  </summary>
    function Keys: IReadOnlyList< string >;

    ///  <sumamry>
    ///    Returns a read-only list of the values in the dictionary.
    ///  </summary>
    function Values: IReadOnlyList< V >;

    /// <summary>
    ///   Returns true if there is an item with a key that matches the key
    ///   paramter, else returns false.
    /// </summary>
    /// <param name="key">
    ///   The key string of the item to return.
    /// </param>
    /// <returns>
    ///   True if the item is found by it's key string, else returns false.
    /// </returns>
    /// <remarks>
    ///   <b>Note</b> Duplicate values are always permitted. Duplicate keys are
    ///   not permitted in the dictionary.
    /// </remarks>
    function KeyExists( const key: string ): boolean;

    ///  <summary>
    ///    Returns the dictionmary as a read-only IReadOnlyDictionary.
    ///    (For use in derrived interfaces)
    ///  </summary>
    function getAsReadOnly: IReadOnlyStringDictionary< V >;

    /// <summary>
    ///   Returns the value part of an item in the dictionary, identified by
    ///   it's key string.
    /// </summary>
    /// <param name="key">
    ///   The key of the item to find in the dictionary.
    /// </param>
    /// <value>
    ///   If an item exists in the dictionary with a key to match the 'key'
    ///   index parameter, then that value is returned. Otherwise, returns nil.
    /// </value>
    property Value[ const key: string ]: V read getValue; default;

  end;

{$endregion}

{$region ' IReadOnlyGuidDictionary< V > '}

type
  /// <summary>
  ///   A dictionary is a collection of key-value pairs. <br />
  ///   This interface represents a read-only dictionary in which the keys
  ///   are TGUID.
  /// </summary>
  /// <typeparam name="V">
  ///   Data type for the value part of each key/value pair.
  /// </typeparam>
  IReadOnlyGuidDictionary< V > = interface
    ['{3E208C75-6B22-4A1E-A788-B362D001B3AB}']

    /// <exclude/> - Getter for 'Value' property.
    function getValue( const key: TGUID ): V;

    /// <summary>
    ///   Returns the total number of items in the dictionary.
    /// </summary>
    /// <returns>
    ///   The number of items in the dictionary.
    /// </returns>
    function Count: nativeuint;

    ///  <summary>
    ///    Returns a read-only list of the keys in the dictionary.
    ///  </summary>
    function Keys: IReadOnlyList< TGUID >;

    ///  <sumamry>
    ///    Returns a read-only list of the values in the dictionary.
    ///  </summary>
    function Values: IReadOnlyList< V >;

    /// <summary>
    ///   Returns true if there is an item with a key that matches the key
    ///   paramter, else returns false.
    /// </summary>
    /// <param name="key">
    ///   The key guid of the item to return.
    /// </param>
    /// <returns>
    ///   True if the item is found by it's key string, else returns false.
    /// </returns>
    /// <remarks>
    ///   <b>Note</b> Duplicate values are always permitted. Duplicate keys are
    ///   not permitted in the dictionary.
    /// </remarks>
    function KeyExists( const key: TGUID ): boolean;

    ///  <summary>
    ///    Returns the dictionmary as a read-only IReadOnlyDictionary.
    ///    (For use in derrived interfaces)
    ///  </summary>
    function getAsReadOnly: IReadOnlyGuidDictionary< V >;

    /// <summary>
    ///   Returns the value part of an item in the dictionary, identified by
    ///   it's key string.
    /// </summary>
    /// <param name="key">
    ///   The key of the item to find in the dictionary.
    /// </param>
    /// <value>
    ///   If an item exists in the dictionary with a key to match the 'key'
    ///   index parameter, then that value is returned. Otherwise, returns nil.
    /// </value>
    property Value[ const key: TGUID ]: V read getValue; default;

  end;

{$endregion}

{$region ' IStringDictionary< V > '}

type
  /// <summary>
  ///   A dictionary is a collection of key-value pairs.
  ///   This dictionary is keyed by a string.
  /// </summary>
  /// <typeparam name="V">
  ///   The data type for the value in each key/value pair.
  /// </typeparam>
  IStringDictionary< V > = interface( IReadOnlyStringDictionary< V > )
    ['{5D0EA611-6D3D-4495-B8CB-3F249AF59746}']

    /// <exclude/> - Setter for 'Value' property.
    procedure setValue( const key: string; const value: V );

    ///  <summary>
    ///    Removes a value by key.
    ///  </summary>
    procedure Remove( const Key: string );

    /// <summary>
    ///   Removes all items from the dictionary collection.
    /// </summary>
    procedure Clear;

    /// <summary>
    ///   Gets/Sets the value part of an item in the dictionary, identified by
    ///   it's key.
    /// </summary>
    /// <param name="key">
    ///   The key of the item to find in the dictionary.
    /// </param>
    /// <value>
    ///   If an item exists in the dictionary with a key to match the 'key'
    ///   index parameter, then that value is returned. Otherwise, returns nil.
    /// </value>
    property Value[ const key: string ]: V read getValue write setValue; default;
  end;

{$endregion}

{$region ' IGuidDictionary< V > '}

type
  /// <summary>
  ///   A dictionary is a collection of key-value pairs.
  ///   This dictionary uses TGUID values for the key.
  /// </summary>
  /// <typeparam name="V">
  ///   The data type for the value in each key/value pair.
  /// </typeparam>
  IGUIDDictionary< V > = interface( IReadOnlyGuidDictionary< V > )
    ['{5D0EA611-6D3D-4495-B8CB-3F249AF59746}']

    /// <exclude/> - Setter for 'Value' property.
    procedure setValue( const key: TGUID; const value: V );

    ///  <summary>
    ///    Removes a value by key.
    ///  </summary>
    procedure Remove( const Key: TGUID );

    /// <summary>
    ///   Removes all items from the dictionary collection.
    /// </summary>
    procedure Clear;

    /// <summary>
    ///   Gets/Sets the value part of an item in the dictionary, identified by
    ///   it's key.
    /// </summary>
    /// <param name="key">
    ///   The key of the item to find in the dictionary.
    /// </param>
    /// <value>
    ///   If an item exists in the dictionary with a key to match the 'key'
    ///   index parameter, then that value is returned. Otherwise, returns nil.
    /// </value>
    property Value[ const key: TGUID ]: V read getValue write setValue; default;
  end;

{$endregion}

{$region ' IContainer< Factory > '}

type
  ///  <summary>
  ///    A container of interface GUIDs and their associated factory.
  ///  </summary>
  IContainer< Factory > = interface
    ['{53FC26C3-33EB-43A6-A00A-BA8094E1E420}']

    ///  <summary>
    ///    Adds an item to the container.
    ///  </summary>
    procedure Add( const Ifce: TGUID; const F: Factory );

    ///  <summary>
    ///    Returns true if specified interface can be found in
    ///    the container.
    ///  </summary>
    function Contains( Ifce: TGUID ): boolean;

    ///  <summary>
    ///    Locates and returns the factory for an item
    ///    based on the interface guid provided.
    ///  </summary>
    function Resolve( const Ifce: TGUID ): Factory;
  end;

{$endregion}

{$region ' TList< T >' }

type
  ///  <summary>
  ///    Factory record for instancing IList<T>
  ///  </summary>
  TList< T > = record
    type TArrayOfT = array of T;
    class function Create( const Granularity: nativeuint = 32; const isOrdered: boolean = false; const isPruned: boolean = false ): IList< T >; overload; static;
    class function Create( const Items: TArrayOfT ): IList< T >; overload; static;
  end;

{$endregion}

{$region ' TRingBuffer< T > '}

type
  ///  <summary>
  ///    Factory record for instancing IRingBuffer<T>
  ///  </summary>
  TRingBuffer<T> = record
    class function Create( ItemCount: nativeuint = 128 ): IRingBuffer<T>; static;
  end;

{$endregion}

{$region ' TStack< T > '}

type
  ///  <summary>
  ///    Factory record for instancing IStack<T>
  ///  </summary>
  TStack<T> = record
    class function Create( const Granularity: nativeuint = 0; const IsPruned: boolean = false ): IStack<T>; static;
  end;

{$endregion}

{$region ' TStringDictionary< V >'}

type
  ///  <summary>
  ///    Factory record for instancing IStringDictionary< V >
  ///  </summary>
  TStringDictionary< V > = record
    class function Create( const Granularity: nativeuint = 32 ): IStringDictionary< V >; overload; static;
  end;

{$endregion}

{$region ' TGuidDictionary< V >'}

type
  ///  <summary>
  ///    Factory record for instancing IGuidDictionary< V >
  ///  </summary>
  TGuidDictionary< V > = record
    class function Create( const Granularity: nativeuint = 32 ): IGuidDictionary< V >; overload; static;
  end;

{$endregion}

implementation
uses
  utlStatus
, utlCollections.List
, utlCollections.RingBuffer
, utlCollections.Stack
, utlCollections.StringDictionary
, utlCollections.GuidDictionary
;

class function TList< T >.Create( const Granularity: nativeuint; const isOrdered: boolean; const isPruned: boolean ): IList< T >;
begin
  Result := TStandardList< T >.Create( Granularity, isOrdered, isPruned );
end;

class function TRingBuffer< T >.Create(ItemCount: nativeuint): IRingBuffer< T >;
begin
  Result := TStandardRingBuffer< T >.Create( ItemCount );
end;

class function TStack< T >.Create( const Granularity: nativeuint; const IsPruned: boolean ): IStack< T >;
begin
  Result := TStandardStack< T >.Create( Granularity, IsPruned );
end;

class function TList< T >.Create( const Items: TArrayOfT ): IList< T >;
var
  idx: nativeuint;
begin
  Result := TList< T >.Create;
  if Length( Items ) = 0 then exit;
  for idx := 0 to pred( Length( Items ) ) do Result.Add( Items[ idx ] );
end;

class function TStringDictionary< V >.Create( const Granularity: nativeuint ): IStringDictionary< V >;
begin
  Result := utlCollections.StringDictionary.TStringDictionary< V >.Create( Granularity );
end;

class function TGuidDictionary< V >.Create( const Granularity: nativeuint ): IGuidDictionary< V >;
begin
  Result := utlCollections.GuidDictionary.TGuidDictionary< V >.Create( Granularity );
end;

initialization
  TStatus.Register( stDictionaryKeyNotFound, 'Dictionary key not found.' );

end.
