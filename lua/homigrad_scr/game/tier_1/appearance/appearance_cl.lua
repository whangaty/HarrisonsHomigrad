--[[
    TO-DO: 
    - Appearance menu like hmcd
    - Networking :/    
]]

EasyAppearance = EasyAppearance or {}

function EasyAppearance.Menu( ply )

end

function EasyAppearance.SendNet( bRandom, tAppearanceData )

    net.Start( "EasyAppearance_SendData" )
        net.WriteBool( bRandom or false )
        net.WriteTable( tAppearanceData )
    net.SendToServer()

end

function EasyAppearance.SaveData( tAppearanceData )

    if not file.Exists( "homigrad", "DATA" ) then file.CreateDir( "homigrad" ) end

    file.Write( "homigrad/AppearanceData.json", util.TableToJSON( tAppearanceData, true ) )

end

function EasyAppearance.GetData( bForceRandom )

    if not file.Exists( "homigrad", "DATA" ) then file.CreateDir( "homigrad" ) end
    if bForceRandom then return true end
    if not file.Exists( "homigrad/AppearanceData.json", "DATA" ) then return true end

    local tAppearanceData = util.JSONToTable( file.Read( "homigrad/AppearanceData.json", "DATA" ) )
    return false, tAppearanceData

end

// -- Net Recives

local cvrForceRandom = CreateClientConVar( "hg_random_appearance", 0, true, false, "", 0, 1 )

net.Receive( "EasyAppearance_SendReqData", function()

    local bRandom, tAppearanceData = EasyAppearance.GetData( cvrForceRandom:GetBool() )
    EasyAppearance.SendNet( bRandom, tAppearanceData or {} )
    
end)