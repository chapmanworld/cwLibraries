(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlIO.PartialStream;

interface
uses
  utlIO
, utlStatus
;

type
  TPartialStream = class( TInterfacedObject, IReadOnlyStream, IReadOnlyUnicodeStream )
  private
    fSourceStream: IReadOnlyUnicodeStream;
    fOffset: nativeuint;
    fSize: nativeuint;
    fCursor: nativeuint;
  strict private //- IReadOnlyStream -//
    function EndOfStream: boolean;
    function getPosition: nativeuint;
    procedure setPosition( const newPosition: nativeuint );
    function getRemainingBytes: nativeuint;
    function Read( const p: pointer; const Count: nativeuint ): nativeuint; overload;
    function Read( out Value: int8 ): TStatus; overload;
    function Read( out Value: int16 ): TStatus; overload;
    function Read( out Value: int32 ): TStatus; overload;
    function Read( out Value: int64 ): TStatus; overload;
    function Read( out Value: uint8 ): TStatus; overload;
    function Read( out Value: uint16 ): TStatus; overload;
    function Read( out Value: uint32 ): TStatus; overload;
    function Read( out Value: uint64 ): TStatus; overload;
    function Read( out Value: single ): TStatus; overload;
    function Read( out Value: double ): TStatus; overload;
    function Read( out Value: boolean ): TStatus; overload;
    function Read( out Value: string ): TStatus; overload;
    function Read( out Value: TGUID ): TStatus; overload;
    function Size: nativeuint;
    function ReadByte: uint8;
  strict private //- IReadOnlyUnicodeStream -//
    function ReadBOM( const Format: TUnicodeFormat ): boolean;
    function DetermineUnicodeFormat: TUnicodeFormat;
    function ReadChar( const Format: TUnicodeFormat ): char;
    function ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string;
  public
    constructor Create( const SourceStream: IReadOnlyUnicodeStream; const Offset: nativeuint; const Size: nativeuint ); reintroduce;
    destructor Destroy; override;
  end;

implementation

constructor TPartialStream.Create( const SourceStream: IReadOnlyUnicodeStream; const Offset, Size: nativeuint );
begin
  inherited Create;
  fSourceStream := SourceStream;
  fOffset := Offset;
  fSize := Size;
  fCursor := 0;
end;

destructor TPartialStream.Destroy;
begin
  fSourceStream := nil;
  inherited Destroy;
end;

function TPartialStream.DetermineUnicodeFormat: TUnicodeFormat;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.DetermineUnicodeFormat;
    fCursor := fSourceStream.Position - fOffset;
    if fCursor > fSize then raise TStatus.CreateException( stStreamReadError );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.EndOfStream: boolean;
begin
  Result := fCursor >= fSize;
end;

function TPartialStream.getPosition: nativeuint;
begin
  Result := fCursor;
end;

function TPartialStream.getRemainingBytes: nativeuint;
begin
  if fCursor > fSize then exit( 0 );
  Result := fSize - fCursor;
end;

function TPartialStream.Read( out Value: uint8 ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( uint8 ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: int64 ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( int64 ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: uint16 ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( uint16 ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: uint32 ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( uint32 ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( const p: pointer; const Count: nativeuint ): nativeuint;
var
  StorePosition: nativeuint;
  Remaining: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Remaining := getRemainingBytes;
    if Remaining >= Count then begin
      Result := fSourceStream.Read( p, Count );
      inc( fCursor, Count );
    end else if Remaining > 0 then begin
      inc( fCursor, Remaining );
      Result := fSourceStream.Read( P, Remaining );
    end else exit( 0 );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: int8 ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( int8 ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: int16 ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( int16 ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: int32 ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( int32 ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: boolean ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( boolean ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: string ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    if not Result then exit;
    fCursor := fSourceStream.Position - fOffset;
    if fCursor > ( fSize ) then exit( stStreamReadError );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: TGUID ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( TGUID ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: uint64 ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( uint64 ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: single ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( single ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.Read( out Value: double ): TStatus;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.Read( Value );
    inc( fCursor, sizeof( double ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.ReadBOM( const Format: TUnicodeFormat ): boolean;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.ReadBOM( Format );
    fCursor := fSourceStream.Position - fOffset;
    if fCursor > fSize then raise TStatus.CreateException( stStreamReadError );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.ReadByte: uint8;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.ReadByte;
    inc( fCursor, sizeof( uint8 ) );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.ReadChar( const Format: TUnicodeFormat ): char;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.ReadChar( Format );
    fCursor := fSourceStream.Position - fOffset;
    if fCursor > fSize then raise TStatus.CreateException( stStreamReadError );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

function TPartialStream.ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean; const Max: int32 ): string;
var
  StorePosition: nativeuint;
begin
  StorePosition := fSourceStream.Position;
  try
    fSourceStream.Position := fOffset + fCursor;
    Result := fSourceStream.ReadString( Format, ZeroTerm, Max );
    fCursor := fSourceStream.Position - fOffset;
    if fCursor > fSize then raise TStatus.CreateException( stStreamReadError );
  finally
    fSourceStream.Position := StorePosition;
  end;
end;

procedure TPartialStream.setPosition( const newPosition: nativeuint );
begin
  fCursor := NewPosition;
  if fCursor > fSize then fCursor := fSize;
end;

function TPartialStream.Size: nativeuint;
begin
  Result := fSize;
end;

end.
