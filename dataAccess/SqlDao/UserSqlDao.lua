local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "Interfaces.IUserDao"

local createTableSql = [[
CREATE TABLE IF NOT EXISTS User (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);
]]


UserSqlDao = class('UserSqlDao', IUserDao)

function UserSqlDao:initialize(connection)
    self.db = connection
    self.db:exec(createTableSql)
end


function UserSqlDao:CreateUser(name)
    local sql = self.db:prepare("INSERT INTO User (name) VALUES (?)")
    sql:bind_values(name)
    local result = sql:step()
    sql:finalize()

    return result == sqlite3.DONE
end

function UserSqlDao:GetUserById(id)
    local sql = self.db:prepare("SELECT id, name FROM User WHERE id = ?")
    sql:bind_values(id)
    local row = nil
    
    if sql:step() == sqlite3.ROW then
        row = {
            id = sql:get_value(0),
            name = sql:get_value(1)
        }
    end

    sql:finalize()
    return row
end

