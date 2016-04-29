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



instance Print UIdent where
  prt _ (UIdent (_,i)) = doc (showString ( i))
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])

instance Print LIdent where
  prt _ (LIdent (_,i)) = doc (showString ( i))



instance Print AnyIdent where
  prt i e = case e of
    AnyIden lident -> prPrec i 0 (concatD [prt 0 lident])
    AnyTyIden uident -> prPrec i 0 (concatD [prt 0 uident])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print Program where
  prt i e = case e of
    Prog modules -> prPrec i 0 (concatD [prt 0 modules])

instance Print Module where
  prt i e = case e of
    Modul qtype exports imports annotdecls maybeblock -> prPrec i 0 (concatD [doc (showString "module"), prt 0 qtype, doc (showString ";"), prt 0 exports, prt 0 imports, prt 0 annotdecls, prt 0 maybeblock])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print Export where
  prt i e = case e of
    AnyExport anyidents -> prPrec i 0 (concatD [doc (showString "export"), prt 0 anyidents])
    AnyFromExport anyidents qtype -> prPrec i 0 (concatD [doc (showString "export"), prt 0 anyidents, doc (showString "from"), prt 0 qtype])
    StarExport -> prPrec i 0 (concatD [doc (showString "export"), doc (showString "*")])
    StarFromExport qtype -> prPrec i 0 (concatD [doc (showString "export"), doc (showString "*"), doc (showString "from"), prt 0 qtype])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ";"), prt 0 xs])
instance Print Import where
  prt i e = case e of
    AnyImport importtype ttype anyident -> prPrec i 0 (concatD [prt 0 importtype, prt 0 ttype, prt 0 anyident])
    AnyFromImport importtype anyidents qtype -> prPrec i 0 (concatD [prt 0 importtype, prt 0 anyidents, doc (showString "from"), prt 0 qtype])
    StarFromImport importtype qtype -> prPrec i 0 (concatD [prt 0 importtype, doc (showString "*"), doc (showString "from"), prt 0 qtype])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ";"), prt 0 xs])
instance Print ImportType where
  prt i e = case e of
    ForeignImport -> prPrec i 0 (concatD [doc (showString "fimport")])
    NormalImport -> prPrec i 0 (concatD [doc (showString "import")])

instance Print Type where
  prt i e = case e of
    TUnderscore -> prPrec i 0 (concatD [doc (showString "_")])
    TSimple qtype -> prPrec i 0 (concatD [prt 0 qtype])
    TGen qtype types -> prPrec i 0 (concatD [prt 0 qtype, doc (showString "<"), prt 0 types, doc (showString ">")])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print QType where
  prt i e = case e of
    QTyp qtypesegments -> prPrec i 0 (concatD [prt 0 qtypesegments])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print QTypeSegment where
  prt i e = case e of
    QTypeSegmen uident -> prPrec i 0 (concatD [prt 0 uident])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString "."), prt 0 xs])
instance Print TType where
  prt i e = case e of
    TTyp ttypesegments -> prPrec i 0 (concatD [prt 0 ttypesegments])

instance Print TTypeSegment where
  prt i e = case e of
    TTypeSegmen uident -> prPrec i 0 (concatD [prt 0 uident])
  prtList _ [x] = (concatD [prt 0 x, doc (showString ".")])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString "."), prt 0 xs])
