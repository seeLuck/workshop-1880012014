modimport "scripts/tools/waffles"

TUNING.EPICHEALTHBAR_TIMEOUT = 10
TUNING.EPICHEALTHBAR_SEARCH_DIST = 20

table.insert(Waffles.GetPath(env, "Assets"), Asset("ATLAS", "images/ui/boss_hb.xml"))

local EpicHealthbar = require "widgets/epichealthbar/healthbar"
AddClassPostConstruct("widgets/controls", function(self)
	self.epichealthbar = self.top_root:AddChild(EpicHealthbar(self.owner))
end)

local NETVAR_EXCEPTIONS =
{
	toadstool_dark = net_uint,
	crabking = net_uint,
}

local function OnCurrentHealthDirty(inst)
    inst.epichealthbar.currenthealth = inst.epichealthbar_currenthealth:value()
end

local function OnMaxHealthDirty(inst)
    inst.epichealthbar.maxhealth = inst.epichealthbar_maxhealth:value()
end

local function AddEpicHealthbarNetvars(inst)
	if inst.epichealthbar_currenthealth ~= nil then
		return
	end
	
	local netvar = NETVAR_EXCEPTIONS[inst.prefab] or net_ushortint
    inst.epichealthbar_currenthealth = netvar(inst.GUID, "epichealthbar_currenthealth", "epichealthbar_currenthealth_dirty")
    inst.epichealthbar_maxhealth = netvar(inst.GUID, "epichealthbar_maxhealth", "epichealthbar_maxhealth_dirty")
    
   	if not TheNet:IsDedicated() then
       	inst.epichealthbar = { currenthealth = 0, maxhealth = 0 }
		inst:ListenForEvent("epichealthbar_currenthealth_dirty", OnCurrentHealthDirty)
       	inst:ListenForEvent("epichealthbar_maxhealth_dirty", OnMaxHealthDirty)		
   	end
		
   	if not TheWorld.ismastersim then
       	return
   	end

   	if inst.components.health ~= nil then
       	inst.epichealthbar_currenthealth:set(inst.components.health.currenthealth)
       	inst.epichealthbar_maxhealth:set(inst.components.health.maxhealth)
   	end
end

for i, v in ipairs({ "rook", "knight", "bishop" }) do
	AddPrefabPostInit("shadow_" .. v, AddEpicHealthbarNetvars)
end
AddPrefabPostInit("crabking", AddEpicHealthbarNetvars)

local health_replica = require "components/health_replica"

Waffles.Parallel(health_replica, "_ctor", function(self, inst)
	if inst:HasTag("epic") then
		AddEpicHealthbarNetvars(inst)
	end
end, true)

--[[!]] if not TheNet:GetIsServer() then return end

Waffles.Parallel(health_replica, "SetCurrent", function(self, current)
    if self.inst.epichealthbar_currenthealth ~= nil then
        self.inst.epichealthbar_currenthealth:set(current)
    end
end, true)

Waffles.Parallel(health_replica, "SetMax", function(self, max)
    if self.inst.epichealthbar_maxhealth ~= nil then
        self.inst.epichealthbar_maxhealth:set(max)
    end
end, true)