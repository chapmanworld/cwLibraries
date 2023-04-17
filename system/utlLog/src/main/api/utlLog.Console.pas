(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLog.Console;

interface
uses
  utlLog
;

type
  ///  <summary>
  ///    Factory record which instances a log target which outputs log messages to standard-out.
  ///  </summary>
  TConsoleLogTarget = record
    class function Create: ILogTarget; static;
  end;

implementation
uses
  utlThreads
;

type
  TStandardConsoleLogTarget = class( TInterfacedObject, ILogTarget )
  private
    fCS: ICriticalSection;
  strict private //- ILogTarget -//
    procedure LogMessage( const LogMessage: string );
  public
    constructor Create;
    destructor Destroy; override;
  end;

procedure TStandardConsoleLogTarget.LogMessage( const LogMessage: string );
begin
  fCS.Acquire;
  try
    Writeln( LogMessage );
  finally
    fCS.Release;
  end;
end;

constructor TStandardConsoleLogTarget.Create;
begin
  inherited Create;
  fCS := TCriticalSection.Create;
end;

destructor TStandardConsoleLogTarget.Destroy;
begin
  fCS := nil;
  inherited Destroy;
end;

class function TConsoleLogTarget.Create: ILogTarget;
begin
  Result := TStandardConsoleLogTarget.Create;
end;

end.
