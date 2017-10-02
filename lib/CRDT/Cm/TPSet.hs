{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE TypeFamilies #-}

-- | TODO(cblp, 2017-09-29) USet?
module CRDT.Cm.TPSet
    ( TPSet (..)
    , TPSetOp (..)
    , initial
    , lookup
    , updateAtSource
    , updateDownstream
    ) where

import           Prelude hiding (lookup)

import           Algebra.PartialOrd (PartialOrd (..))
import           Data.Observe (Observe (..))
import           Data.Set (Set)
import qualified Data.Set as Set

import           CRDT.Cm (CmRDT (..))

newtype TPSet a = TPSet{payload :: Set a}
    deriving (Show)

data TPSetOp a = Add a | Remove a
    deriving (Eq, Show)

initial :: TPSet a
initial = TPSet Set.empty

-- | query lookup
lookup :: Ord a => a -> TPSet a -> Bool
lookup a TPSet{payload} = Set.member a payload

instance Ord a => CmRDT (TPSet a) (TPSetOp a) (TPSetOp a) where
    updateAtSourcePre op payload = case op of
        Add _     -> True
        Remove a  -> lookup a payload

    updateAtSource = pure

    updateDownstream op TPSet{payload} = case op of
        Add a     -> TPSet{payload = Set.insert a payload}
        Remove a  -> TPSet{payload = Set.delete a payload}

instance Observe (TPSet a) where
    type Observed (TPSet a) = Set a
    observe = payload

instance Eq a => PartialOrd (TPSetOp a) where
    leq (Remove a) (Add b) = a == b -- `Remove e` can occur only after `Add e`
    leq _ _ = False -- Any other are not ordered