instance Print Decl where
  prt i e = case e of
    TypeDecl uident type_ -> prPrec i 0 (concatD [doc (showString "type"), prt 0 uident, doc (showString "="), prt 0 type_, doc (showString ";")])
    TypeParDecl uident uidents type_ -> prPrec i 0 (concatD [doc (showString "type"), prt 0 uident, doc (showString "<"), prt 0 uidents, doc (showString ">"), doc (showString "="), prt 0 type_, doc (showString ";")])
    ExceptionDecl constrident -> prPrec i 0 (concatD [doc (showString "exception"), prt 0 constrident, doc (showString ";")])
    DataDecl uident constridents -> prPrec i 0 (concatD [doc (showString "data"), prt 0 uident, doc (showString "="), prt 0 constridents, doc (showString ";")])
    DataParDecl uident uidents constridents -> prPrec i 0 (concatD [doc (showString "data"), prt 0 uident, doc (showString "<"), prt 0 uidents, doc (showString ">"), doc (showString "="), prt 0 constridents, doc (showString ";")])
    FunDecl type_ lident params funbody -> prPrec i 0 (concatD [doc (showString "def"), prt 0 type_, prt 0 lident, doc (showString "("), prt 0 params, doc (showString ")"), doc (showString "="), prt 0 funbody, doc (showString ";")])
    FunParDecl type_ lident uidents params funbody -> prPrec i 0 (concatD [doc (showString "def"), prt 0 type_, prt 0 lident, doc (showString "<"), prt 0 uidents, doc (showString ">"), doc (showString "("), prt 0 params, doc (showString ")"), doc (showString "="), prt 0 funbody, doc (showString ";")])
    InterfDecl uident annotmethsignats -> prPrec i 0 (concatD [doc (showString "interface"), prt 0 uident, doc (showString "{"), prt 0 annotmethsignats, doc (showString "}")])
    ExtendsDecl uident qtypes annotmethsignats -> prPrec i 0 (concatD [doc (showString "interface"), prt 0 uident, doc (showString "extends"), prt 0 qtypes, doc (showString "{"), prt 0 annotmethsignats, doc (showString "}")])
    ClassDecl uident classbodys1 maybeblock classbodys2 -> prPrec i 0 (concatD [doc (showString "class"), prt 0 uident, doc (showString "{"), prt 0 classbodys1, prt 0 maybeblock, prt 0 classbodys2, doc (showString "}")])
    ClassParamDecl uident params classbodys1 maybeblock classbodys2 -> prPrec i 0 (concatD [doc (showString "class"), prt 0 uident, doc (showString "("), prt 0 params, doc (showString ")"), doc (showString "{"), prt 0 classbodys1, prt 0 maybeblock, prt 0 classbodys2, doc (showString "}")])
    ClassImplements uident qtypes classbodys1 maybeblock classbodys2 -> prPrec i 0 (concatD [doc (showString "class"), prt 0 uident, doc (showString "implements"), prt 0 qtypes, doc (showString "{"), prt 0 classbodys1, prt 0 maybeblock, prt 0 classbodys2, doc (showString "}")])
    ClassParamImplements uident params qtypes classbodys1 maybeblock classbodys2 -> prPrec i 0 (concatD [doc (showString "class"), prt 0 uident, doc (showString "("), prt 0 params, doc (showString ")"), doc (showString "implements"), prt 0 qtypes, doc (showString "{"), prt 0 classbodys1, prt 0 maybeblock, prt 0 classbodys2, doc (showString "}")])

instance Print ConstrIdent where
  prt i e = case e of
    SinglConstrIdent uident -> prPrec i 0 (concatD [prt 0 uident])
    ParamConstrIdent uident constrtypes -> prPrec i 0 (concatD [prt 0 uident, doc (showString "("), prt 0 constrtypes, doc (showString ")")])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString "|"), prt 0 xs])
instance Print ConstrType where
  prt i e = case e of
    EmptyConstrType type_ -> prPrec i 0 (concatD [prt 0 type_])
    RecordConstrType type_ lident -> prPrec i 0 (concatD [prt 0 type_, prt 0 lident])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print FunBody where
  prt i e = case e of
    BuiltinFunBody -> prPrec i 0 (concatD [doc (showString "builtin")])
    NormalFunBody pureexp -> prPrec i 0 (concatD [prt 0 pureexp])

instance Print MethSignat where
  prt i e = case e of
    MethSig type_ lident params -> prPrec i 0 (concatD [prt 0 type_, prt 0 lident, doc (showString "("), prt 0 params, doc (showString ")")])

instance Print ClassBody where
  prt i e = case e of
    FieldClassBody type_ lident -> prPrec i 0 (concatD [prt 0 type_, prt 0 lident, doc (showString ";")])
    FieldAssignClassBody type_ lident pureexp -> prPrec i 0 (concatD [prt 0 type_, prt 0 lident, doc (showString "="), prt 0 pureexp, doc (showString ";")])
    MethClassBody type_ lident params block -> prPrec i 0 (concatD [prt 0 type_, prt 0 lident, doc (showString "("), prt 0 params, doc (showString ")"), prt 0 block])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print Block where
  prt i e = case e of
    Bloc annotstms -> prPrec i 0 (concatD [doc (showString "{"), prt 0 annotstms, doc (showString "}")])

instance Print MaybeBlock where
  prt i e = case e of
    JustBlock annots block -> prPrec i 0 (concatD [prt 0 annots, prt 0 block])
    NoBlock -> prPrec i 0 (concatD [])

