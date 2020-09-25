local G = GLOBAL

local TUNING = 	{
	duration = 60,
	maximum = 300,
}

AddPrefabPostInitAny(function(inst)
	local GetIsWet_old = inst.GetIsWet
	function inst:GetIsWet(...)
		if inst:HasTag("moddedwatered") then
			return true
		end
		return GetIsWet_old(self, ...)
	end
end)

local function WaterEntity(inst)
	inst:AddTag("moddedwatered")
end
local function DryEntity(inst)
	inst:RemoveTag("moddedwatered")
	inst.moddedwatered_endtime = nil
end
local function ApplyWaterballonWetness(inst, duration)
	if inst.moddedwatered_endtime == nil then
		inst.moddedwatered_endtime = G.GetTime() + duration
		WaterEntity(inst)
		inst.moddedwatered_task = inst:DoTaskInTime(duration, DryEntity)
	else
		if inst.moddedwatered_task ~= nil then
			inst.moddedwatered_task:Cancel()
			inst.moddedwatered_task = nil
		end
		local newduration = math.min(inst.moddedwatered_endtime - G.GetTime() + duration, TUNING.maximum)
		inst.moddedwatered_endtime = G.GetTime() + newduration
		WaterEntity(inst)
		inst.moddedwatered_task = inst:DoTaskInTime(newduration, DryEntity)
	end
end

AddPrefabPostInit("waterballoon", function(inst)
	if inst.components.wateryprotection == nil then return end
	local SpreadProtectionAtPoint_old = inst.components.wateryprotection.SpreadProtectionAtPoint
	function inst.components.wateryprotection:SpreadProtectionAtPoint(x, y, z, dist, ...)
		SpreadProtectionAtPoint_old(self,x,y,z,dist,...)
		local ents = G.TheSim:FindEntities(x, y, z, dist or 4, {"_combat"}, self.ignoretags)
		for k, v in pairs(ents) do
			if v.components.moisture == nil then
				ApplyWaterballonWetness(v, TUNING.duration)
				if inst.components.complexprojectile ~= nil and inst.components.complexprojectile.attacker ~= nil then
					local attacker = inst.components.complexprojectile.attacker
					if attacker.components.combat and attacker.components.combat:CanTarget(v) then
						v:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
					end
				end
			end
		end
	end
end)