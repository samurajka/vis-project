local socket = require "socket"
local json = require("dkjson")

require "serverFunctions"

package.path = package.path .. ";../dataAccess/?.lua"

DataService = dofile("../dataAccess/dataaccess.lua")

local server = assert(socket.bind("*", 8080))
print("Server running on http://localhost:8080/")



while true do
    local client = server:accept()
    client:settimeout(10)
    
    local request_line = client:receive("*l")
    if request_line then
        print("Received request:", request_line)


        -- Extract method and path (e.g. "GET /api/item HTTP/1.1")
        local method, path = request_line:match("^(%u+)%s+([^%s]+)")

        -- Read the rest of the request headers
        local requestHeaders = Read_headers(client)
        requestHeaders = requestHeaders or {}

        -- Common headers (including CORS)
        local headers = "Access-Control-Allow-Origin: *\r\n" ..
                        "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n" ..
                        "Access-Control-Allow-Headers: Content-Type\r\n"

        local status, body = "200 OK", ""

        if method == "OPTIONS" then
            status = "204 No Content"
            body = ""
        elseif path == "/api/login" and method == "POST" then
            local content_length = tonumber(requestHeaders["content-length"] or "0")
            local body_raw = ""
            if content_length > 0 then
                body_raw = client:receive(content_length)
            end

            local data, pos, jerr = json.decode(body_raw, 1, nil)
            if not data or not data.name or not data.password then
                Send_response(client, "400 bad request", {error = "missing name or password"})
                client:close()
            else
                local user, err = DataService.User:ValidateLogin(data.name, data.password)
                if not user then
                    Send_response(client, "401 unauthorized", {error = err})
                    client:close()
                else
                    Send_response(client, "200 OK", {id = user.id, name = user.name})
                    client:close()
                end
            end

        elseif path == "/api/item" then
            body = '{"item": "french fries", "price": 3.99}'
            headers = headers .. "Content-Type: application/json\r\n"
        elseif path == "/api/user" then
            body = '{"user": "Claire", "role": "tester"}'
            headers = headers .. "Content-Type: application/json\r\n"

        elseif path:match("^/api/user/%d+$") then
            local id = path:match("(%d+)$")
            local rec = DataService.User:GetUserById(id)

            if not rec then
                Send_response(client, "404 not found", {error = "user not found", uid = id})
                client:close()
            else
                Send_response(client, "200 OK", rec)
            end
            client:close()

        elseif path:match("^/api/listing/%d+$") then
            local id = path:match("(%d+)$")
            local rec = DataService.MarketListing:GetMarketListingById(id)

            if not rec then
                Send_response(client, "404 not found", {error = "listing not found", uid = id})
                client:close()
            else
                Send_response(client, "200 OK", rec)
            end
            client:close()

        elseif path == "/api/listings" and method == "GET" then
            local listings = DataService.MarketListing:GetAllListings()
            Send_response(client, "200 OK", listings)
            client:close()

        elseif path == "/api/warning" and method == "POST" then
            local content_length = tonumber(requestHeaders["content-length"] or "0")
            local body_raw = ""
            if content_length > 0 then
                body_raw = client:receive(content_length)
            end

            local data, pos, jerr = json.decode(body_raw, 1, nil)
            if not data or not data.marketListingId or not data.userId or not data.reason then
                Send_response(client, "400 bad request", {error = "missing marketListingId, userId, or reason"})
                client:close()
            else
                local warningId = DataService.Warning:CreateWarning(
                    tonumber(data.marketListingId),
                    tonumber(data.userId),
                    data.reason
                )
                if not warningId then
                    Send_response(client, "500 server error", {error = "failed to create warning"})
                    client:close()
                else
                    Send_response(client, "201 Created", {id = warningId, success = true})
                    client:close()
                    print("inserted warning id: " .. warningId)
                end
            end

        elseif path:match("^/api/warnings/listing/%d+$") and method == "GET" then
            local listingId = path:match("(%d+)$")
            local warnings = DataService.Warning:GetWarningsByListing(tonumber(listingId))
            Send_response(client, "200 OK", warnings)
            client:close()

        elseif path:match("^/api/warnings/user/%d+$") and method == "GET" then
            local userId = path:match("(%d+)$")
            local warnings = DataService.Warning:GetWarningsByUser(tonumber(userId))
            Send_response(client, "200 OK", warnings)
            client:close()

        elseif path == "/api/warnings" and method == "GET" then
            local warnings = DataService.Warning:GetAllWarnings()
            Send_response(client, "200 OK", warnings)
            client:close()

        elseif path:match("^/api/warning/%d+$") and method == "GET" then
            local warningId = path:match("(%d+)$")
            local warning = DataService.Warning:GetWarningById(tonumber(warningId))
            if not warning then
                Send_response(client, "404 not found", {error = "warning not found"})
                client:close()
            else
                Send_response(client, "200 OK", warning)
                client:close()
            end

        --
        elseif path == "/api/marketlisting" and method == "POST" then
            local content_length = tonumber(requestHeaders["content-length"] or "0")
            local body = ""
            if content_length > 0 then
                body = client:receive(content_length)
            end

            local data, pos, jerr = json.decode(body, 1, nil)
            if not data then
                Send_response(client, "400 bad request", {error = "bad data"})
                client:close()
            else
                -- process the data 
                local price = tonumber(data.totalPrice) or tonumber(data.price)
                local cards = data.cards
                if not price or price < 0 then
                    Send_response(client, "400 bad request", {error = "bad price"})
                    client:close()
                elseif not cards then
                    Send_response(client "400 bada request", {error = "no cards"})
                    client:close()
                else
                    -- TODO: check if cards are ok
                    

                    -- insert into database
                    local mlid, dberror = DataService.MarketListing:CreateListing(price, cards)
                    if not mlid then
                        Send_response(client, "500 server error", {error = "database error", details = dberror})
                        client:close()
                    else 
                        Send_response(client, "201 Listing created")
                        client:close()
                        print("inserted listing id: " .. mlid)
                    end
                end



            end
        else
            status = "404 Not Found"
            body = '{"error": "Not found"}'
            headers = headers .. "Content-Type: application/json\r\n"
        end

        local response = "HTTP/1.1 " .. status .. "\r\n" ..
                         headers ..
                         "Content-Length: " .. #body .. "\r\n" ..
                         "\r\n" ..
                         body

        client:send(response)
    end

    client:close()
end
