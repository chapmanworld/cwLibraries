(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlIO.Buffer;

interface
uses
  utlStatus
, utlUnicode
, utlIO
;

type
  TStandardBuffer = class( TInterfacedObject, IBuffer, IUnicodeBuffer )
  private
    fFixed: boolean;
    fFixedPtr: boolean;
    fAlign16: boolean;
    fActualDataWhenAligned: pointer;
    fData: pointer;
    fSize: nativeuint;
  strict private  //- IBuffer -//
    procedure FillMem( const value: uint8 );
    function LoadFromStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
    function SaveToStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
    procedure Assign( const Buffer: IBuffer );
    procedure InsertData( const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint; MakeSpace: boolean = FALSE );
    procedure DeleteData( const Offset: nativeuint; const Bytes: nativeuint );
    function AppendData( const Buffer: Pointer; const Bytes: nativeuint ): pointer; overload;
    function AppendData( const Buffer: pointer ): pointer; overload;
    procedure AppendData( const Buffer: IBuffer ); overload;
    procedure ExtractData( const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint );
    function getDataPointer: pointer;
    function getSize: nativeuint;
    function getByte( const idx: nativeuint ): uint8;
    procedure setByte( const idx: nativeuint; const value: uint8 );
    procedure setSize( const aSize: nativeuint );
  strict private //- IUnicodeBuffer -//
    function ReadBOM( const Format: TUnicodeFormat ): boolean;
    procedure WriteBOM( const Format: TUnicodeFormat );
    function DetermineUnicodeFormat: TUnicodeFormat;
    function WriteString( const aString: string; const Format: TUnicodeFormat; ZeroTerm: boolean = FALSE ): nativeuint;
    function ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean = False; const Max: int32 = -1 ): string;
    function getAsString: string;
    procedure setAsString( const value: string );
    procedure AllocateBuffer( const NewSize: nativeuint );
    procedure DeallocateBuffer;
    procedure ResizeBuffer( const NewSize: nativeuint );
  public
    constructor Create( const aSize: nativeuint = 0; const Align16: boolean = FALSE ); overload;
    constructor CreateFixed( const aSize: nativeuint = 0; const DataPtr: pointer = nil );
    destructor Destroy; override;
  end;

implementation

procedure TStandardBuffer.AllocateBuffer( const NewSize: nativeuint );
begin
  if fFixed then raise TStatus.CreateException( stCannotResizeFixedBuffer );
  if ( fSize > 0 ) then DeallocateBuffer;
  if NewSize > 0 then begin
    fSize := NewSize;
    if fAlign16 then begin
      GetMem( fActualDataWhenAligned, ( fSize + $0F ) );
      {$ifdef CPU64}
      {$hints off}
      fData := pointer( ( ( nativeuint( fActualDataWhenAligned ) and $FFFFFFFFFFFFFFF0 ) + $0F ) );
      {$hints on}
      {$else}
      {$hints off}
      fData := pointer( ( ( nativeuint( fActualDataWhenAligned ) and $FFFFFFF0 ) + $0F ) );
      {$hints on}
      {$endif}
    end;
    GetMem( fData, fSize );
  end;
end;

procedure TStandardBuffer.DeallocateBuffer;
begin
  if ( fSize > 0 ) then begin
    if assigned( fData ) then begin
      if fAlign16 then begin
        FreeMem( fActualDataWhenAligned );
      end else begin
        FreeMem( fData );
      end;
    end;
    fSize := 0;
    fData := nil;
  end;
end;

function TStandardBuffer.getDataPointer: pointer;
begin
  Result := fData;
end;

function TStandardBuffer.getSize: nativeuint;
begin
  Result := fSize;
end;

function TStandardBuffer.ReadBOM( const Format: TUnicodeFormat ): boolean;
var
  BomSize: uint8;
begin
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
    Result := TUnicodeCodec.DecodeBOM( fData^, Format, BomSize );
  end else begin
    Result := False;
  end;
end;

