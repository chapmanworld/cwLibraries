(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlTiming.Timer.Windows;

interface
{$ifdef MSWINDOWS}
uses
  utlTiming
;

type
  TStandardTimer = class( TInterfacedObject, ITimer )
  private
    fPreviousTicks: TTickInteger;
    fTicksPerSecond: TTickInteger;
  strict private //- ITimer -//
    procedure Clear;
    function getDeltaSeconds: double;
    function getDeltaTicks: TTickInteger;
    function getTicksPerSecond: TTickInteger;
  private
    procedure internalGetResolution;
    function internalGetTicks: TTickInteger;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$endif}
implementation
{$ifdef MSWINDOWS}
uses
  WinAPI.Windows
, utlStatus
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
begin
  if not QueryPerformanceFrequency( fTicksPerSecond ) then raise TStatus.CreateException( stNoHighPrecisionTimer );
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
  fCurrentTicks := internalGetTicks;
  // Trap wrap around on timer, just in case.
  if fCurrentTicks < fPreviousTicks then begin
    Result := ( High( Int64 ) - fPreviousTicks ) + fCurrentTicks;
  end else begin
    Result := fCurrentTicks - fPreviousTicks;
  end;
  fPreviousTicks := fCurrentTicks;
end;

function TStandardTimer.getTicksPerSecond: TTickInteger;
begin
  Result := fTicksPerSecond;
end;

function TStandardTimer.internalGetTicks: TTickInteger;
begin
  Result := 0;
  QueryPerformanceCounter( Result );
end;

{$endif}
end.


