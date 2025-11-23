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


-- strategy pattern (not implemented yet)

local userDao = UserSqlDao:new(db)

local cardDao = CardSqlDao:new(db)

local listedCardDao = ListedCardSqlDao:new(db)

local marketListingDao = MarketListingSqlDao:new(db)

-- assigning the services and returning
dataaccess.Card = cardDao

dataaccess.User = userDao

dataaccess.ListedCard = listedCardDao

dataaccess.MarketListing = marketListingDao

return dataaccess