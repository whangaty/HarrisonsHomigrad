include("../../playermodelmanager_sv.lua")

local function makeT(ply)
    ply.roleT = true
    table.insert(juggernaut.t,ply)

    ply:Give("weapon_kabar")
    local wep = ply:Give("weapon_hk_usp")
    wep:SetClip1(wep:GetMaxClip1())
    ply:GiveAmmo(6 * wep:GetMaxClip1(),wep:GetPrimaryAmmoType())

    ply:Give("weapon_hg_rgd5")

    local wep = ply:Give("weapon_ar15")
    wep:SetClip1(wep:GetMaxClip1())
    ply:GiveAmmo(2 * wep:GetMaxClip1(),wep:GetPrimaryAmmoType())
    ply.nopain = true
    ply:SetMaxHealth(#player.GetAll() * 200)
    ply:SetHealth(#player.GetAll() * 200)

    ply:ChatPrint("You are John Wick")
end

function juggernaut.SpawnsCT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("hiders")) do
        table.insert(aviable,point)
    end

    return aviable
end

function juggernaut.SpawnsT()
    local aviable = {}

    for i,point in pairs(ReadDataMap("hiders")) do
        table.insert(aviable,point)
    end

    return aviable
end

function juggernaut.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

	roundTimeStart = CurTime()
	roundTime = math.max(math.ceil(#player.GetAll() / 1.5),1) * 60

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    for i,ply in player.Iterator() do ply.roleT = false end

    juggernaut.t = {}

    local countT = 0

    local aviable = juggernaut.SpawnsCT()
    local aviable2 = juggernaut.SpawnsT()

    local players = PlayersInGame()

    local count = 1
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end

    juggernaut.SyncRole()

    tdm.SpawnCommand(players,aviable,function(ply)
        ply.roleT = false

        ply:Give("weapon_gurkha")
        local wep = ply:Give("weapon_hk_usp")
        wep:SetClip1(wep:GetMaxClip1())
        ply:GiveAmmo(2 * wep:GetMaxClip1(),wep:GetPrimaryAmmoType())
    end)

    tdm.SpawnCommand(juggernaut.t,aviable2,function(ply)
        timer.Simple(1,function()
            ply.nopain = true
        end)
    end)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

function juggernaut.RoundEndCheck()
    tdm.Center()

    if roundTimeStart + roundTime - CurTime() <= 0 then EndRound() end
	local TAlive = tdm.GetCountLive(juggernaut.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
        EndRound(1)
	end

	if TAlive == 0 and Alive == 0 then EndRound() return end

	if TAlive == 0 then EndRound(2) end
	if Alive == 0 then EndRound(1) end
end

function juggernaut.EndRound(winner)
    PrintMessage(3,(winner == 1 and "John Wick remains Victorious." or winner == 2 and "Wick has fallen." or "Nobody Wins."))
end

local empty = {}

function juggernaut.PlayerSpawn(ply,teamID)
    local teamTbl = juggernaut[juggernaut.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]

	-- Set the player's model to the custom model if available, otherwise use a random team model
    local customModel = GetPlayerModelBySteamID(ply:SteamID())

    if ply.roleT then
        -- Give Armour to Wick and make it invisible, because current health increase doesnt seem to work?
        JMod.EZ_Equip_Armor(ply,"Medium-Vest",Color(0,0,0,0))
        JMod.EZ_Equip_Armor(ply,"Medium-Helmet",Color(0,0,0,0))

        if customModel then
            ply:SetModel(customModel)
        else
            ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
        end
    end
    ply:SetPlayerColor(color:ToVector())

	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = false end)
end

function juggernaut.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function juggernaut.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("homicide_roleget2")

function juggernaut.SyncRole()
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
    end

    net.Start("homicide_roleget2")
    net.WriteTable(role)
    net.Broadcast()
end

function juggernaut.PlayerDeath(ply,inf,att) return false end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","painkiller"}
local rare = {"weapon_fiveseven","weapon_gurkha","weapon_t","weapon_per4ik","*ammo*"}

function juggernaut.ShouldSpawnLoot()
    return false
end

function juggernaut.GuiltLogic(ply,att,dmgInfo)
    return (not ply.roleT) == (not att.roleT) and 20 or 0
end

function juggernaut.NoSelectRandom()
    return #ReadDataMap("spawnpointswick") < 1
end
