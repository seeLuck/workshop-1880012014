-- 草蜥蜴
TUNING.GRASSGEKKO_MORPH_CHANCE = 0

-- 蜘蛛吃肉
--Make spiders wait longer before trying to eat
GLOBAL.TUNING.SPIDER_EAT_DELAY = 10		--default is 1.5

--Remove edible-ness of following items
AddPrefabPostInit("pigskin", function(inst)
	inst:RemoveComponent("edible")
end)

AddPrefabPostInit("manrabbit_tail", function(inst)
	inst:RemoveComponent("edible")
end)

AddPrefabPostInit("minotaurhorn", function(inst)
	inst:RemoveComponent("edible")
end)

AddPrefabPostInit("deerclops_eyeball", function(inst)
	inst:RemoveComponent("edible")
end)

-- 船血上限
TUNING.BOAT.HEALTH = 2000

-- 蘑菇帽孢子速度
TUNING.MUSHROOMHAT_SPORE_TIME = 20

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