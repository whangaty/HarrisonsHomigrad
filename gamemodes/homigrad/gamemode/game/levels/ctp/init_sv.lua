local function GetTeamSpawns(ply)
    local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()

    if ply:Team() == 1 then
        return spawnsT
    elseif ply:Team() == 2 then
        return spawnsCT
    else
        return false
    end
end

function ctp.SpawnVehicle()
    for k, v in pairs(ReadDataMap("swo_carsct")) do
        local v2 = ReadPoint(v)
        local contradiction = false
        for k3, v3 in pairs(ents.FindInSphere(v2[1], 128)) do
            if v3:GetClass() == "gmod_sent_vehicle_fphysics_base" or v3:GetClass() == "lvs_base" then
                contradiction = true
            end
        end

        if !contradiction then
            simfphys.SpawnVehicleSimple("sim_fphys_van",v2[1],v2[2])
        end
    end

    for k, v in pairs(ReadDataMap("swo_carst")) do
        local v2 = ReadPoint(v)
        local contradiction = false
        for k3, v3 in pairs(ents.FindInSphere(v2[1], 128)) do
            if v3:GetClass() == "gmod_sent_vehicle_fphysics_base" or v3:GetClass() == "lvs_base" then
                contradiction = true
            end
        end

        if !contradiction then
            simfphys.SpawnVehicleSimple("sim_fphys_van",v2[1],v2[2])
        end
    end
end

function ctp.SpawnGred()
	for i,point in pairs(ReadDataMap("gred_emp_dshk")) do
		local ent = ents.Create("gred_emp_dshk")
		ent:SetPos(point[1])
		ent:SetAngles(point[2])
		ent:Spawn()
	end
    for i,point in pairs(ReadDataMap("gred_ammobox")) do
        local ent = ents.Create("gred_ammobox")
        ent:SetPos(point[1])
		ent:SetAngles(point[2])
		ent:Spawn()
    end
end

function ctp.StartRoundSV()
    tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60*15 --15 минут

	for i,ply in pairs(team.GetPlayers(3)) do ply:SetTeam(math.random(1,2)) end

	OpposingAllTeam()
	AutoBalanceTwoTeam()

    local spawnsT,spawnsCT = tdm.SpawnsTwoCommand()
	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)

    ctp.SpawnVehicle()
	ctp.SpawnGred()

    bahmut.SelectRandomPlayers(team.GetPlayers(1),4,bahmut.GiveAidPhone)
    bahmut.SelectRandomPlayers(team.GetPlayers(2),4,bahmut.GiveAidPhone)

    tdm.CenterInit()

    ctp.ragdolls = {}
end

function ctp.Think()
    ctp.LastWave = ctp.LastWave or CurTime() + 60

    if CurTime() >= ctp.LastWave then
        SetGlobalInt("CP_respawntime", CurTime())
    
        ctp.SpawnVehicle()
    
        for _, v in player.Iterator() do
            local players = {}
            if !v:Alive() and v:Team() != 1002 then
                v:Spawn()
                local teamspawn = GetTeamSpawns(v)
    
                local point,key = table.Random(teamspawn)
                point = ReadPoint(point)
                if not point then continue end
    
                v:SetPos(point[1])
                players[v:Team()] = players[v:Team()] or {}
                players[v:Team()][v] = true
            end
    
            for i,list in pairs(players) do
                bahmut.SelectRandomPlayers(list[1],6,bahmut.GiveAidPhone)
                bahmut.SelectRandomPlayers(list[2],6,bahmut.GiveAidPhone)
            end
    
        end
    
        for ent in pairs(ctp.ragdolls) do
            if IsValid(ent) then ent:Remove() end
    
            ctp.ragdolls[ent] = nil
        end

        ctp.LastWave = CurTime() + 60
    end
end

