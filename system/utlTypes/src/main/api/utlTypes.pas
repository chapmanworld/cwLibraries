(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlTypes;

interface
uses
  Sysutils
, utlStatus
, utlUnicode
, utlIO
;

{$region ' Status values '}

const
  stStringToHexFailed   : TGUID = '{46C8097B-48C3-43C6-9BB4-C64F8C23C37D}';
  stTypeConversionError : TGUID = '{2ABAEE65-E10B-4938-85FB-C1B38F5EFBC2}';
  stInvalidYear         : TGUID = '{412ECFC7-7D3A-47EA-B742-A25A7DDA4C4A}';
  stInvalidMonth        : TGUID = '{A3E487ED-2D20-469F-B838-B4E2E2FA07D4}';
  stInvalidDate         : TGUID = '{B7337FBE-FB42-403F-9C9F-6999CC442AA3}';
  stIndexOutOfBounds    : TGUID = '{C4F5A61B-B248-4490-8BF3-3F227433B76B}';
  stNoStreamAssigned    : TGUID = '{4B776151-CD10-42C6-BBDF-7A7663EEC908}';

{$endregion}

{$region ' Constants '}

const
  /// <summary>
  ///   A constant representing a carriage return character from the ascii set.
  /// </summary>
  CR = #13;

  /// <summary>
  ///   A constant representing a line feed character from the ascii set. <br />
  /// </summary>
  LF = #10;

  /// <summary>
  ///   A constant representing a tab feed character from the ascii set.
  /// </summary>
  TAB = #9;

  ///  <summary>
  ///    A constant representing a carrage return character followed by a line
  ///    feed character from the ascii set.
  ///  </summary>
  CRLF: string = CR + LF;

  /// <summary>
  ///   A constant representing a space character from the ascii set.
  /// </summary>
  SPACE = ' ';

  ///  <summary>
  ///    The default whitepsace characters used when trimming strings.
  ///  </summary>
  DefaultWhitespace: array of char = [ ' ', TAB, CR, LF ];

  ///  <summary>
  ///    Array of characters which are valid as part of a hex number.
  ///  </summary>
  HexChars: array of char = [ '0','1','2','3','4','5','6','7','8','9', 'a','b','c','d','e','f','A','B','C','D','E','F' ];

{$endregion}

{$region ' TArrayOfString '}

type
  ///  <summary>
  ///    This alias for dynamic array of string allows for a type helper,
  ///    see TArrayOfStringHelper.
  ///  </summary>
  TArrayOfString = array of string;

{$endregion}

{$region ' TInt8Helper '}

type
  TInt8Helper = record helper for int8
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  public

    /// <summary>
    ///   Returns the value as a series of hex digits.
    /// </summary>
    /// <remarks>
    ///   Returns two hex digits, and expects two or fewer hex digits.
    /// </remarks>
    function AsHex: string;

    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TInt16Helper '}

type
  TInt16Helper = record helper for int16
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  public

    /// <summary>
    ///   Returns the value as a series of hex digits.
    /// </summary>
    /// <remarks>
    ///   Returns two hex digits, and expects two or fewer hex digits.
    /// </remarks>
    function AsHex: string;

    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TInt32Helper '}

type
  TInt32Helper = record helper for int32
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  public

    /// <summary>
    ///   Returns the value as a series of hex digits.
    /// </summary>
    /// <remarks>
    ///   Returns two hex digits, and expects two or fewer hex digits.
    /// </remarks>
    function AsHex: string;

    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TInt64Helper '}

type
  TInt64Helper = record helper for int64
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  public

    /// <summary>
    ///   Returns the value as a series of hex digits.
    /// </summary>
    /// <remarks>
    ///   Returns two hex digits, and expects two or fewer hex digits.
    /// </remarks>
    function AsHex: string;

    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TNativeIntHelper '}

type
  TNativeIntHelper = record helper for nativeint
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  public
    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TUInt8Helper '}

type
  TUInt8Helper = record helper for uint8
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  public

    /// <summary>
    ///   Return the value as a series of hex digits.
    /// </summary>
    /// <remarks>
    ///   Returns two hex digits, and expects two or fewer hex digits.
    /// </remarks>
    function AsHex: string;

    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TUInt16Helper '}

type
  TUInt16Helper = record helper for uint16
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  public
    /// <summary>
    ///   Returns the value as a series of hex digits.
    /// </summary>
    /// <remarks>
    ///   Returns four hex digits, and expects four or fewer hex digits.
    /// </remarks>
    function AsHex: string;

    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TUInt32Helper '}

type
  TUInt32Helper = record helper for uint32
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  public

    /// <summary>
    ///   Returns the value as a series of hex digits.
    /// </summary>
    /// <remarks>
    ///   Returns eight hex digits, and expects eight or fewer hex digits.
    /// </remarks>
    function AsHex: string;

    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TUInt64Helper '}

type
  TUInt64Helper = record helper for uint64
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  public

    /// <summary>
    ///   Returns the value as a series of hex digits.
    /// </summary>
    /// <remarks>
    ///   Returns sixteen hex digits, and expects sixteen or fewer hex digits.
    /// </remarks>
    function AsHex: string;

    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TNativeUIntHelper '}

type
  TNativeUIntHelper = record helper for nativeuint
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    function getAsDouble: double;
    function getAsBoolean: boolean;
    procedure setAsBoolean( const value: boolean );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    {$endregion}
  public
    /// <summary>
    ///   Sets the nativeuint as a pointer.
    /// </summary>
    class function FromPointer( const value: pointer ): nativeuint; static;

    ///  <summary>
    ///    Casts the nativeuint as a pointer
    ///  </summary>
    function AsPointer: pointer;

    /// <summary>
    ///   Return the value as a series of hex digits.
    /// </summary>
    /// <remarks>
    ///   Returns eight hex digits for 32-bits or sixteeen hex digits for 64-bits.
    /// </remarks>
    function AsHex: string;

    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsSingle: single         read getAsSingle;
    property AsDouble: double         read getAsDouble;
    property AsBoolean: boolean       read getAsBoolean    write setAsBoolean;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TGUIDHelper ' }

type
  TGUIDHelper = record helper for TGUID
  private
    {$region ' Getters / Setters for properties. '}
    function getAsString: string;
    procedure setAsString( const value: string );
    {$endregion}
  public

    ///  <summary>
    ///    Compare B to this GUID, return TRUE if they are the same.
    ///  </summary>
    function EqualTo( const B: TGUID ): boolean;

    ///  <summary>
    ///    Set the GUID to a newly generated value.
    ///  </summary>
    class function New: TGUID; static;

    ///  <summary>
    ///    Get / Set the guid as a string.
    ///  </summary>
    property AsString: string read getAsString write setAsString;
  end;

{$endregion}

{$region ' TSingleHelper '}

type
  TSingleHelper = record helper for single
  private
    {$region ' Getters / Setters for properties. '}
    function getAsString: string;
    procedure setAsString( const value: string );
    {$endregion}
  public
    ///  <summary>
    ///    Returns true if this single is equal to Value using
    ///    Precision as a margin for error both above and below
    ///    the value.
    ///  </summary>
    function Approximates( const Value: single; const Precision: single = 0.01 ): boolean;

    property AsString: string read getAsString write setAsString;

  end;

{$endregion}

{$region ' TDoubleHelper '}

type
  TDoubleHelper = record helper for double
  private
    {$region ' Getters / Setters for properties. '}
    function getAsString: string;
    procedure setAsString( const value: string );
    {$endregion}
  public

    ///  <summary>
    ///    Returns true if this double is equal to Value using
    ///    Precision as a margin for error both above and below
    ///    the value.
    ///  </summary>
    function Approximates( const Value: double; const Precision: double = 0.01 ): boolean;

    property AsString: string read getAsString write setAsString;
  end;

{$endregion}

{$region ' TDateTimeHelper '}

type
  /// <summary>
  ///   A helper for working with TDateTime.
  /// </summary>
  TDateTimeHelper = record helper for TDateTime
  private
    function getDate: TDateTime;
    procedure setDate( const Value: TDateTime );
    function getTime: TDateTime;
    procedure setTime( const Value: TDateTime );
  public

    ///  <summary>
    ///    Returns the current date & time as a TDateTime;
    ///  </summary>
    class function Now: TDateTime; static;

    /// <summary>
    ///   This overload of Encode allows the TDateTime to be set using discrete
    ///   components of Year, Month, Day, Hour, Minute, Second and Millisecond.
    /// </summary>
    class function Encode( const Year, Month, Day, Hour, Minute, Second, Millisecond: uint16 ): TDateTime; overload; static;

    /// <summary>
    ///   This overload of Encode allows the TDateTime to be set using discrete
    ///   components of Year, Month, and Day. The time will be set to 00:00:00
    ///   at 0 ms.
    /// </summary>
    class function Encode( const Year, Month, Day: uint16 ): TDateTime; overload; static;

    /// <summary>
    ///   This overload of Encode allows the TDateTime to be set using discrete
    ///   components of Hour, Minute, Second and Millisecond. The date will be
    ///   set to 0000-00-00.
    /// </summary>
    class function Encode( const Hour, Minute, Second, Millisecond: uint16 ): TDateTime; overload; static;

    ///  <summary>
    ///    Returns the number of seconds between this date time and the 'Other'.
    ///  </summary>
    function SecondsBetween( const Other: TDateTime ): nativeuint;

    ///  <summary>
    ///    Increment the number of milliseconds by 'Count'
    ///  </summary>
    procedure IncMillisecond( const Count: uint16 );

    ///  <summary>
    ///    Increment the number of seconds by 'Count'
    ///  </summary>
    procedure IncSecond( const Count: uint16 );

    ///  <summary>
    ///    Increment the number of minutes by 'Count'
    ///  </summary>
    procedure IncMinute( const Count: uint16 );

    ///  <summary>
    ///    Increment the number of hours by 'Count'
    ///  </summary>
    procedure IncHour( const Count: uint16 );

    ///  <summary>
    ///    Increment the number of days by 'Count'
    ///  </summary>
    procedure IncDay( const Count: uint16 );

    ///  <summary>
    ///    Increment the number of years by 'Count'
    ///  </summary>
    procedure IncYear( const Count: uint16 );

    ///  <summary>
    ///    Decrement the number of milliseconds by 'Count'
    ///  </summary>
    procedure DecMillisecond( const Count: uint16 );

    ///  <summary>
    ///    Decrement the number of seconds by 'Count'
    ///  </summary>
    procedure DecSecond( const Count: uint16 );

    ///  <summary>
    ///    Decrement the number of minutes by 'Count'
    ///  </summary>
    procedure DecMinute( const Count: uint16 );

    ///  <summary>
    ///    Decrement the number of hours by 'Count'
    ///  </summary>
    procedure DecHour( const Count: uint16 );

    ///  <summary>
    ///    Decrement the number of days by 'Count'
    ///  </summary>
    procedure DecDay( const Count: uint16 );

    ///  <summary>
    ///    Decrement the number of years by 'Count'
    ///  </summary>
    procedure DecYear( const Count: uint16 );

    /// <summary>
    ///   This overload of Decode extracts the Year, Month, Day, Hour, Minute,
    ///   Second and Millisecond components from the TDateTime.
    /// </summary>
    procedure Decode( out Year, Month, Day, Hour, Minute, Second, Millisecond: uint16 ); overload;

    /// <summary>
    ///   This overload of Decode extracts only the Year, Month and Day
    ///   components of the TDateTime, ignoring the Hour, Minute, Second and
    ///   Millisecond components.
    /// </summary>
    procedure Decode( out Year, Month, Day: uint16 ); overload;

    /// <summary>
    ///   This overload of Decode extracts the Hour, Minute, Second and
    ///   Millisecond components of the TDateTime, ignoring the Year, Month and
    ///   Day.
    /// </summary>
    procedure Decode( out Hour, Minute, Second, Millisecond: uint16 ); overload;

    ///  <summary>
    ///    Returns the date time a sa string using the 'Format' parameter to
    ///    specify how the date/time is to be encoded.
    ///  </summary>
    function Format( const FormatString: string ): string;

    /// <summary>
    ///   This property returns or sets the Date components of the TDateTime,
    ///   without affecting the Time components.
    /// </summary>
    property Date: TDateTime read getDate write setDate;

    /// <summary>
    ///   This property returns or sets the Time componets of the TDateTime,
    ///   without affecting the date components.
    /// </summary>
    property Time: TDateTime read getTime write setTime;

  end;

{$endregion}

{$region ' TCharHelper '}

type
   ///  <summary>
   ///    Utilities to enhance chars
   ///  </summary>
  TCharHelper = record helper for Char
  public
    ///  <summary>
    ///    Returns the character as a hex representation of the unicode codepoint.
    ///  </summary>
    function AsHex: string;

    ///  <summary>
    ///    Returns true if the ch char can be found in the char array.
    ///  </summary>
    function CharInArray( const Characters: array of char ): boolean;

    ///  <summary>
    ///    Returns true if the ch char can be found in the char set.
    ///  </summary>
    function CharInSet( const Characters: TSysCharSet ): boolean;
  end;

{$endregion}

{$region ' TAnsiStringHelper '}

type
  ///  <summary>
  ///    Enables conversion of ansistring to string.
  ///  </summary>
  TAnsiStringHelper = record helper for ansistring
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    procedure setAsSingle( const value: single );
    function getAsDouble: double;
    procedure setAsDouble( const value: double );
    function getAsGUID: TGUID;
    procedure setAsGUID( const value: TGUID );
    function getAsString: string;
    procedure setAsString( const value: string );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}

  public
    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle     write setAsSingle;
    property AsDouble: double         read getAsDouble     write setAsDouble;
    property AsGUID: TGUID            read getAsGUID       write setAsGUID;
    property AsString: string         read getAsString     write setAsString;
  end;

