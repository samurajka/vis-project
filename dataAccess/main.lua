local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "SqlDao.UserSqlDao"
require "SqlDao.CardSqlDao"
require "SqlDao.MarketListingSqlDao"

local db = sqlite3.open("Databases/database.sql")

db:exec("PRAGMA journal_mode=WAL;")

local userDao = UserSqlDao:new(db)
local cardDao = CardSqlDao:new(db)


userDao:GetUsers()

-- userDao:CreateUser("Pepa")

local marketListingDao = MarketListingSqlDao:new(db)

marketListingDao:GetMarketListingById()

local row = userDao:GetUserById(1)

print(row.name)

db:close()