function TStandardBuffer.ReadString( const Format: TUnicodeFormat; const ZeroTerm: boolean; const Max: int32 ): string;
var
  TotalSize: nativeuint;
  bytecount: uint8;
  ptr: pointer;
  CH: uint32;
  CP: TUnicodeCodePoint;
  S: string;
  StopOnError: boolean;
begin
  CH := 0;
  Result := '';
  if fSize = 0 then exit;
  S := '';
  bytecount := 0;
  CP := 0;
  TotalSize := 0;
  ptr := fData;
  StopOnError := False;
  while ( TotalSize < GetSize ) and ( ( Max < 0 ) or ( Length( S ) < Max ) ) and ( not StopOnError ) do begin
    Move( ptr^, CH, sizeof( CH ) );
    {$warnings off}
    case Format of

      TUnicodeFormat.utfANSI: begin
        bytecount := sizeof( uint8 );
        if not TUnicodeCodec.AnsiDecode( CH, CP ) then begin
          StopOnError := True;
          Continue;
        end;
      end;

      TUnicodeFormat.utf8: begin
        if TUnicodeCodec.UTF8CharacterLength( CH, bytecount ) then begin
          if not TUnicodeCodec.UTF8Decode( CH, CP ) then begin
            StopOnError := True;
            Continue;
          end;
          end else begin
            StopOnError := True;
            Continue;
          end;
      end;

      TUnicodeFormat.utf16LE: begin
        if TUnicodeCodec.UTF16LECharacterLength( CH, bytecount ) then begin
          if not TUnicodeCodec.UTF16LEDecode( CH, CP ) then begin
            StopOnError := True;
            Continue;
          end;
        end else begin
          StopOnError := True;
          Continue;
        end;
      end;

      TUnicodeFormat.utf16BE: begin
        if TUnicodeCodec.UTF16BECharacterLength( CH, bytecount ) then begin
          if not TUnicodeCodec.UTF16BEDecode( CH, CP ) then begin
            StopOnError := True;
            Continue;
          end;
        end else begin
          StopOnError := True;
          Continue;
        end;
      end;

      TUnicodeFormat.utf32LE: begin
        bytecount := sizeof( uint32 );
        if not TUnicodeCodec.UTF32LEDecode( CH, CP ) then begin
          StopOnError := True;
          Continue;
        end;
      end;

      TUnicodeFormat.utf32BE: begin
        bytecount := sizeof( uint32 );
        if not TUnicodeCodec.UTF32BEDecode( CH, CP ) then begin
          StopOnError := True;
          Continue;
        end;
      end;

    end;
    {$warnings on}
    if ( CP = 0 ) and ( ZeroTerm ) then Break;
    TUnicodeCodec.EncodeCodepointToString( CP, S );
    {$hints off} ptr := pointer( nativeuint( ptr ) + bytecount ); {$hints on}
    TotalSize := TotalSize + bytecount;
  end;
  Result := S;
end;

procedure TStandardBuffer.ResizeBuffer( const NewSize: nativeuint );
var
  fNewBuffer: pointer;
begin
  if fFixed then raise TStatus.CreateException( stCannotResizeFixedBuffer );
  if NewSize = fSize then exit
  else if fSize = 0 then begin
    AllocateBuffer( NewSize );
  end else if NewSize = 0 then begin
    DeallocateBuffer;
  end else begin
    GetMem( fNewBuffer, NewSize );
    FillChar( fNewBuffer^, NewSize, 0 );
    if NewSize > fSize then begin
    	Move( fData^, fNewBuffer^, fSize );
    end else begin
      Move( fData^, fNewBuffer^, NewSize );
    end;
    DeallocateBuffer;
    fData := fNewBuffer;
    fSize := NewSize;
  end;
end;

procedure TStandardBuffer.setAsString( const value: string );
begin
  SetSize( Length( value ) * 4 );
  SetSize( WriteString( value, TUnicodeFormat.utf16LE ) );
end;

procedure TStandardBuffer.setByte( const idx: nativeuint; const value: uint8 );
var
  ptr: ^uint8;
begin
  if ( idx < fSize ) then begin
    {$hints off} ptr := pointer( nativeuint( fData ) + idx ); {$hints on}
    ptr^ := value;
  end;
