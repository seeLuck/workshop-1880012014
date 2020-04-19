local require = GLOBAL.require
local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

STRINGS.REFRESH_TIME = 1
STRINGS.BACKPACK_SETTING = 1

STRINGS.FERTILIZER_NOTIFICATION = "我没有材料施肥"
STRINGS.PLANT_NOTIFICATION = "我没有种子种植了"
STRINGS.ACTIVATE_MUSHROOM = "我需要活木激活蘑菇农场"
STRINGS.FIRESUPPRESSOR_FUEL = "我没有材料给灭火器添加燃料了"
STRINGS.CONTAINER_FULL = "我的袋子已经满了 无法再装下更多的东西了"

STRINGS.NAMES.OLDFISH_FARMHOME = "农屋"
STRINGS.RECIPE_DESC.OLDFISH_FARMHOME = "农民温馨的家！"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.OLDFISH_FARMHOME = "漂亮的农屋"
STRINGS.NAMES.OLDFISH_FARMER = "农民"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.OLDFISH_FARMER = "听从指挥！"

PrefabFiles = {
    "oldfish_farmer",
    "oldfish_farmhome"
}
Assets = {
    Asset("ATLAS", "images/inventoryimages/oldfish_farmhome.xml"),
    Asset("ANIM", "anim/ui_chest_8x8.zip"),
}
local oldfish_farmhome = GLOBAL.Recipe(
    "oldfish_farmhome",
    {
        Ingredient("boards", 10),
        Ingredient("cutstone", 5)
    },
    RECIPETABS.FARM,
    TECH.SCIENCE_TWO,
    "oldfish_farmhome_placer",
    1)

oldfish_farmhome.atlas = "images/inventoryimages/oldfish_farmhome.xml"

local function FuckGlobalUsingMetatable()
    GLOBAL.setmetatable(env, {   __index = function(t, k)
        return GLOBAL.rawget(GLOBAL, k)
    end,  })
end

FuckGlobalUsingMetatable()

local PERDGIVE = Action()
PERDGIVE.id = "PERDGIVE"
PERDGIVE.str = STRINGS.PERDGIVE
PERDGIVE.fn = function(act)
    if act.doer and act.target and act.target.components.trader then
        local able, reason = act.target.components.trader:AbleToAccept(act.invobject, act.doer)
        if not able then
            return false,
            reason
        end
        act.target.components.trader:AcceptGift(act.doer, act.invobject, 1)
        return true
    end
    return false
end
AddAction(PERDGIVE)


local AUTO_PLANT = GLOBAL.Action()
AUTO_PLANT.id = "AUTO_PLANT"
AUTO_PLANT.str = "AUTO_PLANT"
AUTO_PLANT.fn = function(act)
    if act.doer.components.container ~= nil then
        local seed = act.doer.components.container:RemoveItem(act.invobject)
        if seed ~= nil then
            if act.target.components.grower ~= nil and act.target.components.grower:PlantItem(seed) then
                return true
            end
        end
    end
    return false
end
AddAction(AUTO_PLANT)


local AUTO_FERTILIZE = GLOBAL.Action()
AUTO_FERTILIZE.id = "AUTO_FERTILIZE"
AUTO_FERTILIZE.str = "AUTO_FERTILIZE"
AUTO_FERTILIZE.fn = function(act)
    if act.doer.components.container ~= nil then
        if act.invobject ~= nil then
            if act.target.components.grower ~= nil  then
                act.target.components.grower:Fertilize(act.invobject, act.doer)
                return true
            elseif act.target.components.pickable ~= nil  then
                act.target.components.pickable:Fertilize(act.invobject, act.doer)
                return true
            end
        end
    end
    return false
end
AddAction(AUTO_FERTILIZE)

