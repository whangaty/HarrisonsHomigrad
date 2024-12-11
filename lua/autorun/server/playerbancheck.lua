local STEAM_API_KEY = "F5F6CB340D1D3080185A4AAA5AB104A8" -- This is not my SteamID. Don't bother using it for anything bad ~ Harrison

local whitelistFile = "whitelisted_steamids.txt" -- File to store whitelisted SteamIDs
local whitelistedSteamIDs = {} -- Table to store whitelisted SteamIDs

-- Function to load the whitelist from file
local function LoadWhitelist()
    if not file.Exists(whitelistFile, "DATA") then return end

    local data = file.Read(whitelistFile, "DATA")
    for steamID in string.gmatch(data, "[^\r\n]+") do
        whitelistedSteamIDs[steamID] = true
    end

    print("Whitelist loaded with " .. table.Count(whitelistedSteamIDs) .. " entries.")
end

-- Function to save the whitelist to file
local function SaveWhitelist()
    local data = ""
    for steamID, _ in pairs(whitelistedSteamIDs) do
        data = data .. steamID .. "\n"
    end

    file.Write(whitelistFile, data)
    print("Whitelist saved with " .. table.Count(whitelistedSteamIDs) .. " entries.")
end

-- Function to whitelist a SteamID
local function AddToWhitelist(steamID)
    if not whitelistedSteamIDs[steamID] then
        whitelistedSteamIDs[steamID] = true
        SaveWhitelist()
        print("SteamID " .. steamID .. " has been added to the whitelist.")
    else
        print("SteamID " .. steamID .. " is already in the whitelist.")
    end
end

-- Console command to add a SteamID to the whitelist
concommand.Add("forgive", function(ply, cmd, args)
    if IsValid(ply) then
        -- Check player permissions
        local userGroup = ply:GetUserGroup()
        if not (userGroup == "superadmin" or userGroup == "owner" or userGroup == "servermanager") then
            ply:ChatPrint("You do not have permission to use this command.")
            return
        end
    end

    local steamID = args[1]
    if not steamID then
        print("Usage: add_whitelist <SteamID>")
        return
    end

    AddToWhitelist(steamID)
end)

-- Function to check ownership and VAC/Game bans
local function CheckPlayerDetails(ply)
    if not ply:IsPlayer() then return end

    local steamID = ply:SteamID()
    local steamID64 = ply:SteamID64()

    -- Skip check if player is whitelisted
    if whitelistedSteamIDs[steamID] then
        print("Player ", ply:Nick(), " (SteamID: ", steamID, ") is whitelisted and bypassed checks.")
        return
    end

    -- Check if the player owns the game
    if steamID64 ~= ply:OwnerSteamID64() then
        --print("Player ", ply:Nick(), " (SteamID: ", steamID, ") is likely using family share.")
        ply:Kick("You must own Garry's Mod to play on this server.")
    end

    -- Check VAC/Game bans using Steam Web API
    local apiUrl = string.format("https://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=%s&steamids=%s", STEAM_API_KEY, steamID64)

    http.Fetch(apiUrl,
        function(body)
            local data = util.JSONToTable(body)

            if data and data.players and #data.players > 0 then
                local banData = data.players[1]

                if banData.VACBanned or banData.NumberOfGameBans > 0 then
                    print("Player ", ply:Nick(), " (SteamID: ", steamID, ") has a VAC/Game ban.")
                    ply:Kick("You are banned from playing due to VAC or game bans.")
                else
                    print("Player ", ply:Nick(), " (SteamID: ", steamID, ") is clean.")
                end
            else
                print("Failed to fetch ban data for SteamID: ", steamID)
            end
        end,
        function(error)
            print("HTTP request failed for SteamID: ", steamID, ", Error: ", error)
        end
    )
end

-- Hook into the player join event
hook.Add("PlayerInitialSpawn", "CheckPlayerOwnershipAndBans", function(ply)
    timer.Simple(1, function() -- Delay to ensure player entity is fully initialized
        CheckPlayerDetails(ply)
    end)
end)

-- Load the whitelist at server start
hook.Add("Initialize", "LoadWhitelistOnInit", LoadWhitelist)
