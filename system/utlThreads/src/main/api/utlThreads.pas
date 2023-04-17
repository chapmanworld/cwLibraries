(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlThreads;

interface

{$region ' Status values '}

const
  stThreadSleepFailed : TGUID = '{A897543D-461F-4355-8D99-73861892D994}';

{$endregion}

{$region ' ICriticalSection '}

type
  ///  <summary>
  ///    Represents a mutex lock which may be used to protect a critical
  ///    section of code, which must be executed by only one thread at any
  ///    time.
  ///  </summary>
  ICriticalSection = interface
    ['{21F4E11C-C165-4473-82C0-1674EBD90678}']

    ///  <summary>
    ///    Acquire the mutex lock. A thread should call this to ensure that
    ///    it is executing exclusively.
    ///  </summary>
    procedure Acquire;

    ///  <summary>
    ///    Release the mutex lock. A thread calls this method to release it's
    ///    exclusive execution.
    ///  </summary>
    procedure Release;
  end;

{$endregion}

{$region ' ISignaledCriticalSection '}

type
  ///  <summary>
  ///    Represents a critical section controlled by a condition variable. <br/>
  ///    This works in the same way as an ICriticalSection, except that a
  ///    thread can put it's self to sleep (releasing the mutex), until it
  ///    is woken by an external signal from another thread. Once woken the
  ///    thread re-aquires the mutex lock and continues execution.
  ///  </summary>
  ISignaledCriticalSection = interface
    ['{89D86C88-78BB-4FD5-AE68-BFF81C035BF0}']

    ///  <summary>
    ///    Acquire the mutex lock. A thread should call this to ensure that
    ///    it is executing exclusively.
    ///  </summary>
    procedure Acquire;

    ///  <summary>
    ///    Release the mutex lock. A thread calls this method to release it's
    ///    exclusive execution.
    ///  </summary>
    procedure Release;

    ///  <summary>
    ///    Causes the calling thread to release the mutex lock and begin
    ///    sleeping. While sleeping, the calling thread is excluded from the
    ///    thread scheduler, allowing other threads to consume it's runtime.
    ///    <remarks>
    ///      Sleep may return at any time, regardless of the work having been
    ///      completed. You should check that the work has actually been
    ///      completed, and if not, put the signaled critical seciton back
    ///      to sleep.
    ///    </remarks>
    ///  </summary>
    procedure Sleep;

    ///  <summary>
    ///    Called by some external thread, Wake causes the sleeping thread to
    ///    re-aquire the mutex lock and to continue executing.
    ///  </summary>
    procedure Wake;
  end;

{$endregion}

{$region ' TCriticalSection (factory) '}

type
  TCriticalSection = record
    class function Create: ICriticalSection; static;
  end;

{$endregion}

{$region ' TSignaledCriticalSection (factory) '}

type
  TSignaledCriticalSection = record
    class function Create( const SleepTimeout: uint32 = 0 ): ISignaledCriticalSection; static;
  end;

{$endregion}

implementation
uses
  utlStatus
, utlThreads.CriticalSection
, utlThreads.SignaledCriticalSection
;

{$region ' TCriticalSection (factory) '}

class function TCriticalSection.Create: ICriticalSection;
begin
  Result := utlThreads.CriticalSection.TCriticalSection.Create;
end;

{$endregion}

{$region ' TSignaledCriticalSection (factory) '}

class function TSignaledCriticalSection.Create( const SleepTimeout: uint32 ): ISignaledCriticalSection;
begin
  Result := utlThreads.SignaledCriticalSection.TSignaledCriticalSection.Create( SleepTimeout );
end;

{$endregion}

initialization
  TStatus.Register( stThreadSleepFailed , 'Failed to sleep thread.' );

end.
