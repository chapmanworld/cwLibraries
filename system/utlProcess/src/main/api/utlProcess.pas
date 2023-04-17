(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlProcess;

interface
uses
  utlStatus
, utlTypes
, utlCollections
;

const
  stCreatePipeFailed      : TGUID = '{038CF393-3AEC-43C4-8612-0B4E55FD0B9C}';
  stFailedToCreateProcess : TGUID = '{E9CF41E1-0C80-4C14-B06F-F6A506E64C1F}';

  type
  ///  <summary>
  ///    Executes an external process
  ///  </summary>
  IProcess = interface
    ['{4BADF493-AFE9-4B75-8EA0-9D5EE99F318B}']

    ///  <summary>
    ///    Runs the process and waits for it to complete, without capturing output.
    ///  </summary>
    function FireAndWait: TStatus;

    ///  <summary>
    ///    Launch the process and continue without waiting, do not capture output.
    ///  </summary>
    function FireAndForget: TStatus;

    ///  <summary>
    ///    Executes the process and waits for it to finish. <br/>
    ///    The 'Output' parameter is an array of strings which contains
    ///    the output of the process. <br/>
    ///    Returns the exit status of the process.
    ///  </summary>
    function Execute( out Output: TArrayOfString; out ExitCode: uint32 ): TStatus;

    ///  <summary>
    ///    Returns an instance of the parameters list for this process, prior to
    ///    calling one of the execute methods (Execute,FireAndWait,FireAndForget).
    ///    After an execute method has been called, parameters will return nil,
    ///  </summary>
    function Parameters: IList< string >;
  end;

type
  /// <summary>
  ///  A factory record for instancing IProcess/
  /// </summary>
  TProcess = record
    class function Create( const Executable: string; const WorkingDir: string ): IProcess; static;
  end;

implementation
uses
  {$ifdef MSWINDOWS}
  utlProcess.Process.Windows
  {$endif}
;

class function TProcess.Create( const Executable: string; const WorkingDir: string ): IProcess;
begin
  Result := TPlatformProcess.Create( Executable, WorkingDir );
end;

initialization
  TStatus.Register( stCreatePipeFailed      , 'Failed to create I/O pipe to capture process output with error code: (%%)' );
  TStatus.Register( stFailedToCreateProcess , 'Failed to create process with error code: (%%)' );

end.
