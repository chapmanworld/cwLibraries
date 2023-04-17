(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlIO.FileStream;

interface
uses
  utlStatus
, utlIO
, utlUnicode
;

type
  TStandardFileStream = class( TInterfacedObject,
                               IReadOnlyStream,
                               IStream,
                               IReadOnlyUnicodeStream,
                               IUnicodeStream
                             )
  private
    fFile: file;
    fFilePath: string;
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
    constructor Create( const Filepath: string; const ReadOnly: boolean );
    destructor Destroy; override;
  end;


implementation
uses
  SysUtils
, utlIO.StreamCommon
;

{$region ' GetIOError() '}

(*
  Attempts to map the IOResult errors to more meaningful status values.
  Provide the File/Path being operated on at the time.
  If no error occurred, GetIOError will simply return stSuccess, and because
  stSuccess does not get raized, you may call GetIOError.Raize() in order
  to perform IO result checking with exception raising.
*)
function GetIOResultAsStatus( const FileOrPath: string ): TStatus;
begin
  case IOResult of
    000: Result := TStatus.Return( stSuccess );
    002: Result := TStatus.Return( stIOFileNotFound,                 [ FileOrPath ] );
    003: Result := TStatus.Return( stIOPathNotFound,                 [ FileOrPath ] );
    004: Result := TStatus.Return( stIOTooManyOpenFiles,             [ FileOrPath ] );
    005: Result := TStatus.Return( stIOFileAccessDenied,             [ FileOrPath ] );
    006: Result := TStatus.Return( stIOInvalidFileHandle,            [ FileOrPath ] );
    012: Result := TStatus.Return( stIOInvalidFileAccessMode,        [ FileOrPath ] );
    015: Result := TStatus.Return( stIOInvalidDiskNumber,            [ FileOrPath ] );
    016: Result := TStatus.Return( stIOCannotRemoveCurrentDirectory, [ FileOrPath ] );
    017: Result := TStatus.Return( stIOCannotRenameAcrossVolumes,    [ FileOrPath ] );
    100: Result := TStatus.Return( stIOErrorReadingFromDisk,         [ FileOrPath ] );
    101: Result := TStatus.Return( stIOErrorWritingToDisk,           [ FileOrPath ] );
    102: Result := TStatus.Return( stIOFileNotAssigned,              [ FileOrPath ] );
    103: Result := TStatus.Return( stIOFileNotOpen,                  [ FileOrPath ] );
    104: Result := TStatus.Return( stIOFileNotOpenedForInput,        [ FileOrPath ] );
    105: Result := TStatus.Return( stIOFileNotOpenedForOutput,       [ FileOrPath ] );
    106: Result := TStatus.Return( stIOInvalidNumber,                [ FileOrPath ] );
    150: Result := TStatus.Return( stIODiskIsWriteProtected,         [ FileOrPath ] );
    151: Result := TStatus.Return( stIOUnknownDevice,                [ FileOrPath ] );
    152: Result := TStatus.Return( stIODriveNotReady,                [ FileOrPath ] );
    153: Result := TStatus.Return( stIOUnknownCommand,               [ FileOrPath ] );
    154: Result := TStatus.Return( stIOCRCCheckFailed,               [ FileOrPath ] );
    155: Result := TStatus.Return( stIOInvalidDriveSpecified,        [ FileOrPath ] );
    156: Result := TStatus.Return( stIOSeekErrorOnDisk,              [ FileOrPath ] );
    157: Result := TStatus.Return( stIOInvalidMediaType,             [ FileOrPath ] );
    158: Result := TStatus.Return( stIOSectorNotFound,               [ FileOrPath ] );
    159: Result := TStatus.Return( stIOPrinterOutOfPaper,            [ FileOrPath ] );
    160: Result := TStatus.REturn( stIOErrorWritingToDevice,         [ FileOrPath ] );
    161: Result := TStatus.Return( stIOErrorReadingFromDevice,       [ FileOrPath ] );
    162: Result := TStatus.Return( stIOHardwareFailure,              [ FileOrPath ] );
    else Result := TStatus.Return( stIOUnkownError,                  [ FileOrPath ] );
  end;
end;

{$endregion}

constructor TStandardFileStream.Create( const Filepath: string; const ReadOnly: boolean );
var
  Status: TStatus;
begin
  inherited Create;
  fFilePath := FilePath;
  {$I-} Assign( fFile, fFilePath ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
  if not FileExists( fFilePath ) then begin
    if ReadOnly then raise TStatus.CreateException( stIOFileNotFound, [ fFilePath ] );
    {$I-} Rewrite( fFile, sizeof( uint8 ) ); {$I+}
    Status := GetIOResultAsStatus( fFilePath );
    if not Status then raise Status.CreateException;
    exit;
  end;
  {$I-} Reset( fFile, sizeof( uint8 ) ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
end;

destructor TStandardFileStream.Destroy;
var
  Status: TStatus;
begin
  {$I-} system.Close( fFile ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
  inherited Destroy;
end;

function TStandardFileStream.EndOfStream: boolean;
begin
  Result := getPosition = Size;
end;

function TStandardFileStream.getPosition: nativeuint;
var
  Status: TStatus;
begin
  {$I-} Result := FilePos( fFile ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
end;

procedure TStandardFileStream.setPosition( const newPosition: nativeuint );
var
  Status: TStatus;
begin
  {$I-} Seek( fFile, newPosition ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
end;

function TStandardFileStream.getRemainingBytes: nativeuint;
begin
  Result := Size - getPosition;
end;

function TStandardFileStream.Read( const p: pointer; const Count: nativeuint ): nativeuint;
var
  BytesToRead: nativeuint;
  BytesRead: Integer;
  RemainingToRead: nativeuint;
  Available: nativeuint;
  Status: TStatus;
  Buffer: array[0..2047] of uint8;
  PtrOut: pointer;
begin
  BytesToRead := Count;
  Available := getRemainingBytes;
  if Count > Available then BytesToRead := Available;
  if BytesToRead = 0 then exit( 0 );
  RemainingToRead := BytesToRead;
  Result := 0;
  ptrOut := P;
  repeat
    if BytesToRead > Length( Buffer ) then BytesToRead := Length( Buffer );
    {$I-} BlockRead( fFile, Buffer[0], BytesToRead, BytesRead ); {$I+}
    Status := GetIOResultAsStatus( fFilePath );
    if not Status then raise Status.CreateException;
    Move( Buffer[0], PtrOut^, BytesRead );
    {$warnings off} ptrOut := pointer( nativeuint( PtrOut ) + BytesRead ); {$warnings on}
    {$warnings off} Result := Result + BytesRead; {$warnings on}
    {$warnings off} RemainingToRead := RemainingToRead - BytesRead; {$warnings on}
    BytesToRead := RemainingToRead;
  until RemainingToRead = 0;
end;

function TStandardFileStream.Size: nativeuint;
var
  Status: TStatus;
begin
  {$I-} Result := FileSize( fFile ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
end;

function TStandardFileStream.ReadByte: uint8;
begin
  Read( @Result, sizeof( uint8 ) );
end;

procedure TStandardFileStream.Clear;
var
  Status: TStatus;
begin
  {$I-} System.Close( fFile ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
  {$I-} sysutils.DeleteFile( fFilePath ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
  {$I-} Rewrite( fFile ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
end;

function TStandardFileStream.Write( const p: pointer; const Count: nativeuint ): nativeuint;
var
  Status: TStatus;
begin
  {$I-} BlockWrite( fFile, P^, Count ); {$I+}
  Status := GetIOResultAsStatus( fFilePath );
  if not Status then raise Status.CreateException;
  Result := Count;
end;

function TStandardFileStream.CopyFrom( const Source: IReadOnlyStream ): nativeuint;
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
      WrittenBytes := Self.Write( @Buffer[ 0 ], ReadBytes );
      Result := Result + WrittenBytes;
    until ( ReadBytes < cCopyBlockSize ) or ( not WrittenBytes = ReadBytes ) or ( Source.EndOfStream );
  finally
    Finalize( Buffer );
  end;
end;

procedure TStandardFileStream.WriteByte( const value: uint8 );
begin
  Write( @Value, sizeof( uint8 ) );
end;

procedure TStandardFileStream.WriteBytes( const value: array of uint8 );
begin
  Write( @value[ 0 ], Length( value ) );
end;

function TStandardFileStream.Read( out Value: int64 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: uint8 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: uint16 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: int8 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: int16 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: int32 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: uint32 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: boolean ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: string ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: TGUID ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: uint64 ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: single ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.Read( out Value: double ): TStatus;
begin
  Result := TStreamCommon.Read( Self, Value );
end;

function TStandardFileStream.ReadBOM( const Format: TUnicodeFormat ): boolean;
begin
  Result := TStreamCommon.ReadBOM( Self, Format );
end;

function TStandardFileStream.DetermineUnicodeFormat: TUnicodeFormat;
begin
  Result := TStreamCommon.DetermineUnicodeFormat( Self );
end;

function TStandardFileStream.ReadChar( const Format: TUnicodeFormat ): char;
begin
  Result := TStreamCommon.ReadChar( Self, Format );
end;

function TStandardFileStream.ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string;
begin
  Result := TStreamCommon.ReadString( Self, Format, ZeroTerm, Max );
end;

function TStandardFileStream.Write( const Value: int64 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: uint8 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: uint16 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: int8 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: int16 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: int32 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: uint32 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: boolean ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: string ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: TGUID ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: uint64 ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: single ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

function TStandardFileStream.Write( const Value: double ): TStatus;
begin
  Result := TStreamCommon.Write( Self, Value );
end;

procedure TStandardFileStream.WriteBOM( const Format: TUnicodeFormat );
begin
  TStreamCommon.WriteBOM( Self, Format );
end;

procedure TStandardFileStream.WriteChar( const aChar: char; const Format: TUnicodeFormat );
begin
  TStreamCommon.WriteChar( Self, aChar, Format );
end;

procedure TStandardFileStream.WriteString( const aString: string; const Format: TUnicodeFormat; const ZeroTerm: boolean = FALSE );
begin
  TStreamCommon.WriteString( Self, aString, Format, ZeroTerm );
end;

end.
