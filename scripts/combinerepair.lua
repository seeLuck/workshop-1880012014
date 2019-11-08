
local _G = GLOBAL

TUNING.REPAIRCOMBINE_maxweapon = 1
TUNING.REPAIRCOMBINE_bonus = 0

local function MakeRepairWithItself(inst)
    if not (_G.TheNet:GetIsServer() or _G.TheNet:IsDedicated()) then 
        return
    end
    if inst and (inst:HasTag("musha_items") or inst:HasTag("yamche")) then
        return -- do not change musha items from musha mod
    end
    if inst.components.finiteuses then
        inst:AddComponent("combinerepairable")
    elseif inst.components.armor then
        inst:AddComponent("combinerepairable")
    elseif inst.components.fueled then
        inst:AddComponent("combinerepairable")
    elseif inst.components.perishable and inst.components.equippable then
        inst:AddComponent("combinerepairable")
    end
end
AddPrefabPostInitAny(MakeRepairWithItself)

-- #############
-- actions stuff
-- #############
local str = _G.STRINGS.ACTIONS.REPAIR~=nil and _G.STRINGS.ACTIONS.REPAIR.GENERIC or "Combine" -- continue to use "repair" string if possible, so we dont have to translate it to various languages
local action = AddAction("COMBINEREPAIR", str, function(act)
	if act.target ~= nil and act.target.components.combinerepairable ~= nil then
        local material = act.invobject
        if material ~= nil and material.components.combinerepairable ~= nil then
            return act.target.components.combinerepairable:Repair(act.doer, material)
        end
    end
end)
action.mount_valid = true
action.encumbered_valid = true
local function ComponentActionCombineRepairable(inst, doer, target, actions, right)
    if right then
        if doer.replica.rider ~= nil and doer.replica.rider:IsRiding() then
            if not (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer)) then
                return
            end
        elseif doer.replica.inventory ~= nil and doer.replica.inventory:IsHeavyLifting() then
            return
        end
        if inst.prefab==target.prefab and inst:HasTag("combinerepairable") and target:HasTag("combinerepairable") then
            table.insert(actions, _G.ACTIONS.COMBINEREPAIR)
        end
    end
end
AddComponentAction("USEITEM", "combinerepairable", ComponentActionCombineRepairable)
AddStategraphActionHandler("wilson",_G.ActionHandler(_G.ACTIONS.COMBINEREPAIR,"dolongaction"))
AddStategraphActionHandler("wilson_client",_G.ActionHandler(_G.ACTIONS.COMBINEREPAIR,"dolongaction"))

