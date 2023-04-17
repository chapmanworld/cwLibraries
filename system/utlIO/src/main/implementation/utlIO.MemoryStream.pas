(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlIO.MemoryStream;

interface
uses
  utlStatus
, utlIO
, utlUnicode
;

type
  TStandardMemoryStream = class( TInterfacedObject,
                                  IReadOnlyStream,
                                  IStream,
                                  IReadOnlyUnicodeStream,
                                  IUnicodeStream
                                )
  private
    fBuffer: IUnicodeBuffer;
    fGranularity: nativeuint;
    fSize: nativeuint;
    fPosition: nativeuint;

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
  strict private //- IStream -//
    procedure Clear;
    function Write( const p: pointer; const Count: nativeuint ): nativeuint; overload;
    function Write( const Value: int8 ): TStatus; overload;
    function Write( const Value: int16 ): TStatus; overload;
    function Write( const Value: int32 ): TStatus; overload;
    function Write( const Value: int64 ): TStatus; overload;
    function Write( const Value: uint8 ): TStatus; overload;
    function Write( const Value: uint16 ): TStatus; overload;
    function Write( const Value: uint32 ): TStatus; overload;
    function Write( const Value: uint64 ): TStatus; overload;
    function Write( const Value: single ): TStatus; overload;
    function Write( const Value: double ): TStatus; overload;
    function Write( const Value: boolean ): TStatus; overload;
    function Write( const Value: string ): TStatus; overload;
    function Write( const Value: TGUID ): TStatus; overload;
    function CopyFrom( const Source: IReadOnlyStream ): nativeuint;
    procedure WriteByte( const value: uint8 );
    procedure WriteBytes( const value: array of uint8 );
  strict private //- IReadOnlyUnicodeStream -//
    function ReadBOM( const Format: TUnicodeFormat ): boolean;
    function DetermineUnicodeFormat: TUnicodeFormat;
    function ReadChar( const Format: TUnicodeFormat ): char;
    function ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string;
  strict private //- IUnicodeStream -//
    procedure WriteBOM( const Format: TUnicodeFormat );
    procedure WriteChar( const aChar: char; const Format: TUnicodeFormat );
    procedure WriteString( const aString: string; const Format: TUnicodeFormat; const ZeroTerm: boolean = FALSE );
  public
    constructor Create( const BufferGranularity: nativeuint = 0 );
    destructor Destroy; override;
  end;

implementation
uses
  utlIO.Buffer
, utlIO.StreamCommon
;

constructor TStandardMemoryStream.Create( const BufferGranularity: nativeuint );
const
  cDefaultGranularity = 1024; // 1k
begin
  inherited Create;
  fBuffer := TStandardBuffer.Create();
  if BufferGranularity > 0 then begin
    fGranularity := BufferGranularity;
  end else begin
    fGranularity := cDefaultGranularity;
  end;
  Clear;
end;

destructor TStandardMemoryStream.Destroy;
begin
  fBuffer := nil;
  inherited Destroy;
end;

function TStandardMemoryStream.EndOfStream: boolean;
begin
  Result := getPosition = Size;
end;

function TStandardMemoryStream.getPosition: nativeuint;
begin
  Result := fPosition;
end;

procedure TStandardMemoryStream.setPosition( const newPosition: nativeuint );
begin
  if newPosition < fSize then fPosition := NewPosition else fPosition := fSize;
end;

function TStandardMemoryStream.getRemainingBytes: nativeuint;
begin
  Result := Size - getPosition;
end;

function TStandardMemoryStream.Read( const p: pointer; const Count: nativeuint ): nativeuint;
var
  ActualBytesToRead: nativeuint;
begin
  Result := 0;
  ActualBytesToRead := Count;
  if ActualBytesToRead > Size - getPosition then ActualBytesToRead := Size - getPosition;
  if ActualBytesToRead <= 0 then exit;
  fBuffer.ExtractData( P, getPosition, ActualBytesToRead );
  fPosition := fPosition + ActualBytesToRead;
  Result := ActualBytesToRead;
end;

function TStandardMemoryStream.Size: nativeuint;
begin
  Result := fSize;
end;

function TStandardMemoryStream.ReadByte: uint8;
begin
  Read( @Result, sizeof( uint8 ) );
end;

procedure TStandardMemoryStream.Clear;
begin
  fBuffer.Size := fGranularity;
  fSize := 0;
  fPosition := 0;
end;

function TStandardMemoryStream.Write( const p: pointer; const Count: nativeuint ): nativeuint;
begin
  while ( Count > fBuffer.Size - getPosition) do fBuffer.Size := fBuffer.Size + fGranularity;
  fBuffer.InsertData( p, getPosition, count );
  if ( getPosition + Count ) > fSize then fSize := fSize + ( ( getPosition + Count ) - fSize );
  fPosition := fPosition + Count;
  Result := Count;
end;

function TStandardMemoryStream.CopyFrom( const Source: IReadOnlyStream ): nativeuint;
const
  cCopyBlockSize = 1024;
var
  Buffer: array of uint8;
  ReadBytes: nativeuint;
  WrittenBytes: nativeuint;
begin
  Result := 0;
  Initialize( Buffer );
  try
    SetLength( Buffer, cCopyBlockSize );
    if not Source.EndOfStream then repeat
      ReadBytes := Source.Read( @Buffer[ 0 ], cCopyBlockSize );
      WrittenBytes := Write( @Buffer[ 0 ], ReadBytes );
      Result := Result + WrittenBytes;
    until ( ReadBytes < cCopyBlockSize ) or ( not WrittenBytes = ReadBytes ) or ( Source.EndOfStream );
  finally
    Finalize( Buffer );
  end;
end;

procedure TStandardMemoryStream.WriteByte( const value: uint8 );
begin
  Write( @value, sizeof( uint8 ) );
end;

procedure TStandardMemoryStream.WriteBytes( const value: array of uint8 );
begin
  Write( @value[ 0 ], Length( value ) );
end;

function TStandardMemoryStream.Read( out Value: int64 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: uint8 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: uint16 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: int8 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: int16 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: int32 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: uint32 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: boolean ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: string ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: TGUID ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: uint64 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: single ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.Read( out Value: double ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardMemoryStream.ReadBOM( const Format: TUnicodeFormat ): boolean;
begin
  Result := TStreamCommon.ReadBOM( Self, Format );
end;

function TStandardMemoryStream.DetermineUnicodeFormat: TUnicodeFormat;
begin
  Result := TStreamCommon.DetermineUnicodeFormat( Self );
end;

function TStandardMemoryStream.ReadChar( const Format: TUnicodeFormat ): char;
begin
  Result := TStreamCommon.ReadChar( Self, Format );
end;

function TStandardMemoryStream.ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string;
begin
  Result := TStreamCommon.ReadString( Self, Format, ZeroTerm, Max );
end;

function TStandardMemoryStream.Write( const Value: int64 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: uint8 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: uint16 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: int8 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: int16 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: int32 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: uint32 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: boolean ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: string ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: TGUID ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: uint64 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: single ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardMemoryStream.Write( const Value: double ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

procedure TStandardMemoryStream.WriteBOM( const Format: TUnicodeFormat );
begin
  TStreamCommon.WriteBOM( Self, Format );
end;

procedure TStandardMemoryStream.WriteChar( const aChar: char; const Format: TUnicodeFormat );
begin
  TStreamCommon.WriteChar( Self, aChar, Format );
end;

procedure TStandardMemoryStream.WriteString( const aString: string; const Format: TUnicodeFormat; const ZeroTerm: boolean = FALSE );
begin
  TStreamCommon.WriteString( Self, aString, Format, ZeroTerm );
end;

end.
