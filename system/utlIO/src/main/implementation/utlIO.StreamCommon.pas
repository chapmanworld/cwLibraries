(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlIO.StreamCommon;

interface
uses
  utlStatus
, utlIO
, utlUnicode
;

type
  (* Provides common unicode functionality to aid in implementing streams
     with unicode support. The methods are reflections of those in the IReadOnlyUnicodeStream and
     IUnicodeStream interfaces. *)
  TStreamCommon = record
    class function Read( const Stream: IStream; out Value: int8    ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: int16   ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: int32   ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: int64   ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: uint8   ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: uint16  ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: uint32  ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: uint64  ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: single  ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: double  ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: boolean ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: string  ): TStatus; overload; static;
    class function Read( const Stream: IStream; out Value: TGUID   ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: int8    ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: int16   ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: int32   ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: int64   ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: uint8   ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: uint16  ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: uint32  ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: uint64  ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: single  ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: double  ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: boolean ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: string  ): TStatus; overload; static;
    class function Write( const Stream: IStream; const Value: TGUID   ): TStatus; overload; static;

    class procedure WriteBOM( const Stream: IStream; const Format: TUnicodeFormat ); static;
    class procedure WriteChar( const Stream: IStream; const aChar: char; const Format: TUnicodeFormat ); static;
    class procedure WriteString( const Stream: IStream; const aString: string; const Format: TUnicodeFormat; const ZeroTerm: boolean = FALSE ); static;
    class function ReadBOM( const Stream: IStream; const Format: TUnicodeFormat ): boolean; static;
    class function DetermineUnicodeFormat( const Stream: IStream ): TUnicodeFormat; static;
    class function ReadChar( const Stream: IStream; const Format: TUnicodeFormat ): char; static;
    class function ReadString( const Stream: IStream; const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string; static;
  end;

implementation

class function TStreamCommon.Write( const Stream: IStream; const Value: double ): TStatus;
begin
  if Stream.Write( @Value, sizeof( double ) ) <> sizeof( double ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: single ): TStatus;
begin
  if Stream.Write( @Value, sizeof( single ) ) <> sizeof( single ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: uint64 ): TStatus;
begin
  if Stream.Write( @Value, sizeof( uint64 ) ) <> sizeof( uint64 ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: TGUID ): TStatus;
begin
  if Stream.Write( @Value, sizeof( TGUID ) ) <> sizeof( TGUID ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: string ): TStatus;
const
  cUnicodeFormat = utf8;
var
  utfString: IUnicodeString;
  StringSize: uint64;
  WrittenBytes: nativeuint;
begin
  utfString := TUnicodeString.Create( Value, cUnicodeFormat );
  try
    StringSize := utfString.SizeInBytes;
    Result := Write( Stream, StringSize );
    if not Result then exit;
    WrittenBytes := Stream.Write( utfString.AsPointer, StringSize );
    if WrittenBytes <> StringSize then exit( TStatus.Return( stStreamWriteError ) );
    Result := stSuccess;
  finally
    utfString := nil;
  end;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: boolean ): TStatus;
var
  B: int8;
begin
  if Value then B := 0 else B := -1;
  Result := TStreamCommon.Write( Stream, B );
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: uint32 ): TStatus;
begin
  if Stream.Write( @Value, sizeof( uint32 ) ) <> sizeof( uint32 ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: int32 ): TStatus;
begin
  if Stream.Write( @Value, sizeof( int32 ) ) <> sizeof( int32 ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: int16 ): TStatus;
begin
  if Stream.Write( @Value, sizeof( int16 ) ) <> sizeof( int16 ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: int8 ): TStatus;
begin
  if Stream.Write( @Value, sizeof( int8 ) ) <> sizeof( int8 ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: uint16 ): TStatus;
begin
  if Stream.Write( @Value, sizeof( uint16 ) ) <> sizeof( uint16 ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: uint8 ): TStatus;
