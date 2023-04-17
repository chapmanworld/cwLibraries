(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlIO.CyclicBuffer;

interface
uses
  utlIO
, utlUnicode
;

type
  TStandardCyclicBuffer = class( TInterfacedObject, ICyclicBuffer )
  private
    fBuffer: IBuffer;
    fBottom: nativeuint;
    fTop: nativeuint;
  private
    function OffsetPointer( const P: pointer; const Offset: nativeuint ): pointer; overload;
    function OffsetPointer( const Offset: nativeuint ): pointer; overload;
  strict private//- Implement IdeCyclicBuffer -//
    procedure Clear;
    function Write( const DataPtr: Pointer; const Count: nativeuint ): nativeuint;
    function Read( const DataPtr: Pointer; const Count: nativeuint ): nativeuint;
    function Peek( const DataPtr: Pointer; const Count: nativeuint ): nativeuint;
    function LoadFromStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
    function SaveToStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
    function getFreeBytes: nativeuint;
    function getUsedBytes: nativeuint;
  public
    constructor Create( const Size: nativeuint = 0 ); reintroduce;
    destructor Destroy; override;
  end;

implementation

procedure TStandardCyclicBuffer.Clear;
begin
  fBottom := 0;
  fTop := 0;
end;

constructor TStandardCyclicBuffer.Create( const Size: nativeuint = 0 );
begin
  inherited Create;
  fBuffer := TBuffer.Create( Size );
  Clear;
end;

destructor TStandardCyclicBuffer.Destroy;
begin
  fBuffer := nil;
  inherited Destroy;
end;

function TStandardCyclicBuffer.GetFreeBytes: nativeuint;
begin
  if fBottom < fTop then begin
    Result := ( fBuffer.Size - fTop ) + ( fBottom )
  end else if fTop < fBottom then begin
    Result := fBottom - fTop;
  end else begin
    Result := fBuffer.Size;
  end;
end;

function TStandardCyclicBuffer.GetUsedBytes: nativeuint;
begin
  if fTop > fBottom then begin
    Result := fTop - fBottom;
  end else if fBottom > fTop then begin
    Result := ( fBuffer.Size - fBottom ) + fTop;
  end else begin
    Result := 0;
  end;
end;

function TStandardCyclicBuffer.LoadFromStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
var
  Buffer: IBuffer;
  BytesToLoad: nativeuint;
  BytesLoaded: nativeuint;
begin
  Buffer := TBuffer.Create();
  try
    BytesToLoad := Bytes;
    if getFreeBytes < BytesToLoad then BytesToLoad := getFreeBytes;
    if ( Stream.Size - Stream.getPosition ) < BytesToLoad then begin
      BytesToLoad := ( Stream.Size - Stream.getPosition );
    end;
    Buffer.setSize( BytesToLoad );
    BytesLoaded := Buffer.LoadFromStream( Stream, BytesToLoad );
    Result := Write( Buffer.getDataPointer, BytesLoaded );
  finally
    Buffer := nil;
  end;
end;

function TStandardCyclicBuffer.OffsetPointer(const P: pointer; const Offset: nativeuint): pointer;
begin
  {$hints off} Result := pointer( nativeuint( P ) + Offset ); {$hints on}
end;

function TStandardCyclicBuffer.OffsetPointer(const Offset: nativeuint): pointer;
begin
  Result := OffsetPointer( fBuffer.getDataPointer, Offset );
end;

function TStandardCyclicBuffer.Peek(const DataPtr: Pointer; const Count: nativeuint): nativeuint;
var
  SizeToRead: nativeuint;
  Remaining: nativeuint;
  NewPtr: pointer;
begin
  Result := 0;
  if fTop > fBottom then begin
    SizeToRead := fTop - fBottom;
    if SizeToRead > Count then begin
      SizeToRead := Count;
    end;
    Move( OffsetPointer( fBottom )^, DataPtr^, SizeToRead );
    Result := SizeToRead;
  end else if fBottom >= fTop then begin
    SizeToRead := fBuffer.Size - fBottom;
    if SizeToRead > Count then begin
      SizeToRead := Count;
    end;
    Move( OffsetPointer( fBottom )^, DataPtr^, SizeToRead );
    inc( Result, SizeToRead );
    NewPtr := OffsetPointer( DataPtr, SizeToRead );
    Remaining := Count - SizeToRead;
    if Remaining > 0 then begin
      SizeToRead := fTop;
      if SizeToRead > Remaining then begin
        SizeToRead := Remaining;
      end;
      Move( OffsetPointer( fBottom )^, NewPtr^, SizeToRead );
      Result := Result + SizeToRead;
    end;
  end;
end;

function TStandardCyclicBuffer.Read( const DataPtr: Pointer; const Count: nativeuint ): nativeuint;
var
  SizeToRead: nativeuint;
  Remaining: nativeuint;
  NewPtr: pointer;
begin
  Result := 0;
  if fTop > fBottom then begin
    SizeToRead := fTop - fBottom;
    if SizeToRead > Count then SizeToRead := Count;
    Move( OffsetPointer( fBottom )^, DataPtr^, SizeToRead );
    inc( fBottom, SizeToRead );
    Result := SizeToRead;
  end else if fBottom >= fTop then begin
    SizeToRead := fBuffer.Size - fBottom;
    if SizeToRead > Count then begin
      SizeToRead := Count;
    end;
    Move( OffsetPointer( fBottom )^, DataPtr^, SizeToRead );
    inc( Result, SizeToRead );
    NewPtr := OffsetPointer( DataPtr, SizeToRead );
    Remaining := Count - SizeToRead;
    fBottom := 0;
    if Remaining > 0 then begin
      SizeToRead := fTop;
      if SizeToRead > Remaining then begin
        SizeToRead := Remaining;
      end;
      Move( OffsetPointer( fBottom )^, NewPtr^, SizeToRead );
      Result := Result + SizeToRead;
    end;
  end;
end;

function TStandardCyclicBuffer.SaveToStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
var
  BytesToWrite: nativeuint;
  Buffer: IBuffer;
begin
  BytesToWrite := Bytes;
  if BytesToWrite > getUsedBytes then BytesToWrite := getUsedBytes;
  Buffer := TBuffer.Create();
  try
    Buffer.setSize( Bytes );
    BytesToWrite := Read( Buffer.getDataPointer, BytesToWrite );
    Result := Buffer.SaveToStream( Stream, BytesToWrite );
  finally
    Buffer := nil;
  end;
end;

function TStandardCyclicBuffer.Write( const DataPtr: Pointer; const Count: nativeuint ): nativeuint;
var
  SizeToWrite: nativeuint;
  Remaining: nativeuint;
  Space: nativeuint;
  NewPtr: pointer;
  P: pointer;
begin
  SizeToWrite := getFreeBytes;
  if SizeToWrite > Count then SizeToWrite := Count;
  Remaining := SizeToWrite;
  if fTop < fBottom then begin
    P := OffsetPointer( fTop );
    Move( DataPtr^, P^, Remaining );
    inc( fTop, Remaining );
  end else if fBottom < fTop then begin
    Space := fBuffer.Size - fTop;
    if Space > Remaining then begin
      Space := Remaining;
    end;
    p := OffsetPointer( fTop );
    Move( DataPtr^, P^, Space );
    NewPtr := OffsetPointer( DataPtr, Space ); // pointer for remaining data.
    dec( Remaining, Space );
    inc( fTop, Space );
    if Remaining > 0 then begin
      P := fBuffer.getDataPointer;
      Move( NewPtr^, P^, Remaining );
      fTop := Remaining;
    end;
  end else begin
    SizeToWrite := fBuffer.Size;
    if SizeToWrite > Count then begin
      SizeToWrite := Count;
    end;
    P := OffsetPointer( fTop );
    Move( DataPtr^, P^, SizeToWrite );
    inc( fTop, SizeToWrite );
  end;
  Result := SizeToWrite;
end;

end.
