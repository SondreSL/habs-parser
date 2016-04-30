-- | A wrapper on the BNFC-generated AST, that re-adds (custom) Eq,Ord instances after being sed-removed by @make generate@.
module ABS.AST 
    ( module BNFC_Gen.AbsABS
    ) where

import BNFC_Gen.AbsABS

instance Eq U where
    U (_,s1) == U (_, s2) = s1 == s2

instance Eq L where
    L (_,s1) == L (_, s2) = s1 == s2

instance Ord U where
   compare (U (_,s1)) (U (_,s2)) = compare s1 s2

instance Ord L where
   compare (L (_,s1)) (L (_,s2)) = compare s1 s2
