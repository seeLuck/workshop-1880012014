local _G = GLOBAL

TUNING.REPAIRCOMBINE_maxweapon = 1.5
TUNING.REPAIRCOMBINE_overmaxfiniteuses = false
TUNING.REPAIRCOMBINE_overmaxarmor = false
TUNING.REPAIRCOMBINE_overmaxfueled = false
TUNING.REPAIRCOMBINE_overmaxperishable = false
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

-- #############
-- save current/max values if we change the max ones
-- #############

if TUNING.REPAIRCOMBINE_overmaxfiniteuses then -- we have to save the new max values
    AddComponentPostInit("finiteuses", function(self)
        local old_OnSave = self.OnSave
        local function new_OnSave(self,...) 
            if old_OnSave~=nil then data = old_OnSave(self,...) else data = {} end 
            if data==nil then data = {} end
            data.total = self.total
            data.uses = self.current -- we also have to save this again, in case it is equal to max, because of original onsave code
            return data 
        end
        self.OnSave = new_OnSave
        local old_OnLoad = self.OnLoad
        local function new_OnLoad(self,data,...) 
            if data~=nil and data.total~=nil then 
                self.total = data.total
            end 
            if old_OnLoad~=nil then return old_OnLoad(self,data,...) end 
        end
        self.OnLoad = new_OnLoad
    end)
end
if TUNING.REPAIRCOMBINE_overmaxarmor then -- we have to save the new max values
    AddComponentPostInit("armor", function(self)
        local old_OnSave = self.OnSave
        local function new_OnSave(self,...) 
            if old_OnSave~=nil then data = old_OnSave(self,...) else data = {} end 
            if data==nil then data = {} end
            data.maxcondition = self.maxcondition
            data.condition = self.condition -- we also have to save this again, in case it is equal to max, because of original onsave code
            return data 
        end
        self.OnSave = new_OnSave
        local old_OnLoad = self.OnLoad
        local function new_OnLoad(self,data,...) 
            if data~=nil and data.maxcondition~=nil then 
                self.maxcondition = data.maxcondition
            end 
            if old_OnLoad~=nil then return old_OnLoad(self,data,...) end 
        end
        self.OnLoad = new_OnLoad
    end)
end
if TUNING.REPAIRCOMBINE_overmaxfueled then -- we have to save the new max values
    AddComponentPostInit("fueled", function(self)
        local old_OnSave = self.OnSave
        local function new_OnSave(self,...) 
            if old_OnSave~=nil then data = old_OnSave(self,...) else data = {} end 
            if data==nil then data = {} end
            data.maxfuel = self.maxfuel
            data.fuel = self.currentfuel -- we also have to save this again, in case it is equal to max, because of original onsave code
            return data 
        end
        self.OnSave = new_OnSave
        local old_OnLoad = self.OnLoad
        local function new_OnLoad(self,data,...) 
            if data~=nil and data.maxfuel~=nil then 
                self.maxfuel = data.maxfuel
            end 
            if old_OnLoad~=nil then return old_OnLoad(self,data,...) end 
        end
        self.OnLoad = new_OnLoad
    end)
end
if TUNING.REPAIRCOMBINE_overmaxperishable then -- we have to save the new max values
    AddComponentPostInit("perishable", function(self)
        local old_OnSave = self.OnSave
        local function new_OnSave(self,...) 
            if old_OnSave~=nil then data = old_OnSave(self,...) else data = {} end 
            if data==nil then data = {} end
            data.perishtime = self.perishtime
            return data 
        end
        self.OnSave = new_OnSave
        local old_OnLoad = self.OnLoad
        local function new_OnLoad(self,data,...) 
            if data~=nil and data.perishtime~=nil then 
                self.perishtime = data.perishtime
            end 
            if old_OnLoad~=nil then return old_OnLoad(self,data,...) end 
        end
        self.OnLoad = new_OnLoad
    end)
end