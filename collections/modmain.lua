if GetModConfigData("fiveslot") then
	modimport("scripts/fiveslot.lua")
end

if GetModConfigData("minisign") then
	modimport("scripts/minisign.lua")
end

if GetModConfigData("refiller") then
	modimport("scripts/refiller.lua")
end

if GetModConfigData("epichealthbar") then
	modimport("scripts/epichealthbar.lua")
end

if GetModConfigData("combinerepair") then
	modimport("scripts/combinerepair.lua")
end

if GetModConfigData("largeboat") then
	modimport("scripts/largeboat.lua")
end

if GetModConfigData("dart") then
	modimport("scripts/dart.lua")
end

if GetModConfigData("farmer") then
	modimport("scripts/farmer.lua")
end

modimport("scripts/trashcan.lua")
TUNING.NO_CAVE_ENTRANCE_BAT = GetModConfigData("noentrancebat")
TUNING.MUTE_LUCY = GetModConfigData("mutelucy")