instance Print Param where
  prt i e = case e of
    Par type_ lident -> prPrec i 0 (concatD [prt 0 type_, prt 0 lident])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print Stm where
  prt i e = case e of
    SExp exp -> prPrec i 0 (concatD [prt 0 exp, doc (showString ";")])
    SBlock annotstms -> prPrec i 0 (concatD [doc (showString "{"), prt 0 annotstms, doc (showString "}")])
    SWhile pureexp annotstm -> prPrec i 0 (concatD [doc (showString "while"), doc (showString "("), prt 0 pureexp, doc (showString ")"), prt 0 annotstm])
    SReturn exp -> prPrec i 0 (concatD [doc (showString "return"), prt 0 exp, doc (showString ";")])
    SAss lident exp -> prPrec i 0 (concatD [prt 0 lident, doc (showString "="), prt 0 exp, doc (showString ";")])
    SFieldAss lident exp -> prPrec i 0 (concatD [doc (showString "this"), doc (showString "."), prt 0 lident, doc (showString "="), prt 0 exp, doc (showString ";")])
    SDec type_ lident -> prPrec i 0 (concatD [prt 0 type_, prt 0 lident, doc (showString ";")])
    SDecAss type_ lident exp -> prPrec i 0 (concatD [prt 0 type_, prt 0 lident, doc (showString "="), prt 0 exp, doc (showString ";")])
    SIf pureexp annotstm -> prPrec i 0 (concatD [doc (showString "if"), doc (showString "("), prt 0 pureexp, doc (showString ")"), prt 0 annotstm])
    SIfElse pureexp annotstm1 annotstm2 -> prPrec i 0 (concatD [doc (showString "if"), doc (showString "("), prt 0 pureexp, doc (showString ")"), prt 0 annotstm1, doc (showString "else"), prt 0 annotstm2])
    SSuspend -> prPrec i 0 (concatD [doc (showString "suspend"), doc (showString ";")])
    SSkip -> prPrec i 0 (concatD [doc (showString "skip"), doc (showString ";")])
    SAssert pureexp -> prPrec i 0 (concatD [doc (showString "assert"), prt 0 pureexp, doc (showString ";")])
    SAwait awaitguard -> prPrec i 0 (concatD [doc (showString "await"), prt 0 awaitguard, doc (showString ";")])
    SThrow pureexp -> prPrec i 0 (concatD [doc (showString "throw"), prt 0 pureexp, doc (showString ";")])
    SGive pureexp1 pureexp2 -> prPrec i 0 (concatD [prt 0 pureexp1, doc (showString "."), doc (showString "pro_give"), doc (showString "("), prt 0 pureexp2, doc (showString ")"), doc (showString ";")])
    STryCatchFinally annotstm catchbranchs maybefinally -> prPrec i 0 (concatD [doc (showString "try"), prt 0 annotstm, doc (showString "catch"), doc (showString "{"), prt 0 catchbranchs, doc (showString "}"), prt 0 maybefinally])
    SPrint pureexp -> prPrec i 0 (concatD [doc (showString "println"), prt 0 pureexp, doc (showString ";")])

instance Print CatchBranch where
  prt i e = case e of
    CatchBranc pattern annotstm -> prPrec i 0 (concatD [prt 0 pattern, doc (showString "=>"), prt 0 annotstm])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print MaybeFinally where
  prt i e = case e of
    JustFinally annotstm -> prPrec i 0 (concatD [doc (showString "finally"), prt 0 annotstm])
    NoFinally -> prPrec i 0 (concatD [])

instance Print AwaitGuard where
  prt i e = case e of
    FutGuard lident -> prPrec i 0 (concatD [prt 0 lident, doc (showString "?")])
    ProGuard lident -> prPrec i 0 (concatD [prt 0 lident, doc (showString "$")])
    FutFieldGuard lident -> prPrec i 0 (concatD [doc (showString "this"), doc (showString "."), prt 0 lident, doc (showString "?")])
    ProFieldGuard lident -> prPrec i 0 (concatD [doc (showString "this"), doc (showString "."), prt 0 lident, doc (showString "$")])
    ExpGuard pureexp -> prPrec i 0 (concatD [prt 0 pureexp])
    AndGuard awaitguard1 awaitguard2 -> prPrec i 0 (concatD [prt 0 awaitguard1, doc (showString "&"), prt 0 awaitguard2])

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
    EFunCall lident pureexps -> prPrec i 7 (concatD [prt 0 lident, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    EQualFunCall ttype lident pureexps -> prPrec i 7 (concatD [prt 0 ttype, prt 0 lident, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    ENaryFunCall lident pureexps -> prPrec i 7 (concatD [prt 0 lident, doc (showString "["), prt 0 pureexps, doc (showString "]")])
    ENaryQualFunCall ttype lident pureexps -> prPrec i 7 (concatD [prt 0 ttype, prt 0 lident, doc (showString "["), prt 0 pureexps, doc (showString "]")])
    EVar lident -> prPrec i 7 (concatD [prt 0 lident])
    EThis lident -> prPrec i 7 (concatD [doc (showString "this"), doc (showString "."), prt 0 lident])
    EQualVar ttype lident -> prPrec i 7 (concatD [prt 0 ttype, prt 0 lident])
    ESinglConstr qtype -> prPrec i 7 (concatD [prt 0 qtype])
    EParamConstr qtype pureexps -> prPrec i 7 (concatD [prt 0 qtype, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    ELit literal -> prPrec i 7 (concatD [prt 0 literal])
    Let param pureexp1 pureexp2 -> prPrec i 0 (concatD [doc (showString "let"), doc (showString "("), prt 0 param, doc (showString ")"), doc (showString "="), prt 0 pureexp1, doc (showString "in"), prt 0 pureexp2])
    If pureexp1 pureexp2 pureexp3 -> prPrec i 0 (concatD [doc (showString "if"), prt 0 pureexp1, doc (showString "then"), prt 0 pureexp2, doc (showString "else"), prt 0 pureexp3])
    Case pureexp casebranchs -> prPrec i 0 (concatD [doc (showString "case"), prt 0 pureexp, doc (showString "{"), prt 0 casebranchs, doc (showString "}")])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print CaseBranch where
  prt i e = case e of
    CaseBranc pattern pureexp -> prPrec i 0 (concatD [prt 0 pattern, doc (showString "=>"), prt 0 pureexp])
  prtList _ [x] = (concatD [prt 0 x, doc (showString ";")])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ";"), prt 0 xs])
instance Print Pattern where
  prt i e = case e of
    PIdent lident -> prPrec i 0 (concatD [prt 0 lident])
    PLit literal -> prPrec i 0 (concatD [prt 0 literal])
    PSinglConstr uident -> prPrec i 0 (concatD [prt 0 uident])
    PParamConstr uident patterns -> prPrec i 0 (concatD [prt 0 uident, doc (showString "("), prt 0 patterns, doc (showString ")")])
    PUnderscore -> prPrec i 0 (concatD [doc (showString "_")])
  prtList _ [] = (concatD [])
  prtList _ [x] = (concatD [prt 0 x])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ","), prt 0 xs])
