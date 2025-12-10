-- Seed script to populate demo users
-- Run this from the dataAccess directory: lua seed.lua

local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "SqlDao.UserSqlDao"

local db = sqlite3.open("Databases/database.sql")
db:exec("PRAGMA journal_mode=WAL;")

local userDao = UserSqlDao:new(db)

-- Create demo users
print("Creating demo users...")
userDao:CreateUser("Simona", "password123")
print("Created user: Simona / password123")

userDao:CreateUser("Dan", "password456")
print("Created user: Dan / password456")

userDao:CreateUser("Pepa", "password789")
print("Created user: Pepa / password789")

-- Display all users
print("\nAll users in database:")
local users = userDao:GetUsers()
for _, u in ipairs(users) do
    print("  - " .. u.name .. " (ID: " .. u.id .. ")")
end

db:close()
print("\nDone!")
