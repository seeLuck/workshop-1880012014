-------------------------
-- General information --
-------------------------

name = "Hounds Attack"
description = "Adjust hound attacks.\n- Numbers of hound\n- Days gap\n- Add wargs\nAll settings can be configured."
author = "雪绕风飞"
version = "1.16"
api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"
client_only_mod = false
all_clients_require_mod = true
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
server_filter_tags = {"hounds","hound","hounded","monster","mobs","warg"}

configuration_options =
{
	{
		name = "days",
		label = "Alerts",
		hover = "Days alert in advance of hound attack.",
		options =
		{
			{description = "No Alert", data = -1},
			{description = "On Attack Day", data = 0},
			{description = "1 Day", data = 1},
			{description = "2 Days", data = 2},
			{description = "3 Days", data = 3},
			{description = "4 Days", data = 4}
		},
		default = 2,
	},
	{
		name = "",
		label = "",
		hover = "",
		options =	
		{
			{description = "", data = 0},
		},
		default = 0,
	},
	{
		name = "houndMode",
		label = "Hound Mode",
		hover = "Select the preset for Hound attacks.\nThis section only works while Hound Mode is Customized.",
		options =
		{
			{description = "Never", data = "never", hover = "No hound attacks"},
			{description = "Default", data = false, hover = "No change to the game setting"},
			{description = "Customized", data = "customized", hover = "Customize attacks by following settings"}
		},
		default = false,
	},
	{
		name = "daysGap",
		label = "Days Gap",
		hover = "Select days gap of attacks.",
		options =
		{
			{description = "Very Long", data = 14, hover = "20 Days"},
			{description = "Long", data = 6, hover = "12 Days"},
			{description = "Medium", data = 0, hover = "6 Days"},
			{description = "Short", data = -3, hover = "3 Days"},
			{description = "Rush", data = -5, hover = "1 Days"},
			{description = "Instant", data = -5.875, hover = "1 Min (Real Time!)"}
		},
		default = 0,
	},
    {
        name = "houndNumber",
        label = "Hound Number",
        hover = "Set number of hounds.",
        options =
        {
            {description = "5", data = 0.5, hover = "5 Hounds"},
            {description = "10", data = 1, hover = "10 Hounds"},
            {description = "25", data = 2.5, hover = "25 Hounds"},
			{description = "50", data = 5, hover = "50 Hounds"},
			{description = "100", data = 10, hover = "100 Hounds"},
			{description = "200", data = 20, hover = "200 Hounds"},
			{description = "300", data = 30, hover = "300 Hounds"}
        },
        default = 1,
	},
	{
        name = "wargNumber",
        label = "Warg Number",
        hover = "Set number of warg(Hound King).",
        options =
        {
            {description = "None", data = 0, hover = "No Warg"},
			{description = "1", data = 1, hover = "1 Warg"},
			{description = "2", data = 2, hover = "2 Warg"},
			{description = "3", data = 3, hover = "3 Warg"},
			{description = "4", data = 4, hover = "4 Warg"},
			{description = "5", data = 5, hover = "5 Warg"}
        },
        default = 0,
	},
	{
        name = "wargStrength",
        label = "Warg Strength",
        hover = "Set Health/Damage of warg(Hound King).\nJust tell me if not satisified:)",
        options =
        {
            {description = "Week", data = 0, hover = "Health 900/Damage 25"},
			{description = "Default", data = 1, hover = "Health 1800/Damage 50"},
			{description = "Strong", data = 2, hover = "Health 3000/Damage 100"},
			{description = "Dangerous", data = 3, hover = "Health 6000/Damage 200"},
			{description = "Monster", data = 4, hover = "Health 10000/Damage 300"}
        },
        default = 1,
	},
	{
		name = "safeKey",
		label = "Clear All Hounds Button",
		hover = "Press it while hounds are ruling your world.\nSave your time from rolling back.",
		options = (function()
			local KEY_A  = 97 -- ASCII code for "a"
			local values = {}
			local chars  = {
				"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
				"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
			}
			for i = 1, #chars do
				values[#values + 1] = { description = chars[i], data = i + KEY_A - 1 }
			end

			return values
		end)(),
		default = 111, -- ASCII code for "o"
	},
	{
		name = "balanceSetting",
		label = "Balance Setting",
		hover = "Only players can truely harm wargs.\nWhich means even tons of bunnyman cannot defeat Warg. You need kill Warg on your own.",
		options =
		{
			{description = "Disable", data = 0, hover = "No change"},
			{description = "Enable", data = 1, hover = "Only players can truely harm wargs"},

		},
		default = 0,
	},
	{
		name = "",
		label = "",
		hover = "",
		options =	
		{
			{description = "", data = 0},
		},
		default = 0,
	},
	{
		name = "wormMode",
		label = "Worm Mode",
		hover = "Select the preset for Cave Worm attacks.",
		options =
		{
			{description = "Never", data = "never", hover = "No cave worm attacks"},
			{description = "Default", data = false, hover = "No change to the game setting"}
		},
		default = false,
	},
}