{$endregion}

{$region ' TStringHelper '}

type
  ///  <summary>
  ///    Used to specify case sensitivity for string search and manipulations.
  ///  </summary>
  TCaseSensitivity = (
    caseSensitive,
    caseInsensitive
  );

type
  ///  <summary>
  ///    Utilities to enhance strings.
  ///  </summary>
  TStringHelper = record helper for string
  private
    {$region ' Getters / Setters for properties. '}
    function getAsInt8: int8;
    procedure setAsInt8( const value: int8 );
    function getAsInt16: int16;
    procedure setAsInt16( const value: int16 );
    function getAsInt32: int32;
    procedure setAsInt32( const value: int32 );
    function getAsInt64: int64;
    procedure setAsInt64( const value: int64 );
    function getAsUint8: uint8;
    procedure setAsUint8( const value: uint8 );
    function getAsUint16: uint16;
    procedure setAsUint16( const value: uint16 );
    function getAsUint32: uint32;
    procedure setAsUint32( const value: uint32 );
    function getAsUInt64: uint64;
    procedure setAsUInt64( const value: uint64 );
    function getAsSingle: single;
    procedure setAsSingle( const value: single );
    function getAsDouble: double;
    procedure setAsDouble( const value: double );
    function getAsGUID: TGUID;
    procedure setAsGUID( const value: TGUID );
    function getAsNativeInt: nativeint;
    procedure setAsNativeInt( const value: nativeint );
    function getAsNativeUInt: nativeuint;
    procedure setAsNativeUInt( const value: nativeuint );
    {$endregion}
  private
    class function FindDelimiter(const Source: string; const Delimiters: array of string; var start, stop: nativeuint): boolean; static;
  public

    ///  <summary>
    ///    Sequentially populates markers of the four character
    ///    sequence '(%%)', with the string values provided in the
    ///    parameters array.  <br/>
    ///    for instance " S := string( 'test (%%) works' ).Populate( [ 5 ] ); "
    ///    will set S to the value 'test 5 works' <br/>
    ///    Populate is fault tollerant, meaning that if too few markers exist
    ///    for the number of parameters provided, the remaining parameters are
    ///    ignored. If too few parameters are provided, the remaining markers
    ///    are simply removed from the string. <br/>
    ///  </summary>
    function Populate( const Parameters: array of const ): string;

    ///  <summary>
    ///    Returns the length of the string.
    ///  </summary>
    function Length: nativeuint;

    ///  <summary>
    ///    Sets the string to a unique string of the specified length
    ///    using only hex characters.
    ///  </summary>
    class function Unique( const CharCount: nativeuint ): string; static;

    ///  <summary>
    ///    Searches for Left and Right, and if found, returns the
    ///    content of the string which falls between the two. <br/>
    ///    If either search string is not found, returns null string.
    ///  </summary>
    function ExtractBetween( const Left: string; const Right: string ): string;

    ///  <summary>
    ///    Pads the left side of the string with the 'ch' character until the
    ///    length of the string matches CharCount. (Unlike PadLeft which
    ///    pre-fixes the string).
    ///  </summary>
    function LeftPad( const CharCount: nativeuint; const ch: char ): string;

    ///  <summary>
    ///    Pads the right side of the string with the 'ch' character until
    ///    the length of the string matches CharCount.
    ///  </summary>
    function RightPad( const CharCount: nativeuint; const ch: char ): string;

    /// <summary>
    ///   Trims whitepsace characters from the left of the string. Whitespace
    ///   characters may be provided in the optional array parameter, or else
    ///   the default whitespace characters will be used. <br />( Space, Tab,
    ///   CR, LF )
    /// </summary>
    /// <param name="Whitespace">
    ///   Optional array of characters to consider as white space.
    /// </param>
    function TrimLeft( const Whitespace: array of char ): string; overload;
    ///<exclude/>
    function TrimLeft: string; overload;

    /// <summary>
    ///   Trims whitepsace characters from the right of the string. Whitespace
    ///   characters may be provided in the optional array parameter, or else
    ///   the default whitespace characters will be used. <br />( Space, Tab,
    ///   CR, LF )
    /// </summary>
    /// <param name="Whitespace">
    ///   Optional array of characters to consider as white space.
    /// </param>
    function TrimRight( const Whitespace: array of char ): string; overload;
    ///<exclude/>
    function TrimRight: string; overload;

    /// <summary>
    ///   Trims whitepsace characters from both the left and the right of the
    ///   string. Whitespace characters may be provided in the optional array
    ///   parameter, or else the default whitespace characters will be used. <br />
    ///   ( Space, Tab, CR, LF )
    /// </summary>
    /// <param name="Whitespace">
    ///   Optional array of characters to consider as white space.
    /// </param>
    function Trim( const Whitespace: array of char ): string; overload;
    ///  <exclude/>
    function Trim: string; overload;

    ///  <summary>
    ///    Replaces lower-case characters with upper-case characters.
    ///  </summary>
    function Uppercase: string;

    /// <summary>
    ///   Performs both Uppercase() and Trim() using the default whitepsace
    ///   characters.
    /// </summary>
    function UppercaseTrim: string;

    ///  <summary>
    ///    Replaces upper case characters with lower case charaacters
    ///  </summary>
    function Lowercase: string;

    /// <summary>
    ///   Performs both Lowercase() and Trim() using the default whitepsace
    ///   characters.
    /// </summary>
    function LowercaseTrim: string;

    /// <summary>
    ///   Returns a new string which is a copy of this one, but with the first
    ///   found instance of OldParttern replaced by NewPattern. <br />You may
    ///   optionally specify the case sensitivity of the search.
    /// </summary>
    /// <param name="OldPattern">
    ///   Test to be replaced.
    /// </param>
    /// <param name="NewPattern">
    ///   The replacement text.
    /// </param>
    /// <param name="CaseSensitivity">
    ///   (Optional) Specify case seneitivity of search.
    /// </param>
    function Replace( const OldPattern: string; const NewPattern: string; const CaseSensitivity: TCaseSensitivity = TCaseSensitivity.caseSensitive ): string;

    /// <summary>
    ///   Returns a new string which is a copy of this one, but with the all
    ///   found instances of OldParttern replaced by NewPattern. <br />You may
    ///   optionally specify the case sensitivity of the search.
    /// </summary>
    /// <param name="OldPattern">
    ///   Test to be replaced.
    /// </param>
    /// <param name="NewPattern">
    ///   The replacement text.
    /// </param>
    /// <param name="CaseSensitivity">
    ///   (Optional) Specify case seneitivity of search.
    /// </param>
    function ReplaceAll( const OldPattern: string; const NewPattern: string { const CaseSensitivity: TCaseSensitivity = TCaseSensitivity.caseSensitive } ): string;

    ///  <summary>
    ///    Returns 'ACount' characters from the left of the string.
    ///  </summary>
    function Left( const ACount: nativeuint ): string;

    ///  <summary>
    ///    Returns 'ACount' characters from the right of the string.
    ///  </summary>
    function Right( const ACount: nativeuint ): string;

    ///  <summary>
    ///    Returns 'count' characters from the position 'start' within
    ///    the string. <br/>  If there are insufficient characters between
    ///    start and the end of the string, the returned string is truncated
    ///    to the available length of characters.
    ///  </summary>
    function Copy( const start: nativeuint; const Count: nativeuint ): string;

    /// <summary>
    ///   Attempts to locate the pattern 'SubString' within this string, and if
    ///   successful, returns the start and stop character indices in the out
    ///   parameters. <br />Optionally, the search may be performed with case
    ///   insensitivity.
    /// </summary>
    /// <param name="SubString">
    ///   Pattern to search for.
    /// </param>
    /// <param name="Start">
    ///   If successfully found, this is the index of the first character of
    ///   the search pattern within the string.
    /// </param>
    /// <param name="Stop">
    ///   If succesfully found, this is the indes of the last character of the
    ///   search pattern within the string.
    /// </param>
    /// <param name="CaseSensitivity">
    ///   (Optional) You may specify the case sensitivity of the search using
    ///   the enum TCaseSensitivity.
    /// </param>
    /// <returns>
    ///   Returns TRUE if the sub-string pattern is found, else returns FALSE.
    /// </returns>
    function Find( const SubString: string; out Start: nativeuint; out Stop: nativeuint; const CaseSensitivity: TCaseSensitivity = TCaseSensitivity.caseSensitive ): boolean;

    ///  <summary>
    ///    Returns TRUE if this string contains the provided sub-string. <br/>
    ///  </summary>
    function Contains( const SubString: string; const CaseSensitivity: TCaseSensitivity = TCaseSensitivity.caseSensitive ): boolean;

    ///  <summary>
    ///    Returns the string as a system managed AnsiString type.
    ///  </summary>
    function AsAnsiString: AnsiString;

    ///  <summary>
    ///    If this string matches the provided 'positive' string, this function returns 'TRUE',
    ///    otherwise it returns FALSE.
    ///  </summary>
    function AsBoolean( const CaseSensitive: boolean; const positive: string ): boolean;

    ///  <sumamry>
    ///    Separates this string by the specified delimiter string, and returns
    ///    the results as an array of strings. <br/>
    ///    An overload allows for splitting by one of several delimiters. In this
    ///    case the delimiters are tried in the order that they are provided in
    ///    the array. If the first delimiter in the array is not found, the next
    ///    is tried, and so on.
    ///  </summary>
    function Explode( const Delimiter: string ): TArrayOfString; overload;
    ///  <exclude/>
    function Explode( const Delimiters: array of string ): TArrayOfString; overload;

    property AsInt8: int8             read getAsInt8       write setAsInt8;
    property AsInt16: int16           read getAsInt16      write setAsInt16;
    property AsInt32: int32           read getAsInt32      write setAsInt32;
    property AsInt64: int64           read getAsInt64      write setAsInt64;
    property AsNativeInt: nativeint   read getAsNativeInt  write setAsNativeInt;
    property AsUInt8: uint8           read getAsUInt8      write setAsUInt8;
    property AsUInt16: uint16         read getAsUInt16     write setAsUInt16;
    property AsUInt32: uint32         read getAsUInt32     write setAsUInt32;
    property AsUInt64: uint64         read getAsUInt64     write setAsUInt64;
    property AsNativeUInt: nativeuint read getAsNativeUInt write setAsNativeUInt;
    property AsSingle: single         read getAsSingle     write setAsSingle;
    property AsDouble: double         read getAsDouble     write setAsDouble;
    property AsGUID: TGUID            read getAsGUID       write setAsGUID;

  end;

{$endregion}

{$region ' TStreamOptions '}

type
  ///  <summary>
  ///    When saving an array of strings to a stream using the
  ///    TArrayOfStringHelper.SaveToStream() method, this enum contains
  ///    the options which may be provided to the optional "options" parameter.
  ///  </summary>
  TStreamOption = (
      soWriteBOM
    , soWriteCR
    , soWriteLF
    , soWriteZeroTerm
  );

type
  ///  <summary>
  ///    A set of options for saving to, or loading from a stream.
  ///    See TStreamOption.
  ///  </summary>
  TStreamOptions = set of TStreamOption;

{$endregion}

{$region ' TArrayOfStringHelper '}

type
  TArrayOfStringHelper = record helper for TArrayOfString
  private
    function getLength: nativeuint;
    procedure setLength( const Value: nativeuint );
  public
    ///  <summary>
    ///    Returns all items in the array as a single string, using the
    ///    optional delimiter to separate entries.
    ///  </summary>
    function Combine( const Delimiter: string = '' ): string;

    ///  <sumamry>
    ///    Trims all strings in the array.
    ///  <summary>
    procedure Trim;

    ///  <summary>
    ///    Uppercases all strings in the array.
    ///  </summary>
    procedure Uppercase;

    ///  <summary>
    ///    Lowercases all strings in the array.
    ///  </summary>
    procedure Lowercase;

    ///  <summary>
    ///    Uppercases and trims all strings in the array.
    ///  </summary>
    procedure UppercaseTrim;

    ///  <summary>
    ///    Uppercases and trims all strings in the array.
    ///  </summary>
    procedure LowercaseTrim;

    ///  <summary>
    ///    Returns TRUE only if this array contains a string which matches
    ///    the search string.
    ///  </summary>
    function Contains( const SearchString: string ): boolean;

    ///  <summary>
    ///    Removes duplicate strings from the array.
    ///  </summary>
    procedure RemoveDuplicates( const CaseSensitivity: TCaseSensitivity );

    /// <summary>
    ///   Removes a string from the array as specified by it's index.
    /// </summary>
    /// <param name="idx">
    ///   The index of the string to remove.
    /// </param>
    /// <returns>
    ///   Should always return stSuccess unless idx is out of bounds.
    /// </returns>
    function RemoveString( const idx: nativeuint ): TStatus;

    ///  <summary>
    ///    Saves the content of the string array to a unicode stream in the
    ///    specified unicode format. Optionally this method can write a
    ///    carriage return, line feed and zero terminator after each string
    ///    is written, and may also begin the streaming operation by writing
    ///    a unicode byte-order-mark (BOM).
    ///  </summary>
    function SaveToStream( const Stream: IUnicodeStream; const Format: TUnicodeFormat; const Options: TStreamOptions = []  ): TStatus;

    ///  <summary>
    ///    Loads the string list content from a unicode stream using the
    ///    specified format. If TUnicodeFormat.utfUnknown is specified,
    ///    an attempt is made to determine the unicode format automatically. <br/>
    ///    Strings will be separated in the stream using any one of the following
    ///    three characters  char(#0), Carriage Return, Line Feed. <br/>
    ///    The three line separator characters will be omitted from the loaded
    ///    strings as white-space.
    ///  </summary>
    function LoadFromStream( const Stream: IUnicodeStream; const Format: TUnicodeFormat ): TStatus;

    ///  <summary>
    ///    Get / Set the length of the array.
    ///  </summary>
    property Length: nativeuint read getLength write setLength;
  end;

