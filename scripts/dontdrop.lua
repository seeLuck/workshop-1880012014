local R_diao = 0
local B_diao = 0
local amu_diao = true
local zhuang_bei = false
local R_d = R_diao - 3
local B_d = B_diao - 5
if R_d < 0 then R_d = 0 end if B_d < 0 then B_d = 0 end

AddComponentPostInit("container", function(Container, inst)
	function Container:DropSuiji(ondeath)
		local amu_x = true
		for k=1, self.numslots do
			local v = self.slots[k]
			if amu_diao and amu_x and v and v.prefab == "amulet" then
				amu_x = false
				self:DropItem(v)
			end
			if B_diao ~= 0 and v and v.prefab == "reviver" then
				self:DropItem(v)
			end
		end
		for k=1, self.numslots do
			local v = self.slots[math.random(1, self.numslots)]
			if k > math.random(B_d, B_diao) then
				return false
			end
			if v then
				self:DropItem(v)
			end
		end
	end
end)

AddComponentPostInit("inventory", function(Inventory, inst)
	Inventory.oldDropEverythingFn = Inventory.DropEverything
	function Inventory:DropSuiji(ondeath)
		local amu_x = true
		for k=1, self.maxslots do
			local v = self.itemslots[k]
			if amu_diao and amu_x and v and v.prefab == "amulet" then
				amu_x = false
				self:DropItem(v, true, true)
			end
			if R_diao ~= 0 and v and v.prefab == "reviver" then
				self:DropItem(v, true, true)
			end
		end
		for k=1, self.maxslots do
			local v = self.itemslots[math.random(1, self.maxslots)]
			if k~=1 and k > math.random(R_d, R_diao) then
				return false
			end
			if v then
				self:DropItem(v, true, true)
			end
		end
	end

	function Inventory:PlayerSiWang(ondeath)
		for k, v in pairs(self.equipslots) do
			if v:HasTag("backpack") and v.components.container then
				v.components.container:DropSuiji(true)
			end
		end
		if zhuang_bei then
			for k, v in pairs(self.equipslots) do
				if not v:HasTag("backpack") then
					self:DropItem(v, true, true)
				end
			end
		end
		self.inst.components.inventory:DropSuiji(true)
	end

	function Inventory:DropEverything(ondeath, keepequip)
		if not inst:HasTag("player") then
			return Inventory:oldDropEverythingFn(ondeath, keepequip)
		else
			return Inventory:PlayerSiWang(ondeath)
		end
	end
end)