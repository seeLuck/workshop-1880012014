-- ####################################################################################################
-- ####################################################################################################
-- UpvalueHacker util by rezecib
-- Placed here because if two mods use it but are in different locations bad stuff WILL happen
-- ####################################################################################################
local assert = GLOBAL.assert
local debug = GLOBAL.debug

local UpvalueHacker = {}

local function FindUpvalueHelper(fn, name)
	local i = 1
	while debug.getupvalue(fn, i) and debug.getupvalue(fn, i) ~= name do
		i = i + 1
	end
	local name, value = debug.getupvalue(fn, i)
	return value, i
end

UpvalueHacker.FindUpvalue = function(fn, ...)
	local prv, i, prv_var = nil, nil, "(the starting point)"
	for j,var in ipairs({...}) do
		assert(type(fn) == "function", "We were looking for "..var..", but the value before it, "
			..prv_var..", wasn't a function (it was a "..type(fn)
			.."). Here's the full chain: "..table.concat({"(the starting point)", ...}, ", "))
		prv = fn
		prv_var = var
		fn, i = FindUpvalueHelper(fn, var)
	end
	return fn, i, prv
end

UpvalueHacker.SetUpvalue = function(start_fn, new_fn, ...)
	local _fn, _fn_i, scope_fn = UpvalueHacker.FindUpvalue(start_fn, ...)
	debug.setupvalue(scope_fn, _fn_i, new_fn)
end
-- ####################################################################################################
-- ####################################################################################################

local ReleaseBees = false
local HatDecay = false
local NeutralSpringBees = true

local DecayPercent = 0.02

local function HasBeehatEquipped(inst)
	return inst and inst.components.inventory and inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD) and inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD).prefab == "beehat"
end

local function BeeNiceFn(inst, picker)
	if HasBeehatEquipped(picker) then
		if ReleaseBees then
			inst.components.childspawner:ReleaseAllChildren(nil) -- release "friendly" bees
		end
		
		if HatDecay then
			local beehat = picker.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
			
			if beehat.components.armor then
				local percent = beehat.components.armor:GetPercent()
				beehat.components.armor:SetPercent(percent - DecayPercent)
			end
		end
	else
		inst.components.childspawner:ReleaseAllChildren(picker) -- RELEASE THE BEES!
	end
end

AddPrefabPostInit("beebox", function(inst)

	local updatelevel = UpvalueHacker.FindUpvalue(GLOBAL.Prefabs.beebox.fn, "updatelevel")
	
	local function onharvest(inst, picker)
		if not inst:HasTag("burnt") then
			updatelevel(inst)
			if inst.components.childspawner and not GLOBAL.TheWorld.state.iswinter then
				BeeNiceFn(inst, picker)
			end
		end
	end
	
	if inst.components.harvestable then
        inst.components.harvestable:SetUp("honey", 6, nil, onharvest, updatelevel)
    end
end)


if GLOBAL.KnownModIndex:GetModActualName("DST Fish Farm") then
    
    AddPrefabPostInit("w_pond", function (inst)
    
        local updatelevel = UpvalueHacker.FindUpvalue(GLOBAL.Prefabs.w_pond.fn, "updatelevel")

        local function onharvest(inst, picker)
            updatelevel(inst)
            if inst.components.childspawner and not GLOBAL.TheWorld.state.iswinter then
                BeeNiceFn(inst, picker)
            end
        end

        if inst.components.harvestable then
            inst.components.harvestable:SetUp("fish", 3, nil, onharvest, updatelevel)
        end
    end)
end

if NeutralSpringBees then
	local function SpringBeeRetarget(inst)
		return GLOBAL.TheWorld.state.isspring and
			GLOBAL.FindEntity(inst, 4,
				function(guy)
					return not HasBeehatEquipped(guy) and inst.components.combat:CanTarget(guy)
				end,
				{ "_combat", "_health" },
				{ "insect", "INLIMBO" },
				{ "character", "animal", "monster" })
			or nil
	end
	
	AddPrefabPostInit("bee", function(inst)
		if inst.components.combat then
			inst.components.combat:SetRetargetFunction(2, SpringBeeRetarget)
		end
	end)
end

-- ####################################################################################################
-- beehat was buffed; since the Bee Queen is a thing, we shouldn't let the Beekeeper Hat degrade over time
-- ####################################################################################################
--[[ AddPrefabPostInit("beehat", function(inst)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = GLOBAL.FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(GLOBAL.TUNING.EARMUFF_PERISHTIME / 3)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    
    inst:ListenForEvent("percentusedchange", function (inst, data)
    
    local maxfuel = GLOBAL.TUNING.EARMUFF_PERISHTIME / 3
    local maxcondition = TUNING.ARMOR_BEEHAT
    
        if inst.components.armor then
            inst.components.armor.condition = math.min(data.percent * maxcondition)
        end
        
        if inst.components.fueled then
            inst.components.fueled.currentfuel = math.min(data.percent * maxfuel)
        end
    end)
end)]]--