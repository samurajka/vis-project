local json = require "dkjson"

function Read_headers(client)
  local headers = {}
  while true do
    local line, err = client:receive("*l")
    if not line then return headers, err end
    if line == "" then break end
    local k, v = line:match("^([^:]+):%s*(.*)")
    if k and v then
      headers[k:lower()] = v
    end
  end
  return headers
end

function Send_response(client, status_code, body_table, extra_headers)
  extra_headers = extra_headers or {}
  local body = body_table and json.encode(body_table) or ""
  local headers = {
    "HTTP/1.1 " .. tostring(status_code),
    "Content-Type: application/json",
    "Access-Control-Allow-Origin: *",
    "Access-Control-Allow-Methods: GET, POST, OPTIONS",
    "Access-Control-Allow-Headers: Content-Type",
    "Content-Length: " .. tostring(#body)
  }
  for k, v in pairs(extra_headers) do
    table.insert(headers, k .. ": " .. v)
  end
  client:send(table.concat(headers, "\r\n") .. "\r\n\r\n" .. body)
end