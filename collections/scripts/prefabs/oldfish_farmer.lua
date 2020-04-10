local assets =
{
    Asset("ANIM", "anim/oldfish_farmer.zip"),

}
local prefabs = {
    "drumstick"
}

local brain = require "brains/oldfish_farmbrain"
local loot = { "smallmeat", "strawhat", }

local function ShouldWake()
    return TheWorld.state.isday
end

local function OnSave(inst, data)

end

local function OnLoadPostPass(inst, newents, data)
    if data ~= nil and data.home ~= nil then
        local home = newents[data.home]
        if home ~= nil and inst.components.homeseeker ~= nil then
            inst.components.homeseeker:SetHome(home.entity)
        end
    end
end

local function OnAttacked(inst, data)
    if data.attacker.prefab == "bunnyman" or data.attacker.prefab == "bee" or data.attacker.prefab == "leif" 
    or data.attacker.prefab == "frog" then
        return
    end
    inst:PushEvent("gohome")
end

local function OnEat(inst, food)

end

local function onopen(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    inst.brain:Stop()
    inst.sg:GoToState("open")
end

local function onclose(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    inst.brain:Start()
    inst.sg:GoToState("close")
end

local function OnDeath(inst)
    inst.components.container:DropEverything()
end



local function OnPreLoad(inst, data)

end

local function ReflectDamageFn(inst, attacker, damage, weapon, stimuli)
    if attacker.prefab == "bunnyman" or attacker.prefab == "bee" or attacker.prefab == "leif" 
    or attacker.prefab == "frog" then
        return 5000
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.DynamicShadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced(inst)
    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("oldfish_farmer")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:OverrideSymbol("swap_hat", "hat_straw", "swap_hat")

    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:Show("ARM_normal")

    inst:AddTag("character")
    inst:AddTag("companion")
    inst:AddTag("notraptrigger")
    inst:AddTag("beefalo")
    inst:AddTag("berrythief")
    inst:AddTag("healthinfo")
    inst:AddTag("oldfish_farmer")
    inst:AddTag("insect")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 30
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0, -400, 0)
    inst.components.talker:MakeChatter()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0, function()
            inst.replica.container:WidgetSetup("farmer")
        end)
        return inst
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("farmer")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose


    if STRINGS.BACKPACK_SETTING == 2 or STRINGS.BACKPACK_SETTING == 3 then
        local param = STRINGS.BACKPACK_SETTING == 2 and 0 or -.01
        inst:DoPeriodicTask(2, function()
            for i = 1, 64, 1 do
                local item = inst.components.container:GetItemInSlot(i)
                if item and item.components.perishable then
                    item.components.perishable:ReducePercent(param)
                end
            end
        end)
    end





    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.PERD_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PERD_WALK_SPEED

    inst:SetStateGraph("SGoldfish_farmer")

    inst:AddComponent("homeseeker")
    inst:SetBrain(brain)

    inst:ListenForEvent("death", OnDeath)
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE, FOODTYPE.ROUGHAGE }, { FOODTYPE.VEGGIE, FOODTYPE.ROUGHAGE })
    inst.components.eater:SetCanEatRaw()
    inst.components.eater:SetOnEatFn(OnEat)

    inst:AddComponent("health")
    inst.components.health:StartRegen(10, 3)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.health:SetMaxHealth(300)
    inst.components.combat:SetDefaultDamage(1)
    inst.components.combat:SetAttackPeriod(10)

    inst:AddComponent("damagereflect")
    inst.components.damagereflect:SetReflectDamageFn(ReflectDamageFn)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 0
    inst.components.inventory.GetOverflowContainer = function(self)
        return self.inst.components.container
    end

    inst:AddComponent("inspectable")

    MakeHauntablePanic(inst)

    inst:ListenForEvent("attacked", OnAttacked)


    inst.isSpeak = false

    inst.ChesterState = "NORMAL"
    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad
    inst.OnLoadPostPass = OnLoadPostPass
    return inst
end

return Prefab("oldfish_farmer", fn, assets, prefabs)