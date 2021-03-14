require "behaviours/wander"
require "behaviours/leash"
require "behaviours/standstill"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5
local SEE_FOOD_DIST = 15
local SEE_BUSH_DIST = 30
local SEE_SHRINE_DIST = 20
local MIN_SHRINE_WANDER_DIST = 4
local MAX_SHRINE_WANDER_DIST = 15
local MAX_WANDER_DIST = 80
local SHRINE_LOITER_TIME = 4
local SHRINE_LOITER_TIME_VAR = 3

local PerdBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function IsBerry(item,inst)
    return item:IsNear(inst._shrine,SEE_FOOD_DIST) and
    (item.prefab == "berries" or
        item.prefab == "berries_juicy" or
        item.prefab == "cutgrass" or
        item.prefab == "twigs" or
        item.prefab == "bird_egg")
end

local function HasBerry(item,inst)
    if not item:IsNear(inst._shrine,SEE_FOOD_DIST) then return end
    if item.components.dryer then
        return item:HasTag("dried")
    else
        return item.components.pickable ~= nil and item.components.pickable.canbepicked and
        (item.components.pickable.product == "berries" or
        item.components.pickable.product == "berries_juicy" or
        item.components.pickable.product == "cutgrass" or
        item.components.pickable.product == "twigs")
    end
end

local function FindShrine(inst)
    if not inst.seekshrine then
        inst._shrine = nil
    elseif inst._shrine == nil
        or not inst._shrine:IsValid()
        or not inst._shrine:IsNear(inst, SEE_SHRINE_DIST)
        or (inst._shrine.components.burnable ~= nil and
            inst._shrine.components.burnable:IsBurning() or
            inst._shrine:HasTag("burnt")) then
        local x, y, z = inst.Transform:GetWorldPosition()
        inst._shrine = TheSim:FindEntities(x, y, z, SEE_SHRINE_DIST, { "pickingshrine" }, { "burnt", "fire" })[1]
    end
    return inst._shrine
end

local function EatFoodAction(inst, checksafety)
    if inst.components.container:IsFull() then return end
    local shrine = FindShrine(inst)
    if shrine == nil then return end
    local target = FindEntity(inst, SEE_BUSH_DIST, IsBerry, nil , { "INLIMBO" })
    return target ~= nil and BufferedAction(inst, target, ACTIONS.PICKUP)
            or nil
end


local function EatFoodWhenSafe(inst)
    return EatFoodAction(inst, true)
end

local function EatFoodAnytime(inst)
    return EatFoodAction(inst, false)
end

local function PickBerriesAction(inst)
    if inst.components.container:IsFull() then return end
    local shrine = FindShrine(inst)
    if shrine == nil then return end
    local target = FindEntity(inst, SEE_BUSH_DIST, HasBerry, nil ,{"INLIMBO"})
    if target ~= nil and target:HasTag("dried") then
        return BufferedAction(inst, target, ACTIONS.HARVEST)
    elseif target ~= nil and target.components.pickable then
        return BufferedAction(inst, target, ACTIONS.PICK)
    end
end

local function HasBeefalo(item,inst)
    if not item:IsNear(inst._shrine,SEE_FOOD_DIST) then return end
    if item:HasTag("beefalo") and item.components.domesticatable and item.components.hunger then
        return item.components.domesticatable:GetDomestication() > 0 and  not item.components.domesticatable.domesticated and
        (item.components.hunger.current < 200 or item.components.domesticatable:GetObedience() < 0.5)
    end
end

local function FeedBeefalo(inst)
    local target = FindEntity(inst, SEE_BUSH_DIST, HasBeefalo, nil ,{"INLIMBO"})
    if inst.feedfood and target then 
        return BufferedAction(inst, target, ACTIONS.PERDGIVE)
    end
    local mycontainer = inst.components.container
    if mycontainer:IsEmpty() then return end
    local shrine = FindShrine(inst)
    if shrine == nil then return end
    local item = nil
    for i = mycontainer.numslots - 3, mycontainer.numslots do
        local temp = mycontainer.slots[i]
        if temp and temp.components.edible and 
            (temp.components.edible.foodtype == FOODTYPE.ROUGHAGE 
            or temp.components.edible.foodtype == FOODTYPE.VEGGIE) then
            if temp.components.perishable == nil or temp:HasTag("fresh") then
                item = temp.prefab
                break
            end
        end
    end
    if item == nil then return end
    if target ~= nil then
        mycontainer:ConsumeByName(item,1)
        inst.feedfood = SpawnPrefab(item)
        return BufferedAction(inst, target, ACTIONS.PERDGIVE)
    end
end

local function ShrinePos(inst)
    return inst._shrine:GetPosition()
end

local function ShrineWanderPos(inst)
    inst._lastshrinewandertime = GetTime()
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = inst._shrine.Transform:GetWorldPosition()
    local dx, dz = x - x1, z - z1
    local nlen = MIN_SHRINE_WANDER_DIST / math.sqrt(dx * dx + dz * dz)
    return Vector3(x1 + dx * nlen, 0, z1 + dz * nlen)
end

local function ShouldLoiter(inst)
    if inst._lastshrinewandertime == nil or inst:IsNear(inst._shrine, MAX_SHRINE_WANDER_DIST) then
        return false
    end
    local t = GetTime() - inst._lastshrinewandertime - SHRINE_LOITER_TIME
    if t <= 0 or math.random() * SHRINE_LOITER_TIME_VAR >= t then
        return true
    end
    inst._lastshrinewandertime = nil
    return false
end

function PerdBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.health.takingfiredamage or self.inst.components.hauntable.panic end, "Panic",
            Panic(self.inst)),


        IfNode(function() return self.inst.seekshrine end, "Seek Shrine",
            WhileNode(function() return FindShrine(self.inst) ~= nil end, "Approach Shrine",
                PriorityNode({
                    DoAction(self.inst, EatFoodWhenSafe, "Eat Food", true),
                    WhileNode(function() return ShouldLoiter(self.inst) end, "Loiter",
                        StandStill(self.inst)),
                    Leash(self.inst, ShrinePos, MAX_SHRINE_WANDER_DIST, MIN_SHRINE_WANDER_DIST),
                    DoAction(self.inst, PickBerriesAction, "Pick Berries", true),
                    DoAction(self.inst, FeedBeefalo, "Feed Beefalo", true),
                    Wander(self.inst, ShrineWanderPos, MAX_SHRINE_WANDER_DIST - MIN_SHRINE_WANDER_DIST, { minwaittime = SHRINE_LOITER_TIME * .5, randwaittime = SHRINE_LOITER_TIME_VAR }),
                }, .25))),
        RunAway(self.inst, "hostile", SEE_PLAYER_DIST, STOP_RUN_DIST),
        DoAction(self.inst, PickBerriesAction, "Pick Berries", true),
    }, .25)
    self.bt = BT(self.inst, root)
end

return PerdBrain
