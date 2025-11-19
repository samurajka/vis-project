local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "SqlDao.UserSqlDao"

local db = sqlite3.open("Databases/database.sql")

db:exec("PRAGMA journal_mode=WAL;")

local userDao = UserSqlDao:new(db)

userDao:GetUsers()

userDao:CreateUser("Pepa")

local row = userDao:GetUserById(1)

print(row.name)

db:close()