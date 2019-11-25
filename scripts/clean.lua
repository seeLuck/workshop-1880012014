local TheNet = GLOBAL.TheNet
local IsServer = TheNet:GetIsServer() or TheNet:IsDedicated()
local TUNING = GLOBAL.TUNING
local _iClean = nil
local _G = GLOBAL

if IsServer then
    -- 需要清理的物品
    -- @max        地图上存在的最大数量
    -- @stack      堆叠大于n时跳过
    -- @reclean    跳过的清理次数
    -- @tool       工具时跳过
    local function GetLevelPrefabs()
        local levelPrefabs = {
            ------------------------  生物  ------------------------
            spider_warrior  = { max = 5 },    -- 蜘蛛战士
            spider          = { max = 10 },    -- 蜘蛛
            flies           = { max = 5 },    -- 苍蝇
            mosquito        = { max = 5 },    -- 蚊子
            killerbee       = { max = 5 },    -- 杀人蜂
            frog            = { max = 5 },    -- 青蛙
            grassgekko      = { max = 0 },     -- 草蜥蜴
            deer            = { max = 15 },    -- 鹿
            slurtle         = { max = 5 },     -- 鼻涕虫
            snurtle         = { max = 5 },     -- 蜗牛

            ------------------------  地面物体  ------------------------
            twiggytree          = { max = 100 },                      -- 树枝树
            marsh_tree          = { max = 50 },                       -- 针刺树
            rock_petrified_tree = { max = 200 },                      -- 石化树
            skeleton_player     = { max = 20 },                       -- 玩家尸体
            spiderden           = { max = 60 },                       -- 蜘蛛巢
            burntground         = { max = 20 },                       -- 陨石痕跡
            tentacle            = { max = 150 },

            ------------------------  可拾取物品  ------------------------
            seeds           = { max = 3, stack = 0, reclean = 1 },       -- 种子
            log             = { max = 5, stack = 5, reclean = 1 },       -- 木头
            livinglog       = { max = 3, stack = 0, reclean = 2 },        -- 活木
            charcoal        = { max = 5, stack = 5, reclean = 2 },        -- 木炭
            pinecone        = { max = 5, stack = 10, reclean = 1 },       -- 松果
            acorn           = { max = 5, stack = 10, reclean = 1 },       -- 桦木果
            twiggy_nut      = { max = 5, stack = 10, reclean = 1 },       -- 桦木果
            cutgrass        = { max = 5, stack = 5, reclean = 1 },       -- 草
            twigs           = { max = 5, stack = 5, reclean = 1 },       -- 树枝
            dug_grass       = { max = 0, stack = 0, reclean = 2 },        -- 草根
            dug_berrybush   = { max = 0, stack = 0, reclean = 2 },        -- 浆果苗
            dug_berrybush2  = { max = 0, stack = 0, reclean = 2 },        -- 浆果苗
            dug_berrybush_juicy  = { max = 0, stack = 0, reclean = 2 },        -- 浆果苗
            dug_sapling     = { max = 0, stack = 0, reclean = 2 },       -- 小树苗
            rocks           = { max = 5, stack = 5, reclean = 1 },       -- 石头
            moonrocknugget  = { max = 3, stack = 0, reclean = 1 },       -- 月石
            thulecite_pieces  = { max = 10, stack = 0, reclean = 1 },       -- 铥矿碎片
            goldnugget      = { max = 5, stack = 0, reclean = 2 },        -- 金块
            marble          = { max = 5, stack = 0, reclean = 3 },       -- 大理石
            nitre           = { max = 5, stack = 0, reclean = 3 },       -- 硝石
            flint           = { max = 5, stack = 5, reclean = 1 },       -- 燧石
            poop            = { max = 10 , stack = 3, reclean = 5 },       -- 屎
            guano           = { max = 10 , stack = 3, reclean = 5 },       -- 鸟屎
            manrabbit_tail  = { max = 5 , stack = 0, reclean = 2 },       -- 兔毛
            pigskin         = { max = 5 , stack = 0, reclean = 2 },       -- 猪皮
            silk            = { max = 5 , stack = 3, reclean = 7 },       -- 蜘蛛丝
            spidergland     = { max = 5 , stack = 3, reclean = 3 },       -- 蜘蛛腺体
            spidereggsack   = { max = 0 , stack = 0, reclean = 3 },       -- 蜘蛛巢卵
            stinger         = { max = 0 , stack = 0, reclean = 2 },       -- 蜂刺
            beardhair       = { max = 3 , stack = 3, reclean = 1 },       -- 胡须
            coontail        = { max = 3 , stack = 2, reclean = 3 },       -- 猫尾巴
            boneshard       = { max = 0 , stack = 0, reclean = 2 },       -- 骨头碎片
            cutreeds        = { max = 0 , stack = 0, reclean = 3 },       -- 芦苇
            feather_crow    = { max = 3 , stack = 0, reclean = 3 },       -- 黑羽毛
            feather_robin    = { max = 2 , stack = 0, reclean = 3 },       -- 羽毛
            feather_robin_winter    = { max = 2 , stack = 0, reclean = 3 },       -- 羽毛
            feather_canary    = { max = 2 , stack = 0, reclean = 3 },       -- 羽毛
            furtuft         = { max = 0 , stack = 0, reclean = 1 },       -- 小熊毛
            houndstooth     = { max = 0 , stack = 0, reclean = 2 },       -- 狗牙
            mosquitosack    = { max = 0 , stack = 0, reclean = 1 },       -- 蚊子血袋
            tentaclespots   = { max = 0 , stack = 0, reclean = 1 },       -- 触手皮
            glommerfuel     = { max = 50 , stack = 0, reclean = 30 },       -- 格罗姆粘液
            slurtleslime    = { max = 0 , stack = 0, reclean = 1 },       -- 鼻涕虫粘液
            slurtle_shellpieces = { max = 0 , stack = 0, reclean = 1 },   -- 鼻涕虫壳碎片

            spoiled_food    = { max = 5, stack = 5, reclean = 10 },       -- 腐烂食物
            winter_food4    = { max = 2, stack = 1, reclean = 3 },        -- 维多利亚面包

            winter_ornament_plain1 = { max = 2, stack = 1, reclean = 3 }, -- 节日小饰品
            winter_ornament_plain2 = { max = 2, stack = 1, reclean = 3 },
            winter_ornament_plain4 = { max = 2, stack = 1, reclean = 3 },
            winter_ornament_plain5 = { max = 2, stack = 1, reclean = 3 },
            winter_ornament_plain6 = { max = 2, stack = 1, reclean = 3 },
            winter_ornament_plain7 = { max = 2, stack = 1, reclean = 3 },
            winter_ornament_plain8 = { max = 2, stack = 1, reclean = 3 },

            trinket_1   = { max = 0, stack = 0, reclean = 1 },
            trinket_3   = { max = 0, stack = 0, reclean = 1 },            -- 戈尔迪乌姆之结
            trinket_6   = { max = 0, stack = 0, reclean = 1 },
            trinket_8   = { max = 0, stack = 0, reclean = 1 },

            blueprint   = { max = 3, tool = true, reclean = 1 },    -- 蓝图
            axe         = { max = 3, tool = true, reclean = 1 },    -- 斧子
            torch       = { max = 3, tool = true, reclean = 1 },    -- 火炬
            pickaxe     = { max = 3, tool = true, reclean = 1 },    -- 镐子
            shovel      = { max = 3, tool = true, reclean = 1 },    -- 铲子
            razor       = { max = 3, tool = true, reclean = 1 },    -- 剃刀
            pitchfork   = { max = 3, tool = true, reclean = 1 },    -- 草叉
            bugnet      = { max = 3, tool = true, reclean = 1 },    -- 捕虫网
            fishingrod  = { max = 3, tool = true, reclean = 1 },    -- 鱼竿
            spear       = { max = 3, tool = true, reclean = 1 },    -- 矛
            spiderhat   = { max = 0 },    -- 蜘蛛帽
            heatrock    = { max = 20, tool = true, reclean = 1 },   -- 热能石
            trap        = { max = 20, tool = true, reclean = 1 },   -- 动物陷阱
            birdtrap    = { max = 10, tool = true, reclean = 1 },   -- 鸟陷阱
            compass     = { max = 0 },    -- 指南針

            glommerwings  = { max = 0 },       -- 格罗姆翅膀

            chesspiece_deerclops_sketch     = { max = 2, tool = true, reclean = 1 },    -- 四季 boss 棋子图
            chesspiece_bearger_sketch       = { max = 2, tool = true, reclean = 1 },
            chesspiece_moosegoose_sketch    = { max = 2, tool = true, reclean = 1 },
            chesspiece_dragonfly_sketch     = { max = 2, tool = true, reclean = 1 },

            winter_ornament_boss_bearger    = { max = 2, stack = 1, reclean = 3 },    -- 四季 boss 和蛤蟆、蜂后的挂饰
            winter_ornament_boss_beequeen   = { max = 2, stack = 1, reclean = 3 },
            winter_ornament_boss_deerclops  = { max = 2, stack = 1, reclean = 3 },
            winter_ornament_boss_dragonfly  = { max = 2, stack = 1, reclean = 3 },
            winter_ornament_boss_moose      = { max = 2, stack = 1, reclean = 3 },
            winter_ornament_boss_toadstool  = { max = 2, stack = 1, reclean = 3 },

            -- armor_sanity   = { max = 10 },    -- 影甲
            nightsword    = { max = 10 },    -- 影刀
            shadowheart    = { max = 3 },    -- 影心
        }

        return levelPrefabs
    end

    local function RemoveItem(inst)
        if inst.components.health ~= nil and not inst:HasTag("wall") then
            if inst.components.lootdropper ~= nil then
                inst.components.lootdropper.DropLoot = function(pt) end
            end
            inst.components.health:SetPercent(0)
        else
            inst:Remove()
        end
    end

    local function Clean(inst, level)
        local this_max_prefabs = GetLevelPrefabs()
        local countList = {}

        for _,v in pairs(GLOBAL.Ents) do
            if v.prefab ~= nil then
                repeat
                    -- 不可见物品(在包裹内等)
                    if v.inlimbo then break end

                    local thisPrefab = v.prefab
                    if this_max_prefabs[thisPrefab] ~= nil then
                        if v.reclean == nil then
                            v.reclean = 1
                        else
                            v.reclean = v.reclean + 1
                        end

                        local bNotClean = true
                        if this_max_prefabs[thisPrefab].reclean ~= nil then
                            bNotClean = this_max_prefabs[thisPrefab].reclean >= v.reclean
                        end

                        if bNotClean then
                            if this_max_prefabs[thisPrefab].stack ~= nil and v.components and v.components.stackable and v.components.stackable:StackSize() >= this_max_prefabs[thisPrefab].stack then break 
                            elseif this_max_prefabs[thisPrefab].tool then break end
                        end
                    else break end

                    if countList[thisPrefab] == nil then
                        countList[thisPrefab] = { name = v.name, count = 1, currentcount = 1 }
                    else
                        countList[thisPrefab].count = countList[thisPrefab].count + 1
                        countList[thisPrefab].currentcount = countList[thisPrefab].currentcount + 1
                    end

                    if this_max_prefabs[thisPrefab].max >= countList[thisPrefab].count then break end

                    if (v.components.hunger ~= nil and v.components.hunger.current > 0) or (v.components.domesticatable ~= nil and v.components.domesticatable.domestication > 0) then
                        break
                    end

                    RemoveItem(v)
                    countList[thisPrefab].currentcount = countList[thisPrefab].currentcount - 1
                until true
            end
        end
    end

    local function CleanDelay(inst)
        if GLOBAL.TheWorld.state.cycles > 80 then
            inst:DoTaskInTime(5, Clean)
        end
    end

    AddPrefabPostInit("world", function(inst)
        inst:DoPeriodicTask(3 * TUNING.TOTAL_DAY_TIME, CleanDelay)
    end)
end

