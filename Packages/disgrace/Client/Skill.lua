PlayerLevel = 1

SkillCooldown = {{true, 20000}, {true, 30000}, {true, 60000}, {true, 50000}}

function SetPlayerLevel(level)
	PlayerLevel = level
	Sound(
			Vector(), -- Location (if a 3D sound)
			"nanos-world::A_Vehicle_Horn_Toyota", -- Asset Path
			true, -- Is 2D Sound
			true, -- Auto Destroy (if to destroy after finished playing)
			SoundType.SFX,
			1, -- Volume
			1 -- Pitch
	)
end

function SoundMission()
	Sound(
			Vector(), -- Location (if a 3D sound)
			"nanos-world::A_Vehicle_Horn_Dixie", -- Asset Path
			true, -- Is 2D Sound
			true, -- Auto Destroy (if to destroy after finished playing)
			SoundType.SFX,
			1, -- Volume
			1 -- Pitch
	)
end


Events.Subscribe("SetPlayerLevel", SetPlayerLevel)
Events.Subscribe("StartMission", SoundMission)


function UseSkill(skill)
	if skill == "One" and PlayerLevel >= 5 and SkillCooldown[1][1] then
		SkillCooldown[1][1] = false
		Timer.SetTimeout(function() 
			SkillCooldown[1][1] = true
			Sound(Vector(), "nanos-world::A_VR_Click_01", true, true, SoundType.SFX, 1, 1)
		end, SkillCooldown[1][2]- (PlayerLevel*100) )
		Events.CallRemote("UseSkill", 1)
	end

	if skill == "Two" and PlayerLevel >= 10 and SkillCooldown[2][1] then
		SkillCooldown[2][1] = false
		Timer.SetTimeout(function() 
			SkillCooldown[2][1] = true 
			Sound(Vector(), "nanos-world::A_VR_Click_02", true, true, SoundType.SFX, 1, 1)
		end, SkillCooldown[2][2]- (PlayerLevel*100))
		Events.CallRemote("UseSkill", 2)
	end

	if skill == "Three" and PlayerLevel >= 15 and SkillCooldown[3][1] then
		SkillCooldown[3][1] = false
		Timer.SetTimeout(function() 
			SkillCooldown[3][1] = true 
			Sound(Vector(), "nanos-world::A_VR_Click_03", true, true, SoundType.SFX, 1, 1)
		end, SkillCooldown[3][2]- (PlayerLevel*100))
		Events.CallRemote("UseSkill", 3)
	end

	if skill == "Four" and PlayerLevel >= 20 and SkillCooldown[4][1] then
		SkillCooldown[4][1] = false
		Timer.SetTimeout(function() 
			SkillCooldown[4][1] = true 
			Sound(Vector(), "nanos-world::A_VR_Click_03", true, true, SoundType.SFX, 1, 1)
		end, SkillCooldown[4][2]- (PlayerLevel*100))
		Events.CallRemote("UseSkill", 4)
	end
end


Client.Subscribe("KeyUp", UseSkill)
