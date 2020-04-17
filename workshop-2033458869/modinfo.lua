name = "Auto Cooking"
description = ""
author = "Tony"
version = "1.0.6"
icon_atlas = "modicon.xml"
icon = "modicon.tex"
dst_compatible = true
client_only_mod = true
all_clients_require_mod = false

api_version = 10

local string = ""
local keys = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12","LAlt","RAlt","LCtrl","RCtrl","LShift","RShift","Tab","Capslock","Space","Minus","Equals","Backspace","Insert","Home","Delete","End","Pageup","Pagedown","Print","Scrollock","Pause","Period","Slash","Semicolon","Leftbracket","Rightbracket","Backslash","Up","Down","Left","Right"}
local keylist = {}
for i = 1, #keys do
    keylist[i] = {description = keys[i], data = "KEY_"..string.upper(keys[i])}
end

configuration_options =
{
    {
        name = "Language",
        hover = "Choose your language\n选择您使用的语言",
        label = "Language",
        options =
        {
            {description = "English", data = "English", hover = "English"},
            {description = "简体中文", data = "Chinese", hover = "简体中文"},
        },
        default = "English",
    },
    {
        name = "key",
        hover = "Key to start cooking\n启动做饭的按键",
        label = "Action Key",
        options = keylist,
        default = "KEY_F5"
    },
    {
        name = "last_recipe_key",
        hover = "Key to start lastest cooking recipe\n开始做上一次配方的按键",
        label = "Lastest Recipe Key",
        options = keylist,
        default = "KEY_HOME"
    },
    {
        name = "last_recipe_mode",
        hover = "Last recipe mode\n烹饪上次配方的模式",
        label = "Lastest Recipe Mode",
        options =
        {
            {description = "Auto Cooking", data = "auto", hover = "Last auto cooking recipe only"},
            {description = "Last Cooking", data = "last", hover = "Last cooking recipe"}
        },
        default = "auto"
    },
    {
        name = "laggy_mode",
        hover = "If you are really laggy, pls turn this on\n如果很卡的话再开",
        label = "Laggy Mode",
        options =
        {
            {description = "Off", data = "off", hover = "Always off"},
            {description = "On", data = "on", hover = "Always on"},
            {description = "In Game Button", data = "in_game", hover = "Toggleable in game"},
        },
        default = "off"
    },
    {
        name = "laggy_mode_key",
        hover = "Key to toggle laggy mode\n切换卡顿模式的按键",
        label = "Laggy Mode Toggle Key",
        options = keylist,
        default = "KEY_RSHIFT"
    }
}