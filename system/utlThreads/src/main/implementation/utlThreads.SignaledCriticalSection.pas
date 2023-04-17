(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlThreads.SignaledCriticalSection;

interface
uses
  utlThreads
  {$ifdef MSWINDOWS}
  , WinAPI.Windows
  {$endif}
;

type
  TSignaledCriticalSection = class( TInterfacedObject, ISignaledCriticalSection )
  private
    fLockedByThreadID: TThreadID;
    {$ifdef MSWINDOWS}
    fTimeoutMS: uint64;
    fMutex: SRWLOCK;
    fCondition: CONDITION_VARIABLE;
    {$else}
    fSleepTimeoutNanoseconds: uint64;
    fMutex: pthread_mutex_t;
    fCondition: pthread_cond_t;
    {$endif}
  strict private //- ISignaledCriticalSection -//
    procedure Acquire;
    procedure Release;
    procedure Sleep;
    procedure Wake;
  public
    constructor Create( const SleepTimeoutMilliseconds: uint64 = 0 ); reintroduce;
    destructor Destroy; override;
  end;

implementation
uses
  utlStatus
;

procedure TSignaledCriticalSection.Acquire;
var
  CurrentThread: TThreadID;
begin
  CurrentThread := GetCurrentThreadID;
  if fLockedByThreadID=CurrentThread then exit;
  {$ifdef MSWINDOWS}
  AcquireSRWLockExclusive(fMutex);
  {$else}
  pthread_mutex_lock(@fMutex);
  {$endif}
  fLockedByThreadID := CurrentThread;
end;

procedure TSignaledCriticalSection.Release;
begin
  fLockedByThreadID := 0;
  {$ifdef MSWINDOWS}
  ReleaseSRWLockExclusive(fMutex);
  {$else}
  pthread_mutex_unlock(@fMutex);
  {$endif}
end;

procedure TSignaledCriticalSection.Sleep;
{$ifndef MSWINDOWS}
var
  retval  : int32;
  ts      : Timespec;
  TotalNS : int64;
{$endif}
begin
  {$ifdef MSWINDOWS}
  if not SleepConditionVariableSRW(fCondition, fMutex, fTimeoutMS, 0) then begin
    if GetLastError <> ERROR_TIMEOUT then raise TStatus( stThreadSleepFailed ).CreateException;
  end;
  {$else}
  if fSleepTimeoutNanoseconds=0 then begin
    if pthread_cond_wait(
      @fCondition,
      @fMutex
    ) <> 0 then begin
      TStatus(stThreadSleepFailed).Raize;
    end;
  end else begin
    //- Get the current time and add the interval which is in nanoseconds.
    clock_gettime( CLOCK_REALTIME, ts );
    TotalNS    := ( ts.tv_sec *  TTimeConstants.NanosecondsPerSecond );
    TotalNS    := ( TotalNS   +  ts.tv_nsec                          );
    TotalNS    := ( TotalNS   +  fSleepTimeoutNanoseconds            );
    ts.tv_sec  := ( TotalNS  div TTimeConstants.NanosecondsPerSecond );
    ts.tv_nsec := ( TotalNS  mod TTimeConstants.NanosecondsPerSecond );
    // Now run the wait until we timeout.
    repeat
      retval := pthread_cond_timedwait(
        @fCondition,
        @fMutex,
        @ts
      );
      {$ifndef fpc}
      if retval=ETIMEDOUT then exit;
      {$else}
      if (retval=ESysETIMEDOUT) or (retval=ETIMEDOUT) then exit;
      {$endif}
    until (RetVal<>0);
    if RetVal=0 then exit;
    TStatus(stThreadSleepFailed).Raize;
  end;
  {$endif}
end;

procedure TSignaledCriticalSection.Wake;
begin
  {$ifdef MSWINDOWS}
  WakeConditionVariable(fCondition);
  {$else}
  pthread_cond_signal(@fCondition);
  {$endif}
end;

constructor TSignaledCriticalSection.Create(const SleepTimeoutMilliseconds: uint64);
begin
  inherited Create;
  fLockedByThreadID := 0;
  {$ifdef MSWINDOWS}
  InitializeSRWLock(fMutex);
  InitializeConditionVariable(fCondition);
  if SleepTimeoutMilliseconds=0 then fTimeoutMS := INFINITE else fTimeoutMS := SleepTimeoutMilliseconds;
  {$else}
  fSleepTimeoutNanoSeconds := SleepTimeoutMilliseconds * TTimeConstants.NanosecondsPerMillisecond;
  if pthread_mutex_init(@fMutex, nil)<>0 then TStatus(stInitMutexFailed).Raize([GetLastError().AsString]);
  if pthread_cond_init(@fCondition,nil)<>0 then TStatus(stInitConditionVariableFailed).Raize([GetLastError().AsString]);
  {$endif}
end;

destructor TSignaledCriticalSection.Destroy;
begin
  {$ifndef MSWINDOWS}
  pthread_mutex_destroy(@fMutex);
  pthread_cond_destroy(@fCondition);
  {$endif}
  inherited Destroy;
end;

end.


