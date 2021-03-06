{-# LANGUAGE OverloadedStrings #-}

module Mud.TopLvlDefs.FilePaths where

import System.Directory (getHomeDirectory)
import System.FilePath ((<.>), (</>))

type HomeDir     = FilePath
type FilePathFun = HomeDir -> FilePath

mkMudFilePath :: FilePathFun -> IO FilePath
mkMudFilePath = flip fmap getHomeDirectory

under :: FilePathFun -> FilePath -> HomeDir -> FilePath
under f fp hd = f hd </> fp

-- ==================================================
-- Directories:

mudDirFun :: FilePathFun
mudDirFun = (</> "CurryMUD")

dbDirFun, logDirFun, persistDirFun, resDirFun, serverSettingsFun :: FilePathFun
dbDirFun          = under mudDirFun "db"
logDirFun         = under mudDirFun "logs"
persistDirFun     = under mudDirFun "persist"
resDirFun         = under mudDirFun "res"
serverSettingsFun = under mudDirFun $ "settings" <.> "yaml"

bookDirFun, dictDirFun, helpDirFun, miscDirFun, raceDirFun, titleDirFun :: FilePathFun
bookDirFun  = under resDirFun "books"
dictDirFun  = under resDirFun "dict"
helpDirFun  = under resDirFun "help"
miscDirFun  = under resDirFun "misc"
raceDirFun  = bookDirFun
titleDirFun = under resDirFun "titles"

adminHelpDirFun, plaHelpDirFun, rootHeplFileFun :: FilePathFun
adminHelpDirFun = under helpDirFun "admin"
plaHelpDirFun   = under helpDirFun "pla"
rootHeplFileFun = under helpDirFun "root"

plaHelpCmdsDirFun, plaHelpTopicsDirFun :: FilePathFun
plaHelpCmdsDirFun   = under plaHelpDirFun "cmds"
plaHelpTopicsDirFun = under plaHelpDirFun "topics"

adminHelpCmdsDirFun, adminHelpTopicsDirFun :: FilePathFun
adminHelpCmdsDirFun   = under adminHelpDirFun "cmds"
adminHelpTopicsDirFun = under adminHelpDirFun "topics"

-- ==================================================
-- Log files:

bugLogFileFun, errorLogFileFun, loggingExLogFileFun, noticeLogFileFun, typoLogFileFun :: FilePathFun
bugLogFileFun         = under logDirFun $ "bug"                      <.> "log"
errorLogFileFun       = under logDirFun $ "error"                    <.> "log"
loggingExLogFileFun   = under logDirFun $ "logging thread exception" <.> "log"
noticeLogFileFun      = under logDirFun $ "notice"                   <.> "log"
typoLogFileFun        = under logDirFun $ "typo"                     <.> "log"

-- ==================================================
-- Persistence files:

armTblFile, chanTblFile, clothTblFile, coinsTblFile, conTblFile, corpseTblFile, entTblFile, eqTblFile, foodTblFile, holySymbolTblFile, hostTblFile, invTblFile, lightTblFile, mobTblFile, objTblFile, pausedCorpseDecompsTblFile, pausedEffectTblFile, pcSingTblFile, pcTblFile, plaTblFile, rmTblFile, rmTeleNameTblFile, rndmNamesMstrTblFile, teleLinkMstrTblFile, typeTblFile, vesselTblFile, wpnTblFile, writableTblFile :: FilePath
armTblFile                 = "armTbl"                 <.> "json"
chanTblFile                = "chanTbl"                <.> "json"
clothTblFile               = "clothTbl"               <.> "json"
coinsTblFile               = "coinsTbl"               <.> "json"
conTblFile                 = "conTbl"                 <.> "json"
corpseTblFile              = "corpseTbl"              <.> "json"
entTblFile                 = "entTbl"                 <.> "json"
eqTblFile                  = "eqTbl"                  <.> "json"
foodTblFile                = "foodTbl"                <.> "json"
holySymbolTblFile          = "holySymbolTbl"          <.> "json"
hostTblFile                = "hostTbl"                <.> "json"
invTblFile                 = "invTbl"                 <.> "json"
lightTblFile               = "lightTbl"               <.> "json"
mobTblFile                 = "mobTbl"                 <.> "json"
objTblFile                 = "objTbl"                 <.> "json"
pausedCorpseDecompsTblFile = "pausedCorpseDecompsTbl" <.> "json"
pausedEffectTblFile        = "pausedEffectTbl"        <.> "json"
pcSingTblFile              = "pcSingTbl"              <.> "json"
pcTblFile                  = "pcTbl"                  <.> "json"
plaTblFile                 = "plaTbl"                 <.> "json"
rmTblFile                  = "rmTbl"                  <.> "json"
rmTeleNameTblFile          = "rmTeleNameTbl"          <.> "json"
rndmNamesMstrTblFile       = "rndmNamesMstrTbl"       <.> "json"
teleLinkMstrTblFile        = "teleLinkMstrTbl"        <.> "json"
typeTblFile                = "typeTbl"                <.> "json"
vesselTblFile              = "vesselTbl"              <.> "json"
wpnTblFile                 = "wpnTbl"                 <.> "json"
writableTblFile            = "writableTbl"            <.> "json"

-- ==================================================
-- The database file:

dbFileFun :: FilePathFun
dbFileFun = under dbDirFun $ "CurryMUD" <.> "sqlite3"

-- ==================================================
-- Books:

bookListFileFun :: FilePathFun
bookListFileFun = under bookDirFun "booklist"

-- Races:
bookDwarfFileFun, bookElfFileFun, bookFelinoidFileFun, bookHobbitFileFun, bookHumanFileFun, bookLagomorphFileFun, bookNymphFileFun, bookRacesFileFun, bookVulpenoidFileFun :: FilePathFun
bookDwarfFileFun     = under bookDirFun "dwarf"
bookElfFileFun       = under bookDirFun "elf"
bookFelinoidFileFun  = under bookDirFun "felinoid"
bookHobbitFileFun    = under bookDirFun "hobbit"
bookHumanFileFun     = under bookDirFun "human"
bookLagomorphFileFun = under bookDirFun "lagomorph"
bookNymphFileFun     = under bookDirFun "nymph"
bookRacesFileFun     = under bookDirFun "races"
bookVulpenoidFileFun = under bookDirFun "vulpenoid"

-- Other:
bookCreationFileFun, bookHistoryFileFun, bookHolyFileFun, bookLopoLwanmiFileFun, bookMapsFileFun, bookShunfalipmiFileFun :: FilePathFun
bookCreationFileFun    = under bookDirFun "creation"
bookHistoryFileFun     = under bookDirFun "history"
bookHolyFileFun        = under bookDirFun "holy"
bookLopoLwanmiFileFun  = under bookDirFun "lopolwanmi"
bookMapsFileFun        = under bookDirFun "maps"
bookShunfalipmiFileFun = under bookDirFun "shunfalipmi"

-- ==================================================
-- Dictionaries:

profanitiesFileFun, propNamesFileFun, rndmNamesFileFun, wordsFileFun :: FilePathFun
profanitiesFileFun = under dictDirFun "profanities"
propNamesFileFun   = under dictDirFun "propernames"
rndmNamesFileFun   = under dictDirFun "randomnames"
wordsFileFun       = under dictDirFun "words"

-- ==================================================
-- Misc. files:

aboutFileFun, cowbyeFileFun, descRulesFileFun, motdFileFun, uptimeFileFun :: FilePathFun
aboutFileFun     = under miscDirFun "about"
cowbyeFileFun    = under miscDirFun "cowbye"
descRulesFileFun = under miscDirFun "descRules"
motdFileFun      = under miscDirFun "motd"
uptimeFileFun    = under mudDirFun  "uptime"