{$endregion}

implementation
uses
  DateUtils
, AnsiStrings
  {$ifdef MSWINDOWS}
, WinAPI.Windows
, WinAPI.ActiveX
  {$endif}
, utlTiming
;

{$region ' Integer size constants. '}

const
  cInt8Min   = -128;
  cInt8Max   = 122;
  cInt16Min  = -32768;
  cInt16Max  = 32767;
  cInt32Min  = -2147483648;
  cInt32Max  = 2147483647;
  cInt64Max  = 9223372036854775807;
  cUInt8Max  = 255;
  cUInt16Max = 65535;
  cUInt32Max = 4294967296;

{$endregion}

{$region ' HexToString() '}

function HexToString( const value; const bytecount: nativeuint ): string;
var
  CP: utfCodepoint;
  pbyte: ^uint8;
  idx: nativeuint;
  lsn: uint8;
  msn: uint8;
begin
  Result := '';
  if bytecount = 0 then exit;
  {$hints off}
  pbyte := pointer( nativeuint( @value ) + pred( bytecount ) );
  {$hints on}
  for idx := 0 to pred( bytecount ) do begin
    lsn := ( pbyte^ and $F0 ) shr 4;
    msn := pbyte^ and $0F;
    CP.Value := lsn;
    if ( CP.Value < $0A ) then
      CP.Value := CP.Value + $30 else //- + ascii/utf '0'
      CP.Value := CP.Value + $37;     //- + ascii/utf 'A' (sub 10 for '0'..'9')
    Result := Result + char( CP );
    CP.Value := msn;
    if ( CP.Value < $0A ) then
      CP.Value := CP.Value + $30 else //- + ascii/utf '0'
      CP.Value := CP.Value + $37;     //- + ascii/utf 'A' (sub 10 for '0'..'9')
    Result := Result + char( CP );
    {$hints off}
    pbyte := pointer( nativeuint( pbyte ) - sizeof( uint8 ) );
    {$hints on}
  end;
end;

{$endregion}

{$region ' StringToHex() '}

procedure StringToHex( const src: string; var Buffer; const BufferSize: nativeuint );

  function CalcNibble( const Codepoint: uint32 ): uint8; inline;
  begin
    if ( Codepoint >= $30 ) and ( Codepoint <= $39 ) then begin // utf/ascii 0..9
      Result := CodePoint - $30;
    end else if ( Codepoint >= $41 ) and ( Codepoint <= $46 ) then begin // utf/ascii 'A'..'F'
      Result := Codepoint - $37;
    end else if ( Codepoint >= $61 ) and ( Codepoint <= $66 ) then begin // utf/ascii 'a'..'f'
      Result := Codepoint - $57;
    end else begin
      raise TStatus.CreateException( stStringToHexFailed, [ char( utfCodepoint( Codepoint ) ) ] );
    end;
  end;

var
  CP: utfCodepoint;
  DecodedBytes: nativeuint;
  Stridx: nativeuint;
  Strtop: nativeuint;
  pByte: ^uint8;
  lsn: uint8; //- least significant nibble, going to toggle 0/4 for shl.
begin
  DecodedBytes := 0;
  stridx := 1;
  strtop := src.Length;
  {$hints off}
  pByte := pointer( nativeuint( @Buffer ) + pred( BufferSize ) );
  {$hints on}
  lsn := 4;
  while ( stridx <= strtop) and ( DecodedBytes <= BufferSize ) do begin
    CP := src[ stridx ];
    if lsn = 4 then begin
      pByte^ := CalcNibble( CP.Value );
      pByte^ := pByte^ shl lsn;
      lsn := 0;
    end else begin
      pByte^ := pByte^ or CalcNibble( CP.Value );
      inc( DecodedBytes );
      {$hints off}
      pByte := pointer( nativeuint( pByte ) - sizeof( uint8 ) );
      {$hints on}
      lsn := 4;
    end;
    inc( stridx );
  end;
end;

{$endregion}

{$region ' IntegerToString '}

function IntegerToString( const Value: int64 ): string; inline;
begin
  {$warnings off} Str(value,Result); {$warnings on}
end;

{$endregion}

{$region ' UnsignedIntegerToString '}

function UnsignedIntegerToString( const Value: uint64 ): string; inline;
begin
  {$warnings off} Str(value,Result); {$warnings on}
end;

{$endregion}

{$region ' FloatToString '}

function FloatToString( const Value: extended ): string; inline;
begin
  {$warnings off} Str(value:10:10,Result); {$warnings on}
end;

{$endregion}

{$region ' DaysInMonth() '}

function DaysInMonth( const Year, Month: uint16 ): uint16; inline;
begin
  case Month of
    1, 3, 5, 7, 8, 10, 12: Result := 31;
    4, 6, 9, 11: Result := 30;
    else if ( Year mod 4 ) = 0 then Result := 29 else Result := 28;
  end;
end;

{$endregion}

{$region ' DaysInYear() '}

function DaysInYear( const Year: uint16 ): uint16; inline;
var
  idx: uint32;
begin
  Result := 0;
  for idx := 1 to 12 do Result := Result + DaysInMonth( Year, idx );
end;

{$endregion}

{$region ' EncodeDate() '}

function EncodeDate( const Year, Month, Day: uint16 ): TDateTime; inline;
// Epoch for TDateTime = 1899/12/30
const
  cEpochDays = 693974; // 1899/12/30 in days.
var
  idx: uint16;
  TotalDays: nativeuint;
begin
  if ( Year > 9999 ) then raise TStatus.CreateException( stInvalidYear, [ Year.AsString ] );
  if ( Month < 1 ) or ( Month > 12 ) then raise TStatus.CreateException( stInvalidMonth, [ Month.AsString ] );
  if ( Day < 1 ) or ( Day > DaysInMonth( Year, Month ) ) then raise TStatus.CreateException( stInvalidDate, [ Day.AsString, Month.AsString, Year.AsString] );
  TotalDays := 0;
  if Year > 0  then for idx := 0 to pred( Year ) do TotalDays := TotalDays + DaysInYear( idx );
  if Month > 1 then for idx := 1 to pred( Month ) do TotalDays := TotalDays + DaysInMonth( Year, Idx );
  {$warnings off} TotalDays := TotalDays + pred(Day); {$warnings on}
  TotalDays := TotalDays - cEpochDays;
  Double( Result ) := TotalDays;
end;

{$endregion}

{$region ' DecodeDate() '}

procedure DecodeDate( const DateTime: TDateTime; out Year, Month, Day: uint16 ); inline;
const
  cEpochDays = 693974; // 1899/12/30 in days.
var
  Days: uint16;
  TotalDays: nativeuint;
begin
  TotalDays := Trunc( DateTime ) + cEpochDays + 1;
  Year := 0;
  repeat
    Days := DaysInYear( Year );
    if TotalDays>=Days then begin
      inc( Year );
      TotalDays := TotalDays - Days;
    end;
  until TotalDays<Days;
  Month := 1;
  repeat
    Days := DaysInMonth( Year, Month );
    if TotalDays >= Days then begin
      inc( month );
      TotalDays := TotalDays - Days;
    end;
  until TotalDays<Days;
  Day := TotalDays;
end;

{$endregion}

{$region ' EncodeTime() '}

function EncodeTime( const Hour, Minute, Second, Millisecond: uint16 ): TDateTime; inline;
const
  cUnitaryDay = 1 / TTimeConstants.MillisecondsPerDay;
begin
  Double( Result  ) := (
                         ( Hour * TTimeConstants.MillisecondsPerHour ) +
                         ( Minute * TTimeConstants.MillisecondsPerMinute ) +
                         ( Second * TTimeConstants.MillisecondsPerSecond ) +
                         ( Millisecond )
                       ) * cUnitaryDay;
end;

{$endregion}

{$region ' DecodeTime() '}

procedure DecodeTime( const DateTime: TDateTime; out Hour, Minute, Second, Millisecond: uint16 ); inline;
var
  F: nativeint;
begin
  F := Trunc( ( Frac(DateTime ) * TTimeConstants.MillisecondsPerDay ) );
  Hour := ( F div TTimeConstants.MillisecondsPerHour );
  F := F mod TTimeConstants.MillisecondsPerHour;
  Minute := ( F div TTimeConstants.MillisecondsPerMinute );
  F := F mod TTimeConstants.MillisecondsPerMinute;
  Second := ( F div TTimeConstants.MillisecondsPerSecond );
  Millisecond := F mod TTimeConstants.MillisecondsPerSecond;
end;

{$endregion}

{$region ' EncodeDateTime() '}

function EncodeDateTime( const Year, Month, Day, Hour, Minute, Second, Millisecond: uint16 ): TDateTime; inline;
begin
  Result := EncodeDate( Year, Month, Day ) + EncodeTime( Hour, Minute, Second, Millisecond );
end;

{$endregion}

{$region ' DecodeDateTime() '}

procedure DecodeDateTime( const DateTime: TDateTime; out Year, Month, Day, Hour, Minute, Second, Millisecond: uint16 ); inline;
begin
  DecodeDate( DateTime, Year, Month, Day );
  DecodeTime( DateTime, Hour, Minute, Second, Millisecond );
end;

{$endregion}

{$region ' GetNow() '}

function GetNow: TDateTime; inline;
var
{$ifdef MSWINDOWS}
  SysTime: TSystemTime;
{$else}
  SysTime: TimeSpec;
  pTime: ptm;
const
  cNanosecondsPerMillisecond = 1000000;
{$endif}
begin
  {$ifdef MSWINDOWS}
  {$hints off} GetSystemTime( SysTime ); {$hints on}
  Result := EncodeDateTime( SysTime.wYear, SysTime.wMonth, SysTime.wDay, SysTime.wHour, SysTime.wMinute, SysTime.wSecond, SysTime.wMilliseconds );
  {$else}
  clock_gettime( CLOCK_REALTIME, SysTime );
  ptime := localtime( SysTime.tv_sec );
  Result := EncodeDateTime( ptime^.tm_year, ptime^.tm_mon, ptime^.tm_mday, ptime^.tm_hour, ptime^.tm_min, ptime^.tm_sec, SysTime.tv_nsec div cNanosecondsPerMillisecond );
  {$endif}
end;

{$endregion}

{$region ' VarToString() '}

(*
    Converts a TVarRec into a string. <br/>
    TVarRec is provided by "compiler magic" when passing an
    "array of const" as a parameter. For example, consider the
    well known Format() function, which takes a string and
    an "array of const" as parameters. Format inserts each of
    the provided constants into the provided string, regardless
    of their data-type. The const to string conversion is made
    possible because the compiler converts the "array of const"
    parameter into an array of TVarRec, which may then be used
    to convert each item to a string representation. <br/><br/>
    VarToString() performs the same task as Format() does internally
    to convert a TVarRec into its string representation. This is
    used to enable the TStatus() type in cwRuntime to be populated
    with place-holder values witin its translated string representation. <br/>
    <br/>
    NOTE: This is a near duplication of the same inline function within
    utlStatus. It was necessary to duplicate as utlTypes depends on
    utlStatus, and it would not be a better option to create a common
    ancestry unit.
*)
function VarToString( const VarRec: TVarRec ): string; inline;
begin
  case VarRec.vtype of
    vtInteger       : Result := string( IntToStr( VarRec.vinteger ) );
    vtBoolean       : if VarRec.vboolean then Result := 'TRUE' else Result := 'FALSE';
    vtChar          : Result := string( VarRec.vchar );
    vtWideChar      : Result := string( VarRec.VWideChar );
    vtPWideChar     : Result := string( VarRec.VPWideChar );
    vtExtended      : Result := FloatToStr( VarRec.VExtended^ );
    vtCurrency      : Result := FloatToStr( VarRec.VCurrency^ );
    vtPointer       : Result := string( IntToStr( {$hints off} nativeuint( VarRec.VPointer ) {$hints on} ) );
    vtPChar         : Result := string( VarRec.VPChar );
    vtInterface     : begin
      if SysUtils.Supports( IInterface( VarRec.VInterface ), IAsString ) then begin
        Result := ( IInterface( VarRec.VInterface ) as IAsString ).AsString;
      end else begin
        Result := '???';
      end;
    end;
    vtObject        : if SysUtils.Supports( VarRec.VObject, IAsString ) then Result := '???';
    vtClass         : Result := 'class:' + string( VarRec.VClass.Classname );
    vtString        : Result := string( VarRec.VString );
    vtWideString    : Result := string( VarRec.VWideString );
    vtAnsiString    : Result := string( AnsiStrings.StrPas( pAnsiChar( VarRec.VAnsiString ) ) );
    vtUnicodeString : Result := string( VarRec.VUnicodeString );
    else              Result := '???' ;
  end;
