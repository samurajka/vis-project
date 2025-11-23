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
