AddPrefabPostInit("eyeturret", function(inst)
	local function turnon( inst )
		inst.on = true
		inst:Remove()
		GLOBAL.SpawnPrefab("eyeturret_item").Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
	inst:AddComponent("machine")
	inst.components.machine.turnonfn = turnon
	
	if inst and inst.components and inst.components.lootdropper then
		inst.components.lootdropper:AddRandomLoot("eyeturret_item", 1)
		inst.components.lootdropper.numrandomloot = 1
	end
end)