local class = require "middleclass"

-- Interface for Warning data access
IWarningDao = class('IWarningDao')

-- Create a new warning for a listing
-- @param marketListingId: The ID of the marketplace listing
-- @param userId: The ID of the user reporting the warning
-- @param reason: The reason for the warning (string)
-- @return warning id on success, nil on failure
function IWarningDao:CreateWarning(marketListingId, userId, reason)
    error("CreateWarning not implemented")
end

-- Get warning by ID
-- @param id: The warning ID
-- @return warning object or nil
function IWarningDao:GetWarningById(id)
    error("GetWarningById not implemented")
end

-- Get all warnings for a listing
-- @param marketListingId: The ID of the marketplace listing
-- @return array of warnings
function IWarningDao:GetWarningsByListing(marketListingId)
    error("GetWarningsByListing not implemented")
end

-- Get all warnings by a user
-- @param userId: The ID of the user
-- @return array of warnings
function IWarningDao:GetWarningsByUser(userId)
    error("GetWarningsByUser not implemented")
end

-- Get all warnings
-- @return array of all warnings
function IWarningDao:GetAllWarnings()
    error("GetAllWarnings not implemented")
end

-- Update warning status
-- @param id: The warning ID
-- @param status: The new status (pending, reviewed, resolved)
-- @return true on success, nil on failure
function IWarningDao:UpdateWarningStatus(id, status)
    error("UpdateWarningStatus not implemented")
end

-- Delete a warning
-- @param id: The warning ID
-- @return true on success, nil on failure
function IWarningDao:DeleteWarning(id)
    error("DeleteWarning not implemented")
end

-- Get warning count for a listing
-- @param marketListingId: The ID of the marketplace listing
-- @return count of warnings
function IWarningDao:GetWarningCountForListing(marketListingId)
    error("GetWarningCountForListing not implemented")
end
