local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "Interfaces.IUserDao"

local createTableSql = [[
CREATE TABLE IF NOT EXISTS User (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    password TEXT NOT NULL
);
]]


UserSqlDao = class('UserSqlDao', IUserDao)

function UserSqlDao:initialize(connection)
    self.db = connection
    self.db:exec(createTableSql)
end


function UserSqlDao:CreateUser(name, password)
    local sql = self.db:prepare("INSERT INTO User (name, password) VALUES (?, ?)")
    sql:bind_values(name, password)
    local result = sql:step()
    sql:finalize()

    return result == sqlite3.DONE
end

function UserSqlDao:GetUserById(id)
    local sql = self.db:prepare("SELECT id, name, password FROM User WHERE id = ?")
    sql:bind_values(id)
    local row = nil
    
    if sql:step() == sqlite3.ROW then
        row = {
            id = sql:get_value(0),
            name = sql:get_value(1),
            password = sql:get_value(2)
        }
    end

    sql:finalize()
    return row --or {error = "no user"}
end

function UserSqlDao:GetUserByName(name)
    local sql = self.db:prepare("SELECT id, name, password FROM User WHERE name = ?")
    sql:bind_values(name)
    local row = nil
    
    if sql:step() == sqlite3.ROW then
        row = {
            id = sql:get_value(0),
            name = sql:get_value(1),
            password = sql:get_value(2)
        }
    end

    sql:finalize()
    return row
end

function UserSqlDao:ValidateLogin(name, password)
    local user = self:GetUserByName(name)
    if not user then
        return nil, "User not found"
    end
    if user.password ~= password then
        return nil, "Invalid password"
    end
    return user
end

function UserSqlDao:GetUsers()
    local users = {}
    for row in self.db:nrows("SELECT id, name FROM User") do
        table.insert(users, {id = row.id, name = row.name})
    end
    return users
end