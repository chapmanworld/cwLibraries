(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlUnicode;

interface

{$region ' Status values '}

const
  stUTFUnknownNotSupported : TGUID = '{4F0F07D0-6CFE-4487-A360-AAF97997270E}';
  stUnicodeDecodingFailed  : TGUID = '{CAA59455-DBCA-4B8F-80DD-97728CBAB09B}';
  stUnicodeEncodingFailed  : TGUID = '{5E5C865F-12B1-4127-8572-AA09EAD07CFB}';

{$endregion}

{$region ' TUnicodeFormat '}

type

  /// <summary>
  ///   Specifies a supported unicode text format.
  /// </summary>
  TUnicodeFormat = (

    /// <summary>
    ///   An undetermined text format.
    /// </summary>
    utfUnknown,

    /// <summary>
    ///   Ansi format (UTF-8 compatible)
    /// </summary>
    utfANSI,

    /// <summary>
    ///   UTF-8
    /// </summary>
    utf8,

    /// <summary>
    ///   UTF-16 Little Endian
    /// </summary>
    utf16LE,

    /// <summary>
    ///   UTF-16 Big Endian
    /// </summary>
    utf16BE,

    /// <summary>
    ///   UTF-32 Little Endian
    /// </summary>
    utf32LE,

    /// <summary>
    ///   UTF-32 Big Endian
    /// </summary>
    utf32BE
  );

{$endregion}

{$region ' TUnicodeCodec & Supporting Types '}

type
  /// <summary>
  ///   Represents the unicode code-plane portion of a code point.
  /// </summary>
  TCodePlane = $00 .. $10; //- code planes 0-17, represented as 5-bits of code plane.

type
  /// <summary>
  ///   Canonical representation of a code point, will never exceed 32-bits.
  /// </summary>
  TUnicodeCodePoint = uint32;

type
  TUnicodeCodec = record

    ///  <summary>
    ///    Returns the format name as a string.
    ///  </summary>
    class function FormatToString( const UnicodeFormat: TUnicodeFormat ): string; static;

    /// <summary>
    ///   Get the code plane portion of a code point.
    /// </summary>
    class function GetPlane( CodePoint: TUnicodeCodePoint ): TCodePlane; static;

    /// <summary>
    ///   Get the value portion of a code point.
    /// </summary>
    class function GetValue( CodePoint: TUnicodeCodePoint  ): uint32; static;

    /// <summary>
    ///   Get the least significant byte of a code point.
    /// </summary>
    class function GetLSB( CodePoint: TUnicodeCodePoint ): uint8; static;

    /// <summary>
    ///   Get the most significatn byte of a code point.
    /// </summary>
    class function GetMSB( CodePoint: TUnicodeCodePoint ): uint8; static;

    /// <summary>
    ///   Set the unicode code plane portion of a code point.
    /// </summary>
    class procedure SetPlane( var CodePoint: TUnicodeCodePoint; const Value: TCodePlane ); static;

    /// <summary>
    ///   Set the value portion of a code point.
    /// </summary>
    class procedure SetValue( var CodePoint: TUnicodeCodePoint; const Value: uint32 ); static;

    /// <summary>
    ///   Set the least significant byte of a code point.
    /// </summary>
    class procedure SetLSB( var CodePoint: TUnicodeCodePoint; const Value: uint8 ); static;

    /// <summary>
    ///   Set the most significant byte of a code point.
    /// </summary>
    class procedure SetMSB( var CodePoint: TUnicodeCodePoint; const Value: uint8 ); static;

    class function EncodeCodepointToString( const CodePoint: TUnicodeCodePoint; var Str: string ): boolean; static;
    class function DecodeCodepointFromString( var CodePoint: TUnicodeCodePoint; const Source: string; var Cursor: int32 ): boolean; static;
    class function UTF8CharacterLength( var Bytes; out size: uint8 ): boolean; static;
    class function UTF16LECharacterLength( var Bytes; out size: uint8 ): boolean; static;
    class function UTF16BECharacterLength( var Bytes; out size: uint8 ): boolean; static;
    class function UTF8Decode( var Bytes; out CodePoint: TUnicodeCodePoint ): boolean; static;
    class function UTF16LEDecode( const Bytes; out CodePoint: TUnicodeCodePoint ): boolean; static;
    class function UTF16BEDecode( const Bytes; out CodePoint: TUnicodeCodePoint ): boolean; static;
    class function UTF32LEDecode( const Bytes; out CodePoint: TUnicodeCodePoint ): boolean; static;
    class function UTF32BEDecode( const Bytes; out CodePoint: TUnicodeCodePoint ): boolean; static;
    class function AnsiDecode( const Bytes; out CodePoint: TUnicodeCodePoint ): boolean; static;
    class function UTF8Encode( const CodePoint: TUnicodeCodePoint; var Bytes; out Size: uint8 ): boolean; static;
    class function UTF16LEEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean; static;
    class function UTF16BEEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean; static;
    class function UTF32LEEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean; static;
    class function UTF32BEEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean; static;
    class function AnsiEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean; static;
    class function DecodeBOM( var Bytes; const Format: TUnicodeFormat; const BomSize: uint8 ): boolean; static;
    class function EncodeBOM( var Bytes; const Format: TUnicodeFormat; out size: uint8 ): boolean; static;
  end;

type
  (*
    Used internally within cwRuntime.
    Represents a single unicode codepoint (character) which may be
    assigned to and from a char, ansichar or widechar. <br/>
    Note that assignment to AnsiChar will fail when the code-point falls
    outside the range of ansi characters, and will return (#0) in this case.
  *)
  utfCodepoint = record
  public
    Value: TUnicodeCodepoint;
  public
    class operator Implicit          ( const a: AnsiChar     ): utfCodepoint;
    class operator Implicit          ( const a: utfCodepoint ): AnsiChar;
    class operator Implicit          ( const a: WideChar     ): utfCodepoint;
    class operator Implicit          ( const a: utfCodepoint ): WideChar;
    class operator Explicit          ( const a: AnsiChar     ): utfCodepoint;
    class operator Explicit          ( const a: utfCodepoint ): AnsiChar;
    class operator Explicit          ( const a: WideChar     ): utfCodepoint;
    class operator Explicit          ( const a: utfCodepoint ): WideChar;
    class operator GreaterThan       ( const a: utfCodepoint;   const b: utfCodepoint ): boolean;
    class operator GreaterThan       ( const a: utfCodepoint;   const b: AnsiChar     ): boolean;
    class operator GreaterThan       ( const a: utfCodepoint;   const b: WideChar     ): boolean;
    class operator GreaterThan       ( const a: AnsiChar;       const b: utfCodepoint ): boolean;
    class operator GreaterThan       ( const a: WideChar;       const b: utfCodepoint ): boolean;
    class operator GreaterThanOrEqual( const a: utfCodepoint;   const b: utfCodepoint ): boolean;
    class operator GreaterThanOrEqual( const a: utfCodepoint;   const b: AnsiChar     ): boolean;
    class operator GreaterThanOrEqual( const a: utfCodepoint;   const b: WideChar     ): boolean;
    class operator GreaterThanOrEqual( const a: AnsiChar;       const b: utfCodepoint ): boolean;
    class operator GreaterThanOrEqual( const a: WideChar;       const b: utfCodepoint ): boolean;
    class operator LessThan          ( const a: utfCodepoint;   const b: utfCodepoint ): boolean;
    class operator LessThan          ( const a: utfCodepoint;   const b: AnsiChar     ): boolean;
    class operator LessThan          ( const a: utfCodepoint;   const b: WideChar     ): boolean;
    class operator LessThan          ( const a: AnsiChar;       const b: utfCodepoint ): boolean;
    class operator LessThan          ( const a: WideChar;       const b: utfCodepoint ): boolean;
    class operator LessThanOrEqual   ( const a: utfCodepoint;   const b: utfCodepoint ): boolean;
    class operator LessThanOrEqual   ( const a: utfCodepoint;   const b: AnsiChar     ): boolean;
    class operator LessThanOrEqual   ( const a: utfCodepoint;   const b: WideChar     ): boolean;
    class operator LessThanOrEqual   ( const a: AnsiChar;       const b: utfCodepoint ): boolean;
    class operator LessThanOrEqual   ( const a: WideChar;       const b: utfCodepoint ): boolean;
    class operator Equal             ( const a: utfCodepoint;   const b: utfCodepoint ): boolean;
    class operator Equal             ( const a: utfCodepoint;   const b: AnsiChar     ): boolean;
    class operator Equal             ( const a: utfCodepoint;   const b: WideChar     ): boolean;
    class operator Equal             ( const a: AnsiChar;       const b: utfCodepoint ): boolean;
    class operator Equal             ( const a: WideChar;       const b: utfCodepoint ): boolean;
    class operator NotEqual          ( const a: utfCodepoint;   const b: utfCodepoint ): boolean;
    class operator NotEqual          ( const a: utfCodepoint;   const b: AnsiChar     ): boolean;
    class operator NotEqual          ( const a: utfCodepoint;   const b: WideChar     ): boolean;
    class operator NotEqual          ( const a: AnsiChar;       const b: utfCodepoint ): boolean;
    class operator NotEqual          ( const a: WideChar;       const b: utfCodepoint ): boolean;
  public

    ///  <summary>
    ///    Returns the size of this codepoint in bytes, when converted
    ///    to the specified unicode format.
    ///  </summary>
    function Size( const UnicodeFormat: TUnicodeFormat ): nativeuint;

    ///  <summary>
    ///    Writes the codepoint to the target of the pointer 'P' in
    ///    the format specified, and advances P beyond the codepoint.
    ///  </summary>
    procedure WriteMem( var P: pointer; const UnicodeFormat: TUnicodeFormat );

    ///  <summary>
    ///    Reads the codepoint from the target of pointer 'P' in the
    ///    format specified, and advances P beyond the codepoint.
    ///  </summary>
    procedure ReadMem( var P: pointer; const UnicodeFormat: TUnicodeFormat );

    ///  <summary>
    ///    Returns the uppercase of this code point.
    ///    This method relies on the target-operating system for locale sensitive
    ///    case conversion, and will therefore conform to the constraints of
    ///    the target.
    ///  </summary>
    function Uppercase: utfCodepoint;

    ///  <summary>
    ///    Returns the lowercase of this code point.
    ///    This method relies on the target-operating system for locale sensitive
    ///    case conversion, and will therefore conform to the constraints of
    ///    the target.
    ///  </summary>
    function Lowercase: utfCodepoint;
  end;

{$endregion}

{$region ' IUnicodeString '}

type
  ///  <summary>
  ///    Arc managed buffer containing unicode data.
  ///  </summary>
  IUnicodeString = interface
    ['{6EA6936C-E5FE-4AD1-A54E-283816E6F659}']

    ///  <summary>
    ///    Clears the string and sets it to the new string 'S' in the
    ///    specified unicode format, and with a zero terminator.
    ///  </summary>
    procedure SetAsString( const S: string; const UnicodeFormat: TUnicodeFormat );

    ///  <summary>
    ///    Appends the provided string to the unicode string while preserving the
    ///    internal unicode format.
    ///  </summary>
    procedure AppendString( const S: String );

    ///  <summary>
    ///    Attempts to append the provided codepoint (utf32LE), while preserving the
    ///    internal unicode format. Not all 32-bit values are valid unicode codepoints,
    ///    this method will return a success indication as a boolean.
    ///  </summary>
    function AppendCodepoint( const Codepoint: uint32 ): boolean;

    ///  <summary>
    ///    Clears the string and copies the provided source string using the specified
    ///    unicode format. Note that the source string must be zero terminated or else
    ///    a buffer overrun is likely to occur. If nil is provided, then an empty
    ///    zero-terminated string is set.
    ///  </summary>
    procedure SetAsUTFZero( const Source: pointer; const UnicodeFormat: TUnicodeFormat );

    ///  <summary>
    ///    Returns the contents of the buffer as a regular string. (UTF16LE as the fpc compiler default)
    ///  </summary>
    function AsString: String;

    ///  <summary>
    ///    Returns a pointer to the unicode data.
    ///  </summary>
    function AsPointer: pointer;

    ///  <summary>
    ///    Returns the size of the stored unicode data in bytes, including the zero terminator.
    ///  </summary>
    function SizeInBytes: uint8;

    ///  <summary>
    ///    Returns the length of the stored string in code-points, Excluding the zero terminator.
    ///  </summary>
    function Length: uint8;

  end;

{$endregion}

{$region ' TUnicodeString '}

type
  ///  <summary>
  ///    A factory record for instancing IUnicodeString.
  ///  </summary>
  TUnicodeString = record

    ///  <summary>
    ///    Instantiates IUnicodeString containing an empty zero-terminated string
    ///    in utf8 encoding.
    ///  </summary>
    class function Create: IUnicodeString; overload; static;

    ///  <summary>
    ///    Instances the string, initializing it to contain the zero terminated
    ///    encoding of 'S' using the specified unicode format.
    ///  </summary>
    class function Create( const S: string; const UnicodeFormat: TUnicodeFormat ): IUnicodeString; overload; static;

    ///  <summary>
    ///    Instances the string to contain a copy of the unicode string contained within the
    ///    source pointer. Note that the source pointer must contain a zero terminated string
    ///    or else buffer overrun is likely. If nil is provided, then an empty zero-terminated
    ///    string is set.
    ///  </summary>
    class function Create( const Source: pointer; const UnicodeFormat: TUnicodeFormat ): IUnicodeString; overload; static;

  end;

{$endregion}

implementation
uses
  SysUtils
, utlStatus
, utlUnicode.UnicodeString
;

const
  BMP   = 0;  /// Unicode Basic Multilingual plane.

{$region ' IncPtr() '}

(* Returns the pointer 'P' incremented by one *)
function IncPtr( P: pointer ): pointer; inline;
begin
  {$hints off} Result := pointer( nativeuint( P ) + sizeof( uint8 ) ); {$hints on}
end;

{$endregion}

{$region ' SwapBytes() '}

(* Returns the word 'value' with the high and low order bytes swapped. *)
function SwapBytes( value: uint16 ): uint16; inline;
type
  TByteSwapper = packed record
    A: uint8;
    B: uint8;
  end;
var
  ByteSwapper: TByteSwapper;
  Swap: uint16 absolute ByteSwapper;
begin
  Swap := Value;
  Result := ( ByteSwapper.A shl 8 ) or ( ByteSwapper.B );
end;

{$endregion}

{$region ' HiWord() '}

(* Returns the high word of dword 'x' *)
function HiWord( x: uint32 ): uint16; inline;
begin
  Result := ( x and $FFFF0000 ) shr 16;
end;

{$endregion}

{$region ' LoWord() '}

(* Returns the low word of dword 'x' *)
function LoWord( x: uint32 ): uint16; inline;
begin
  Result := ( x and $0000FFFF );
end;

{$endregion}

{$region ' SwapEndianess() '}

(* Returns the dword 'value' with its words swapped, and each byte within those words also swapped. *)
function SwapEndianess( value: uint32 ): uint32; inline;
var
  h: uint16;
  l: uint16;
begin
  h := HiWord( Value );
  l := LoWord( Value );
  h := SwapBytes( h );
  l := SwapBytes( l );
  Result := ( L shl 16 ) or H;
end;

{$endregion}

{$region ' TUnicodeCodec implementation '}

class function TUnicodeCodec.GetPlane( CodePoint: TUnicodeCodePoint ): TCodePlane;
begin
  Result := ( CodePoint and $1F0000 ) shr 16;
end;

class function TUnicodeCodec.GetValue( CodePoint: TUnicodeCodePoint ): uint32;
begin
  Result := ( CodePoint and $FFFF );
end;

class function TUnicodeCodec.GetLSB( CodePoint: TUnicodeCodePoint ): uint8;
begin
  Result := CodePoint and $000000FF;
end;

class function TUnicodeCodec.GetMSB( CodePoint: TUnicodeCodePoint ): uint8;
begin
  Result := ( CodePoint and $0000FF00 ) shr 8;
end;

class procedure TUnicodeCodec.SetPlane( var CodePoint: TUnicodeCodePoint; const Value: TCodePlane );
var
  aPlane: uint32;
begin
  aPlane := Value shl 16;
  CodePoint := ( CodePoint AND $FFFF );
  CodePoint := ( CodePoint or aPlane );
end;

class procedure TUnicodeCodec.SetValue( var CodePoint: TUnicodeCodePoint; const Value: uint32 );
begin
  CodePoint := ( CodePoint and $FF0000 );
  CodePoint := ( CodePoint or Value );
end;

class procedure TUnicodeCodec.SetLSB( var CodePoint: TUnicodeCodePoint; const Value: uint8 );
begin
  CodePoint := ( CodePoint and $FFFF00 );
  CodePoint := ( CodePoint or Value );
end;

class procedure TUnicodeCodec.SetMSB( var CodePoint: TUnicodeCodePoint; const Value: uint8 );
var
  aValue: uint16;
begin
  CodePoint := ( CodePoint and $FF00FF );
  aValue := Value;
  AValue := AValue shl 8;
  CodePoint := ( CodePoint or aValue );
end;

class function TUnicodeCodec.AnsiDecode( const Bytes; out CodePoint: TUnicodeCodePoint ): boolean;
var
  Buffer: ^uint8;
begin
  Result := True;
  CodePoint := 0;
  Buffer := @Bytes;
  TUnicodeCodec.SetPlane( CodePoint, 0 );
  TUnicodeCodec.SetMSB( CodePoint, 0 );
  TUnicodeCodec.SetLSB( CodePoint, Buffer^ );
end;

class function TUnicodeCodec.AnsiEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean;
var
  Buffer: ^uint8;
begin
  Result := True;
  Size := sizeof(uint8);
  Buffer := @Bytes;
  Buffer^ := TUnicodeCodec.GetLSB( CodePoint );
end;

class function TUnicodeCodec.UTF8CharacterLength( var Bytes; out size: uint8 ): boolean;
var
  Buffer: ^uint8;
begin
  Size := 0;
  Result := False;
  Buffer := @Bytes;
       if ( Buffer^ and $FC ) = $FC then Size := 6
  else if ( Buffer^ and $F8 ) = $F8 then Size := 5
  else if ( Buffer^ and $F0 ) = $F0 then Size := 4
  else if ( Buffer^ and $E0 ) = $E0 then Size := 3
  else if ( Buffer^ and $C0 ) = $C0 then Size := 2
  else if ( Buffer^ or  $7F ) = $7F then Size := 1
  else exit;
  Result := True;
end;

class function TUnicodeCodec.UTF8Decode( var Bytes; out CodePoint: TUnicodeCodePoint ): boolean;
var
  Target: uint32;
  Temp: uint32;
  Buffer: ^uint8;
begin
  Result    := False;
  CodePoint := 0;
  Target    := 0;
  Buffer    := @Bytes;
  if ( Buffer^ and $FC ) = $FC then begin
    {$region ' six-byte encoding '}
    Temp    := ( Buffer^ AND $01 );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    {$endregion}
  end else if ( Buffer^ and $F8 ) = $F8 then begin
    {$region ' five-byte encoding'}
    Temp    := ( Buffer^ AND $03 );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    {$endregion}
  end else if ( Buffer^ and $F0 ) = $F0 then begin
    {$region ' four-byte encoding '}
    Temp    := ( Buffer^ AND $07 );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    {$endregion}
  end else if ( Buffer^ and $E0 ) = $E0 then begin
    {$region ' three-byte encoding '}
    Temp    := ( Buffer^ AND $0F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    {$endregion}
  end else if ( Buffer^ and $C0 ) = $C0 then begin
    {$region ' two-byte encoding '}
    Temp    := ( Buffer^ AND $1F );
    Target  := Target or Temp;
    Target  := Target shl 6;
    Buffer  := IncPtr( Buffer );
    Temp    := ( Buffer^ AND $3F );
    Target  := Target or Temp;
    {$endregion}
  end else if ( Buffer^ or $7F ) = $7F then begin
    {$region ' one-byte encoding '}
    Target  := ( Buffer^ AND $7F );
    {$endregion}
  end else exit;
  TUnicodeCodec.SetValue( CodePoint, Target );
  Result := True;
end;

class function TUnicodeCodec.UTF8Encode( const CodePoint: TUnicodeCodePoint; var Bytes; out Size: uint8 ): boolean;
var
  Point: uint64;
  Buffer: ^uint8;
begin
  Result    := False;
  Size      := 0;
  Point     := CodePoint;
  Buffer    := @Bytes;
  if ( Point <= $007F ) then begin
    {$region ' one-byte encoding '}
    Buffer^ := Point and $7F;
    Size    := sizeof( uint8 );
    {$endregion}
  end else if ( Point >= $0080 ) and ( Point <= $07FF ) then begin
    {$region ' two-byte encoding' }
    Buffer^ := $C0;
    Buffer^ := Buffer^ or ( ( Point and $7C0 ) shr 6 );
    Buffer  := IncPtr( Buffer );
    Buffer^ := $80;
    Buffer^ := Buffer^ or ( Point and $3F );
    Size    := sizeof( uint16 );
    {$endregion}
  end else if ( Point >= $0800 ) and ( Point <= $FFFF ) then begin
    {$region ' three-byte encoding '}
    Buffer^ := $E0;
    Buffer^ := Buffer^ or ( ( Point and $F000 ) shr 12 );
    Buffer  := IncPtr( Buffer );
    Buffer^ := $80;
    Buffer^ := Buffer^ or ( ( Point and $FC0 ) shr 6 );
    Buffer  := IncPtr( Buffer );
    Buffer^ := $80;
    Buffer^ := Buffer^ or ( Point and $3F );
    Size    := sizeof( uint8 ) + sizeof( uint16 );
    {$endregion}
  end else if ( Point >= $10000 ) and ( Point <= $1FFFFF ) then begin
    {$region ' four-byte encoding '}
    Buffer^ := $F0;
    Buffer^ := Buffer^ or ( ( Point and $1C0000 ) shr 18 );
    Buffer  := IncPtr( Buffer );
    Buffer^ := $80;
    Buffer^ := Buffer^ or ( ( Point and $3F000 ) shr 12 );
    Buffer  := IncPtr( Buffer );
    Buffer^ := $80;
    Buffer^ := Buffer^ or ( ( Point and $FC0 ) shr 6 );
    Buffer  := IncPtr( Buffer );
    Buffer^ := $80;
    Buffer^ := Buffer^ or ( Point and $3F );
    Size    := sizeof( uint32 );
    {$endregion}
  end else exit;
  Result := True;
end;

class function TUnicodeCodec.UTF16BECharacterLength( var Bytes; out size: uint8 ): boolean;
var
  Value: uint32;
  Buffer: ^uint32;
begin
  Buffer := @Bytes;
  value  := SwapEndianess( Buffer^ );
  Result := UTF16LECharacterLength( Value, Size );
end;

class function TUnicodeCodec.UTF16BEDecode( const Bytes; out CodePoint: TUnicodeCodePoint ): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
  Buffer: ^Uint16;
begin
  Result    := False;
  CodePoint := 0;
  Buffer    := @Bytes;
  W := Buffer^;
  W := SwapBytes(W);
  if ( W >= $D800 ) and ( W <= $DBFF ) then begin
    {$region ' Leading surrogate found ' }
    W := W - $D800;
    SupplementaryPlane := W;
    SupplementaryPlane := SupplementaryPlane shl 10;
    Buffer := IncPtr( Buffer );
    Buffer := IncPtr( Buffer );
    W := Buffer^;
    W := SwapBytes( W );
    W := W - $DC00;
    SupplementaryPlane := SupplementaryPlane or W;
    SupplementaryPlane := SupplementaryPlane + $010000;
    TUnicodeCodec.SetValue( CodePoint, SupplementaryPlane xor ( $F0000 ) );
    TUnicodeCodec.SetPlane( CodePoint, ( SupplementaryPlane xor $FFFF ) shr 16 );
    {$endregion}
  end else if ( W >= $DC00 ) and ( W <= $DFFF ) then exit
  else begin
    CodePoint := 0;
    TUnicodeCodec.SetPlane( CodePoint, BMP );
    TUnicodeCodec.SetValue( CodePoint, W );
  end;
  Result := True;
end;

class function TUnicodeCodec.UTF16BEEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
  Buffer: ^uint16;
begin
  Size   := 0;
  Result := False;
  Buffer := @Bytes;
  if TUnicodeCodec.GetPlane( CodePoint ) = BMP then begin
    if ( TUnicodeCodec.GetValue( CodePoint ) >= $D800 ) and
       ( TUnicodeCodec.GetValue(CodePoint) <= $DFFF ) then exit;
    W := TUnicodeCodec.GetValue( CodePoint );
    Buffer^ := SwapBytes(W);
    size := sizeof(uint16);
  end else begin
    SupplementaryPlane := 0;
    SupplementaryPlane := SupplementaryPlane or TUnicodeCodec.GetPlane( CodePoint );
    SupplementaryPlane := SupplementaryPlane shl 16;
    SupplementaryPlane := SupplementaryPlane or TUnicodeCodec.GetValue( CodePoint );
    SupplementaryPlane := SupplementaryPlane - $010000;
    W := ( ( SupplementaryPlane xor $3FF ) shr 10 ) + $D800;
    if ( W < $D800 ) or ( W > $DBFF ) then exit;
    Buffer^ := SwapBytes( W );
    Buffer  := IncPtr( Buffer );
    Buffer  := IncPtr( Buffer );
    W := ( SupplementaryPlane and $3FF ) + $DC00;
    if ( W < $DC00 ) or ( W > $DFFF ) then exit;
    Buffer^ := SwapBytes( W );
    size := Sizeof( uint32 );
  end;
  Result := True;
end;

class function TUnicodeCodec.UTF16LECharacterLength( var Bytes; out size: uint8 ): boolean;
var
  Buffer: ^uint16;
begin
  Result := False;
  Size   := 0;
  Buffer := @Bytes;
  if ( Buffer^ >= $D800 ) and ( Buffer^ <= $DBFF ) then size := 4
  else if ( Buffer^ >= $DC00 ) and ( Buffer^ <= $DFFF ) then exit
  else size := 2;
  Result := True;
end;

class function TUnicodeCodec.UTF16LEDecode(const Bytes; out CodePoint: TUnicodeCodePoint): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
  Buffer: ^uint16;
begin
  Result    := False;
  CodePoint := 0;
  Buffer    := @Bytes;
  W := Buffer^;
  if ( W >= $D800 ) and ( W <= $DBFF ) then begin
    W := W - $D800;
    SupplementaryPlane := W;
    SupplementaryPlane := SupplementaryPlane shl 10;
    Buffer := IncPtr( Buffer );
    Buffer := IncPtr( Buffer );
    W := Buffer^;
    W := W - $DC00;
    SupplementaryPlane := SupplementaryPlane or W;
    SupplementaryPlane := SupplementaryPlane + $010000;
    TUnicodeCodec.SetValue( CodePoint, SupplementaryPlane xor ( $F0000 ) );
    TUnicodeCodec.SetPlane( CodePoint, ( SupplementaryPlane xor $FFFF ) shr 16 );
  end else if ( W >= $DC00 ) and ( W <= $DFFF ) then exit
  else begin
    CodePoint := 0;
    TUnicodeCodec.SetPlane( CodePoint, BMP );
    TUnicodeCodec.SetValue( CodePoint, W );
  end;
  Result := True;
end;

class function TUnicodeCodec.UTF16LEEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
  Buffer: ^uint16;
begin
  Size   := 0;
  Result := False;
  Buffer := @Bytes;
  if TUnicodeCodec.GetPlane( CodePoint )=BMP then begin
    if ( TUnicodeCodec.GetValue( CodePoint ) >= $D800 ) and
        ( TUnicodeCodec.GetValue(CodePoint) <= $DFFF ) then exit;
    W := TUnicodeCodec.GetValue( CodePoint );
    Buffer^ := W;
    size := Sizeof( uint16 );
  end else begin
    SupplementaryPlane := 0;
    SupplementaryPlane := SupplementaryPlane or TUnicodeCodec.GetPlane( CodePoint );
    SupplementaryPlane := SupplementaryPlane shl 16;
    SupplementaryPlane := SupplementaryPlane or TUnicodeCodec.GetValue( CodePoint );
    SupplementaryPlane := SupplementaryPlane - $010000;
    W := ( ( SupplementaryPlane xor $3FF ) shr 10 ) + $D800;
    if ( W < $D800 ) or ( W > $DBFF ) then exit;
    Buffer^ := W;
    Buffer  := IncPtr( Buffer );
    Buffer  := IncPtr( Buffer );
    W := ( SupplementaryPlane and $3FF ) + $DC00;
    if ( W < $DC00 ) or ( W > $DFFF ) then exit;
    Buffer^ := W;
    size := Sizeof( uint32 );
  end;
  Result := True;
end;

class function TUnicodeCodec.UTF32BEDecode( const Bytes; out CodePoint: TUnicodeCodePoint ): boolean;
var
  Buffer: ^uint32;
begin
  Result    := True;
  Buffer    := @Bytes;
  CodePoint := SwapEndianess( Buffer^ );
end;

class function TUnicodeCodec.UTF32BEEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean;
var
  Buffer: ^uint32;
begin
  Result  := True;
  Buffer  := @Bytes;
  Buffer^ := SwapEndianess( CodePoint );
  Size    := sizeof( uint32 );
end;

class function TUnicodeCodec.UTF32LEDecode( const Bytes; out CodePoint: TUnicodeCodePoint ): boolean;
var
  Buffer: ^uint32;
begin
  Result    := True;
  Buffer    := @Bytes;
  CodePoint := Buffer^;
end;

class function TUnicodeCodec.UTF32LEEncode( const CodePoint: TUnicodeCodePoint; var Bytes; out size: uint8 ): boolean;
var
  Buffer: ^uint32;
begin
  Result  := True;
  Buffer  := @Bytes;
  Buffer^ := CodePoint;
  Size    := sizeof(uint32);
end;

class function TUnicodeCodec.EncodeBOM( var Bytes; const Format: TUnicodeFormat; out size: uint8 ): boolean;
var
  Buffer: ^uint8;
  Buffer16: ^uint16;
  Buffer32: ^uint32;
begin
  Size := 0;
  Result := True;
  Buffer   := @Bytes;
  Buffer16 := @Bytes;
  Buffer32 := @Bytes;

  case Format of
    TUnicodeFormat.utf8: begin
      Buffer^   := $EF;
      Buffer    := IncPtr( Buffer );
      Buffer^   := $BB;
      Buffer    := IncPtr( Buffer );
      Buffer^   := $BF;
      Size      := sizeof( uint16 ) + sizeof( uint8 );
    end;

    TUnicodeFormat.utf16LE: begin
      Buffer16^ := $FEFF;
      Size      := sizeof( uint16 );
    end;

    TUnicodeFormat.utf16BE: begin
      Buffer16^ := $FFFE;
      Size      := sizeof( uint16 );
    end;

    TUnicodeFormat.utf32LE: begin
      Buffer32^ := $0000FEFF;
      Size      := sizeof( uint32 );
    end;

    TUnicodeFormat.utf32BE: begin
      Buffer32^ := $FFFE0000;
      Size      := sizeof( uint32 );
    end;

    else ;
  end;
end;

class function TUnicodeCodec.EncodeCodepointToString( const CodePoint: TUnicodeCodePoint; var Str: string ): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
begin
  Result := False;
  if TUnicodeCodec.GetPlane( CodePoint )=BMP then begin
    W := TUnicodeCodec.GetValue( CodePoint );
    Str := Str + char( W );
  end else begin
    SupplementaryPlane := 0;
    SupplementaryPlane := SupplementaryPlane or TUnicodeCodec.GetPlane( CodePoint );
    SupplementaryPlane := SupplementaryPlane shl 16;
    SupplementaryPlane := SupplementaryPlane or TUnicodeCodec.GetValue( CodePoint );
    SupplementaryPlane := ( SupplementaryPlane - $010000 );
    W := ( ( SupplementaryPlane xor $3FF ) shr 10 ) + $D800;
    if ( W < $D800 ) or ( W > $DBFF ) then exit;
    Str := Str + char( W );
    W := ( SupplementaryPlane and $3FF ) + $DC00;
    if ( W < $DC00 ) or ( W > $DFFF ) then exit;
    Str := Str + char( W );
  end;
  Result := True;
end;

class function TUnicodeCodec.FormatToString( const UnicodeFormat: TUnicodeFormat ): string;
begin
  case UnicodeFormat of
    utfANSI: Result := 'utfANSI';
    utf8:    Result := 'utf-8';
    utf16LE: Result := 'utf-16 (LE)';
    utf16BE: Result := 'utf-16 (BE)';
    utf32LE: Result := 'utf-32 (LE)';
    utf32BE: Result := 'utf-32 (BE)';
    else     Result := '?utfUnknown?';
  end;
end;

class function TUnicodeCodec.DecodeCodepointFromString( var CodePoint: TUnicodeCodePoint; const Source: string; var Cursor: int32 ): boolean;
var
  W: uint16;
  SupplementaryPlane: uint32;
begin
  Result := False;
  W := uint16( Source[ Cursor ] );
  inc( Cursor );
  if ( W >= $D800 ) and ( W <= $DBFF ) then begin
    W := W - $D800;
    SupplementaryPlane := W;
    SupplementaryPlane := SupplementaryPlane shl 10;
    W := uint16( Source[ Cursor ] );
    inc( Cursor );
    if ( W < $DC00 ) or ( W > $DFFF ) then exit;
    W := W - $DC00;
    SupplementaryPlane := SupplementaryPlane or W;
    SupplementaryPlane := SupplementaryPlane + $010000;
    TUnicodeCodec.SetValue( CodePoint, SupplementaryPlane xor ( $F0000 ) );
    TUnicodeCodec.SetPlane( CodePoint, ( SupplementaryPlane xor $FFFF ) shr 16 );
  end else if ( W >= $DC00 ) and ( W <= $DFFF ) then exit
  else begin
    CodePoint := 0;
    TUnicodeCodec.SetPlane( CodePoint, BMP );
    TUnicodeCodec.SetValue( CodePoint, W );
  end;
  Result := True;
end;

class function TUnicodeCodec.DecodeBOM( var Bytes; const Format: TUnicodeFormat; const BomSize: uint8 ): boolean;
var
  Buffer: ^uint8;
  Buffer16: ^uint16;
  Buffer32: ^uint32;
begin
  Buffer   := @Bytes;
  Buffer16 := @Bytes;
  Buffer32 := @Bytes;
  Result   := False;
  case Format of
    TUnicodeFormat.utfANSI: exit;
    TUnicodeFormat.utfUnknown: exit;
    TUnicodeFormat.utf8: begin
      if ( BomSize <> 3 ) then exit;
      if ( Buffer^ <> $EF ) then exit;
      Buffer := IncPtr( Buffer );
      if ( Buffer^ <> $BB ) then exit;
      Buffer := IncPtr( Buffer );
      if ( Buffer^ <> $BF ) then exit;
      Result := True;
    end;
    TUnicodeFormat.utf16BE: Result := ( BomSize = 2 ) and ( Buffer16^ = $FFFE );
    TUnicodeFormat.utf16LE: Result := ( BomSize = 2 ) and ( Buffer16^ = $FEFF );
    TUnicodeFormat.utf32LE: Result := ( BomSize = 4 ) and ( Buffer32^ = $0000FEFF );
    TUnicodeFormat.utf32BE: Result := ( BomSize = 4 ) and ( Buffer32^ = $FFFE0000 );
  end;
end;

{$endregion}

{$region ' utfCodepoint implementation '}

class operator utfCodepoint.Implicit( const a: AnsiChar ): utfCodepoint;
begin
  if not TUnicodeCodec.AnsiDecode( A, Result.Value ) then
    raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utfANSI ) ] );
