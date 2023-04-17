(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLexers.Scanner;

interface
uses
  utlIO
, utlLexers
;

type
  ptrChar = ^char;

  TScanner = class( TInterfacedObject, IScanner )
  private
    fLineFeedChar: char;
    fFilename: string;
    fLineNumber: nativeuint;
    fLinePosition: nativeuint;
    fEOS: boolean;
    fChild: IScanner;
    //- Actual data and cursor.
    fBuffer: IBuffer;
    fCursorPtr: ptrChar;
    fBufferTopPtr: ptrChar;
  private
    procedure LoadStream( const srcStream: IUnicodeStream; const format: TUnicodeFormat );
  strict private //- IScanner -//
    function Cursor: ICursor;
    function Current: char;
    procedure Advance;
    function EndOfStream: boolean;
    procedure InsertChild( const Scanner: IScanner );
  public
    constructor Create( const Filename: string; const SourceStream: IUnicodeStream; const UnicodeFormat: TUnicodeFormat; const LFChar: char = #10 );
    destructor Destroy; override;
  end;

implementation
uses
  utlLexers.Cursor
;

function TScanner.Cursor: ICursor;
begin
  if not assigned( fChild ) then begin
    Result := TCursor.Create( fFilename, fLineNumber, fLinePosition );
  end else begin
    Result := fChild.Cursor;
  end;
end;

function TScanner.Current: char;
begin
  if not assigned( fChild ) then begin
    Result := char( fCursorPtr^ );
    exit;
  end;
  Result := fChild.Current;
end;

procedure TScanner.Advance;
var
  tmp: pointer;
begin
  if assigned( fChild ) then begin
    fChild.Advance;
    if fChild.EndOfStream then begin
      fChild := nil;
    end;
    exit;
  end;

  // Detect EOS
  {$hints off} tmp := pointer( nativeuint( fCursorPtr ) + sizeof( char ) ); {$hints on}
  if tmp = fBufferTopPtr then begin
    fEOS := True;
    exit;
  end;

  // If not EOF, advance the cursor pointer and line/pos
  if Current = fLineFeedChar then begin
    inc( fLineNumber );
    fLinePosition := 1;
  end else begin
    inc( fLinePosition );
  end;
  fCursorPtr := tmp;
end;

function TScanner.EndOfStream: boolean;
begin
  if not assigned( fChild ) then begin
    Result := fEOS;
  end else begin
    Result := fChild.EndOfStream;
  end;
end;

procedure TScanner.InsertChild(const Scanner: IScanner);
begin
  if not assigned( fChild ) then begin
    fChild := Scanner;
  end else begin
    fChild.InsertChild( Scanner );
  end;
end;

procedure TScanner.LoadStream( const srcStream: IUnicodeStream; const format: TUnicodeFormat );
const
  cTmpBufferGranularity = 1024;
var
  tmpBuffer: IBuffer;
  tmpBufferByteCount: nativeuint;
  srcFormat: TUnicodeFormat;
  tmp: nativeuint;
  tmpPtr: ^char;
  CH: Char;
begin
  srcStream.Position := 0;
  tmpBufferByteCount := 0;

  //- If the unicode format is unknown, we attempt to determine the format
  //- from the stream, by seeking a BOM - If we can't determine the format
  //- we assume utf8;
  srcFormat := format;
  if srcFormat = TUnicodeFormat.utfUnknown then begin
    srcFormat := srcStream.DetermineUnicodeFormat;
    if srcFormat = TUnicodeFormat.utfUnknown then begin
      srcFormat := TUnicodeFormat.utf8;
    end;
  end;

  //- If there is a BOM present, remove it.
  srcStream.ReadBOM(format);

  //- Load content.
  //- In order to translate formats, when the source is not UTF16LE we must load a single character at a time.
  if format<>TUnicodeFormat.utf16LE then begin
    //- Using a temp buffer to allocate with a granularity of ctmpBufferGranularity bytes
    //- to save allocating a new buffer for EVERY character read.
    TmpBuffer := TBuffer.Create( 0 );
    try

      tmpBufferByteCount := 0;
      while not srcStream.EndOfStream do begin
        CH := srcStream.ReadChar(srcFormat);
        if tmpBufferByteCount = tmpBuffer.Size then begin
          tmpBuffer.Size := tmpBuffer.Size + ctmpBufferGranularity;
        end;
        tmpBuffer.InsertData( @ch, tmpBufferByteCount, sizeof( char ) );
        tmpBufferByteCount := tmpBufferByteCount + sizeof( char );
      end;

    finally
      fBuffer.Size := tmpBufferByteCount;
      fBuffer.InsertData( tmpBuffer.getDataPointer, 0, fBuffer.Size );
      TmpBuffer := nil;
    end;

  end else begin
    fBuffer.Size := srcStream.Size - srcStream.Position;
    fBuffer.LoadFromStream( srcStream, fBuffer.getSize );
  end;

  /// Test for empty file.
  if fBuffer.Size = 0 then begin
    fBufferTopPtr := fCursorPtr;
    fEOS          := True;
    fLinePosition := 1;
    fLineNumber   := 1;
    exit;
  end;

  //- Configure internal pointers
  fCursorPtr := fBuffer.getDataPointer; //- points at first character
  {$hints off} tmp := nativeuint( fBuffer.getDataPointer ) + fBuffer.getSize; {$hints on}
  {$hints off} fBufferTopPtr := pointer( tmp ); {$hints on} //- points beyond last character.

  //- If the stream is zero terminated, pull the buffer top back before the zero (to avoid unexpected tokens)
  repeat
    {$hints off} tmpPtr := pointer( nativeuint( fBufferTopPtr ) - sizeof( char ) ); {$hints on}
    if tmpPtr^ <> #0 then break;
    {$hints off} fBufferTopPtr := pointer( nativeuint( fBufferTopPtr ) - sizeof( char ) ); {$hints on}
  until fBufferTopPtr = fCursorPtr; //- should never get here but prevent infinite loop.

  fLineNumber := 1;
  fLinePosition := 1;
end;

constructor TScanner.Create( const Filename: string; const SourceStream: IUnicodeStream; const UnicodeFormat: TUnicodeFormat; const LFChar: char = #10 );
begin
  inherited Create;
  fLineFeedChar := LFChar;
  fFilename     := Filename;
  fLineNumber   := 1;
  fLinePosition := 1;
  fEOS          := False;
  fChild        := nil;
  fCursorPtr    := nil;
  fBufferTopPtr := nil;
  fBuffer := TBuffer.Create;
  LoadStream( SourceStream, UnicodeFormat );
end;

destructor TScanner.Destroy;
begin
  fChild  := nil;
  fBuffer := nil;
  inherited Destroy;
end;

end.




