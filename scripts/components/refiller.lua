local Refiller = Class(function(self, inst)
    self.inst = inst
    self.refill_value = 5
end)

function Refiller:DoRefilling(target, doer)
	if target:HasTag("refillable") then

		target.components.finiteuses:SetUses(target.components.finiteuses:GetUses() + self.refill_value)

		if target.components.finiteuses:GetUses() > 0 and target.components.fertilizer == nil then
			target:AddComponent("fertilizer")
			target.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
			target.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
			target.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
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