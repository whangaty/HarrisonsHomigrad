function ffa.StartRoundSV()
    tdm.RemoveItems()

    roundTimeStart = CurTime()
    roundTime = 300 + math.random(0, 300)

    local players = PlayersInGame()
    for i, ply in pairs(players) do
        ply:SetTeam(1)
        ply:SetNWInt("KillCount", 0)
        ffa.SpawnPlayer(ply) 
    end

    local aviable = ReadDataMap("dm")
    aviable = #aviable ~= 0 and aviable or homicide.Spawns()

    tdm.SpawnCommand(team.GetPlayers(1), aviable, function(ply)
        ply:Freeze(true)
    end)

    freezing = true
    roundTimeRespawn = CurTime() + 10

    return {roundTimeStart, roundTime}
end

function ffa.SpawnPlayer(ply)
    ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:SetPlayerColor(Vector(0, 1, 0.051))

    ply:Give("weapon_hands")

    local roundDmType = math.random(1, 4)
    if roundDmType == 1 then
        local r = math.random(1, 8)
        ply:Give((r == 1 and "weapon_mp7") or (r == 2 and "weapon_ak74u") or (r == 3 and "weapon_akm") or (r == 4 and "weapon_rpgg" and "weapon_ump") or (r == 5 and "weapon_m4a1") or (r == 6 and "weapon_mk18") or (r == 7 and "weapon_m4a1") or (r == 8 and "weapon_galil"))
        ply:Give("weapon_kabar")
        ply:Give("medkit")
        ply:Give("med_band_big")
        ply:SetAmmo(90, (r == 1 and 46) or (r == 2 and 44) or (r == 3 and 47) or (r >= 5 and 45))

    elseif roundDmType == 2 then
        local r = math.random(1, 4)
        local p = math.random(1, 4)
        ply:Give((r == 1 and "weapon_spas12") or (r == 2 and "weapon_xm1014") or (r == 3 and "weapon_remington870") or (r == 4 and "weapon_minu14"))
        ply:Give((p == 1 and "weapon_ump") or p == 2 and "weapon_fiveseven" or p == 3 and "weapon_glock" or p == 4 and "weapon_glock18")
        ply:Give("weapon_kabar")
        ply:Give("medkit")
        ply:Give("med_band_big")
        ply:Give("weapon_hg_rgd5")
        ply:SetAmmo(90, (p <= 3 and 49) or (p == 4 and "5.7×28 mm"))
        ply:SetAmmo(90, 41)

    elseif roundDmType == 3 then
        ply:Give("weapon_deagle")
        ply:Give("weapon_kabar")
        ply:Give("medkit")
        ply:Give("med_band_big")
        ply:SetAmmo(90, ".44 Remington Magnum")

    elseif roundDmType == 4 then
        local r = math.random(1, 3)
        ply:Give((r == 1 and "weapon_hk_usp") or (r == 2 and "weapon_fiveseven") or (r == 3 and "weapon_beretta"))
        ply:Give("weapon_kabar")
        ply:Give("med_band_big")
        ply:Give("weapon_hg_rgd5")
        ply:Give("weapon_hidebomb")
        ply:SetAmmo(50, 49)
    end

    ply:Give("weapon_radio")
    ply:SetLadderClimbSpeed(100)
end

function ffa.RoundEndCheck()
    local winner = nil
    local highestKills = 0
    local topPlayer = nil

    for i, ply in pairs(team.GetPlayers(1)) do
        local kills = ply:GetNWInt("KillCount", 0)

        if kills >= 50 then
            winner = ply
            break
        end

        if kills > highestKills then
            highestKills = kills
            topPlayer = ply
        end
    end

    if winner then
        EndRound(winner)
    elseif roundTimeStart + roundTime < CurTime() then
        EndRound(topPlayer)
    end
end

function ffa.EndRound(winner)
    if winner then
        PrintMessage(3, winner:GetName() .. " won with " .. winner:GetNWInt("KillCount") .. " kills!")
    else
        PrintMessage(3, "Time is up! No one reached 50 kills.")
    end

    for i, ply in ipairs(player.GetAll()) do
        ply:SetNWInt("KillCount", 0)
    end

    hook.Remove("EntityTakeDamage", "FFA_TrackPlayerDamage")
    hook.Remove("PlayerDeath", "FFA_HandlePlayerDeath")
end

function ffa.TrackPlayerDamage(target, dmgInfo)
    if target:IsPlayer() and dmgInfo:GetAttacker():IsPlayer() then
        local attacker = dmgInfo:GetAttacker()

        if not damageTracking[target] then
            damageTracking[target] = {}
        end

        if not damageTracking[target][attacker] then
            damageTracking[target][attacker] = 0
        end

        damageTracking[target][attacker] = damageTracking[target][attacker] + dmgInfo:GetDamage()
    end
end

function ffa.HandlePlayerDeath(victim)
    if damageTracking[victim] then
        local highestDamage = 0
        local killer = nil

        for attackerPlayer, damage in pairs(damageTracking[victim]) do
            if damage > highestDamage then
                highestDamage = damage
                killer = attackerPlayer
            end
        end

        if killer and killer:IsValid() then
            killer:SetNWInt("KillCount", killer:GetNWInt("KillCount") + 1)
        end

        damageTracking[victim] = nil
    end

    timer.Simple(10, function()
        if IsValid(victim) then
            ffa.SpawnPlayer(victim) 
        end
    end)
end

function ffa.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function ffa.PlayerCanJoinTeam(ply, teamID)
    if teamID ~= 1 then
        ply:ChatPrint("Only one team is available.")
        return false
    end
    return true
end

damageTracking = {}
