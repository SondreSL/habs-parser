{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
module BNFC_Gen.PrintABS where

-- pretty-printer generated by the BNF converter

import BNFC_Gen.AbsABS
import Data.Char


-- the top-level printing method
printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : "," :ts -> showString t . space "," . rend i ts
    t  : ")" :ts -> showString t . showChar ')' . rend i ts
    t  : "]" :ts -> showString t . showChar ']' . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else (' ':s))

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- the printer class does the job
class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j<i then parenth else id


instance Print Integer where
  prt _ x = doc (shows x)


instance Print Double where
  prt _ x = doc (shows x)



instance Print U where
  prt _ (U (_,i)) = doc (showString ( i))
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])

instance Print L where
  prt _ (L (_,i)) = doc (showString ( i))



instance Print Literal where
  prt i e = case e of
    LNull -> prPrec i 0 (concatD [doc (showString "null")])
    LThis -> prPrec i 0 (concatD [doc (showString "this")])
    LStr str -> prPrec i 0 (concatD [prt 0 str])
    LInt n -> prPrec i 0 (concatD [prt 0 n])
    LFloat d -> prPrec i 0 (concatD [prt 0 d])
    LThisDC -> prPrec i 0 (concatD [doc (showString "thisDC")])

instance Print QU where
  prt i e = case e of
    U_ u -> prPrec i 0 (concatD [prt 0 u])
    QU u qu -> prPrec i 0 (concatD [prt 0 u, doc (showString "."), prt 0 qu])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print QL where
  prt i e = case e of
    L_ l -> prPrec i 0 (concatD [prt 0 l])
    QL u ql -> prPrec i 0 (concatD [prt 0 u, doc (showString "."), prt 0 ql])

instance Print QA where
  prt i e = case e of
    LA l -> prPrec i 0 (concatD [prt 0 l])
    UA u -> prPrec i 0 (concatD [prt 0 u])
    QA u qa -> prPrec i 0 (concatD [prt 0 u, doc (showString "."), prt 0 qa])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print T where
  prt i e = case e of
    TSimple qu -> prPrec i 0 (concatD [prt 0 qu])
    TPoly qu ts -> prPrec i 0 (concatD [prt 0 qu, doc (showString "<"), prt 0 ts, doc (showString ">")])
    TInfer -> prPrec i 0 (concatD [doc (showString "_")])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print FormalPar where
  prt i e = case e of
    FormalPar t l -> prPrec i 0 (concatD [prt 0 t, prt 0 l])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print Program where
  prt i e = case e of
    Program modules -> prPrec i 0 (concatD [prt 0 modules])

instance Print Module where
  prt i e = case e of
    Module qu exports imports anndecls maybeblock -> prPrec i 0 (concatD [doc (showString "module"), prt 0 qu, doc (showString ";"), prt 0 exports, prt 0 imports, prt 0 anndecls, prt 0 maybeblock])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print Export where
  prt i e = case e of
    StarExport -> prPrec i 0 (concatD [doc (showString "export"), doc (showString "*")])
    StarFromExport qu -> prPrec i 0 (concatD [doc (showString "export"), doc (showString "*"), doc (showString "from"), prt 0 qu])
    AnyExport qas -> prPrec i 0 (concatD [doc (showString "export"), prt 0 qas])
    AnyFromExport qas qu -> prPrec i 0 (concatD [doc (showString "export"), prt 0 qas, doc (showString "from"), prt 0 qu])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ";"), prt 0 xs])
instance Print Import where
  prt i e = case e of
    StarFromImport isforeign qu -> prPrec i 0 (concatD [prt 0 isforeign, doc (showString "*"), doc (showString "from"), prt 0 qu])
    AnyImport isforeign qas -> prPrec i 0 (concatD [prt 0 isforeign, prt 0 qas])
    AnyFromImport isforeign qas qu -> prPrec i 0 (concatD [prt 0 isforeign, prt 0 qas, doc (showString "from"), prt 0 qu])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ";"), prt 0 xs])
instance Print IsForeign where
  prt i e = case e of
    NoForeign -> prPrec i 0 (concatD [doc (showString "import")])
    YesForeign -> prPrec i 0 (concatD [doc (showString "fimport")])

