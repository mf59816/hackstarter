module DuesTransactions where

import Import
import Permissions
import TransactionQueries
import Data.List
import Data.Fixed
import Data.Time.Clock
import Data.Time.Calendar
import qualified Database.Esqueleto      as E
import           Database.Esqueleto      ((^.))

data DuesEntry = DuesEntry {
  date :: UTCTime,
  amount :: Centi,
  balance :: Centi
  }
  deriving Show

getDuesRates :: ClubId -> Handler [Centi] 
getDuesRates cid = do
  drs <- runDB $ selectList [DuesRateClub ==. cid] []
  return $ (\dre -> duesRateAmount $ entityVal dre) <$> drs

-- if we allowed paying any amount for dues, carrying over a balance and so forth, how would we determine the
-- dues rates without programming them in manually?
-- could assume 'regular' unless there is a dues amount.
-- if there is a dues amount, that's the rate until there is another valid dues amount.
-- ok lets do it that way.

-- assuming transactions are in ascending order by time.
-- assuming all these are FOR dues
calcDues :: [(UTCTime, Centi)] -> [Centi] -> [DuesEntry]
calcDues transactions duesrates = 
  makeDues (filter ((<) 0) (sort duesrates)) Nothing 0 transactions

makeDues :: [Centi] -> (Maybe (UTCTime, Centi)) -> Centi -> [(UTCTime, Centi)] -> [DuesEntry]
-- if no more transactions, we're done making dues entries.
makeDues _ Nothing _ [] = []
makeDues drs (Just (time,amt)) bal [] = 
  if (bal >= amt)
    then let nexttime = addMonths time 1 
             newbal = bal - amt in 
      (DuesEntry nexttime amt newbal) : 
        (makeDues drs (Just (nexttime, amt)) newbal [])
    else []
-- add transactions until the balance is >= one of the dues rates.  that's our initial
-- dues rate, and dues transaction datetime.
makeDues duesrates Nothing argbalance ((time,amt):rest) = 
  let balance = argbalance + amt
      rates = takeWhile ((>=) balance) duesrates in 
  case rates of 
    [] -> makeDues duesrates Nothing (balance + amt) rest
    ratez -> let rate = last ratez 
                 newbal = balance - rate in 
      (DuesEntry time rate newbal) : 
         makeDues duesrates (Just (time, rate)) newbal rest
makeDues duesrates (Just (lasttime, lastrate)) balance ((time,amt):rest) = 
  let nextdate = addMonths lasttime 2 in
  if (time > nextdate) 
    then makeDues duesrates (Just ((addMonths lasttime 1), lastrate)) balance ((time,amt):rest)
    else let
      newbalance = balance + amt
      rate = if (elem amt duesrates) then amt else lastrate
      in
      if newbalance >= rate
        then let ddate = addMonths lasttime 1 
                 nbal = newbalance - rate in 
          (DuesEntry ddate rate nbal) : makeDues duesrates (Just (ddate, rate)) nbal rest 
        else makeDues duesrates (Just (lasttime, rate)) newbalance rest 

addMonths :: UTCTime -> Integer -> UTCTime
addMonths start months =
  start { utctDay = addGregorianMonthsClip months (utctDay start) } 

splitOn :: (a -> Bool) -> [a] -> ([a], [a])
splitOn cond lst = 
  spuliton cond [] lst 

spuliton :: (a -> Bool) -> [a] -> [a] -> ([a],[a])
spuliton _ [] [] = ([], [])
spuliton _ frnt [] = (reverse frnt, [])
spuliton cond frnt (s:ss)  = 
  if (cond s) then
    (reverse frnt, (s:ss))
  else
    spuliton cond (s:frnt) ss



