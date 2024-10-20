if engine.ActiveGamemode() == "homigrad" then
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
include("weps.lua")


function ENT:Initialize()
	self:SetUseType( SIMPLE_USE )
	local ply = self:GetOwner()

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if(IsValid(phys))then
		phys:Wake()
		--phys:SetMass(150)
	end

	self:GetOwner().wep = self

end

function ENT:Clip1()
	local ply = self:GetOwner()
	self.Clip1 = IsValid(lootInfo.Weapons[self.Class]) and lootInfo.Weapons[self.Class]:Clip1() or self.Clip1 or 0

	return self.Clip1
end

function ENT:SetClip1(val)
	local ply = self:GetOwner()

	if IsValid(lootInfo.Weapons[self.Class]) then
		lootInfo.Weapons[self.Class]:SetClip1(val)
	end
end

function ENT:GetPrimaryAmmoType()
	local ply = self:GetOwner()
	self.AmmoType = IsValid(lootInfo.Weapons[self.Class]) and lootInfo.Weapons[self.Class]:GetPrimaryAmmoType() or self.AmmoType or weapons.Get(self.Class):GetPrimaryAmmoType()

	return self.AmmoType
end

function ENT:Use(taker)
	local ply = self:GetOwner()
	local phys = self:GetPhysicsObject()

	SavePlyInfo(ply)

	local lootInfo = IsValid(ply) and ply.Info
	if (ply.Otrub or not ply:IsPlayer() or not ply:Alive()) then
		local rag = self.rag
		
		if taker:HasWeapon(self.Class) then
			if lootInfo then
				taker:GiveAmmo(self:Clip1(), lootInfo.Weapons[self.Class]:GetPrimaryAmmoType())
				lootInfo.Weapons[self.Class]:SetClip1(0)
			end
		else
			self:Remove()
			lootInfo.Weapons[self.Class]:SetOwner(taker)
			if lootInfo then lootInfo.Weapons[self.Class] = nil end
			if IsValid(ply) and ply:IsPlayer() then ply:StripWeapon(self.Class) end
		end

		if self:Clip1() == 0 then
			if self:IsPlayerHolding() then
				taker:DropObject()
			else
				taker:PickupObject(self)
			end
		end
	end

end end