--==[ ПОЛОСКА ЗДОРОВЬЯ БОССОВ ]==--

Assets = { Asset("ATLAS", "images/ui/boss_hb.xml") }

_G = GLOBAL; require = _G.require
IsDedicated = _G.TheNet:IsDedicated()

-- Инициализация --

local EpicHealthbar = require "widgets/epichealthbar/bar"
AddClassPostConstruct("widgets/controls", function(self)
    EpicHealthbar.init(self)
end)

-- Даём значения боссам --

local function OnHealthEpicDirty(inst)
    inst.health_epic.act = inst.net_health_epic:value()
end

local function OnHealthEpicMaxDirty(inst)
    inst.health_epic.max = inst.net_health_epic_max:value()
end

local function AddHealthNetvars(inst)
	inst.health_epic = { act = 0, max = 0 }
	
   	if inst.prefab == "toadstool_dark" then
    	inst.net_health_epic = _G.net_uint(inst.GUID, "health_epic", "health_epic_dirty")
     	inst.net_health_epic_max = _G.net_uint(inst.GUID, "health_epic_max", "health_epic_max_dirty")
   	else --65535 max
     	inst.net_health_epic = _G.net_ushortint(inst.GUID, "health_epic", "health_epic_dirty")
       	inst.net_health_epic_max = _G.net_ushortint(inst.GUID, "health_epic_max", "health_epic_max_dirty")
   	end
    			
   	if not IsDedicated then
       	inst:ListenForEvent("health_epic_dirty", OnHealthEpicDirty)
       	inst:ListenForEvent("health_epic_max_dirty", OnHealthEpicMaxDirty)
   	end
		
   	if not _G.TheWorld.ismastersim then
       	return
   	end

   	if inst.components.health ~= nil then
       	inst.net_health_epic:set(inst.components.health.currenthealth)
       	inst.net_health_epic_max:set(inst.components.health.maxhealth)
   	end
end

AddPrefabPostInitAny(function(inst)
   	if inst and inst:HasTag("epic") then
		AddHealthNetvars(inst)
	end
end)

for _,v in pairs({ "rook", "knight", "bishop" }) do
	AddPrefabPostInit("shadow_"..v, AddHealthNetvars)
end

--[[!]] if not _G.TheNet:GetIsServer() then return end

-- Вставляем триггеры --

local function AppendFn(comp, fn_name, fn)
    local old_fn = comp[fn_name]
    comp[fn_name] = function(self, ...)
        local amount = old_fn(self, ...)
		
        fn(self)
		
		if amount ~= nil then
			return amount
		end
    end
end

local health = require "components/health"

AppendFn(health, "SetCurrentHealth", function(self)
    if self.inst.health_epic ~= nil then
        self.inst.net_health_epic:set(self.currenthealth)
    end
end)

AppendFn(health, "SetMaxHealth", function(self)
    if self.inst.health_epic ~= nil then
        self.inst.net_health_epic:set(self.currenthealth)
		self.inst.net_health_epic_max:set(self.maxhealth)
    end
end)

AppendFn(health, "DoDelta", function(self)
    if self.inst.health_epic ~= nil then
        self.inst.net_health_epic:set(self.currenthealth)
    end
end)

AppendFn(health, "OnRemoveFromEntity", function(self)
    if self.inst.health_epic ~= nil then
        self.inst.net_health_epic:set(0)
		self.inst.net_health_epic_max:set(0)
    end
end)