local TheNet = GLOBAL.TheNet
local TheSim = GLOBAL.TheSim
local SpawnPrefab = GLOBAL.SpawnPrefab
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()

local FOODTYPE = GLOBAL.FOODTYPE

-- 物品自动堆叠检测范围
local SEE_ITEM_STACK_DIST = 10
local PI = 3.14159

-- 掉落物品自动堆叠
if IsServer then
    local function AnimPut(item, target)
        if target and target ~= item and target.prefab == item.prefab and item.components.stackable and not item.components.stackable:IsFull() and target.components.stackable and not target.components.stackable:IsFull() then
            local start_fx = SpawnPrefab("small_puff")
            start_fx.Transform:SetPosition(target.Transform:GetWorldPosition())
            start_fx.Transform:SetScale(.5, .5, .5)

            item.components.stackable:Put(target)
        end
    end

    local LootDropper = GLOBAL.require("components/lootdropper")
    local old_FlingItem = LootDropper.FlingItem
    -- 掉落物品自动堆叠
    function LootDropper:FlingItem(loot, pt, bouncedcb)
        if loot ~= nil and loot:IsValid() then
            if self.inst:IsValid() or pt ~= nil then
                old_FlingItem(self, loot, pt, bouncedcb)

                loot:DoTaskInTime(0.5, function(inst)
                    if inst:IsValid() then
                        local pos = inst:GetPosition()
                        local x, y, z = pos:Get()
                        local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
                        for _,obj in pairs(ents) do
                            AnimPut(loot, obj)
                        end
                    end
                end)
            end
        end
    end

    local Beard = GLOBAL.require("components/beard")
    -- 刮胡子自动堆叠
    function Beard:Shave(who, withwhat)
        if self.bits == 0 then
            return false, "NOBITS"
        elseif self.canshavetest ~= nil then
            local pass, reason = self.canshavetest(self.inst)
            if not pass then
                return false, reason
            end
        end

        if self.prize ~= nil then
            for k = 1 , self.bits do
                local bit = SpawnPrefab(self.prize)
                local x, y, z = self.inst.Transform:GetWorldPosition()
                bit.Transform:SetPosition(x, y + 2, z)
                local speed = 1 + math.random()
                local angle = math.random() * 2 * PI
                bit.Physics:SetVel(speed * math.cos(angle), 2 + math.random() * 3, speed * math.sin(angle))

                bit:DoTaskInTime(0.5, function(inst)
                    if inst:IsValid() then
                        local pos = inst:GetPosition()
                        local x, y, z = pos:Get()
                        local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
                        for _,obj in pairs(ents) do
                            AnimPut(bit, obj)
                        end
                    end
                end)
            end
            self:Reset()
        end

        if who == self.inst and who.components.sanity ~= nil then
            who.components.sanity:DoDelta(TUNING.SANITY_SMALL)
        end

        self.inst:PushEvent("shaved")

        return true
    end

    local Terraformer = GLOBAL.require("components/terraformer")
    -- 铲地皮自动堆叠
    function Terraformer:Terraform(pt, spawnturf)
        local world = GLOBAL.TheWorld
        local GroundTiles = GLOBAL.require("worldtiledefs")
        local map = world.Map
        if not world.Map:CanTerraformAtPoint(pt:Get()) then
            return false
        end

        local original_tile_type = map:GetTileAtPoint(pt:Get())
        local x, y = map:GetTileCoordsAtPoint(pt:Get())

        map:SetTile(x, y, GROUND.DIRT)
        map:RebuildLayer(original_tile_type, x, y)
        map:RebuildLayer(GROUND.DIRT, x, y)

        world.minimap.MiniMap:RebuildLayer(original_tile_type, x, y)
        world.minimap.MiniMap:RebuildLayer(GROUND.DIRT, x, y)

        spawnturf = spawnturf and GroundTiles.turf[original_tile_type] or nil
        if spawnturf ~= nil then
            local loot = SpawnPrefab("turf_"..spawnturf.name)
            if loot.components.inventoryitem ~= nil then
                loot.components.inventoryitem:InheritMoisture(world.state.wetness, world.state.iswet)
            end
            loot.Transform:SetPosition(pt:Get())
            if loot.Physics ~= nil then
                local angle = math.random() * 2 * PI
                loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))

                loot:DoTaskInTime(0.5, function(inst)
                    if inst:IsValid() then
                        local pos = inst:GetPosition()
                        local x, y, z = pos:Get()
                        local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
                        for _,obj in pairs(ents) do
                            AnimPut(loot, obj)
                        end
                    end
                end)
            end
        else
            SpawnPrefab("sinkhole_spawn_fx_"..tostring(math.random(3))).Transform:SetPosition(pt:Get())
        end

        return true
    end

    -- 猪王给予物品自动堆叠
    AddPrefabPostInit("pigking", function(inst)
        local old_onaccept = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(inst, giver, item)
            if old_onaccept ~= nil then old_onaccept(inst, giver, item) end

            inst:DoTaskInTime(2, function(inst)
                local pos = inst:GetPosition()
                local x, y, z = pos:Get()
                local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
                for _,objBase in pairs(ents) do
                    -- objBase.replica.inventoryitem.classified ~= nil
                    if objBase:IsValid() and objBase.components.stackable and not objBase.components.stackable:IsFull() then
                        for _,obj in pairs(ents) do
                            if obj:IsValid() then
                                AnimPut(objBase, obj)
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- 蚁狮给予物品自动堆叠
    AddPrefabPostInit("antlion", function(inst)
        local old_onaccept = inst.components.trader.onaccept
        inst.components.trader.onaccept = function(inst, giver, item)
            if old_onaccept ~= nil then old_onaccept(inst, giver, item) end

            inst:DoTaskInTime(3, function(inst)
                local pos = inst:GetPosition()
                local x, y, z = pos:Get()
                local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
                for _,objBase in pairs(ents) do
                    -- objBase.replica.inventoryitem.classified ~= nil
                    if objBase:IsValid() and objBase.components.stackable and not objBase.components.stackable:IsFull() then
                        for _,obj in pairs(ents) do
                            if obj:IsValid() then
                                AnimPut(objBase, obj)
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- 疯猪的屎自动堆叠
    local function OnEat(inst, food)
        if food.components.edible ~= nil then
            if food.components.edible.foodtype == FOODTYPE.VEGGIE then
                local poop = SpawnPrefab("poop")
                local pos = inst:GetPosition()
                local x, y, z = pos:Get()
                poop.Transform:SetPosition(inst.Transform:GetWorldPosition())
                local ents = TheSim:FindEntities(x, y, z, SEE_ITEM_STACK_DIST, { "_inventoryitem" }, { "INLIMBO", "NOCLICK", "catchable", "fire" })
                for _,obj in pairs(ents) do
                    AnimPut(poop, obj)
                end
            elseif food.components.edible.foodtype == FOODTYPE.MEAT and
            inst.components.werebeast ~= nil and
            not inst.components.werebeast:IsInWereState() and
            food.components.edible:GetHealth(inst) < 0 then
                inst.components.werebeast:TriggerDelta(1)
            end
        end
    end

    AddPrefabPostInit("pigman", function(inst)
        inst.components.eater:SetOnEatFn(OnEat)
    end)

    AddPrefabPostInit("pigguard", function(inst)
        inst.components.eater:SetOnEatFn(OnEat)
    end)
end