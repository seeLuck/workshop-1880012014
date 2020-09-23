local _G = GLOBAL
_G.RET = {}
local RET = _G.RET
local TUNING = _G.TUNING
local Action = _G.Action
local ACTIONS = _G.ACTIONS
local ActionHandler = _G.ActionHandler
local STRINGS = _G.STRINGS

TUNING.ALLOW={}
TUNING.ALLOW["nightstick"] = true
TUNING.ALLOW["tornado"] = true

RET.SEWLIST = {}
RET.LIST = {}

local ALLOW = TUNING.ALLOW
if ALLOW["nightstick"] then
RET.SEWLIST.NIGHTSTICK={
    {"lightbulb",{
        {"nightstick",72},
    }},
    {"nitre",{
        {"nightstick",72},
    }},
}
end

if ALLOW["tornado"] then
RET.SEWLIST.TORNADO={
    {"gears",{
        {"staff_tornado",5},
    }},
    {"goose_feather",{
        {"staff_tornado",1},
    }},
}
end

for k,v in pairs(RET.SEWLIST) do
    for k1,v1 in pairs(v) do
        table.insert(RET.LIST, v1)
    end
end

local LIST = RET.LIST
local SEWINGNEW = Action({mount_valid=true})
local SEWINGQUICK = Action({mount_valid=true})
local SEWINGQUICKWET = Action({mount_valid=true})
SEWINGNEW.id = "SEWINGNEW"
SEWINGQUICK.id = "SEWINGQUICK"
SEWINGQUICKWET.id = "SEWINGQUICKWET"
SEWINGNEW.str = ACTIONS.REPAIR.str
SEWINGQUICK.str = ACTIONS.ADDFUEL.str
SEWINGQUICKWET.str = ACTIONS.ADDWETFUEL.str

SEWINGNEW.fn = function ( act )
    local sewtool = act.invobject
    local item = act.target
    if sewtool and sewtool.components.sewingnew and item and (item.components.perishable or item.components.finiteuses or item.components.fueled or item.components.armor) then
        sewtool.components.sewingnew:DoSewing(item, act.doer)
    end
    return true
end

SEWINGQUICK.fn = SEWINGNEW.fn
SEWINGQUICKWET.fn = SEWINGNEW.fn

AddAction(SEWINGNEW)
AddAction(SEWINGQUICK)
AddAction(SEWINGQUICKWET)

function SetupActionSewingnew( inst, doer, target, actions, right)
    local sewingnew = inst.components.sewingnew
    if not sewingnew then return end
    --快速填充
    if sewingnew.quick and type(sewingnew.quick) == "table" then
        for k,v in pairs(sewingnew.quick) do
            -- local wetmult = inst:GetIsWet() and 0.7 or 1
            if target.prefab == v then
                if inst:GetIsWet() then
                  table.insert(actions, ACTIONS.SEWINGQUICKWET)
                else
                  table.insert(actions, ACTIONS.SEWINGQUICK)
                end
                return
            end
        end
    end
    --非快速填充
    if type(sewingnew.repair_maps) == "table" then
        for k,v in pairs(sewingnew.repair_maps) do
            if type(v) == "table" then
                if v[1] == target.prefab then
                    table.insert(actions, ACTIONS.SEWINGNEW)
                end
            elseif type(v) == "string" then
                if v == target.prefab then
                    table.insert(actions, ACTIONS.SEWINGNEW)
                end
            end
        end
    end
end

AddComponentAction("USEITEM", "sewingnew", SetupActionSewingnew)

AddStategraphActionHandler("wilson", ActionHandler(SEWINGNEW, "dolongaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(SEWINGNEW, "dolongaction"))

AddStategraphActionHandler("wilson", ActionHandler(SEWINGQUICK, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(SEWINGQUICK, "doshortaction"))

AddStategraphActionHandler("wilson", ActionHandler(SEWINGQUICKWET, "doshortaction"))
AddStategraphActionHandler("wilson_client", ActionHandler(SEWINGQUICKWET, "doshortaction"))

for k,v in pairs(LIST) do
    local prefabname = nil
    local repairmap = nil
    if type(v) == "table" then
        prefabname = v[1]
        repairmap = v[2]
    elseif type(v) == "string" then
        prefabname = v
        repairmap = v
    end
    AddPrefabPostInit(prefabname, function (inst)
        local sewingnew = inst.components.sewingnew
        if sewingnew == nil then
			--if not _G.TheWorld.ismastersim then
			  inst:AddComponent("sewingnew")
		      sewingnew = inst.components.sewingnew
			--end
        end
        if type(repairmap) == "table" then
            for k1,v1 in pairs(repairmap) do
			--if not _G.TheWorld.ismastersim then
                sewingnew:AddRepairMap(v1)
			--end
            end
        elseif type(repairmap) == "string" then
			--if not _G.TheWorld.ismastersim then
            sewingnew:AddRepairMap(repairmap)
		--end
        end
    end)
end
