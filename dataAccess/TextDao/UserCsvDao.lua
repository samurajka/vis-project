local class = require "middleclass"

-- UserCsvDao provides CRUD operations for User data stored in CSV format
UserCsvDao = class('UserCsvDao')

-- Default CSV file location
local DEFAULT_CSV_PATH = "data/users.csv"

function UserCsvDao:initialize(csvPath)
    self.csvPath = csvPath or DEFAULT_CSV_PATH
    self:ensureDirectoryExists()
    self:ensureFileExists()
end

-- Ensure the data directory exists
function UserCsvDao:ensureDirectoryExists()
    local dir = self.csvPath:match("(.*/)")
    if dir and dir ~= "" then
        os.execute("mkdir -p \"" .. dir .. "\"")
    end
end

-- Ensure the CSV file exists with headers
function UserCsvDao:ensureFileExists()
    local file = io.open(self.csvPath, "r")
    if not file then
        file = io.open(self.csvPath, "w")
        if file then
            file:write("id,name,password\n")
            file:close()
        end
    else
        file:close()
    end
end

-- Helper: Parse CSV line into table
function UserCsvDao:parseCsvLine(line)
    local fields = {}
    local current = ""
    local inQuotes = false
    
    for i = 1, #line do
        local char = line:sub(i, i)
        
        if char == '"' then
            inQuotes = not inQuotes
        elseif char == "," and not inQuotes then
            table.insert(fields, current)
            current = ""
        else
            current = current .. char
        end
    end
    
    table.insert(fields, current)
    return fields
end

-- Helper: Escape CSV field (add quotes if needed)
function UserCsvDao:escapeCsvField(field)
    field = tostring(field)
    if field:find(",") or field:find('"') or field:find("\n") then
        return '"' .. field:gsub('"', '""') .. '"'
    end
    return field
end

-- Helper: Read all records from CSV
function UserCsvDao:readAllRecords()
    local records = {}
    local file = io.open(self.csvPath, "r")
    
    if not file then
        return records
    end
    
    local isFirstLine = true
    for line in file:lines() do
        if not isFirstLine then
            local fields = self:parseCsvLine(line)
            if #fields >= 3 then
                table.insert(records, {
                    id = tonumber(fields[1]),
                    name = fields[2],
                    password = fields[3]
                })
            end
        else
            isFirstLine = false
        end
    end
    
    file:close()
    return records
end

-- Helper: Write all records to CSV
function UserCsvDao:writeAllRecords(records)
    local file = io.open(self.csvPath, "w")
    
    if not file then
        return false
    end
    
    -- Write header
    file:write("id,name,password\n")
    
    -- Write records
    for _, record in ipairs(records) do
        local line = self:escapeCsvField(record.id) .. "," ..
                     self:escapeCsvField(record.name) .. "," ..
                     self:escapeCsvField(record.password) .. "\n"
        file:write(line)
    end
    
    file:close()
    return true
end

-- Helper: Get next available ID
function UserCsvDao:getNextId(records)
    local maxId = 0
    for _, record in ipairs(records) do
        if record.id > maxId then
            maxId = record.id
        end
    end
    return maxId + 1
end

-- CREATE: Insert a new user
function UserCsvDao:CreateUser(name, password)
    if not name or not password then
        return nil, "Name and password are required"
    end
    
    local records = self:readAllRecords()
    local newId = self:getNextId(records)
    
    local newUser = {
        id = newId,
        name = name,
        password = password
    }
    
    table.insert(records, newUser)
    
    if self:writeAllRecords(records) then
        return newId
    else
        return nil, "Failed to write to CSV file"
    end
end

-- READ: Get user by ID
function UserCsvDao:GetUserById(id)
    if not id then
        return nil
    end
    
    id = tonumber(id)
    local records = self:readAllRecords()
    
    for _, record in ipairs(records) do
        if record.id == id then
            return {
                id = record.id,
                name = record.name,
                password = record.password
            }
        end
    end
    
    return nil
end

-- READ: Get user by name
function UserCsvDao:GetUserByName(name)
    if not name then
        return nil
    end
    
    local records = self:readAllRecords()
    
    for _, record in ipairs(records) do
        if record.name == name then
            return {
                id = record.id,
                name = record.name,
                password = record.password
            }
        end
    end
    
    return nil
end

-- READ: Get all users (without passwords for security)
function UserCsvDao:GetUsers()
    local records = self:readAllRecords()
    local users = {}
    
    for _, record in ipairs(records) do
        table.insert(users, {
            id = record.id,
            name = record.name
        })
    end
    
    return users
end

-- READ: Get all users with passwords (internal use)
function UserCsvDao:GetAllUserRecords()
    return self:readAllRecords()
end

-- UPDATE: Update a user
function UserCsvDao:UpdateUser(id, name, password)
    if not id then
        return nil, "ID is required"
    end
    
    id = tonumber(id)
    local records = self:readAllRecords()
    local found = false
    
    for i, record in ipairs(records) do
        if record.id == id then
            if name then
                record.name = name
            end
            if password then
                record.password = password
            end
            found = true
            break
        end
    end
    
    if not found then
        return nil, "User not found"
    end
    
    if self:writeAllRecords(records) then
        return id
    else
        return nil, "Failed to write to CSV file"
    end
end

-- DELETE: Delete a user
function UserCsvDao:DeleteUser(id)
    if not id then
        return nil, "ID is required"
    end
    
    id = tonumber(id)
    local records = self:readAllRecords()
    local found = false
    
    for i, record in ipairs(records) do
        if record.id == id then
            table.remove(records, i)
            found = true
            break
        end
    end
    
    if not found then
        return nil, "User not found"
    end
    
    if self:writeAllRecords(records) then
        return true
    else
        return nil, "Failed to write to CSV file"
    end
end

-- VALIDATE: Validate login credentials
function UserCsvDao:ValidateLogin(name, password)
    if not name or not password then
        return nil, "Name and password are required"
    end
    
    local user = self:GetUserByName(name)
    
    if not user then
        return nil, "User not found"
    end
    
    local fullRecord = self:GetUserById(user.id)
    
    if fullRecord ~= nil and fullRecord.password ~= password then
        return nil, "Invalid password"
    end
    
    return {
        id = user.id,
        name = user.name
    }
end

-- UTILITY: Get file path
function UserCsvDao:GetCsvPath()
    return self.csvPath
end

-- UTILITY: Clear all users (for testing)
function UserCsvDao:Clear()
    local file = io.open(self.csvPath, "w")
    if file then
        file:write("id,name,password\n")
        file:close()
        return true
    end
    return false
end

-- UTILITY: Get record count
function UserCsvDao:GetCount()
    return #self:readAllRecords()
end

-- UTILITY: Export users to table (for inspection)
function UserCsvDao:ExportAll()
    return self:readAllRecords()
end
