
for _,v in pairs(GLOBAL.AllRecipes) do
    v.min_spacing = 1
end

AddPrefabPostInit("dug_berrybush", function(inst)
    if inst.components.deployable then
        inst.components.deployable:SetDeploySpacing(GLOBAL.DEPLOYSPACING.MEDIUM)
    end
end)
AddPrefabPostInit("dug_berrybush2", function(inst)
    if inst.components.deployable then
        inst.components.deployable:SetDeploySpacing(GLOBAL.DEPLOYSPACING.MEDIUM)
    end
end)
AddPrefabPostInit("dug_berrybush_juicy", function(inst)
    if inst.components.deployable then
        inst.components.deployable:SetDeploySpacing(GLOBAL.DEPLOYSPACING.MEDIUM)
    end
end)
AddPrefabPostInit("rock_avocado_fruit_sprout", function(inst)
    if inst.components.deployable then
        inst.components.deployable:SetDeploySpacing(GLOBAL.DEPLOYSPACING.MEDIUM)
    end
end)
AddPrefabPostInit("dug_rock_avocado_bush", function(inst)
    if inst.components.deployable then
        inst.components.deployable:SetDeploySpacing(GLOBAL.DEPLOYSPACING.MEDIUM)
    end
end)
AddPrefabPostInit("butterfly", function(inst)
    if inst.components.deployable then
        inst.components.deployable:SetDeploySpacing(GLOBAL.DEPLOYSPACING.MEDIUM)
    end
end)
