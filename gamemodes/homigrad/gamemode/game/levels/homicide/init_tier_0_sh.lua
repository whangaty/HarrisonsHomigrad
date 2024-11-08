table.insert(LevelList,"homicide")
homicide = homicide or {}
homicide.Name = "Homicide"

homicide.red = {"Innocent",Color(125,125,125),
    models = tdm.models
}

homicide.teamEncoder = {
    [1] = "red"
}

homicide.RoundRandomDefalut = 6

local playsound = false
if SERVER then
    util.AddNetworkString("roundType")
else
    net.Receive("roundType",function(len)
        homicide.roundType = net.ReadInt(4)
        playsound = true
    end)
end

--[[local turnTable = {
    ["standard"] = 2,
    ["soe"] = 1,
    ["wild-west"] = 4,
    ["gun-free-zone"] = 3
}--]]

local homicide_setmode = CreateConVar("homicide_setmode","",FCVAR_LUA_SERVER,"")
CreateClientConVar("homicide_get",0,true,true,"show traitors and stuff while you're spectating", 0, 1)

function homicide.IsMapBig()
    local mins,maxs = game.GetWorld():GetModelBounds()
    local skybox = 0
    for i,ent in pairs(ents.FindByClass("sky_camera")) do
        --local skyboxang = ent:GetPos():GetNormalized():Dot(maxs:GetNormalized())
        
        skybox = 0--skyboxang > 0 and ent:GetPos():Distance(-mins) or ent:GetPos():Distance(-maxs)
        --maxs:Sub(skybox)
    end
    
    --PrintMessage(3,tostring(mins:Distance(maxs) - skybox))
    return (mins:Distance(maxs) - skybox) > 5000
    --Vector(-10000, -2000, -2500) Vector(5000, 10000, 800)
end

function homicide.StartRound(data)
    team.SetColor(1,homicide.red[2])

    game.CleanUpMap(false)

    if SERVER then
        local roundType = homicide_setmode:GetInt() == math.random(1,4) or (homicide.IsMapBig() and 1) or false
        homicide.roundType = math.random(1,4)
        --homicide.roundType = roundType or math.random(2,4)
        --soe, standard, gun-free-zone, wild west
        --print(homicide_setmode:GetString(),homicide.roundType)
        net.Start("roundType")
        net.WriteInt(homicide.roundType,4)
        net.Broadcast()
    end

    if CLIENT then
        for i,ply in player.Iterator() do
            ply.roleT = false
            ply.roleCT = false
            ply.countKick = 0
        end

        roundTimeLoot = data.roundTimeLoot

        return
    end

    return homicide.StartRoundSV()
end

if SERVER then return end

local red,blue = Color(200,0,10),Color(75,75,255)
local gray = Color(122,122,122,255)
function homicide.GetTeamName(ply)
    if ply.roleT then return "Traitor",red end
    if ply.roleCT then return "Innocent",blue end

    local teamID = ply:Team()
    if teamID == 1 then
        return "Innocent",ScoreboardSpec
    end
    if teamID == 3 then
        return "Police",blue
    end
end

local black = Color(0,0,0,255)

net.Receive("homicide_roleget",function()
    for i,ply in pairs(player.GetAll()) do ply.roleT = nil ply.roleCT = nil end
    local role = net.ReadTable()

    for i,ply in pairs(role[1]) do ply.roleT = true end
    for i,ply in pairs(role[2]) do ply.roleCT = true end
end)

function homicide.HUDPaint_Spectate(spec)
    --local name,color = homicide.GetTeamName(spec)
    --draw.SimpleText(name,"HomigradFontBig",ScrW() / 2,ScrH() - 150,color,TEXT_ALIGN_CENTER)
end

function homicide.Scoreboard_Status(ply)
    local lply = LocalPlayer()
    if not lply:Alive() or lply:Team() == 1002 then return true end

    return "Unknown",ScoreboardSpec
end

local red,blue = Color(200,0,10),Color(75,75,255)
local roundTypes = {"Shotgun", "Regular Round", "No Firearms Permitted Zone", "Wild West"}
local roundSound = {"snd_jack_hmcd_disaster.mp3","snd_jack_hmcd_shining.mp3","snd_jack_hmcd_panic.mp3","snd_jack_hmcd_wildwest.mp3"}

