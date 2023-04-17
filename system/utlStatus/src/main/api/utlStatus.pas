(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlStatus;

interface
uses
  SysUtils
;

{$region ' Status values '}

const
  stUnknown                        : TGUID = '{00000000-0000-0000-0000-000000000000}';
  stSuccess                        : TGUID = '{11111111-1111-1111-1111-111111111111}';
  stIndexOutOfBounds               : TGUID = '{1BCD139B-E4B2-477E-B7DA-DF542AE2FBDA}';
  stOffsetOutOfBounds              : TGUID = '{53BF72D0-4994-4336-86E3-D88A6113F3E1}';

{$endregion}

type
  ///  <summary>
  ///    When a call is made to TStatus.CreateException, this is the class of exception raised.
  ///  </summary>
  EStatus = class( Exception );

type
  ///  <summary>
  ///    An object which supports IAsString may be returned as a string by calling the AsString() method. <br/>
  ///    ( Useful for passing interfaces as parameters when parameterizing status messages )
  ///  <summary>
  IAsString = interface
    ['{FB24095F-B954-4A73-859A-9B96430CB610}']

    ///  <summary>
    ///    Returns the string representation of this object.
    ///  </summary>
    function AsString: string;
  end;

type
  ///  <summary>
  ///    TStatus is a record type with operator overloads and functions which
  ///    allow it to be treated as one of several types. It is intended to be
  ///    returned from a function or method, to indicate a success or failure state. <br/>
  ///    TStatus may be treated as a boolean, a string, or an exception class which
  ///    may be raised in the case of failure. The status type also supports features
  ///    for string translation for internationalization purposes. <br/>
  ///    The total payload of a TStatus, when not populated with error information, is
  ///    that of sizeof( pointer ) for the target system. <br/>
  ///    For more information on the usage of TStatus, please see the sample applications
  ///    in the 'samples/TStatus' directory.
  ///  </summary>
  TStatus = record
  private
    fStatus: array of TGUID;  // - Dynamic arrays are always initialized (nil) length=0, making it possible to test.
    fParameters: array of string;
    class function LookupText( const Status: TGUID; out Text: string ): boolean; static;
    class function StatusExists( const Status: TGUID ): boolean; static;
    class function StatusToString( const Status: TStatus ): string; static;
    class procedure Parameterize( var Status: TStatus; const Parameters: array of const ); static;
    class function IsInitialized( const Status: TStatus ): boolean; static;
    class procedure EnsureInitialized( var Status: TStatus ); static;
  public
    class operator Implicit( const Value: TStatus ): boolean;
    class operator Explicit( const Value: TStatus ): boolean;
    class operator Implicit( const Value: TStatus ): string;
    class operator Explicit( const Value: TStatus ): string;
    class operator Implicit( const Value: TGUID ): TStatus;
    class operator Explicit( const Value: TGUID ): TStatus;
    class operator logicalNot( const Value: TStatus ): boolean;
    class operator Equal( const A: TStatus; const B: TStatus ): boolean;
    class operator NotEqual( const A: TStatus; const B: TStatus ): boolean;
    class operator Equal( const A: TStatus; const B: TGUID ): boolean;
    class operator NotEqual( const A: TStatus; const B: TGUID ): boolean;
    class operator Equal( const A: TGUID; const B: TStatus ): boolean;
    class operator NotEqual( const A: TGUID; const B: TStatus ): boolean;
  public
    class procedure Register( const Status: TGUID; const DefaultText: string ); static;
    class function Return( const Status: TGUID ): TStatus; overload; static;
    function Return( const Parameters: array of const ): TStatus; overload;
    class function Return( const Status: TGUID; const Parameters: array of const ): TStatus; overload; static;
    function CreateException: Exception; overload;
    function CreateException( const Parameters: array of const ): Exception; overload;
    class function CreateException( const Status: TGUID ): Exception; overload; static;
    class function CreateException( const Status: TGUID; const Parameters: array of const ): Exception; overload; static;
  end;

implementation
uses
  AnsiStrings
;

const
  cStatusGranularity = 16;

var
  StatusGUIDS: array of TGUID;
  StatusTexts: array of string;
  StatusCount: nativeuint = 0;


(*
    Converts a TVarRec into a string. <br/>
    TVarRec is provided by "compiler magic" when passing an
    "array of const" as a parameter. For example, consider the
    well known FPC Format() function, which takes a string and
    an "array of const" as parameters. Format inserts each of
    the provided constants into the provided string, regardless
    of their data-type. The const to string conversion is made
    possible because the compiler converts the "array of const"
    parameter into an array of TVarRec, which may then be used
    to convert each item to a string representation. <br/><br/>
    VarToString() performs the same task as Format() does internally
    to convert a TVarRec into its string representation. This is
    used to enable the TStatus() type in cwRuntime to be populated
    with place-holder values witin its translated string representation.
*)
function VarToString( const VarRec: TVarRec ): string; inline;
begin
  case VarRec.vtype of
    vtInteger       : Result := string( IntToStr( VarRec.vinteger ) );
    vtBoolean       : if VarRec.vboolean then Result := 'TRUE' else Result := 'FALSE';
    vtChar          : Result := string( VarRec.vchar );
    vtWideChar      : Result := string( VarRec.VWideChar );
    vtPWideChar     : Result := string( VarRec.VPWideChar );
    vtExtended      : Result := FloatToStr( VarRec.VExtended^ );
    vtCurrency      : Result := FloatToStr( VarRec.VCurrency^ );
    vtPointer       : Result := string( IntToStr( {$hints off} nativeuint( VarRec.VPointer ) {$hints on} ) );
    vtPChar         : Result := string( VarRec.VPChar );
    vtInterface     : begin
      if SysUtils.Supports( IInterface( VarRec.VInterface ), IAsString ) then begin
        Result := ( IInterface( VarRec.VInterface ) as IAsString ).AsString;
      end else begin
        Result := '???';
      end;
    end;
    vtObject        : begin
      if SysUtils.Supports( VarRec.VObject, IAsString ) then begin
        Result := ( TInterfacedObject( VarRec.VObject ) as IAsString ).AsString;
      end else begin
        Result := '???';
      end;
    end;
    vtClass         : Result := 'class:' + string( VarRec.VClass.Classname );
    vtString        : Result := string( VarRec.VString );
    vtWideString    : Result := string( VarRec.VWideString );
    vtAnsiString    : Result := string( AnsiStrings.StrPas( pAnsiChar( VarRec.VAnsiString ) ) );
    vtUnicodeString : Result := string( VarRec.VUnicodeString );
    else              Result := '???' ;
  end;
end;


class function TStatus.StatusExists( const Status: TGUID ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if StatusCount = 0 then exit;
  for idx := 0 to pred( StatusCount ) do begin
    if IsEqualGUID( StatusGUIDS[ idx ], Status ) then exit( true );
  end;
end;

class function TStatus.LookupText( const Status: TGUID; out Text: string ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  Text := '';
  if StatusCount = 0 then exit;
  for idx := 0 to pred( StatusCount ) do begin
    if IsEqualGUID( StatusGUIDS[ idx ], Status ) then begin
      Text := StatusTexts[ idx ];
      exit( true );
    end;
  end;
end;

class procedure TStatus.Register( const Status: TGUID; const DefaultText: string );
begin
  if StatusExists( Status ) then begin
    raise EStatus.Create( 'Unable to register status as guid already exists.' );
  end;
  if Length( StatusGUIDS ) >= StatusCount then begin
    SetLength( StatusGUIDS, Length( StatusGUIDS ) + cStatusGranularity );
    SetLength( StatusTexts, Length( StatusTexts ) + cStatusGranularity );
  end;
  StatusGUIDS[ StatusCount ] := Status;
  StatusTexts[ StatusCount ] := DefaultText;
  inc( StatusCount );
end;

class function TStatus.IsInitialized( const Status: TStatus ): boolean;
begin
  Result := Length( Status.fStatus ) > 0;
end;

class procedure TStatus.EnsureInitialized( var Status: TStatus );
begin
  if IsInitialized( Status ) then exit;
  SetLength( Status.fStatus, 1 );
  Status.fStatus[ 0 ] := stUnknown;
end;

class function TStatus.StatusToString( const Status: TStatus ): string;
var
  s: string;
  idx: nativeuint;
begin
  S := '';
  if not IsInitialized( Status ) then begin
    TStatus.LookupText( stUnknown, S );
  end else begin
    if not TStatus.LookupText( Status.fStatus[ 0 ], S ) then begin
      raise EStatus.Create('Unable to resolve status message.');
    end;
  end;
  if Length( Status.fParameters ) = 0 then exit( S );
  for idx := 0 to pred( length( Status.fParameters ) ) do begin
    S := StringReplace( S, '(%%)', Status.fParameters[ idx ], [] );
  end;
  Result := S;
end;

class procedure TStatus.Parameterize( var Status: TStatus; const Parameters: array of const );
var
  idx: nativeuint;
begin
  EnsureInitialized( Status );
  SetLength( Status.fParameters, Length( Parameters ) );
  if Length( Status.fParameters ) = 0 then exit;
  for idx := 0 to pred( Length( Status.fParameters ) ) do begin
    Status.fParameters[ idx ] := VarToString( Parameters[ idx ] );
  end;
end;

class operator TStatus.Implicit( const Value: TStatus ): boolean;
begin
  if not IsInitialized( Value ) then exit( false );
  Result := IsEqualGUID( Value.fStatus[ 0 ], stSuccess );
end;

class operator TStatus.Explicit( const Value: TStatus ): boolean;
begin
  if not IsInitialized( Value ) then exit( false );
  Result := IsEqualGUID( Value.fStatus[ 0 ], stSuccess );
end;

class operator TStatus.Implicit( const Value: TStatus ): string;
begin
  Result := TStatus.StatusToString( Value );
end;

class operator TStatus.Explicit( const Value: TStatus ): string;
begin
  Result := TStatus.StatusToString( Value );
end;

class operator TStatus.Implicit( const Value: TGUID ): TStatus;
begin
  SetLength( Result.fStatus, 1 );
  Result.fStatus[ 0 ] := Value;
  SetLength( Result.fParameters, 0 );
end;

class operator TStatus.Explicit( const Value: TGUID ): TStatus;
begin
  SetLength( Result.fStatus, 1 );
  Result.fStatus[ 0 ] := Value;
  SetLength( Result.fParameters, 0 );
end;

class operator TStatus.logicalNot( const Value: TStatus ): boolean;
begin
  if not IsInitialized( Value ) then exit( true );
  Result := not IsEqualGUID( Value.fStatus[ 0 ], stSuccess );
end;

class operator TStatus.Equal( const A: TStatus; const B: TStatus ): boolean;
begin
  if ( IsInitialized( A ) and IsInitialized( B ) ) then begin
    exit( IsEqualGUID( A.fStatus[ 0 ], B.fStatus[ 0 ] ) );
  end;
  if ( IsInitialized( A ) ) or ( IsInitialized( B ) ) then exit( false );
  Result := true;
end;

class operator TStatus.NotEqual( const A: TStatus; const B: TStatus ): boolean;
begin
  if ( IsInitialized( A ) and IsInitialized( B ) ) then begin
    exit( not IsEqualGUID( A.fStatus[ 0 ], B.fStatus[ 0 ] ) );
  end;
  if ( IsInitialized( A ) ) or ( IsInitialized( B ) ) then exit( true );
  Result := false;
end;

class operator TStatus.Equal( const A: TStatus; const B: TGUID ): boolean;
begin
  if ( not IsInitialized( A ) ) then begin
    exit( IsEqualGUID( stUnknown, B ) );
  end;
  Result := IsEqualGUID( A.fStatus[ 0 ], B );
end;

class operator TStatus.NotEqual( const A: TStatus; const B: TGUID ): boolean;
begin
  if ( not IsInitialized( A ) ) then begin
    exit( not IsEqualGUID( stUnknown, B ) );
  end;
  Result := not IsEqualGUID( A.fStatus[ 0 ], B );
end;

class operator TStatus.Equal( const A: TGUID; const B: TStatus ): boolean;
begin
  if ( not IsInitialized( B ) ) then begin
    exit( IsEqualGUID( stUnknown, A ) );
  end;
  Result := IsEqualGUID( A, B.fStatus[ 0 ] );
end;

class operator TStatus.NotEqual( const A: TGUID; const B: TStatus ): boolean;
begin
  if ( not IsInitialized( B ) ) then begin
    exit( not IsEqualGUID( stUnknown, A ) );
  end;
  Result := not IsEqualGUID( A, B.fStatus[ 0 ] );
end;

class function TStatus.Return( const Status: TGUID ): TStatus;
begin
  EnsureInitialized( Result );
  Result.fStatus[ 0 ] := Status;
  SetLength( Result.fParameters, 0 );
end;

function TStatus.Return( const Parameters: array of const ): TStatus;
begin
  EnsureInitialized( Self );
  EnsureInitialized( Result );
  Result.fStatus[ 0 ] := Self.fStatus[ 0 ];
  if Length( Parameters ) = 0 then exit;
  TStatus.Parameterize( Result, Parameters );
end;

class function TStatus.Return( const Status: TGUID; const Parameters: array of const ): TStatus;
begin
  EnsureInitialized( Result );
  Result.fStatus[ 0 ] := Status;
  SetLength( Result.fParameters, 0 );
  if Length( Parameters ) = 0 then exit;
  TStatus.Parameterize( Result, Parameters );
end;

function TStatus.CreateException: Exception;
begin
  if IsInitialized( Self )  and IsEqualGUID( fStatus[ 0 ], stSuccess ) then exit( nil );
  Result := EStatus.Create( TStatus.StatusToString( Self ) );
end;

class function TStatus.CreateException( const Status: TGUID ): Exception;
var
  aStatus: TStatus;
begin
  EnsureInitialized( aStatus );
  aStatus.fStatus[ 0 ] := Status;
  Result := aStatus.CreateException;
end;

function TStatus.CreateException( const Parameters: array of const ): Exception;
begin
  TStatus.Parameterize( Self, Parameters );
  Result := Self.CreateException;
end;

class function TStatus.CreateException( const Status: TGUID; const Parameters: array of const ): Exception;
var
  aStatus: TStatus;
begin
  EnsureInitialized( aStatus );
  aStatus.fStatus[ 0 ] := Status;
  TStatus.Parameterize( aStatus, Parameters );
  Result := aStatus.CreateException;
end;

initialization
  TStatus.Register( stUnknown           , 'Unknown' );
  TStatus.Register( stSuccess           , 'Success' );
  TStatus.Register( stIndexOutOfBounds  , 'Index out of bounds "(%%)"' );
  TStatus.Register( stOffsetOutOfBounds , 'Offset out of bounds "(%%)"' );

end.