end;

function TStandardBuffer.LoadFromStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
begin
  if getSize <= Bytes then begin
    Stream.Read( getDataPointer, getSize );
    Result := getSize;
  end else begin
    Stream.Read( getDataPointer, Bytes );
    Result := Bytes;
  end;
end;

function TStandardBuffer.SaveToStream( const Stream: IStream; const Bytes: nativeuint ): nativeuint;
begin
  if Bytes > getSize then begin
    Stream.Write( getDataPointer, getSize );
    Result := getSize;
  end else begin
    Stream.Write( getDataPointer, Bytes );
    Result := Bytes;
  end;
end;

procedure TStandardBuffer.setSize( const aSize: nativeuint );
begin
  if fFixed then raise TStatus.CreateException( stCannotResizeFixedBuffer );
  if fSize = aSize then exit;
  ResizeBuffer( aSize );
end;

procedure TStandardBuffer.WriteBOM( const Format: TUnicodeFormat );
var
  size: uint8;
begin
  size := 0;
  TUnicodeCodec.EncodeBOM( fData^, Format, size );
end;

function TStandardBuffer.WriteString( const aString: string; const Format: TUnicodeFormat; ZeroTerm: boolean = FALSE ): nativeuint;
var
  ptr: ^char;
  CH: uint32;
  StrLen: int32;
  CP: TUnicodeCodepoint;
  Cursor: int32;
  L: uint8;
begin
  CP := 0;
  CH := 0;
  L := 0;
  Result := 0;
  StrLen := Length(aString);
  Cursor := 1;
  while ( Cursor <= StrLen) do begin
    TUnicodeCodec.DecodeCodepointFromString( CP, aString, Cursor );
    case Format of
      TUnicodeFormat.utfUnknown : raise TStatus.CreateException( stUTFUnknownNotSupported, [ 'TBuffer.WriteString' ] );
      TUnicodeFormat.utfANSI    : L := 1;
      TUnicodeFormat.utf8       : TUnicodeCodec.UTF8Encode( CP, CH, L );
      TUnicodeFormat.utf16LE    : TUnicodeCodec.UTF16LEEncode( CP, CH, L );
      TUnicodeFormat.utf16BE    : TUnicodeCodec.UTF16BEEncode( CP, CH, L );
      TUnicodeFormat.utf32LE    : TUnicodeCodec.UTF32LEEncode( CP, CH, L );
      TUnicodeFormat.utf32BE    : TUnicodeCodec.UTF32BEEncode( CP, CH, L );
    end;
    Result := Result + L;
  end;
  if ZeroTerm then begin
    case Format of
      TUnicodeFormat.utfANSI,
         TUnicodeFormat.utf8: inc( Result );
      TUnicodeFormat.utf16LE,
      TUnicodeFormat.utf16BE: inc( Result, sizeof( uint16 ) );
      TUnicodeFormat.utf32LE,
      TUnicodeFormat.utf32BE: inc( Result, sizeof( uint32 ) );
      else ;
    end;
  end;
  if (fFixed) and (Result<>fSize) then raise TStatus.CreateException( stCannotResizeFixedBuffer );
  if not fFixed then Self.AllocateBuffer( Result );
  Cursor := 1;
  ptr := fData;
  while ( Cursor <= StrLen ) do begin
    TUnicodeCodec.DecodeCodepointFromString( CP, aString, Cursor );
    {$warnings off}
    case Format of
      TUnicodeFormat.utfANSI: TUnicodeCodec.ANSIEncode( CP, CH, L );
      TUnicodeFormat.utf8   : TUnicodeCodec.UTF8Encode( CP, CH, L );
      TUnicodeFormat.utf16LE: TUnicodeCodec.UTF16LEEncode( CP, CH, L );
      TUnicodeFormat.utf16BE: TUnicodeCodec.UTF16BEEncode( CP, CH, L );
      TUnicodeFormat.utf32LE: TUnicodeCodec.UTF32LEEncode( CP, CH, L );
      TUnicodeFormat.utf32BE: TUnicodeCodec.UTF32BEEncode( CP, CH, L );
    end;
    {$warnings on}
    Move( CH, ptr^, L );
    {$hints off} ptr := pointer( nativeuint( pointer( Ptr ) ) + L ); {$hints on}
  end;
  if ZeroTerm then begin
    case Format of
      TUnicodeFormat.utfANSI,
         TUnicodeFormat.utf8: uint8( pointer( ptr )^ ) := 0;
      TUnicodeFormat.utf16LE,
      TUnicodeFormat.utf16BE: uint16( pointer( ptr )^ ) := 0;
      TUnicodeFormat.utf32LE,
      TUnicodeFormat.utf32BE: uint32( pointer( ptr )^ ) := 0;
      else ;
    end;
  end;
