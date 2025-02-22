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

        ent:SetupBones()
        ent:SetSubMaterial( Models[ ent:GetModel() ][2], Appearance.strColthesStyle and EasyAppearance.Appearances[ sex ][ Appearance.strColthesStyle ] or "" )
        --EasyAppearance.DrawAttachment(ent,Appearance.strAttachmets)
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

    DPanel.CombAttBox = vgui.Create("DComboBox",DPanel)
    local CombAttBox = DPanel.CombAttBox
    CombAttBox:Dock(TOP)
    CombAttBox:DockMargin(15,10,15,0)

    for k,v in pairs( EasyAppearance.Attachmets ) do
        CombAttBox:AddChoice( k, k )
    end
--[[]
    function CombAttBox:OnSelect( index, text, data )
        Appearance.strAttachmets = text
    end
]]
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
    local ply = LocalPlayer()

    if ply:IsUserGroup() ~= "user" and ply:IsUserGroup() ~= "regular" then
        EasyAppearance.Menu( LocalPlayer() )
    else
        ply:ChatPrint("The appearence menu is donator only!")
    end
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

    --SaveData() should call SendNet(). W/o this - Old skins/mdls are the same as the new for the host - Niik
	EasyAppearance.SendNet(bRandom, tAppearanceData or {})
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

--self:SetNWEntity("Ragdoll", rag )

local hg_appearance_dis = CreateClientConVar("hg_appearance_dis","6000",true,false)

--[[
    ["HatExample"] = {
        strModel = strModel,
        strMaterial = strMaterial,
        strBone = strBone,
        vPos = vPos or Vector( 0, 0, 0 ),
        vFPos = vFPos or Vector( 0, 0, 0 ),
        aAng = aAng or Angle( 0, 0, 0 ),
        aFAng = aFAng or Angle( 0, 0, 0 ),
        iSkin = iSkin or 0,
        strBodyGroups = strBodyGroups or "0000000"
    }
--]]

function EasyAppearance.DrawAttachment( eEnt, strAtt, ply )

    local att = EasyAppearance.Attachmets[strAtt]
    local firstPerson = DRAWMODEL

    if not IsValid(eEnt) or not att then return end

    local iBone = eEnt:LookupBone( att.strBone )
    if not iBone then return end

    local matrix = eEnt:GetBoneMatrix( iBone )
    if not matrix then return end
    
    if eEnt:GetManipulateBoneScale( iBone ):IsZero() then return end

    local pos = matrix:GetTranslation()
    local ang = matrix:GetAngles()

    local modelSex = eEnt:GetModelSex()

    if not IsValid(eEnt.AttachModel) then
        eEnt.AttachModel = ClientsideModel( att.strModel )
        eEnt:CallOnRemove("RemoveAttach",function()
            eEnt.AttachModel:Remove()
        end)

        eEnt.AttachModel:SetNoDraw( true )
        if att.strMaterial then
            eEnt.AttachModel:SetMaterial( att.strMaterial )
        end
        if att.iSkin then
            eEnt.AttachModel:SetSkin( att.iSkin )
        end

        eEnt.AttachModel:AddEffects( EF_BONEMERGE )
        --eEnt.AttachModel:AddEffects( EF_FOLLOWBONE )  
    elseif IsValid(eEnt.AttachModel) then
        --if not IsValid(eEnt.AttachModel) then eEnt.AttachModel = nil return end
        if IsValid(eEnt.AttachModel) and eEnt.AttachModel:GetModel() ~= att.strModel then
            eEnt.AttachModel:SetModel(att.strModel)
        end
        
        if att.bDrawOnLocal or GetViewEntity() != ply then
            local lPos,lAng = LocalToWorld( modelSex > 1 and att.vFPos or att.vPos, modelSex > 1 and att.aFAng or att.aAng, pos, ang)
            --eEnt.AttachModel:SetPos( lPos )
            eEnt.AttachModel:SetParent( eEnt, iBone )

            eEnt.AttachModel:SetRenderOrigin( lPos )
            eEnt.AttachModel:SetRenderAngles( lAng )
            eEnt.AttachModel:SetupBones()
            eEnt.AttachModel:DrawModel()
            
        end
    end 

end

hook.Add( "HG_PostPlayerDraw", "EA_AttachmentsRender", function( ent, ply ) 
    local lply = LocalPlayer()
    local firstPerson = DRAWMODEL

    local cameraPos = EyePos()
    local dis = hg_appearance_dis:GetInt()

    local Attachmets = ent:GetNWString("EA_Attachments",nil)
    if Attachmets == nil then return end
    ent:SetupBones()
    EasyAppearance.DrawAttachment(ent,Attachmets,ply)
    --print(ent,ply)
end)