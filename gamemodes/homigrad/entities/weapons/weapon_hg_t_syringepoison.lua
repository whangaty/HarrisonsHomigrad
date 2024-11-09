SWEP.Base = "medkit"

SWEP.PrintName = "Biotoxin Syringe"
SWEP.Author = "Homigrad"
SWEP.Instructions = "A powerful & lethal sedative.\nInjecting into a spine is quiet, injecting elsewhere is loud."

SWEP.Spawnable = true
SWEP.Category = "Traitor Tools"

SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.ViewModel = "models/weapons/w_models/w_jyringe_proj.mdl"
SWEP.WorldModel = "models/weapons/w_models/w_jyringe_proj.mdl"
SWEP.HoldType = "normal"

SWEP.dwsPos = Vector(7,7,7)
SWEP.dwsItemPos = Vector(2,0,2)

SWEP.dwmModeScale = 0.5
SWEP.dwmForward = 3
SWEP.dwmRight = 1
SWEP.dwmUp = 0

SWEP.dwmAUp = 0
SWEP.dwmARight = 90
SWEP.dwmAForward = 0

local injectsound = Sound("Underwater.BulletImpact")

local function eyeTrace(ply)
    local att1 = ply:LookupAttachment("eyes")

    if not att1 then return end

    local att = ply:GetAttachment(att1)

    if not att then return end

    local tr = {}
    tr.start = att.Pos
    tr.endpos = tr.start + ply:EyeAngles():Forward() * 50
    tr.filter = ply

    return util.TraceLine(tr)
end

function SWEP:Initialize()
	self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    if CLIENT then return end

    local ent = eyeTrace(self:GetOwner()).Entity
    local ply = ent:IsPlayer() and ent or RagdollOwner(ent)

    if not ply then return end

    self:Poison(ply)
end

function SWEP:SecondaryAttack() end

if SERVER then

    function SWEP:Poison(ent)

        local entreal = ent.FakeRagdoll or ent

        local bone = entreal:LookupBone("ValveBiped.Bip01_Spine4")

        if not bone then return end

        local matrix = entreal:GetBoneMatrix(bone)

        if not matrix then return end

        local trace = eyeTrace(self:GetOwner())
        local tracePos = trace.HitPos
        local traceDir = trace.HitPos - trace.StartPos
        traceDir:Normalize()
        traceDir:Mul(4)

        if not tracePos or not traceDir then return end 

        local ang = matrix:GetAngles()
        local pos = matrix:GetTranslation()

        local huy = util.IntersectRayWithOBB(tracePos,traceDir, pos, ang, Vector(-8,-1,-1),Vector(2,0,1))



        local bone = entreal:LookupBone("ValveBiped.Bip01_Spine1")

        if not bone then return end

        local matrix = entreal:GetBoneMatrix(bone)

        if not matrix then return end

        local ang = matrix:GetAngles()
        local pos = matrix:GetTranslation()
        local huy2 = util.IntersectRayWithOBB(tracePos,traceDir, pos, ang, Vector(-8,-3,-1),Vector(2,-2,1))

    

        if not huy then
            if not huy2 then
                self:GetOwner():EmitSound(injectsound)
                ent:EmitSound("vo/npc/male01/pain0"..math.random(1,5)..".wav",60)
            end
        end

        ent.poisoned = true
        ent.poisonbro = self:GetOwner()
        timer.Create("Cyanid"..ent:EntIndex().."1", 30, 1, function()
            if ent:Alive() and ent.poisoned then
                ent:EmitSound("vo/npc/male01/moan0"..math.random(1,5)..".wav",60)
            end

            timer.Create( "Cyanid"..ent:EntIndex().."2", 10, 1, function()
                if ent:Alive() and ent.poisoned then
                    ent:EmitSound("vo/npc/male01/moan0"..math.random(1,5)..".wav",60)
                end
            end)

            timer.Create( "Cyanid"..ent:EntIndex().."3", 15, 1, function()
                if ent:Alive() and ent.poisoned then
                    ent.KillReason = "poison"
                    --ent:Kill()
                    ent.nohook = true
                    ent:TakeDamage(10000,ent.poisonbro)
                    ent.nohook = nil
                end
            end)
        end)

        self:GetOwner():EmitSound("snd_jack_hmcd_needleprick.wav",30)
        self:Remove()
        self:GetOwner():SelectWeapon("weapon_hands")
        return false
    end


    function SWEP:Think()
        
    end

else

    function SWEP:DrawHUD()
        local owner = self:GetOwner()
        local traceResult = eyeTrace(owner)
        local ent = traceResult.Entity

        if not IsValid(ent) then return end

        local bone = ent:LookupBone("ValveBiped.Bip01_Spine4")

        if not bone then return end

        local matrix = ent:GetBoneMatrix(bone)

        if not matrix then return end

        local trace = eyeTrace(self:GetOwner())
        local tracePos = trace.HitPos
        local traceDir = trace.HitPos - trace.StartPos
        traceDir:Normalize()
        traceDir:Mul(4)

        if not tracePos or not traceDir then return end 

        local ang = matrix:GetAngles()
        local pos = matrix:GetTranslation()

        local huy = util.IntersectRayWithOBB(tracePos,traceDir, pos, ang, Vector(-8,-1,-1),Vector(2,0,1))


        local bone = ent:LookupBone("ValveBiped.Bip01_Spine1")

        if not bone then return end

        local matrix = ent:GetBoneMatrix(bone)

        if not matrix then return end

        local ang = matrix:GetAngles()
        local pos = matrix:GetTranslation()
        local huy2 = util.IntersectRayWithOBB(tracePos,traceDir, pos, ang, Vector(-8,-3,-1),Vector(2,-2,1))

        local hitEnt = (huy or huy2) and 0 or 1

        
        local loudText = "Inject Poison (Loud)"
        local quietText = "Quietly Inject Poison"

        local loudColor = Color(255,0,0,255)
        local quietColor = Color(255,255,255,255)

        local frac = traceResult.Fraction
        
                if huy2 then
            debugoverlay.BoxAngles(
                    pos,                             -- Position of the OBB (origin point)
                    Vector(-8, -1, -1),              -- Minimum bounds of the OBB
                    Vector(2, 0, 1),                 -- Maximum bounds of the OBB
                    ang,                             -- Orientation of the OBB
                    0.01,                            -- Duration (how long to show the box)
                    Color(125, 255, 0)                 -- Green color for intersection
                )
        else
                debugoverlay.BoxAngles(
                    pos,
                    Vector(-8, -1, -1),
                    Vector(2, 0, 1),
                    ang,
                    0.01,
                    Color(255, 125, 0)                 -- Red color for no intersection
                )
        end


        if huy or huy2 then
            draw.DrawText(not tobool(hitEnt) and quietText or "","TargetID",traceResult.HitPos:ToScreen().x,traceResult.HitPos:ToScreen().y - 40,color_white,TEXT_ALIGN_CENTER)
            surface.SetDrawColor(quietColor)
        else
            surface.SetDrawColor(loudColor)
            draw.DrawText(loudText or "","TargetID",traceResult.HitPos:ToScreen().x,traceResult.HitPos:ToScreen().y - 40,color_red,TEXT_ALIGN_CENTER)
        end

        draw.NoTexture()
        Circle(traceResult.HitPos:ToScreen().x, traceResult.HitPos:ToScreen().y, 5 / frac, 32)
    end
end