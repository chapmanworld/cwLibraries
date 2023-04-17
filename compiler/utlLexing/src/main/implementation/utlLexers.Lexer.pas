(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLexers.Lexer;

interface
uses
  utlStatus
, utlLog
, utlLexers
;

type
  TLexer< TTokenType > = class( TInterfacedObject, ILexer< TTokenType > )
  private
    fLog: ILog;
    fScanner: IScanner;
    fToken: TTokenType;
    fData: string;
    fUnknown: TTokenType;
    fEOS: TTokenType;
    fTokenizer: ITokenizer< TTokenType >;
    fEquality: TTokenEquality< TTokenType >;
  strict private //- ITokenizer< TTokenType > -//
    function Cursor: ICursor;
    function Data: string;
    function Expect( const Token: TTokenType; const Expected: string ): TStatus; overload;
    function Expect( const Tokens: array of TTokenType; const Expected: string ): TStatus; overload;
    function Match( const Token: TTokenType ): boolean; overload;
    function Match( const Tokens: array of TTokenType ): boolean; overload;
    function Current: TTokenType;
    function EndOfStream: boolean;
    procedure Next;
  public
    constructor Create( const Log: ILog; const Scanner: IScanner; const Tokenizer: ITokenizer< TTokenType >; const Equality: TTokenEquality< TTokenType > );
    destructor Destroy; override;
  end;

implementation
uses
  utlLexers.Cursor
, utlLexers.Scanner
;

function TLexer< TTokenType >.Cursor: ICursor;
begin
  Result := fScanner.Cursor;
end;

function TLexer< TTokenType >.Data: string;
begin
  Result := fData;
end;

function TLexer< TTokenType >.Expect( const Token: TTokenType; const Expected: string ): TStatus;
begin
  if fEquality( fToken, Token ) then exit( stSuccess );
  if assigned( fLog ) then begin
    Result := fLog.Insert( stExpected, lsError, [ fScanner.Cursor, Expected ] );
  end else begin
    Result := stExpected;
  end;
end;

function TLexer< TTokenType >.Expect( const Tokens: array of TTokenType; const Expected: string ): TStatus;
var
  Token: TTokenType;
begin
  for Token in Tokens do begin
    if fEquality( fToken, Token ) then exit( stSuccess );
  end;
  if assigned( fLog ) then begin
    Result := fLog.Insert( stExpected, lsError, [ fScanner.Cursor, Expected ] );
  end else begin
    Result := stExpected;
  end;
end;

function TLexer< TTokenType >.Match( const Token: TTokenType ): boolean;
begin
  if fEquality( fToken, Token ) then exit( true );
  Result := False;
end;

function TLexer< TTokenType >.Match( const Tokens: array of TTokenType ): boolean;
var
  Token: TTokenType;
begin
  for Token in Tokens do begin
    if fEquality( fToken, Token ) then exit( true );
  end;
  Result := False;
end;

function TLexer< TTokenType >.Current: TTokenType;
begin
  Result := fToken;
end;

function TLexer< TTokenType >.EndOfStream: boolean;
begin
  Result := fEquality( fToken, fEOS ) or ( fScanner.EndOfStream );
end;

procedure TLexer< TTokenType >.Next;
begin
  if fEquality( fToken, fEOS ) then exit;
  fToken := fUnknown;
  fData := '';
  if fScanner.EndOfStream then begin
    fToken := fEOS;
    exit;
  end;
  fTokenizer.SkipWhitespace( fScanner );
  if fScanner.EndOfStream then begin
    fToken := fEOS;
    exit;
  end;
  fTokenizer.GetNextToken( fScanner, fToken, fData );
end;

constructor TLexer< TTokenType >.Create( const Log: ILog; const Scanner: IScanner; const Tokenizer: ITokenizer< TTokenType >; const Equality: TTokenEquality< TTokenType > );
begin
  inherited Create;
  fLog       := Log;
  fScanner   := Scanner;
  fTokenizer := Tokenizer;
  fEquality  := Equality;
  fEOS       := fTokenizer.EOSToken;
  fUnknown   := fTokenizer.UnknownToken;
  fToken     := fUnknown;
  fData      := '';
  if ( not assigned( fScanner ) ) or
     ( not assigned( fTokenizer ) ) or
     ( not assigned( fEquality ) ) then begin
    fToken := fEOS;
    exit;
  end;
end;

destructor TLexer< TTokenType >.Destroy;
begin
  fScanner := nil;
  inherited Destroy;
end;

end.