end;

class operator utfCodepoint.Implicit( const a: utfCodepoint ): AnsiChar;
var
  throwaway: uint8;
begin
  Result := Default( AnsiChar );
  if not TUnicodeCodec.AnsiEncode( a.Value, Result, throwaway ) then
    raise TStatus.CreateException( stUnicodeEncodingFailed , [ TUnicodeCodec.FormatToString( TUnicodeFormat.utfANSI ) ] );
end;

class operator utfCodepoint.Implicit( const a: WideChar ): utfCodepoint;
begin
  if not TUnicodeCodec.UTF16LEDecode( A, Result.Value ) then
    raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16LE ) ] );
end;

class operator utfCodepoint.Implicit( const a: utfCodepoint ): WideChar;
type
  TSurrogatePair = record
    a: uint16;
    b: uint16;
  end;
var
  bytes: TSurrogatePair;
  count: uint8;
begin
  bytes := Default( TSurrogatePair );
  if not TUnicodeCodec.UTF16LEEncode( a.value, bytes, count ) then
    raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16LE ) ] );
  Result := WideChar( bytes.a );
end;

class operator utfCodepoint.Explicit( const a: AnsiChar ): utfCodepoint;
begin
  if not TUnicodeCodec.AnsiDecode( a, Result.Value ) then
    raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utfANSI ) ] );
