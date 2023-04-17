(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlProcess.Process.Windows;

interface
uses
  utlStatus
, utlTypes
, utlProcess
, utlCollections
;

type
  TPlatformProcess = class( TInterfacedObject, IProcess )
  private
    fExecutable: string;
    fParameters: IList< string >;
    fWorkingDir: string;
  private
    function InternalFire(const Wait: boolean): TStatus;
    function GetParamString: string;
  strict private //- IProcess -//
    function FireAndForget: TStatus;
    function FireAndWait: TStatus;
    function Execute( out Output: TArrayOfString; out ExitCode: uint32 ): TStatus;
    function Parameters: IList< string >;
  public
    constructor Create( const Executable: string; const WorkingDir: string );
  end;

implementation
uses
  utlIO
, utlUnicode
, Windows
;

constructor TPlatformProcess.Create( const Executable: string; const WorkingDir: string );
var
  idx: nativeuint;
begin
  inherited Create;
  fExecutable := Executable;
  fWorkingDir := WorkingDir;
  fParameters := TList< string >.Create;
end;

function TPlatformProcess.GetParamString: string;
var
  Parameter: string;
begin
  Result := '';
  for Parameter in fParameters do begin
    if Result = '' then begin
      Result := Result + Parameter;
    end else begin
      Result := Result + ' ' + Parameter;
    end;
  end;
  fParameters := nil;
end;

function TPlatformProcess.Execute( out Output: TArrayOfString; out ExitCode: uint32 ): TStatus;
const
  cZeroWord: uint16 = 0;
var
  ReadPipeHandle: THandle;
  WritePipeHandle: THandle;
  SecurityAttributes: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  ParamString: string;
  ProcessInformation: TProcessInformation;
  SignalEvent: uint32;
  AvailableBytes: uint32;
  BytesRead: uint32;
  ReadBuffer: IBuffer;
  OutputBuffer: IBuffer;
  utfString: IUnicodeString;
begin
  // Prepare security attributes for creating input/output pipe, allow inherit handle.
  FillChar( SecurityAttributes, sizeof( TSecurityAttributes ), 0 );
  SecurityAttributes.nLength := sizeof( TSecurityAttributes );
  SecurityAttributes.bInheritHandle := True;
  // Create a pipe for marshalling input/output for the process.
  if not CreatePipe( ReadPipeHandle, WritePipeHandle, @SecurityAttributes, 0 ) then exit( TStatus.Return( stCreatePipeFailed, [ GetLastError() ] ) );
  try
    // Prepare startup info record for the process.
    FillChar( StartupInfo, sizeof( TStartupInfo ), #0 );
    StartupInfo.cb          := sizeof( TStartupInfo );
    StartupInfo.dwFlags     := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW; // use handles for pipe, use wShowWindow member of this record
    StartupInfo.wShowWindow := SW_HIDE; // window is hidden
    StartupInfo.hStdInput   := ReadPipeHandle;
    StartupInfo.hStdOutput  := WritePipeHandle;  //- both output and error go to our pipes 'write' channel.
    StartupInfo.hStdError   := WritePipeHandle;
    // Prepare the command line parameters.
    ParamString := GetParamString;
    // Start the process
    if not CreateProcess( nil,
                          PChar( fExecutable + ' ' + ParamString ),
                          @SecurityAttributes,
                          @SecurityAttributes,
                          True,
                          NORMAL_PRIORITY_CLASS,
                          nil,
                          nil,
                          StartupInfo,
                          ProcessInformation ) then exit( TStatus.Return( stFailedToCreateProcess, [ GetLastError() ] ) );
    try
      //- Create buffers for reading, and aggregate output
      ReadBuffer := TBuffer.Create( 2048 );
      OutputBuffer := TBuffer.Create;
      try

        //- Repeatedly check for output from the process
        repeat
          SignalEvent := WaitForSingleObject( ProcessInformation.hProcess, 100 );
          PeekNamedPipe( ReadPipeHandle, nil, 0, nil, @AvailableBytes, nil );
          if ( AvailableBytes > 0 ) then begin
            repeat
              BytesRead := 0;
              ReadFile( ReadPipeHandle, ReadBuffer.DataPtr^, ReadBuffer.Size, BytesRead, nil );
              if BytesRead > 0 then OutputBuffer.AppendData( ReadBuffer.DataPtr, BytesRead );
            until ( BytesRead < ReadBuffer.Size );
          end;
        until ( SignalEvent <> WAIT_TIMEOUT );

        //- Convert the output buffer to an array of strings to return
        OutputBuffer.AppendData( @cZeroWord, sizeof( uint16 ) );
        utfString := TUnicodeString.Create( OutputBuffer.DataPtr, TUnicodeFormat.utfAnsi );
        try
          Output := utfString.AsString.Explode( LF );
        finally
          utfString := nil;
        end;

        //- Get the process out code.
        GetExitCodeProcess( ProcessInformation.hProcess, ExitCode );

        //- The process ran
        Result := stSuccess;

      finally
        ReadBuffer := nil;
        OutputBuffer := nil;
      end;
    finally
      CloseHandle( ProcessInformation.hProcess );
      CloseHandle( ProcessInformation.hThread  );
    end;
  finally
    CloseHandle( ReadPipeHandle );
    CloseHandle( WritePipeHandle );
  end;
end;

function TPlatformProcess.InternalFire( const Wait: boolean ): TStatus;
var
  SecurityAttributes: TSecurityAttributes;
  StartupInfo: TStartupInfo;
  ParamString: string;
  ProcessInformation: TProcessInformation;
  SignalEvent: uint32;
begin
  // Prepare security attributes for creating input/output pipe, allow inherit handle.
  FillChar( SecurityAttributes, sizeof( TSecurityAttributes ), 0 );
  SecurityAttributes.nLength := sizeof( TSecurityAttributes );
  // Prepare startup info record for the process.
  FillChar( StartupInfo, sizeof( TStartupInfo ), 0 );
  StartupInfo.cb          := sizeof( TStartupInfo );
  StartupInfo.wShowWindow := SW_SHOW;
  // Prepare the command line parameters.
  ParamString := GetParamString();
  // Start the process
  if not CreateProcess( nil,
                        PChar( fExecutable + ' ' + ParamString ),
                        @SecurityAttributes,
                        @SecurityAttributes,
                        False,
                        CREATE_NO_WINDOW,
                        nil,
                        nil,
                        StartupInfo,
                        ProcessInformation ) then exit( TStatus.Return( stFailedToCreateProcess, [ GetLastError() ] ) );
  if Wait then begin
    SignalEvent := WaitForSingleObject( ProcessInformation.hProcess, INFINITE );
  end;

  Result := stSuccess;
  CloseHandle( ProcessInformation.hProcess );
  CloseHandle( ProcessInformation.hThread  );
end;

function TPlatformProcess.Parameters: IList< string >;
begin
  Result := fParameters;
end;

function TPlatformProcess.FireAndForget: TStatus;
begin
  InternalFire( False );
end;

function TPlatformProcess.FireAndWait: TStatus;
begin
  InternalFire( True );
end;

end.
