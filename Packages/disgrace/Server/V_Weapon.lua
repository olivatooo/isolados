Package.RequirePackage("NanosWorldWeapons")

V_WeaponPriceTable = {
	{NanosWorldWeapons.AK47, 2700},
	{NanosWorldWeapons.AK47U, 1800},
	{NanosWorldWeapons.GE36, 5200},
	{NanosWorldWeapons.Glock, 0},
	{NanosWorldWeapons.DesertEagle, 700},
	{NanosWorldWeapons.AR4, 3100},
	{NanosWorldWeapons.Moss500, 1700},
	{NanosWorldWeapons.AP5, 2100},
	{NanosWorldWeapons.SMG11, 1700},
	{NanosWorldWeapons.ASVal, 4750}
}


V_Weapon = {}
V_Weapon.__index = V_Weapon
setmetatable(V_Weapon, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})


function V_Weapon:GenerateWeapon()
	local index = nil
	while index == nil do
		index = math.random(#V_WeaponPriceTable)
		local weapon_price = V_WeaponPriceTable[index][2]
		local weapon = V_WeaponPriceTable[index][1]
		if weapon then
			if self.Price >= weapon_price then
				self.Weapon = weapon(self.Location)
			else
				index = nil
			end
		else
			index = nil
		end
	end
	self:LeftOver()
end


function UpgradeAmmoSettings(weapon, price)
	local lower = math.ceil(price/1000)
	local upper = math.ceil(price/200) + 15
	local ammo_clip = math.random(lower, upper)
	weapon:SetAmmoSettings(ammo_clip, ammo_clip*10, ammo_clip, ammo_clip)
end


function UpgradeDamageSettings(weapon, price)
	local damage = weapon:GetDamage()
	weapon:SetDamage(damage + math.ceil(price/1000))
	if damage >= 50 then
		weapon:SetScale(Vector(damage/50,damage/50,damage/50))
	end
end


function UpgradeSpread(weapon, price)
	weapon:SetSpread(weapon:GetSpread() - math.ceil(price/400))
end


function UpgradeBulletCount(weapon, price)
	local bullet_count = 1
	for i=1,math.ceil(price/1000) do 
		if math.random(100) > 50 then
			weapon:SetBulletSettings(bullet_count, math.random(100000), math.random(100000), Color.Random())
			weapon:SetSpread(weapon:GetSpread() + math.random(1, 120))
			bullet_count = bullet_count + 1 
		end
	end
end


function UpgradeCadence(weapon, price)
	-- TOOD: Wait for get cadence
	local cadence = 1
	if math.random(100) > 50 then
		weapon:SetCadence(math.random())
	else
		weapon:SetCadence(math.sqrt(2)^-(price/3000))
	end
	if cadence <=0.33 then
		local my_light = Light(
			Vector(0, 0, -1000000),
			Rotator(0, 90, 90), -- Relevant only for Rect and Spot light types
			Color.Random(), -- Red Tint
			LightType.Point, -- Point Light type
			100, -- Intensity
			250, -- Attenuation Radius
			44, -- Cone Angle (Relevant only for Spot light type)
			0, -- Inner Cone Angle Percent (Relevant only for Spot light type)
			5000, -- Max Draw Distance (Good for performance - 0 for infinite)
			true, -- Whether to use physically based inverse squared distance falloff, where Attenuation Radius is only clamping the light's contribution. (Spot and Point types only)
			true, -- Cast Shadows?
			true -- Enabled?
	)
	my_light:AttachTo(weapon, AttachmentRule.SnapToTarget)
	end
end


function V_Weapon:AddUpgrade(upgrade_function)
	table.insert(self.Upgrades, upgrade_function)
end


function V_Weapon:LeftOver()
	while self.Price > 0 do
		local price = 0
		if self.Price > 1000 then
			price = math.random(1000, self.Price)
		else
			price = self.Price
		end
		self.Upgrades[math.random(#self.Upgrades)](self.Weapon, price)
		self.Price = self.Price - price
	end
end


function V_Weapon.new(price, location)
	local self = setmetatable({}, V_Weapon)
	self.Weapon = nil
	self.Location = location or Vector(0,0,100)
	self.Modifiers = {}
	self.Upgrades = {UpgradeAmmoSettings, UpgradeDamageSettings, UpgradeSpread, UpgradeCadence}
	self.Price = price or 300
	self:GenerateWeapon()
	return self
end
