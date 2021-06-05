if GetModConfigData("minisign") then
	modimport("scripts/minisign.lua")
end

if GetModConfigData("refiller") then
	modimport("scripts/refiller.lua")
end

if GetModConfigData("combinerepair") then
	modimport("scripts/combinerepair.lua")
	modimport("scripts/refillerweapon.lua")
end

if GetModConfigData("dart") then
	modimport("scripts/dart.lua")
end

if GetModConfigData("farmer") then
	modimport("scripts/farmer.lua")
end

if GetModConfigData("trashcan") then
	modimport("scripts/trashcan.lua")
end

if GetModConfigData("buildingCloser") then
	modimport("scripts/buildingcloser.lua")
end

TUNING.NO_CAVE_ENTRANCE_BAT = GetModConfigData("noentrancebat")
TUNING.MUTE_LUCY = GetModConfigData("mutelucy")
TUNING.MUTE_BEE = GetModConfigData("mutebee")

if GetModConfigData("waterballoon") then
	modimport("scripts/waterballoon.lua")
end