end;

{$endregion}

{$region ' TInt8Helper '}

function TInt8Helper.AsHex: string;
begin
  Result := HexToString( Self, sizeof( uint8 ) );
end;

function TInt8Helper.getAsInt16: int16;
begin
  Result := Self;
end;

procedure TInt8Helper.setAsInt16( const value: int16 );
begin
  if ( value < cInt8Min ) or ( value > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'int8', value ] );
  Self := Value;
end;

function TInt8Helper.getAsInt32: int32;
begin
  Result := Self;
end;

procedure TInt8Helper.setAsInt32( const value: int32 );
begin
  if ( value < cInt8Min ) or ( value > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'int8', value ] );
  Self := Value;
end;

function TInt8Helper.getAsInt64: int64;
begin
  Result := Self;
end;

procedure TInt8Helper.setAsInt64( const value: int64 );
begin
  if ( value < cInt8Min ) or ( value > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'int8', value ] );
  Self := Value;
end;

function TInt8Helper.getAsUint8: uint8;
begin
  if ( self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'uint8', Self ] );
  Result := Self;
end;

procedure TInt8Helper.setAsUint8( const value: uint8 );
begin
  if ( value > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint8', 'int8', value ] );
  Self := Value;
end;

function TInt8Helper.getAsUint16: uint16;
begin
  if ( self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'uint16', Self ] );
  Result := Self;
end;

procedure TInt8Helper.setAsUint16( const value: uint16 );
begin
  if ( value > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint16', 'int8', value ] );
  Self := Value;
end;

function TInt8Helper.getAsUint32: uint32;
begin
  if ( self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'uint32', Self ] );
  Result := Self;
end;

procedure TInt8Helper.setAsUint32( const value: uint32 );
begin
  if ( value > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'int8', value ] );
  Self := Value;
end;

function TInt8Helper.getAsUInt64: uint64;
begin
  if ( self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'uint64', Self ] );
  Result := Self;
end;

procedure TInt8Helper.setAsUInt64( const value: uint64 );
begin
  if ( value > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'int8', value ] );
  Self := Value;
end;

function TInt8Helper.getAsSingle: single;
begin
  Result := Self;
end;

function TInt8Helper.getAsDouble: double;
begin
  Result := Self;
end;

function TInt8Helper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TInt8Helper.setAsBoolean( const value: boolean );
begin
  if value then Self := 0 else Self := 1;
end;

function TInt8Helper.getAsString: string;
begin
  Result := IntegerToString( Self );
end;

procedure TInt8Helper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'int8', value ] );
end;

function TInt8Helper.getAsNativeInt: nativeint;
begin
  Result := Self;
end;

procedure TInt8Helper.setAsNativeInt( const value: nativeint );
begin
  if ( value < cInt8Min ) or ( value > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'int8', value ] );
  Self := Value;
end;

function TInt8Helper.getAsNativeUInt: nativeuint;
begin
  if ( self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'nativeuint', Self ] );
  Result := Self;
end;

procedure TInt8Helper.setAsNativeUInt( const value: nativeuint );
begin
  if ( value > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'int8', value ] );
  Self := Value;
end;

{$endregion}

{$region ' TInt16Helper '}

function TInt16Helper.AsHex: string;
begin
  Result := HexToString( Self, sizeof( uint16 ) );
end;

function TInt16Helper.getAsInt8: int8;
begin
  Result := Self;
end;

procedure TInt16Helper.setAsInt8( const value: int8 );
begin
  Self := value;
end;

function TInt16Helper.getAsInt32: int32;
begin
  Result := Self;
end;

procedure TInt16Helper.setAsInt32( const value: int32 );
begin
  if ( value < cInt16Min ) or ( value > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'int16', value ] );
  Self := value;
end;

function TInt16Helper.getAsInt64: int64;
begin
  Result := Self;
end;

procedure TInt16Helper.setAsInt64( const value: int64 );
begin
  if ( value < cInt16Min ) or ( value > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'int16', value ] );
  Self := value;
end;

function TInt16Helper.getAsUint8: uint8;
begin
  if ( self < 0 ) or ( self > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'uint8', Self ] );
  Result := Self;
end;

procedure TInt16Helper.setAsUint8( const value: uint8 );
begin
  Self := Value;
end;

function TInt16Helper.getAsUint16: uint16;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'uint16', Self ] );
  Result := Self;
end;

procedure TInt16Helper.setAsUint16( const value: uint16 );
begin
  if ( Value > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint16', 'int16', value ] );
  Self := Value;
end;

function TInt16Helper.getAsUint32: uint32;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'uint32', Self ] );
  Result := Self;
end;

procedure TInt16Helper.setAsUint32( const value: uint32 );
begin
  if ( value > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'int16', value ] );
end;

function TInt16Helper.getAsUInt64: uint64;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'uint64', Self ] );
  Result := Self;
end;

procedure TInt16Helper.setAsUInt64( const value: uint64 );
begin
  if ( value > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'int16', value ] );
  Self := Value;
end;

function TInt16Helper.getAsSingle: single;
begin
  Result := Self;
end;

function TInt16Helper.getAsDouble: double;
begin
  Result := Self;
end;

function TInt16Helper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TInt16Helper.setAsBoolean( const value: boolean );
begin
  if Value then Self := 0 else Self := 1;
end;

function TInt16Helper.getAsString: string;
begin
  Result := IntegerToString( Self );
end;

procedure TInt16Helper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'int16', value ] );
end;

function TInt16Helper.getAsNativeInt: nativeint;
begin
  Result := Self;
end;

procedure TInt16Helper.setAsNativeInt( const value: nativeint );
begin
  if ( value < cInt16Min ) or ( value > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'int16', value ] );
  Self := Value;
end;

function TInt16Helper.getAsNativeUInt: nativeuint;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'nativeuint', Self ] );
  Result := Self;
end;

procedure TInt16Helper.setAsNativeUInt( const value: nativeuint );
begin
  if ( value > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'int16', value ] );
  Self := Value;
end;

{$endregion}

{$region ' TInt32Helper '}

function TInt32Helper.AsHex: string;
begin
  Result := HexToString( Self, sizeof( uint32 ) );
end;

function TInt32Helper.getAsInt8: int8;
begin
  if ( Self < cInt8Min ) or ( Self > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'int8', Self ] );
  Result := Self;
end;

procedure TInt32Helper.setAsInt8( const value: int8 );
begin
  Self := Value;
end;

function TInt32Helper.getAsInt16: int16;
begin
  if ( Self < cInt16Min ) or ( Self > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'int16', Self ] );
  Result := Self;
end;

procedure TInt32Helper.setAsInt16( const value: int16 );
begin
  Self := Value;
end;

function TInt32Helper.getAsInt64: int64;
begin
  Result := Self;
end;

procedure TInt32Helper.setAsInt64( const value: int64 );
begin
  if ( value < cInt32Min ) or ( value > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'int32', value ] );
  Self := Value;
end;

function TInt32Helper.getAsUint8: uint8;
begin
  if ( Self < 0 ) or ( Self > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'uint8', Self ] );
  Result := Self;
end;

procedure TInt32Helper.setAsUint8( const value: uint8 );
begin
  Self := Value;
end;

function TInt32Helper.getAsUint16: uint16;
begin
  if ( Self < 0 ) or ( Self > cUInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'uint16', Self ] );
  Result := Self;
end;

procedure TInt32Helper.setAsUint16( const value: uint16 );
begin
  Self := Value;
end;

function TInt32Helper.getAsUint32: uint32;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'uint32', Self ] );
  Result := Self;
end;

procedure TInt32Helper.setAsUint32( const value: uint32 );
begin
  if ( value > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'int32', value ] );
  Self := Value;
end;

function TInt32Helper.getAsUInt64: uint64;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'uint64', Self ] );
  Result := Self;
end;

procedure TInt32Helper.setAsUInt64( const value: uint64 );
begin
  if ( value > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'int32', value ] );
  Self := Value;
end;

function TInt32Helper.getAsSingle: single;
begin
  Result := Self;
end;

function TInt32Helper.getAsDouble: double;
begin
  Result := Self;
end;

function TInt32Helper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TInt32Helper.setAsBoolean( const value: boolean );
begin
  if value then Self := 0 else Self := 1;
end;

function TInt32Helper.getAsString: string;
begin
  Result := IntegerToString( Self );
end;

procedure TInt32Helper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'int32', value ] );
end;

function TInt32Helper.getAsNativeInt: nativeint;
begin
  Result := Self;
end;

procedure TInt32Helper.setAsNativeInt( const value: nativeint );
begin
  if ( value < cInt32Min ) or ( Value > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'int32', value ] );
  Self := Value;
end;

function TInt32Helper.getAsNativeUInt: nativeuint;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'nativeuint', Self ] );
  Result := Self;
end;

procedure TInt32Helper.setAsNativeUInt( const value: nativeuint );
begin
  if ( value > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'int32', value ] );
end;

{$endregion}

{$region ' TInt64Helper '}

function TInt64Helper.AsHex: string;
begin
  Result := HexToString( Self, sizeof(uint64) );
end;

function TInt64Helper.getAsInt8: int8;
begin
  if ( Self < cInt8Min ) or ( Self > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'int8', Self ] );
  Result := Self;
end;

procedure TInt64Helper.setAsInt8( const value: int8 );
begin
  Self := Value;
end;

function TInt64Helper.getAsInt16: int16;
begin
  if ( Self < cInt16Min ) or ( Self > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'int16', Self ] );
  Result := Self;
end;

procedure TInt64Helper.setAsInt16( const value: int16 );
begin
  Self := Value;
end;

function TInt64Helper.getAsInt32: int32;
begin
  if ( Self < cInt32Min ) or ( Self > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'int32', Self ] );
  Result := Self;
end;

procedure TInt64Helper.setAsInt32( const value: int32 );
begin
  Self := Value;
end;

function TInt64Helper.getAsUint8: uint8;
begin
  if ( Self < 0 ) or ( Self > cuInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'uint8', Self ] );
  Result := Self;
end;

procedure TInt64Helper.setAsUint8( const value: uint8 );
begin
  Self := Value;
end;

function TInt64Helper.getAsUint16: uint16;
begin
  if ( Self < 0 ) or ( Self > cUint16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'uint16', Self ] );
  Result := Self;
end;

procedure TInt64Helper.setAsUint16( const value: uint16 );
begin
  Self := value;
end;

function TInt64Helper.getAsUint32: uint32;
begin
  if ( Self < 0 ) or ( Self > cUint32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'uint32', Self ] );
  Result := Self;
end;

procedure TInt64Helper.setAsUint32( const value: uint32 );
begin
  Self := Value;
end;

function TInt64Helper.getAsUInt64: uint64;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'uint64', Self ] );
  Result := Self;
end;

procedure TInt64Helper.setAsUInt64( const value: uint64 );
begin
  if ( value > cInt64Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'uint64', value ] );
  Self := Value;
end;

function TInt64Helper.getAsSingle: single;
begin
  Result := Self;
end;

function TInt64Helper.getAsDouble: double;
begin
  Result := Self;
end;

function TInt64Helper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TInt64Helper.setAsBoolean( const value: boolean );
begin
  if Value then Self := 0 else Self := 1;
end;

function TInt64Helper.getAsString: string;
begin
  Result := IntegerToString( Self );
end;

procedure TInt64Helper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'int64', value ] );
end;

function TInt64Helper.getAsNativeInt: nativeint;
begin
  {$ifdef CPU32}
  if ( Self < cInt32Min ) or ( Self > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'nativeint', Self ] );
  {$endif}
  Result := Self;
end;

procedure TInt64Helper.setAsNativeInt( const value: nativeint );
begin
  Self := Value;
end;

function TInt64Helper.getAsNativeUInt: nativeuint;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'nativeuint', Self ] );
  {$ifdef CPU32}
  if ( Self > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'nativeuint', Self ] );
  {$endif}
  Result := Self;
end;

procedure TInt64Helper.setAsNativeUInt( const value: nativeuint );
begin
  Self := Value;
end;

{$endregion}

{$region ' TNativeIntHelper '}

function TNativeIntHelper.getAsInt8: int8;
begin
  if ( Self < cInt8Min ) or ( Self > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'int8', Self ] );
  Result := Self;
end;

procedure TNativeIntHelper.setAsInt8( const value: int8 );
begin
  Self := Value;
end;

function TNativeIntHelper.getAsInt16: int16;
begin
  if ( Self < cInt16Min ) or ( Self > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'int16', Self ] );
  Result := Self;
end;

procedure TNativeIntHelper.setAsInt16( const value: int16 );
begin
  Self := Value;
end;

