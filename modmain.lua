if GetModConfigData("fiveslot") then
	modimport("scripts/fiveslot.lua")
end

if GetModConfigData("epichealthbar") then
	modimport("scripts/epichealthbar.lua")
end

if GetModConfigData("minisign") then
	modimport("scripts/minisign.lua")
end

if GetModConfigData("salt") then
	modimport("scripts/salt.lua")
end

if GetModConfigData("refiller") then
	modimport("scripts/refiller.lua")
end

if GetModConfigData("beenice") then
	modimport("scripts/beenice.lua")
end

if GetModConfigData("wx78drop") then
	modimport("scripts/wx78drop.lua")
end

modimport("scripts/usercmd.lua")
modimport("scripts/trashcan.lua")
modimport("scripts/stack.lua")
modimport("scripts/clean.lua")
modimport("scripts/autocatch.lua")
modimport("scripts/thermalstone.lua")
modimport("scripts/toolsfule.lua")
modimport("scripts/boatpatch.lua")
modimport("scripts/equipmentswitcher.lua")
modimport("scripts/settings.lua")
modimport("scripts/wallmath.lua")
modimport("scripts/dontdrop.lua")
modimport("scripts/combinerepair.lua")
modimport("scripts/eyeturret.lua")

AddPrefabPostInit("houndstooth", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.tradable then
			inst:AddComponent("tradable")
		end
	end
end)

AddPrefabPostInit("stinger", function(inst)
	if GLOBAL.TheWorld.ismastersim then
		if not inst.components.tradable then
			inst:AddComponent("tradable")
		end
	end
end)