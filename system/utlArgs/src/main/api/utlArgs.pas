(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC. <br/>
  PROPERTY OF: ChapmanWorld LLC. <br/>
  ALL RIGHTS RESERVED. <br/>
*)
unit utlArgs;

interface
uses
  utlCollections
;

type
  ///  <summary>
  ///    IArguments represents either the command line arguments for the
  ///    program, or arguments of the same format that have been loaded
  ///    from a file. <br/>
  ///  </summary>
  IArguments = interface
    ['{5AAE1414-4C4E-49D1-A5BF-59C0AC5D0FF0}']

    ///  <summary>
    ///    IArguments does not read arguments exclusively from the command
    ///    line, but can be fed additional argument strings via this
    ///    AddString() method.
    ///  </summary>
    procedure AddString( const S: string );

    ///  <summary>
    ///    Returns TRUE if the specified switch is found on the
    ///    command line. <br/>
    ///  </summary>
    function Switch( const SwitchName: string ): boolean;

    ///  <summary>
    ///    If the value as specified by 'key' is found on the
    ///    command line, this method returns TRUE and sets the
    ///    'Value' out parameter to the found value. Otherwise
    ///    this method returns false.
    ///  </summary>
    function Value( const Key: string; out Value: string ): boolean;

    ///  <summary>
    ///    Any parameters provided on the command line (not via AddString),
    ///    which do not begin with a switch char ( default=hyphen '-' ), will
    ///    be added to this parameters list.
    ///  </summary>
    function Parameters: IReadOnlyList< string >;

  end;

///  <summary>
///    Returns a reference to a singleton instance of IArguments. <br/>
///    ParamStr() arguments from the command line will have been added
///    automatically.
///  </summary>
function Args: IArguments;

implementation
uses
  utlArgs.Args
;

var
  SingletonArgs: IArguments = nil;

function Args: IArguments;
begin
  if not assigned( SingletonArgs ) then begin
    SingletonArgs := TArguments.Create;
  end;
  Result := SingletonArgs;
end;

initialization
  SingletonArgs := nil;

finalization
  SingletonArgs := nil;

end.
