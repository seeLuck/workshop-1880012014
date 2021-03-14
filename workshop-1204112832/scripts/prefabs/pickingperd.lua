local assets =
{
    Asset("ANIM", "anim/pickingperd.zip"),
    Asset("ANIM", "anim/pickingperd_snow.zip"),
    Asset("ANIM", "anim/hat_beefalo.zip"),
    Asset("SOUND", "sound/perd.fsb"),
}

local prefabs =
{
    "drumstick",
}

local brain = require "brains/pickingperdbrain"

local loot =
{
    "drumstick",
    "drumstick",
}

local function ShouldWake()
    return TheWorld.state.isday
end

local function OnSave(inst, data)
    data.ChesterState = inst.ChesterState
    if inst.components.homeseeker ~= nil and inst.components.homeseeker.home ~= nil then
        data.home = inst.components.homeseeker.home.GUID
        return { data.home }
    end
end

local function OnLoadPostPass(inst, newents, data)
    if data ~= nil and data.home ~= nil then
        local home = newents[data.home]
        if home ~= nil and inst.components.homeseeker ~= nil then
            inst.components.homeseeker:SetHome(home.entity)
        end
    end
end

local function OnAttacked(inst)
    local tochain = {}
    local x, y, z = inst.Transform:GetWorldPosition()
    for i, v in ipairs(TheSim:FindEntities(x, y, z, 14, { "perd" })) do
        if v.seekshrine then
            v.seekshrine = nil
            inst:RemoveEventCallback("attacked", OnAttacked)
            if v ~= inst then
                table.insert(tochain, v)
            end
        end
    end
    for i, v in ipairs(tochain) do
        OnAttacked(v)
    end
end

local function OnEat(inst, food)
    if not inst.components.container:IsFull() then
        print("I pick "..food.prefab)
    end
end

local function lootsetfn(lootdropper)
    if not lootdropper.inst.components.timer:TimerExists("offeringcooldown") then
        lootdropper:AddChanceLoot("redpouch", .1)
    end
end

local function DropOffering(inst)
    if not inst.components.timer:TimerExists("offeringcooldown") then
        inst.components.timer:StartTimer("offeringcooldown", TUNING.TOTAL_DAY_TIME)
        LaunchAt(SpawnPrefab("redpouch"), inst, inst:GetNearestPlayer(true) or inst:GetNearestPlayer(), .5, 1, .5)
    end
end

local function onopen(inst)
    inst.brain:Stop()
    inst.sg:GoToState("open")
end

local function onclose(inst)
    inst.brain:Start()
    inst.sg:GoToState("close")
end

local function OnDeath(inst)
    inst.components.container:DropEverything()
end

local function CanMorph(inst)
    if inst.ChesterState ~= "NORMAL" or not TheWorld.state.isfullmoon then
        return false
    end

    local container = inst.components.container
    if container:IsOpen() then
        return false
    end

    local canSnow = true

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item == nil then
            return false
        end

        canSnow = canSnow and item.prefab == "bluegem"

        if not canSnow then
            return false
        end
    end

    return canSnow
end

local function DoMorph(inst)
    inst.AnimState:AddOverrideBuild("pickingperd_snow")
    inst:AddTag("fridge")
    inst.ChesterState = "SNOW"
end

local function MorphChester(inst)
    local container = inst.components.container
    for i = 1, container:GetNumSlots() do
        container:RemoveItem(container:GetItemInSlot(i)):Remove()
    end

    DoMorph(inst)
end

local function CheckForMorph(inst)
    local canSnow = CanMorph(inst)
    if canSnow then
        MorphChester(inst)
    end
end

local function OnPreLoad(inst, data)
    if data == nil then
        return
    elseif data.ChesterState == "SNOW" then
        DoMorph(inst)
        inst:StopWatchingWorldState("isfullmoon", CheckForMorph)
        inst:RemoveEventCallback("onclose", CheckForMorph)
    end
end

local function creat_perd()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 50, .5)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("perd")
    inst.AnimState:SetBuild("perd")
    inst.AnimState:AddOverrideBuild("pickingperd")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_beefalo", "swap_hat")
    --inst.AnimState:Hide("hat")

    inst:AddTag("character")
    inst:AddTag("companion")
    inst:AddTag("notraptrigger")
    inst:AddTag("berrythief")
    inst:AddTag("healthinfo")
    inst:AddTag("beefalo")
    if IsSpecialEventActive(SPECIAL_EVENTS.YOTG) then
        inst:AddTag("perd")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, function()
            inst.replica.container:WidgetSetup("chester")
        end)
        return inst
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("chester")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.PERD_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PERD_WALK_SPEED

    inst:SetStateGraph("SGpickingperd")

    inst:AddComponent("homeseeker")
    inst:SetBrain(brain)
    inst:ListenForEvent("death", OnDeath)

    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE, FOODTYPE.ROUGHAGE }, { FOODTYPE.VEGGIE, FOODTYPE.ROUGHAGE })
    inst.components.eater:SetCanEatRaw()
    inst.components.eater:SetOnEatFn(OnEat)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)

    inst:AddComponent("health")
    inst.components.health:StartRegen(10, 3)
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"

    inst.components.health:SetMaxHealth(TUNING.PICKINGPERD_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.PERD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PERD_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 0
    inst.components.inventory.GetOverflowContainer = function(self) return self.inst.components.container end

    inst:AddComponent("inspectable")

    MakeHauntablePanic(inst)

    inst.seekshrine = true
    inst.ChesterState = "NORMAL"
    inst:WatchWorldState("isfullmoon", CheckForMorph)
    inst:ListenForEvent("onclose", CheckForMorph)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("pickingperd", creat_perd, assets, prefabs)
