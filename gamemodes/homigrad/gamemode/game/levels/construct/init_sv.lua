-- Include the player model manager script (adjust the path as necessary)
include("../../playermodelmanager_sv.lua")

local function GetFriends(play)
    
    local huy = ""

    for i, ply in pairs(construct.t) do
        if play == ply then continue end
        huy = huy .. ply:Name() .. ", "
    end

    return huy
end

COMMANDS.homicide_get = {function(ply,args)
    if not (ply:IsAdmin() or (ply:GetUserGroup() == "operator") or (ply:GetUserGroup() == "tmod")) then return end
    if ply:Alive() then return end

    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply.roleT then table.insert(role[1],ply) end
        if ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("homicide_roleget")
    net.WriteTable(role)
    net.Send(ply)
end}

local function makeT(ply)
    ply.roleT = true --Игрока не существует. Выдаёт из-за этого ошибку в первый раз.
    table.insert(construct.t,ply)

    if construct.roundType == 1 or construct.roundType == 2 then
        local wep = ply:Give("weapon_hk_usps")
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        ply:Give("weapon_radar")
    elseif construct.roundType == 3 then
        local wep = ply:Give("weapon_hg_crossbow")
        ply:GiveAmmo(8, "XBowBolt", true) -- slots = bolts.
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_rgd5")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_radar")
        print(player.GetCount())
    else
        local wep = ply:Give("weapon_mateba")
        ply:GiveAmmo(3*8, ".44 Remington Magnum", true) -- slots = bullets.
        wep:SetClip1(wep:GetMaxClip1())
        ply:Give("weapon_kabar")
        ply:Give("weapon_hg_t_vxpoison")
        ply:Give("weapon_hidebomb")
        ply:Give("weapon_hg_rgd5")
        ply:Give("weapon_radar")
        ply:GiveAmmo(12,5)
    end

    timer.Simple(5,function() ply.allowFlashlights = true end)

    AddNotificate( ply,"You are a traitor.")

    if #GetFriends(ply) >= 1 then
        timer.Simple(1,function() AddNotificate( ply,"Your Traitor Buddies are" .. GetFriends(ply)) end)
    end
end

local function makeCT(ply)
    ply.roleCT = true
    table.insert(construct.ct,ply)
    if construct.roundType == 1 then
        local wep = ply:Give("weapon_remington870")
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"You have been given a shotgun. Be careful, the traitor will be likely to target you.")
    elseif construct.roundType == 2 then
        local wep = ply:Give("weapon_beretta")
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"You have been given a M9 Beretta with one magazine.")
    elseif construct.roundType == 3 then
        local wep = ply:Give("weapon_taser")
        ply:Give("weapon_police_bat")
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"You have been given a Taser & Baton to take care of the traitor.")
    elseif construct.roundType == 4 then
        local wep = ply:Give("weapon_mateba")
        wep:SetClip1(wep:GetMaxClip1())
        AddNotificate( ply,"You & the traitor have been given identical revolvers. Find them and kill them.")
    else
    end

end

COMMANDS.russian_roulette = {function(ply,args)
    if not ply:IsAdmin() then return end

	for i,plya in pairs(player.GetListByName(args[1]) or {ply}) do
		local wep = plya:Give("weapon_mateba",true)
        wep:SetClip1(1)
        wep:RollDrum()
	end
end}

function construct.Spawns()
    local aviable = {}

    if game.GetMap() ~= "gm_freeway_spacetunnel" then
        for i,ent in pairs(ents.FindByClass("info_player*")) do
            table.insert(aviable,ent:GetPos())
        end

        for i,ent in pairs(ents.FindByClass("info_node*")) do
            table.insert(aviable,ent:GetPos())
        end
    end

    for i,point in pairs(ReadDataMap("spawnpointshiders")) do
        table.insert(aviable,point)
    end

    --[[
    for i,point in pairs(ReadDataMap("spawnpointst")) do
        table.insert(aviable,point)
    end

    for i,point in pairs(ReadDataMap("spawnpointsct")) do
        table.insert(aviable,point)
    end
    ]]
    return aviable
end

