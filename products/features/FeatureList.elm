module Products.Features.FeatureList where

import Data.DirectoryTree as DT

-- MODEL

type alias FeatureList =
  { features: DT.DirectoryTree }
