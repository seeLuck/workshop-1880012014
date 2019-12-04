local prefabs = {
}
prefabs.wasphive = 20
prefabs.beehive = 30
prefabs.houndmound = 20
prefabs.pighouse = 25
prefabs.mermhouse = 50
prefabs.catcoonden = 10
prefabs.spiderden = 30
prefabs.tallbirdnest = 30
prefabs.tentacle = 120
prefabs.beefalo = 30
prefabs.lightninggoat = 20
prefabs.pigtorch = 30
prefabs.knight = 2
prefabs.bishop = 2
prefabs.rook = 1
prefabs.mandrake = 2
prefabs.blue_mushroom = 30
prefabs.green_mushroom = 30
prefabs.red_mushroom = 10
prefabs.fireflies = 120
prefabs.slurtlehole = 30
prefabs.flower_cave = 500
prefabs.spiderhole = 40
prefabs.rabbithouse = 30

local tilefns = {}
tilefns.wasphive = function(tile) return (tile == GROUND.GRASS) end
tilefns.beehive = function(tile) return (tile == GROUND.GRASS) end
tilefns.houndmound = function(tile) return (tile == GROUND.DESERT_DIRT) end
tilefns.pighouse = function(tile) return (tile == GROUND.DECIDUOUS) end
tilefns.mermhouse = function(tile) return (tile == GROUND.FOREST or tile == GROUND.MARSH) end
tilefns.catcoonden = function(tile) return (tile == GROUND.DECIDUOUS) end
tilefns.spiderden = function(tile) return (tile == GROUND.ROCKY or tile == GROUND.FOREST or tile == GROUND.SINKHOLE) end
tilefns.tallbirdnest = function(tile) return (tile == GROUND.ROCKY or tile == GROUND.DESERT_DIRT) end
tilefns.tentacle = function(tile) return (tile == GROUND.MARSH) end
tilefns.beefalo = function(tile) return (tile == GROUND.SAVANNA) end
tilefns.lightninggoat = function(tile) return (tile == GROUND.DESERT_DIRT) end
tilefns.pigtorch = function(tile) return (tile == GROUND.FOREST or tile == GROUND.SAVANNA) end
tilefns.knight = function(tile) return (tile == GROUND.ROCKY) end
tilefns.bishop = function(tile) return (tile == GROUND.ROCKY) end
tilefns.rook = function(tile) return (tile == GROUND.ROCKY) end
tilefns.mandrake = function(tile) return (tile == GROUND.FOREST) end
tilefns.blue_mushroom = function(tile) return (tile == GROUND.FOREST or tile == GROUND.DECIDUOUS or tile == GROUND.GRASS) end
tilefns.green_mushroom = function(tile) return (tile == GROUND.FOREST or tile == GROUND.DECIDUOUS or tile == GROUND.GRASS) end
tilefns.red_mushroom = function(tile) return (tile == GROUND.FOREST or tile == GROUND.DECIDUOUS or tile == GROUND.GRASS) end
tilefns.fireflies = function(tile) return (tile == GROUND.FOREST or tile == GROUND.DECIDUOUS or tile == GROUND.GRASS or tile == GROUND.SAVANNA) end
tilefns.slurtlehole = function(tile) return (tile == GROUND.MUD) end
tilefns.flower_cave = function(tile) return (tile == GROUND.MUD or tile == GROUND.SINKHOLE) end
tilefns.spiderhole = function(tile) return (tile == GROUND.UNDERROCK) end
tilefns.rabbithouse = function(tile) return (tile == GROUND.SINKHOLE) end

function c_countprefabsonground(prefab)
    local count = 0
    for k, v in pairs(Ents) do
        local owner = v.components.inventoryitem and v.components.inventoryitem.owner
        if owner == nil then
            if v.prefab == prefab then
                count = count + 1
            end
        end
    end
    return count
end

local function TrySpawn(strfab, inst)
    local pt = Vector3(math.random(-1000, 1000), 0, math.random(-1000, 1000))
    local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    --local playerInRange = IsAnyPlayerInRange(pt.x, pt.y, pt.z, 50)
    local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= 255
    local tilecheck = tilefns[strfab]
    if canspawn and tilecheck(tile) and inst.Map:CanPlantAtPoint(pt:Get()) and inst.Map:CanPlacePrefabFilteredAtPoint(pt:Get()) then
        --inst:DoTaskInTime(math.random(1, 240), function(target)
            local b = SpawnPrefab(strfab)
            if b ~= nil then
                if b.Physics ~= nil then
                    b.Physics:Teleport(pt:Get())
                else
                    b.Transform:SetPosition(pt:Get())
                end
                if b.components and b.components.spawnfader ~= nil then
                    b.components.spawnfader:FadeIn()
                end
            end
        --end)
    else
        TrySpawn(strfab, inst)
    end
end

local function wasphive_spawner(inst)
    local min_num = prefabs.wasphive
    local count = c_countprefabsonground("wasphive")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("wasphive", inst)
        end
    end
end

local function beehive_spawner(inst)
    local min_num = prefabs.beehive
    local count = c_countprefabsonground("beehive")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("beehive", inst)
        end
    end
end

local function houndmound_spawner(inst)
    local min_num = prefabs.houndmound
    local count = c_countprefabsonground("houndmound")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("houndmound", inst)
        end
    end
