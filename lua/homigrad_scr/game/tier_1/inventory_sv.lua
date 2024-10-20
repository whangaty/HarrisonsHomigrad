if not engine.ActiveGamemode() == "homigrad" then return end
util.AddNetworkString("inventory")
util.AddNetworkString("ply_take_item")
util.AddNetworkString("ply_take_ammo")

local function send(ply,lootEnt,remove)
	if ply then
		net.Start("inventory")
		net.WriteEntity(not remove and lootEnt or nil)
		net.WriteTable(lootEnt.Info.Weapons)
		net.WriteTable(lootEnt.Info.Ammo)
		net.Send(ply)
	else
		for ply in pairs(lootEnt.UsersInventory) do
			if not IsValid(ply) or not ply:Alive() or remove then lootEnt.UsersInventory[ply] = nil continue end

			send(ply,lootEnt,remove)
		end
	end
end

hook.Add("PlayerSpawn","!!!huyassdd",function(lootEnt)
	if lootEnt.UsersInventory ~= nil then
		for plys,bool in pairs(lootEnt.UsersInventory) do
			lootEnt.UsersInventory[plys] = nil
			send(plys,lootEnt,true)
		end
	end
end)

hook.Add("Player Think","Looting",function(ply)
	local key = ply:KeyDown(IN_USE)

	if not IsValid(ply.FakeRagdoll) and ply:Alive() and ply:KeyDown(IN_ATTACK2) then
		if ply.okeloot ~= key and key then
			local tr = {}
			tr.start = ply:GetAttachment(ply:LookupAttachment("eyes")).Pos
			tr.endpos = tr.start + ply:EyeAngles():Forward() * 64
			tr.filter = ply
			local tracea = util.TraceLine(tr)
			local hitEnt = tracea.Entity

			if not IsValid(hitEnt) then return end
			if IsValid(RagdollOwner(hitEnt)) then hitEnt = RagdollOwner(hitEnt) end
			if IsValid(hitEnt) and hitEnt.IsJModArmor then hitEnt = hitEnt.Owner end
			if not IsValid(hitEnt) then return end
			if hitEnt:IsPlayer() and hitEnt:Alive() and not IsValid(hitEnt.FakeRagdoll) then return end
			SavePlyInfo(hitEnt)
			if not hitEnt.Info then return end
			
			hitEnt.UsersInventory = hitEnt.UsersInventory or {}
			hitEnt.UsersInventory[ply] = true

			send(ply,hitEnt)
			hitEnt:CallOnRemove("fuckoff",function() send(nil,hitEnt,true) end)
		end
	end

	ply.okeloot = key
end)

local prekol = {
	weapon_physgun = true,
	gmod_tool = true
}

net.Receive("inventory",function(len,ply)
	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end

	lootEnt.UsersInventory[ply] = nil
	player.Event(ply,"inventory close",lootEnt)
end)

hook.Add("DoPlayerDeath","huyhuy",function(ply)
	local info = SavePlyInfo(ply)

	ply.weps = {}

	local actwep = ply:GetActiveWeapon()
	
	actwep = IsValid(actwep) and actwep:GetClass() or IsValid(ply.ActiveWeapon) and ply.ActiveWeapon:GetClass()
	for class, wep in pairs(info.Weapons) do
		local tbl = wep:GetTable()

		local ent = ents.Create(class)
		ent:SetPos(ply:GetPos() + vector_up * 10)

		local clip1 = wep:Clip1()
		timer.Simple(0.1,function()
			local rag = ply:GetNWEntity("Ragdoll",ply.FakeRagdoll)
			ent:SetClip1(clip1)
			ent:SetTable(tbl)
			ent:SetOwner(rag)
			ent:SetParent(rag, 0)
			ent:SetRenderMode(RENDERMODE_NONE)
		end)

		ent:Spawn()
		ent:SetRenderMode(RENDERMODE_NONE)
		--ent:SetNoDraw(true)
		ent:DrawShadow(false)
		ent:SetSolidFlags(FSOLID_NOT_SOLID)

		if IsValid(wep) then wep:Remove() end
		ply.weps[class] = ent
	end

	timer.Simple(0.1,function()
		local rag = ply:GetNWEntity("Ragdoll",ply.FakeRagdoll)
		if IsValid(rag) then
			rag.Info = rag.Info or {}
			if ply.weps then
				rag.Info.Weapons = ply.weps
				rag.ActiveWeapon = ply.weps[actwep]
			end
			ply.weps = nil
		end
	end)
end)

net.Receive("ply_take_item",function(len,ply)
	--if ply:Team() ~= 1002 then return end

	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end

	local weapon = net.ReadEntity()
	local wep = weapon:GetClass()

	local lootInfo = lootEnt.Info
	local wepInfo = lootInfo.Weapons[wep]
	
	if not wepInfo then return end
	
	if prekol[wep] and not ply:IsAdmin() then ply:Kick("You have been kicked. Error Code: AT6001") return end

	if ply:HasWeapon(wep) then
		if lootEnt:IsPlayer() and (lootEnt.ActiveWeapon == weapon and not lootEnt.unconscious) then return end
		if weapon:Clip1() > 0 then
			ply:GiveAmmo(weapon:Clip1(),weapon:GetPrimaryAmmoType())
			weapon:SetClip1(0)
		else
			ply:ChatPrint("You already have this weapon.")
		end
	else
		if lootEnt:IsPlayer() and (lootEnt.ActiveWeapon == weapon and not lootEnt.unconscious) then return end
		
		if lootEnt:IsPlayer() then lootEnt:DropWeapon(weapon) end
		ply:PickupWeapon(weapon)

		weapon:SetRenderMode(RENDERMODE_NORMAL)
		weapon:DrawShadow(true)
		--weapon:SetSolidFlags(FSOLID_)

		lootInfo.Weapons[wep] = nil
		
		if lootEnt.ActiveWeapon == weapon then
			DespawnWeapon(lootEnt)
		end
	end

	send(nil,lootEnt)
end)

net.Receive("ply_take_ammo",function(len,ply)
	--if ply:Team() ~= 1002 then return end

	local lootEnt = net.ReadEntity()
	if not IsValid(lootEnt) then return end
	local ammo = net.ReadFloat()
	local lootInfo = lootEnt.Info
	if not lootInfo.Ammo[ammo] then return end

	ply:GiveAmmo(lootInfo.Ammo[ammo],ammo)

	if lootEnt:IsPlayer() then
		lootEnt:SetAmmo(0,ammo)
	end

	lootInfo.Ammo[ammo] = nil

	send(nil,lootEnt)
end)