table.insert(LevelList,"ctp")
ctp = {}
ctp.Name = "Capture The Point"
ctp.points = {}

ctp.WinPoints = ctp.WinPoints or {}
ctp.WinPoints[1] = ctp.WinPoints[1] or 0
ctp.WinPoints[2] = ctp.WinPoints[2] or 0

local red, blue, gray = Color(255,75,75), Color(75,75,255), Color(200, 200, 200)

ctp.red = {"Red",Color(255,75,75),
    weapons = {"weapon_binokle","weapon_radio","weapon_gurkha","weapon_hands","med_band_big","med_band_small","medkit","painkiller"},
    main_weapon = {"weapon_ak74u","weapon_akm","weapon_remington870","weapon_galil","weapon_rpk","weapon_asval","weapon_p90","weapon_scout","weapon_barret"},
    secondary_weapon = {"weapon_p220","weapon_mateba","weapon_glock"},
    models = tdm.models
}

ctp.blue = {"Blue",Color(75,75,255),
    weapons = {"weapon_binokle","weapon_radio","weapon_hands","weapon_kabar","med_band_big","med_band_small","medkit","painkiller","weapon_handcuffs","weapon_taser"},
    main_weapon = {"weapon_hk416","weapon_m4a1","weapon_m3super","weapon_mp7","weapon_xm1014","weapon_fal","weapon_asval","weapon_m249","weapon_p90","weapon_scout","weapon_barret"},
    secondary_weapon = {"weapon_beretta","weapon_p99","weapon_hk_usp"},
    models = tdm.models
}

ctp.teamEncoder = {
    [1] = "red",
    [2] = "blue"
}

ctp.RoundRandomDefalut = 1

function ctp.StartRound()
    local ply = player.GetAll()
	game.CleanUpMap(false)
    ctp.points = {}
    if !file.Read( "homigrad/maps/"..game.GetMap()..".txt", "DATA" ) and SERVER then
        print("No points are available on this map! Admins have to place them with: !point control_point") 
        PrintMessage(HUD_PRINTCENTER, "No points are available on this map! Admins have to place them with: !point control_point")
    end

    ctp.LastWave = CurTime()

    ctp.WinPoints = {}
    ctp.WinPoints[1] = 0
    ctp.WinPoints[2] = 0

	team.SetColor(1,red)
	team.SetColor(2,blue)

    for i, point in pairs(SpawnPointsList.controlpoint[3]) do
        SetGlobalInt(i .. "PointProgress", 0)
        SetGlobalInt(i .. "PointCapture", 0)
        ctp.points[i] = {}
    end

    SetGlobalInt("CP_respawntime", CurTime())

	if CLIENT then return end

    timer.Create("CP_ThinkAboutPoints", 1, 0, function() --подумай о точках... засунул в таймер для оптимизации, ибо там каждый тик игроки в сфере подглядываются, ну и в целом для удобства
        ctp.PointsThink()
    end)

    ctp.StartRoundSV()
end

--тот кто это кодил нужно убить нахуй

ctp.SupportCenter = true