end;

constructor TStandardBuffer.Create( const aSize: nativeuint = 0; const Align16: boolean = FALSE );
begin
  inherited Create;
  fFixedPtr := False;
  fFixed := False;
  fData := nil;
  fSize := aSize;
  fAlign16 := Align16;
  AllocateBuffer( fSize );
end;

constructor TStandardBuffer.CreateFixed( const aSize: nativeuint = 0; const DataPtr: pointer = nil );
begin
  inherited Create;
  fFixedPtr := False;
  fData := nil;
  fSize := aSize;
  fAlign16 := FALSE;
  if assigned( DataPtr ) then begin
    fFixed := TRUE;
    fFixedPtr := TRUE;
    fData := DataPtr;
  end else begin
    fFixed := False;
    AllocateBuffer( fSize );
    fFixed := TRUE;
  end;
end;

destructor TStandardBuffer.Destroy;
begin
  if not fFixedPtr then begin
    DeallocateBuffer;
  end;
  inherited Destroy;
end;

function TStandardBuffer.DetermineUnicodeFormat: TUnicodeFormat;
begin
  Result := TUnicodeFormat.utfUnknown;
  if ReadBOM( TUnicodeFormat.utf32LE ) then begin
    Result := TUnicodeFormat.utf32LE;
  end else if ReadBOM( TUnicodeFormat. utf32BE ) then begin
    Result := TUnicodeFormat.utf32BE;
  end else if ReadBOM( TUnicodeFormat.utf16LE ) then begin
    Result := TUnicodeFormat.utf16LE
  end else if ReadBOM( TUnicodeFormat.utf16BE ) then begin
    Result := TUnicodeFormat.utf16BE;
  end else if ReadBOM( TUnicodeFormat.utf8 ) then begin
    Result := TUnicodeFormat.utf8;
  end;
end;

function TStandardBuffer.AppendData( const Buffer: pointer ): pointer;
var
  count: nativeuint;
  measurePtr: ^uint8;
begin
  count := 0;
  measurePtr := Buffer;
  while measurePtr^ <> 0 do begin
    inc( count );
    inc( measurePtr );
  end;
  Result := AppendData( Buffer, succ( Count ) );
end;

procedure TStandardBuffer.AppendData( const Buffer: IBuffer );
begin
  AppendData( Buffer.getDataPointer, Buffer.Size );
end;

procedure TStandardBuffer.Assign( const Buffer: IBuffer );
begin
  if Buffer.Size = 0 then begin
    fSize := 0;
    exit;
  end;
  SetSize( Buffer.Size );
  Move( Buffer.getDataPointer^, fData^, fSize );
end;

procedure TStandardBuffer.InsertData( const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint; MakeSpace: boolean );
var
  NewSize: nativeuint;
  NewBuffer: pointer;
  SrcPtr: pointer;
  DataPtr: pointer;