local AUTO_FARM_PLANT = GLOBAL.Action()
AUTO_FARM_PLANT.id = "AUTO_FARM_PLANT"
AUTO_FARM_PLANT.str = "AUTO_FARM_PLANT"
AUTO_FARM_PLANT.fn = function(act)

    local result = string.find(act.invobject.prefab, "dug_")
    if result ~= nil then
        act.invobject.components.deployable.ondeploy(act.invobject,act:GetActionPoint(), act.doer)
    else
        local obj = act.doer.components.container and act.doer.components.container:RemoveItem(act.invobject)
        obj.components.deployable.ondeploy(obj,act:GetActionPoint(), act.doer)
    end
    return true

end
AddAction(AUTO_FARM_PLANT)

local function oldfish_widgetcreation()
    local params = {}
    params.farmer = {
        widget = {
            slotpos = {},
            animbank = "ui_chest_8x8",
            animbuild = "ui_chest_8x8",
            pos = GLOBAL.Vector3(0, 200, 0),
            side_align_tip = 160,
        },
        type = "chest"
    }

    for y = 7, 0, -1 do
        for x = 0, 7 do
            table.insert(params.farmer.widget.slotpos, GLOBAL.Vector3(70 * x -250, 70 * y - 270, 0))
        end
    end

    local containers = GLOBAL.require "containers"
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, params.farmer.widget.slotpos ~= nil and #params.farmer.widget.slotpos or 0)
    local old_widgetsetup = containers.widgetsetup
    function containers.widgetsetup(container, prefab, data)
        local pref = prefab or container.inst.prefab
        if pref == "farmer" then
            local t = params[pref]
            if t ~= nil then
                for k, v in pairs(t) do
                    container[k] = v
                end
                container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
            end
        else
            return old_widgetsetup(container, prefab)
        end
    end

end

oldfish_widgetcreation()


local needTags = {"berrybush","grass","berrybush2","berrybush_juicy","firesuppressor","berries","beebox","berries_juicy","cutgrass","twigs","mushroom_farm","meatrack","slow_farmplot","fast_farmplot"}

--添加独一无二的标签，方便农民快速定位
for k,v in ipairs(needTags) do
    AddPrefabPostInit(v, function (inst)
        inst:AddTag("oldfish_"..v)
    end)
end

local function FindTarget(inst, radius)
    return FindEntity(
        inst,
        SpringCombatMod(radius),
        function(guy)
            return inst.components.combat:CanTarget(guy) and 
            (not guy:HasTag("oldfish_farmer") and (not guy:HasTag("monster") or guy:HasTag("player")) 
            or (guy:HasTag("oldfish_farmer") and 
                guy.components.container:GetItemInSlot(4) ~= nil and 
                guy.components.container:GetItemInSlot(4).prefab == "spear")
            )
        end,
        { "_combat", "character" },
        { "spiderwhisperer", "spiderdisguise", "INLIMBO" },
        { "oldfish_farmer", "player" }
    )
end

local function SpiderTarget(inst)
    return FindTarget(inst, inst.components.knownlocations:GetLocation("investigate") ~= nil and TUNING.SPIDER_INVESTIGATETARGET_DIST or TUNING.SPIDER_TARGET_DIST)
end

AddPrefabPostInit("spider", function(inst)
    if inst.components.combat ~= nil then
        inst.components.combat:SetRetargetFunction(1, SpiderTarget)
    end
end)
AddPrefabPostInit("spider_warrior", function(inst)
    if inst.components.combat ~= nil then
        inst.components.combat:SetRetargetFunction(1, SpiderTarget)
    end
end)

local function QueenTarget(inst)
    if not inst.components.health:IsDead() and not inst.components.sleeper:IsAsleep() then
        local oldtarget = inst.components.combat.target
        local newtarget = FindEntity(inst, 10, 
            function(guy) 
                return inst.components.combat:CanTarget(guy) and 
                (not guy:HasTag("oldfish_farmer") and (not guy:HasTag("monster") or guy:HasTag("player")) 
                or (guy:HasTag("oldfish_farmer") and 
                    guy.components.container:GetItemInSlot(4) ~= nil and 
                    guy.components.container:GetItemInSlot(4).prefab == "spear")
                )
            end,
            { "character", "_combat" },
            { "spiderwhisperer", "spiderdisguise", "INLIMBO" },
            { "oldfish_farmer", "player" }
        )

        if newtarget ~= nil and newtarget ~= oldtarget then
            inst.components.combat:SetTarget(newtarget)
        end
    end
