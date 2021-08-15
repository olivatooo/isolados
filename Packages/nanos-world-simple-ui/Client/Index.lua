persistent_data_notifications = {}

-- Spawns Sandbox HUD
main_hud = WebUI("Sandbox HUD", "file:///WebUI/index.html")

Package.Require("Scoreboard.lua")


Package.Subscribe("Load", function()
	if (Client.GetLocalPlayer() ~= nil) then
		UpdateLocalCharacter(Client.GetLocalPlayer():GetControlledCharacter())
	end

	-- Gets all notifications already sent
	persistent_data_notifications = Package.GetPersistentData().notifications or {}

	-- Updates all existing Players
	for k, player in pairs(Player.GetAll()) do
		UpdatePlayerScoreboard(player)
	end
end)


-- Function to set all needed events on local character (to update the UI when it takes damage or dies)
function UpdateLocalCharacter(character)
	-- Verifies if character is not nil (eg. when GetControllerCharacter() doesn't return a character)
	if (character == nil) then return end

	-- Updates the UI with the current character's health
	UpdateHealth(character:GetHealth())

	-- Sets on character an event to update the health's UI after it takes damage
	character:Subscribe("TakeDamage", function(charac, damage, type, bone, from_direction, instigator)
		-- Plays a Hit Taken sound effect
		Sound(Vector(), "nanos-world::A_HitTaken_Feedback", true)

		-- Updates the Health UI
		UpdateHealth(math.max(charac:GetHealth() - damage, 0))
	end)

	-- Sets on character an event to update the health's UI after it dies
	character:Subscribe("Death", function(charac)
		UpdateHealth(0)
	end)

	-- Sets on character an event to update the health's UI after it respawns
	character:Subscribe("Respawn", function(charac)
		UpdateHealth(100)
	end)

	-- Try to get if the character is holding any weapon
	local current_picked_item = character:GetPicked()

	-- If so, update the UI
	if (current_picked_item and current_picked_item:GetType() == "Weapon" and not current_picked_item:GetValue("ToolGun")) then
		UpdateAmmo(true, current_picked_item:GetAmmoClip(), current_picked_item:GetAmmoBag())
	end

	-- Sets on character an event to update his grabbing weapon (to show ammo on UI)
	character:Subscribe("PickUp", function(charac, object)
		if (object:GetType() == "Weapon" and not object:GetValue("ToolGun")) then
			UpdateAmmo(true, object:GetAmmoClip(), object:GetAmmoBag())

			-- Sets on character an event to update the UI when he fires
			character:Subscribe("Fire", function(charac, weapon)
				UpdateAmmo(true, weapon:GetAmmoClip(), weapon:GetAmmoBag())
			end)

			-- Sets on character an event to update the UI when he reloads the weapon
			character:Subscribe("Reload", function(charac, weapon, ammo_to_reload)
				UpdateAmmo(true, weapon:GetAmmoClip(), weapon:GetAmmoBag())
			end)
		end
	end)

	-- Sets on character an event to remove the ammo ui when he drops it's weapon
	character:Subscribe("Drop", function(charac, object)
		UpdateAmmo(false)
		character:Unsubscribe("Fire")
		character:Unsubscribe("Reload")
	end)
end

-- Function to update the Ammo's UI
function UpdateAmmo(enable_ui, ammo, ammo_bag)
	main_hud:CallEvent("UpdateWeaponAmmo", enable_ui, ammo, ammo_bag)
end

-- Function to update the Health's UI
function UpdateHealth(health)
	main_hud:CallEvent("UpdateHealth", health)
end

-- VOIP UI
Player.Subscribe("VOIP", function(player, is_talking)
	main_hud:CallEvent("ToggleVoice", player:GetName(), is_talking)
end)


Player.Subscribe("Destroy", function(player)
	main_hud:CallEvent("ToggleVoice", player:GetName(), false)
	main_hud:CallEvent("UpdatePlayer", player:GetID(), false)
end)
