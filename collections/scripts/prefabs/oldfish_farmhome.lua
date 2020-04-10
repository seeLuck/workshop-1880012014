require "prefabutil"

local assets =
{
    Asset("ANIM", "anim/farm_home.zip"),
}

local prefabs =
{
    "collapse_small",
    "oldfish_farmer",
}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.doortask ~= nil then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
    if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        inst.components.spawner:ReleaseChild()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil then
        if data.burnt then
            inst.components.burnable.onburnt(inst)
        end
    end
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
    end
end

local function onstopcavedaydoortask(inst)
    inst.doortask = nil
    inst.components.spawner:ReleaseChild()
end

local function OnStartDay(inst)
    if not inst:HasTag("burnt") and inst.components.spawner:IsOccupied() then
        if inst.doortask ~= nil then
            inst.doortask:Cancel()
        end
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstopcavedaydoortask)
    end
end

local function SpawnCheckCaveDay(inst)
    inst.inittask = nil
    inst:WatchWorldState("startcaveday", OnStartDay)
    if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        if TheWorld.state.iscaveday or
                (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            inst.components.spawner:ReleaseChild()
        end
    end
end

local function oninit(inst)
    inst.inittask = inst:DoTaskInTime(math.random(), SpawnCheckCaveDay)
    if inst.components.spawner ~= nil and
            inst.components.spawner.child == nil and
            inst.components.spawner.childname ~= nil and
            not inst.components.spawner:IsSpawnPending() then
        local child = SpawnPrefab(inst.components.spawner.childname)
        if child ~= nil then
            inst.components.spawner:TakeOwnership(child)
            inst.components.spawner:GoHome(child)
        end
    end
end


local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/together/perd_shrine_place")
end

local PLACER_SCALE = 1.55


local function OnEnableHelper(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateEntity()

            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.Transform:SetScale(PLACER_SCALE, PLACER_SCALE, PLACER_SCALE)

            inst.helper.AnimState:SetBank("firefighter_placement")
            inst.helper.AnimState:SetBuild("firefighter_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetAddColour(0, .2, .5, 0)

            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function onvacate(inst, child)
    if not inst:HasTag("burnt") and child ~= nil and
        child.components.health ~= nil then
        child.components.health:SetPercent(1)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("perdshrine.png")

    inst.AnimState:SetBank("farm_home")
    inst.AnimState:SetBuild("farm_home")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)
    inst.AnimState:OverrideSymbol("swap_meter", "firefighter_meter", "10")

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("oldfish_farmhome.tex")

    MakeObstaclePhysics(inst, 0.3)

    inst:AddTag("structure")
    inst:AddTag("oldfish_farmhome")

    inst.entity:SetPristine()

    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnWorkCallback(onhit)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("spawner")
    inst.components.spawner:Configure("oldfish_farmer", TUNING.TOTAL_DAY_TIME * STRINGS.REFRESH_TIME)
    inst.components.spawner.onvacate = onvacate
    inst.components.spawner:CancelSpawning()

    MakeSnowCovered(inst)

    MakeSmallBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

    MakeHauntableWork(inst)
    inst:ListenForEvent("onbuilt", onbuilt)
    inst.inittask = inst:DoTaskInTime(0, oninit)

    inst:DoPeriodicTask(5, function(inst)
        if inst.components.spawner ~= nil
                and inst.components.spawner:IsOccupied()
                and not TheWorld.state.isnight
        then
            inst.components.spawner:ReleaseChild()
        end
    end)

    return inst
end

local function placer_postinit_fn(inst)

    local placer2 = CreateEntity()

    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer2.Transform:SetScale(s, s, s)

    placer2.AnimState:SetBank("farm_home")
    placer2.AnimState:SetBuild("farm_home")
    placer2.AnimState:PlayAnimation("idle")
    placer2.AnimState:SetLightOverride(1)
    placer2.AnimState:SetScale(PLACER_SCALE, PLACER_SCALE)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)
end

return Prefab("oldfish_farmhome", fn, assets, prefabs),
    MakePlacer("oldfish_farmhome_placer", "firefighter_placement", "firefighter_placement", "idle", true, nil, nil, PLACER_SCALE, nil, nil, placer_postinit_fn)

