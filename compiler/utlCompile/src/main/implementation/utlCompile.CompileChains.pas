(*
  AUTHOR: Craig Chapman for ChapmanWorld LLC.
  PROPERTY OF: ChapmanWorld LLC.
  ALL RIGHTS RESERVED.
*)
unit utlCompile.CompileChains;

interface
uses
  utlLog
, utlCompile
, utlCollections
, utlCompile.CompileChain
;

{$region ' TCompileChainRecord used internally to represent the dictionary of availabe compile chains. '}

type
  TCompileChainRecord = record
    SourceSyntax: string;
    Target: TTarget;
    Platform: TPlatform;
    ConfigFactory: TConfigFactory;
    ParserFactory: TParserFactory;
    TransitionRecords: array of TTransitionRecord;
    CodeGeneratorFactory: TCodeGeneratorFactory;
    PostProcesses: array of TPostProcessFactory;
  end;

{$endregion}

type
  TCompileChains = class( TInterfacedObject, ICompileChains )
  private
    fChains: IList< TCompileChainRecord >;
  private
    function FindChainRecord( const SourceSyntax: string; const Platform: TPlatform; const Target: TTarget; out FoundIdx: nativeuint ): boolean;
  strict private
    function RegisterChain( const SourceSyntax: string;
                            const Platform: TPlatform;
                            const Target: TTarget;
                            const Parser: TParserFactory;
                            const Transitions: array of TTransitionRecord;
                            const CodeGenerator: TCodeGeneratorFactory;
                            const PostProcesses: array of TPostProcessFactory;
                            const ConfigFactory: TConfigFactory
                          ): ICompileChain;
    function CreateChain( const Log: ILog; const SourceSyntax: string; const Platform: TPlatform; const Target: TTarget; const ConfigHandler: TConfigurationHandler ): ICompileChain;
    function InputSyntax: IReadOnlyList< string >;
    function Platforms( const InputSyntax: string ): IReadOnlyList< TPlatform >;
    function Targets( const InputSyntax: string; const Platform: TPlatform ): IReadOnlyList< TTarget >;
    function ModelNames( const InputSyntax: string; const Platform: TPlatform; const Target: TTarget ): IReadOnlyList< string >;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation
uses
  utlStatus
;

constructor TCompileChains.Create;
begin
  inherited Create;
  fChains := TList< TCompileChainRecord >.Create;
end;

function TCompileChains.CreateChain( const Log: ILog; const SourceSyntax: string; const Platform: TPlatform; const Target: TTarget; const ConfigHandler: TConfigurationHandler ): ICompileChain;
var
  FoundIdx: nativeuint;
  Parser: IParser;
  Transitions: IList< ITransition >;
  Transition: ITransition;
  CodeGenerator: ICodeGenerator;
  PostProcesses: IList< IPostProcess >;
  PostProcess: IPostProcess;
  TransitionIdx: nativeuint;
  PostProcessIdx: nativeuint;
  CompileChain: ICompileChain;
  Config: IInterface;
begin
  Result := nil;
  if not FindChainRecord( SourceSyntax, Platform, Target, FoundIdx ) then exit;
  Transitions := TList< ITransition >.Create;
  PostProcesses := TList< IPostProcess >.Create;
  try
    // Instance the configuration model.
    Config := fChains[ FoundIdx ].ConfigFactory( Platform, Target );
    if not assigned( Config ) then exit;
    // If a config handler is assigned...
    if assigned( ConfigHandler ) then ConfigHandler( Config );
    // Instance the parser
    Parser := fChains[ FoundIdx ].ParserFactory( Log, Config );
    CodeGenerator := fChains[ FoundIdx ].CodeGeneratorFactory( Log, Config );
    try
      // Instance transitions
      if Length( fChains[ FoundIdx ].TransitionRecords ) > 0 then begin
        for TransitionIdx := 0 to pred( Length( fChains[ FoundIdx ].TransitionRecords ) ) do begin
          Transition := fChains[ FoundIdx ].TransitionRecords[ TransitionIdx ].Factory( Log, Config );
          if assigned( Transition ) then Transitions.Add( Transition );
        end;
      end;
      // Instance post processes
      if Length( fChains[ FoundIdx ].PostProcesses ) > 0 then begin
        for PostProcessIdx := 0 to pred( Length( fChains[ FoundIdx ].PostProcesses ) ) do begin
          PostProcess := fChains[ FoundIdx ].PostProcesses[ PostProcessIdx ]( Log, Config );
          if assigned( PostProcess ) then PostProcesses.Add( PostProcess );
        end;
      end;
      // Instance a compile chain.
      CompileChain := TCompileChain.Create( Log, Config, Parser, Transitions, CodeGenerator, PostProcesses );
      Result := CompileChain;
    finally
      Parser := nil;
      CodeGenerator := nil;
    end;
  finally
    Transitions := nil;
    PostProcesses := nil;
  end;
end;

destructor TCompileChains.Destroy;
begin
  fChains := nil;
  inherited Destroy;
end;

