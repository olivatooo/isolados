Package.Require("BotNew.lua")
Package.Require("V_Weapon.lua")
Package.Require("Skill.lua")

Squad = {}
Squad.__index = Squad
setmetatable(Squad, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})


function Squad:EquipBotWithWeapon(bot, weapon)
	bot.Character:PickUp(weapon.Weapon)
end


function SquadBotSkill(bot)
	Timer.SetInterval(function () 
		if bot and bot:IsValid() then
			if bot.InCombat then
				SkillList[math.random(#SkillList)](bot)
			end
		else
			return false
		end
	end, 20000)
end


function BuyHealth(value)
	return math.ceil(value/math.random(1, 100))
end

function DefaultSquadGenerator(self)
	for i=1,self.Size do
		local weapon_value = self.Budget - math.random(self.Budget)
		local weapon = V_Weapon(self.Budget, Vector(0,0,-1000000))
		local bot = Bot(Vector(self.Location.X + (100 * i), self.Location.Y + (100 * i), self.Location.Z), self.SquadNumber, nil, nil, nil)
		if self.Budget >= 5000 then
			bot.Character:SetHealth(BuyHealth(self.Budget - weapon_value))
			if bot.Character:GetHealth() > 10000 then
				bot.Character:SetScale(Vector(2,2,2))
			end
			if bot.Character:GetHealth() > 50000 then
				bot.Character:SetScale(Vector(3,3,3))
			end
		end
		if self.Budget >= 10000 and math.random(100) > 50 then
			SquadBotSkill(bot.Character)
		end
		table.insert(self.Bots, bot)
		bot.Character:Subscribe("Death", function(character)
			self.Size = self.Size - 1
			if self.Size <= 0 then
				Events.Call("SquadWipe")
			end
		end)
		self:EquipBotWithWeapon(bot, weapon)
	end
end

function Squad:AddModifier(modifier)
	table.insert(self.Modifiers, modifier)
end

function Squad.new(location, budget, size, squad_generator)
	local self = setmetatable({}, Squad)
	self.SquadNumber = math.random(0,10000000)
	self.Bots = {}
	self.Budget = budget or 5000
	self.Size = size or 5
	self.Location = location or Vector(0,0,100)
	self.SquadGenerator = squad_generator or DefaultSquadGenerator
	-- Squad modifiers is a list of functions
	-- Here you can insert healers, meelee, kamikazes, etc
	self.Modifiers = {}
	self:SquadGenerator()
	return self
end
