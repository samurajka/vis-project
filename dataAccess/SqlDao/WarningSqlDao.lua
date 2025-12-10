local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "Interfaces.IWarningDao"

local createTableSql = [[
CREATE TABLE IF NOT EXISTS Warning (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    marketListingId INTEGER NOT NULL,
    userId INTEGER NOT NULL,
    reason TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (marketListingId) REFERENCES MarketListing(id),
    FOREIGN KEY (userId) REFERENCES User(id)
);
]]

WarningSqlDao = class('WarningSqlDao', IWarningDao)

function WarningSqlDao:initialize(connection)
    self.db = connection
    self.db:exec(createTableSql)
end

function WarningSqlDao:CreateWarning(marketListingId, userId, reason)
    if not marketListingId or not userId or not reason then
        return nil
    end

    local sql = self.db:prepare(
        "INSERT INTO Warning (marketListingId, userId, reason, status, createdAt, updatedAt) " ..
        "VALUES (?, ?, ?, 'pending', datetime('now'), datetime('now'))"
    )
    sql:bind_values(marketListingId, userId, reason)
    local result = sql:step()
    sql:finalize()

    if result == sqlite3.DONE then
        return self.db:last_insert_rowid()
    end
    return nil
end

function WarningSqlDao:GetWarningById(id)
    local sql = self.db:prepare(
        "SELECT id, marketListingId, userId, reason, status, createdAt, updatedAt " ..
        "FROM Warning WHERE id = ?"
    )
    sql:bind_values(id)
    local row = nil

    if sql:step() == sqlite3.ROW then
        row = {
            id = sql:get_value(0),
            marketListingId = sql:get_value(1),
            userId = sql:get_value(2),
            reason = sql:get_value(3),
            status = sql:get_value(4),
            createdAt = sql:get_value(5),
            updatedAt = sql:get_value(6)
        }
    end

    sql:finalize()
    return row
end

function WarningSqlDao:GetWarningsByListing(marketListingId)
    local warnings = {}
    local sql = self.db:prepare(
        "SELECT id, marketListingId, userId, reason, status, createdAt, updatedAt " ..
        "FROM Warning WHERE marketListingId = ? ORDER BY createdAt DESC"
    )
    sql:bind_values(marketListingId)

    while sql:step() == sqlite3.ROW do
        table.insert(warnings, {
            id = sql:get_value(0),
            marketListingId = sql:get_value(1),
            userId = sql:get_value(2),
            reason = sql:get_value(3),
            status = sql:get_value(4),
            createdAt = sql:get_value(5),
            updatedAt = sql:get_value(6)
        })
    end

    sql:finalize()
    return warnings
end

function WarningSqlDao:GetWarningsByUser(userId)
    local warnings = {}
    local sql = self.db:prepare(
        "SELECT id, marketListingId, userId, reason, status, createdAt, updatedAt " ..
        "FROM Warning WHERE userId = ? ORDER BY createdAt DESC"
    )
    sql:bind_values(userId)

    while sql:step() == sqlite3.ROW do
        table.insert(warnings, {
            id = sql:get_value(0),
            marketListingId = sql:get_value(1),
            userId = sql:get_value(2),
            reason = sql:get_value(3),
            status = sql:get_value(4),
            createdAt = sql:get_value(5),
            updatedAt = sql:get_value(6)
        })
    end

    sql:finalize()
    return warnings
end

function WarningSqlDao:GetAllWarnings()
    local warnings = {}
    local sql = self.db:prepare(
        "SELECT id, marketListingId, userId, reason, status, createdAt, updatedAt " ..
        "FROM Warning ORDER BY createdAt DESC"
    )

    while sql:step() == sqlite3.ROW do
        table.insert(warnings, {
            id = sql:get_value(0),
            marketListingId = sql:get_value(1),
            userId = sql:get_value(2),
            reason = sql:get_value(3),
            status = sql:get_value(4),
            createdAt = sql:get_value(5),
            updatedAt = sql:get_value(6)
        })
    end

    sql:finalize()
    return warnings
end

function WarningSqlDao:UpdateWarningStatus(id, status)
    if not id or not status then
        return nil
    end

    -- Validate status
    if status ~= "pending" and status ~= "reviewed" and status ~= "resolved" then
        return nil
    end

    local sql = self.db:prepare(
        "UPDATE Warning SET status = ?, updatedAt = datetime('now') WHERE id = ?"
    )
    sql:bind_values(status, id)
    local result = sql:step()
    sql:finalize()

    return result == sqlite3.DONE
end

function WarningSqlDao:DeleteWarning(id)
    if not id then
        return nil
    end

    local sql = self.db:prepare("DELETE FROM Warning WHERE id = ?")
    sql:bind_values(id)
    local result = sql:step()
    sql:finalize()

    return result == sqlite3.DONE
end

function WarningSqlDao:GetWarningCountForListing(marketListingId)
    local sql = self.db:prepare(
        "SELECT COUNT(*) FROM Warning WHERE marketListingId = ?"
    )
    sql:bind_values(marketListingId)
    local count = 0

    if sql:step() == sqlite3.ROW then
        count = sql:get_value(0)
    end

    sql:finalize()
    return count
end
