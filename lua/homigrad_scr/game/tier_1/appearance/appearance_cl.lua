--[[
    TO-DO: 
    - Appearance menu like hmcd
    - Networking :/    
]]

EasyAppearance = EasyAppearance or {}

EasyAppearance.OpenedMenu = EasyAppearance.OpenedMenu or nil


--[[
    local Models = {
    // Male
    ["Male 01"] = {strPatch = "models/player/group01/male_01.mdl", intSubMat = 3 },
    ["Male 02"] = {strPatch = "models/player/group01/male_02.mdl", intSubMat = 2 },
    ["Male 03"] = {strPatch = "models/player/group01/male_03.mdl", intSubMat = 4 },
    ["Male 04"] = {strPatch = "models/player/group01/male_04.mdl", intSubMat = 4 },
    ["Male 05"] = {strPatch = "models/player/group01/male_05.mdl", intSubMat = 4 },
    ["Male 06"] = {strPatch = "models/player/group01/male_06.mdl", intSubMat = 0 },
    ["Male 07"] = {strPatch = "models/player/group01/male_07.mdl", intSubMat = 4 },
    ["Male 08"] = {strPatch = "models/player/group01/male_08.mdl", intSubMat = 0 },
    ["Male 09"] = {strPatch = "models/player/group01/male_09.mdl", intSubMat = 2 },
    // Female
    ["Female 01"] = {strPatch = "models/player/group01/female_01.mdl", intSubMat = 2 },
    ["Female 02"] = {strPatch = "models/player/group01/female_02.mdl", intSubMat = 3 },
    ["Female 03"] = {strPatch = "models/player/group01/female_03.mdl", intSubMat = 3 },
    ["Female 04"] = {strPatch = "models/player/group01/female_04.mdl", intSubMat = 1 },
    ["Female 05"] = {strPatch = "models/player/group01/female_05.mdl", intSubMat = 2 },
    ["Female 06"] = {strPatch = "models/player/group01/female_06.mdl", intSubMat = 4 },
}
--]]

local Models = {
    // Male
    ["models/player/group01/male_01.mdl"] = {1,3},
    ["models/player/group01/male_02.mdl"] = {1,2},
    ["models/player/group01/male_03.mdl"] = {1,4},
    ["models/player/group01/male_04.mdl"] = {1,4},
    ["models/player/group01/male_05.mdl"] = {1,4},
    ["models/player/group01/male_06.mdl"] = {1,0},
    ["models/player/group01/male_07.mdl"] = {1,4},
    ["models/player/group01/male_08.mdl"] = {1,0},
    ["models/player/group01/male_09.mdl"] = {1,2},
    // Female
    ["models/player/group01/female_01.mdl"] = {2,2},
    ["models/player/group01/female_02.mdl"] = {2,3},
    ["models/player/group01/female_03.mdl"] = {2,3},
    ["models/player/group01/female_04.mdl"] = {2,1},
    ["models/player/group01/female_05.mdl"] = {2,2},
    ["models/player/group01/female_06.mdl"] = {2,4},
}

