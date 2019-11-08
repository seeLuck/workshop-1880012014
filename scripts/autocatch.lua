--[[

Catching rangs is now automatic

--]]
local IsServer = GLOBAL.TheNet:GetIsServer()

function setAutoCatch(inst)
    if IsServer then
		local oldhit = inst.components.projectile.Hit
		function inst.components.projectile:Hit(target)
			if target == self.owner and target.components.catcher then
				target:PushEvent("catch", {projectile = self.inst})
				self.inst:PushEvent("caught", {catcher = target})
				self:Catch(target)
				target.components.catcher:StopWatching(self.inst)
			else
				oldhit(self, target)
			end
		end
	end
end

AddPrefabPostInit("boomerang", setAutoCatch)
AddPrefabPostInit("bonerang", setAutoCatch)