function TCompileChains.FindChainRecord( const SourceSyntax: string; const Platform: TPlatform; const Target: TTarget; out FoundIdx: nativeuint ): boolean;
var
  idx: nativeuint;
begin
  Result := False;
  if fChains.Count = 0 then exit;
  for idx := 0 to pred( fChains.Count ) do begin
    if ( fChains[ idx ].SourceSyntax = SourceSyntax ) and
       ( fChains[ idx ].Target = Target ) and
       ( fChains[ idx ].Platform = Platform ) then begin
      FoundIdx := idx;
      exit( true );
    end;
  end;
end;

function TCompileChains.InputSyntax: IReadOnlyList< string >;
var
  List: IList< string >;
  Chain: TCompileChainRecord;
begin
  List := TList< string >.Create;
  Result := List.getAsReadOnly;
  for Chain in fChains do begin
    if List.Contains( Chain.SourceSyntax,
      function ( const A: string; const B: string ): TCompareResult
      begin
        if A < B then Result := crAIsLess else
        if B < A then Result := crBIsLess else
        Result := crEqual;
      end
    ) then continue;
    List.Add( Chain.SourceSyntax );
  end;
end;

function TCompileChains.ModelNames( const InputSyntax: string; const Platform: TPlatform; const Target: TTarget ): IReadOnlyList< string >;
var
  List: IList< string >;
  FoundIdx: nativeuint;
  TransitionRecord: TTransitionRecord;
begin
  List := TList< string >.Create;
  Result := List.getAsReadOnly;
  if not FindChainRecord( InputSyntax, Platform, Target, FoundIdx ) then exit;
  for TransitionRecord in fChains[ FoundIdx ].TransitionRecords do begin
    List.Add( TransitionRecord.OutputName );
  end;
end;

function TCompileChains.Platforms( const InputSyntax: string ): IReadOnlyList< TPlatform >;
var
  List: IList< TPlatform >;
  Chain: TCompileChainRecord;
begin
  List := TList< TPlatform >.Create;
  Result := List.getAsReadOnly;
  for Chain in fChains do begin
    if Chain.SourceSyntax <> InputSyntax then continue;
    if List.Contains( Chain.Platform,
      function ( const A: TPlatform; const B: TPlatform ): TCompareResult
      begin
        if A < B then Result := crAIsLess else
        if B < A then Result := crBIsLess else
        Result := crEqual;
      end
    ) then continue;
    List.Add( Chain.Platform );
  end;
end;

function TCompileChains.RegisterChain( const SourceSyntax: string;
                                       const Platform: TPlatform;
                                       const Target: TTarget;
                                       const Parser: TParserFactory;
                                       const Transitions: array of TTransitionRecord;
                                       const CodeGenerator: TCodeGeneratorFactory;
                                       const PostProcesses: array of TPostProcessFactory;
                                       const ConfigFactory: TConfigFactory ): ICompileChain;
var
  CompileChainRecord: TCompileChainRecord;
  TransitionIdx: nativeuint;
  PostProcessIdx: nativeuint;
  FoundIdx: nativeuint;
begin
  if FindChainRecord( SourceSyntax, Platform, Target, FoundIdx ) then
    raise TStatus.CreateException( stChainAlreadyRegistered, [ SourceSyntax, TargetName( Target ), PlatformName( Platform ) ] );
  CompileChainRecord.ConfigFactory := ConfigFactory;
  CompileChainRecord.SourceSyntax := SourceSyntax;
  CompileChainRecord.Target := Target;
  CompileChainRecord.Platform := Platform;
  CompileChainRecord.ParserFactory := Parser;
  setLength( CompileChainRecord.TransitionRecords, Length( Transitions ) );
  if Length( Transitions ) > 0 then begin
    for TransitionIdx := 0 to pred( Length( Transitions ) ) do begin
      CompileChainRecord.TransitionRecords[ TransitionIdx ] := Transitions[ TransitionIdx ];
    end;
  end;
  CompileChainRecord.CodeGeneratorFactory := CodeGenerator;
  setLength( CompileChainRecord.PostProcesses, Length( PostProcesses ) );
  if Length( PostProcesses ) > 0 then begin
    for PostProcessIdx := 0 to pred( Length( PostProcesses ) ) do begin
      CompileChainRecord.PostProcesses[ PostProcessIdx ] := PostProcesses[ PostProcessIdx ];
    end;
  end;
  fChains.Add( CompileChainRecord );
end;

function TCompileChains.Targets( const InputSyntax: string; const Platform: TPlatform ): IReadOnlyList< TTarget >;
var
  List: IList< TTarget >;
  Chain: TCompileChainRecord;
begin
  List := TList< TTarget >.Create;
  Result := List.getAsReadOnly;
  for Chain in fChains do begin
    if Chain.SourceSyntax <> InputSyntax then continue;
    if Chain.Platform <> Platform then continue;
    if List.Contains( Chain.Target,
      function ( const A: TTarget; const B: TTarget ): TCompareResult
      begin
        if A < B then Result := crAIsLess else
        if B < A then Result := crBIsLess else
        Result := crEqual;
      end
    ) then continue;
    List.Add( Chain.Target );
  end;
end;

end.