function TNativeIntHelper.getAsInt32: int32;
begin
  if ( Self < cInt32Min ) or ( Self > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'int32', Self ] );
  Result := Self;
end;

procedure TNativeIntHelper.setAsInt32( const value: int32 );
begin
  Self := Value;
end;

function TNativeIntHelper.getAsInt64: int64;
begin
  Result := Self;
end;

procedure TNativeIntHelper.setAsInt64( const value: int64 );
begin
  {$ifdef CPU32}
  if ( value < cInt32Min ) or ( value > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'nativeint', value ] );
  {$endif}
  Self := Value;
end;

function TNativeIntHelper.getAsUint8: uint8;
begin
  if ( Self < 0 ) or ( Self > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'uint8', Self ] );
  Result := Self;
end;

procedure TNativeIntHelper.setAsUint8( const value: uint8 );
begin
  Self := value;
end;

function TNativeIntHelper.getAsUint16: uint16;
begin
  if ( Self < 0 ) or ( Self > cUInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'uint16', Self ] );
  Result := Self;
end;

procedure TNativeIntHelper.setAsUint16( const value: uint16 );
begin
  Self := Value;
end;

function TNativeIntHelper.getAsUint32: uint32;
begin
  {$ifdef CPU32}
  if ( Self < 0 ) or ( Self > cUInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'uint32', Self ] );
  {$endif}
  Result := Self;
end;

procedure TNativeIntHelper.setAsUint32( const value: uint32 );
begin
  {$ifdef CPU32}
  if ( Value > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'nativeuint', value ] );
  {$endif}
  Self := Value;
end;

function TNativeIntHelper.getAsUInt64: uint64;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'uint64', Self ] );
  Result := Self;
end;

procedure TNativeIntHelper.setAsUInt64( const value: uint64 );
begin
  {$ifdef CPU32}
  if ( Value > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'nativeuint', value ] );
  {$endif}
  Self := Value;
end;

function TNativeIntHelper.getAsSingle: single;
begin
  Result := Self;
end;

function TNativeIntHelper.getAsDouble: double;
begin
  Result := Self;
end;

function TNativeIntHelper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TNativeIntHelper.setAsBoolean( const value: boolean );
begin
  if Value then Self := 0 else Self := 1;
end;

function TNativeIntHelper.getAsString: string;
begin
  Result := IntegerToString( Self )
end;

procedure TNativeIntHelper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'nativeint', value ] );
end;

function TNativeIntHelper.getAsNativeUInt: nativeuint;
begin
  if ( Self < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'nativeuint', Self ] );
  Result := Self;
end;

procedure TNativeIntHelper.setAsNativeUInt( const value: nativeuint );
begin
  {$ifdef CPU32}
  if Value > cInt32Max then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'nativeint', value ] );
  {$endif}
  Self := Value;
end;

{$endregion}

{$region ' TUInt16Helper '}

function TUInt16Helper.AsHex: string;
begin
  Result := HexToString( Self, sizeof( uint16 ) );
end;

function TUInt16Helper.getAsInt8: int8;
begin
  if ( Self > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint16', 'int8', Self ] );
  Result := Self;
end;

procedure TUInt16Helper.setAsInt8( const value: int8 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'uint16', value ] );
  Self := value;
end;

function TUInt16Helper.getAsInt16: int16;
begin
  if ( Self > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint16', 'int16', Self ] );
  Result := Self;
end;

procedure TUInt16Helper.setAsInt16( const value: int16 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'uint16', value ] );
  Self := value;
end;

function TUInt16Helper.getAsInt32: int32;
begin
  Result := Self;
end;

procedure TUInt16Helper.setAsInt32( const value: int32 );
begin
  if ( value < 0 ) or ( value > cUInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'uint16', value ] );
  Self := value;
end;

function TUInt16Helper.getAsInt64: int64;
begin
  Result := Self;
end;

procedure TUInt16Helper.setAsInt64( const value: int64 );
begin
  if ( value < 0 ) or ( value > cUInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'uint16', value ] );
  Self := value;
end;

function TUInt16Helper.getAsUint8: uint8;
begin
  if ( Self > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint16', 'uint8', Self ] );
  Result := Self;
end;

procedure TUInt16Helper.setAsUint8( const value: uint8 );
begin
  Self := value;
end;

function TUInt16Helper.getAsUint32: uint32;
begin
  Result := Self;
end;

procedure TUInt16Helper.setAsUint32( const value: uint32 );
begin
  if ( value > cUInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'uint16', value ] );
  Self := value;
end;

function TUInt16Helper.getAsUInt64: uint64;
begin
  Result := Self;
end;

procedure TUInt16Helper.setAsUInt64( const value: uint64 );
begin
  if ( value > cUInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'uint16', value ] );
  Self := value;
end;

function TUInt16Helper.getAsSingle: single;
begin
  Result := Self;
end;

function TUInt16Helper.getAsDouble: double;
begin
  Result := Self;
end;

function TUInt16Helper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TUInt16Helper.setAsBoolean( const value: boolean );
begin
  if value then Self := 0 else Self := 1;
end;

function TUInt16Helper.getAsString: string;
begin
  Result := UnsignedIntegerToString( Self );
end;

procedure TUInt16Helper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'uint16', value ] );
end;

function TUInt16Helper.getAsNativeInt: nativeint;
begin
  Result := Self;
end;

procedure TUInt16Helper.setAsNativeInt( const value: nativeint );
begin
  if ( value < 0 ) or ( value > cUInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'uint16', value ] );
  Self := value;
end;

function TUInt16Helper.getAsNativeUInt: nativeuint;
begin
  Result := Self;
end;

procedure TUInt16Helper.setAsNativeUInt( const value: nativeuint );
begin
  if ( value > cUInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'uint16', value ] );
  Self := value;
end;

{$endregion}

{$region ' TUInt32Helper '}

function TUInt32Helper.AsHex: string;
begin
  Result := HexToString( Self, sizeof( uint32 ) );
end;

function TUInt32Helper.getAsInt8: int8;
begin
  if ( Self > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'int8', Self ] );
  Result := Self;
end;

procedure TUInt32Helper.setAsInt8( const value: int8 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'uint32', value ] );
end;

function TUInt32Helper.getAsInt16: int16;
begin
  if ( Self > cInt16Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'int16', Self ] );
  Result := Self;
end;

procedure TUInt32Helper.setAsInt16( const value: int16 );
begin
  Self := Value;
end;

function TUInt32Helper.getAsInt32: int32;
begin
  if ( Self > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'int32', Self ] );
  Result := Self;
end;

procedure TUInt32Helper.setAsInt32( const value: int32 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'uint32', value ] );
  Self := Value;
end;

function TUInt32Helper.getAsInt64: int64;
begin
  Result := Self;
end;

procedure TUInt32Helper.setAsInt64( const value: int64 );
begin
  if ( value < 0 ) or ( value > cUInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'uint32', value ] );
  Self := Value;
end;

function TUInt32Helper.getAsUint8: uint8;
begin
  if ( Self > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'uint8', Self ] );
  Result := Self;
end;

procedure TUInt32Helper.setAsUint8( const value: uint8 );
begin
  Self := value;
end;

function TUInt32Helper.getAsUint16: uint16;
begin
  if ( Self > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'uint16', Self ] );
  Result := Self;
end;

procedure TUInt32Helper.setAsUint16( const value: uint16 );
begin
  Self := Value;
end;

function TUInt32Helper.getAsUInt64: uint64;
begin
  Result := Self;
end;

procedure TUInt32Helper.setAsUInt64( const value: uint64 );
begin
  if ( value > cUInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'uint32', value ] );
  Self := Value;
end;

function TUInt32Helper.getAsSingle: single;
begin
  Result := Self;
end;

function TUInt32Helper.getAsDouble: double;
begin
  Result := Self;
end;

function TUInt32Helper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TUInt32Helper.setAsBoolean( const value: boolean );
begin
  if value then Self := 0 else Self := 1;
end;

function TUInt32Helper.getAsString: string;
begin
  Result := UnsignedIntegerToString( Self );
end;

procedure TUInt32Helper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'uint32', value ] );
end;

function TUInt32Helper.getAsNativeInt: nativeint;
begin
  {$ifdef CPU32}
  if ( Self > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'nativeint', Self ] );
  {$endif}
  Result := Self;
end;

procedure TUInt32Helper.setAsNativeInt( const value: nativeint );
begin
  if ( value < 0 ) or ( value > cUInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'uint32', value ] );
  Self := value;
end;

function TUInt32Helper.getAsNativeUInt: nativeuint;
begin
  Result := Self;
end;

procedure TUInt32Helper.setAsNativeUInt( const value: nativeuint );
begin
  {$ifdef CPU64}
  if ( value > cUInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'uint32', value ] );
  {$endif}
  Self := value;
end;

{$endregion}

{$region ' TUInt64Helper '}

function TUInt64Helper.AsHex: string;
begin
  Result := HexToString( Self, sizeof( uint64 ) );
end;

function TUInt64Helper.getAsInt8: int8;
begin
  if Self > cInt8Max then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'int8', Self ] );
  Result := Self;
end;

procedure TUInt64Helper.setAsInt8( const value: int8 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'uint64', value ] );
  Self := Value;
end;

function TUInt64Helper.getAsInt16: int16;
begin
  if Self > cInt16Max then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'int16', Self ] );
  Result := Self;
end;

procedure TUInt64Helper.setAsInt16( const value: int16 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'uint64', value ] );
  Self := Value;
end;

function TUInt64Helper.getAsInt32: int32;
begin
  if Self > cInt32Max then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'int32', Self ] );
  Result := Self;
end;

procedure TUInt64Helper.setAsInt32( const value: int32 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'uint64', value ] );
  Self := Value;
end;

function TUInt64Helper.getAsInt64: int64;
begin
  if Self > cInt64Max then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'int64', Self ] );
  Result := Self;
end;

procedure TUInt64Helper.setAsInt64( const value: int64 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'uint64', value ] );
  Self := Value;
end;

function TUInt64Helper.getAsUint8: uint8;
begin
  if Self > cUInt8Max then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'uint8', Self ] );
  Result := Self;
end;

procedure TUInt64Helper.setAsUint8( const value: uint8 );
begin
  Self := value;
end;

function TUInt64Helper.getAsUint16: uint16;
begin
  if Self > cUInt16Max then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'uint16', Self ] );
  Result := Self;
end;

procedure TUInt64Helper.setAsUint16( const value: uint16 );
begin
  Self := value;
end;

function TUInt64Helper.getAsUint32: uint32;
begin
  if Self > cUInt32Max then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'uint32', Self ] );
  Result := Self;
end;

procedure TUInt64Helper.setAsUint32( const value: uint32 );
begin
  Self := value;
end;

function TUInt64Helper.getAsSingle: single;
begin
  Result := Self;
end;

function TUInt64Helper.getAsDouble: double;
begin
  Result := Self;
end;

function TUInt64Helper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TUInt64Helper.setAsBoolean( const value: boolean );
begin
  if value then Self := 0 else Self := 1;
end;

function TUInt64Helper.getAsString: string;
begin
  Result := UnsignedIntegerToString( Self );
end;

procedure TUInt64Helper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'uint64', value ] );
end;

function TUInt64Helper.getAsNativeInt: nativeint;
begin
  {$ifdef CPU32}
  if ( Self > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'nativeint', Self ] );
  {$endif}
  {$ifdef CPU64}
  if ( Self > cInt64Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'nativeint', Self ] );
  {$endif}
  Result := Self;
end;

procedure TUInt64Helper.setAsNativeInt( const value: nativeint );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'uint64', value ] );
  Self := value;
end;

function TUInt64Helper.getAsNativeUInt: nativeuint;
begin
  {$ifdef CPU32}
  if ( Self > cUInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'nativeuint', Self ] );
  {$endif}
  Result := Self;
end;

procedure TUInt64Helper.setAsNativeUInt( const value: nativeuint );
begin
  Self := Value;
end;

{$endregion}

{$region ' TNativeUIntHelper '}

class function TNativeUIntHelper.FromPointer( const value: pointer ): nativeuint;
begin
  {$hints off} Result := nativeuint( value ); {$hints on}
end;

function TNativeUIntHelper.AsPointer: pointer;
begin
  {$hints off} Result := pointer( self ); {$hints on}
end;

{$warnings off}
{$hints off}
function TNativeUIntHelper.AsHex: string;
var
  u32: uint32;
  u64: uint64;
begin
  if sizeof( nativeuint ) = sizeof( uint32 ) then begin
    u32 := Self;
    Result := u32.AsHex;
  end else if sizeof( nativeuint ) = sizeof( uint64 ) then begin
    u64 := Self;
    Result := u64.AsHex;
  end;
end;
{$hints on}
{$warnings on}

function TNativeUIntHelper.getAsInt8: int8;
begin
  if Self > cInt8Max then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'int8', Self ] );
  Result := Self;
end;

procedure TNativeUIntHelper.setAsInt8( const value: int8 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'nativeuint', value ] );
  Self := value;
end;

function TNativeUIntHelper.getAsInt16: int16;
begin
  if Self > cInt16Max then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'int16', Self ] );
  Result := Self;
end;

procedure TNativeUIntHelper.setAsInt16( const value: int16 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'nativeuint', value ] );
  Self := value;
end;

