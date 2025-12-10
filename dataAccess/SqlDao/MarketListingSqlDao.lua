local class = require "middleclass"
local sqlite3 = require "lsqlite3complete"

require "Interfaces.IMarketListingDao"

local createTableSql = [[
CREATE TABLE IF NOT EXISTS MarketListing (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    price DECIMAL NOT NULL
);
]]

MarketListingSqlDao = class("MarketListingSqlDao", IMarketListingDao)

function MarketListingSqlDao:initialize(connection)
    self.db = connection
    self.db:exec(createTableSql)
end

function MarketListingSqlDao:CreateListing(totalPrice, cards)
    self.db:exec("BEGIN;")
    local sql = self.db:prepare("INSERT INTO MarketListing (price) VALUES (?)")
    sql:bind_values(totalPrice)
    local rc = sql:step()
    sql:finalize()
    if rc ~= sqlite3.DONE then
        self.db:exec("ROLLBACK;")
        return nil, "Failed to insert Market Listing"
    end

    local listingId = self.db:last_insert_rowid()

    local cardSql = self.db:prepare("INSERT INTO ListedCard (mlid, cid, condition, foil) VALUES (?, ?, ?, ?)")
    for _, card in ipairs(cards) do
        local cid = tonumber(card.cid)
        local cond = tonumber(card.cond)
        local foil = tonumber(card.foil)
        cardSql:bind_values(listingId, cid, cond, foil)
        local rc2 = cardSql:step()
        if rc2 ~= sqlite3.DONE then
            cardSql:finalize()
            self.db:exec("ROLLBACK;")
            return nil, "Failed to insert Card: " .. cid .. "  card values: mlid, cid, condition, foil" .. listingId .. ", " .. cid .. ", " .. cond .. ", " .. foil
        end
        cardSql:reset()
    end
    cardSql:finalize()

    self.db:exec("COMMIT;")

    return listingId
end


function MarketListingSqlDao:GetMarketListingById(id)
    local result = {}
    
    for row in self.db:nrows("SELECT id, price FROM MarketListing WHERE id = " .. tonumber(id)) do
        result.id = row.id
        result.price = row.price
    end

    if not result.id then return nil end

    result.cards = {}
    
    for row in self.db:nrows("SELECT id, cid, condition, foil FROM ListedCard WHERE mlid = " .. tonumber(id)) do
        table.insert(result.cards, {id = row.id, cid = row.cid, cond = row.condition, foil = row.foil})
    end
    
    return result
end

function MarketListingSqlDao:GetAllListings()
    local listings = {}
    
    for row in self.db:nrows("SELECT id, price FROM MarketListing ORDER BY id DESC") do
        local listing = {
            id = row.id,
            price = row.price,
            cards = {}
        }
        
        for cardRow in self.db:nrows("SELECT id, cid, condition, foil FROM ListedCard WHERE mlid = " .. row.id) do
            table.insert(listing.cards, {
                id = cardRow.id,
                cid = cardRow.cid,
                cond = cardRow.condition,
                foil = cardRow.foil
            })
        end
        
        table.insert(listings, listing)
    end
    
    return listings
end

