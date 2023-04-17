(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlUnicode.UnicodeString;

interface
uses
  utlUnicode
;

type
  TStandardUnicodeString = class( TInterfacedObject, IUnicodeString )
  private
    fData: array of uint8;
    fFormat: TUnicodeFormat;
  private
    function CountAnsiCodepoints( const Ptr: pointer ): nativeuint;
    function CountUTF8Codepoints( const Ptr: pointer ): nativeuint;
    function CountUTF16LECodepoints( const Ptr: pointer ): nativeuint;
    function CountUTF16BECodepoints( const Ptr: pointer ): nativeuint;
    function CountUTF32Codepoints( const Ptr: pointer ): nativeuint;
    procedure AppendData( const DataPtr: pointer; const Size: nativeuint );
  strict private //- IUnicodeString -//
    procedure AppendString( const S: String );
    function AppendCodepoint( const Codepoint: uint32 ): boolean;
    procedure SetAsString( const S: string; const UnicodeFormat: TUnicodeFormat );
    procedure SetAsUTFZero( const Source: pointer; const UnicodeFormat: TUnicodeFormat );
    function AsString: String;
    function SizeInBytes: uint8;
    function Length: uint8;
    function AsPointer: pointer;
  public
    constructor Create; overload;
    constructor Create( const S: string; const UnicodeFormat: TUnicodeFormat ); overload;
    constructor Create( const Source: pointer; const UnicodeFormat: TUnicodeFormat ); overload;
    destructor Destroy; override;
  end;

implementation
uses
  utlStatus
;

function TStandardUnicodeString.CountAnsiCodepoints( const Ptr: pointer ): nativeuint;
var
  PtrCodepoint: ^uint8;
begin
  Result := 0;
  ptrCodepoint := Ptr;
  while ( PtrCodepoint^ <> 0 ) do begin
    inc( Result );
    {$hints off} PtrCodepoint := pointer( nativeuint( PtrCodepoint ) + sizeof( uint8 ) ); {$hints on}
  end;
end;

function TStandardUnicodeString.CountUTF8Codepoints(const Ptr: pointer): nativeuint;
var
  PtrCodepoint: ^uint8;
  ByteCount: uint8;
begin
  Result := 0;
  ptrCodepoint := Ptr;
  while ( PtrCodepoint^ <> 0 ) do begin
    TUnicodeCodec.UTF8CharacterLength( PtrCodepoint^, ByteCount );
    Result := Result + ByteCount;
    {$hints off} PtrCodepoint := pointer( nativeuint( PtrCodepoint ) + ByteCount ); {$hints on}
  end;
end;

function TStandardUnicodeString.CountUTF16LECodepoints(const Ptr: pointer): nativeuint;
var
  PtrCodepoint: ^uint16;
  ByteCount: uint8;
begin
  Result := 0;
  ptrCodepoint := Ptr;
  while ( PtrCodepoint^ <> 0 ) do begin
    TUnicodeCodec.UTF16LECharacterLength( PtrCodepoint^, ByteCount );
    Result := Result + ByteCount;
    {$hints off} PtrCodepoint := pointer( nativeuint( PtrCodepoint ) + ByteCount ); {$hints on}
  end;
end;

function TStandardUnicodeString.CountUTF16BECodepoints(const Ptr: pointer): nativeuint;
var
  PtrCodepoint: ^uint16;
  ByteCount: uint8;
begin
  Result := 0;
  ptrCodepoint := Ptr;
  while ( PtrCodepoint^ <> 0 ) do begin
    TUnicodeCodec.UTF16BECharacterLength( PtrCodepoint^, ByteCount );
    Result := Result + ByteCount;
    {$hints off} PtrCodepoint := pointer( nativeuint( PtrCodepoint ) + ByteCount ); {$hints on}
  end;
end;

function TStandardUnicodeString.CountUTF32Codepoints(const Ptr: pointer): nativeuint;
var
  PtrCodepoint: ^uint32;
begin
  Result := 0;
  ptrCodepoint := Ptr;
  while ( PtrCodepoint^ <> 0 ) do begin
    Result := Result + sizeof( uint32 );
    {$hints off} PtrCodepoint := pointer( nativeuint( PtrCodepoint ) + sizeof( uint32 ) ); {$hints on}
  end;
end;

procedure TStandardUnicodeString.AppendString( const S: String );
var
  NewString: string;
begin
  NewString := Self.AsString + S;
  SetAsString( NewString, fFormat );
end;

function TStandardUnicodeString.AppendCodepoint( const Codepoint: uint32 ): boolean;
var
  S: string;
begin
  S := '';
  if not TUnicodeCodec.EncodeCodepointToString( Codepoint, S ) then exit( false );
  AppendString( S );
  Result := True;
end;

procedure TStandardUnicodeString.AppendData( const DataPtr: pointer; const Size: nativeuint );
var
  PrevSize: nativeuint;
  TargetPtr: pointer;
begin
  PrevSize := System.Length( fData );
  SetLength( fData, PrevSize + Size );
  TargetPtr := @fData[ PrevSize ];
  Move( DataPtr^, TargetPtr^, Size );
end;

procedure TStandardUnicodeString.SetAsString( const S: string; const UnicodeFormat: TUnicodeFormat );
var
  Cursor: int32;
  Buffer: uint64;
  CP: uint32;
  L: uint8;
  lZero: uint32;
begin
  lZero := 0;
  Cursor := 1;
  if UnicodeFormat = TUnicodeFormat.utfUnknown then
      raise TStatus.CreateException( stUTFUnknownNotSupported );
  fFormat := UnicodeFormat;
  SetLength( fData, 0 );
  while ( Cursor <= System.Length( S ) ) do begin
    CP := 0;
    L := 0;
    TUnicodeCodec.DecodeCodepointFromString( CP, S, Cursor );
    Buffer := 0;
    case fFormat of
      TUnicodeFormat.utfANSI: TUnicodeCodec.ANSIEncode( CP, Buffer, L );
      TUnicodeFormat.utf8   : TUnicodeCodec.UTF8Encode( CP, Buffer, L );
      TUnicodeFormat.utf16LE: TUnicodeCodec.UTF16LEEncode( CP, Buffer, L );
      TUnicodeFormat.utf16BE: TUnicodeCodec.UTF16BEEncode( CP, Buffer, L );
      TUnicodeFormat.utf32LE: TUnicodeCodec.UTF32LEEncode( CP, Buffer, L );
      TUnicodeFormat.utf32BE: TUnicodeCodec.UTF32BEEncode( CP, Buffer, L );
      else ;
    end;
    AppendData( @Buffer, L );
  end;
  case fFormat of
    utfANSI: AppendData( @lZero, sizeof( uint8 ) );
    utf8   : AppendData( @lZero, sizeof( uint8 ) );
    utf16LE: AppendData( @lZero, sizeof( uint16 ) );
    utf16BE: AppendData( @lZero, sizeof( uint16 ) );
    utf32LE: AppendData( @lZero, sizeof( uint32 ) );
    utf32BE: AppendData( @lZero, sizeof( uint32 ) );
    else ;
  end;
end;

procedure TStandardUnicodeString.SetAsUTFZero( const Source: pointer; const UnicodeFormat: TUnicodeFormat );
var
  CP: uint32;
  ByteCount: uint8;
  BufferPtr: pointer;
  lZero: uint32;
begin
  lZero := 0;
  CP := 0;
  ByteCount := 0;
  if UnicodeFormat = TUnicodeFormat.utfUnknown then
    raise TStatus.CreateException( stUTFUnknownNotSupported );
  fFormat := UnicodeFormat;
  SetLength( fData, 0 );
  if Source = nil then begin
    case UnicodeFormat of
      utfANSI: AppendData( @lZero, sizeof( uint8 ) );
      utf8   : AppendData( @lZero, sizeof( uint8 ) );
      utf16LE: AppendData( @lZero, sizeof( uint16 ) );
      utf16BE: AppendData( @lZero, sizeof( uint16 ) );
      utf32LE: AppendData( @lZero, sizeof( uint32 ) );
      utf32BE: AppendData( @lZero, sizeof( uint32 ) );
      else ;
    end;
    exit;
  end;
  case fFormat of
    TUnicodeFormat.utfAnsi: ByteCount := sizeof( uint8 );
    TUnicodeFormat.utf32LE: ByteCount := sizeof( uint32 );
    TUnicodeFormat.utf32BE: ByteCount := sizeof( uint32 );
    else ;
  end;
  BufferPtr := Source;
  repeat
    case fFormat of
      TUnicodeFormat.utfANSI: if not TUnicodeCodec.AnsiDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf8:    if not TUnicodeCodec.UTF8Decode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf16LE: if not TUnicodeCodec.UTF16LEDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf16BE: if not TUnicodeCodec.UTF16BEDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf32LE: if not TUnicodeCodec.UTF32LEDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf32BE: if not TUnicodeCodec.UTF32BEDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      else ;
    end;
    if CP = 0 then begin
      case fFormat of
        utfANSI: AppendData( @lZero, sizeof( uint8 ) );
        utf8   : AppendData( @lZero, sizeof( uint8 ) );
        utf16LE: AppendData( @lZero, sizeof( uint16 ) );
        utf16BE: AppendData( @lZero, sizeof( uint16 ) );
        utf32LE: AppendData( @lZero, sizeof( uint32 ) );
        utf32BE: AppendData( @lZero, sizeof( uint32 ) );
        else ;
      end;
      exit;
    end;
    case fFormat of
      TUnicodeFormat.utf8:    TUnicodeCodec.UTF8CharacterLength( BufferPtr^, ByteCount );
      TUnicodeFormat.utf16LE: TUnicodeCodec.UTF16LECharacterLength( BufferPtr^, ByteCount );
      TUnicodeFormat.utf16BE: TUnicodeCodec.UTF16BECharacterLength( BufferPtr^, ByteCount );
      else ;
    end;
    AppendData( BufferPtr, ByteCount );
    {$hints off} BufferPtr := pointer( nativeuint( BufferPtr ) + ByteCount ); {$hints on}
  until CP = 0;
end;

function TStandardUnicodeString.AsString: String;
var
  CP: uint32;
  ByteCount: uint8;
  BufferPtr: pointer;
begin
  Result := '';
  CP := 0;
  ByteCount := 0;
  if fFormat = TUnicodeFormat.utfUnknown then raise TStatus.CreateException( stUTFUnknownNotSupported );
  case fFormat of
    TUnicodeFormat.utfAnsi: ByteCount := sizeof( uint8 );
    TUnicodeFormat.utf32LE: ByteCount := sizeof( uint32 );
    TUnicodeFormat.utf32BE: ByteCount := sizeof( uint32 );
    else ;
  end;
  BufferPtr := @fData[ 0 ];
  repeat
    case fFormat of
      TUnicodeFormat.utfANSI: if not TUnicodeCodec.AnsiDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf8:    if not TUnicodeCodec.UTF8Decode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf16LE: if not TUnicodeCodec.UTF16LEDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf16BE: if not TUnicodeCodec.UTF16BEDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf32LE: if not TUnicodeCodec.UTF32LEDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      TUnicodeFormat.utf32BE: if not TUnicodeCodec.UTF32BEDecode( BufferPtr^, CP ) then raise TStatus.CreateException( stUnicodeDecodingFailed );
      else ;
    end;
    if CP = 0 then exit;
    if not TUnicodeCodec.EncodeCodepointToString( CP, Result ) then raise TStatus.CreateException( stUnicodeEncodingFailed );
    case fFormat of
      TUnicodeFormat.utf8:    TUnicodeCodec.UTF8CharacterLength( BufferPtr^, ByteCount );
      TUnicodeFormat.utf16LE: TUnicodeCodec.UTF16LECharacterLength( BufferPtr^, ByteCount );
      TUnicodeFormat.utf16BE: TUnicodeCodec.UTF16BECharacterLength( BufferPtr^, ByteCount );
      else ;
    end;
    {$hints off} BufferPtr := pointer( nativeuint( BufferPtr ) + ByteCount ); {$hints on}
  until CP = 0;
end;

function TStandardUnicodeString.SizeInBytes: uint8;
begin
  Result := System.Length( fData );
end;

function TStandardUnicodeString.Length: uint8;
begin
  case fFormat of
    utfANSI: Result := CountAnsiCodepoints( @fData[ 0 ] );
    utf8: Result := CountUtf8Codepoints( @fData[ 0 ] );
    utf16LE: Result := CountUtf16LECodepoints( @fData[ 0 ] );
    utf16BE: Result := CountUtf16BECodepoints( @fData[ 0 ] );
    utf32LE: Result := CountUtf32Codepoints( @fData[ 0 ] );
    utf32BE: Result := CountUtf32Codepoints( @fData[ 0 ] );
    else begin
      raise TStatus.CreateException( stUTFUnknownNotSupported );
    end;
  end;
end;

function TStandardUnicodeString.AsPointer: pointer;
begin
  Result := @fData[ 0 ];
end;

constructor TStandardUnicodeString.Create;
begin
  inherited Create;
  SetLength( fData, 1 );
  FillChar( fData[ 0 ], 1, 0 );
  fFormat := TUnicodeFormat.utf8;
end;

constructor TStandardUnicodeString.Create( const S: string; const UnicodeFormat: TUnicodeFormat );
begin
  Create;
  SetAsString( S, UnicodeFormat );
end;

constructor TStandardUnicodeString.Create( const Source: pointer; const UnicodeFormat: TUnicodeFormat );
begin
  Create;
  SetAsUTFZero( Source, UnicodeFormat );
end;

destructor TStandardUnicodeString.Destroy;
begin
  SetLength( fData, 0 );
  inherited Destroy;
end;

end.
