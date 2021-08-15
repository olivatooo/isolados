Package.Require("Utils.lua")


CharacterBot = {}
setmetatable(CharacterBot, 
	{ __mode = 'k' }
)


Bots = {}
BotTeamColor = {}

Bot = {}
Bot.__index = Bot
setmetatable(Bot, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})


-- Function to add a Nametag to a Player
function Bot:DebugText(text)
		-- local character = self.Character
    -- -- Spawns the Nametag (TextRender),
    -- local nametag = TextRender(
    --     Vector(),               -- Any Location
    --     Rotator(),              -- Any Rotation
    --     text,       -- Player Name
    --     Vector(0.5, 0.5, 0.5),  -- 50% Scale
    --     Color(1, 1, 1),         -- White
    --     FontType.Roboto,        -- Roboto Font
    --     TextRenderAlignCamera.AlignCameraRotation -- Follow Camera Rotation
    -- )
    -- nametag:AttachTo(character)
    -- nametag:SetRelativeLocation(Vector(0, 0, 250))
end


-- Function to remove a Nametag from  a Player
function RemoveNametag(player, character)
    -- Try to get it's character
    if (character == nil) then
        character = player:GetControlledCharacter()
        if (character == nil) then return end
    end

    -- Gets the Nametag from the player, if any, and destroys it
    local text_render = player:GetValue("Nametag")
    if (text_render and text_render:IsValid()) then
        text_render:Destroy()
    end
end

function Bot:Color()
	local team = self.Character:GetTeam()
	local color = BotTeamColor[team]
	if color then
		self.Character:SetMaterialColorParameter("Tint", color)
	else
		BotTeamColor[team] = Color.Random()
		self.Character:SetMaterialColorParameter("Tint", BotTeamColor[team])
	end
end

function Bot:AlertTeam(enemy)
	local bot = self.Character
	local scream = Trigger(bot:GetLocation(), Rotator(), self.ScreamRange, TriggerType.Sphere, false, Color(1, 0, 1))
	scream:AttachTo(bot, AttachmentRule.SnapToTarget)
	scream:Subscribe("BeginOverlap", function (_, friend)
		if friend and 
			friend:IsValid() and
			friend:GetType() == "Character" and
			friend:GetTeam() == bot:GetTeam() then
				table.insert(CharacterBot[friend].Enemies, enemy)
		end
	end)
	Timer.SetTimeout(function(sc)
		sc:Destroy()
	end, 5000, scream)
	-- 
end


function Bot:SubscribeTakeDamage()
	local bot = self.Character
	self.Character:Subscribe("TakeDamage", function(char, damage, _, _, _, instigator)
			if instigator and instigator:GetType() == "Player" then
				instigator = instigator:GetControlledCharacter()
			end
			if bot:GetPlayer() == nil then
				if bot and instigator and instigator:GetType() == "Character" and instigator:GetHealth() > 0 then
					table.insert(self.Enemies, instigator)
					self:AlertTeam(instigator)
				end
			end
	end)
end


function Bot:SubscribeDeath()
	self.Character:Subscribe("Death", function(char, _, _, _, _, _)
		for k,v in pairs(Bots) do
			for i, b in pairs(v.Enemies) do
				if b == char then
					v.Enemies[i] = nil
				end
			end
		end
		if char and self.Movement then
			Timer.ClearInterval(self.Movement)
		end
		Timer.SetTimeout(function(char)
			local attached = char:GetAttachedEntities()
			for _,v in pairs(attached) do
				v:Destroy()
			end
		char:Destroy()
		end, 10000, char)
	end)
end


function Bot:Surroundings()
		local long_aware = Trigger(Vector(0, 0, -100000), Rotator(), Vector(self.LongAwareSize), TriggerType.Sphere, false, Color(0, 1, 0))
		local medium_aware = Trigger(Vector(0, 100, -100000), Rotator(), Vector(self.MediumAwareSize), TriggerType.Sphere, false, Color(0, 0, 1))
		local short_aware = Trigger(Vector(0, 0, -100000), Rotator(), Vector(self.ShortAwareSize), TriggerType.Sphere, false, Color(1, 0, 0))
		local weapon_aware = Trigger(Vector(0, 0, -100000), Rotator(), Vector(self.WeaponAwareSize), TriggerType.Sphere, false, Color(1, 1, 1))
		local fov_radius = self.FOVRadius
		local fov = Trigger(Vector(0, 100, -100000), Rotator(), Vector(fov_radius), TriggerType.Sphere, false, Color(0, 1, 1))
		self:Aware(long_aware, self.LongAwareChance)
		self:Aware(medium_aware, self.MediumAwareChance)
		self:Aware(short_aware, self.ShortAwareChance)
		self:Aware(fov, self.FOVChance, Vector(fov_radius, 0, 0))
		self:PickupCloseWeapon(weapon_aware)
end


-- Sensors to bot in the world
function Bot:Aware(trigger, aware_chance, offset)
	offset = offset or Vector(0,0,0)
	local bot = self.Character
	trigger:AttachTo(bot, AttachmentRule.SnapToTarget)
	trigger:SetRelativeLocation(offset)
	self:SeeEnemy(trigger, aware_chance)
end


function Bot:Movement()
	local bot = self.Character
	if bot and bot:IsValid() then
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