end;

class operator utfCodepoint.Explicit( const a: utfCodepoint ): AnsiChar;
var
  throwaway: uint8;
begin
  Result := Default( AnsiChar );
  if not TUnicodeCodec.AnsiEncode( a.Value, Result, throwaway ) then
    raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utfANSI ) ] );
end;

class operator utfCodepoint.Explicit( const a: WideChar ): utfCodepoint;
begin
  if not TUnicodeCodec.UTF16LEDecode( a, Result.Value ) then
    raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16LE ) ] );
end;

class operator utfCodepoint.Explicit( const a: utfCodepoint ): WideChar;
type
  TSurrogatePair = record
    a: uint16;
    b: uint16;
  end;
var
  bytes: TSurrogatePair;
  count: uint8;
begin
  Bytes := Default( TSurrogatePair );
  if not TUnicodeCodec.UTF16LEEncode( a.Value, bytes, count ) then
    raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16LE ) ] );
  Result := WideChar( bytes.a );
end;

class operator utfCodepoint.GreaterThan( const a: utfCodepoint; const b: utfCodepoint ): boolean;
begin
  Result := a.Value > b.Value;
end;

class operator utfCodepoint.GreaterThan( const a: utfCodepoint; const b: AnsiChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value > cp.Value;
end;

class operator utfCodepoint.GreaterThan( const a: utfCodepoint; const b: WideChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value > cp.Value;
end;

class operator utfCodepoint.GreaterThan( const a: AnsiChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value > b.Value;
end;

class operator utfCodepoint.GreaterThan( const a: WideChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value > b.Value;
end;

class operator utfCodepoint.GreaterThanOrEqual( const a: utfCodepoint; const b: utfCodepoint ): boolean;
begin
  Result := a.Value >= b.Value;
end;

class operator utfCodepoint.GreaterThanOrEqual( const a: utfCodepoint; const b: AnsiChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value >= cp.Value;
end;

class operator utfCodepoint.GreaterThanOrEqual( const a: utfCodepoint; const b: WideChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value >= cp.Value;
end;

class operator utfCodepoint.GreaterThanOrEqual( const a: AnsiChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value >= b.Value;
end;

class operator utfCodepoint.GreaterThanOrEqual( const a: WideChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value >= b.Value;
end;

class operator utfCodepoint.LessThan( const a: utfCodepoint; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value < CP.Value;
end;

class operator utfCodepoint.LessThan( const a: utfCodepoint; const b: AnsiChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value < CP.Value;
end;

class operator utfCodepoint.LessThan( const a: utfCodepoint; const b: WideChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value < CP.Value;
end;

class operator utfCodepoint.LessThan( const a: AnsiChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value < b.Value;
end;

class operator utfCodepoint.LessThan( const a: WideChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value < b.Value;
end;

class operator utfCodepoint.LessThanOrEqual( const a: utfCodepoint; const b: utfCodepoint ): boolean;
begin
  Result := a.Value <= b.Value;
end;

class operator utfCodepoint.LessThanOrEqual( const a: utfCodepoint; const b: AnsiChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value <= CP.Value;
end;

class operator utfCodepoint.LessThanOrEqual( const a: utfCodepoint; const b: WideChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value <= CP.Value;
end;

class operator utfCodepoint.LessThanOrEqual( const a: AnsiChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value <= b.Value;
end;

class operator utfCodepoint.LessThanOrEqual( const a: WideChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value <= b.Value;
end;

class operator utfCodepoint.Equal( const a: utfCodepoint; const b: utfCodepoint ): boolean;
begin
  Result := a.Value = b.Value;
end;

class operator utfCodepoint.Equal( const a: utfCodepoint; const b: AnsiChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value = CP.Value;
end;

class operator utfCodepoint.Equal( const a: utfCodepoint; const b: WideChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value = CP.Value;
end;

class operator utfCodepoint.Equal( const a: AnsiChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value = b.Value;
end;

class operator utfCodepoint.Equal( const a: WideChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value = b.Value;
end;

class operator utfCodepoint.NotEqual( const a: utfCodepoint; const b: utfCodepoint ): boolean;
begin
  Result := a.Value <> b.Value;
end;

class operator utfCodepoint.NotEqual( const a: utfCodepoint; const b: AnsiChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value <> CP.Value;
end;

class operator utfCodepoint.NotEqual( const a: utfCodepoint; const b: WideChar ): boolean;
var
  CP: utfCodepoint;
begin
  CP := b;
  Result := a.Value <> CP.Value;
end;

class operator utfCodepoint.NotEqual( const a: AnsiChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value <> b.Value;
end;

class operator utfCodepoint.NotEqual( const a: WideChar; const b: utfCodepoint ): boolean;
var
  CP: utfCodepoint;
begin
  CP := a;
  Result := CP.Value <> b.Value;
end;

procedure utfCodepoint.ReadMem( var P: pointer; const UnicodeFormat: TUnicodeFormat );
begin
  case UnicodeFormat of
    utfUnknown: raise TStatus.CreateException( stUTFUnknownNotSupported );
       utfANSI: if not TUnicodeCodec.AnsiDecode( P^, Self.Value )    then raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
          utf8: if not TUnicodeCodec.UTF8Decode( P^, Self.Value )    then raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
       utf16LE: if not TUnicodeCodec.UTF16LEDecode( P^, Self.Value ) then raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
       utf16BE: if not TUnicodeCodec.UTF16BEDecode( P^, Self.Value ) then raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
       utf32LE: if not TUnicodeCodec.UTF32LEDecode( P^, Self.Value ) then raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
       utf32BE: if not TUnicodeCodec.UTF32BEDecode( P^, Self.Value ) then raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
  end;
  {$hints off}
  P := pointer( nativeuint( p ) + Self.Size( UnicodeFormat ) );
  {$hints on}
end;

function utfCodepoint.Size( const UnicodeFormat: TUnicodeFormat ): nativeuint;
var
  CP: TUnicodeCodePoint;
  B: uint8;
begin
  CP := Default( TUnicodeCodePoint );
  case UnicodeFormat of
    utfUnknown : raise TStatus.CreateException( stUTFUnknownNotSupported );
    utfANSI    : B := sizeof( uint8 );
    utf8       : if not    TUnicodeCodec.UTF8Encode( self.Value, CP, B ) then raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf8 ) ] );
    utf16LE    : if not TUnicodeCodec.UTF16LEEncode( self.Value, CP, B ) then raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16LE ) ] );
    utf16BE    : if not TUnicodeCodec.UTF16BEEncode( self.Value, CP, B ) then raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16BE ) ] );
    utf32LE,
    utf32BE    : B := sizeof( uint32 );
  end;
  Result := B;
end;

function utfCodepoint.Uppercase: utfCodepoint;
var
  ch: char;
  s: string;
  size_encoded: uint8;
begin
  ch := Default( char );
  if not TUnicodeCodec.UTF16LEEncode( Self.Value, ch, size_encoded ) then begin
    raise
      TStatus( stUnicodeEncodingFailed ).CreateException( [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16LE ) ] );
  end;
  s := ch;
  s := SysUtils.Uppercase( s );
  ch := s[ 1 ];
  if not TUnicodeCodec.UTF16LEDecode( ch, Result.Value ) then
    raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16LE ) ] );
end;

procedure utfCodepoint.WriteMem( var P: pointer; const UnicodeFormat: TUnicodeFormat );
var
  B: uint8;
begin
  case UnicodeFormat of
    utfUnknown : raise TStatus.CreateException( stUTFUnknownNotSupported );
       utfANSI: if not TUnicodeCodec.AnsiEncode(    Self.Value, P^, B ) then raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
          utf8: if not TUnicodeCodec.UTF8Encode(    Self.Value, P^, B ) then raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
       utf16LE: if not TUnicodeCodec.UTF16LEEncode( Self.Value, P^, B ) then raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
       utf16BE: if not TUnicodeCodec.UTF16BEEncode( Self.Value, P^, B ) then raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
       utf32LE: if not TUnicodeCodec.UTF32LEEncode( Self.Value, P^, B ) then raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
       utf32BE: if not TUnicodeCodec.UTF32BEEncode( Self.Value, P^, B ) then raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( UnicodeFormat ) ] );
  end;
  {$hints off}
  P := pointer( nativeuint( P ) + B );
  {$hints on}
end;

function utfCodepoint.Lowercase: utfCodepoint;
var
  ch: char;
  s: string;
  size_encoded: uint8;
begin
  ch := Default( char );
  if not TUnicodeCodec.UTF16LEEncode( Self.Value, ch, size_encoded ) then
    raise TStatus.CreateException( stUnicodeEncodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16LE ) ] );
  s := ch;
  s := SysUtils.Lowercase( s );
  ch := s[ 1 ];
  if not TUnicodeCodec.UTF16LEDecode( ch, Result.Value ) then
    raise TStatus.CreateException( stUnicodeDecodingFailed, [ TUnicodeCodec.FormatToString( TUnicodeFormat.utf16LE ) ] );
end;

{$endregion}

{$region ' TUnicodeString (factory) '}

class function TUnicodeString.Create: IUnicodeString;
begin
  Result := TStandardUnicodeString.Create;
end;

class function TUnicodeString.Create( const S: string; const UnicodeFormat: TUnicodeFormat ): IUnicodeString;
begin
  Result := TStandardUnicodeString.Create( S, UnicodeFormat );
end;

class function TUnicodeString.Create( const Source: pointer; const UnicodeFormat: TUnicodeFormat ): IUnicodeString;
begin
  Result := TStandardUnicodeString.Create( Source, UnicodeFormat );
end;

{$endregion}

initialization
  TStatus.Register( stUnicodeDecodingFailed  , 'Unicode decoding failed for (%%)' );
  TStatus.Register( stUnicodeEncodingFailed  , 'Unicode encoding failed for (%%)' );
  TStatus.Register( stUTFUnknownNotSupported , 'TUnicodeFormat.utfUnknown cannot be used to encode or decode.' );

end.
