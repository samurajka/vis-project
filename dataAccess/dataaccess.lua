local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "Interfaces.ICardDao"
require "Interfaces.IListedCardDao"
require "Interfaces.IUserDao"
require "Interfaces.IMarketListingDao"

require "SqlDao.UserSqlDao"
require "SqlDao.CardSqlDao"
require "SqlDao.MarketListingSqlDao"
require "SqlDao.ListedCardSqlDao"

require "TextDao.UserCsvDao"

CONF = require "conf"

local dataaccess = {}


local db

pcall(function ()
    db = sqlite3.open("Databases/database.sql")
end)

pcall(function ()
    db = sqlite3.open("../dataAccess/Databases/database.sql")
end)

assert(db)


db:exec("PRAGMA journal_mode=WAL;")


-- strategy pattern
local userDao
local cardDao
local listedCardDao
local marketListingDao


if CONF.dbsystem == "SQLITE" then
    -- use sqlite dao implementations
    userDao = UserSqlDao:new(db)

    cardDao = CardSqlDao:new(db)

    listedCardDao = ListedCardSqlDao:new(db)

    marketListingDao = MarketListingSqlDao:new(db)
elseif CONF.dbsystem == "CSV" then
    -- use csv dao implementations
    userDao = UserCsvDao:new("Databases/User.csv")
else
    error("Unsupported DB system: " .. tostring(CONF.dbsystem) .. " - check conf.lua")
end



-- assigning the services and returning
dataaccess.Card = cardDao

dataaccess.User = userDao

dataaccess.ListedCard = listedCardDao

dataaccess.MarketListing = marketListingDao

return dataaccess