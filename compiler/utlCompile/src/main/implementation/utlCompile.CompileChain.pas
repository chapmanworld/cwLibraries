(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCompile.CompileChain;

interface
uses
  utlStatus
, utlLog
, utlCollections
, utlCompile
, utlModels
;

type
  TCompileChain = class( TInterfacedObject, ICompileChain )
  private
    fLog: ILog;
    fConfigModel: IInterface;
    fParser: IParser;
    fTransitions: IList< ITransition >;
    fCodeGenerator: ICodeGenerator;
    fPostProcesses: IList< IPostProcess >;
    fModel: IModelInstance;
  private //- State -//
    fParsed: boolean;
    fTransitioned: boolean;
    fTransition: uint32;
    fGenerated: boolean;
    fPostProcess: uint32;
    fPostProcessed: boolean;
  private
    procedure Reset;
  strict private //- ICompileChain -//
    function Configuration: IInterface;
    function Model: IModelInstance;
    function Parse: TStatus;
    function Transition: TStatus;
    function Generate: TStatus;
    function PostProcess: TStatus;
  public
    constructor Create( const Log: ILog;
                        const ConfigModel: IInterface;
                        const Parser: IParser;
                        const Transitions: IList< ITransition >;
                        const CodeGenerator: ICodeGenerator;
                        const PostProcesses: IList< IPostProcess >
                      ); reintroduce;
    destructor Destroy; override;
  end;

implementation

function TCompileChain.Configuration: IInterface;
begin
  Result := fConfigModel;
end;

constructor TCompileChain.Create( const Log: ILog; const ConfigModel: IInterface; const Parser: IParser; const Transitions: IList< ITransition >; const CodeGenerator: ICodeGenerator; const PostProcesses: IList< IPostProcess > );
var
  Transition: ITransition;
  PostProcess: IPostProcess;
begin
  inherited Create;
  fLog            := Log;
  fConfigModel    := ConfigModel;
  fParser         := Parser;
  fTransitions    := TList< ITransition >.Create;
  for Transition  in Transitions do fTransitions.Add( Transition );
  fCodeGenerator  := CodeGenerator;
  fPostProcesses  := TList< IPostProcess >.Create;
  for PostProcess in PostProcesses do fPostProcesses.Add( PostProcess );
  Reset;
end;

destructor TCompileChain.Destroy;
begin
  fModel          := nil;
  fPostProcesses  := nil;
  fTransitions    := nil;
  fCodeGenerator  := nil;
  fParser         := nil;
  fConfigModel    := nil;
  fLog            := nil;
  inherited Destroy;
end;

procedure TCompileChain.Reset;
begin
  fModel := nil;
  fParsed := False;
  fTransitioned := False;
  fTransition := 0;
  fGenerated := False;
  fPostProcessed := False;
  fPostProcess := 0;
end;

function TCompileChain.Parse: TStatus;
begin
  Reset;
  Result := fParser.Parse( fModel );
  if not Result then exit;
  fParsed := True;
end;

function TCompileChain.Transition: TStatus;
var
  TargetModel: IModelInstance;
begin
  if not fParsed then exit( stSourceNotParsed );
  if fTransitions.Count = 0 then begin
    fTransitioned := True;
    exit( stDone );
  end;
  if fTransition = fTransitions.Count then begin
    fTransitioned := True;
    exit( stDone );
  end;
  Result := fTransitions[ fTransition ].Transition( fModel, TargetModel );
  if not Result then exit;
  inc( fTransition );
  fModel := TargetModel;
end;

function TCompileChain.Generate: TStatus;
begin
  if not fParsed then exit( stSourceNotParsed );
  if not fTransitioned then exit( stModelNotTransitioned );
  Result := fCodeGenerator.Generate( fModel );
  if not Result then exit;
  fGenerated := True;
  fModel := nil; // we can dispose it now.
end;

function TCompileChain.Model: IModelInstance;
begin
  Result := fModel;
end;

function TCompileChain.PostProcess: TStatus;
begin
  if not fParsed then exit( stSourceNotParsed );
  if not fTransitioned then exit( stModelNotTransitioned );
  if not fGenerated then exit( stNotGenerated );
  if fPostProcesses.Count = 0 then begin
    fPostProcessed := True;
    exit( stDone );
  end;
  if fPostProcess = fPostProcesses.Count then begin
    fPostProcessed := True;
    exit( stDone );
  end;
  Result := fPostProcesses[ fPostProcess ].Run();
  if not Result then exit;
  inc( fPostProcess );
end;

end.
