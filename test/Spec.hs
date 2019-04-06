import Data.Set (Set)
import Hedgehog (Gen, Property, property, forAll, (===))
import qualified Data.Set as Set
import qualified Hedgehog.Gen as Gen
import qualified Hedgehog.Range as Range
import System.Environment (getEnv)
import System.Process (callCommand, readCreateProcess, CreateProcess(..), shell)
import Test.Tasty (defaultMain, testGroup, withResource)
import Test.Tasty.Hedgehog (testProperty)
import Control.Monad.IO.Class (liftIO)

data Language
  = JavaScript
  | PLpgSQL

toPath :: Language -> String
toPath JavaScript = "js"
toPath PLpgSQL = "plpgsql"

jsEncode :: String -> Set Char -> Int -> Int -> IO String
jsEncode = encode JavaScript

plpgsqlEncode :: String -> Set Char -> Int -> Int -> IO String
plpgsqlEncode = encode PLpgSQL

encode :: Language -> String -> Set Char -> Int -> Int -> IO String
encode lang salt alphabet minLength id_ = do
  path <- getEnv "PATH" -- NOTE: Required to find `psql`
  let cmd = (shell $ "./adapters/" <> toPath lang <> "/encode.sh")
              { env = Just
                  [ ("PATH", path)
                  , ("HASHIDS_SALT", salt)
                  -- HACK: Disable custom alphabets as it breaks PL/pgSQL
                  -- implementation:
                  -- https://github.com/andreystepanov/hashids.sql/issues/2
                  -- , ("HASHIDS_ALPHABET", Set.toList alphabet)
                  , ("HASHIDS_MIN_LENGTH", show minLength)
                  , ("HASHIDS_ID", show id_)
                  ]
              }
  readCreateProcess cmd ""

-- #############################################################################

genSalt :: Gen String
genSalt =
  Gen.list (Range.linear 0 100) Gen.alphaNum

genAlphabet :: Gen (Set Char)
genAlphabet =
  Gen.set (Range.linear 16 100) Gen.alphaNum

genMinLength :: Gen Int
genMinLength =
  Gen.integral (Range.constant 0 10)

genId :: Gen Int
genId =
  Gen.integral (Range.constant 0 1000000000000)

-- #############################################################################

prop_plpsql_matches_javascript :: Property
prop_plpsql_matches_javascript =
  property $ do
    salt <- forAll genSalt
    alphabet <- forAll genAlphabet
    minLength <- forAll genMinLength
    id_ <- forAll genId

    jsResult <- liftIO $ jsEncode salt alphabet minLength id_
    plpgsqlResult <- liftIO $ plpgsqlEncode salt alphabet minLength id_

    jsResult === plpgsqlResult

-- #############################################################################

setupDatabase :: IO ()
setupDatabase =
  callCommand $ "./adapters/" <> toPath PLpgSQL <> "/setup.sh"

teardownDatabase :: () -> IO ()
teardownDatabase _ =
  callCommand $ "./adapters/" <> toPath PLpgSQL <> "/teardown.sh"

-- #############################################################################

main :: IO ()
main = defaultMain $
  withResource setupDatabase teardownDatabase $ \_ ->
    testGroup "hashids.sql vs hashids.js"
      [ testProperty "PL/pSQL matches JavaScript" prop_plpsql_matches_javascript
      ]
