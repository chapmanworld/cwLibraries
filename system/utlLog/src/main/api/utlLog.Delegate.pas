(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLog.Delegate;

interface
uses
  utlLog
;

type
  ///  <summary>
  ///    A call-back delegate to handle messages from a log
  ///    instanced using TDelegateLogTarget.
  ///  </summary>
  TLogDelegate = procedure ( const Msg: string ) of object;

type
  ///  <summary>
  ///    Creates a log target which simply forwards log messages
  ///    to a delegate method.
  ///  </summary>
  TDelegateLogTarget = record
    class function Create( const LogDelegate: TLogDelegate ): ILogTarget; static;
  end;

implementation

type
  TStandardDelegateLogTarget = class( TInterfacedObject, ILogTarget )
  private
    fDelegate: TLogDelegate;
  strict private //- ILogTarget -//
    procedure LogMessage( const LogMessage: string );
  public
    constructor Create( const LogDelegate: TLogDelegate );
    destructor Destroy; override;
  end;

procedure TStandardDelegateLogTarget.LogMessage( const LogMessage: string );
begin
  if not assigned( fDelegate ) then exit;
  fDelegate( LogMessage );
end;

constructor TStandardDelegateLogTarget.Create( const LogDelegate: TLogDelegate );
begin
  inherited Create;
  fDelegate := LogDelegate;
end;

destructor TStandardDelegateLogTarget.Destroy;
begin
  fDelegate := nil;
  inherited Destroy;
end;

class function TDelegateLogTarget.Create( const LogDelegate: TLogDelegate ): ILogTarget;
begin
  Result := TStandardDelegateLogTarget.Create( LogDelegate );
end;

end.
