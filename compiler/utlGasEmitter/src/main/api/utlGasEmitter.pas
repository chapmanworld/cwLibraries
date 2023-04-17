(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlGasEmitter;

interface
uses
  utlLog
, utlIO
;

const
  cUnicodeFormat = TUnicodeFormat.utf8;

{$region ' IGasEmitter '}

type
  ///  <summary>
  ///    A utility for writing gas-assembler files. <br/>
  ///    An instance of IGasEmitter provides tools for writing gas-syntax
  ///    assembler structures for various target CPUs and platforms.
  ///  </summary>
  IGasEmitter = interface
    ['{04131581-3D3A-4637-8A5C-A2FA18383DC9}']

    {$region ' Writing to stream '}
    procedure Write( const Text: string );
    procedure WriteLine( const Text: string );
    procedure WriteIndented( const Text: string );
    procedure WriteLineIndented( const Text: string );
    procedure WriteLabel( const Name: string );
    procedure WriteComment( const Text: string );
    procedure WriteCommentIndented( const Text: string );
    procedure WriteSection( const Name: string );
    {$endregion}

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
    procedure WriteAnsiStringConstant( const Value: string );
    procedure WriteByteArrayConstant( const pBytes: pointer; const ByteCount: nativeuint );
    {$endregion}

  end;

{$endregion}

type
  TGasEmitter = record
    class function Create( const Log: ILog; const Stream: IUnicodeStream; const PointerType: string ): IGasEmitter; static;
  end;

implementation
uses
  utlGasEmitter.Emitter
;

class function TGasEmitter.Create( const Log: ILog; const Stream: IUnicodeStream; const PointerType: string ): IGasEmitter;
begin
  Result := utlGasEmitter.Emitter.TGasEmitter.Create( Log, Stream, PointerType );
end;

end.


