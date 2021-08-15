-- prints "Server started" when the server is starting
--

Package.RequirePackage("NanosWorldWeapons")
Package.Require("Utils.lua")

Bot = {}
Bot.MovementTable = {}

Bot.__index = Bot

setmetatable(Bot, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

function Bot.new(Location, Team)
	local self = setmetatable({}, Bot)
	self.Character = Character(Location, Rotator(0, 0, 0), "nanos-world::SK_Mannequin")
	self.Movement = nil
	self.Enemies = {}
	return self
end

function Bot:Enrich(enrich_function)
end

function Bot:Movement()
	local bot = self.Character
	if bot:IsValid() then
		bot:SetGaitMode(GaitMode.Walking)
		bot:SetWeaponAimMode(AimMode.None)
		bot:SetStanceMode(StanceMode.None)
		local location = bot:GetLocation()
		local random_place = Vector(math.random(-10000,10000), math.random(-10000,10000), math.random(-250,250))
		bot:LookAt(location+random_place)
		bot:MoveTo(location+random_place, 500)
	else
		return false
	end
end


function Bot:RemoveEnemyFromTable(enemy)
	local bot = self.Character
	local enemies = bot:GetValue("Enemies")
	table.removeitem(enemies, enemy)
	if next(enemies) == nil then
		Bot.Behavior()
	end
	bot:SetValue("Enemies", enemies)
	if next(enemies) == nil then
		Bot.Behavior()
		return false
	end
	return true
end


function Bot.SearchAndDestroy(self, enemy, weapon)
	local bot = self.Character
	if bot:IsValid() then
		if enemy:IsValid() and enemy:GetHealth()>0 then
			local enemy_location = enemy:GetLocation()
			bot:LookAt(enemy_location + Vector(0,0,math.random(-100,100)))
			bot:SetStanceMode(math.random(0,3))
			bot:SetWeaponAimMode(AimMode.ZoomedZoom)
			weapon:PullUse()
			bot:SetGaitMode(math.random(0,2))
			local run_location = enemy:GetLocation() + Vector(math.random(-25000, 25000), math.random(-25000, 25000), 1) 
			bot:MoveTo(run_location, 500)
		else
			Bot.RemoveEnemyFromTable(bot, enemy)
			return false
		end
	else
		return false
	end
end


function Bot.AlertTeam(self, enemy)
	local bot = self.Character
	local scream = Trigger(bot:GetLocation(), Rotator(), Vector(math.random(10000,15000)), TriggerType.Sphere, true, Color(1, 0, 1))
	scream:Subscribe("BeginOverlap", function (_, friend)
		if friend:IsValid() and
			friend:GetType() == "Character" and
			friend:GetTeam() == bot:GetTeam() then
				Bot.ReactionToAnEnemy(friend, enemy)
		end
	end)
end


function Bot.SniperFromDistance(self, enemy, weapon)
	local bot = self.Character
	if bot:IsValid() then
		if enemy:IsValid() and enemy:GetHealth()>0 then
			local enemy_location = enemy:GetLocation()
			bot:LookAt(enemy_location + Vector(0,0,math.random(-100,100)))
			bot:SetStanceMode(StanceMode.Proning)
			bot:SetWeaponAimMode(AimMode.ZoomedZoom)
			weapon:PullUse()
		else
			Bot.RemoveEnemyFromTable(bot, enemy)
			return false
		end
	else
		return false
	end
end


function Bot.SurfAndShoot(self, enemy, weapon)
	local bot = self.Character
	if bot:IsValid() then
		if enemy:IsValid() and enemy:GetHealth()>0 then
			local enemy_location = enemy:GetLocation()
			bot:LookAt(enemy_location + Vector(0,0,math.random(-100,100)))
			bot:SetStanceMode(StanceMode.Crouching)
			bot:SetGaitMode(GaitMode.Sprinting)
			bot:SetWeaponAimMode(AimMode.ZoomedZoom)
			weapon:PullUse()
			bot:SetGaitMode(math.random(0,2))
			local run_location = bot:GetLocation() + Vector(math.random(-500, 500), math.random(-500, 500), 1) 
			bot:MoveTo(run_location, 100)
		else
			Bot.RemoveEnemyFromTable(bot, enemy)
			return false
		end
	else
		return false
	end
end

function Bot.JumpAndShoot(bot, enemy, weapon)
	if bot:IsValid() then
		if enemy:IsValid() and enemy:GetHealth()>0 then
			local enemy_location = enemy:GetLocation()
			bot:LookAt(enemy_location + Vector(0,0,math.random(-100,100)))
			if math.random(100) > 50 then
				bot:Jump()
			end
			if math.random(100) > 50 then
				bot:SetStanceMode(math.random(3))
			end
			if math.random(100) > 50 then
				bot:SetStanceMode(math.random(3))
			end
			bot:SetWeaponAimMode(AimMode.ZoomedZoom)
			local run_location = bot:GetLocation() + Vector(math.random(-500, 500), math.random(-500, 500), 1) 
			bot:MoveTo(run_location, 100)
			weapon:PullUse()
		else
			Bot.RemoveEnemyFromTable(bot, enemy)
			return false
		end
	else
		return false
	end
end

Bot.OffensiveCombatBehaviors = {Bot.SniperFromDistance, Bot.SurfAndShoot, Bot.SearchAndDestroy, Bot.JumpAndShoot}

function Bot.RunAndHide(bot, enemy)
	if bot:IsValid() then
		if enemy:IsValid() and enemy:GetHealth()>0 then
			bot:SetGaitMode(GaitMode.Sprinting)
			bot:SetStanceMode(math.random(0,3))
			local run_location = enemy:GetLocation():GetSafeNormal() * Vector(-1,-1, 1) 
			run_location = run_location * math.random(1000, 10000)
			bot:MoveTo(run_location)
		else
			Bot.Behavior()
			Bot.RemoveEnemyFromTable(bot, enemy)
			return false
		end
	else
		Bot.Behavior()
		return false
	end
end


function Bot.ProneAndRun(bot, enemy)
	if bot:IsValid() then
		if enemy:IsValid() and enemy:GetHealth()>0 then
			bot:SetGaitMode(GaitMode.Sprinting)
			bot:SetStanceMode(StanceMode.Proning)
				local run_location = enemy:GetLocation():GetSafeNormal() * Vector(-1,-1, 1) 
				run_location = run_location * math.random(1000, 10000)
				bot:MoveTo(run_location)
		else
			Bot.RemoveEnemyFromTable(bot, enemy)
			Bot.Behavior()
			return false
		end
	else
		Bot.Behavior()
		return false
	end
end


function Bot.FindWeaponToFight(bot, enemy)
	if bot == nil and bot:IsValid() then
	else
		return false
	end
	local find_weapon = Trigger(bot:GetLocation(), Rotator(), Vector(math.random(10000,20000)), TriggerType.Sphere, true, Color(1, 0, 1))
	local weapon_list = {}
	find_weapon:Subscribe("BeginOverlap", function (_, weapon)
		if WeaponIsInFloor(weapon) then
			table.insert(weapon_list, weapon)
		end
	end)

	find_weapon:Destroy()

	if bot:IsValid() then
		if enemy:IsValid() and enemy:GetHealth()>0 then
			bot:SetGaitMode(math.random(0,2))
			bot:SetStanceMode(math.random(0,3))
			local run_location = weapon_list[math.random(#weapon_list)]
			bot:MoveTo(run_location)
		else
			Bot.Behavior()
			Bot.RemoveEnemyFromTable(bot, enemy)
			return false
		end
	else
		Bot.Behavior()
		return false
	end
end


Bot.DeffensiveCombatBehaviors = {Bot.RunAndHide, Bot.ProneAndRun, Bot.FindWeaponToFight}

function Bot.ReactionToAnEnemy(bot, enemy)
	local dl = 200
	local dh = 4000 
	-- Stop normal behavior
	if Bot.MovementTable[bot] then
		Timer.ClearInterval(Bot.MovementTable[bot])
	end
	local weapon = bot:GetPicked()
	if weapon then
		Timer.SetInterval(Bot.OffensiveCombatBehaviors[math.random(#Bot.OffensiveCombatBehaviors)] , math.random(dl, dh), bot, enemy, weapon)
	else
		Timer.SetInterval(Bot.DeffensiveCombatBehaviors[math.random(#Bot.DeffensiveCombatBehaviors)] , math.random(1000, 20000), bot, enemy)
	end
end


function Bot.Behavior(self)
	local bot = self.Character
	local bot_movement = Timer.SetInterval(Bot.Movement , math.random(1000, 15000), bot)
	Bot.MovementTable[bot] = bot_movement
end


function Bot.RegisterEnemy(trigger, bot, aware_chance)	
	local tt = {"EndOverlap" , "BeginOverlap"}
	for trigger_type = 1, 2 do
		trigger:Subscribe(tt[trigger_type], function(_, enemy)
			local enemies = bot:GetValue("Enemies")
			if enemies[enemy] == nil 
				and enemy:GetType() == "Character"
				and enemy:GetTeam() ~= bot:GetTeam()
				and aware_chance > math.random(1,100)
				and enemy:GetHealth() > 0 then
					table.insert(enemies, enemy)
					Bot.ReactionToAnEnemy(bot, enemy)
			end
		end)
	end
end


function Bot.Aware(self, trigger, aware_chance)
	local bot = self.Character
	trigger:AttachTo(bot, AttachmentRule.SnapToTarget)
	Bot.RegisterEnemy(trigger, bot, aware_chance)
end


function Bot.FOV(self)
	local bot = self.Character
	local fov_radius = math.random(1000,5000)
	local trigger = Trigger(Vector(0, 100, -100000), Rotator(), Vector(fov_radius), TriggerType.Sphere, true, Color(0, 1, 1))
	trigger:AttachTo(bot, AttachmentRule.SnapToTarget)
	trigger:SetRelativeLocation(Vector(fov_radius, 0, 0))
	Bot.RegisterEnemy(trigger, bot, math.random(80, 100))
end


function Bot.PickupCloseWeapon(self, trigger)
	local bot = self.Character
	trigger:AttachTo(bot, AttachmentRule.SnapToTarget)
	trigger:Subscribe("BeginOverlap", function (_, weapon)
			if bot:IsValid() and bot:GetPicked() == nil and WeaponIsInFloor(weapon) then
					bot:PickUp(weapon)
			end
	end)
end

function Bot.Spawn(location, team)
		local bot = Character(location, Rotator(0, 0, 0), "nanos-world::SK_Mannequin")
		local long_aware = Trigger(Vector(0, 0, -100000), Rotator(), Vector(self.LongAwareSize), TriggerType.Sphere, false, Color(0, 1, 0))
		local medium_aware = Trigger(Vector(0, 100, -100000), Rotator(), Vector(self.MediumAwareSize), TriggerType.Sphere, false, Color(0, 0, 1))
		local short_aware = Trigger(Vector(0, 0, -100000), Rotator(), Vector(self.ShortAwareSize), TriggerType.Sphere, false, Color(1, 0, 0))
		local weapon_aware = Trigger(Vector(0, 0, -100000), Rotator(), Vector(self.WeaponAwareSize), TriggerType.Sphere, false, Color(1, 1, 1))

		bot:SetValue("Enemies", {}, false)
		bot.Sensors = {short_aware, medium_aware, long_aware}
		bot:SetValue("Timers", {}, false)

		bot:SetTeam(team)
		Bot.Aware(short_aware, math.random(90,100))
		Bot.Aware(medium_aware, math.random(30,40))
		Bot.Aware(long_aware, math.random(1,20))
		Bot.FOV()
		Bot.PickupCloseWeapon(weapon_aware)
		Bot.Behavior()
		return bot
end

Character.Subscribe("TakeDamage", function(self, damage, bone, type, from_direction, instigator)
	if instigator and instigator:GetType() == "Player" then
		instigator = instigator:GetControlledCharacter()
	end

	if self:GetPlayer() == nil then
		if instigator then
			local enemies = self:GetValue("Enemies")
			if instigator:GetType() == "Character" and instigator:GetHealth() > 0 then
				table.insert(enemies, instigator)
				Bot.AlertTeam(self, instigator)
				Bot.ReactionToAnEnemy(self, instigator)
				self:SetValue("Enemies", enemies)
			end
		end
	end
end)


Server.Subscribe("Console", function(my_input)
    if (my_input == "pra") then
        for _, p in pairs(Server.GetPackages(true)) do
            Server.ReloadPackage(p)
        end
    end
end)


Character.Subscribe("Death", function(self, last_damage_taken, last_bone_damage, damage_type_reason, hit_from_direction, instigator)
	Timer.SetTimeout(function(char)
		local attached = char:GetAttachedEntities()
		for _,v in pairs(attached) do
			v:Destroy()
		end

	if Bot.MovementTable[char] then
		Timer.ClearInterval(Bot.MovementTable[char])
	end

	Bot.MovementTable[char] = nil

	char:Destroy()
	end, 10000, self)
end)


Character.Subscribe("FallingModeChanged", function(self, old_state, new_state)
	if self:IsValid() and self:GetHealth()>0 and self:GetPlayer() == nil then
		if new_state == FallingMode.HighFalling then
			self:Jump()
		end
	end
end)