instance Print Decl where
  prt i e = case e of
    DType u t -> prPrec i 0 (concatD [doc (showString "type"), prt 0 u, doc (showString "="), prt 0 t, doc (showString ";")])
    DTypePoly u us t -> prPrec i 0 (concatD [doc (showString "type"), prt 0 u, doc (showString "<"), prt 0 us, doc (showString ">"), doc (showString "="), prt 0 t, doc (showString ";")])
    DData u constridents -> prPrec i 0 (concatD [doc (showString "data"), prt 0 u, doc (showString "="), prt 0 constridents, doc (showString ";")])
    DDataPoly u us constridents -> prPrec i 0 (concatD [doc (showString "data"), prt 0 u, doc (showString "<"), prt 0 us, doc (showString ">"), doc (showString "="), prt 0 constridents, doc (showString ";")])
    DFun t l formalpars funbody -> prPrec i 0 (concatD [doc (showString "def"), prt 0 t, prt 0 l, doc (showString "("), prt 0 formalpars, doc (showString ")"), doc (showString "="), prt 0 funbody, doc (showString ";")])
    DFunPoly t l us formalpars funbody -> prPrec i 0 (concatD [doc (showString "def"), prt 0 t, prt 0 l, doc (showString "<"), prt 0 us, doc (showString ">"), doc (showString "("), prt 0 formalpars, doc (showString ")"), doc (showString "="), prt 0 funbody, doc (showString ";")])
    DInterf u methsigs -> prPrec i 0 (concatD [doc (showString "interface"), prt 0 u, doc (showString "{"), prt 0 methsigs, doc (showString "}")])
    DExtends u qus methsigs -> prPrec i 0 (concatD [doc (showString "interface"), prt 0 u, doc (showString "extends"), prt 0 qus, doc (showString "{"), prt 0 methsigs, doc (showString "}")])
    DClass u classbodys1 maybeblock classbodys2 -> prPrec i 0 (concatD [doc (showString "class"), prt 0 u, doc (showString "{"), prt 0 classbodys1, prt 0 maybeblock, prt 0 classbodys2, doc (showString "}")])
    DClassPar u formalpars classbodys1 maybeblock classbodys2 -> prPrec i 0 (concatD [doc (showString "class"), prt 0 u, doc (showString "("), prt 0 formalpars, doc (showString ")"), doc (showString "{"), prt 0 classbodys1, prt 0 maybeblock, prt 0 classbodys2, doc (showString "}")])
    DClassImplements u qus classbodys1 maybeblock classbodys2 -> prPrec i 0 (concatD [doc (showString "class"), prt 0 u, doc (showString "implements"), prt 0 qus, doc (showString "{"), prt 0 classbodys1, prt 0 maybeblock, prt 0 classbodys2, doc (showString "}")])
    DClassParImplements u formalpars qus classbodys1 maybeblock classbodys2 -> prPrec i 0 (concatD [doc (showString "class"), prt 0 u, doc (showString "("), prt 0 formalpars, doc (showString ")"), doc (showString "implements"), prt 0 qus, doc (showString "{"), prt 0 classbodys1, prt 0 maybeblock, prt 0 classbodys2, doc (showString "}")])
    DException constrident -> prPrec i 0 (concatD [doc (showString "exception"), prt 0 constrident, doc (showString ";")])

instance Print ConstrIdent where
  prt i e = case e of
    SinglConstrIdent u -> prPrec i 0 (concatD [prt 0 u])
    ParamConstrIdent u constrtypes -> prPrec i 0 (concatD [prt 0 u, doc (showString "("), prt 0 constrtypes, doc (showString ")")])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString "|"), prt 0 xs])
instance Print ConstrType where
  prt i e = case e of
    EmptyConstrType t -> prPrec i 0 (concatD [prt 0 t])
    RecordConstrType t l -> prPrec i 0 (concatD [prt 0 t, prt 0 l])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print FunBody where
  prt i e = case e of
    BuiltinFunBody -> prPrec i 0 (concatD [doc (showString "builtin")])
    NormalFunBody pureexp -> prPrec i 0 (concatD [prt 0 pureexp])

