(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLexers;

interface
uses
  utlStatus
, utlCollections
, utlLog
, utlIO
;

{$region ' Status messages '}

const
  stLexerNotFound          : TGUID = '{0BCADADE-8DC0-461B-80AE-0300B722DE76}';
  stLexerAlreadyRegistered : TGUID = '{9C151F4C-AA73-4878-AA50-69342220F721}';
  stExpected               : TGUID = '{AB92AE96-4C46-499E-B135-BC852347534A}';

{$endregion}

{$region ' ICursor '}

type
  ///  <summary>
  ///    A reference counted cursor object that may be obtained
  ///    from the scanner during parsing.
  ///  <summary>
  ICursor = interface
  ['{1F4CC41A-45B1-4A1F-8A33-A5087028C427}']

    ///  <summary>
    ///    The name of the file being scanned when this cursor was generated.
    ///  </summary>
    function Filename: string;

    ///  <summary>
    ///    Returns the line number being scanned when this cursor was generated.
    ///  </summary>
    function LineNumber: nativeuint;

    ///  <summary>
    ///     Returns the line position being scanned when this cursor was generated.
    ///  </summary>
    function LinePosition: nativeuint;

    ///  <summary>
    ///    Copies the contents of SourceCursor to this one.
    ///  </summary>
    procedure Assign( const SourceCursor: ICursor );

  end;

{$endregion}

{$region ' IScanner '}

type
  ///  <summary>
  ///    An interface for referencing the source code scanner.
  ///    This scanner has the ability to nest source files which
  ///    is handy for include files.
  ///  </summary>
  IScanner = interface
  ['{A5733AD5-973B-4F9B-9D81-CE7E6EAF263A}']

    ///  <summary>
    ///    Returns an instance of ICursor to describe
    ///    the location of the scanner within the source file(s).
    ///  </summary>
    function Cursor: ICursor;

    ///  <summary>
    ///    Returns the character at the current cursor position within
    ///    the file being scanned. <br/>
    ///    This method does not advance the cursor.
    ///  </sumamry>
    function Current: char;

    ///  <summary>
    ///    Advances the scanning cursor to the next location. <br/>
    ///    When the end of the source code is reached, Advance will
    ///    simply fail to advance the cursor. <br/>
    ///    It is up to the caller to call EndOfFile() to determine if the
    ///    end of file has been reached. EndOfFile() will only return
    ///    true when the cursor has advanced beyond the final character.
    ///  </summary>
    procedure Advance;

    ///  <summary>
    ///    Returns true if the scanner is positioned to look at a character
    ///    beyond the last character in the source.
    ///  </summary>
    function EndOfStream: boolean;

    ///  <summary>
    ///    Inserts a new scanner into this one as a child at the current
    ///    cursor position. All calls to scanner methods will be forwarded
    ///    to the child until it reaches EOF, at which point, the child
    ///    scanner will be disposed and scanning operations revert to
    ///    its parent scanner. <br/> (Allow for include files).
    ///  </summary>
    procedure InsertChild( const Scanner: IScanner );

  end;

{$endregion}

{$region ' ITokenizer< TTokenType > '}

type
  ///  <summary>
  ///    ITokenizer< TTokenType > is the piece of the lexer that you must
  ///    supply. Implement ITokenizer< TToken > and register a lexer with
  ///    the ILexers singleton using a factory for your implementation.
  ///  </summary>
  ITokenizer< TTokenType > = interface
    ['{582BF433-F976-4AFF-9129-387982704172}']

    ///  <summary>
    ///    Because ITokenizer<> is a generic type, allowing for any data-type
    ///    to be provided to represent tokens, utlLexer has no way to know
    ///    which value should be returned by a lexer when it reaches the
    ///    end of the input stream. <br/>
    ///    This method should return an approprote value for the end of
    ///    stream token.
    ///  </summary>
    function EOSToken: TTokenType;

    ///  <summary>
    ///    Because ITokenizer<> is a generic type, allowing for any data-type
    ///    to be provided to represent tokens, utlLexer has no way to know
    ///    which value should be returned by a lexer when it is unable to
    ///    determine the next token value. <br/>
    ///    This method should return an approprote value for the end of
    ///    stream token.
    ///  </summary>
    function UnknownToken: TTokenType;

    ///  <summary>
    ///    Your tokenizer should read characters from the scanner so long
    ///    as the current character is one which should be considered as
    ///    whitespace for the input syntax. <br/>
    ///    For each whitespace character encountered, call Scanner.Next <br/>
    ///    You must also check Scanner.EndOfStream for every character read
    ///    and simply exit SkipWhitespace of EndOfStream is encountered.
    ///  </summary>
    procedure SkipWhitespace( const Scanner: IScanner );

    ///  <summary>
    ///    Your implementation of GetNexttoken() should read characters from
    ///    the scanner in order to determine the next token value. When the
    ///    value is identified, set the 'Token' var parameter to an appropriate
    ///    token value. <br/>
    ///    If you are unable to determine the next token, exit without altering
    ///    the 'Token' parameter. <br/>
    ///    If it is relevant, your implementation of GetNextToken must also
    ///    set the 'Data' var parameter. For instance, if tokenizing an
    ///    identifier named 'XYZ', you should set the 'Token' parameter to
    ///    a token such as tkIdentifier, and the Data parameter to 'XYZ' in
    ///    order that the lexer is able to present the identifier name to
    ///    a parser.
    ///  </summary>
    procedure GetNextToken( const Scanner: IScanner; var Token: TTokenType; var Data: string );

  end;

{$endregion}

{$region ' ILexer< TTokenType > '}

type
  ///  <summary>
  ///    A lexer is responsible for reading 'tokens' from an input stream
  ///    in order that the parser can make use of them. This is a generic
  ///    implementation of a lexer that can be instanced by a call to the
  ///    singleton  Lexers().Instance< TTokenType > function. <br/>
  ///    The actual functionality for this lexer is injected in the form
  ///    of a user implemented ITokenizer< TTokenType >.
  ///  </summary>
  ILexer< TTokenType > = interface
    ['{25FCCEC4-FC06-4E65-BA33-E882100459CE}']

    ///  <summary>
    ///    Returns the cursor location at which the
    ///    current token was found.
    ///  </summary>
    function Cursor: ICursor;

    ///  <summary>
    ///    If the token contains data, such as a numerical
    ///    or string literal, that data is returned by this method.
    ///  </summary>
    function Data: string;

    ///  <summary>
    ///    This overload of Expect() tests to see if the current token
    ///    matches that in the 'Token' parameter. If the current token
    ///    is not of the specified type, an stExpected status is returned
    ///    which is pre-populated using the 'expected' string parameter.
    ///  </summary>
    function Expect( const Token: TTokenType; const Expected: string ): TStatus; overload;

    ///  <summary>
    ///    This overload of Expect() tests to see if the current token matches
    ///    one of those in the 'Tokens' array parameter. If the current token
    ///    does not match one of those specified, an stExpected status is
    ///    returned, which is pre-populated using the 'expected' string parameter.
    ///  </summary>
    function Expect( const Tokens: array of TTokenType; const Expected: string ): TStatus; overload;

    ///  <summary>
    ///     Returns true if the current token matches the 'Token' parameter.
    ///  </summary>
    function Match( const Token: TTokenType ): boolean; overload;

    ///  <summary>
    ///     Returns true if the current token matches one of those in the 'Tokens' array parameter.
    ///  </summary>
    function Match( const Tokens: array of TTokenType ): boolean; overload;

    ///  <summary>
    ///    The generic TTokenType is expected to be an enum type, and this method
    ///    will return the current token. When instancing TTokenizer< TTokenType >, one
    ///    of the constructor parameters is an 'unknown' token value, which will be the
    ///    default returned token value before a call to 'Next' is made to advance
    ///    the tokenizer through its source stream. <br/>
    ///    The unknown value may also be returned if the user-provided tokenizing
    ///    method is unable to identify the next token. <br/>
    ///    Also watch for a matching 'EOF' token indicating that the tokenizer
    ///    reached the end of its input stream ( again, provided to constructor ).
    ///  </summary>
    function Current: TTokenType;

    ///  <summary>
    ///    Returns true if the tokenizer has reached the end of the input stream.
    ///  </summary>
    function EndOfStream: boolean;

    ///  <summary>
    ///    Advances the tokenizer to the next token in the input stream.
    ///  </summary>
    procedure Next;
  end;

{$endregion}

{$region ' Lexers '}

type
  ///  <summary>
  ///    A factory method for instancing custom tokenizers. <br/>
  ///    See usage information in comments above.
  ///  </summary>
  TTokenizerFactory< TTokenType > = function (): ITokenizer< TTokenType >;

  ///  <summary>
  ///    A equality comparing function to compare A to B.
  ///  </summary>
  TTokenEquality< TTokenType > = function ( const A, B: TTokenType ): boolean;

type
  ///  <summary>
  ///    Lexers represents a singleton container of available lexers that
  ///    are registered via a call to RegisterLezer<>;
  ///  </summary>
  Lexers = record
  public
    ///  <summary>
    ///    Registers a new lexer with the system. <br/>
    ///  </summary>
    class procedure RegisterLexer< TTokenType >( const Name: string; const Factory: TTokenizerFactory< TTokenType >; const Equality: TTokenEquality< TTokenType > ); static;

    ///  <summary>
    ///    Creates an instance of a lexer that was previously registered via
    ///    the RegisterLexer< TTokenType >() method.
    ///  </summary>
    class function CreateLexer< TTokenType >( const Log: ILog; const Name: string; const SourceFilePath: string ): ILexer< TTokenType >; static;
  end;

{$endregion}

implementation
uses
  SysUtils
, utlLexers.Lexer
, utlLexers.Common
, utlLexers.Scanner
;

class function Lexers.CreateLexer< TTokenType >( const Log: ILog; const Name: string; const SourceFilePath: string ): ILexer< TTokenType >;
var
  FoundIdx: nativeuint;
  Scanner: IScanner;
  FS: IUnicodeStream;
begin
  if not FindLexerRecord( Name, FoundIdx ) then raise TStatus.CreateException( stLexerNotFound, [ Name ] );
  FS := TFileStream.Create( SourceFilePath, TRUE );
  try
    Scanner := TScanner.Create( ExtractFileName( SourceFilePath ), FS, TUnicodeFormat.utfUnknown );
  finally
    FS := nil;
  end;
  try
    Result := TLexer< TTokenType >.Create(
      Log,
      Scanner,
      TTokenizerFactory< TTokenType > ( LexerRecordByIndex( FoundIdx ).Factory ),
      TTokenEquality< TTokenType >( LexerRecordByIndex( FoundIdx ).Equality )
    );
  finally
    Scanner := nil;
  end;
end;

class procedure Lexers.RegisterLexer< TTokenType >( const Name: string; const Factory: TTokenizerFactory< TTokenType >; const Equality: TTokenEquality< TTokenType > );
var
  FoundIdx: nativeuint;
  LexerRecord: TLexerRecord;
begin
  if FindLexerRecord( Name, FoundIdx ) then raise TStatus.CreateException( stLexerAlreadyRegistered, [ Name ] );
  LexerRecord.Name := Name;
  LexerRecord.Factory := Addr( Factory );
  LexerRecord.Equality := Addr( Equality );
  AddLexerRecord( LexerRecord );
end;

initialization
  TStatus.Register( stLexerNotFound          , 'Internal Error: Lexer "(%%)" not found.' );
  TStatus.Register( stLexerAlreadyRegistered , 'Internal Error: A lexer named "(%%)" is already registered.' );
  TStatus.Register( stExpected               , '(%%) : Expected "(%%)".' );

end.
