(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlGasEmitter.Emitter;

interface
uses
  utlLog
, utlIO
, utlGasEmitter
;

type
  TGasEmitter = class( TInterfacedObject, IGasEmitter )
  private
    fLog: ILog;
    fStream: IUnicodeStream;
    fPtrType: string;
  strict private //- IGasEmitter -//

    procedure Write( const Text: string );
    procedure WriteLine( const Text: string );
    procedure WriteIndented( const Text: string );
    procedure WriteLineIndented( const Text: string );
    procedure WriteLabel( const Name: string );
    procedure WriteComment( const Text: string );
    procedure WriteCommentIndented( const Text: string );
    procedure WriteSection( const Name: string );

    {$region ' Windows / PE-file only '}
    procedure BeginThunkTable( const Module: string );
    procedure WriteThunk( const Module: string; const Symbol: string );
    procedure EndThunkTable;
    procedure WriteIDTEntry( const Module: string );
    procedure EndIDT;
    procedure BeginILT;
    procedure BeginILTModule( const Module: string );
    procedure WriteILTEntry( const Module: string; const Symbol: string );
    procedure EndILTModule( const Module: string );
    procedure EndILT;
    procedure WriteModuleName( const Module: string );
    procedure WriteHint( const Module: string; const Symbol: string );
    {$endregion}

    {$region ' Constant Data '}
    procedure WriteByteArrayConstant( const pBytes: pointer; const ByteCount: nativeuint );
    procedure WriteAnsiStringConstant( const Value: string );
    {$endregion}
  public
    constructor Create( const Log: ILog; const Stream: IUnicodeStream; const PointerType: string ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlTypes
;

procedure TGasEmitter.BeginILT;
begin
  WriteLine( 'ilt_start: ');
end;

procedure TGasEmitter.BeginILTModule( const Module: string );
begin
  WriteLine( 'ilt_' + Module + ':' );
end;

procedure TGasEmitter.BeginThunkTable( const Module: string );
begin
  WriteLine( 'thunk_table_' + Module + ': ' );
end;

constructor TGasEmitter.Create( const Log: ILog; const Stream: IUnicodeStream; const PointerType: string );
begin
  inherited Create;
  fLog     := Log;
  fStream  := Stream;
  fPtrType := PointerType;
end;

destructor TGasEmitter.Destroy;
begin
  fStream := nil;
  fLog    := nil;
  inherited Destroy;
end;

procedure TGasEmitter.EndIDT;
begin
  WriteLine( 'idt_ends: ');
  WriteLineIndented( '.long 0x00' );
  WriteLineIndented( '.long 0x00' );
  WriteLineIndented( '.long 0x00' );
  WriteLineIndented( '.long 0x00' );
  WriteLineIndented( '.long 0x00' );
  WriteLine( '' );
end;

procedure TGasEmitter.EndILT;
begin
  WriteLine( 'ilt_end: ');
  WriteLine( '');
end;

procedure TGasEmitter.EndILTModule( const Module: string );
begin
  WriteLine( 'ilt_end_' + Module + ': ' + fPtrType + ' 0x00 ' );
end;

procedure TGasEmitter.EndThunkTable;
begin
  WriteLineIndented( fPtrType + ' 0x00' );
  WriteLine( '' );
end;

procedure TGasEmitter.WriteILTEntry( const Module: string; const Symbol: string );
begin
  WriteLineIndented( 'ilt_entry_' + Symbol +': ' + fPtrType + ' hint_' + Module + '_' + Symbol );
end;

procedure TGasEmitter.WriteIndented( const Text: string );
begin
  Write( TAB + Text );
end;

procedure TGasEmitter.Write( const Text: string );
begin
  fStream.WriteString( Text, cUnicodeFormat );
end;

procedure TGasEmitter.WriteAnsiStringConstant( const Value: string );
begin
  WriteLineIndented( '.asciz "' + Value + '"' );
end;

procedure TGasEmitter.WriteByteArrayConstant( const pBytes: pointer; const ByteCount: nativeuint );
var
  idx: nativeuint;
  HexString: string;
  EOL: boolean;
  pByte: ^uint8;
begin
  if ByteCount = 0 then exit;
  pByte := pBytes;
  HexString := '.byte ';
  for idx := 0 to pred( ByteCount ) do begin
    HexString := HexString + '0x' + uint8( pByte^ ).AsHex;
    EOL := ( idx < pred( ByteCount ) ) and ( idx > 1 ) and ( ( idx mod 8 ) = 0 );
    if ( idx < pred( ByteCount ) ) and ( not EOL ) then HexString := HexString + ', ';
    if EOL then HexString := HexString + LF + TAB + '.byte ';
    inc( pByte );
  end;
  WriteLineIndented( HexString );
end;

procedure TGasEmitter.WriteComment( const Text: string );
begin
  WriteLine( '# ' + Text );
end;

procedure TGasEmitter.WriteCommentIndented(const Text: string);
begin
  WriteLineIndented( '# ' + Text );
end;

procedure TGasEmitter.WriteHint( const Module: string; const Symbol: string );
begin
  WriteLine( 'hint_' + Module + '_' + Symbol + ': ' );
  WriteLineIndented( ' .word 0x00' );
  WriteLineIndented( ' .ascii "' + Symbol + '\0"' );
end;

procedure TGasEmitter.WriteIDTEntry( const Module: string );
begin
  WriteLine( 'idt_' + Module + ':' );
  WriteLineIndented( '.long ilt_' + Module );
  WriteLineIndented( '.long 0x00' );
  WriteLineIndented( '.long 0x00' );
  WriteLineIndented( '.long name_' + Module );
  WriteLineIndented( '.long text ' );
  WriteLine( '' );
end;

procedure TGasEmitter.WriteModuleName( const Module: string );
begin
  WriteLine( 'name_' + Module +': .ascii "' + Module + '\0"' );
end;

procedure TGasEmitter.WriteSection( const Name: string );
begin
  WriteLine( '.section .' + Name );
  WriteLabel( Name );
  WriteLine( '' );
end;

procedure TGasEmitter.WriteThunk( const Module: string; const Symbol: string );
begin
  WriteLine( Module + '_' + Symbol + ': ' + fPtrType + ' hint_' + Module + '_' + Symbol );
end;

procedure TGasEmitter.WriteLabel( const Name: string );
begin
  WriteLine( Name + ':' );
end;

procedure TGasEmitter.WriteLine( const Text: string );
begin
  Write( Text + LF );
end;

procedure TGasEmitter.WriteLineIndented( const Text: string );
begin
  WriteLine( TAB + Text );
end;

end.
