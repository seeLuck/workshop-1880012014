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

if GetModConfigData("dart") then
	modimport("scripts/dart.lua")
end

modimport("scripts/trashcan.lua")