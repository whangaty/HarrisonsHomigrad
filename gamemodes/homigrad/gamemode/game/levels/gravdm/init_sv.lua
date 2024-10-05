function dm.StartRoundSV()
    tdm.RemoveItems()

	roundTimeStart = CurTime()
	roundTime = 60 * (1 + math.min(#player.GetAll() / 8,2))

    local players = PlayersInGame()
    for i,ply in pairs(players) do ply:SetTeam(1) end

    local aviable = ReadDataMap("dm")
    aviable = #aviable ~= 0 and aviable or homicide.Spawns()
    tdm.SpawnCommand(team.GetPlayers(1),aviable,function(ply)
        ply:Freeze(true)
    end)

    freezing = true

    RTV_CountRound = RTV_CountRound - 1

    roundTimeRespawn = CurTime() + 15

    --roundDmType = math.random(1,4)

    return {roundTimeStart,roundTime}
end

function dm.RoundEndCheck()
    local Alive = 0

    for i,ply in pairs(team.GetPlayers(1)) do
        if ply:Alive() then Alive = Alive + 1 end
    end

    if freezing and roundTimeStart + dm.LoadScreenTime < CurTime() then
        freezing = nil

        for i,ply in pairs(team.GetPlayers(1)) do
            ply:Freeze(false)
        end
    end

    if Alive <= 1 then EndRound() return end

end

function dm.EndRound(winner)
    for i, ply in ipairs( player.GetAll() ) do
	    if ply:Alive() then
            PrintMessage(3,ply:GetName() .. " remains. They are victorious!")
        end
    end
end

local red = Color(255,0,0)

function dm.PlayerSpawn(ply,teamID)
	ply:SetModel(tdm.models[math.random(#tdm.models)])
    ply:SetPlayerColor(Vector(0,0,0.6))


    ply:Give("weapon_hands")
    ply:Give("weapon_physcannon")
    ply:Give("weapon_crowbar")
    ply:Give("medkit")
    ply:Give("med_band_big")
    ply:Give("weapon_radio")

    ply:SetLadderClimbSpeed(100)

end

function dm.PlayerInitialSpawn(ply)
    ply:SetTeam(1)
end

function dm.PlayerCanJoinTeam(ply,teamID)
	if teamID == 2 or teamID == 3 then ply:ChatPrint("Pashol fuck") return false end

    return true
end

function dm.GuiltLogic() return false end

util.AddNetworkString("dm die")
function dm.PlayerDeath()
    net.Start("dm die")
    net.Broadcast()
end