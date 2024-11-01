--[[
    TO-DO:
    - Easyly to add some appearances: ✔
    - GetModelSex: ✔
]]
EasyAppearance = EasyAppearance or {}

local EntityMeta = FindMetaTable("Entity")

local Appearances = {
    Male = {
        ["Casual 1"] = "models/humans/modern/male/sheet_01",
        ["Firefighter"] = "models/humans/modern/male/sheet_02",
        ["Casual 2"] = "models/humans/modern/male/sheet_03",
        ["Casual 3"] = "models/humans/modern/male/sheet_04",
        ["Casual 4"] = "models/humans/modern/male/sheet_05",
        ["Casual 5"] = "models/humans/modern/male/sheet_08",
        ["Casual 6"] = "models/humans/modern/male/sheet_09",
        ["Casual 7"] = "models/humans/modern/male/sheet_10",
        ["Casual 8"] = "models/humans/modern/male/sheet_11",
        ["Casual 9"] = "models/humans/modern/male/sheet_12",
        ["Casual 10"] = "models/humans/modern/male/sheet_13",
        ["Casual 11"] = "models/humans/modern/male/sheet_14",
        ["Casual 12"] = "models/humans/modern/male/sheet_16",
        ["Casual 13"] = "models/humans/modern/male/sheet_17",
        ["Casual 14"] = "models/humans/modern/male/sheet_18",
        ["Casual 15"] = "models/humans/modern/male/sheet_20",
        ["Casual 16"] = "models/humans/modern/male/sheet_21",
        ["Casual 17"] = "models/humans/modern/male/sheet_22",
        ["Casual 18"] = "models/humans/modern/male/sheet_23",
        ["Casual 19"] = "models/humans/modern/male/sheet_24",
        ["Casual 20"] = "models/humans/modern/male/sheet_25",
        ["Casual 21"] = "models/humans/modern/male/sheet_26",
        ["Casual 22"] = "models/humans/modern/male/sheet_27",
        ["Casual 23"] = "models/humans/modern/male/sheet_28",
        ["Casual 24"] = "models/humans/modern/male/sheet_29",
        ["Casual 25"] = "models/humans/modern/male/sheet_30",
        ["Casual 26"] = "models/humans/modern/male/sheet_31"
    },
    Female = {
        ["Casual 1"] = "models/humans/modern/female/sheet_01",
        ["Casual 2"] = "models/humans/modern/female/sheet_02",
        ["Casual 3"] = "models/humans/modern/female/sheet_03",
        ["Casual 4"] = "models/humans/modern/female/sheet_04",
        ["Casual 5"] = "models/humans/modern/female/sheet_05",
        ["Casual 6"] = "models/humans/modern/female/sheet_06",
        ["Casual 7"] = "models/humans/modern/female/sheet_07",
        ["Casual 8"] = "models/humans/modern/female/sheet_08",
        ["Casual 9"] = "models/humans/modern/female/sheet_09",
        ["Casual 10"] = "models/humans/modern/female/sheet_10",
        ["Casual 11"] = "models/humans/modern/female/sheet_11",
        ["Casual 12"] = "models/humans/modern/female/sheet_12",
        ["Casual 13"] = "models/humans/modern/female/sheet_13",
        ["Casual 14"] = "models/humans/modern/female/sheet_14",
        ["Casual 15"] = "models/humans/modern/female/sheet_15"
    }
}

local Models = {
    // Male
    ["Male 01"] = {strPatch = "models/player/group01/male_01.mdl", intSubMat = 3 },
    ["Male 02"] = {strPatch = "models/player/group01/male_02.mdl", intSubMat = 2 },
    ["Male 03"] = {strPatch = "models/player/group01/male_03.mdl", intSubMat = 4 },
    ["Male 04"] = {strPatch = "models/player/group01/male_04.mdl", intSubMat = 4 },
    ["Male 05"] = {strPatch = "models/player/group01/male_05.mdl", intSubMat = 4 },
    ["Male 06"] = {strPatch = "models/player/group01/male_06.mdl", intSubMat = 0 },
    ["Male 07"] = {strPatch = "models/player/group01/male_07.mdl", intSubMat = 4 },
    ["Male 08"] = {strPatch = "models/player/group01/male_08.mdl", intSubMat = 0 },
    ["Male 09"] = {strPatch = "models/player/group01/male_09.mdl", intSubMat = 2 },
    // Female
    ["Female 01"] = {strPatch = "models/player/group01/female_01.mdl", intSubMat = 2 },
    ["Female 02"] = {strPatch = "models/player/group01/female_02.mdl", intSubMat = 3 },
    ["Female 03"] = {strPatch = "models/player/group01/female_03.mdl", intSubMat = 3 },
    ["Female 04"] = {strPatch = "models/player/group01/female_04.mdl", intSubMat = 1 },
    ["Female 05"] = {strPatch = "models/player/group01/female_05.mdl", intSubMat = 2 },
    ["Female 06"] = {strPatch = "models/player/group01/female_06.mdl", intSubMat = 4 },
}

EasyAppearance.Models = Models
EasyAppearance.Appearances = Appearances

local sex = {
    [1] = "Male",
    [2] = "Female"
}

EasyAppearance.Sex = sex

// -- Functions

function EasyAppearance.GetModelSex( entity )

    local tSubModels = entity:GetSubModels()

    for i = 1, #tSubModels do

        local name = tSubModels[ i ][ "name" ]

        if name == "models/m_anm.mdl" then
            return 1
        end

        if name == "models/f_anm.mdl" then
            return 2
        end

    end

    return false

end

function EntityMeta:GetModelSex()

    return EasyAppearance.GetModelSex(self)

end

function EasyAppearance.AddAppearances( intSex, strMame, strTexturePatch )

    if not intSex or not strName or not strTexturePatch then print( "invalid vars" ) return false end
    
    local strSex = sex[ math.Clamp( intSex, 1, 2 ) ]

    EasyAppearance.Appearances[ strSex ][ strName ] = strTexturePatch

    return true

end