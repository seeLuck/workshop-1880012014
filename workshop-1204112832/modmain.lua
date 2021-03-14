local require = GLOBAL.require

local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

PrefabFiles = {
    "pickingperd",
    "pickingshrine",
}

Assets = {
	Asset("ATLAS", "images/inventoryimages/pickingshrine.xml"),
}

if GetModConfigData("language") == 2 then
	STRINGS.NAMES.PICKINGSHRINE = "采摘祭坛"
	STRINGS.RECIPE_DESC.PICKINGSHRINE = "从忙碌的农场生活中解放！"
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.PICKINGSHRINE = "我现在是农场主了~"
	STRINGS.NAMES.PICKINGPERD = "工作火鸡"
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.PICKINGPERD = "工作非常勤勉啊"
else STRINGS.NAMES.PICKINGSHRINE = "Picking Altar" 
	STRINGS.RECIPE_DESC.PICKINGSHRINE = "Free from the busy farm life!" 
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.PICKINGSHRINE = "I am the farmer now." 
	STRINGS.NAMES.PICKINGPERD = "Worker Turkey" 
	STRINGS.CHARACTERS.GENERIC.DESCRIBE.PICKINGPERD = "A very hard worker."
end

local pickingshrine = GLOBAL.Recipe("pickingshrine", {Ingredient("boards", 5), Ingredient("goldnugget", 10), Ingredient("redgem", 1)}, RECIPETABS.FARM,  TECH.SCIENCE_TWO,"pickingshrine_placer",1)
pickingshrine.atlas = "images/inventoryimages/pickingshrine.xml"

TUNING.PICKINGPERD_HEALTH = 400

local function FuckGlobalUsingMetatable()
	GLOBAL.setmetatable(env, {
		__index = function(t, k)
			return GLOBAL.rawget(GLOBAL, k)
		end,
	})	
end
FuckGlobalUsingMetatable()

local PERDGIVE = Action()
PERDGIVE.id = "PERDGIVE"
PERDGIVE.str = STRINGS.PERDGIVE
PERDGIVE.fn = function(act)
	if act.doer and act.target and act.target.components.trader and act.doer.feedfood then
		local able, reason = act.target.components.trader:AbleToAccept(act.doer.feedfood, act.doer)
        if not able then
            return false, reason
        end
		act.target.components.trader:AcceptGift(act.doer, act.doer.feedfood, 1)
		act.doer.feedfood = nil
		return true
	end
	return false
end
AddAction(PERDGIVE)