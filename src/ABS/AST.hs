-- | A wrapper on the BNFC-generated AST, that re-adds (custom) Eq,Ord instances after being sed-removed by @make generate@.
module ABS.AST 
    ( module BNFC_Gen.AbsABS
    ) where

import BNFC_Gen.AbsABS

instance Eq UIdent where
    UIdent (_,s1) == UIdent (_, s2) = s1 == s2

instance Eq LIdent where
    LIdent (_,s1) == LIdent (_, s2) = s1 == s2

instance Ord UIdent where
   compare (UIdent (_,s1)) (UIdent (_,s2)) = compare s1 s2

instance Ord LIdent where
   compare (LIdent (_,s1)) (LIdent (_,s2)) = compare s1 s2
