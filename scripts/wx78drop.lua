local UpvalueHacker = GLOBAL.require("tools/upvaluehacker")
AddPrefabPostInit("world", function(inst)
	local applyupgrades = UpvalueHacker.GetUpvalue(GLOBAL.Prefabs.wx78.fn, "master_postinit", "ondeath", "applyupgrades")
	local function ondeath(inst)
		if inst.level > 0 then
			applyupgrades(inst)
		end
	end
	UpvalueHacker.SetUpvalue(GLOBAL.Prefabs.wx78.fn, ondeath, "master_postinit", "ondeath")
end)