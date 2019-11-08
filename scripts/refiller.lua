local multiplier_guano = 0.4
local multiplier_poop = 1
local multiplier_spoiled_food = 2
local multiplier_rotten_egg = 2
local multiplier_glommer_fuel = 2
TUNING.FERTILIZER_USES = 10

local REFILL = AddAction("REFILL", "Refill Bucket", function(act)
    if act.target ~= nil and
        act.invobject ~= nil and
        act.target.components.finiteuses ~= nil and
        act.invobject.components.refiller ~= nil then
        return act.invobject.components.refiller:DoRefilling(act.target, act.doer)
    end
end)

REFILL.strfn = function(act)
	return act.target and (act.target:HasTag("refillable") and "Refill Bucket")
end
REFILL.mount_valid = true

AddComponentAction("USEITEM", "refiller", function(inst, doer, target, actions)
    if target:HasTag("refillable") and
        not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding() and
        not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer))) then
            table.insert(actions, REFILL)
    end
end)

AddStategraphActionHandler("wilson", GLOBAL.ActionHandler(REFILL, "give"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(REFILL, "give"))

if not GLOBAL.TheNet:GetIsServer() then return end

local function checkRefillableState(inst)
    if inst.components.finiteuses:GetUses() < inst.components.finiteuses.total then
        inst:AddTag("refillable")
    else
        inst:RemoveTag("refillable")
    end
end

AddPrefabPostInit("fertilizer", function(inst)
    inst.components.finiteuses:SetOnFinished(function(inst)
        inst:RemoveComponent("fertilizer")
        inst:AddTag("refillable")
    end)
    checkRefillableState(inst)
    inst:ListenForEvent("percentusedchange", function(inst)
        checkRefillableState(inst)
    end)
end)

AddPrefabPostInit("poop", function(inst)
    inst:AddComponent("refiller")
    inst.components.refiller.refill_value = 5 * multiplier_poop
end)

AddPrefabPostInit("guano", function(inst)
    inst:AddComponent("refiller")
    inst.components.refiller.refill_value = 7.5 * multiplier_guano
end)

AddPrefabPostInit("spoiled_food", function(inst)
    inst:AddComponent("refiller")
    inst.components.refiller.refill_value = 1.25 * multiplier_spoiled_food
end)

AddPrefabPostInit("rottenegg", function(inst)
    inst:AddComponent("refiller")
    inst.components.refiller.refill_value = 1.25 * multiplier_rotten_egg
end)

AddPrefabPostInit("glommerfuel", function(inst)
    inst:AddComponent("refiller")
    inst.components.refiller.refill_value = 5 * multiplier_glommer_fuel
end)


