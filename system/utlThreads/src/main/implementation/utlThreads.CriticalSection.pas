(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlThreads.CriticalSection;

interface
uses
  utlThreads
  {$ifdef MSWINDOWS}
  , WinAPI.Windows
  {$endif}
;

type
  TCriticalSection = class( TInterfacedObject, ICriticalSection )
  private
    fLockedByThreadID: TThreadID;
    fMutex: {$ifdef MSWINDOWS} SRWLOCK; {$else} pthread_mutex_t; {$endif}
  strict private //- ICriticalSection -//
    procedure Acquire;
    procedure Release;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

procedure TCriticalSection.Acquire;
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

procedure TCriticalSection.Release;
begin
  fLockedByThreadID := 0;
  {$ifdef MSWINDOWS}
  ReleaseSRWLockExclusive(fMutex);
  {$else}
  pthread_mutex_unlock(@fMutex)
  {$endif}
end;

constructor TCriticalSection.Create;
begin
  inherited Create;
  fLockedByThreadID := 0;
  {$ifdef MSWINDOWS}
  InitializeSRWLock(fMutex);
  {$else}
  if pthread_mutex_init(@fMutex, nil)<>0 then TStatus(stCreateMutexFailed).Raize([GetLastError().AsString]);
  {$endif}
end;

destructor TCriticalSection.Destroy;
begin
  {$ifndef MSWINDOWS}
  pthread_mutex_destroy(@fMutex);
  {$endif}
  inherited Destroy;
end;

end.


