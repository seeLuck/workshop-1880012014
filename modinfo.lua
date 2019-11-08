name = "Mod Collections"
description = "自用。整合并小修改了一些我常用的mod，随时可能再改，最好别订阅。\nSelf-use mod collections. Updating at any time. No recommend to subscribe it."
author = "雪绕风飞"
version = "1.9"
forumthread = ""
api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = false
dst_compatible = true
client_only_mod = false
all_clients_require_mod = true
server_filter_tags = {"stack", "clean"}

configuration_options =
{
    {
        name = "fiveslot",
        label = "FiveSlot",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "epichealthbar",
        label = "EpicHealthBar",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "minisign",
        label = "MiniSign",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "salt",
        label = "Salt",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "refiller",
        label = "Refiller",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "beenice",
        label = "BeeNice",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "wx78drop",
        label = "WX78Drop",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    }
}