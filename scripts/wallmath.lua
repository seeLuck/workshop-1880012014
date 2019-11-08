PrefabFiles = {
}
Assets = {
}

local inithealth = .25
-- local Recipes = rawget(GLOBAL,"AllRecipes") or (rawget(GLOBAL,"GetAllKnownRecipes") and GLOBAL.GetAllKnownRecipes())

--Repair tuning
--in most cases, it takes 1 raw resource to make a wall item
--maybe I should fetch the crafting cost and crafting amount from the recipes?
TUNING.REPAIR_CUTGRASS_HEALTH = TUNING.HAYWALL_HEALTH * inithealth

TUNING.REPAIR_LOGS_HEALTH = TUNING.WOODWALL_HEALTH * inithealth
TUNING.REPAIR_BOARDS_HEALTH = TUNING.REPAIR_LOGS_HEALTH * 4
TUNING.REPAIR_STICK_HEALTH = TUNING.REPAIR_LOGS_HEALTH * .5

TUNING.REPAIR_ROCKS_HEALTH = TUNING.STONEWALL_HEALTH * inithealth
TUNING.REPAIR_CUTSTONE_HEALTH = TUNING.REPAIR_ROCKS_HEALTH * 3

TUNING.REPAIR_THULECITE_PIECES_HEALTH = TUNING.RUINSWALL_HEALTH * inithealth

--DST
if TUNING.MOONROCKWALL_HEALTH then
--it takes three moonrock nuggets to make a wall item
TUNING.REPAIR_MOONROCK_NUGGET_HEALTH = TUNING.MOONROCKWALL_HEALTH * inithealth / 3
TUNING.REPAIR_MOONROCK_CRATER_HEALTH = TUNING.REPAIR_MOONROCK_NUGGET_HEALTH * 3
end

--Island Adventures
if TUNING.LIMESTONEWALL_HEALTH then
TUNING.REPAIR_CORAL_HEALTH = TUNING.LIMESTONEWALL_HEALTH * inithealth
TUNING.REPAIR_LIMESTONE_HEALTH = TUNING.LIMESTONEWALL_HEALTH * 3
end


local function adjustrepair(maxhealth)
	return function(inst)
		if inst.components.repairer then
			inst.components.repairer.healthrepairvalue = maxhealth * inithealth
		end
	end
end
local function adjustinit(inst)
	if inst.components.health and GLOBAL.GetTime() > 0 then --ignore worldgen walls
		if inst.components.health.SetCurrentHealth then
			inst.components.health:SetCurrentHealth(inst.components.health.maxhealth * inithealth)
		else
			inst.components.health.currenthealth = inst.components.health.maxhealth * inithealth
		end
		inst.components.health:DoDelta(0)
	end
end

AddPrefabPostInit("wall_hay_item", adjustrepair(TUNING.HAYWALL_HEALTH))
AddPrefabPostInit("wall_hay", adjustinit)
AddPrefabPostInit("wall_wood_item", adjustrepair(TUNING.WOODWALL_HEALTH))
AddPrefabPostInit("wall_wood", adjustinit)
AddPrefabPostInit("wall_stone_item", adjustrepair(TUNING.STONEWALL_HEALTH))
AddPrefabPostInit("wall_stone", adjustinit)
AddPrefabPostInit("wall_ruins_item", adjustrepair(TUNING.RUINSWALL_HEALTH))
AddPrefabPostInit("wall_ruins", adjustinit)
AddPrefabPostInit("wall_moonrock_item", adjustrepair(TUNING.MOONROCKWALL_HEALTH))
AddPrefabPostInit("wall_moonrock", adjustinit)
AddPrefabPostInit("wall_limestone_item", adjustrepair(TUNING.LIMESTONEWALL_HEALTH))
AddPrefabPostInit("wall_limestone", adjustinit)
AddPrefabPostInit("wall_enforcedlimestone_item", adjustrepair(TUNING.ENFORCEDLIMESTONEWALL_HEALTH))
AddPrefabPostInit("wall_enforcedlimestone", adjustinit)
