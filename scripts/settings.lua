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
if GetModConfigData("boatHealth") then
	TUNING.BOAT.HEALTH = 1000
end

-- 蘑菇帽孢子速度
TUNING.MUSHROOMHAT_SPORE_TIME = 20

-- 自动雪球机
if GetModConfigData("smartIceMachine") then
	GLOBAL.TUNING.EMERGENCY_BURNT_NUMBER = 1
	GLOBAL.TUNING.EMERGENCY_BURNING_NUMBER = 1 -- number of fires to maintain warning level one automatically
	GLOBAL.TUNING.EMERGENCY_WARNING_TIME = 1 -- minimum length of warning period
	GLOBAL.TUNING.EMERGENCY_RESPONSE_TIME = 2 -- BURNT_NUMBER structures must burn within this time period to trigger flingomatic emergency response
	GLOBAL.TUNING.EMERGENCY_SHUT_OFF_TIME = 10 -- stay on for this length of time
	GLOBAL.TUNING.FIRESUPPRESSOR_MAX_FUEL_TIME = 480*50
end

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

-- 世界再生
AddPrefabPostInit("forest", function(inst)
	inst:AddComponent("naturespawn")
end)