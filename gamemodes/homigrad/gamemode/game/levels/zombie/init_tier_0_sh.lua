table.insert(LevelList,"zombie")
zombie = {}
zombie.Name = "Zombie Survival"

zombie.green = {"Survivors",Color(55,255,55),
    weapons = {"weapon_hands"},
    models = tdm.models
}

zombie.blue = {"Special Forces",Color(55,55,255),
    weapons = {"weapon_radio","weapon_hands","weapon_kabar","med_band_big","med_band_small","medkit","painkiller","weapon_hg_f1","weapon_handcuffs","weapon_taser","weapon_hg_flashbang"},
    main_weapon = {"weapon_hk416","weapon_m4a1","weapon_m3super","weapon_mp7","weapon_xm1014","weapon_fal","weapon_asval","weapon_m249","weapon_mp5","weapon_p90"},
    secondary_weapon = {"weapon_beretta","weapon_p99","weapon_hk_usp"},
    models = tdm.models
}

zombie.teamEncoder = {
    [1] = "green",
    [2] = "blue"
}

function zombie.StartRound(data)
	team.SetColor(1,zombie.green[2])
	team.SetColor(2,zombie.blue[2])

	game.CleanUpMap(false)

    if CLIENT then
		roundTimeLoot = data.roundTimeLoot

		return
	end

    return zombie.StartRoundSV()
end

zombie.SupportCenter = false
