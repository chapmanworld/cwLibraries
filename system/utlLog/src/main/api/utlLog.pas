(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLog;

interface
uses
  utlStatus
;

{$region ' TLogSeverity '}

type
  ///  <summary>
  ///    Enumeration to provide an indication of the severity of
  ///    a log entry.
  ///  </summary>
  TLogSeverity = (

    ///  <summary>
    ///    Log entries inserted with a severity of lsNone are
    ///    simply ignored. This log level is used when setting
    ///    the log level to filter nothing.
    ///  </summary>
    lsNone    = $00,

    ///  <summary>
    ///    Reserved to provide information to the developer during
    ///    debugging. Generally, the log level of 'lsDebug' will be
    ///    set within conditional defines, such that the log entry
    ///    is only inserted into the log targets while debugging
    ///    the application.
    ///  </summary>
    lsDebug   = $01,

    ///  <summary>
    ///    Used to provide logging of low-level events for use during
    ///    fault finding. lsVerbose is most useful for fault finding
    ///    for host/environment issues. For example, verbose logging
    ///    may be used on release level builds in q/a or production
    ///    environments during testing or stand-up, to identify
    ///    faults specific to the host environment.
    ///  </summary>
    lsVerbose = $02,

    ///  <summary>
    ///    Application level logging to inform the end-user of
    ///    information about what the application is doing at
    ///    any given time.
    ///  </summary>
    lsInfo    = $03,

    ///  <summary>
    ///    Hints are usually inserted into the log to provide the end
    ///    user of the application with notifications of configuration
    ///    settings which could be altered to improve performance, stability
    ///    or other key metrics for the application.
    ///  </summary>
    lsHint    = $04,

    ///  <summary>
    ///    Warnings are usually inserted into the log to caution the
    ///    end user of undesirable configuration or operation states which
    ///    do not necessarily indicate a fault, but could lead to fault
    ///    at a later stage.
    ///  </summary>
    lsWarning = $05,

    ///  <summary>
    ///    Errors are inserted into the log when the application enters an
    ///    erroneous state, but may still continue to function or recover.
    ///  </summary>
    lsError   = $06,

    ///  <summary>
    ///    Fatal errors are inserted into the log when an error state has
    ///    been encountered from which the application is unable to recover.
    ///    While fatal log entries are the last entry inserted into the log
    ///    before the application shut-down process begins. (Not necessarily
    ///    the very last message since the application may continue logging
    ///    during shutdown)
    ///  </summary>
    lsFatal   = $07
  );

{$endregion}

{$region ' ILogTarget '}

type
  ///  <summary>
  ///    An instance of ILogTarget is passed to the constructor
  ///    of TLog, in order to provide the log with somewhere to
  ///    send inserted log messages. <br/>
  ///    Implement your own log target, or use one of the
  ///    defined log target classes defined within this
  ///    unit.
  ///  </summary>
  ILogTarget = interface
    ['{4BA55916-9522-4A2C-92BF-030E5002A7D6}']

    ///  <summary>
    ///    When a log message is inserted into an instance of ILog, it
    ///    makes a call to this method in its assigned log target. <br/>
    ///    The received message is a pre-translated and pre-formated
    ///    text message.
    ///  </summary>
    procedure LogMessage( const LogMessage: string );
  end;

{$endregion}

{$region ' ILog '}

type
  ///  <summary>
  ///    An instance of ILog may be used to generate logging output for
  ///    your application, using TStatus for language translation.
  ///  </summary>
  ILog = interface
    ['{F55DD837-3175-46BC-AF18-202DE4378F4D}']

    ///  <summary>
    ///    Adds a target for log messages to be written to as they are
    ///    inserted.
    ///  </summary>
    procedure AddLogTarget( const LogTarget: ILogTarget );

    ///  <summary>
    ///    Inserts an entry into the log. <br/>
    ///    An overload makes the parameters array optional.
    ///  </summary>
    function Insert( const Status: TStatus; const Severity: TLogSeverity; const Parameters: array of const ): TStatus; overload;
    ///  <exclude/>
    function Insert( const Status: TStatus; const Severity: TLogSeverity ): TStatus; overload;
  end;

{$endregion}

{$region ' TLog '}

type
  ///  <summary>
  ///    A factory for creating instances of ILog.
  ///  </summary>
  TLog = record

    ///  <summary>
    ///    Creates an instance of ILog. <br/>
    ///    The provided LogTarget determines where the log message should
    ///    be sent, and may optionally add additional information (such as
    ///    a time-stamp for instance) to the log message. <br/>
    ///    If the LogTarget is set nil, log messages are simply supressed. <br/>
    ///    LogLevel may be optionally set to filter the entries
    ///    inserted into the log. When set, messages of the same severity
    ///    or lower, will be omitted from the log.
    ///  </summary>
    class function Create( const LogLevel: TLogSeverity = lsNone ): ILog; static;

  end;

{$endregion}

implementation

type
  TStandardLog = class( TInterfacedObject, ILog )
  private
    fLogTargets: array of ILogTarget;
    fLogTargetCount: nativeuint;
    fLogLevel: TLogSeverity;
  private
    function LogSeverityToString(const Severity: TLogSeverity): string;
  strict private //- ILog -//
    procedure AddLogTarget( const LogTarget: ILogTarget );
    function Insert( const Status: TStatus; const Severity: TLogSeverity; const Parameters: array of const ): TStatus; overload;
    function Insert( const Status: TStatus; const Severity: TLogSeverity ): TStatus; overload;
  public
    constructor Create( const LogLevel: TLogSeverity );
    destructor Destroy; override;
  end;


function TStandardLog.LogSeverityToString( const Severity: TLogSeverity ): string;
const
  cSeverityDebug   = '[  DEBUG  ]';
  cSeverityVerbose = '[ VERBOSE ]';
  cSeverityInfo    = '[  INFO   ]';
  cSeverityHint    = '[  HINT   ]';
  cSeverityWarning = '[ WARNING ]';
  cSeverityError   = '[  ERROR  ]';
  cSeverityFatal   = '[  FATAL  ]';
  cUnknown         = '[ ??????? ]';
begin
  case Severity of
    lsDebug:    Result := cSeverityDebug;
    lsVerbose:  Result := cSeverityVerbose;
    lsInfo:     Result := cSeverityInfo;
    lsHint:     Result := cSeverityHint;
    lsWarning:  Result := cSeverityWarning;
    lsError:    Result := cSeverityError;
    lsFatal:    Result := cSeverityFatal;
       else     Result := cUnknown;
  end;
end;

function TStandardLog.Insert( const Status: TStatus; const Severity: TLogSeverity; const Parameters: array of const ): TStatus;
var
  S: string;
  idx: nativeuint;
begin
  Result := Status;
  if fLogTargetCount = 0 then exit;
  if ord( fLogLevel ) > ord( Severity ) then exit;
  S := LogSeverityToString( Severity ) + ' ';
  if Length( Parameters ) > 0 then begin
    S := S + string( Status.Return( Parameters ) );
  end else begin
    S := S + string( Status );
  end;
  S := S;
  for idx := 0 to pred( fLogTargetCount ) do begin
    if assigned( fLogTargets[ idx ] ) then fLogTargets[ idx ].LogMessage( S );
  end;
end;

function TStandardLog.Insert( const Status: TStatus; const Severity: TLogSeverity ): TStatus;
begin
  Result := Insert( Status, Severity, [] );
end;

procedure TStandardLog.AddLogTarget( const LogTarget: ILogTarget );
const
  cLogTargetGranularity = 2;
begin
  if fLogTargetCount = Length( fLogTargets ) then begin
    SetLength( fLogTargets, Length( fLogTargets ) + cLogTargetGranularity );
  end;
  fLogTargets[ fLogTargetCount ] := LogTarget;
  inc( fLogTargetCount );
end;

constructor TStandardLog.Create( const LogLevel: TLogSeverity );
begin
  inherited Create;
  SetLength( fLogTargets, 0 );
  fLogLevel := LogLevel;
end;

destructor TStandardLog.Destroy;
begin
  SetLength( fLogTargets, 0 );
  inherited Destroy;
end;

class function TLog.Create( const LogLevel: TLogSeverity ): ILog;
begin
  Result := TStandardLog.Create( LogLevel );
end;

end.
