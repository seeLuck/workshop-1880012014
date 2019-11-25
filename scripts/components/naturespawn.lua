local prefabs = {
}
prefabs["wasphive"] = 20,
prefabs["beehive"] = 30,
prefabs["houndmound"] = 20,
prefabs["pighouse"] = 25,
prefabs["mermhouse"] = 50,
prefabs["catcoonden"] = 10,
prefabs["spiderden"] = 30,
prefabs["tallbirdnest"] = 30,
prefabs["tentacle"] = 120,
prefabs["beefalo"] = 30,
prefabs["lightninggoat"] = 20,
prefabs["pigtorch"] = 30,
prefabs["knight"] = 2,
prefabs["bishop"] = 2,
prefabs["rook"] = 1,
prefabs["mandrake"] = 2,
prefabs["blue_mushroom"] = 30,
prefabs["green_mushroom"] = 30,
prefabs["red_mushroom"] = 10,
prefabs["fireflies"] = 120,
prefabs["slurtlehole"] = 30,
prefabs["flower_cave"] = 500,
prefabs["spiderhole"] = 40,
prefabs["rabbithouse"] = 30,

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

local function TrySpawn(strfab)
    local pt = Vector3(math.random(-1000, 1000), 0, math.random(-1000, 1000))
    local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    local canspawn = tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID and tile ~= 255
    local tilecheck = tilefns[strfab]
    canspawn = canspawn and tilecheck(tile)
    if canspawn then
        local b = SpawnPrefab(strfab)
        b.Transform:SetPosition(pt:Get())
    else
        TrySpawn(strfab)
    end
end

local function wasphive_spawner()
    local min_num = prefabs.wasphive
    local count = c_countprefabsonground("wasphive")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("wasphive")
        end
    end
end

local function beehive_spawner()
    local min_num = prefabs.beehive
    local count = c_countprefabsonground("beehive")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("beehive")
        end
    end
end

local function houndmound_spawner()
    local min_num = prefabs.houndmound
    local count = c_countprefabsonground("houndmound")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("houndmound")
        end
    end
end

local function pighouse_spawner()
    local min_num = prefabs.pighouse
    local count = c_countprefabsonground("pighouse")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("pighouse")
        end
    end
end

local function mermhouse_spawner()
    local min_num = prefabs.mermhouse
    local count = c_countprefabsonground("mermhouse")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("mermhouse")
        end
    end
end

local function catcoonden_spawner()
    local min_num = prefabs.catcoonden
    local count = c_countprefabsonground("catcoonden")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("catcoonden")
        end
    end
end

local function spiderden_spawner()
    local min_num = prefabs.spiderden
    local count = c_countprefabsonground("spiderden")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("spiderden")
        end
    end
end

local function tallbirdnest_spawner()
    local min_num = prefabs.tallbirdnest
    local count = c_countprefabsonground("tallbirdnest")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("tallbirdnest")
        end
    end
end

local function tentacle_spawner()
    local min_num = prefabs.tentacle
    local count = c_countprefabsonground("tentacle")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("tentacle")
        end
    end
end

local function beefalo_spawner()
    local min_num = prefabs.beefalo
    local count = c_countprefabsonground("beefalo")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("beefalo")
        end
    end
end

local function lightninggoat_spawner()
    local min_num = prefabs.lightninggoat
    local count = c_countprefabsonground("lightninggoat")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("lightninggoat")
        end
    end
end

local function pigtorch_spawner()
    local min_num = prefabs.pigtorch
    local count = c_countprefabsonground("pigtorch")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("pigtorch")
        end
    end
end

local function knight_spawner()
    local min_num = prefabs.knight
    local count = c_countprefabsonground("knight")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("knight")
        end
    end
end

local function bishop_spawner()
    local min_num = prefabs.bishop
    local count = c_countprefabsonground("bishop")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("bishop")
        end
    end
end

local function rook_spawner()
    local min_num = prefabs.rook
    local count = c_countprefabsonground("rook")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("rook")
        end
    end
end

local function mandrake_spawner()
    local min_num = prefabs.mandrake
    local count = c_countprefabsonground("mandrake")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("mandrake")
        end
    end
end

local function blue_mushroom_spawner()
    local min_num = prefabs.blue_mushroom
    local count = c_countprefabsonground("blue_mushroom")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("blue_mushroom")
        end
    end
end

local function green_mushroom_spawner()
    local min_num = prefabs.green_mushroom
    local count = c_countprefabsonground("green_mushroom")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("green_mushroom")
        end
    end
end

local function red_mushroom_spawner()
    local min_num = prefabs.red_mushroom
    local count = c_countprefabsonground("red_mushroom")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("red_mushroom")
        end
    end
end

local function fireflies_spawner()
    local min_num = prefabs.fireflies
    local count = c_countprefabsonground("fireflies")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("fireflies")
        end
    end
end

local function slurtlehole_spawner()
    local min_num = prefabs.slurtlehole
    local count = c_countprefabsonground("slurtlehole")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("slurtlehole")
        end
    end
end

local function flower_cave_spawner()
    local min_num = prefabs.flower_cave
    local count = c_countprefabsonground("flower_cave")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("flower_cave")
        end
    end
end

local function spiderhole_spawner()
    local min_num = prefabs.spiderhole
    local count = c_countprefabsonground("spiderhole")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("spiderhole")
        end
    end
end

local function rabbithouse_spawner()
    local min_num = prefabs.rabbithouse
    local count = c_countprefabsonground("rabbithouse")
    local numtospawn = min_num - count
    if numtospawn > 0 then
        for i = 1, numtospawn, 1 do
            TrySpawn("rabbithouse")
        end
    end
end

local NatureSpawn = Class(function(self, inst)
    self.inst = inst

    inst:ListenForEvent("cycleschanged", function()
        local count_60days = TheWorld.state.cycles/60
        if math.floor(count_60days) == count_60days and count_60days ~= 0 then --try spawn prefabs every 50 days
            if TheWorld:HasTag("forest") then
                wasphive_spawner()
                beehive_spawner()
                houndmound_spawner()
                pighouse_spawner()
                mermhouse_spawner()
                catcoonden_spawner()
                tallbirdnest_spawner()
                tentacle_spawner()
                beefalo_spawner()
                lightninggoat_spawner()
                pigtorch_spawner()
                knight_spawner()
                bishop_spawner()
                rook_spawner()
                mandrake_spawner()
                blue_mushroom_spawner()
                green_mushroom_spawner()
                red_mushroom_spawner()
                fireflies_spawner()
            elseif TheWorld:HasTag("cave") then
                slurtlehole_spawner()
                flower_cave_spawner()
                spiderhole_spawner()
                rabbithouse_spawner()
            end
            spiderden_spawner()
            TheNet:Announce("世界资源再生中...")
            TheNet:Announce("退出3分钟重进可解决显示BUG")
        end
    end)
end)

return NatureSpawn