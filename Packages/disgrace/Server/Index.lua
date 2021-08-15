Package.Require("Mission.lua")
Package.Require("Skill.lua")
Package.RequirePackage("NanosWorldWeapons")
PlayerLevel = 1
OnGoing = false


local spawn_locations = {
	Vector(-2006, 8287, 200),
	Vector(-4701, 7058, 236),
	Vector(7065, 5516, 210),
	Vector(4084, 8175, 238),
	Vector(-4661, -688, 295),
	Vector(9349, -776, 215),
	Vector(6221, -7602, 197),
	Vector(344, -4713, 517),
	Vector(-2352, -6579, 313),
	Vector(-7831, -7635, 197),
	Vector(-9481, -2884, 185),
	Vector(-8014, -754, 394),
	Vector(-9400, 3869, 186),
	Vector(-5850, 8164, 222),
	Vector(-2050, 6654, 228),
	Vector(-1207, 5057, 235),
	Vector(3760, 10620, 119),
	Vector(3143, 8325, 248),
	Vector(6910, -1799, 267),
	Vector(1569, -10662, 216),
}



local Selector = Prop(
	Vector(-4014, -4765, 714),
	Rotator(0, 90, 90),
	"nanos-world::SM_Cube"
)
Selector:SetPhysicsDamping(1000, 1000)
Selector:SetMaterialColorParameter("Tint", Color(1, 0, 0))


-- Called when Players join the server (i.e. Spawn)
Player.Subscribe("Spawn", function(new_player)
	-- TODO: When a new player joins the server
end)


Character.Subscribe("Death", function(self)
	if self and self:GetPlayer() then
		Timer.SetTimeout(function(char)
			CreateCharacter(char:GetPlayer())
			char:Destroy()
		end, 5000, self)
	end
end)


Server.Subscribe("Console", function(my_input)
    if (my_input == "pra") then
        for _, p in pairs(Server.GetPackages(true)) do
            Server.ReloadPackage(p)
        end
    end
    if (my_input == "start") then
        for _, p in pairs(Server.GetPackages(true)) do
            Server.ReloadPackage(p)
        end
    end
end)


function QuickReward(char)
	char:SetMaxHealth(math.ceil(100*PlayerLevel*1.5))
	char:SetHealth(math.ceil(100*PlayerLevel*1.5))
end


Events.Subscribe("MissionEnd", function(id)
	Selector:SetMaterialColorParameter("Tint", Color(1, 0, 0))
	OnGoing = false
	PlayerLevel = PlayerLevel + 1
	Events.BroadcastRemote("SetPlayerLevel", PlayerLevel)
	for k,v in pairs(Player.GetAll()) do 
		local char = v:GetControlledCharacter()
		QuickReward(char)
	end
end)


function CreateCharacter(player)
	if player and player:IsValid() then
		local w = NanosWorldWeapons.Glock(Vector(-4014, -4865, 714))
		local new_character = Character(Vector(-4014, -4865, 714), Rotator(0,0,0), "nanos-world::SK_Male")
		new_character:PickUp(w)
		new_character:SetTeam(8)
		new_character:SetHealth(100*PlayerLevel*1.5)
		new_character:SetViewMode(ViewMode.FPS)
		new_character:SetCameraMode(CameraMode.FPSOnly)
		new_character:Subscribe("Interact", function(self, object)
			if object and object:GetAssetName() == "nanos-world::SM_Cube" and OnGoing == false then
					object:SetMaterialColorParameter("Tint", Color(0, 1, 0))
					local m = Mission(spawn_locations[math.random(#spawn_locations)] + Vector(0,0,3000), nil, nil, nil, {PlayerLevel})
					Events.BroadcastRemote("StartMission", PlayerLevel)
					OnGoing = true
					for k,v in ipairs(Weapon.GetAll()) do
						if v and v:IsValid() and v:GetHandler() == nil then
							v:Destroy()
						end
					end
					return false
			end
			if object and object:GetAssetName() == "nanos-world::SM_Cube" then
				return false
			end
		end)
		player:Possess(new_character)
	end
end


Package.Subscribe("Load", function()
	Package.Log("Loaded")
	for k,v in pairs(Player.GetAll()) do
		CreateCharacter(v)
	end
end)