end
AddPrefabPostInit("spiderqueen", function(inst)
    if inst.components.combat ~= nil then
        inst.components.combat:SetRetargetFunction(3, QueenTarget)
    end
end)

local function is_meat(item)
    return item.components.edible ~= nil and item.components.edible.foodtype == FOODTYPE.MEAT and not item:HasTag("smallcreature")
end

local function BunnymanTarget(inst)
    return not inst:IsInLimbo()
        and FindEntity(
                inst,
                TUNING.PIG_TARGET_DIST,
                function(guy)
                    return inst.components.combat:CanTarget(guy) and 
                    (guy:HasTag("monster") 
                    or (guy:HasTag("oldfish_farmer") and 
                        guy.components.container:GetItemInSlot(3) ~= nil and 
                        guy.components.container:GetItemInSlot(3).prefab == "hammer")
                    or (not guy:HasTag("oldfish_farmer") and
                        guy.components.inventory ~= nil and
                        guy:IsNear(inst, TUNING.BUNNYMAN_SEE_MEAT_DIST) and
                        guy.components.inventory:FindItem(is_meat) ~= nil)
                    )
                end,
                { "_combat", "_health" }, -- see entityreplica.lua
                nil,
                { "oldfish_farmer", "monster", "player" }
            )
        or nil
end

AddPrefabPostInit("bunnyman", function(inst)
    if inst.components.combat ~= nil then
        inst.components.combat:SetRetargetFunction(3, BunnymanTarget)
    end
end)


local function PigmanTarget(inst)
	local exclude_tags = { "playerghost", "INLIMBO" }
	if inst.components.follower.leader ~= nil then
		table.insert(exclude_tags, "abigail")
	end
	if inst.components.minigame_spectator ~= nil then
		table.insert(exclude_tags, "player") -- prevent spectators from auto-targeting webber
	end

    local oneof_tags = {"monster", "oldfish_farmer"}
    if not inst:HasTag("merm") then
        table.insert(oneof_tags, "merm")
    end

    return not inst:IsInLimbo()
        and FindEntity(
                inst,
                TUNING.PIG_TARGET_DIST,
                function(guy)
                    return (guy:HasTag("oldfish_farmer") and 
                    guy.components.container:GetItemInSlot(3) ~= nil and 
                    guy.components.container:GetItemInSlot(3).prefab == "hammer")
                        or (not guy:HasTag("oldfish_farmer") and 
                        (guy.LightWatcher == nil or guy.LightWatcher:IsInLight()) and 
                        inst.components.combat:CanTarget(guy))
                end,
                { "_combat" }, -- see entityreplica.lua
                exclude_tags,
                oneof_tags
            )
        or nil
end

AddPrefabPostInit("pigman", function(inst)
    if inst.components.combat ~= nil then
        inst.components.combat:SetRetargetFunction(3, PigmanTarget)
    end
end)

AddComponentPostInit("combat",function(inst)
	if not GLOBAL.TheWorld.ismastersim then
		return
	end
	local oldbonusdamagefn = inst.bonusdamagefn
	inst.bonusdamagefn = function(attacker, target, damage, weapon)
		local bonus = 0
		if oldbonusdamagefn then
			bonus = oldbonusdamagefn(attacker, target, damage, weapon) or 0
		end
		if target.prefab == "oldfish_farmer" and (attacker.prefab == "bunnyman" or attacker.prefab == "pigman" or
        attacker.prefab == "bee" or attacker.prefab == "leif" or attacker.prefab == "frog" or 
        attacker.prefab == "spider" or attacker.prefab == "spider_warrior" or attacker.prefab == "spiderqueen") then
			bonus = 0 - damage
		end
		return bonus
	end
end)