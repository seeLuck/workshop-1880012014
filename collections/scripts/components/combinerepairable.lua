
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
        if TUNING.REPAIRCOMBINE_overmaxfiniteuses then
            self.inst.components.finiteuses:SetMaxUses(self.inst.components.finiteuses.total*divide + repair_item.components.finiteuses.total)
            self.inst.components.finiteuses:SetUses(self.inst.components.finiteuses:GetUses()*divide + repair_item.components.finiteuses:GetUses())
            self.inst.components.finiteuses:SetUses(math.min(math.ceil(self.inst.components.finiteuses:GetUses() * (1+actualbonus)),self.inst.components.finiteuses.total))
        else
            self.inst.components.finiteuses:SetPercent(math.max(math.min(((repair_item.components.finiteuses:GetPercent()/divide) + self.inst.components.finiteuses:GetPercent())+actualbonus,TUNING.REPAIRCOMBINE_maxweapon),0.01))
        end
    elseif self.inst.components.armor~=nil and repair_item.components.armor~=nil then
        if TUNING.REPAIRCOMBINE_overmaxarmor then
            self.inst.components.armor.maxcondition = self.inst.components.armor.maxcondition*divide + repair_item.components.armor.maxcondition
            self.inst.components.armor:SetCondition(self.inst.components.armor.condition*divide + repair_item.components.armor.condition)
            self.inst.components.armor:SetCondition(math.min(math.ceil(self.inst.components.armor.condition * (1+actualbonus)),self.inst.components.armor.maxcondition))
        else
            self.inst.components.armor:SetPercent(math.max(math.min(((repair_item.components.armor:GetPercent()/divide) + self.inst.components.armor:GetPercent())+actualbonus,TUNING.REPAIRCOMBINE_maxweapon),0.01))
        end
    elseif self.inst.components.fueled~=nil and repair_item.components.fueled~=nil then
        if TUNING.REPAIRCOMBINE_overmaxfueled then
            self.inst.components.fueled.maxfuel = self.inst.components.fueled.maxfuel*divide + repair_item.components.fueled.maxfuel
            self.inst.components.fueled.currentfuel = self.inst.components.fueled.currentfuel*divide + repair_item.components.fueled.currentfuel
            self.inst.components.fueled.currentfuel = math.min(math.ceil(self.inst.components.fueled.currentfuel * (1+actualbonus)),self.inst.components.fueled.maxfuel)
        else
            self.inst.components.fueled:SetPercent(math.max(math.min(((repair_item.components.fueled:GetPercent()/divide) + self.inst.components.fueled:GetPercent())+actualbonus,TUNING.REPAIRCOMBINE_maxweapon),0.01))
        end
    elseif self.inst.components.perishable~=nil and self.inst.components.equippable~=nil and repair_item.components.perishable~=nil and repair_item.components.equippable~=nil then
        if TUNING.REPAIRCOMBINE_overmaxperishable then
            self.inst.components.perishable.perishtime = self.inst.components.perishable.perishtime*divide + repair_item.components.perishable.perishtime
            self.inst.components.perishable.perishremainingtime = math.min(math.ceil((self.inst.components.perishable.perishremainingtime*divide + repair_item.components.perishable.perishremainingtime) * (1+actualbonus)),self.inst.components.perishable.perishtime)
            -- self.inst.components.perishable.perishremainingtime = math.min(math.ceil(self.inst.components.perishable.perishremainingtime * (1+actualbonus)),self.inst.components.perishable.perishtime) -- done above in single line
            self.inst.components.perishable.inst:PushEvent("perishchange", {percent = self.inst.components.perishable:GetPercent()})
        else
            self.inst.components.perishable:SetPercent(math.max(((repair_item.components.perishable:GetPercent()/divide) + self.inst.components.perishable:GetPercent())+actualbonus,0.01)) -- a max of 100% is in component
        end
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