begin
  if Stream.Write( @Value, sizeof( uint8 ) ) <> sizeof( uint8 ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class function TStreamCommon.Write( const Stream: IStream; const Value: int64 ): TStatus;
begin
  if Stream.Write( @Value, sizeof( int64 ) ) <> sizeof( int64 ) then TStatus.Return( stStreamWriteError );
  Result := stSuccess;
end;

class procedure TStreamCommon.WriteBOM( const Stream: IStream; const Format: TUnicodeFormat );
var
  Buffer: uint64;
  L: uint8;
begin
  {$hints off} TUnicodeCodec.EncodeBOM( Buffer, Format, L ); {$hints on}
  Stream.Write( @Buffer, L );
end;

class procedure TStreamCommon.WriteChar( const Stream: IStream; const aChar: char; const Format: TUnicodeFormat );
var
  Cursor: int32;
  Buffer: uint64;
  CP: uint32;
  L: uint8;
  aString: string;
begin
  aString := '' + aChar;
  Cursor := 1;
  CP := 0;
  L := 0;
  TUnicodeCodec.DecodeCodepointFromString( CP, aString, Cursor );
  Buffer := 0;
  case Format of
    TUnicodeFormat.utfANSI: TUnicodeCodec.ANSIEncode( CP, Buffer, L );
    TUnicodeFormat.utf8   : TUnicodeCodec.UTF8Encode( CP, Buffer, L );
    TUnicodeFormat.utf16LE: TUnicodeCodec.UTF16LEEncode( CP, Buffer, L );
    TUnicodeFormat.utf16BE: TUnicodeCodec.UTF16BEEncode( CP, Buffer, L );
    TUnicodeFormat.utf32LE: TUnicodeCodec.UTF32LEEncode( CP, Buffer, L );
    TUnicodeFormat.utf32BE: TUnicodeCodec.UTF32BEEncode( CP, Buffer, L );
    else ;
  end;
  Stream.Write( @Buffer, L );
end;

class procedure TStreamCommon.WriteString( const Stream: IStream; const aString: string; const Format: TUnicodeFormat; const ZeroTerm: boolean = FALSE );
var
  Cursor: int32;
  Buffer: uint64;
  CP: uint32;
  L: uint8;
  lZero: uint32;
begin
  lZero := 0;
  Cursor := 1;
  while ( Cursor <= Length( aString ) ) do begin
    CP := 0;
    L := 0;
    TUnicodeCodec.DecodeCodepointFromString( CP, aString, Cursor );
    Buffer := 0;
    case Format of
      TUnicodeFormat.utfANSI: TUnicodeCodec.ANSIEncode( CP, Buffer, L );
      TUnicodeFormat.utf8   : TUnicodeCodec.UTF8Encode( CP, Buffer, L );
      TUnicodeFormat.utf16LE: TUnicodeCodec.UTF16LEEncode( CP, Buffer, L );
      TUnicodeFormat.utf16BE: TUnicodeCodec.UTF16BEEncode( CP, Buffer, L );
      TUnicodeFormat.utf32LE: TUnicodeCodec.UTF32LEEncode( CP, Buffer, L );
      TUnicodeFormat.utf32BE: TUnicodeCodec.UTF32BEEncode( CP, Buffer, L );
      else ;
    end;
    Stream.Write( @Buffer, L );
  end;
  if ZeroTerm then begin
    case Format of
      utfANSI: Stream.Write( @lZero, sizeof( uint8 ) );
      utf8   : Stream.Write( @lZero, sizeof( uint8 ) );
      utf16LE: Stream.Write( @lZero, sizeof( uint16 ) );
      utf16BE: Stream.Write( @lZero, sizeof( uint16 ) );
      utf32LE: Stream.Write( @lZero, sizeof( uint32 ) );
      utf32BE: Stream.Write( @lZero, sizeof( uint32 ) );
      else ;
    end;
  end;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: double ): TStatus;
begin
  if Stream.Read( @Value, sizeof( double ) ) <> sizeof( double ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: single ): TStatus;
begin
  if Stream.Read( @Value, sizeof( single ) ) <> sizeof( single ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: uint64 ): TStatus;
begin
  if Stream.Read( @Value, sizeof( uint64 ) ) <> sizeof( uint64 ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: TGUID ): TStatus;
begin
  if Stream.Read( @Value, sizeof( TGUID ) ) <> sizeof( TGUID ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: string ): TStatus;
const
  cUnicodeFormat = utf8;
var
  utfString: IUnicodeString;
  StringSize: uint64;
  ReadBytes: uint64;
  Buffer: array of uint8;
begin
  Result := Read( Stream, StringSize );
  if not Result then exit;
  SetLength( Buffer, succ( StringSize ) );
  try
    FillChar( Buffer[ 0 ], Length( Buffer ), 0 );
    ReadBytes := Stream.Read( @Buffer[ 0 ], StringSize );
    if ReadBytes <> StringSize then exit( TStatus.Return( stStreamReadError ) );
    utfString := TUnicodeString.Create( @Buffer[ 0 ], cUnicodeFormat );
    try
      Value := utfString.AsString;
    finally
      utfString := nil;
    end;
  finally
    SetLength( Buffer, 0 );
  end;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: boolean ): TStatus;
var
  B: uint8;
begin
  Result := TStreamCommon.Read( Stream, B );
  if not Result then exit;
  Value := B = 0;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: uint32 ): TStatus;