Character.Subscribe("FallingModeChanged", function(self, old_state, new_state)
	if self and 
		self:IsValid() and 
		self:GetHealth()>0 and 
		self:GetPlayer() == nil then
		if new_state == FallingMode.HighFalling then
			self:Jump()
		end
	end
end)


function Bot:SeeEnemy(trigger, aware_chance)
	local bot_character = self.Character
	local bot = self
	local trigger_options = {"EndOverlap", "BeginOverlap"}
	for t = 1, #trigger_options do
		trigger:Subscribe(trigger_options[t], function(_, enemy) 
			if enemy and
				enemy:GetType() == "Character" and
				enemy:GetTeam() ~= bot_character:GetTeam() and
				aware_chance > math.random(1,100) and
				enemy:GetHealth() > 0 then
					table.insert(bot.Enemies, enemy)
			end
		end)
	end
end


function Bot:EnemyFoundBehavior()
	local bot = self.Character
	local weapon = bot:GetPicked()
	local movement_timer = self.Movement
	if movement_timer then
		Timer.ClearInterval(movement_timer)
	end
	if weapon then
		if self.Debug then Bot:DebugText("Combating with weapon") end
		self.Movement = Timer.SetInterval(self.CombatBehavior, self.CombatReactionTime, self)
	else
		if self.Debug then Bot:DebugText("Running without weapon") end
		self.Movement = Timer.SetInterval(self.DefensiveBehavior , self.DefensiveReactionTime, self)
	end
end


function Bot:PickupCloseWeapon(trigger)
	local bot = self.Character
	trigger:AttachTo(bot, AttachmentRule.SnapToTarget)
	trigger:Subscribe("BeginOverlap", function (_, weapon)
			if bot and
				bot:IsValid() and 
				bot:GetPicked() == nil and
				bot:GetHealth() > 0 and
				WeaponIsInFloor(weapon) then
					bot:PickUp(weapon)
			end
	end)
end


function DefaultDefensiveBehavior(self)
	local bot = self.Character
	local enemy = self.Enemies[#self.Enemies]
	if bot and bot:IsValid() then
		if enemy and enemy:IsValid() and enemy:GetHealth()>0 then
			bot:SetGaitMode(GaitMode.Sprinting)
			if self.Stance == nil then
				self.Stance = math.random(0,3)
				bot:SetStanceMode(self.Stance)
			end
			local run_location = enemy:GetLocation():GetSafeNormal() * Vector(-1,-1, 1) 
			run_location = run_location * math.random(1000, 10000)
			bot:MoveTo(run_location)
		else
			self:IdleMovementBehavior()
			return false
		end
	else
		return false
	end
end


function DefaultCombatMovement(self)
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
			local run_location = enemy:GetLocation() + Vector(math.random(-25000, 25000), math.random(-25000, 25000), 1) 
			bot:MoveTo(run_location, 500)
		else
			self:IdleMovementBehavior()
			return false
		end
	else
		return false
	end
end


function DefaultMovement(bot)
	if bot and bot:IsValid() then
		bot:SetGaitMode(GaitMode.Walking)
		bot:SetWeaponAimMode(AimMode.None)
		bot:SetStanceMode(StanceMode.None)
		local location = bot:GetLocation()
		local random_place = Vector(math.random(-2500,2500), math.random(-2500,2500), math.random(-250,250))
		bot:LookAt(location+random_place)
		bot:MoveTo(location+random_place, 500)
	else
		return false
	end
end


function Bot:IdleMovementBehavior()
	if self.Debug then Bot:DebugText("I'm idle") end
	local bot = self.Character
	local bot_movement = Timer.SetInterval(self.IdleBehavior , self.IdleTime, bot)
	self.Movement = bot_movement
end


function Bot.new(location, team, combat_behavior, defensive_behavior, idle_behavior, debug)
	local self = setmetatable({}, Bot)
	self.Character = Character(location, Rotator(0, 0, 0), "nanos-world::SK_Mannequin")
	self.Character:SetTeam(team)
	self.Movement = nil

	self.CombatReactionTime = math.random(250, 750)
	self.DefensiveReactionTime = math.random(1000, 1500)
	self.IdleTime = math.random(2500,5000)
	self.InCombat = false

	self.LongAwareSize = 7500
	self.LongAwareChance = 10

	self.MediumAwareSize = 3750
	self.MediumAwareChance = 35

	self.ShortAwareSize = 1000
	self.ShortAwareChance = 95

	self.WeaponAwareSize = 300
	self.WeaponAwareChance = 100

	self.FOVRadius = 3000
	self.FOVChance = 100

	self.ScreamRange = 5000
	self.Debug = debug

	self.Enemies = {}
	setmetatable(self.Enemies, {
			__newindex = function(t,k,v)
				self:EnemyFoundBehavior()
				rawset (t, k, v)
			end
	},
	{
		__mode = 'k' 
	}
	)

	self.CombatBehavior = combat_behavior or DefaultCombatMovement
	self.DefensiveBehavior = defensive_behavior or DefaultDefensiveBehavior
	self.IdleBehavior = idle_behavior or DefaultMovement

	CharacterBot[self.Character] = self
	self:Surroundings()
	self:IdleMovementBehavior()
	self:SubscribeDeath()
	self:SubscribeTakeDamage()
	self:Color()
	table.insert(Bots, self)

	return self
end


