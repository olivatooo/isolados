Package.Require("Mission.lua")
Package.Require("Skill.lua")
Package.RequirePackage("NanosWorldWeapons")
PlayerLevel = 1
OnGoing = false


local spawn_locations = {
	-- Vector(-65076.000, 4184.000, -106.923),
	-- Vector(-65076.000, 2295.000, -106.923),
	-- Vector(-65076.000, 239.000, -106.923),
	-- Vector(-67469.000, 14820.000, 399.217),
	-- Vector(-67469.000, 16752.000, 399.217),
	-- Vector(-67469.000, 12835.000, 399.217),
	-- Vector(-52230.000, 12190.000, 202.163),
	-- Vector(-53790.000, 12479.000, 193.795),
	-- Vector(-44975.000, 12411.000, -298.149),
	-- Vector(-45069.000, 12956.000, -298.149),
	-- Vector(-45163.000, 13672.000, -298.149),
	-- Vector(-32219.000, 10587.000, 197.131),
	-- Vector(-31788.000, 11671.000, 197.131),
	-- Vector(-31309.000, 12776.000, 197.131),
	-- Vector(-30774.000, 13907.000, 197.131),
	-- Vector(-25101.000, 6002.000, 176.502),
	-- Vector(-24110.000, 6577.000, 176.502),
	-- Vector(-22842.000, -18222.000, -52.235),
	-- Vector(-24534.000, -18334.000, -151.480),
	-- Vector(-33860.000, -15033.000, -145.480),
	-- Vector(-37388.000, -11335.000, 168.078),
	-- Vector(-36571.000, -6030.000, -396.766),
	-- Vector(-30177.000, -1527.000, -281.594),
	-- Vector(-26788.000, 2497.000, 49.047),
	-- Vector(-34133.000, 917.000, -436.952),
	-- Vector(-56030.000, -15969.000, -30.660),
	-- Vector(-54339.000, -15367.000, -181.141),
	-- Vector(-57500.000, -11528.000, -32.134),
	-- Vector(-66100.000, -5985.000, 643.852),
	-- Vector(-41677.000, 12607.000, 217.587),
	Vector(0,0,2000)
}



local Selector = Prop(
	-- Vector(-59018.000, 2541.000, -608.891),
	Vector(0,0,100),
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
		-- NanosWorldWeapons.Glock(Vector(-59018.000, 2641.000, -608.891))
		NanosWorldWeapons.Glock(Vector(0, 0, 300))
		-- local new_character = Character(Vector(-59018.000, 2641.000, -608.891), Rotator(0,0,0), "nanos-world::SK_Male")
		local new_character = Character(Vector(100, 0, 100), Rotator(0,0,0), "nanos-world::SK_Male")
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