begin
  if Stream.Read( @Value, sizeof( uint32 ) ) <> sizeof( uint32 ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: int32 ): TStatus;
begin
  if Stream.Read( @Value, sizeof( int32 ) ) <> sizeof( int32 ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: int16 ): TStatus;
begin
  if Stream.Read( @Value, sizeof( int16 ) ) <> sizeof( int16 ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: int8 ): TStatus;
begin
  if Stream.Read( @Value, sizeof( int8 ) ) <> sizeof( int8 ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: uint16 ): TStatus;
begin
  if Stream.Read( @Value, sizeof( uint16 ) ) <> sizeof( uint16 ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: uint8 ): TStatus;
begin
  if Stream.Read( @Value, sizeof( uint8 ) ) <> sizeof( uint8 ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.Read( const Stream: IStream; out Value: int64 ): TStatus;
begin
  if Stream.Read( @Value, sizeof( int64 ) ) <> sizeof( int64 ) then TStatus.Return( stStreamReadError );
  Result := stSuccess;
end;

class function TStreamCommon.ReadBOM( const Stream: IStream; const Format: TUnicodeFormat ): boolean;
var
  p: uint64;
  BomSize: uint8;
  Buffer32: uint32;
  Buffer16: uint16;
begin
  Result := False;
  Buffer16 := 0;
  Buffer32 := 0;
  P := Stream.Position;
  try
    BomSize := 0;
    case Format of
      TUnicodeFormat.utfUnknown: BomSize := 0;
         TUnicodeFormat.utfANSI: BomSize := 0;
            TUnicodeFormat.utf8: BomSize := 3;
         TUnicodeFormat.utf16LE: BomSize := 2;
         TUnicodeFormat.utf16BE: BomSize := 2;
         TUnicodeFormat.utf32LE: BomSize := 4;
         TUnicodeFormat.utf32BE: BomSize := 4;
    end;
    if BomSize > 0 then begin
      if BomSize > 2 then begin
        if Stream.Read( @Buffer32, BOMSize ) = BOMSize then begin
          Result := TUnicodeCodec.DecodeBOM( Buffer32, Format, BOMSize );
        end;
      end else begin
        Stream.Read( @Buffer16, BomSize );
        Result := TUnicodeCodec.DecodeBOM( Buffer16, Format, BomSize );
      end;
    end;
  finally
    if not Result then begin
      Stream.Position := P;
    end;
  end;
end;

class function TStreamCommon.DetermineUnicodeFormat( const Stream: IStream ): TUnicodeFormat;
begin
  Result := TUnicodeFormat.utfUnknown;
  if TStreamCommon.ReadBOM( Stream, TUnicodeFormat.utf32LE ) then begin
    Result := TUnicodeFormat.utf32LE;
  end else if TStreamCommon.ReadBOM( Stream, TUnicodeFormat.utf32BE ) then begin
    Result := TUnicodeFormat.utf32BE;
  end else if TStreamCommon.ReadBOM( Stream, TUnicodeFormat.utf16LE ) then begin
    Result := TUnicodeFormat.utf16LE
  end else if TStreamCommon.ReadBOM( Stream, TUnicodeFormat.utf16BE ) then begin
    Result := TUnicodeFormat.utf16BE;
  end else if TStreamCommon.ReadBOM( Stream, TUnicodeFormat.utf8 ) then begin
    Result := TUnicodeFormat.utf8;
  end;
end;

class function TStreamCommon.ReadChar( const Stream: IStream; const Format: TUnicodeFormat ): char;
var
  CP: uint32;
  bytecount: uint8;
  Buffer: uint64;
  BufferPtr: pointer;
  aString: string;
begin
  CP := 0;
  Result := chr($0);
  ByteCount := 0;
  if Format = TUnicodeFormat.utfUnknown then exit;
  if ( not Stream.                      EndOfStream ) then begin
    BufferPtr := @Buffer;
    case Format of

      TUnicodeFormat.utfANSI: begin
        Stream.Read( BufferPtr, sizeof( uint8 ) );
        TUnicodeCodec.AnsiDecode( Buffer, CP );
      end;

      TUnicodeFormat.utf8: begin
        Stream.Read( BufferPtr, sizeof( uint8 ) );
        TUnicodeCodec.UTF8CharacterLength( Buffer, bytecount );
        if bytecount>1 then begin
          {$hints off} BufferPtr := pointer( nativeuint( BufferPtr ) + sizeof( uint8 ) ); {$hints on}
          Stream.Read( BufferPtr, pred( bytecount ) );
        end;
        TUnicodeCodec.UTF8Decode( Buffer, CP );
      end;

      TUnicodeFormat.utf16LE: begin
        Stream.Read( BufferPtr, sizeof( uint16 ) );
        TUnicodeCodec.UTF16LECharacterLength( Buffer, bytecount );
        if bytecount > 2 then begin
          {$hints off} BufferPtr := pointer( nativeuint( BufferPtr ) + sizeof( uint16 ) ); {$hints on}
          Stream.Read( BufferPtr, sizeof( uint16 ) );
        end;
        TUnicodeCodec.UTF16LEDecode( Buffer, CP );
      end;

      TUnicodeFormat.utf16BE: begin
        Stream.Read( BufferPtr, sizeof( uint16 ) );
        TUnicodeCodec.UTF16BECharacterLength( Buffer, bytecount );
        if bytecount > 2 then begin
          {$hints off} BufferPtr := pointer( nativeuint( BufferPtr ) + sizeof( uint16 ) ); {$hints on}
          Stream.Read( BufferPtr, sizeof( uint16 ) );
        end;
        TUnicodeCodec.UTF16BEDecode( Buffer, CP );
      end;

      TUnicodeFormat.utf32LE: begin
        Stream.Read( BufferPtr, Sizeof( uint32 ) );
        TUnicodeCodec.UTF32LEDecode( Buffer, CP );
      end;

      TUnicodeFormat.utf32BE: begin
        Stream.Read( BufferPtr, Sizeof( uint32 ) );
        TUnicodeCodec.UTF32BEDecode( Buffer, CP );
      end;

      else ;
    end;
    aString := '';
    TUnicodeCodec.EncodeCodepointToString( CP, aString );
    Result := aString[ 1 ];
  end;
end;

class function TStreamCommon.ReadString( const Stream: IStream; const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string;
var
  count: int32;
  CP: uint32;
  bytecount: uint8;
  Buffer: uint64;
  BufferPtr: pointer;
begin
  Result := '';
  CP := 0;
  ByteCount := 0;
  if Format = TUnicodeFormat.utfUnknown then exit;
  count := 0;
  while ( ( not Stream.EndOfStream ) and ( Max < 0 ) ) or
        ( ( Max >= 0 ) and ( count < Max ) ) do begin
    BufferPtr := @Buffer;
    case Format of

      TUnicodeFormat.utfANSI: begin
        Stream.Read( BufferPtr, sizeof( uint8 ) );
        TUnicodeCodec.AnsiDecode( Buffer, CP );
      end;

      TUnicodeFormat.utf8: begin
        Stream.Read( BufferPtr, sizeof( uint8 ) );
        TUnicodeCodec.UTF8CharacterLength( Buffer, bytecount );
        if bytecount > 1 then begin
          {$hints off} BufferPtr := pointer( nativeuint( BufferPtr ) + sizeof( uint8 ) ); {$hints on}
          Stream.Read( BufferPtr, pred( bytecount ) );
        end;
        TUnicodeCodec.UTF8Decode( Buffer, CP );
      end;

      TUnicodeFormat.utf16LE: begin
        Stream.Read( BufferPtr, sizeof( uint16 ) );
        TUnicodeCodec.UTF16LECharacterLength( Buffer, bytecount );
        if bytecount > 2 then begin
          {$hints off} BufferPtr := pointer(nativeuint(BufferPtr) + sizeof(uint16)); {$hints on}
          Stream.Read( BufferPtr, sizeof( uint16 ) );
        end;
        TUnicodeCodec.UTF16LEDecode( Buffer, CP );
      end;

      TUnicodeFormat.utf16BE: begin
        Stream.Read( BufferPtr, sizeof( uint16 ) );
        TUnicodeCodec.UTF16BECharacterLength( Buffer, bytecount );
        if bytecount>2 then begin
          {$hints off} BufferPtr := pointer( nativeuint( BufferPtr ) + sizeof( uint16 ) ); {$hints on}
          Stream.Read( BufferPtr, sizeof( uint16 ) );
        end;
        TUnicodeCodec.UTF16BEDecode( Buffer, CP );
      end;

      TUnicodeFormat.utf32LE: begin
        Stream.Read( BufferPtr, Sizeof( uint32 ) );
        TUnicodeCodec.UTF32LEDecode( Buffer, CP );
      end;

      TUnicodeFormat.utf32BE: begin
        Stream.Read( BufferPtr, Sizeof( uint32 ) );
        TUnicodeCodec.UTF32BEDecode( Buffer, CP );
      end;

      else ;
    end;
    if ( CP = 0 ) and ( ZeroTerm ) then exit;
    TUnicodeCodec.EncodeCodepointToString( CP, Result );
    inc( count );
  end;
end;

end.
