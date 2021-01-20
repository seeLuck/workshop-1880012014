local FERTILIZER_DEFS = require("prefabs/fertilizer_nutrient_defs").FERTILIZER_DEFS
local nutrients = FERTILIZER_DEFS.fertilizer.nutrients
local Refiller = Class(function(self, inst)
    self.inst = inst
    self.refill_value = 5
end)

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

function Refiller:DoRefilling(target, doer)
	if target:HasTag("refillable") then

		target.components.finiteuses:SetUses(target.components.finiteuses:GetUses() + self.refill_value)

		if target.components.finiteuses:GetUses() > 0 and target.components.fertilizer == nil then
			target:AddComponent("fertilizer")
			target.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
			target.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
			target.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
			target.components.fertilizer:SetNutrients(nutrients[1], nutrients[2], nutrients[3])
		end

		if target.components.finiteuses:GetUses() < target.components.finiteuses.total then
			target:AddTag("refillable")
		else
			target:RemoveTag("refillable")
		end


		if target.components.finiteuses:GetUses() > target.components.finiteuses.total then
			target.components.finiteuses:SetUses(target.components.finiteuses.total)
		end

		if self.inst.components.finiteuses then
			self.inst.components.finiteuses:Use(1)
		elseif self.inst.components.stackable then
			self.inst.components.stackable:Get(1):Remove()
		end

		return true
	end

end

return Refiller