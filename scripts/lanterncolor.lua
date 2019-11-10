local G = GLOBAL

PrefabFiles = {

}

Assets = {

}

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

local function OverrideLight(prefab)
	if prefab:GetSkinName() == "lantern_tesla" then
		--print("telsa ran")
		if prefab._light then
			--print("overriding light for telsa!")
			prefab._light.Light:SetColour(228/255, 46/255, 255/255)
		end
	elseif prefab:GetSkinName() == "lantern_winter" then
		--print("winter ran")
		if prefab._light then
			--print("overriding light for winter.")
			prefab._light.Light:SetColour(140/255, 205/255, 247/255)
		end
	end
end

local function LanternPostInit2(prefab)
	
	if not GLOBAL.TheWorld.ismastersim then
        return prefab
    end
	
	--print("DEBUG: Postinit Server only running!")
	if prefab.components.machine then
		local oldfn = prefab.components.machine.turnonfn 
		prefab.components.machine.turnonfn = function(prefab)
			oldfn(prefab)
			OverrideLight(prefab)
		end
	end
	
	if prefab.components.equippable then
		local oldfn = prefab.components.equippable.onequipfn
		prefab.components.equippable.onequipfn = function(prefab, owner)
			oldfn(prefab, owner)
			OverrideLight(prefab)
		end
	end
	
	if prefab.components.fueled then
		local oldfn = prefab.components.fueled.ontakefuelfn
		prefab.components.fueled.ontakefuelfn = function(prefab, doer)
			oldfn(prefab, doer)
			OverrideLight(prefab)
		end
	end
	
	if prefab.components.inventoryitem then
		local oldfn = prefab.components.inventoryitem.ondropfn
		prefab.components.inventoryitem.ondropfn = function(prefab)
			oldfn(prefab)
			OverrideLight(prefab)
		end
	end
end

AddPrefabPostInit("lantern", LanternPostInit2)