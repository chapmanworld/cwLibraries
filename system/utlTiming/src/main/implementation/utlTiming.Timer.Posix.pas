(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlTiming.Timer.Posix;

interface
{$ifndef MSWINDOWS}
uses
  cwRuntime
;

type
  TStandardTimer = class( TInterfacedObject, ITimer )
  private
    fHighRes: boolean;
    fTicksPerSecond: TTickInteger;
    fPreviousTicks: TTickInteger;
    fClockID: int32;
  private
    procedure internalGetResolution;
    function internalGetTicks: TTickInteger;
  strict private //- ITimer -//
    procedure Clear;
    function getDeltaSeconds: double;
    function getDeltaTicks: TTickInteger;
    function getTicksPerSecond: TTickInteger;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifndef MSWINDOWS}
uses
  DateUtils
//, UnixType
//, Linux
;

constructor TStandardTimer.Create;
begin
  inherited Create;
  internalGetResolution;
  fPreviousTicks := internalGetTicks;
end;

destructor TStandardTimer.Destroy;
begin
  inherited Destroy;
end;

procedure TStandardTimer.internalGetResolution;
//var
//  tp: timespec;
begin
//  fHighRes := True;
//  // Get the resolution of the clock.
//  if ( clock_getRes( CLOCK_MONOTONIC, @tp ) = 0 ) then begin
//    fClockID := CLOCK_MONOTONIC;
//    fTicksPerSecond := ( TTimeConstants.NanosecondsPerSecond div tp.tv_nsec );
//  end else if ( clock_getRES( CLOCK_MONOTONIC_RAW, @tp ) = 0 ) then begin
//    fClockID := CLOCK_MONOTONIC_RAW;
//    fTicksPerSecond := ( TTimeConstants.NanosecondsPerSecond div tp.tv_nsec );
//  end else begin
//    fTicksPerSecond := TTimeConstants.MillisecondsPerSecond;
//    fHighRes := False;
//  end;
end;

procedure TStandardTimer.Clear;
begin
  getDeltaTicks;
end;

function TStandardTimer.getDeltaSeconds: double;
begin
  Result := getDeltaTicks / fTicksPerSecond;
end;

function TStandardTimer.getDeltaTicks: TTickInteger;
var
  fCurrentTicks: TTickInteger;
begin
//  fCurrentTicks := internalGetTicks;
//  // Trap wrap around on timer, just in case.
//  if fCurrentTicks < fPreviousTicks then begin
//    Result := (High( Int64 ) - fPreviousTicks) + fCurrentTicks;
//  end else begin
//    Result := fCurrentTicks - fPreviousTicks;
//  end;
//  fPreviousTicks := fCurrentTicks;
end;

function TStandardTimer.getTicksPerSecond: TTickInteger;
begin
  Result := fTicksPerSecond;
end;

function TStandardTimer.internalGetTicks: TTickInteger;
//var
//  tp: timespec;
begin
//  if fHighRes then begin
//    clock_getTime( fClockID, @tp );
//    Result := ( TTimeConstants.NanosecondsPerSecond * tp.tv_sec ) + tp.tv_nsec;
//  end else begin
//    Result := MillisecondOf( TDateTime.Now );
//  end;
end;

{$endif}
end.