function TNativeUIntHelper.getAsInt32: int32;
begin
  if Self > cInt32Max then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'int32', Self ] );
  Result := Self;
end;

procedure TNativeUIntHelper.setAsInt32( const value: int32 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'nativeuint', value ] );
  Self := value;
end;

function TNativeUIntHelper.getAsInt64: int64;
begin
  Result := Self;
end;

procedure TNativeUIntHelper.setAsInt64( const value: int64 );
begin
  {$ifdef CPU32}
  if ( value > cUInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'nativeuint', value ] );
  {$endif}
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'nativeuint', value ] );
  Self := value;
end;

function TNativeUIntHelper.getAsUint8: uint8;
begin
  if ( Self ) > cUInt8MAx then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'uint8', Self ] );
  Result := Self;
end;

procedure TNativeUIntHelper.setAsUint8( const value: uint8 );
begin
  Self := value;
end;

function TNativeUIntHelper.getAsUint16: uint16;
begin
  if ( Self ) > cUInt16Max then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'uint16', Self ] );
  Result := Self;
end;

procedure TNativeUIntHelper.setAsUint16( const value: uint16 );
begin
  Self := value;
end;

function TNativeUIntHelper.getAsUint32: uint32;
begin
  {$ifdef CPU64}
  if ( Self ) > cUInt32Max then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'uint32', Self ] );
  {$endif}
  Result := Self;
end;

procedure TNativeUIntHelper.setAsUint32( const value: uint32 );
begin
  Self := value;
end;

function TNativeUIntHelper.getAsUInt64: uint64;
begin
  Result := Self;
end;

procedure TNativeUIntHelper.setAsUInt64( const value: uint64 );
begin
  {$ifdef CPU32}
  if ( value ) > cUInt32Max then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'nativeuint', value ] );
  {$endif}
  Self := Value;
end;

function TNativeUIntHelper.getAsSingle: single;
begin
  Result := Self;
end;

function TNativeUIntHelper.getAsDouble: double;
begin
  Result := Self;
end;

function TNativeUIntHelper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TNativeUIntHelper.setAsBoolean( const value: boolean );
begin
  if Value then Self := 0 else Self := 1;
end;

function TNativeUIntHelper.getAsString: string;
begin
  Result := UnsignedIntegerToString( Self );
end;

procedure TNativeUIntHelper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'nativeuint', value ] );
end;

function TNativeUIntHelper.getAsNativeInt: nativeint;
begin
  {$ifdef CPU32}
  if ( Self > cInt32Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'nativeint', Self ] );
  {$endif}
  {$ifdef CPU64}
  if ( Self > cInt64Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'nativeint', Self ] );
  {$endif}
  Result := Self;
end;

procedure TNativeUIntHelper.setAsNativeInt( const value: nativeint );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'nativeuint', value ] );
  Self := Value;
end;

{$endregion}

{$region ' TGUIDHelper '}

type
  TConvertGUID = record
    P1: uint32;
    P2: uint16;
    P3: uint16;
    P4a: uint8;
    P4b: uint8;
    P5a: uint8;
    P5b: uint8;
    P5c: uint8;
    P5d: uint8;
    P5e: uint8;
    P5f: uint8;
  end;
  pConvertGUID = ^TConvertGUID;

function TGUIDHelper.getAsString: string;
begin
  Result :=
    '{'+
    pConvertGUID( @Self )^.P1.AsHex+'-'+
    pConvertGUID( @Self )^.P2.AsHex+'-'+
    pConvertGUID( @Self )^.P3.AsHex+'-'+
    pConvertGUID( @Self )^.P4a.AsHex+
    pConvertGUID( @Self )^.P4b.AsHex+'-'+
    pConvertGUID( @Self )^.P5a.AsHex+
    pConvertGUID( @Self )^.P5b.AsHex+
    pConvertGUID( @Self )^.P5c.AsHex+
    pConvertGUID( @Self )^.P5d.AsHex+
    pConvertGUID( @Self )^.P5e.AsHex+
    pConvertGUID( @Self )^.P5f.AsHex+
    '}';
end;

procedure TGUIDHelper.setAsString( const value: string );

  procedure ConvertPart( const src: string; var idx: nativeuint; const chars: nativeuint; var R );
  var
    idy: nativeuint;
    P: string;
  begin
    P := '';
    for idy := 0 to pred( chars ) do begin
      if not src[ idx ].CharInArray( HexChars ) then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'guid', value ] );
      P := P + src[ idx ];
      inc( idx );
    end;
    StringToHex( P, R, ( chars div 2 ) );
  end;

  procedure Expect( const src: string; var idx: nativeuint; const c: char );
  begin
    if src[ idx ] <> c then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'guid', value ] );
    inc( idx );
  end;

var
  idx: nativeuint;
  S: string;
begin
  S := Value.UppercaseTrim;
  if S.Length <> 38 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'guid', value ] );
  idx := 1;
  Expect( S, idx, '{' );
  ConvertPart( S, idx, 8, pConvertGUID( @Self )^.P1 );
  Expect( S, idx, '-' );
  ConvertPart( S, idx, 4, pConvertGUID( @Self )^.P2 );
  Expect( S, idx, '-' );
  ConvertPart( S, idx, 4, pConvertGUID( @Self )^.P3 );
  Expect( S, idx, '-' );
  ConvertPart( S, idx, 2, pConvertGUID( @Self )^.P4a );
  ConvertPart( S, idx, 2, pConvertGUID( @Self )^.P4b );
  Expect( S, idx, '-' );
  ConvertPart( S, idx, 2, pConvertGUID( @Self )^.P5a );
  ConvertPart( S, idx, 2, pConvertGUID( @Self )^.P5b );
  ConvertPart( S, idx, 2, pConvertGUID( @Self )^.P5c );
  ConvertPart( S, idx, 2, pConvertGUID( @Self )^.P5d );
  ConvertPart( S, idx, 2, pConvertGUID( @Self )^.P5e );
  ConvertPart( S, idx, 2, pConvertGUID( @Self )^.P5f );
end;

function TGUIDHelper.EqualTo( const B: TGUID ): boolean;
begin
  Result := IsEqualGUID( B, Self );
end;

class function TGUIDHelper.New: TGUID;
begin
  {$ifdef MSWINDOWS}
    CoCreateGuid( Result );
  {$else}
  uuid_generate_time_safe( Result );
  {$endif}
end;

{$endregion}

{$region ' TSingleHelper '}

function TSingleHelper.Approximates( const Value: single; const Precision: single ): boolean;
begin
  Result := ( Self > ( Value - Precision ) ) and ( Self < ( Value + Precision ) );
end;

function TSingleHelper.getAsString: string;
begin
  Result := FloatToString( Self ).Trim( [ '0' ] );
end;

procedure TSingleHelper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'single', value ] );
end;


{$endregion}

{$region ' TDoubleHelper '}

function TDoubleHelper.Approximates( const Value: double; const Precision: double ): boolean;
begin
  Result := ( Self > ( Value - Precision ) ) and ( Self < ( Value + Precision ) );
end;

function TDoubleHelper.getAsString: string;
begin
  Result := FloatToString( Self ).Trim( ['0'] );
end;

procedure TDoubleHelper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'double', value ] );
end;

{$endregion}

{$region ' TDateTimeHelper '}

class function TDateTimeHelper.Now: TDateTime;
begin
  Result := GetNow;
end;

function TDateTimeHelper.getDate: TDateTime;
var
  D: double;
begin
  D := Trunc(Double(Self));
  Result := TDateTime( D );
end;

procedure TDateTimeHelper.setDate( const Value: TDateTime );
var
  D: double;
begin
  D := Trunc( Double( Value ) ) + Frac( Double( Self ) );
  Self := TDateTime( D );
end;

function TDateTimeHelper.getTime: TDateTime;
begin
  Result := Frac( Double( Self ) );
end;

procedure TDateTimeHelper.setTime( const Value: TDateTime );
var
  D: double;
begin
  D := Trunc( Double( Self ) ) + Frac( Double( Value ) );
  Self := TDateTime( D );
end;

class function TDateTimeHelper.Encode( const Year, Month, Day, Hour, Minute, Second, Millisecond: uint16 ): TDateTime;
begin
  Result := EncodeDateTime( Year, Month, Day, Hour, Minute, Second, Millisecond );
end;

class function TDateTimeHelper.Encode( const Year, Month, Day: uint16 ): TDateTime;
begin
  Result := EncodeDate( Year, Month, Day );
end;

class function TDateTimeHelper.Encode( const Hour, Minute, Second, Millisecond: uint16 ): TDateTime;
begin
  Result := EncodeTime( Hour, Minute, Second, Millisecond ).getTime;
end;

function TDateTimeHelper.SecondsBetween( const Other: TDateTime ): nativeuint;
begin
  Result := dateutils.SecondsBetween( Self, Other );
end;

procedure TDateTimeHelper.IncMillisecond( const Count: uint16 );
begin
  Self := dateutils.IncMillisecond( Self, Count );
end;

procedure TDateTimeHelper.IncSecond( const Count: uint16 );
begin
  Self := dateutils.IncSecond( Self, Count );
end;

procedure TDateTimeHelper.IncMinute( const Count: uint16 );
begin
  Self := dateutils.IncMinute( Self, Count );
end;

procedure TDateTimeHelper.IncHour( const Count: uint16 );
begin
  Self := dateutils.incHour( Self, Count );
end;

procedure TDateTimeHelper.IncDay( const Count: uint16 );
begin
  Self := dateutils.IncDay( Self, Count );
end;

procedure TDateTimeHelper.IncYear( const Count: uint16 );
begin
  Self := dateutils.IncYear( Self, Count );
end;

procedure TDateTimeHelper.DecMillisecond( const Count: uint16 );
begin
  Self := dateutils.incMillisecond( Self, -Count );
end;

procedure TDateTimeHelper.DecSecond( const Count: uint16 );
begin
  Self := dateutils.incSecond( Self, -Count );
end;

procedure TDateTimeHelper.DecMinute( const Count: uint16 );
begin
  Self := dateutils.incMinute( Self, -Count );
end;

procedure TDateTimeHelper.DecHour( const Count: uint16 );
begin
  Self := dateutils.incHour( Self, -Count );
end;

procedure TDateTimeHelper.DecDay( const Count: uint16 );
begin
  Self := dateutils.incDay( Self, -Count );
end;

procedure TDateTimeHelper.DecYear( const Count: uint16 );
begin
  Self := dateutils.incYear( Self, -Count );
end;

procedure TDateTimeHelper.Decode( out Year, Month, Day, Hour, Minute, Second, Millisecond: uint16 );
begin
  DecodeDateTime( Self, Year, Month, Day, Hour, Minute, Second, Millisecond );
end;

procedure TDateTimeHelper.Decode( out Year, Month, Day: uint16 );
begin
  DecodeDate( Self, Year, Month, Day );
end;

procedure TDateTimeHelper.Decode( out Hour, Minute, Second, Millisecond: uint16 );
begin
  DecodeTime( Self, Hour, Minute, Second, Millisecond );
end;

function TDateTimeHelper.Format( const FormatString: string ): string;
begin
  Result := FormatDateTime( FormatString, Self );
end;

{$endregion}

{$region ' TUInt8Helper '}

function TUInt8Helper.AsHex: string;
begin
  Result := HexToString( Self, sizeof( uint8 ) );
end;

