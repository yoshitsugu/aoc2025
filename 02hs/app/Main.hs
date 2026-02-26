module Main where

import Control.Applicative
import Control.Arrow (second)
import Control.Monad.ST (runST)
import Control.Monad.State.Strict
import Data.ByteString qualified as B
import Data.ByteString.Char8 qualified as C
import Data.Char (isSpace)
import Data.Coerce (coerce)
import Data.Vector.Fusion.Bundle qualified as FU
import Data.Vector.Unboxed qualified as U
import Data.Vector.Unboxed.Mutable qualified as UM
import Data.Word (Word8)
import Debug.Trace (trace)

type Range = (Int, Int)

queryR :: Parser Range
queryR = (,) <$> int <* char <*> int <* char

filterInvalidIds :: Range -> Int
filterInvalidIds (s, e) =
    sum $
        (\r -> trace (show r) r) $
            filter
                ( \x ->
                    let
                        strx = show x
                        halfLength = (length strx `div` 2)
                     in
                        even (length strx)
                            && all (\i -> strx !! i == strx !! (i + halfLength)) [0 .. halfLength - 1]
                )
                [s .. e]

main :: IO ()
main = do
    rs <- U.unfoldr (runParser queryR) <$> B.getContents
    print $ U.sum $ U.map filterInvalidIds rs

type Parser a = StateT C.ByteString Maybe a

runParser :: Parser a -> C.ByteString -> Maybe (a, C.ByteString)
runParser = runStateT
{-# INLINE runParser #-}

int :: Parser Int
int = coerce $ C.readInt . C.dropWhile isSpace
{-# INLINE int #-}

int1 :: Parser Int
int1 = fmap (subtract 1) int
{-# INLINE int1 #-}

char :: Parser Char
char = coerce C.uncons
{-# INLINE char #-}

byte :: Parser Word8
byte = coerce B.uncons
{-# INLINE byte #-}

skipSpaces :: Parser ()
skipSpaces = modify' (C.dropWhile isSpace)
{-# INLINE skipSpaces #-}
