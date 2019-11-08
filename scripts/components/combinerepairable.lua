
local CombineRepairable = Class(function(self, inst)
    self.inst = inst
    self.inst:AddTag("combinerepairable")
end,
nil,
{})

function CombineRepairable:OnRemoveFromEntity()
    self.inst:RemoveTag("combinerepairable")
end

function CombineRepairable:Repair(doer, repair_item)
    -- print("Repair Combine: repare "..tostring(self.inst.prefab).." with "..tostring(repair_item.prefab))
    if repair_item==nil or self.inst==nil or not repair_item:IsValid() or not self.inst:IsValid() or self.inst.prefab ~= repair_item.prefab then
        return false
    end
    local actualbonus = TUNING.REPAIRCOMBINE_bonus
    if actualbonus == 0.05 then
        actualbonus = math.random(6)-1 -- between 0 and 5
    elseif actualbonus==0.1 then
        actualbonus = math.random(11)-1 -- between 0 and 10
    elseif actualbonus == -0.05 then
        actualbonus = -(math.random(6)-1) -- between 0 and -5
    elseif actualbonus == -0.15 then
        actualbonus = math.random(16)-1-5 -- between -5 and 10
    elseif actualbonus == -0.55 then
        actualbonus = math.random(11)-1-5 -- between -5 and 5
    end
    actualbonus = actualbonus/100
    local divide = 1
    if self.inst.components.stackable ~= nil then
        divide = math.max(1,self.inst.components.stackable:StackSize()) -- if the item we want to repair is a stack, then make the repair less efficient, depending on the stacksize
    end
    if self.inst.components.finiteuses~=nil and repair_item.components.finiteuses~=nil then
        self.inst.components.finiteuses:SetPercent(math.max(math.min(((repair_item.components.finiteuses:GetPercent()/divide) + self.inst.components.finiteuses:GetPercent())+actualbonus,TUNING.REPAIRCOMBINE_maxweapon),0.01))
    elseif self.inst.components.armor~=nil and repair_item.components.armor~=nil then
        self.inst.components.armor:SetPercent(math.max(((repair_item.components.armor:GetPercent()/divide) + self.inst.components.armor:GetPercent())+actualbonus,0.01)) -- a max of 100% is in component
    elseif self.inst.components.fueled~=nil and repair_item.components.fueled~=nil then
        self.inst.components.fueled:SetPercent(math.max(((repair_item.components.fueled:GetPercent()/divide) + self.inst.components.fueled:GetPercent())+actualbonus,0.01)) -- a max of 100% is in component
    elseif self.inst.components.perishable~=nil and self.inst.components.equippable~=nil and repair_item.components.perishable~=nil and repair_item.components.equippable~=nil then
        self.inst.components.perishable:SetPercent(math.max(((repair_item.components.perishable:GetPercent()/divide) + self.inst.components.perishable:GetPercent())+actualbonus,0.01)) -- a max of 100% is in component
    else
        return false
    end
    
    if TUNING.REPAIRCOMBINE_bonus~=0 then
        print("Repair Combine: Give repair bonus of "..tostring(actualbonus*100).."% to "..tostring(self.inst.prefab))
    end
    if repair_item.components.stackable ~= nil then
        repair_item.components.stackable:Get():Remove()
    else
        repair_item:Remove()
    end

    return true
end
return CombineRepairable