surface.CreateFont("HomigradRoundFont",{
    font = "Arial", -- On Windows/macOS, use the font-name which is shown to you by your operating system Font Viewer. On Linux, use the file name
	extended = false,
	size = ScreenScale(15),
	weight = 500,
	antialias = true,
})

local DescCT = {
    [1] = "You have been given a shotgun. Kill the traitor before he kills you.", --emergency
    [2] = "You have been given a M9 Beretta with one magazine. Kill the traitor.", --base
    [3] = "You have been given a Taser & Baton. Arrest the traitor to win.", --gunfree
    [4] = "You have been given a revolver identical to the Traitors." --wildwest
}

function homicide.HUDPaint_RoundLeft(white2)
    local roundType = homicide.roundType or 2
    local lply = LocalPlayer()
    local name,color = homicide.GetTeamName(lply)

    local startRound = roundTimeStart + 7 - CurTime()
    if startRound > 0 and lply:Alive() then
        if playsound then
            playsound = false
            surface.PlaySound(roundSound[homicide.roundType])
        end
        lply:ScreenFade(SCREENFADE.IN,Color(0,0,0,220),1,4)


        --[[surface.SetFont("HomigradFontBig")
        surface.SetTextColor(color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255)
        surface.SetTextPos(ScrW() / 2 - 40,ScrH() / 2)

        surface.DrawText("Вы " .. name)]]--
        draw.DrawText( "You are a " .. name, "HomigradRoundFont", ScrW() / 2, ScrH() / 2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( "Homicide", "HomigradRoundFont", ScrW() / 2, ScrH() / 8, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        draw.DrawText( roundTypes[roundType], "HomigradRoundFont", ScrW() / 2, ScrH() / 5, Color( color.r,color.g,color.b ,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )

        if lply.roleT then --Traitor
            if homicide.roundType == 3 then --gunfree
                draw.DrawText( "You have a Crossbow.\nDespite its large size, it is hidden from your character.", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
                --"", "HomigradFontBig", ScrW() / 2, ScrH() / 1.1, Color( 155,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            elseif homicide.roundType == 4 then --wildwest
                draw.DrawText( "You have been given a revolver to take everyone else out.", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.1, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            else --emergency/base
                draw.DrawText( "Kill everyone before the police arrive.", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
            end
        elseif lply.roleCT then --Innocent with a gun
            draw.DrawText( DescCT[homicide.roundType] or "...", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( color.r,color.g,color.b,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        else
            draw.DrawText( "Find the traitor. Tie or Kill him to win.", "HomigradRoundFont", ScrW() / 2, ScrH() / 1.2, Color( 55,55,55,math.Clamp(startRound - 0.5,0,1) * 255 ), TEXT_ALIGN_CENTER )
        end
        return
    end

    local time = math.Round(roundTimeStart + roundTimeLoot - CurTime())
    if time > 0 then
        local acurcetime = string.FormattedTime(time,"%02i:%02i")
        acurcetime = "Police Arrive In: " .. acurcetime -- Нахуя? Это же не видно.

        draw.SimpleText(acurcetime,"HomigradFont",ScrW()/2,ScrH()-25,white,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

    local lply_pos = lply:GetPos()

    for i,ply in player.Iterator() do
        local color = ply.roleT and red or ply.roleCT and blue
        if not color or ply == lply or not ply:Alive() then continue end

        local pos = ply:GetPos() + ply:OBBCenter()
        local dis = lply_pos:Distance(pos)
        if dis > 1024 then continue end

        local pos = pos:ToScreen()
        if not pos.visible then continue end

        color.a = 255 * (1 - dis / 1024)
        --draw.SimpleText(roundTimeStart, "HomigradFont",pos.x,pos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
        --print(roundTimeStart)
        draw.SimpleText("Buddy: "..ply:Nick(),"HomigradFontBig",pos.x,pos.y,color,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end
end

function homicide.VBWHide(ply,wep)
    if (not ply:IsRagdoll() and ply:Team() == 1002) then return end -- t weps hide

    return (wep.IsPistolHoldType and wep:IsPistolHoldType())
end

function homicide.Scoreboard_DrawLast(ply)
    if LocalPlayer():Team() ~= 1002 and LocalPlayer():Alive() then return false end
end

homicide.SupportCenter = true
