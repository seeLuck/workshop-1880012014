AddPrefabPostInit("boat_leak", function(inst)
	local function onrepairedleak(inst)
		inst:Remove()
	end

	if inst.components.boatleak then
		inst.components.boatleak.onrepairedleak = onrepairedleak
	end
end)