function ctp.PlayerSpawn2(ply,teamID)
    local teamTbl = ctp[ctp.teamEncoder[teamID]]
	local color = teamTbl[2]

	ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    ply:SetPlayerColor(color:ToVector())
    ply.allowFlashlights = true

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

    tdm.GiveSwep(ply,teamTbl.main_weapon)
    tdm.GiveSwep(ply,teamTbl.secondary_weapon)

	if math.random(1,4) == 4 then ply:Give("adrenaline") end
	if math.random(1,4) == 4 then ply:Give("morphine") end
    if math.random(1,2) == 2 then ply:Give("megamedkit") end

	--local r = math.random(1,3)
	--ply:Give(r == 1 and "food_fishcan" or r == 2 and "food_spongebob_home" or r == 3 and "food_lays")

	if math.random(1,3) == 3 then ply:Give("weapon_hg_f1") end

	JMod.EZ_Equip_Armor(ply,"Medium-Helmet",color)
	local r = math.random(1,2)
	JMod.EZ_Equip_Armor(ply,(r == 1 and "Medium-Vest") or (r == 2 and "Light-Vest"),color)
end

function ctp.PointsThink() --обработка точек, сколько людей из каждой команды и процесс захвата
    local cp_points = ctp.points
    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        local v = cp_points[i]
        if not v then
            v = {}
            cp_points[i] = v
        end

        v[1] = point[1]

        v.RedAmount = 0
        v.BlueAmount = 0

        for _, v2 in pairs(ents.FindInSphere(v[1], 256)) do
            if !v2:IsPlayer() or !v2:Alive() or v2.unconscious then continue end

            if v2:Team() == 1 then
                v.RedAmount = v.RedAmount + 1
            elseif v2:Team() == 2 then
                v.BlueAmount = v.BlueAmount + 1
            end
        end

        if v.RedAmount > v.BlueAmount then
            v.CaptureProgress = math.Clamp((v.CaptureProgress or 0) + 10, -100, 100)
        elseif v.BlueAmount > v.RedAmount then
            v.CaptureProgress = math.Clamp((v.CaptureProgress or 0) - 10, -100, 100)
        end

        if v.CaptureProgress == 100 then
            v.CaptureTeam = 1
        elseif v.CaptureProgress == -100 then
            v.CaptureTeam = 2
        elseif v.CaptureProgress == 0 then
            v.CaptureTeam = 0
        end

        if v.CaptureTeam and v.CaptureTeam != 0 then
            ctp.WinPoints[v.CaptureTeam] = ctp.WinPoints[v.CaptureTeam] + 7.5 / #SpawnPointsList.controlpoint[3]
        end

        SetGlobalInt(i .. "PointProgress", v.CaptureProgress)
        SetGlobalInt(i .. "PointCapture", v.CaptureTeam)
    end

    for i = 1, 2 do
        SetGlobalInt("CP_Winpoints" .. i, ctp.WinPoints[i])
    end
end

function ctp.RoundEndCheck()
    tdm.Center()

    for i = 1, 2 do
        if ctp.WinPoints[i] >= 1000 then
            EndRound(i)
        end
    end
    if roundTimeStart + roundTime < CurTime() then EndRound() end
end

function ctp.EndRound(winner)
	print("End round, win '" .. tostring(winner) .. "'")

	for _, ply in ipairs(player.GetAll()) do
		if !winner then ply:ChatPrint("Nobody Wins") continue end
		if winner == ply:Team() then ply:ChatPrint("Victory!") end
		if winner ~= ply:Team() then ply:ChatPrint("Defeat") end
	end

    timer.Remove("CP_NewWave")
    timer.Remove("CP_ThinkAboutPoints")
end

function ctp.PlayerInitialSpawn(ply) ply:SetTeam(math.random(2)) end

function ctp.PlayerCanJoinTeam(ply, teamID)
    if teamID == 3 then ply:ChatPrint("Иди нахуй") return false end
end

local function max(a)
    local values = {}

    for k,v in pairs(a) do
        values[#values+1] = v
    end
    table.sort(values) -- automatically sorts lowest to highest

    return values[#values]
end

ctp.ragdolls = {}
function ctp.PlayerDeath(ply,inf,att)
    ctp.ragdolls[ply:GetNWEntity("Ragdoll")] = true

    return false
end

ctp.NoSelectRandom = true
