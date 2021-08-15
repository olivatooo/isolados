Package.Require("Squad.lua")

Mission = {}
Mission.__index = Mission
setmetatable(Mission, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})


function DefaultMissionStart(mission, args)
	local player_level = args[1]
	local s = Squad(mission.Location, math.ceil(math.random(1750, 3500)*player_level*1.1), math.random(2, 6) )
	Events.Subscribe("SquadWipe", function()
		mission:End()
		Events.Call("MissionEnd", mission.ID)
	end)
	return s
end


function DefaultMissionEnd(mission, args)
	for k, v in pairs(mission.Players) do
		-- Reward Players
	end
end


function Mission:AddPlayer(player)
	table.insert(self.Players, player)
end


function Mission:RemovePlayer(player)
	RemoveValueTable(self.Players, player)
end


function Mission.new(location, players, start_mission, end_mission, start_mission_args, end_mission_args, id)
	local self = setmetatable({}, Mission)
	self.ID = id or math.random(1, 4000000000)
	self.Location = location or Vector(0,0,200)
	self.Reward = reward or 1000
	self.Players = players or Player.GetAll()
	self.Start = start_mission or DefaultMissionStart
	self.End = end_mission or DefaultMissionEnd
	self:Start(start_mission_args)
	return self
end
