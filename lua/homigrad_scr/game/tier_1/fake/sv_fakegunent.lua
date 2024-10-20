if engine.ActiveGamemode() != "homigrad" then return end

function SpawnWeapon(ply)
	local weapon = ply.ActiveWeapon
	
	DespawnWeapon(ply)

	if IsValid(weapon) and ishgweapon(weapon) then
		local rag = ply:GetNWEntity("Ragdoll")
		
		if IsValid(rag) then
			local wep = ents.Create("prop_physics")
			ply.wep = wep
			
			wep.Class = ply.ActiveWeapon

			wep:SetModel(weapon.WorldModel)

			wep:SetOwner(ply)
			wep:SetCollisionGroup(COLLISION_GROUP_WEAPON)

			local rh = rag:GetBoneMatrix(rag:LookupBone("ValveBiped.Bip01_R_Hand"))
			local pos,ang = rh:GetTranslation(),rh:GetAngles()

			wep:SetPos(pos)
			wep:SetAngles(ang)

			local rh_wep = wep:GetBoneMatrix(wep:LookupBone("ValveBiped.Bip01_R_Hand") or 0)
			local newmat = rh_wep:GetInverse() * rh
			
			local pos,ang = LocalToWorld(newmat:GetTranslation(),newmat:GetAngles(),pos,ang)

			wep:SetPos(pos)
			wep:SetAngles(ang)
			
			wep:Spawn()
			
			if IsValid(ply.WepCons) then ply.WepCons:Remove() ply.WepCons = nil end
			
			local cons = constraint.Weld(wep,rag,0,rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_R_Hand" )),0,true)
			if IsValid(cons) then
				ply.WepCons=cons
			end

			if weapon.TwoHands then
				local lh = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_L_Hand")))
				local rh = rag:GetPhysicsObjectNum(rag:TranslateBoneToPhysBone(rag:LookupBone("ValveBiped.Bip01_R_Hand")))

				if IsValid(lh) then
					local rhang = rh:GetAngles()
					lh:SetPos(rh:GetPos() + rhang:Forward() * 10 + rhang:Up() * -3)
					rhang:RotateAroundAxis(rhang:Forward(),180)
					lh:SetAngles(rhang)

					if IsValid(ply.WepCons2) then ply.WepCons2:Remove() ply.WepCons2 = nil end

					local cons2 = constraint.Weld(wep,rag,0,rag:TranslateBoneToPhysBone(rag:LookupBone( "ValveBiped.Bip01_L_Hand" )),0,true)
					if IsValid(cons2) then
						ply.WepCons2 = cons2
					end
				end
			end

		end
	end
end

function DespawnWeapon(ply)
	if IsValid(ply.wep) then
		ply.wep:Remove()
		ply.wep = nil
	end
end

local pos = Vector(0,0,0)

function FireShot(wep)
	if not IsValid(wep) then return end
	local ply = wep:GetOwner()

	local weapon = ply.ActiveWeapon

	if IsValid(wep) then return nil end
	
	if ( (wep.NextShot or 0) > CurTime() ) then return end

	wep.NextShot = CurTime() + weapon.ShootWait

	local Attachment = wep:GetAttachment(wep:LookupAttachment("muzzle") or 1)

	local shootOrigin = Attachment and Attachment.Pos or wep:GetPos() + wep:GetAngles():Forward() * 10
	local shootAngles = Attachment and Attachment.Ang or wep:GetAngles()
	local shootDir = shootAngles:Forward()

	local damage = weapon.Primary.Damage
	
	local bullet = {}
	bullet.Num 			= (weapon.NumBullet or 1)
	bullet.Src 			= shootOrigin
	bullet.Dir 			= shootDir
	bullet.Spread 		= Vector(weapon.Primary.Cone or 0,weapon.Primary.Cone or 0,0)
	bullet.Tracer		= 1
	bullet.TracerName 	= 4
	bullet.Force		= weapon.Primary.Force / 90
	bullet.Damage		= damage
	bullet.Attacker 	= ply
	bullet.Callback=function(ply,tr)
		wep:BulletCallbackFunc(damage,ply,tr,damage,false,true,false)
	end

	wep:FireBullets( bullet )
	
	-- Make a muzzle flash
	local effectdata = EffectData()
	effectdata:SetOrigin( shootOrigin )
	effectdata:SetAngles( shootAngles )
	effectdata:SetScale( 1 )
	util.Effect( "MuzzleEffect", effectdata )
end
