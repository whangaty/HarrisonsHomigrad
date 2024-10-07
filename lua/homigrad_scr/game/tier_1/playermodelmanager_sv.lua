-- Define a table to store player models
local playerModels = {}

-- Function to check if a player has the required role
local function hasRole(ply)
    return ply:IsUserGroup("servermanager") or ply:IsUserGroup("owner")
end

-- Command to set player model
concommand.Add("hg_playermodel", function(ply, cmd, args)
    if not hasRole(ply) then
        ply:ChatPrint("You do not have permission to use this command.")
        return
    end

    local steamID = args[1]
    local modelPath = args[2]

    if not steamID or not modelPath then
        ply:ChatPrint("Usage: hg_playermodel <STEAM_ID> <model_path>")
        return
    end

    -- Assign the model to the SteamID, overwriting if it already exists
    playerModels[steamID] = modelPath
    ply:ChatPrint("Player model for " .. steamID .. " set to " .. modelPath)
end)

-- Command to remove player model
concommand.Add("hg_removemodel", function(ply, cmd, args)
    if not hasRole(ply) then
        ply:ChatPrint("You do not have permission to use this command.")
        return
    end

    local steamID = args[1]

    if not steamID then
        ply:ChatPrint("Usage: hg_removemodel <STEAM_ID>")
        return
    end

    -- Remove the model associated with the SteamID
    if playerModels[steamID] then
        playerModels[steamID] = nil
        ply:ChatPrint("Player model for " .. steamID .. " has been removed.")
    else
        ply:ChatPrint("No player model found for " .. steamID .. ".")
    end
end)

-- Command to list all player models
concommand.Add("hg_listmodels", function(ply, cmd, args)
    if not hasRole(ply) then
        ply:ChatPrint("You do not have permission to use this command.")
        return
    end

    ply:ChatPrint("Current Player Models:")
    for steamID, modelPath in pairs(playerModels) do
        ply:ChatPrint(steamID .. " -> " .. modelPath)
    end
end)
