table.insert(LevelList,"gravtdm")
gravtdm = {}
gravtdm.Name = "Gravity Gun Gambit (TDM)"

local models = {}
for i = 1,9 do table.insert(models,"models/player/group03/male_0" .. i .. ".mdl") end

gravtdm.red = {"Resistance",Color(125,95,60),
	weapons = {"weapon_hands","weapon_physcannon","weapon_hg_shovel","medkit","med_band_big"},
	--main_weapon = {"weapon_sar2","weapon_spas12","weapon_akm","weapon_mp7"},
	--secondary_weapon = {"weapon_hk_usp","weapon_p220"},
	models = models
}


gravtdm.blue = {"Combine",Color(75,75,125),
	weapons = {"weapon_hands","weapon_physcannon","weapon_hg_shovel","medkit","med_band_big"},
	--main_weapon = {"weapon_sar2","weapon_spas12","weapon_mp7"},
	--secondary_weapon = {"weapon_hk_usp"},
	models = {"models/player/combine_soldier.mdl"}
}

gravtdm.teamEncoder = {
	[1] = "red",
	[2] = "blue"
}

function gravtdm.StartRound()
	game.CleanUpMap(false)

	team.SetColor(1,gravtdm.red[2])
	team.SetColor(2,gravtdm.blue[2])

	if CLIENT then

		gravtdm.StartRoundCL()
		return
	end

	gravtdm.StartRoundSV()
end
gravtdm.RoundRandomDefalut = 2
gravtdm.SupportCenter = true
