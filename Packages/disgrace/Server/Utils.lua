-- Find value in table
function FindValue(whichArray, itemName)
	for currentIndex = 1, #whichArray do
		if whichArray[currentIndex] == itemName then
			return currentIndex
		end
	end
end

-- Remove value from table
function RemoveValueTable(arr, item)
	table.remove(arr, FindValue(arr,item))
end

table.removeitem = RemoveValueTable
table.contain = FindValue

-- Check if weapon is in floor
function WeaponIsInFloor(weapon)
	if weapon and
		 weapon:GetType() == "Weapon" and
		 weapon:GetHandler() == nil then
		return true
	end
	return false
end

-- Check what weapon is better
function CompareWeapon(w1, w2)
	if w1:GetAmmoClip() == 0 and w1:GetAmmoBag() == 0 and w1:GetAmmoClip() ~= 0 then
		return w2
	end

	if w2:GetDamage() > w1:GetDamage() then
		return w2 
	end
end