instance Print MethSig where
  prt i e = case e of
    MethSig anns t l formalpars -> prPrec i 0 (concatD [prt 0 anns, prt 0 t, prt 0 l, doc (showString "("), prt 0 formalpars, doc (showString ")")])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ";"), prt 0 xs])
instance Print ClassBody where
  prt i e = case e of
    FieldClassBody t l -> prPrec i 0 (concatD [prt 0 t, prt 0 l, doc (showString ";")])
    FieldAssignClassBody t l pureexp -> prPrec i 0 (concatD [prt 0 t, prt 0 l, doc (showString "="), prt 0 pureexp, doc (showString ";")])
    MethClassBody t l formalpars annstms -> prPrec i 0 (concatD [prt 0 t, prt 0 l, doc (showString "("), prt 0 formalpars, doc (showString ")"), doc (showString "{"), prt 0 annstms, doc (showString "}")])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print Stm where
  prt i e = case e of
    SSkip -> prPrec i 0 (concatD [doc (showString "skip"), doc (showString ";")])
    SSuspend -> prPrec i 0 (concatD [doc (showString "suspend"), doc (showString ";")])
    SReturn exp -> prPrec i 0 (concatD [doc (showString "return"), prt 0 exp, doc (showString ";")])
    SAssert pureexp -> prPrec i 0 (concatD [doc (showString "assert"), prt 0 pureexp, doc (showString ";")])
    SAwait awaitguard -> prPrec i 0 (concatD [doc (showString "await"), prt 0 awaitguard, doc (showString ";")])
    SAss l exp -> prPrec i 0 (concatD [prt 0 l, doc (showString "="), prt 0 exp, doc (showString ";")])
    SFieldAss l exp -> prPrec i 0 (concatD [doc (showString "this"), doc (showString "."), prt 0 l, doc (showString "="), prt 0 exp, doc (showString ";")])
    SDec t l -> prPrec i 0 (concatD [prt 0 t, prt 0 l, doc (showString ";")])
    SDecAss t l exp -> prPrec i 0 (concatD [prt 0 t, prt 0 l, doc (showString "="), prt 0 exp, doc (showString ";")])
    SWhile pureexp annstm -> prPrec i 0 (concatD [doc (showString "while"), doc (showString "("), prt 0 pureexp, doc (showString ")"), prt 0 annstm])
    SIf pureexp stm -> prPrec i 0 (concatD [doc (showString "if"), doc (showString "("), prt 0 pureexp, doc (showString ")"), prt 0 stm])
    SIfElse pureexp stm1 stm2 -> prPrec i 0 (concatD [doc (showString "if"), doc (showString "("), prt 0 pureexp, doc (showString ")"), prt 0 stm1, doc (showString "else"), prt 0 stm2])
    SCase pureexp scasebranchs -> prPrec i 0 (concatD [doc (showString "case"), prt 0 pureexp, doc (showString "{"), prt 0 scasebranchs, doc (showString "}")])
    SBlock annstms -> prPrec i 0 (concatD [doc (showString "{"), prt 0 annstms, doc (showString "}")])
    SExp exp -> prPrec i 0 (concatD [prt 0 exp, doc (showString ";")])
    SPrint pureexp -> prPrec i 0 (concatD [doc (showString "print"), prt 0 pureexp, doc (showString ";")])
    SPrintln pureexp -> prPrec i 0 (concatD [doc (showString "println"), prt 0 pureexp, doc (showString ";")])
    SReadln -> prPrec i 0 (concatD [doc (showString "readln"), doc (showString ";")])
    SThrow pureexp -> prPrec i 0 (concatD [doc (showString "throw"), prt 0 pureexp, doc (showString ";")])
    STryCatchFinally annstm scasebranchs maybefinally -> prPrec i 0 (concatD [doc (showString "try"), prt 0 annstm, doc (showString "catch"), doc (showString "{"), prt 0 scasebranchs, doc (showString "}"), prt 0 maybefinally])
    SGive pureexp1 pureexp2 -> prPrec i 0 (concatD [prt 0 pureexp1, doc (showString "."), doc (showString "pro_give"), doc (showString "("), prt 0 pureexp2, doc (showString ")"), doc (showString ";")])
    SDuration pureexp1 pureexp2 -> prPrec i 0 (concatD [doc (showString "duration"), doc (showString "("), prt 0 pureexp1, doc (showString ","), prt 0 pureexp2, doc (showString ")"), doc (showString ";")])

