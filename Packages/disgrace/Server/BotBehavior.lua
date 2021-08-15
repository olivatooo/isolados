Package.Require("Skill.lua")

function BotCombatSniper(self)
	local bot = self.Character
	local weapon = bot:GetPicked()
	local enemy = self.Enemies[#self.Enemies]
	if bot and bot:IsValid() then
		if enemy and enemy:IsValid() and enemy:GetHealth()>0 and enemy:GetType() == "Character" then
			local enemy_location = enemy:GetLocation()
			bot:LookAt(enemy_location + Vector( math.random(-10,10), math.random(-10,10) ,math.random(-100,100)))

			if math.random(100) > 50 then
				bot:SetStanceMode(math.random(0,3))
			end
			bot:SetWeaponAimMode(AimMode.ZoomedZoom)
			if weapon then
				weapon:PullUse()
			else
				self:IdleMovementBehavior()
				return false
			end
			if math.random(100) > 50 then
				bot:SetGaitMode(math.random(0,2))
			end
		else
			self:IdleMovementBehavior()
			return false
		end
	else
		return false
	end
end


function BotRunNGun(self)
	local bot = self.Character
	local weapon = bot:GetPicked()
	local enemy = self.Enemies[#self.Enemies]
	if bot and bot:IsValid() then
		if enemy and enemy:IsValid() and enemy:GetHealth()>0 and enemy:GetType() == "Character" then
			local enemy_location = enemy:GetLocation()
			bot:LookAt(enemy_location + Vector( math.random(-100,100), math.random(-100,100) ,math.random(-100,100)))
			bot:SetStanceMode(StanceMode.Standing)
			bot:SetWeaponAimMode(AimMode.ZoomedZoom)
			bot:SetGaitMode(GaitMode.Sprinting)
			bot:MoveTo(enemy_location, 100)
			if weapon then
				weapon:PullUse()
			else
				self:IdleMovementBehavior()
				return false
			end
		else
			self:IdleMovementBehavior()
			return false
		end
	else
		return false
	end
end


function BotCS16(self)
	local bot = self.Character
	local weapon = bot:GetPicked()
	local enemy = self.Enemies[#self.Enemies]
	if bot and bot:IsValid() then
		if enemy and enemy:IsValid() and enemy:GetHealth()>0 and enemy:GetType() == "Character" then
			local enemy_location = enemy:GetLocation()
			bot:LookAt(enemy_location + Vector( math.random(-10,10), math.random(-10,10) ,math.random(-10,10)))
			bot:SetStanceMode(StanceMode.Standing)
			bot:SetWeaponAimMode(AimMode.ZoomedZoom)
			bot:SetGaitMode(GaitMode.Walking)
			local run_location = bot:GetLocation() + Vector(math.random(-200, 200), math.random(-200, 200), 10) 
			bot:MoveTo(run_location, 70)
			bot:SetWeaponAimMode(AimMode.ZoomedZoom)
			if weapon then
				if math.random(100) > 90 then
					Bomber(bot)
				end
				weapon:PullUse()
			else
				self:IdleMovementBehavior()
				return false
			end
		else
			self:IdleMovementBehavior()
			return false
		end
	else
		return false
	end
end


function BotMLG(self)
	local bot = self.Character
	local weapon = bot:GetPicked()
	local enemy = self.Enemies[#self.Enemies]
	if bot and bot:IsValid() then
		if enemy and enemy:IsValid() and enemy:GetHealth()>0 and enemy:GetType() == "Character" then
			local enemy_location = enemy:GetLocation()
			bot:LookAt(enemy_location + Vector( math.random(-10,10), math.random(-10,10) ,math.random(-10,10)))
			if math.random(100) > 50 then
				bot:Jump()
			end
			if math.random(100) > 50 then
				bot:SetStanceMode(math.random(0,3))
			end
			if math.random(100) > 50 then
				bot:SetGaitMode(math.random(0,2))
			end
			if math.random(100) > 50 then
				local run_location = enemy:GetLocation() + Vector(math.random(-25000, 25000), math.random(-25000, 25000), 1) 
				bot:MoveTo(run_location, 1000)
			end
			bot:SetWeaponAimMode(AimMode.ZoomedZoom)
			if weapon then
				weapon:PullUse()
			else
				self:IdleMovementBehavior()
				return false
			end
		else
			self:IdleMovementBehavior()
			return false
		end
	else
		return false
	end
end

