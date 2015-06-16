{-# LANGUAGE LambdaCase, OverloadedStrings, PatternSynonyms, ViewPatterns #-}

module Mud.Cmds.Util.Misc ( advise
                          , dispCmdList
                          , dispMatches
                          , fileIOExHandler
                          , mkActionParams
                          , mkSingleTarget
                          , pager
                          , prefixCmd
                          , sendGenericErrorMsg
                          , sorryIgnoreLocPref
                          , sorryIgnoreLocPrefPlur
                          , throwToListenThread
                          , withoutArgs ) where

import Mud.Cmds.Util.Abbrev
import Mud.Data.Misc
import Mud.Data.State.ActionParams.ActionParams
import Mud.Data.State.MsgQueue
import Mud.Data.State.MudData
import Mud.Data.State.Util.Get
import Mud.Data.State.Util.Misc
import Mud.Data.State.Util.Output
import Mud.Data.State.Util.Set
import Mud.Interp.Pager
import Mud.Misc.ANSI
import Mud.Misc.LocPref
import Mud.TopLvlDefs.Misc
import Mud.TopLvlDefs.Msgs
import Mud.Util.Operators
import Mud.Util.Padding
import Mud.Util.Quoting
import Mud.Util.Text
import Mud.Util.Wrapping
import qualified Mud.Misc.Logging as L (logIOEx)
import qualified Mud.Util.Misc as U (patternMatchFail)

import Control.Applicative (pure)
import Control.Exception (IOException, SomeException, toException)
import Control.Exception.Lifted (throwTo)
import Control.Monad (unless)
import Data.List (intercalate)
import Data.Maybe (fromJust)
import Data.Monoid ((<>))
import System.IO.Error (isAlreadyInUseError, isDoesNotExistError, isPermissionError)
import qualified Data.Text as T


patternMatchFail :: T.Text -> [T.Text] -> a
patternMatchFail = U.patternMatchFail "Mud.Cmds.Util.Misc"


-----


logIOEx :: T.Text -> IOException -> MudStack ()
logIOEx = L.logIOEx "Mud.Cmds.Util.Misc"


-- ==================================================


advise :: ActionParams -> [HelpName] -> T.Text -> MudStack ()
advise (Advising mq cols) []  msg = wrapSend mq cols msg
advise (Advising mq cols) [h] msg = multiWrapSend mq cols [ msg, T.concat [ "For more information, type "
                                                          , quoteColor
                                                          , dblQuote $ "help " <> h
                                                          , dfltColor
                                                          , "." ] ]
advise (Advising mq cols) (dblQuote . T.intercalate (dblQuote ", ") -> helpTopics) msg =
    multiWrapSend mq cols [ msg, "For more information, see the following help articles: " <> helpTopics <> "." ]
advise p hs msg = patternMatchFail "advise" [ showText p, showText hs, msg ]


-----


dispCmdList :: [Cmd] -> Action
dispCmdList cmds (NoArgs i mq cols) = pager i mq . concatMap (wrapIndent (succ maxCmdLen) cols) . mkCmdListText $ cmds
dispCmdList cmds p                  = dispMatches p (succ maxCmdLen) . mkCmdListText $ cmds


mkCmdListText :: [Cmd] -> [T.Text]
mkCmdListText cmds = let zipped = zip (styleCmdAbbrevs cmds) [ cmdDesc cmd | cmd <- cmds ]
                     in [ pad (succ maxCmdLen) n <> d | (n, d) <- zipped, ()!# d ]


styleCmdAbbrevs :: [Cmd] -> [T.Text]
styleCmdAbbrevs cmds = let cmdNames       = [ cmdName           cmd | cmd <- cmds ]
                           cmdPAs         = [ cmdPriorityAbbrev cmd | cmd <- cmds ]
                           styledCmdNames = styleAbbrevs Don'tBracket cmdNames
                       in [ checkProrityAbbrev a | a <- zip3 cmdNames cmdPAs styledCmdNames ]
  where
    checkProrityAbbrev (_,  Nothing,  scn) = scn
    checkProrityAbbrev (cn, Just cpa, _  ) = T.concat [ abbrevColor, cpa, dfltColor, fromJust . T.stripPrefix cpa $ cn ]


-----


dispMatches :: ActionParams -> Int -> [T.Text] -> MudStack ()
dispMatches (LowerNub i mq cols needles) indent haystack = let (filter (()!#) -> matches) = map grep needles in
    if ()# matches
      then wrapSend mq cols "No matches found."
      else pager i mq . concatMap (wrapIndent indent cols) . intercalate [""] $ matches
  where
    grep needle = let haystack' = [ (hay, hay') | hay <- haystack, let hay' = T.toLower . dropANSI $ hay ]
                  in [ fst match | match <- haystack', needle `T.isInfixOf` snd match ]
dispMatches p indent haystack = patternMatchFail "dispMatches" [ showText p, showText indent, showText haystack ]


-----


fileIOExHandler :: T.Text -> IOException -> MudStack ()
fileIOExHandler fn e = do
    logIOEx fn e
    let rethrow = throwToListenThread . toException $ e
    unless (any (e |$|) [ isAlreadyInUseError, isDoesNotExistError, isPermissionError ]) rethrow


throwToListenThread :: SomeException -> MudStack ()
throwToListenThread e = flip throwTo e . getListenThreadId =<< getState


-----


mkActionParams :: Id -> MudState -> ActionParams
mkActionParams i ms = ActionParams { plaId       = i
                                   , plaMsgQueue = getMsgQueue i ms
                                   , plaCols     = getColumns  i ms
                                   , args        = [] }


-----


mkSingleTarget :: MsgQueue -> Cols -> T.Text -> T.Text -> SingleTarget
mkSingleTarget mq cols target (sorryIgnoreLocPref -> sorryMsg) =
    SingleTarget { strippedTarget     = capitalize   t
                 , strippedTarget'    = uncapitalize t
                 , sendFun            = hlp ? (multiWrapSend mq cols . (sorryMsg :) . pure) :? wrapSend mq cols
                 , consSorry          = hlp ? (sorryMsg :)                                  :? id
                 , consSorryBroadcast = hlp ? f                                             :? const id }
  where
    hlp = hasLocPref . uncapitalize $ target
    t   = hlp ? (T.tail . T.tail $ target) :? target
    f i = ((sorryMsg, pure i) :)


-----


pager :: Id -> MsgQueue -> [T.Text] -> MudStack ()
pager i mq txt@(length -> txtLen) = getState >>= \ms -> let pl = getPageLines i ms in if txtLen + 3 <= pl
  then send mq . nl . T.unlines $ txt
  else let (page, rest) = splitAt (pl - 2) txt in do
      send mq . T.unlines $ page
      sendPagerPrompt mq (pl - 2) txtLen
      setInterp i . Just $ interpPager pl txtLen (page, rest)


-----


prefixCmd :: Char -> CmdName -> T.Text
prefixCmd (T.singleton -> prefix) cn = prefix <> cn


-----


sendGenericErrorMsg :: MsgQueue -> Cols -> MudStack ()
sendGenericErrorMsg mq cols = wrapSend mq cols genericErrorMsg


-----


sorryIgnoreLocPref :: T.Text -> T.Text
sorryIgnoreLocPref msg = parensQuote $ msg <> " need not be given a location prefix. The location prefix you provided \
                                              \will be ignored."


sorryIgnoreLocPrefPlur :: T.Text -> T.Text
sorryIgnoreLocPrefPlur msg = parensQuote $ msg <> " need not be given location prefixes. The location prefixes you \
                                                  \provided will be ignored."


-----


withoutArgs :: Action -> ActionParams -> MudStack ()
withoutArgs act p = ignore p >> act p { args = [] }


ignore :: Action
ignore (Ignoring mq cols as) = send mq . wrapUnlines cols . parensQuote $ "Ignoring " <> as <> "..."
ignore p                     = patternMatchFail "ignore" [ showText p ]