function TUInt8Helper.getAsInt8: int8;
begin
  if ( Self > cInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint8', 'int8', Self ] );
  Result := Self;
end;

procedure TUInt8Helper.setAsInt8( const value: int8 );
begin
  if ( value < 0 ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int8', 'uint8', value ] );
end;

function TUInt8Helper.getAsInt16: int16;
begin
  Result := Self;
end;

procedure TUInt8Helper.setAsInt16( const value: int16 );
begin
  if ( value < 0 ) or ( value > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int16', 'uint8', value ] );
  Self := Value;
end;

function TUInt8Helper.getAsInt32: int32;
begin
  Result := Self;
end;

procedure TUInt8Helper.setAsInt32( const value: int32 );
begin
  if ( value < 0 ) or ( value > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int32', 'uint8', value ] );
  Self := Value;
end;

function TUInt8Helper.getAsInt64: int64;
begin
  Result := Self;
end;

procedure TUInt8Helper.setAsInt64( const value: int64 );
begin
  if ( value < 0 ) or ( value > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'int64', 'uint8', value ] );
  Self := Value;
end;

function TUInt8Helper.getAsUint16: uint16;
begin
  Result := Self;
end;

procedure TUInt8Helper.setAsUint16( const value: uint16 );
begin
  if ( value > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint16', 'uint8', value ] );
  Self := Value;
end;

function TUInt8Helper.getAsUint32: uint32;
begin
  Result := Self;
end;

procedure TUInt8Helper.setAsUint32( const value: uint32 );
begin
  if ( value > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint32', 'uint8', value ] );
  Self := Value;
end;

function TUInt8Helper.getAsUInt64: uint64;
begin
  Result := Self;
end;

procedure TUInt8Helper.setAsUInt64( const value: uint64 );
begin
  if ( value > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'uint64', 'uint8', value ] );
  Self := Value;
end;

function TUInt8Helper.getAsSingle: single;
begin
  Result := Self;
end;

function TUInt8Helper.getAsDouble: double;
begin
  Result := Self;
end;

function TUInt8Helper.getAsBoolean: boolean;
begin
  Result := Self = 0;
end;

procedure TUInt8Helper.setAsBoolean( const value: boolean );
begin
  if Value then Self := 0 else Self := 1;
end;

function TUInt8Helper.getAsString: string;
begin
  Result := UnsignedIntegerToString( Self );
end;

procedure TUInt8Helper.setAsString( const value: string );
var
  C: int32;
begin
  Val( value, Self, C );
  if C <> 0 then raise TStatus( stTypeConversionError ).CreateException( [ 'string', 'uint8', value ] );
end;

function TUInt8Helper.getAsNativeInt: nativeint;
begin
  Result := Self;
end;

procedure TUInt8Helper.setAsNativeInt( const value: nativeint );
begin
  if ( value < 0 ) or ( value > cUInt8Max ) then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeint', 'uint8', value ] );
  Self := Value;
end;

function TUInt8Helper.getAsNativeUInt: nativeuint;
begin
  Result := Self;
end;

procedure TUInt8Helper.setAsNativeUInt( const value: nativeuint );
begin
  if value > cUInt8Max then raise TStatus( stTypeConversionError ).CreateException( [ 'nativeuint', 'uint8', value ] );
  Self := Value;
end;

{$endregion}

{$region ' TCharHelper '}

function TCharHelper.AsHex: string;
var
  Codepoint: TUnicodeCodepoint;
begin
  TUnicodeCodec.UTF16LEDecode( Self, Codepoint );
  Result := Codepoint.AsHex;
end;

function TCharHelper.CharInArray( const Characters: array of char ): boolean;
var
  idx: uint32;
begin
  Result := False;
  if Length( Characters )=0 then exit;
  for idx := 0 to pred( Length( Characters ) ) do
    if self = Characters[ idx ] then exit( true );
end;

function TCharHelper.CharInSet( const Characters: TSysCharSet ): boolean;
var
  C: Char;
begin
  for C in Characters do begin
    if C = Self then exit( True );
  end;
  Result := False;
end;

{$endregion}

{$region ' TAnsiStringHelper '}

function TAnsiStringHelper.getAsInt8: int8;
begin
  Result := Self.AsString.AsInt8;
end;

procedure TAnsiStringHelper.setAsInt8( const value: int8 );
begin
  Self.AsString.AsInt8 := value;
end;

function TAnsiStringHelper.getAsInt16: int16;
begin
  Result := Self.AsString.AsInt16;
end;

procedure TAnsiStringHelper.setAsInt16( const value: int16 );
begin
  Self.AsString.AsInt16 := value;
end;

function TAnsiStringHelper.getAsInt32: int32;
begin
  Result := Self.AsString.AsInt32;
end;

procedure TAnsiStringHelper.setAsInt32( const value: int32 );
begin
  Self.AsString.AsInt32 := value;
end;

function TAnsiStringHelper.getAsInt64: int64;
begin
  Result := Self.AsString.AsInt64;
end;

procedure TAnsiStringHelper.setAsInt64( const value: int64 );
begin
  Self := Value.AsString.AsAnsiString;
end;

function TAnsiStringHelper.getAsUint8: uint8;
begin
  Result := Self.AsString.AsUInt8;
end;

procedure TAnsiStringHelper.setAsUint8( const value: uint8 );
begin
  Self := Value.AsString.AsAnsiString;
end;

function TAnsiStringHelper.getAsUint16: uint16;
begin
  Result := Self.AsString.AsUInt16;
end;

procedure TAnsiStringHelper.setAsUint16( const value: uint16 );
begin
  Self := Value.AsString.AsAnsiString;
end;

function TAnsiStringHelper.getAsUint32: uint32;
begin
  Result := Self.AsString.AsUInt32;
end;

procedure TAnsiStringHelper.setAsUint32( const value: uint32 );
begin
  Self := Value.AsString.AsAnsiString;
end;

function TAnsiStringHelper.getAsUInt64: uint64;
begin
  Result := Self.AsString.AsUInt64;
end;

procedure TAnsiStringHelper.setAsUInt64( const value: uint64 );
begin
  Self := Value.AsString.AsAnsiString;
end;

function TAnsiStringHelper.getAsSingle: single;
begin
  Result := Self.AsString.AsSingle;
end;

procedure TAnsiStringHelper.setAsSingle( const value: single );
begin
  Self := Value.AsString.AsAnsiString;
end;

function TAnsiStringHelper.getAsDouble: double;
begin
  Result := Self.AsString.AsDouble;
end;

procedure TAnsiStringHelper.setAsDouble( const value: double );
begin
  Self := Value.AsString.AsAnsiString;
end;

function TAnsiStringHelper.getAsGUID: TGUID;
begin
  Result := Self.AsString.AsGUID;
end;

procedure TAnsiStringHelper.setAsGUID( const value: TGUID );
begin
  Self := Value.AsString.AsAnsiString;
end;

function TAnsiStringHelper.getAsString: string;
var
  idx: uint32;
  CP: TUnicodeCodepoint;
  B: uint8;
begin
  Result := '';
  if Length( Self ) = 0 then exit;
  CP := 0;
  for idx := 1 to Length( Self ) do begin
    B := ord( Self[ idx ] );
    if not TUnicodeCodec.AnsiDecode( B, CP ) then exit;
    if not TUnicodeCodec.EncodeCodepointToString( CP, Result ) then exit;
  end;
end;

procedure TAnsiStringHelper.setAsString( const value: string );
begin
  Self := Value.AsAnsiString;
end;

function TAnsiStringHelper.getAsNativeInt: nativeint;
begin
  Result := Self.AsString.AsNativeInt;
end;

procedure TAnsiStringHelper.setAsNativeInt( const value: nativeint );
begin
  Self := Value.AsString.AsAnsiString;
end;

function TAnsiStringHelper.getAsNativeUInt: nativeuint;
begin
  Result := Self.AsString.AsNativeUInt;
end;

procedure TAnsiStringHelper.setAsNativeUInt( const value: nativeuint );
begin
  Self := Value.AsString.AsAnsiString;
end;

{$endregion}

{$region ' TStringHelper '}

function TStringHelper.AsBoolean( const CaseSensitive: boolean; const positive: string ): boolean;
begin
  if CaseSensitive then begin
    Result := Self = positive;
  end else begin
    Result := Self.Uppercase = Positive.Uppercase;
  end;
end;

function TStringHelper.getAsDouble: double;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code <> 0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'double', Self ] );
end;

procedure TStringHelper.setAsDouble( const value: double );
begin
  Self := FloatToStr( Value );
end;

function TStringHelper.getAsGUID: TGUID;
begin
  Result.AsString := Self;
end;

procedure TStringHelper.setAsGUID( const value: TGUID );
begin
  Self := Value.AsString;
end;

function TStringHelper.getAsNativeInt: nativeint;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code <> 0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'nativeint', Self ] );
end;

procedure TStringHelper.setAsNativeInt( const value: nativeint );
begin
  Self := IntegerToString( Value );
end;

function TStringHelper.getAsNativeUInt: nativeuint;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code <> 0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'nativeuint', Self ] );
end;

procedure TStringHelper.setAsNativeUInt( const value: nativeuint );
begin
  Self := UnsignedIntegerToString( value );
end;

function TStringHelper.getAsInt8: int8;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code<>0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'int8', Self ] );
end;

procedure TStringHelper.setAsInt8( const value: int8 );
begin
  Self := IntegerToString( value );
end;

function TStringHelper.getAsInt16: int16;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code<>0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'int16', Self ] );
end;

procedure TStringHelper.setAsInt16( const value: int16 );
begin
  Self := IntegerToString( value );
end;

function TStringHelper.getAsInt32: int32;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code<>0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'int32', Self ] );
end;

procedure TStringHelper.setAsInt32( const value: int32 );
begin
  Self := IntegerToString( value );
end;

function TStringHelper.getAsInt64: int64;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code<>0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'int64', Self ] );
end;

procedure TStringHelper.setAsInt64( const value: int64 );
begin
  Self := IntegerToString( value );
end;

function TStringHelper.getAsSingle: single;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code<>0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'single', Self ] );
end;

procedure TStringHelper.setAsSingle( const value: single );
begin
  Self := FloatToStr( value );
end;

function TStringHelper.getAsUint8: uint8;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code<>0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'uint8', Self ] );
end;

procedure TStringHelper.setAsUint8( const value: uint8 );
begin
  Self := UnsignedIntegerToString( value );
end;

function TStringHelper.getAsUint16: uint16;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code<>0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'uint16', Self ] );
end;

procedure TStringHelper.setAsUint16( const value: uint16 );
begin
  Self := UnsignedIntegerToString( value )
end;

function TStringHelper.getAsUint32: uint32;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code<>0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'uint32', Self ] );
end;

procedure TStringHelper.setAsUint32( const value: uint32 );
begin
  Self := UnsignedIntegerToString( value );
end;

function TStringHelper.getAsUInt64: uint64;
var
  Code: int32;
begin
  Val( Self, Result, Code );
  if Code<>0 then raise TStatus.CreateException( stTypeConversionError, [ 'string', 'uint64', Self ] );
end;

procedure TStringHelper.setAsUInt64( const value: uint64 );
begin
  Self := UnsignedIntegerToString( value );
end;

function TStringHelper.Contains( const SubString: string; const CaseSensitivity: TCaseSensitivity ): boolean;
var
  DiscardStart: nativeuint;
  DiscardStop: nativeuint;
begin
  Result := Self.Find( SubString, DiscardStart, DiscardStop, CaseSensitivity );
end;

function TStringHelper.AsAnsiString: AnsiString;
var
  Cursor: int32;
  Stop: int32;
  CP: TUnicodeCodepoint;
  B: uint8;
  S: uint8;
begin
  Result := '';
  if Self.Length = 0 then exit;
  Cursor := 1;
  Stop := succ( Self.Length );
  CP := 0;
  S := 0;
  B := 0;
  while ( Cursor < Stop ) do begin
    if not TUnicodeCodec.DecodeCodepointFromString( CP, Self, Cursor ) then exit;
    if not TUnicodeCodec.AnsiEncode( CP, B, S ) then exit;
    Result := Result + AnsiChar( B );
  end;
end;

function TStringHelper.LeftPad( const CharCount: nativeuint; const ch: char ): string;
begin
  Result := Self;
  {$warnings off}
  if CharCount <= Result.Length then exit;
  while Result.Length < CharCount do begin
  {$warnings on}
    Result := ch + Result;
  end;
end;

function TStringHelper.Left( const ACount: nativeuint ): string;
var
  idx: nativeuint;
begin
  Result := '';
  if Self.Length = 0 then exit;
  idx := 1;
  while ( idx <= Self.Length ) and ( idx <= aCount ) do begin
    Result := Result + Self[ idx ];
    inc( idx );
  end;
end;

function TStringHelper.Populate( const Parameters: array of const ): string;
var
  idx: nativeuint;
  Start: nativeuint;
  Stop: nativeuint;
begin
  if System.Length( Parameters ) = 0 then exit( self );
  for idx := 0 to pred( System.Length( Parameters ) ) do begin
    if not Self.Find( '(%%)', Start, Stop ) then exit( self );
    Self := Self.Left( pred( Start ) ) + VarToString( Parameters[ idx ] ) + Self.Right( Self.Length - Stop );
  end;
  Result := Self;
end;

function TStringHelper.Length: nativeuint;
begin
  Result := System.Length( Self );
end;

class function TStringHelper.Unique( const CharCount: nativeuint ): string;
var
  GUID: TGUID;
  X: string;
  S: string;
  T: string;
  idx: nativeuint;
begin
  GUID := TGUID.New;
  S := GUID.AsString;
  T := '';
  for idx := 1 to S.Length do begin
    if S[ idx ].CharInSet( ['a','b','c','d','e','f','A','B','C','D','E','F','0','1','2','3','4','5','6','7','8','9'] ) then begin
      T := T + S[ idx ];
    end;
  end;
  if T.Length < CharCount then begin
    X := Unique( CharCount - T.Length );
    T := T + X;
  end;
  Result := T.Right( CharCount );
end;

class function TStringHelper.FindDelimiter( const Source: string; const Delimiters: array of string; var start: nativeuint; var stop: nativeuint ): boolean;
var
  idy: nativeuint;
begin
  for idy := 0 to pred( system.Length( Delimiters ) ) do begin
    if Source.Find( Delimiters[ idy ], start, stop ) then exit( true );
  end;
  Result := False;
end;

function TStringHelper.Explode( const Delimiters: array of string ): TArrayOfString;
const
  cResultGranularity = 8;
var
  Count: nativeuint;
  Remaining: string;
  start: nativeuint;
  stop: nativeuint;
begin
  Remaining := Self;
  Count := 0;
  SetLength( Result, 0 );
  repeat
    if FindDelimiter( Remaining, Delimiters, start, stop ) then begin
      if Count >= System.Length( Result ) then begin
        SetLength( Result, System.Length( Result ) + cResultGranularity );
      end;
      Result[ Count ] := Remaining.Left( pred( start ) );
      Remaining := Remaining.Right( Remaining.Length - stop );
      inc( Count );
    end else begin
      if Count >= System.Length( Result ) then begin
        SetLength( Result, succ( Count ) );
      end;
      Result[ Count ] := Remaining;
      inc( Count );
      break;
    end;
  until False;
  if System.Length( Result ) > Count then begin
    SetLength( Result, Count );
  end;
