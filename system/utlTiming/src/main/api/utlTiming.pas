(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlTiming;

interface

{$region ' Status values '}

const
  stNoHighPrecisionTimer: TGUID = '{F4AE74E1-3922-4F6A-B034-C71F354EA0F2}';

{$endregion}

{$region ' TTimeConstants '}

type
  ///  <summary>
  ///    Some constants related to timing events.
  ///  </summary>
  TTimeConstants = record
    const NanosecondsPerMicrosecond  = 1000;
    const MicrosecondsPerMillisecond = 1000;
    const MillisecondsPerSecond      = 1000;
    const NanosecondsPerMillisecond  = ( MicroSecondsPerMillisecond * NanosecondsPerMicrosecond );
    const NanosecondsPerSecond       = ( NanosecondsPerMillisecond  * MillisecondsPerSecond );
    const SecondsPerMinute           = 60;
    const MinutesPerHour             = 60;
    const HoursPerDay                = 24;
    const MinutesPerDay              = MinutesPerHour * HoursPerDay;
    const SecondsPerDay              = SecondsPerMinute * MinutesPerDay;
    const MillisecondsPerMinute      = MillisecondsPerSecond * SecondsPerMinute;
    const MillisecondsPerHour        = MillisecondsPerMinute * MinutesPerHour;
    const MillisecondsPerDay         = MillisecondsPerSecond * SecondsPerDay;
  end;

{$endregion}

{$region ' ITimer '}

type
  ///  <summary>
  ///    TTickInteger a large integer for conveying the nanoseconds or
  ///    milliseconds passed in a delta period of a timer.
  ///  </summary>
  TTickInteger = int64;

  ///  <summary>
  ///    ITimer implementations provide a high precision timer which
  ///    begins the first time you call getDeltaTicks from it.
  ///    Each subsequent call will return the delta time that has passed in
  ///    ticks. You can translate the ticks back to actual time using the
  ///    getTicksPerSecond function, which provides an indication of the
  ///    resolution of the timer.
  ///  </summary>
  ITimer = interface
    ['{C3A210E8-EEA8-4880-863D-8D0AB9529CE8}']

    ///  <summary>
    ///    Resets delta to zero for stop-watch style timing.
    ///  </summary>
    procedure Clear;

    ///  <summary>
    ///    Returns the time that has passed between the previous read of
    ///    getDeltaSeconds and this one.
    ///  </summary>
    function getDeltaSeconds: double;

    ///  <summary>
    ///    Number of ticks that have occurred since last calling getDeltaTicks.
    ///  </summary>
    function getDeltaTicks: TTickInteger;

    ///  <summary>
    ///    The number of ticks per second by this timer (gives resolution)
    ///  </summary>
    function getTicksPerSecond: TTickInteger;

    ///  <summary>
    ///    Returns the time that has passed between the previous read of
    ///    DeltaSeconds and this one.
    ///  </summary>
    property DeltaSeconds: double read getDeltaSeconds;

    ///  <summary>
    ///    Number of ticks that have occurred since last reading DeltaTicks;
    ///  </summary>
    property DeltaTicks: TTickInteger read getDeltaTicks;

    ///  <summary>
    ///    The number of ticks per second by this timer (gives resolution)
    ///  </summary>
    property TicksPerSecond: TTickInteger read getTicksPerSecond;
  end;


{$endregion}

{$region ' TTimer (factory) '}

type
  ///  <summary>
  ///    A factory for instancing ITimer.
  ///  </summary>
  TTimer = record
    class function Create: ITimer; static;
  end;

{$endregion}

implementation
uses
  utlStatus
{$ifdef MSWINDOWS}
, utlTiming.Timer.Windows
{$else}
, utlTiming.Timer.Posix
{$endif}
;

{$region ' TTimer (factory) '}

class function TTimer.Create: ITimer;
begin
  Result := TStandardTimer.Create;
end;

{$endregion}

initialization
  TStatus.Register( stNoHighPrecisionTimer , 'Could not find a high precision timer on this system.' );

end.
