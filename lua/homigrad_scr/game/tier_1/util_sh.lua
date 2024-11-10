
gameevent.Listen( "player_spawn" )
hook.Add("player_spawn","player_activatehg",function(data) 
	local ply = Player(data.userid)
	if not IsValid(ply) then return end
	
	hook.Run("Player Activate", ply)

    ply.RenderOverride = function(self)
        local ent = IsValid( self:GetNWEntity("Ragdoll", NULL ) ) and self:GetNWEntity("Ragdoll", NULL ) or self
        local ply = IsValid( self:GetNWEntity("RagdollOwner", NULL)) and self:GetNWEntity("RagdollOwner", NULL) or self
        if ent ~= self then return end
        hook.Run( "HG_PrePlayerDraw", ent, ply )
        hook.Run( "HG_PlayerDraw", ent, ply )
        hook.Run( "HG_PostPlayerDraw", ent, ply )

        self:DrawModel()
    end

    if not PLYSPAWN_OVERRIDE then
        hook.Run("Player Spawn", ply)
    end
end)

hook.Add( "OnEntityCreated", "RagdollRender", function( ent )
    if ent:GetClass() == "prop_ragdoll" then
        ent.RenderOverride = function(self)
            local ent = IsValid( self:GetNWEntity("Ragdoll", NULL ) ) and self:GetNWEntity("Ragdoll", NULL ) or self
            local ply = IsValid( self:GetNWEntity("RagdollOwner", NULL)) and self:GetNWEntity("RagdollOwner", NULL) or self
            if ent ~= self then return end
            hook.Run( "HG_PrePlayerDraw", ent, ply )
            hook.Run( "HG_PlayerDraw", ent, ply )
            hook.Run( "HG_PostPlayerDraw", ent, ply )

            self:DrawModel()
        end
    end
end)

hook.Add("HomigradRun", "RunShit", function()
    local entitis = player.GetAll()
    table.Add(entitis,ents.FindByClass("prop_ragdoll"))

    for k, ply in ipairs(entitis) do
        ply.RenderOverride = function(self)
            local ent = IsValid( self:GetNWEntity("Ragdoll", NULL ) ) and self:GetNWEntity("Ragdoll", NULL ) or self
            local ply = IsValid( self:GetNWEntity("RagdollOwner", NULL)) and self:GetNWEntity("RagdollOwner", NULL) or self
            if ent ~= self then return end
            hook.Run( "HG_PrePlayerDraw", ent, ply )
            hook.Run( "HG_PlayerDraw", ent, ply )
            hook.Run( "HG_PostPlayerDraw", ent, ply )

            self:DrawModel()
        end
    end
end)

gameevent.Listen( "entity_killed" )
hook.Add("entity_killed","player_deathhg",function(data) 
	local ply = Entity(data.entindex_killed)
    local attacker = Entity(data.entindex_attacker)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	
	hook.Run("Player Death", ply, attacker)
end)

local override = {}
net.Receive("Override Spawn", function() override[net.ReadEntity()] = true end)
hook.Add("Player Spawn", "!Override", function(ply)
	if override[ply] then
		override[ply] = nil
		return false
	end
end)

hook.Add("Player Spawn", "zOverride", function(ply)
	if override[ply] then
		override[ply] = nil
		return false
	end
end)

local hull = 10 
local HullMin = -Vector(hull,hull,0)
local Hull = Vector(hull,hull,72)
local HullDuck = Vector(hull,hull,36)

hook.Add("Player Activate","SetHull",function(ply)
	ply:SetHull(ply:GetNWVector("HullMin",HullMin) or HullMin,ply:GetNWVector("Hull",Hull) or Hull)
	ply:SetHullDuck(ply:GetNWVector("HullMin",HullMin) or HullMin,ply:GetNWVector("HullDuck",HullDuck) or HullDuck)
	ply:SetViewOffset(Vector(0,0,64))
	ply:SetViewOffsetDucked(Vector(0,0,38))
    ply:SetMoveType(MOVETYPE_WALK)
    ply:DrawShadow(true)
    ply:SetRenderMode(RENDERMODE_NORMAL)

    if SERVER then
        ply:SetSolidFlags(bit.band(ply:GetSolidFlags(),bit.bnot(FSOLID_NOT_SOLID)))
        ply:SetNWEntity("ragdollWeapon", NULL)
        ply:SetNWEntity("ActiveWeapon", NULL)
    end

    timer.Simple(0,function()
        local ang = ply:EyeAngles()
        if ang[3] == 180 then
            ang[2] = ang[2] + 180
        end
        ang[3] = 0
        ply:SetEyeAngles(ang)
    end)

    if SERVER then
        hg.send(nil,ply,true)
    end
end)