end;

function TStringHelper.Explode( const Delimiter: string ): TArrayOfString;
begin
  Result := Explode( [ Delimiter ] );
end;

function TStringHelper.ExtractBetween( const Left: string; const Right: string ): string;
var
  LStart: nativeuint;
  LStop: nativeuint;
  RStart: nativeuint;
  RStop: nativeuint;
begin
  Result := '';
  if not Self.Find( Left, LStart, LStop ) then exit;
  if not Self.Find( Right, RStart, RStop ) then exit;
  Result := Self.Left( pred( RStart ) );
  Result := Result.Right( Result.Length - ( LStop ) );
end;

function TStringHelper.Lowercase: string;
var
  idx: nativeuint;
  CP: utfCodepoint;
begin
  Result := '';
  if Self.Length = 0 then exit;
  for idx := 1 to Self.Length do begin
    CP := Self[ idx ];
    Result := Result + char( CP.Lowercase );
  end;
end;

function TStringHelper.LowercaseTrim: string;
begin
  Result := Self.Lowercase.Trim;
end;

function TStringHelper.Copy( const start: nativeuint; const Count: nativeuint ): string;
var
  charPos: nativeuint;
  L: nativeuint;
begin
  Result := '';
  L := Self.Length;
  if L < Start + Count then exit;
  CharPos := Start;
  while CharPos < ( Start + Count ) do begin
    Result := Result + Self[ CharPos ];
    inc( CharPos );
  end;
end;

function TStringHelper.RightPad( const CharCount: nativeuint; const ch: char ): string;
begin
  Result := Self;
  if CharCount <= Result.Length then exit;
  while Result.Length < CharCount do Result := Result + ch;
end;

function TStringHelper.Right( const ACount: nativeuint ): string;
var
  idx: nativeuint;
begin
  Result := '';
  if Self.Length = 0 then exit;
  idx := 1;
  while ( idx <= Self.Length ) and ( idx <= aCount ) do begin
    Result := Result + Self[ Self.Length - ( ACount - idx ) ];
    inc( idx );
  end;
end;

function TStringHelper.Find( const SubString: string; out Start: nativeuint; out Stop: nativeuint; const CaseSensitivity: TCaseSensitivity ): boolean;
var
  idx: nativeuint;
  pidx: nativeuint;
  ptop: nativeuint;
  InPattern: boolean;
  searchString: string;
  sourceString: string;
begin
  Result := False;
  Start := 0;
  Stop := 0;
  if SubString.Length = 0 then exit;
  if Self.Length = 0  then exit;
  if CaseSensitivity = TCaseSensitivity.caseInsensitive then begin
    searchString := SubString.Uppercase;
    sourceString := Self.Uppercase;
  end else begin
    searchString := SubString;
    sourceString := Self;
  end;
  idx := 1;
  pidx := 1;
  ptop := searchString.Length;
  InPattern := False;
  while ( not Result ) and ( idx <= sourceString.Length ) do begin
    if InPattern then begin
      if sourceString[ idx ] <> searchString[ pidx ] then begin
        Start := 0;
        pidx := 1;
        InPattern := False;
      end else begin
        inc( pidx );
        if pidx > ptop then begin
          Stop := idx;
          Result := True;
        end;
      end;
    end else begin
      if sourceString[ idx ] = searchstring[ pidx ] then begin
        Start := idx;
        if searchString.Length = 1 then begin
          Stop := Start;
          Result := True;
        end;
        inc( pidx );
        InPattern := True;
      end;
    end;
    inc( idx );
  end;
end;

function TStringHelper.Replace( const OldPattern: string; const NewPattern: string; const CaseSensitivity: TCaseSensitivity ): string;
var
  Start: nativeuint;
  Stop: nativeuint;
  L: string;
  R: string;
begin
  if Self.Find( OldPattern, Start, Stop, CaseSensitivity ) then begin
    L := Self.Left( pred( Start ) );
    R := Self.Right( Self.Length - Stop );
    Self := L + NewPattern + R;
  end;
  Result := Self;
end;

function TStringHelper.ReplaceAll( const OldPattern: string; const NewPattern: string ): string;
var
  Exploded: TArrayOfString;
begin
  if OldPattern = '' then exit;
  Exploded := Self.Explode( OldPattern );
  Self := Exploded.Combine( NewPattern );
  Result := Self;
end;

function TStringHelper.TrimLeft( const Whitespace: array of char ): string;
var
  idx: nativeuint;
  Count: nativeuint;
begin
  Result := '';
  if Self.Length = 0 then exit;
  Result := Self;
  Count := 0;
  for idx := 1 to Result.Length do begin
    if not ( Result[ idx ].CharInArray( Whitespace ) ) then break;
    inc( Count );
  end;
  if Count = Result.Length then begin
    Result := '';
    exit;
  end else begin
    Result := Result.Right( Result.Length - Count );
  end;
end;

function TStringHelper.TrimLeft: string;
begin
  Result := Self.TrimLeft( DefaultWhitespace );
end;

function TStringHelper.TrimRight( const Whitespace: array of char ): string;
var
  idx: nativeuint;
  Count: nativeuint;
begin
  Result := '';
  if Self.Length = 0 then exit;
  Result := Self;
  Count := 0;
  for idx := Result.Length downto 1 do begin
    if not ( Result[ idx ].CharInArray( Whitespace ) ) then break;
    inc( Count );
  end;
  if Count = Result.Length then begin
    Result := '';
    exit;
  end else begin
    Result := Result.Left( Result.Length - Count );
  end;
end;

function TStringHelper.TrimRight: string;
begin
  Result := Self.TrimRight( DefaultWhitespace );
end;

function TStringHelper.Trim( const Whitespace: array of char ): string;
begin
  Result := Self.TrimLeft( Whitespace ).TrimRight( WhiteSpace );
end;

function TStringHelper.Trim: string;
begin
  Result := Self.TrimLeft.TrimRight;
end;

function TStringHelper.Uppercase: string;
var
  idx: nativeuint;
  CP: utfCodepoint;
begin
  Result := '';
  if Self.Length = 0 then exit;
  for idx := 1 to Self.Length do begin
    CP := Self[ idx ];
    Result := Result + char( CP.Uppercase );
  end;
end;

function TStringHelper.UppercaseTrim: string;
begin
  Result := Self.Uppercase.Trim;
end;

{$endregion}

{$region ' TArrayOfStringHelper '}

function TArrayOfStringHelper.Combine( const Delimiter: string ): string;
var
  idx: nativeuint;
begin
  Result := '';
  if System.Length( Self ) = 0 then exit;
  for idx := 0 to pred( System.Length( Self ) ) do begin
    Result := Result + Self[ idx ];
    if idx < pred( System.Length( Self ) ) then Result := Result + Delimiter;
  end;
end;

function TArrayOfStringHelper.Contains( const SearchString: string ): boolean;
var
  S: string;
begin
  for S in Self do begin
    if S = SearchString then exit( true );
  end;
  Result := False;
end;

function TArrayOfStringHelper.getLength: nativeuint;
begin
  Result := System.Length( Self );
end;

function TArrayOfStringHelper.LoadFromStream( const Stream: IUnicodeStream; const Format: TUnicodeFormat ): TStatus;
const
  cAddStringGranularity = 8;
var
  Count: nativeuint;
  ActualFormat: TUnicodeFormat;
  Exploded: TArrayOfString;
  Item: string;
  S: string;
begin
  if not assigned( Stream ) then exit( TStatus.Return( stNoStreamAssigned, [ 'TArrayOfStringHelper.LoadFromStream()' ] ) );
  Count := 0;
  try
    ActualFormat := Format;
    if ActualFormat = TUnicodeFormat.utfUnknown then ActualFormat := Stream.DetermineUnicodeFormat;
    if ActualFormat = TUnicodeFormat.utfUnknown then raise TStatus.CreateException( stUnableToDetermineUnicodeFormat );
    Self.Length := 0;
    while not Stream.EndOfStream do begin
      S := Stream.ReadString( ActualFormat, True );
      if S.Trim = '' then continue;
      Exploded := S.Explode( [ CR+LF, CR, LF, #0 ] );
      if Exploded.Length = 0 then begin
          if Count >= Self.Length then begin
            Self.Length := Self.Length + cAddStringGranularity;
          end;
          Self[ Count ] := S;
          inc( Count );
          continue;
        end;
        for Item in Exploded do begin
          if Count >= Self.Length then begin
            Self.Length := Self.Length + cAddStringGranularity;
          end;
          Self[ Count ] := Item;
          inc( Count );
      end;
    end;
    Result := stSuccess;
  finally
    if Count > Self.Length then Self.Length := Count;
  end;
end;

procedure TArrayOfStringHelper.Lowercase;
var
  idx: nativeuint;
begin
  if Self.Length = 0 then exit;
  for idx := 0 to pred( self.Length ) do begin
    Self[ idx ] := Self[ idx ].Lowercase;
  end;
end;

procedure TArrayOfStringHelper.LowercaseTrim;
var
  idx: nativeuint;
begin
  if Self.Length = 0 then exit;
  for idx := 0 to pred( self.Length ) do begin
    Self[ idx ] := Self[ idx ].LowercaseTrim;
  end;
end;

procedure TArrayOfStringHelper.RemoveDuplicates( const CaseSensitivity: TCaseSensitivity );
var
  TempArray: TArrayOfString;
  S: string;
  Count: nativeuint;
begin
  if Self.Length = 0 then exit;
  TempArray.Length := Self.Length;
  Count := 0;
  for S in Self do begin
    if not TempArray.Contains( S ) then begin
      TempArray[ Count ] := S;
      inc( Count );
    end;
  end;
  Self.Length := Count;
  Count := 0;
  for S in TempArray do begin
    Self[ Count ] := S;
    inc( Count );
  end;
  TempArray.Length := 0;
end;

function TArrayOfStringHelper.RemoveString( const idx: nativeuint ): TStatus;
var
  idy: nativeuint;
  idz: nativeuint;
  Found: boolean;
begin
  if Self.Length = 0 then TStatus.Return( stIndexOutOfBounds, [ idx ] );
  idz := idx;
  Found := False;
  for idy := 0 to pred( Self.Length ) do begin
    if ( idy > idz ) and ( idz <= pred( Self.Length ) ) then begin
      Found := True;
      Self[ idz ] := Self[ idy ];
      idz := idy;
    end;
  end;
  if Found then begin
    Self.Length := pred( Self.Length );
  end;
end;

function TArrayOfStringHelper.SaveToStream( const Stream: IUnicodeStream; const Format: TUnicodeFormat; const Options: TStreamOptions ): TStatus;
var
  S: string;
  sCR: string;
  sLF: string;
begin
  if Self.Length = 0 then exit( stSuccess );
  if not assigned( Stream ) then exit( TStatus.Return( stNoStreamAssigned, [ 'TArrayOfStringHelper.SaveToStream()' ] ) );
  sCR := '' + CR;
  sLF := '' + LF;
  if soWriteBOM in Options then Stream.WriteBOM( Format );
  for S in Self do begin
    Stream.WriteString( S, Format );
    if soWriteCR in Options then Stream.WriteString( sCR, Format );
    if soWriteLF in Options then Stream.WriteString( sLF, Format );
    if soWriteZeroTerm  in Options then Stream.WriteString( '', Format, True );
  end;
  Result := stSuccess;
end;

procedure TArrayOfStringHelper.setLength( const Value: nativeuint );
begin
  System.SetLength( Self, Value );
end;

procedure TArrayOfStringHelper.Trim;
var
  idx: nativeuint;
begin
  if Self.Length = 0 then exit;
  for idx := 0 to pred( self.Length ) do begin
    Self[ idx ] := Self[ idx ].Trim;
  end;
end;

procedure TArrayOfStringHelper.Uppercase;
var
  idx: nativeuint;
begin
  if Self.Length = 0 then exit;
  for idx := 0 to pred( self.Length ) do begin
    Self[ idx ] := Self[ idx ].Uppercase;
  end;
end;

procedure TArrayOfStringHelper.UppercaseTrim;
var
  idx: nativeuint;
begin
  if Self.Length = 0 then exit;
  for idx := 0 to pred( self.Length ) do begin
    Self[ idx ] := Self[ idx ].UppercaseTrim;
  end;
end;

{$endregion}

initialization
  TStatus.Register( stStringToHexFailed   , 'String to hex conversion failed due to invalid char "(%%)"' );
  TStatus.Register( stTypeConversionError , 'Failed to convert type "(%%)" to "(%%)" for value "(%%)".' );
  TStatus.Register( stInvalidYear         , 'Year "(%%)" is invalid or out of bounds while encoding date.' );
  TStatus.Register( stInvalidMonth        , 'Month "(%%)" is not valid for encoding date.' );
  TStatus.Register( stInvalidDate         , 'Day "(%%)" in month "(%%)" of year "(%%)" is invalid or out of bounds while encoding date.' );
  TStatus.Register( stIndexOutOfBounds    , 'Index "(%%)" is out of bounds.' );
  TStatus.Register( stNoStreamAssigned    , 'No stream assigned during method call "(%%)". ');

end.
