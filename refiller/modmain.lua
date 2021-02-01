local multiplier_guano = GetModConfigData("consumption") and 3 or 1
local multiplier_poop = GetModConfigData("consumption") and 2 or 0.5
local multiplier_spoiled_food = GetModConfigData("consumption") and 2 or 0.5
local multiplier_rotten_egg = GetModConfigData("consumption") and 3 or 1
local multiplier_glommer_fuel = GetModConfigData("consumption") and 5 or 1.5
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

local function fertilizer_ondeploy(inst, pt, deployer)
    if inst.components.fertilizer ~= nil then
        local tile_x, tile_z = GLOBAL.TheWorld.Map:GetTileCoordsAtPoint(pt:Get())
        local nutrients = inst.components.fertilizer.nutrients
        GLOBAL.TheWorld.components.farming_manager:AddTileNutrients(tile_x, tile_z, nutrients[1], nutrients[2], nutrients[3])

        inst.components.fertilizer:OnApplied(deployer)
        if deployer ~= nil and deployer.SoundEmitter ~= nil and inst.components.fertilizer ~= nil and inst.components.fertilizer.fertilize_sound ~= nil then
            deployer.SoundEmitter:PlaySound(inst.components.fertilizer.fertilize_sound)
        end
    end
end

AddComponentPostInit("fertilizer", function(self) 
    local function _OnApplied(inst)
        local final_use = true
        if self.inst.components.finiteuses ~= nil then
            self.inst.components.finiteuses:Use()
            final_use = self.inst.components.finiteuses:GetUses() <= 0
        end

        if self.onappliedfn ~= nil then
            self.onappliedfn(self.inst, final_use, doer, target)
        end

        if final_use and self.inst.prefab ~= 'fertilizer' then
            if self.inst.components.stackable ~= nil then
                self.inst.components.stackable:Get():Remove()
            else
                self.inst:Remove()
            end
        end
    end
    self.OnApplied = _OnApplied
end)

AddPrefabPostInit("fertilizer", function(inst)
    inst.components.deployable.ondeploy = fertilizer_ondeploy
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
    inst.components.refiller.refill_value = multiplier_poop
end)

AddPrefabPostInit("guano", function(inst)
    inst:AddComponent("refiller")
    inst.components.refiller.refill_value = multiplier_guano
end)

AddPrefabPostInit("spoiled_food", function(inst)
    inst:AddComponent("refiller")
    inst.components.refiller.refill_value = multiplier_spoiled_food
end)

AddPrefabPostInit("rottenegg", function(inst)
    inst:AddComponent("refiller")
    inst.components.refiller.refill_value = multiplier_rotten_egg
end)

AddPrefabPostInit("glommerfuel", function(inst)
    inst:AddComponent("refiller")
    inst.components.refiller.refill_value = multiplier_glommer_fuel
end)


