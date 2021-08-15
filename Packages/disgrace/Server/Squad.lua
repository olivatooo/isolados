Package.Require("BotNew.lua")
Package.Require("V_Weapon.lua")

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


function Squad:GenerateSquad()
	for i=1,self.Size do
		local weapon = V_Weapon(self.Budget, Vector(0,0,-1000000))
		local bot = Bot(Vector(self.Location.X + (100 * i), self.Location.Y + (100 * i), self.Location.Z), self.SquadNumber, nil, nil, nil)
		bot.Character:Subscribe("Death", function(character)
			self.Size = self.Size - 1
			if self.Size <= 0 then
				Events.Call("SquadWipe")
			end
		end)
		self:EquipBotWithWeapon(bot, weapon)
	end
end


function Squad.new(location, budget, size)
	local self = setmetatable({}, Squad)
	self.SquadNumber = math.random(0,10000000)
	self.Budget = budget or 5000
	self.Size = size or 5
	self.Location = location or Vector(0,0,100)
	-- Squad modifiers is a list of functions
	-- Here you can insert healers, meelee, kamikazes, etc
	self.Modifiers = {}
	self:GenerateSquad()
	return self
end
