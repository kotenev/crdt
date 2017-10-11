{-# OPTIONS_GHC -Wno-missing-signatures #-}

{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}

module GSet where

import           Test.Tasty.QuickCheck (property)

import qualified CRDT.Cm.GSet as Cm
import qualified CRDT.Cv.GSet as Cv

import           Laws (cmrdtLaw, cvrdtLaws)

prop_Cm = cmrdtLaw @(Cm.GSet Int)

test_Cv = cvrdtLaws @(Cv.GSet Int)

prop_add = property $ \(set :: Cv.GSet Int) i -> Cv.lookup i (Cv.add i set)