hook.Add("Player Death","SetHull",function(ply, attacker)
    timer.Simple(0,function()
        local ang = ply:EyeAngles()
        if ang[3] == 180 then
            ang[2] = ang[2] + 180
        end
        ang[3] = 0
        ply:SetEyeAngles(ang)
    end)
end)

if CLIENT then
    hook.Add("EntityNetworkedVarChanged", "newfakeentity", function(ply, name, oldval, rag)
        --print(ply,name,oldval,rag)
        --[[if name == "Ragdoll" then
            ply.FakeRagdoll = rag
            if IsValid(rag) then
                hook.Run("Fake", "faked", ply, rag)
            end
        end--]]
    end)
end

if CLIENT then
    hook.Add("NetworkEntityCreated","huyhuy",function(ent)
        if not ent:IsRagdoll() then return end
        timer.Simple(LocalPlayer():Ping() / 100 + 0.1,function()
            if not IsValid(ent) then return end
            if IsValid(ent:GetNWEntity("RagdollOwner")) then
                hook.Run("Fake",ent:GetNWEntity("RagdollOwner"),ent)
            end
        end)
    end)
end

hook.Add("Fake","faked",function(ply, rag)
    ply:SetHull(-Vector(1,1,1),Vector(1,1,1))
	ply:SetHullDuck(-Vector(1,1,1),Vector(1,1,1))
    ply:SetViewOffset(Vector(0,0,0))
    ply:SetViewOffsetDucked(Vector(0,0,0))
    ply:SetMoveType(MOVETYPE_NONE)
end)

-- PewPaws!!!
game.AddParticles("particles/muzzleflashes_test.pcf")
game.AddParticles("particles/muzzleflashes_test_b.pcf")
game.AddParticles("particles/pcfs_jack_muzzelflashes.pcf")
game.AddParticles("particles/ar2_muzzle.pcf")

local huyprecahche = {
    "muzzleflash_SR25",
    "pcf_jack_mf_tpistol",
    "pcf_jack_mf_mshotgun",
    "pcf_jack_mf_msmg",
    "pcf_jack_mf_spistol",
    "pcf_jack_mf_mrifle2",
    "pcf_jack_mf_mrifle1",
    "pcf_jack_mf_mpistol",
    "pcf_jack_mf_suppressed",
    "muzzleflash_pistol_rbull",
    "muzzleflash_m24",
    "muzzleflash_m79",
    "muzzleflash_M3",
    "muzzleflash_m14",
    "muzzleflash_g3",
    "muzzleflash_FAMAS",
    "muzzleflash_ak74",
    "muzzleflash_ak47",
    "muzzleflash_mp5",
    "muzzleflash_suppressed",
    "muzzleflash_MINIMI",
    "muzzleflash_svd",
    "new_ar2_muzzle"
}
for k,v in ipairs(huyprecahche) do
    PrecacheParticleSystem(v)
end


-- CAAABOOOOMS!

game.AddParticles("particles/pcfs_jack_explosions_large.pcf")
game.AddParticles("particles/pcfs_jack_explosions_medium.pcf")
game.AddParticles("particles/pcfs_jack_explosions_small.pcf")
game.AddParticles("particles/pcfs_jack_nuclear_explosions.pcf")
game.AddParticles("particles/pcfs_jack_moab.pcf")
game.AddParticles("particles/gb5_large_explosion.pcf")
game.AddParticles("particles/gb5_500lb.pcf")
game.AddParticles("particles/gb5_100lb.pcf")
game.AddParticles("particles/gb5_50lb.pcf")
game.AddParticles("particles/pcfs_jack_muzzelflashes.pcf")
game.AddParticles("particles/pcfs_jack_explosions_incendiary2.pcf")
game.AddParticles("particles/lighter.pcf")

PrecacheParticleSystem("Lighter_flame")
PrecacheParticleSystem("pcf_jack_nuke_ground")
PrecacheParticleSystem("pcf_jack_nuke_air")
PrecacheParticleSystem("pcf_jack_moab")
PrecacheParticleSystem("pcf_jack_moab_air")
PrecacheParticleSystem("cloudmaker_air")
PrecacheParticleSystem("cloudmaker_ground")
PrecacheParticleSystem("500lb_air")
PrecacheParticleSystem("500lb_ground")
PrecacheParticleSystem("100lb_air")
PrecacheParticleSystem("100lb_ground")
PrecacheParticleSystem("50lb_air")
PrecacheParticleSystem("pcf_jack_incendiary_ground_sm2")
PrecacheParticleSystem("pcf_jack_groundsplode_small3")
PrecacheParticleSystem("pcf_jack_smokebomb3")
PrecacheParticleSystem("pcf_jack_groundsplode_medium")
PrecacheParticleSystem("pcf_jack_groundsplode_large")
PrecacheParticleSystem("pcf_jack_airsplode_medium")