--[[
    TO-DO: 
    - Networking of saved data on client
    - Applying appearance
]]

util.AddNetworkString("EasyAppearance_SendData")
util.AddNetworkString("EasyAppearance_SendReqData")

EasyAppearance = EasyAppearance or {}

net.Receive( "EasyAppearance_SendData", function( len, ply ) 

    ply.bRandomAppearance = net.ReadBool()
    ply.tAppearance = net.ReadTable()

end)

--[[
local tDefaultAppearance = {
    strModel = "Male 01",
    strColthesStyle = "Casual 1"
}
--]]

function EasyAppearance.GetRandomAppearance()
    local tRandomAppearance = {}

    tRandomAppearance.strModel = table.Random( table.GetKeys( EasyAppearance.Models ) )
    tRandomAppearance.strColthesStyle = "Random"
    
    return tRandomAppearance
end

function EasyAppearance.SetAppearance( ply )

    if ply.bRandomAppearance then
        
    end
    
end