instance Print SCaseBranch where
  prt i e = case e of
    SCaseBranch pattern annstm -> prPrec i 0 (concatD [prt 0 pattern, doc (showString "=>"), prt 0 annstm])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print AwaitGuard where
  prt i e = case e of
    GFut l -> prPrec i 0 (concatD [prt 0 l, doc (showString "?")])
    GFutField l -> prPrec i 0 (concatD [doc (showString "this"), doc (showString "."), prt 0 l, doc (showString "?")])
    GExp pureexp -> prPrec i 0 (concatD [prt 0 pureexp])
    GAnd awaitguard1 awaitguard2 -> prPrec i 0 (concatD [prt 0 awaitguard1, doc (showString "&"), prt 0 awaitguard2])
    GDuration pureexp1 pureexp2 -> prPrec i 0 (concatD [doc (showString "duration"), doc (showString "("), prt 0 pureexp1, doc (showString ","), prt 0 pureexp2, doc (showString ")")])

instance Print Exp where
  prt i e = case e of
    ExpP pureexp -> prPrec i 0 (concatD [prt 0 pureexp])
    ExpE effexp -> prPrec i 0 (concatD [prt 0 effexp])

instance Print PureExp where
  prt i e = case e of
    EOr pureexp1 pureexp2 -> prPrec i 0 (concatD [prt 0 pureexp1, doc (showString "||"), prt 1 pureexp2])
    EAnd pureexp1 pureexp2 -> prPrec i 1 (concatD [prt 1 pureexp1, doc (showString "&&"), prt 2 pureexp2])
    EEq pureexp1 pureexp2 -> prPrec i 2 (concatD [prt 2 pureexp1, doc (showString "=="), prt 3 pureexp2])
    ENeq pureexp1 pureexp2 -> prPrec i 2 (concatD [prt 2 pureexp1, doc (showString "!="), prt 3 pureexp2])
    ELt pureexp1 pureexp2 -> prPrec i 3 (concatD [prt 3 pureexp1, doc (showString "<"), prt 4 pureexp2])
    ELe pureexp1 pureexp2 -> prPrec i 3 (concatD [prt 3 pureexp1, doc (showString "<="), prt 4 pureexp2])
    EGt pureexp1 pureexp2 -> prPrec i 3 (concatD [prt 3 pureexp1, doc (showString ">"), prt 4 pureexp2])
    EGe pureexp1 pureexp2 -> prPrec i 3 (concatD [prt 3 pureexp1, doc (showString ">="), prt 4 pureexp2])
    EAdd pureexp1 pureexp2 -> prPrec i 4 (concatD [prt 4 pureexp1, doc (showString "+"), prt 5 pureexp2])
    ESub pureexp1 pureexp2 -> prPrec i 4 (concatD [prt 4 pureexp1, doc (showString "-"), prt 5 pureexp2])
    EMul pureexp1 pureexp2 -> prPrec i 5 (concatD [prt 5 pureexp1, doc (showString "*"), prt 6 pureexp2])
    EDiv pureexp1 pureexp2 -> prPrec i 5 (concatD [prt 5 pureexp1, doc (showString "/"), prt 6 pureexp2])
    EMod pureexp1 pureexp2 -> prPrec i 5 (concatD [prt 5 pureexp1, doc (showString "%"), prt 6 pureexp2])
    ELogNeg pureexp -> prPrec i 6 (concatD [doc (showString "~"), prt 6 pureexp])
    EIntNeg pureexp -> prPrec i 6 (concatD [doc (showString "-"), prt 6 pureexp])
    EFunCall ql pureexps -> prPrec i 7 (concatD [prt 0 ql, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    ENaryFunCall ql pureexps -> prPrec i 7 (concatD [prt 0 ql, doc (showString "["), prt 0 pureexps, doc (showString "]")])
    EVar l -> prPrec i 7 (concatD [prt 0 l])
    EThis l -> prPrec i 7 (concatD [doc (showString "this"), doc (showString "."), prt 0 l])
    ESinglConstr qu -> prPrec i 7 (concatD [prt 0 qu])
    EParamConstr qu pureexps -> prPrec i 7 (concatD [prt 0 qu, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    ELit literal -> prPrec i 7 (concatD [prt 0 literal])
    ELet formalpar pureexp1 pureexp2 -> prPrec i 0 (concatD [doc (showString "let"), doc (showString "("), prt 0 formalpar, doc (showString ")"), doc (showString "="), prt 0 pureexp1, doc (showString "in"), prt 0 pureexp2])
    EIf pureexp1 pureexp2 pureexp3 -> prPrec i 0 (concatD [doc (showString "if"), prt 0 pureexp1, doc (showString "then"), prt 0 pureexp2, doc (showString "else"), prt 0 pureexp3])
    ECase pureexp ecasebranchs -> prPrec i 0 (concatD [doc (showString "case"), prt 0 pureexp, doc (showString "{"), prt 0 ecasebranchs, doc (showString "}")])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print ECaseBranch where
  prt i e = case e of
    ECaseBranch pattern pureexp -> prPrec i 0 (concatD [prt 0 pattern, doc (showString "=>"), prt 0 pureexp])
  prtList _ [x] = (concatD [prt 0 x, doc (showString ";")])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ";"), prt 0 xs])
instance Print Pattern where
  prt i e = case e of
    PLit literal -> prPrec i 0 (concatD [prt 0 literal])
    PVar l -> prPrec i 0 (concatD [prt 0 l])
    PSinglConstr qu -> prPrec i 0 (concatD [prt 0 qu])
    PParamConstr qu patterns -> prPrec i 0 (concatD [prt 0 qu, doc (showString "("), prt 0 patterns, doc (showString ")")])
    PWildCard -> prPrec i 0 (concatD [doc (showString "_")])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print EffExp where
  prt i e = case e of
    New qu pureexps -> prPrec i 0 (concatD [doc (showString "new"), prt 0 qu, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    NewLocal qu pureexps -> prPrec i 0 (concatD [doc (showString "new"), doc (showString "local"), prt 0 qu, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    SyncMethCall pureexp l pureexps -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "."), prt 0 l, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    ThisSyncMethCall l pureexps -> prPrec i 0 (concatD [doc (showString "this"), doc (showString "."), prt 0 l, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    AsyncMethCall pureexp l pureexps -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "!"), prt 0 l, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    AwaitMethCall pureexp l pureexps -> prPrec i 0 (concatD [doc (showString "await"), prt 0 pureexp, doc (showString "!"), prt 0 l, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    ThisAsyncMethCall l pureexps -> prPrec i 0 (concatD [doc (showString "this"), doc (showString "!"), prt 0 l, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    Get pureexp -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "."), doc (showString "get")])
    ProNew -> prPrec i 0 (concatD [doc (showString "pro_new")])
    ProTry pureexp -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "."), doc (showString "pro_try")])
    Now -> prPrec i 0 (concatD [doc (showString "now"), doc (showString "("), doc (showString ")")])

instance Print Ann where
  prt i e = case e of
    Ann ann -> prPrec i 0 (concatD [doc (showString "["), prt 0 ann, doc (showString "]")])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print Ann_ where
  prt i e = case e of
    AnnNoType pureexp -> prPrec i 0 (concatD [prt 0 pureexp])
    AnnWithType t pureexp -> prPrec i 0 (concatD [prt 0 t, doc (showString ":"), prt 0 pureexp])

instance Print AnnStm where
  prt i e = case e of
    AnnStm anns stm -> prPrec i 0 (concatD [prt 0 anns, prt 0 stm])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print AnnDecl where
  prt i e = case e of
    AnnDecl anns decl -> prPrec i 0 (concatD [prt 0 anns, prt 0 decl])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print MaybeFinally where
  prt i e = case e of
    JustFinally annstm -> prPrec i 0 (concatD [doc (showString "finally"), prt 0 annstm])
    NoFinally -> prPrec i 0 (concatD [])

instance Print MaybeBlock where
  prt i e = case e of
    JustBlock annstms -> prPrec i 0 (concatD [doc (showString "{"), prt 0 annstms, doc (showString "}")])
    NoBlock -> prPrec i 0 (concatD [])


