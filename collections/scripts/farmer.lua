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
STRINGS.RECIPE_DESC.OLDFISH_FARMHOME = "帮你干活的农民"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.OLDFISH_FARMHOME = "漂亮的农屋"
STRINGS.NAMES.OLDFISH_FARMER = "农民"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.OLDFISH_FARMER = "铲斧稿锤矛网"

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
        Ingredient("boards", 40),
        Ingredient("cutstone", 20),
        Ingredient("twigs", 40),
        Ingredient("cutgrass", 40),
        Ingredient("goldnugget", 20),
        Ingredient("silk", 20),
        Ingredient("stinger", 20),
        Ingredient("pigskin", 10)
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


local needTags = {
    "berrybush",    
    "berrybush2",
    "berrybush_juicy",
    "grass",
    "sapling",
    "sapling_moon",
    "firesuppressor",
    "berries",
    "beebox",
    "berries_juicy",
    "cutgrass",
    "twigs",
    "mushroom_farm",
    "meatrack",
    "evergreen",
    "slow_farmplot",
    "fast_farmplot",
    "rock_avocado_bush",
    "rock_avocado_fruit",
    "marbleshrub_tall"
}

--添加独一无二的标签，方便农民快速定位
for k,v in ipairs(needTags) do
    AddPrefabPostInit(v, function (inst)
        inst:AddTag("oldfish_"..v)
    end)
end