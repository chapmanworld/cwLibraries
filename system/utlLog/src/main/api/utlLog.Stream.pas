(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlLog.Stream;

interface
uses
  utlLog
, utlIO
, utlUnicode
;

type
  ///  <summary>
  ///    Creates a log target which outputs log messages to the
  ///    stream provided in the Create() call.
  ///  </summary>
  TStreamLogTarget = record
    class function Create( const TargetStream: IUnicodeStream; const UnicodeFormat: TUnicodeFormat = utf8 ): ILogTarget; static;
  end;

implementation
uses
  utlThreads
, utlTypes
;

type
  TStandardStreamLogTarget = class( TInterfacedObject, ILogTarget )
  private
    fCS: ICriticalSection;
    fTargetStream: IUnicodeStream;
    fFormat: TUnicodeFormat;
  strict private //- ILogTarget -//
    procedure LogMessage( const LogMessage: string );
  public
    constructor Create( const TargetStream: IUnicodeStream; const Format: TUnicodeFormat );
    destructor Destroy; override;
  end;

procedure TStandardStreamLogTarget.LogMessage( const LogMessage: string );
begin
  fCS.Acquire;
  try
    if not assigned( fTargetStream ) then exit;
    fTargetStream.WriteString( LogMessage + CR + LF, fFormat, FALSE );
  finally
    fCS.Release;
  end;
end;

constructor TStandardStreamLogTarget.Create( const TargetStream: IUnicodeStream; const Format: TUnicodeFormat );
begin
  inherited Create;
  fCS := TCriticalSection.Create;
  fTargetStream := TargetStream;
  fFormat := Format;
  if assigned( fTargetStream ) and ( fFormat <> utfUnknown ) then fTargetStream.WriteBOM( fFormat );
end;

destructor TStandardStreamLogTarget.Destroy;
begin
  fTargetStream := nil;
  fCS := nil;
  inherited Destroy;
end;

class function TStreamLogTarget.Create( const TargetStream: IUnicodeStream; const UnicodeFormat: TUnicodeFormat = utf8 ): ILogTarget;
begin
  Result := TStandardStreamLogTarget.Create( TargetStream, UnicodeFormat );
end;

end.
