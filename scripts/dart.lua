-- 吹箭
AddPrefabPostInit("houndstooth", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.tradable then
			inst:AddComponent("tradable")
		end
	end
end)
AddPrefabPostInit("stinger", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.tradable then
			inst:AddComponent("tradable")
		end
	end
end)
AddPrefabPostInit("feather_robin", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.tradable then
			inst:AddComponent("tradable")
		end
	end
end)
AddPrefabPostInit("feather_robin_winter", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.tradable then
			inst:AddComponent("tradable")
		end
	end
end)
AddPrefabPostInit("feather_crow", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.tradable then
			inst:AddComponent("tradable")
		end
	end
end)
AddPrefabPostInit("feather_canary", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.tradable then
			inst:AddComponent("tradable")
		end
	end
end)
AddPrefabPostInit("boneshard", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.tradable then
			inst:AddComponent("tradable")
		end
	end
end)