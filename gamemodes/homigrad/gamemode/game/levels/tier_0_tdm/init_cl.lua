tdm.GetTeamName = tdm.GetTeamName

local playsound = false

function tdm.StartRoundCL()
    playsound = true
end

function tdm.HUDPaint_RoundLeft(white)
    local lply = LocalPlayer()
	local name,color = tdm.GetTeamName(lply)

	local startRound = roundTimeStart + 5 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound("snd_jack_hmcd_deathmatch.mp3")
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,220),0.5,4)


        --[[surface.SetFont("HomigradRoundFont")
        surface.SetTextColor(color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255)
        surface.SetTextPos(ScrW() / 2 - 40,ScrH() / 2)

        surface.DrawText("Вы " .. name)]]--
        draw.DrawText( "You Are On Team: " .. name, "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Team Deathmatch", "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color( color.r,color.g,color.b,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        --draw.DrawText( roundTypes[roundType], "HomigradRoundFont", ScrW() / 2, ScrH() / 5, Color( 55,55,155,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )

        draw.DrawText( "Eliminate the Enemy Team, and emerge victorious!", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound,0,1) * 255 ), TEXT_ALIGN_CENTER )
        return
    end
end