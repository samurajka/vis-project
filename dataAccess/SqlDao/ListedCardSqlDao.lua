local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "Interfaces.IListedCardDao"

local createTableSql = [[
CREATE TABLE IF NOT EXISTS ListedCard (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    cid INTEGER NOT NULL,
    mlid INTEGER NOT NULL,
    foil INTEGER NOT NULL,
    condition INTEGER NOT NULL
);
]]

ListedCardSqlDao = class("ListedCardSqlDao", IListedCardDao)

function ListedCardSqlDao:initialize(connection)
    self.db = connection
    self.db:exec(createTableSql)
end