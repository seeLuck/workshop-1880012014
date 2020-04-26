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

-- if GetModConfigData("largeboat") then
-- 	modimport("scripts/largeboat.lua")
-- end

if GetModConfigData("dart") then
	modimport("scripts/dart.lua")
end

if TUNING.FARMERPREFABS then
	modimport("scripts/farmer.lua")
end

if GetModConfigData("trashcan") then
	modimport("scripts/trashcan.lua")
end

TUNING.NO_CAVE_ENTRANCE_BAT = GetModConfigData("noentrancebat")
TUNING.MUTE_LUCY = GetModConfigData("mutelucy")
TUNING.MUTE_BEE = GetModConfigData("mutebee")