end

local function pighouse_spawner(inst)
    local min_num = prefabs.pighouse
    local count = c_countprefabsonground("pighouse")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("pighouse", inst)
        end
    end
end

local function mermhouse_spawner(inst)
    local min_num = prefabs.mermhouse
    local count = c_countprefabsonground("mermhouse")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("mermhouse", inst)
        end
    end
end

local function catcoonden_spawner(inst)
    local min_num = prefabs.catcoonden
    local count = c_countprefabsonground("catcoonden")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("catcoonden", inst)
        end
    end
end

local function spiderden_spawner(inst)
    local min_num = prefabs.spiderden
    local count = c_countprefabsonground("spiderden")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("spiderden", inst)
        end
    end
end

local function tallbirdnest_spawner(inst)
    local min_num = prefabs.tallbirdnest
    local count = c_countprefabsonground("tallbirdnest")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("tallbirdnest", inst)
        end
    end
end

local function tentacle_spawner(inst)
    local min_num = prefabs.tentacle
    local count = c_countprefabsonground("tentacle")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("tentacle", inst)
        end
    end
end

local function beefalo_spawner(inst)
    local min_num = prefabs.beefalo
    local count = c_countprefabsonground("beefalo")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("beefalo", inst)
        end
    end
end

local function lightninggoat_spawner(inst)
    local min_num = prefabs.lightninggoat
    local count = c_countprefabsonground("lightninggoat")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("lightninggoat", inst)
        end
    end
end

local function pigtorch_spawner(inst)
    local min_num = prefabs.pigtorch
    local count = c_countprefabsonground("pigtorch")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("pigtorch", inst)
        end
    end
end

local function knight_spawner(inst)
    local min_num = prefabs.knight
    local count = c_countprefabsonground("knight")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("knight", inst)
        end
    end
end

local function bishop_spawner(inst)
    local min_num = prefabs.bishop
    local count = c_countprefabsonground("bishop")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("bishop", inst)
        end
    end
end

local function rook_spawner(inst)
    local min_num = prefabs.rook
    local count = c_countprefabsonground("rook")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("rook", inst)
        end
    end
end

local function mandrake_spawner(inst)
    local min_num = prefabs.mandrake
    local count = c_countprefabsonground("mandrake")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("mandrake", inst)
        end
    end
end

local function blue_mushroom_spawner(inst)
    local min_num = prefabs.blue_mushroom
    local count = c_countprefabsonground("blue_mushroom")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("blue_mushroom", inst)
        end
    end
end

local function green_mushroom_spawner(inst)
    local min_num = prefabs.green_mushroom
    local count = c_countprefabsonground("green_mushroom")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("green_mushroom", inst)
        end
    end
end

local function red_mushroom_spawner(inst)
    local min_num = prefabs.red_mushroom
    local count = c_countprefabsonground("red_mushroom")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("red_mushroom", inst)
        end
    end
end

local function fireflies_spawner(inst)
    local min_num = prefabs.fireflies
    local count = c_countprefabsonground("fireflies")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("fireflies", inst)
        end
    end
end

local function slurtlehole_spawner(inst)
    local min_num = prefabs.slurtlehole
    local count = c_countprefabsonground("slurtlehole")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("slurtlehole", inst)
        end
    end
end

local function flower_cave_spawner(inst)
    local min_num = prefabs.flower_cave
    local count = c_countprefabsonground("flower_cave")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("flower_cave", inst)
        end
    end
end

local function spiderhole_spawner(inst)
    local min_num = prefabs.spiderhole
    local count = c_countprefabsonground("spiderhole")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("spiderhole", inst)
        end
    end
end

local function rabbithouse_spawner(inst)
    local min_num = prefabs.rabbithouse
    local count = c_countprefabsonground("rabbithouse")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("rabbithouse", inst)
        end
    end
end

local NatureSpawn = Class(function(self, inst)
    self.inst = inst

    inst:ListenForEvent("cycleschanged", function()
        local count_60days = TheWorld.state.cycles/60
        if math.floor(count_60days) == count_60days and count_60days ~= 0 then --try spawn prefabs every 50 days
            if TheWorld:HasTag("forest") then
                wasphive_spawner(inst)
                beehive_spawner(inst)
                houndmound_spawner(inst)
                pighouse_spawner(inst)
                mermhouse_spawner(inst)
                catcoonden_spawner(inst)
                tallbirdnest_spawner(inst)
                tentacle_spawner(inst)
                beefalo_spawner(inst)
                lightninggoat_spawner(inst)
                pigtorch_spawner(inst)
                knight_spawner(inst)
                bishop_spawner(inst)
                rook_spawner(inst)
                mandrake_spawner(inst)
                blue_mushroom_spawner(inst)
                green_mushroom_spawner(inst)
                red_mushroom_spawner(inst)
                fireflies_spawner(inst)
            elseif TheWorld:HasTag("cave") then
                slurtlehole_spawner(inst)
                flower_cave_spawner(inst)
                spiderhole_spawner(inst)
                rabbithouse_spawner(inst)
            end
            spiderden_spawner(inst)
            TheNet:Announce("世界资源再生中...")
        end
    end)
end)

return NatureSpawn