begin
  if Bytes = 0 then exit;
  if not MakeSpace then begin
    {$hints off} DataPtr := pointer( nativeuint( fData ) + Offset ); {$hints on}
    Move( Buffer^, DataPtr^, Bytes );
  end else begin
    if fFixed then raise TStatus.CreateException( stCannotResizeFixedBuffer );
    NewSize := fSize + Bytes;
    GetMem( NewBuffer, NewSize );
    if fSize > 0 then begin
       Move( fData^, NewBuffer^, Offset );
       if Offset < fSize then begin
         {$hints off} SrcPtr := pointer( nativeuint( fData ) + Offset ); {$hints on}
         {$hints off} DataPtr := pointer( nativeuint( NewBuffer ) + Offset + Bytes ); {$hints on}
         Move( SrcPtr^, DataPtr^, fSize - Offset );
       end;
    end;
    DeallocateBuffer;
    fData := NewBuffer;
    fSize := NewSize;
    InsertData( Buffer, Offset, Bytes, FALSE );
  end;
end;

procedure TStandardBuffer.DeleteData(const Offset: nativeuint; const Bytes: nativeuint);
var
  BytesToRemove: nativeuint;
  PreserveBefore: nativeuint;
  PreserveAfter: nativeuint;
  NewSize: nativeuint;
  NewBuffer: pointer;
  PtrSource: pointer;
  PtrTarget: pointer;
begin
  if fFixed then raise TStatus.CreateException( stCannotResizeFixedBuffer );
  BytesToRemove := Bytes;
  if BytesToRemove = 0 then exit;
  if Offset > fSize then exit;
  if ( Offset + BytesToRemove ) > fSize then BytesToRemove := fSize - Offset;
  if BytesToRemove = 0 then exit;
  PreserveBefore := Offset;
  PreserveAfter := fSize - ( Offset + BytesToRemove );
  NewSize := PreserveBefore + PreserveAfter;
  if NewSize = 0 then begin
    DeallocateBuffer;
    exit;
  end;
  GetMem( NewBuffer, NewSize );
  FillChar( NewBuffer^, NewSize, 0 );
  if PreserveBefore > 0 then Move( fData^, NewBuffer^, PreserveBefore );
  if PreserveAfter > 0 then begin
    {$hints off} PtrSource := pointer( nativeuint( fData ) + Offset + BytesToRemove ); {$hints on}
    {$hints off} PtrTarget := pointer( nativeuint( NewBuffer ) + PreserveBefore ); {$hints on}
    Move( ptrSource^, PtrTarget^, PreserveAfter );
  end;
  DeallocateBuffer;
  fData := NewBuffer;
  fSize := NewSize;
end;

function TStandardBuffer.AppendData( const Buffer: Pointer; const Bytes: nativeuint ): pointer;
var
  Target: NativeInt;
  TargetPtr: Pointer;
  OldSize: Longword;
begin
  Result := nil;
  if bytes = 0 then exit;
  OldSize := fSize;
  SetSize( OldSize + Bytes );
  {$HINTS OFF} Target := nativeint( fData ); {$HINTS ON}
  inc( Target, OldSize );
  {$HINTS OFF} TargetPtr := Pointer( Target ); {$HINTS ON}
  Move( Buffer^, TargetPtr^, Bytes );
  Result := TargetPtr;
end;

procedure TStandardBuffer.ExtractData( const Buffer: Pointer; const Offset: nativeuint; const Bytes: nativeuint );
var
  DataPtr: pointer;
begin
  if not assigned( Buffer ) then exit;
  if Bytes = 0 then exit;
  {$hints off} DataPtr := pointer( nativeuint( fData ) + Offset ); {$hints on}
  if Bytes > ( fSize - Offset ) then begin
    Move( DataPtr^, Buffer^, ( fSize - Offset ) );
  end else begin
    Move( DataPtr^, Buffer^, Bytes );
  end;
end;

procedure TStandardBuffer.FillMem( const value: uint8 );
begin
  FillChar( getDataPointer^, getSize, value );
end;

function TStandardBuffer.getAsString: string;
begin
  Result := ReadString( TUnicodeFormat.utf16LE );
end;

function TStandardBuffer.getByte( const idx: nativeuint ): uint8;
var
  ptr: ^uint8;
begin
  if ( idx < fSize ) then begin
    {$hints off} ptr := pointer( nativeuint( fData ) + idx ); {$hints on}
    Result := ptr^;
  end else begin
    Result := 0;
  end;
end;

end.
