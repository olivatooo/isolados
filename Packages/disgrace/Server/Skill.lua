function Bomber(character)
	character:PlayAnimation("nanos-world::AM_Mannequin_Taunt_FingerGun", AnimationSlotType.UpperBody, false)
	local control_rotation = character:GetControlRotation()
	local forward_vector = control_rotation:GetForwardVector()
	local spawn_location = character:GetLocation() + forward_vector * 200
	for i=1,math.ceil(PlayerLevel/5) do
		local grenade = Grenade(spawn_location+Vector(math.random(100), math.random(100), math.random(100)), Rotator(), "nanos-world::SM_Grenade_G67", "nanos-world::P_Explosion_Dirt", "nanos-world::A_Explosion_Large")
		grenade:SetNetworkAuthority(character:GetPlayer())
		local trail_particle = Particle(spawn_location, Rotator(), "nanos-world::P_Ribbon", false, true)
		trail_particle:SetParameterColor("Color", Color.ORANGE)
		trail_particle:SetParameterFloat("LifeTime", 1)
		trail_particle:SetParameterFloat("SpawnRate", 30)
		trail_particle:SetParameterFloat("Width", 1)
		trail_particle:AttachTo(grenade)
		grenade:SetValue("Particle", trail_particle)
		grenade:Subscribe("Hit", function(self, intensity)
			self:Explode()
		end)
		grenade:Subscribe("Destroy", function(self, intensity)
			Timer.SetTimeout(function(particle)
			particle:Destroy()
			end, 1000, self:GetValue("Particle"))
		end)
		grenade:AddImpulse(forward_vector * 3000, true)
	end
end


function Barricade(character)
	local barricades = {"nanos-world::SM_Crate_07", "nanos-world::SM_Carpet_01", "nanos-world::SM_Carpet_02"}
	character:PlayAnimation("nanos-world::AM_Mannequin_Taunt_FingerGun", AnimationSlotType.UpperBody, false)
	local control_rotation = character:GetControlRotation()
	local forward_vector = control_rotation:GetForwardVector()
	local spawn_location = character:GetLocation() + forward_vector * 200
	local sm = StaticMesh(
		spawn_location,
		Rotator(0, 90, 90),
		barricades[math.random(#barricades)]
	)
	Timer.SetTimeout(function(static)
		Particle(static:GetLocation(),
		Rotator(0, 0, 0),
		"nanos-world::P_Explosion",
		true, -- Auto Destroy?
		true -- Auto Activate?
		)
		static:Destroy()
	end, 60000, sm)
end


function QuakeBuff(character)
	character:PlayAnimation("nanos-world::AM_Mannequin_Taunt_Praise", AnimationSlotType.UpperBody, false)
	character:SetFallDamageTaken(0)
	character:SetImpactDamageTaken(0)
	character:SetSpeedMultiplier(3)

	Timer.SetTimeout(function(char)
		if char and char:IsValid() then
			char:SetFallDamageTaken(10)
			char:SetImpactDamageTaken(10)
			char:SetSpeedMultiplier(1)
		else
			return false
		end
	end, 30000, character)
end


function Heal(character)
	local aura = Trigger(character:GetLocation(), Rotator(), 500, TriggerType.Sphere, false, Color(1, 0, 1))
	aura:AttachTo(character, AttachmentRule.SnapToTarget)
	local p = Particle(
			character:GetLocation(),
			Rotator(0, 0, 0),
			"nanos-world::P_HangingParticulates",
			true, -- Auto Destroy?
			true -- Auto Activate?
	)
	p:SetParameterColor("Color", Color(0, 10000, 0))
	p:SetParameterVector("BoxSize", Vector(500))
	p:SetParameterFloat("SpawnRate", 100)

	aura:Subscribe("BeginOverlap", function (_, friend)
		if friend and 
			friend:IsValid() and
			friend:GetType() == "Character" and
			friend:GetTeam() == character:GetTeam() then
				friend:SetHealth(friend:GetHealth() + 100 + math.random(0,1000))
		end
	end)

	Timer.SetTimeout(function(sc, pa)
		sc:Destroy()
	end, 4000, aura)
end

SkillList = {Barricade, Bomber, QuakeBuff, Heal}

Events.Subscribe("UseSkill", function(player, skill)
	local char = player:GetControlledCharacter()
	SkillList[skill](char)
end)