instance Print Literal where
  prt i e = case e of
    LNull -> prPrec i 0 (concatD [doc (showString "null")])
    LThis -> prPrec i 0 (concatD [doc (showString "this")])
    LThisDC -> prPrec i 0 (concatD [doc (showString "thisDC")])
    LStr str -> prPrec i 0 (concatD [prt 0 str])
    LInt n -> prPrec i 0 (concatD [prt 0 n])

instance Print EffExp where
  prt i e = case e of
    New qtype pureexps -> prPrec i 0 (concatD [doc (showString "new"), prt 0 qtype, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    NewLocal qtype pureexps -> prPrec i 0 (concatD [doc (showString "new"), doc (showString "local"), prt 0 qtype, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    SyncMethCall pureexp lident pureexps -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "."), prt 0 lident, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    ThisSyncMethCall lident pureexps -> prPrec i 0 (concatD [doc (showString "this"), doc (showString "."), prt 0 lident, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    AsyncMethCall pureexp lident pureexps -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "!"), prt 0 lident, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    AwaitMethCall pureexp lident pureexps -> prPrec i 0 (concatD [doc (showString "await"), prt 0 pureexp, doc (showString "!"), prt 0 lident, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    ThisAsyncMethCall lident pureexps -> prPrec i 0 (concatD [doc (showString "this"), doc (showString "!"), prt 0 lident, doc (showString "("), prt 0 pureexps, doc (showString ")")])
    Get pureexp -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "."), doc (showString "get")])
    ProGet pureexp -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "."), doc (showString "pro_get")])
    ProNew -> prPrec i 0 (concatD [doc (showString "pro_new")])
    ProEmpty pureexp -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "."), doc (showString "pro_isempty")])
    ProTry pureexp -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "."), doc (showString "pro_try")])
    Spawns pureexp type_ pureexps -> prPrec i 0 (concatD [prt 0 pureexp, doc (showString "spawns"), prt 0 type_, doc (showString "("), prt 0 pureexps, doc (showString ")")])

instance Print Annot where
  prt i e = case e of
    Ann annot -> prPrec i 0 (concatD [doc (showString "["), prt 0 annot, doc (showString "]")])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print Annot_ where
  prt i e = case e of
    AnnWithType type_ pureexp -> prPrec i 0 (concatD [prt 0 type_, doc (showString ":"), prt 0 pureexp])
    AnnNoType pureexp -> prPrec i 0 (concatD [prt 0 pureexp])

instance Print AnnotStm where
  prt i e = case e of
    AnnStm annots stm -> prPrec i 0 (concatD [prt 0 annots, prt 0 stm])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print AnnotDecl where
  prt i e = case e of
    AnnDec annots decl -> prPrec i 0 (concatD [prt 0 annots, prt 0 decl])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, prt 0 xs])
instance Print AnnotMethSignat where
  prt i e = case e of
    AnnMethSig annots methsignat -> prPrec i 0 (concatD [prt 0 annots, prt 0 methsignat])
  prtList _ [] = (concatD [])
  prtList _ (x:xs) = (concatD [prt 0 x, doc (showString ";"), prt 0 xs])

