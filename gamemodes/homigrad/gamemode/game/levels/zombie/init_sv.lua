include("../../playermodelmanager_sv.lua")

function zombie.StartRoundSV(data)
    tdm.RemoveItems()

	tdm.DirectOtherTeam(2,1)

	roundTimeStart = CurTime()
	roundTime = 60 * (2 + math.min(#player.GetAll() / 16,2))
	roundTimeLoot = 10

    local players = team.GetPlayers(1)

	local spawnsT = ReadDataMap("spawnpoints_ss_school")
	local spawnsCT = ReadDataMap("spawnpointshiders")

	tdm.SpawnCommand(team.GetPlayers(1),spawnsT)
	tdm.SpawnCommand(team.GetPlayers(2),spawnsCT)

	zombie.police = false

	return {roundTimeLoot = roundTimeLoot}
end

function zombie.RoundEndCheck()
    if roundTimeStart + roundTime < CurTime() then

		if not zombie.police then
			zombie.police = true
			PrintMessage(3,"Special Forces have arrived! Hiders can now escape through select points on the map.")

			local aviable = ReadDataMap("spawnpointsct")

			for i,ply in pairs(tdm.GetListMul(player.GetAll(),1,function(ply) return not ply:Alive() and not ply.roleT and ply:Team() ~= 1002 end),1) do
				ply:Spawn()

                ply:SetPlayerClass("contr")

				ply:SetTeam(2)
			end
		end
	end

	local CTAlive,CTExit = 0,0

	local OAlive = 0

	CTAlive = tdm.GetCountLive(team.GetPlayers(1),function(ply)
		if ply.exit then CTExit = CTExit + 1 return false end
	end)

	local list = ReadDataMap("spawnpoints_ss_exit")

	if zombie.police then
		for i,ply in pairs(team.GetPlayers(2)) do
			if not ply:Alive() or ply.exit then continue end

			for i,point in pairs(list) do
				if ply:GetPos():Distance(point[1]) < (point[3] or 250) then
					ply.exit = true
					ply:KillSilent()

					CTExit = CTExit + 1

					PrintMessage(3,ply:GetName().." has escaped! "..(CTAlive - 1) .. " survivors remain.")
				end
			end
		end
	end

	if CTExit > 0 and CTAlive == 0 then EndRound(1) return end
	if CTAlive == 0 then EndRound() return end
end

function zombie.EndRound(winner) tdm.EndRoundMessage(winner) end

function zombie.PlayerSpawn(ply,teamID)
	local teamTbl = zombie[zombie.teamEncoder[teamID]]
	local color = teamTbl[2]

	-- Set the player's model to the custom model if available, otherwise use a random team model
    local customModel = GetPlayerModelBySteamID(ply:SteamID())

    if customModel then
        ply:SetModel(customModel)
    else
        ply:SetModel(teamTbl.models[math.random(#teamTbl.models)])
    end

    ply:SetPlayerColor(color:ToVector())

	for i,weapon in pairs(teamTbl.weapons) do ply:Give(weapon) end

	tdm.GiveSwep(ply,teamTbl.main_weapon,teamID == 1 and 16 or 4)
	tdm.GiveSwep(ply,teamTbl.secondary_weapon,teamID == 1 and 8 or 2)

	if math.random(1,4) == 4 then ply:Give("weapon_per4ik") end
	if math.random(1,8) == 8 then ply:Give("adrenaline") end
	if math.random(1,7) == 7 then ply:Give("painkiller") end
	if math.random(1,6) == 6 then ply:Give("medkit") end
	if math.random(1,5) == 5 then ply:Give("med_band_big") end
	if math.random(1,8) == 8 then ply:Give("morphine") end

	if ply:IsUserGroup("sponsor") or ply:IsUserGroup("supporterplus") then
		ply:Give("weapon_vape")
	end

	local r = math.random(1,3)
	ply:Give(r == 1 and "food_fishcan" or r == 2 and "food_spongebob_home" or r == 3 and "food_lays")

	if math.random(1,3) == 3 then ply:Give("food_monster") end
	if math.random(1,5) == 5 then ply:Give("weapon_bat") end

    if teamID == 1 then
        JMod.EZ_Equip_Armor(ply,"Medium-Helmet",color)
        JMod.EZ_Equip_Armor(ply,"Light-Vest",color)
	elseif teamID == 2 then
		ply:SetPlayerColor(Color(math.random(160),math.random(160),math.random(160)):ToVector())
    end
	ply.allowFlashlights = false
end

function zombie.PlayerInitialSpawn(ply) ply:SetTeam(2) end

function zombie.PlayerCanJoinTeam(ply,teamID)
	if teamID == 2 then
		if ply:IsAdmin() then
			ply:Spawn()

			return true
		else
			ply:ChatPrint("Not now.")

			return false
		end
	end

    if teamID == 1 then
		if ply:IsAdmin() then
			return true
		else
			ply:ChatPrint("Please wait until next round to join!")

			return false
		end
	end
end

local common = {  "weapon_t", "weapon_hg_molotov", "*ammo*", "weapon_hg_sleagehammer", "weapon_hg_fireaxe", "ent_jack_gmod_ezarmor_gasmask", "ent_jack_gmod_ezarmor_mltorso" }
local uncommon = { "weapon_m3super", "weapon_ar15", "weapon_beretta", "ent_jack_gmod_ezarmor_mtorso", "ent_jack_gmod_ezarmor_mhead" }
local rare = { "weapon_xm1014", "weapon_m4a1", "weapon_xm8_lmg", "weapon_hk416", "weapon_civil_famas", "weapon_glock", "weapon_remington870", "weapon_akm", "weapon_rpk", "weapon_p90", "weapon_asval"}

function zombie.ShouldSpawnLoot()
   	if roundTimeStart + roundTimeLoot - CurTime() > 0 then return false end

	local chance = math.random(100)
	if chance < 5 then
		return true,rare[math.random(#rare)]
	elseif chance < 30 then
		return true,uncommon[math.random(#uncommon)]
	elseif chance < 70 then
		return true,common[math.random(#common)]
	else
		return false
	end
end

function zombie.PlayerDeath(ply,inf,att) return false end

function zombie.GuiltLogic(ply,att,dmgInfo)
	if att.isContr and ply:Team() == 1 then return dmgInfo:GetDamage() * 3 end
end

zombie.NoSelectRandom = true