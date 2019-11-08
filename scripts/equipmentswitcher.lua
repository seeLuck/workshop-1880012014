AddComponentPostInit("inventory", function(self)
	local _Equip = self.Equip
	self.Equip = function(self, item, old_to_active)
		if not item or not item.components.equippable or not item:IsValid() then
			return
		end

		local prevslot = self:GetItemSlot(item)
		local prevcontainer = nil

		if not prevslot then
			local owner = item.components.inventoryitem.owner
			local container = owner and owner.components.container
			if container then
				prevslot = container:GetItemSlot(item)
				prevcontainer = container
			end
		end

		local eslot = item.components.equippable.equipslot
		local olditem = self:GetEquippedItem(eslot)

		if olditem and olditem ~= item then
			olditem.prevslot = prevslot
			olditem.prevcontainer = prevcontainer
		end

		return _Equip(self, item, old_to_active)
	end
end)