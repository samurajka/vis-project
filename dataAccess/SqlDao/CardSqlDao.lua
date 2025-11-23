local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "Interfaces.ICardDao"

local createTableSql = [[
CREATE TABLE IF NOT EXISTS Card (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    printing TEXT NOT NULL,
    set_code TEXT NOT NULL,
    number INTEGER NOT NULL
);
]]


CardSqlDao = class('CardSqlDao', ICardDao)

function CardSqlDao:initialize(db)
    self.db = db
    self.db:exec(createTableSql)
end

function CardSqlDao:CreateCard(name, printing, set, number)
    local sql = self.db:prepare("INSERT INTO Card (name, printing, set, number) VALUES (?, ?, ?, ?)")
    sql:bind_values(name, printing, set, number)
    local result = sql:step()
    sql:finalize()

    return result == sqlite3.DONE
end

function CardSqlDao:GetCardById(id)
    local sql = self.db:prepare("SELECT id, name, printing, set, number FROM Card WHERE id = ?")
    sql:bind_values(id)
    local row = nil
    
    if sql:step() == sqlite3.ROW then
        row = {
            id = sql:get_value(0),
            name = sql:get_value(1),
            printing = sql:get_value(2),
            set = sql:get_value(3),
            number = sql:get_value(4)
        }
    end

    sql:finalize()
    return row
end

function CardSqlDao:GetCards()
    local cards = {}
    for row in self.db:nrows("SELECT id, name, printing, set, number FROM Card") do
        table.insert(cards, row)
    end
    return cards
end