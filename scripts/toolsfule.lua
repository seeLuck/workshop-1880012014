local tiny = TUNING.TINY_FUEL
local small = TUNING.SMALL_FUEL
local med = TUNING.MED_FUEL
local large = TUNING.LARGE_FUEL

local tool_list = {{"axe", tiny}, {"pickaxe", small}, {"shovel", small}, {"hammer", med}, {"pitchfork", small}, {"razor", small},
	{"bugnet", med}, {"fishingrod", small}, {"goldenaxe", small*2}, {"goldenpickaxe", small*2}, {"goldenshovel", small*2},
	{"multitool_axe_pickaxe", med}, {"birdtrap", small}, {"trap", med}, {"grass_umbrella", med}, {"umbrella", med}, {"featherfan", med*2},
	{"fertilizer", med*2}, {"spear", small*2}, {"armormarble", med*2}, {"footballhat", small}, {"blowdart_pipe", small},
	{"blowdart_fire", med}, {"blowdart_sleep", small}, {"boomerang", med*2}, {"trap_teeth", med}, {"staff_tornado", tiny},
	{"spear_wathgrithr", small}, {"wathgrithrhat", tiny}, {"panflute", med}, {"onemanband", tiny}, {"nightsword", small},
	{"armor_sanity", small}, {"batbat", med}, {"armorslurper", med}, {"amulet", tiny}, {"blueamulet", 1}, {"purpleamulet", tiny},
	{"firestaff", med*2}, {"icestaff", 1}, {"telestaff", tiny}, {"sewing_kit", small}, {"flowerhat", med}, {"strawhat", med*2},
	{"tophat", tiny}, {"watermelonhat", small}, {"icehat", 1}, {"beehat", small}, {"earmuffshat", tiny}, {"beefalohat", large},
	{"featherhat", med*2}, {"bushhat", large}, {"reflectivevest", med*2}, {"hawaiianshirt", small}, {"winterhat", med*2},
	{"sweatervest", tiny}, {"trunkvest_summer", tiny}, {"trunkvest_winter", med}, {"catcoonhat", tiny}, {"rainhat", med*2},
	{"raincoat", med}, {"beargervest", large}, {"eyebrellahat", med}, {"torch", small*2}, {"minerhat", med*2}, {"molehat", tiny},
	{"lantern", med}, {"pumpkin_lantern", tiny}, {"orangeamulet", tiny}, {"greenamulet", tiny}, {"orangestaff", tiny},
	{"greenstaff", med}, {"yellowstaff", large}, {"yellowamulet", large}, {"ruinshat", tiny}, {"ruins_bat", med}, {"armorruins", tiny},
	{"tentaclespike", tiny}, {"armorsnurtleshell", tiny}, {"slurtlehat", tiny}, {"walrushat", tiny}, {"spiderhat", tiny},
	{"nightstick", tiny}, {"whip", small}, {"brush", med}, {"deserthat", small}, {"goggleshat", small}, {"saddle_basic", med*2},
	{"saddle_war", large}, {"saddle_racing", large}, {"saddlehorn", tiny}, {"hivehat", med}, {"armorskeleton", 1}, {"opalstaff", med},
	{"thurible", small}}
	
for k, info in pairs(tool_list) do
	AddPrefabPostInit(info[1], function(inst)
		if not inst.components.fuel then --just in case some of these are already fuels, or are changed in the future
			inst:AddComponent("fuel")
			inst.components.fuel.fuelvalue = info[2]
		end
	end)
end
