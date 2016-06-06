

module BNFC_Gen.AbsABS where

-- Haskell module generated by the BNF converter




newtype U = U ((Int,Int),String) deriving (Show, Read)
newtype L = L ((Int,Int),String) deriving (Show, Read)
data Literal
    = LNull
    | LThis
    | LStr String
    | LInt Integer
    | LFloat Double
    | LThisDC
  deriving (Show, Read)

data QU = U_ U | QU U QU
  deriving (Show, Read)

data QL = L_ L | QL U QL
  deriving (Show, Read)

data QA = LA L | UA U | QA U QA
  deriving (Show, Read)

data T = TSimple QU | TPoly QU [T] | TInfer
  deriving (Show, Read)

data FormalPar = FormalPar T L
  deriving (Show, Read)

data Program = Program [Module]
  deriving (Show, Read)

data Module = Module QU [Export] [Import] [AnnDecl] MaybeBlock
  deriving (Show, Read)

data Export
    = StarExport
    | StarFromExport QU
    | AnyExport [QA]
    | AnyFromExport [QA] QU
  deriving (Show, Read)

data Import
    = StarFromImport IsForeign QU
    | AnyImport IsForeign [QA]
    | AnyFromImport IsForeign [QA] QU
  deriving (Show, Read)

data IsForeign = NoForeign | YesForeign
  deriving (Show, Read)

data Decl
    = DType U T
    | DTypePoly U [U] T
    | DData U [ConstrIdent]
    | DDataPoly U [U] [ConstrIdent]
    | DFun T L [FormalPar] FunBody
    | DFunPoly T L [U] [FormalPar] FunBody
    | DInterf U [MethSig]
    | DExtends U [QU] [MethSig]
    | DClass U [ClassBody] MaybeBlock [ClassBody]
    | DClassPar U [FormalPar] [ClassBody] MaybeBlock [ClassBody]
    | DClassImplements U [QU] [ClassBody] MaybeBlock [ClassBody]
    | DClassParImplements U [FormalPar] [QU] [ClassBody] MaybeBlock [ClassBody]
    | DException ConstrIdent
  deriving (Show, Read)

data ConstrIdent
    = SinglConstrIdent U | ParamConstrIdent U [ConstrType]
  deriving (Show, Read)

data ConstrType = EmptyConstrType T | RecordConstrType T L
  deriving (Show, Read)

data FunBody = BuiltinFunBody | NormalFunBody PureExp
  deriving (Show, Read)

data MethSig = MethSig [Ann] T L [FormalPar]
  deriving (Show, Read)

data ClassBody
    = FieldClassBody T L
    | FieldAssignClassBody T L PureExp
    | MethClassBody T L [FormalPar] [AnnStm]
  deriving (Show, Read)

data Stm
    = SSkip
    | SSuspend
    | SReturn Exp
    | SAssert PureExp
    | SAwait AwaitGuard
    | SAss L Exp
    | SFieldAss L Exp
    | SDec T L
    | SDecAss T L Exp
    | SWhile PureExp AnnStm
    | SIf PureExp Stm
    | SIfElse PureExp Stm Stm
    | SCase PureExp [SCaseBranch]
    | SBlock [AnnStm]
    | SExp Exp
    | SPrint PureExp
    | SPrintln PureExp
    | SReadln
    | SThrow PureExp
    | STryCatchFinally AnnStm [SCaseBranch] MaybeFinally
    | SGive PureExp PureExp
    | SDuration PureExp PureExp
  deriving (Show, Read)

data SCaseBranch = SCaseBranch Pattern AnnStm
  deriving (Show, Read)

data AwaitGuard
    = GFut L
    | GFutField L
    | GExp PureExp
    | GAnd AwaitGuard AwaitGuard
    | GDuration PureExp PureExp
  deriving (Show, Read)

data Exp = ExpP PureExp | ExpE EffExp
  deriving (Show, Read)

data PureExp
    = EOr PureExp PureExp
    | EAnd PureExp PureExp
    | EEq PureExp PureExp
    | ENeq PureExp PureExp
    | ELt PureExp PureExp
    | ELe PureExp PureExp
    | EGt PureExp PureExp
    | EGe PureExp PureExp
    | EAdd PureExp PureExp
    | ESub PureExp PureExp
    | EMul PureExp PureExp
    | EDiv PureExp PureExp
    | EMod PureExp PureExp
    | ELogNeg PureExp
    | EIntNeg PureExp
    | EFunCall QL [PureExp]
    | ENaryFunCall QL [PureExp]
    | EVar L
    | EThis L
    | ESinglConstr QU
    | EParamConstr QU [PureExp]
    | ELit Literal
    | ELet FormalPar PureExp PureExp
    | EIf PureExp PureExp PureExp
    | ECase PureExp [ECaseBranch]
  deriving (Show, Read)

data ECaseBranch = ECaseBranch Pattern PureExp
  deriving (Show, Read)

data Pattern
    = PLit Literal
    | PVar L
    | PSinglConstr QU
    | PParamConstr QU [Pattern]
    | PWildCard
  deriving (Show, Read)

data EffExp
    = New QU [PureExp]
    | NewLocal QU [PureExp]
    | SyncMethCall PureExp L [PureExp]
    | ThisSyncMethCall L [PureExp]
    | AsyncMethCall PureExp L [PureExp]
    | AwaitMethCall PureExp L [PureExp]
    | ThisAsyncMethCall L [PureExp]
    | Get PureExp
    | ProNew
    | ProTry PureExp
    | Now
  deriving (Show, Read)

data Ann = Ann Ann_
  deriving (Show, Read)

data Ann_ = AnnNoType PureExp | AnnWithType T PureExp
  deriving (Show, Read)

data AnnStm = AnnStm [Ann] Stm
  deriving (Show, Read)

data AnnDecl = AnnDecl [Ann] Decl
  deriving (Show, Read)

data MaybeFinally = JustFinally AnnStm | NoFinally
  deriving (Show, Read)

data MaybeBlock = JustBlock [AnnStm] | NoBlock
  deriving (Show, Read)