sound.Add({
	name = "police_arrive",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = 100,
	sound = "snd_jack_hmcd_policesiren.wav"
})

function construct.StartRoundSV()
    tdm.RemoveItems()
    tdm.DirectOtherTeam(2,1,1)

    construct.police = false
	roundTimeStart = CurTime()
	roundTime = math.min(math.max(math.ceil(#player.GetAll() / 2), 1) * 45, 330)

    -- Bullshit check.
    if game.GetMap() == "gm_freeway_spacetunnel" then
        RunConsoleCommand("sv_gravity", "300")
    else
        RunConsoleCommand("sv_gravity", "600")
    end

    if construct.roundType == 3 then
        roundTime = roundTime * 1.25
    end

    roundTimeLoot = 5

    for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end
    --for i,ply in pairs(team.GetPlayers(2)) do ply:SetTeam(1) end

    construct.ct = {}
    construct.t = {}

    local countT = 0
    local countCT = 0

    local aviable = construct.Spawns()
    tdm.SpawnCommand(PlayersInGame(),aviable,function(ply)
        ply.roleT = false
        ply.roleCT = false

        if ply.forceT then
            ply.forceT = nil
            countT = countT + 1

            makeT(ply)
        end

        if ply.forceCT then
            ply.forceCT = nil
            countCT = countCT + 1

            makeCT(ply)
        end

        if ply:IsUserGroup("sponsor") or ply:IsUserGroup("supporterplus") then
            ply:Give("weapon_vape")
        end
    end)

    local players = PlayersInGame()
    local count = math.max(math.ceil(#players / 10), 1) - countT
    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        makeT(ply)
    end

    local count = math.max(math.ceil(#players / 10), 1) - countCT

    for i = 1,count do
        local ply = table.Random(players)
        table.RemoveByValue(players,ply)

        if construct.roundType <= 4 then
            makeCT(ply)
        end
    end

    timer.Simple(0,function()
        for i,ply in pairs(construct.t) do
            if not IsValid(ply) then table.remove(construct.t,i) continue end

            construct.SyncRole(ply,1)
        end

        for i,ply in pairs(construct.ct) do
            if not IsValid(ply) then table.remove(construct.ct,i) continue end

            construct.SyncRole(ply,2)
        end
    end)

    tdm.CenterInit()

    return {roundTimeLoot = roundTimeLoot}
end

local aviable = ReadDataMap("spawnpointsct")

COMMANDS.forcepolice = {function(ply)
    if not ply:IsAdmin() then PrintMessage(3,"nope") return end
    construct.police = false

    roundTime = 0
end}

function construct.RoundEndCheck()
    tdm.Center()

	local TAlive = tdm.GetCountLive(construct.t)
	local Alive = tdm.GetCountLive(team.GetPlayers(1),function(ply) if ply.roleT or ply.isContr then return false end end)

    if roundTimeStart + roundTime < CurTime() then
		if not construct.police then
			construct.police = true
            if construct.roundType == 1 then
                PrintMessage(3,"The Police have arrived.")
            else
                PrintMessage(3,"The Police have arrived.")
            end

			local aviable = ReadDataMap("spawnpointsct")
            local ctPlayers = tdm.GetListMul(player.GetAll(),1,function(ply) return not ply:Alive() and not ply.roleT and ply:Team() ~= 1002 end)
			
            local playsound = true
            tdm.SpawnCommand(ctPlayers,aviable,function(ply)
                timer.Simple(0,function()
                    if construct.roundType == 1 then
                        ply:SetPlayerClass("contr")
                    else
                        ply:SetPlayerClass("police")
                    end
                    if playsound then
                        ply:EmitSound("police_arrive")
                        playsound = false
                    end
                end)
            end)
            -- Send a message to each police player
            for _, ply in pairs(ctPlayers) do
                ply:ChatPrint(#construct.t > 1 and ("The traitors are: <clr:red>" .. construct.t[1]:Name() .. ", " .. GetFriends(construct.t[1])) or ("The traitor is: <clr:red>" .. construct.t[1]:Name()))
                ply:ChatPrint("<clr:red>WARNING: <clr:white>Killing friendlies will result in a punishment determined by staff.")
                net.Start("homicide_roleget")
                net.WriteTable({{},{}})
                net.Send(ply)
            end
		end
	end

	if TAlive == 0 and Alive == 0 then EndRound(1) return end

	if TAlive == 0 then EndRound(2) end
	if Alive == 0 then EndRound(1) end
end

function construct.EndRound(winner)
    PrintMessage(3,(winner == 1 and "Traitors Win." or winner == 2 and "Innocents Win!" or "Nobody Wins!"))
    if construct.t and #construct.t > 0 then
        PrintMessage(3,#construct.t > 1 and ("The traitors were: " .. construct.t[1]:Name() .. ", " .. GetFriends(construct.t[1])) or ("The traitor was: " .. construct.t[1]:Name()))
    end
end

local empty = {}

function construct.PlayerSpawn(ply,teamID)
    local teamTbl = construct[construct.teamEncoder[teamID]]
    local color = teamID == 1 and Color(math.random(55,165),math.random(55,165),math.random(55,165)) or teamTbl[2]

	-- Set the player's model to the custom model if available, otherwise use a random team model
    local customModel = GetPlayerModelBySteamID(ply:SteamID())

    if customModel then
        ply:SetSubMaterial()
        ply:SetModel(customModel)
    else
        EasyAppearance.SetAppearance( ply )
    end
    
    ply:SetPlayerColor(color:ToVector())

	ply:Give("weapon_hands")
    timer.Simple(0,function() ply.allowFlashlights = false end)
end

function construct.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function construct.PlayerCanJoinTeam(ply,teamID)
    if ply:IsAdmin() then
        if teamID == 2 then ply.forceCT = nil ply.forceT = true ply:ChatPrint("ты будешь за дбгшера некст раунд") return false end
        if teamID == 3 then ply.forceT = nil ply.forceCT = true ply:ChatPrint("ты будешь за хомисайдера некст раунд") return false end
    else
        if teamID == 2 or teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
    end

    return true
end

util.AddNetworkString("homicide_roleget")

function construct.SyncRole(ply,teamID)
    local role = {{},{}}

    for i,ply in pairs(team.GetPlayers(1)) do
        if teamID ~= 2 and ply.roleT then table.insert(role[1],ply) end
        if teamID ~= 1 and ply.roleCT then table.insert(role[2],ply) end
    end

    net.Start("homicide_roleget")
    net.WriteTable(role)
    net.Send(ply)
end

function construct.PlayerDeath(ply,inf,att)
    if (ply:IsAdmin() or (ply:GetUserGroup() == "operator") or (ply:GetUserGroup() == "tmod")) and ply:GetInfoNum("homicide_get",0) then
        local role = {{},{}}

        for i,ply in pairs(team.GetPlayers(1)) do
            if ply.roleT then table.insert(role[1],ply) end
            if ply.roleCT then table.insert(role[2],ply) end
        end
    
        net.Start("homicide_roleget")
        net.WriteTable(role)
        net.Send(ply)
    end
    return false
end

local common = {"food_lays","weapon_pipe","weapon_bat","med_band_big","med_band_small","medkit","food_monster","food_fishcan","food_spongebob_home"}
local uncommon = {"medkit","weapon_molotok","weapon_per4ik","painkiller"}
local rare = {"weapon_fiveseven","weapon_gurkha","weapon_t","weapon_mateba","weapon_m590"}

function construct.ShouldSpawnLoot()
    if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end
    local chance = math.random(100)
    if chance < 2 and not construct.roundType == 3 then
        return true,rare[math.random(#rare)],"legend"
    elseif chance < 20 then
        return true,uncommon[math.random(#uncommon)],"veryrare"
    elseif chance < 60 then
        return true,common[math.random(#common)],"common"
    else
        return false
    end
    --else
        --return true
end

function construct.ShouldDiscordOutput(ply,text)
    if ply:Team() ~= 1002 and ply:Alive() then return false end
end

function construct.ShouldDiscordInput(ply,text)
    if not ply:IsAdmin() then return false end
end

function construct.GuiltLogic(ply,att,dmgInfo)
    return ply.roleT == att.roleT
end