function EasyAppearance.Menu( ply )
    if IsValid(EasyAppearance.OpenedMenu) then
        EasyAppearance.OpenedMenu:Remove()
        EasyAppearance.OpenedMenu = nil
    end

    local _, Appearance = EasyAppearance.GetData()
    Appearance = Appearance or {}
    EasyAppearance.OpenedMenu = vgui.Create("DFrame")
    local MainPanel = EasyAppearance.OpenedMenu
    MainPanel:SetSize(512,512)
    MainPanel:Center()
    MainPanel:MakePopup()
    MainPanel:SetTitle( "Appearance Menu" )

    MainPanel.ModelView = vgui.Create("DModelPanel",MainPanel)
    local ModelView = MainPanel.ModelView
    ModelView:Dock(LEFT)
    ModelView:SetSize(256,512)
    
    local tModel = EasyAppearance.Models[ Appearance.strModel ]
    local sex = "Male"
    ModelView:SetModel( tModel and tModel.strPatch or table.Random( table.GetKeys(Models) ) )
    function ModelView:LayoutEntity(ent) 
        ent:SetSubMaterial()

        sex = EasyAppearance.Sex[ ent:GetModelSex() ]

        ent:SetSubMaterial( Models[ ent:GetModel() ][2], Appearance.strColthesStyle and EasyAppearance.Appearances[ sex ][ Appearance.strColthesStyle ] or "" )

        return 
    end

    ModelView:SetFOV(37.5)

    MainPanel.RightPanel = vgui.Create("DPanel",MainPanel)
    local DPanel = MainPanel.RightPanel
    DPanel:Dock(FILL)

    DPanel.ComboMdlBox = vgui.Create("DComboBox",DPanel)
    local CombMdlBox = DPanel.ComboMdlBox
    CombMdlBox:Dock(TOP)
    CombMdlBox:DockMargin(15,10,15,0)

    for k,v in pairs( EasyAppearance.Models ) do
        CombMdlBox:AddChoice( k, v.strPatch )
    end

    function CombMdlBox:OnSelect( index, text, data )
        ModelView:SetModel( data )
        Appearance.strModel = text
        timer.Simple(0.1,function()
            DPanel.ComboApperBox:Clear()
            for k,v in pairs( EasyAppearance.Appearances[sex] ) do
                DPanel.ComboApperBox:AddChoice( k, k )
            end
        end)
    end

    DPanel.ComboApperBox = vgui.Create("DComboBox",DPanel)
    local CombApperBox = DPanel.ComboApperBox
    CombApperBox:Dock(TOP)
    CombApperBox:DockMargin(15,10,15,0)

    for k,v in pairs( EasyAppearance.Appearances[sex] ) do
        CombApperBox:AddChoice( k, k )
    end

    function CombApperBox:OnSelect( index, text, data )
        Appearance.strColthesStyle = text
    end

    DPanel.ApplyButton = vgui.Create( "DButton", DPanel )
    local AplyBtn = DPanel.ApplyButton
    AplyBtn:Dock( BOTTOM )
    AplyBtn:SetText( "Apply appearance" )

    function AplyBtn:DoClick()
        if not Appearance.strColthesStyle or not Appearance.strModel then LocalPlayer():PrintMessage(HUD_PRINTTALK,"Not valid.") return false end
        EasyAppearance.SaveData( Appearance )
        MainPanel:Close()
    end

end

concommand.Add("hg_appearance_menu",function()
    EasyAppearance.Menu( LocalPlayer() )
end)

function EasyAppearance.SendNet( bRandom, tAppearanceData )

    net.Start( "EasyAppearance_SendData" )
        net.WriteBool( bRandom or false )
        net.WriteTable( tAppearanceData )
    net.SendToServer()

end

function EasyAppearance.SaveData( tAppearanceData )

    if not file.Exists( "homigrad", "DATA" ) then file.CreateDir( "homigrad" ) end

    file.Write( "homigrad/appearancedata.json", util.TableToJSON( tAppearanceData, true ) )

end

function EasyAppearance.GetData( bForceRandom )

    if not file.Exists( "homigrad", "DATA" ) then file.CreateDir( "homigrad" ) end
    if bForceRandom then return true end
    if not file.Exists( "homigrad/appearancedata.json", "DATA" ) then return true end

    local tAppearanceData = util.JSONToTable( file.Read( "homigrad/appearancedata.json", "DATA" ) )
    return false, tAppearanceData

end

// -- Net Recives

local cvrForceRandom = CreateClientConVar( "hg_random_appearance", 0, true, false, "", 0, 1 )

net.Receive( "EasyAppearance_SendReqData", function()

    local bRandom, tAppearanceData = EasyAppearance.GetData( cvrForceRandom:GetBool() )
    --print(tAppearanceData)
    EasyAppearance.SendNet( bRandom, tAppearanceData or {} )
    --PrintTable(tAppearanceData)
end)