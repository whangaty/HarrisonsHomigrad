
CustomModel = CustomModel or {}

local selectedModel = ply:GetInfo("cl_playermodel") -- Retrieve the model selected by the player
local modelToUse = player_manager.TranslatePlayerModel( selectedModel )
local customModel = GetPlayerModelBySteamID(ply:SteamID()) -- Retrieve the model assigned via SteamID

-- Define allowed user groups
local allowedGroups = {
    sponsor = true,
    tmod = true,
    operator = true,
    admin = true,
    superadmin = true,
    owner = true,
    servermanager = true,
}

-- Determine the model to use
function CustomModel.SetModel()
    if selectedModel and util.IsValidModel(modelToUse) and allowedGroups[ply:GetUserGroup()] then
        ply:SetSubMaterial()
        ply:SetModel(modelToUse)
    end
end