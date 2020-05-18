name = "Mod Collections"
description = "自用。整合并小修改了一些我常用的mod，随时可能再改，最好别订阅。\nSelf-use mod collections. Updating at any time. No recommend to subscribe it."
author = "雪绕风飞"
version = "1.85"
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
        label = "5格物品栏",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "minisign",
        label = "迷你木板",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "trashcan",
        label = "二本垃圾桶",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "refiller",
        label = "便便桶填充",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "epichealthbar",
        label = "史诗血条",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "combinerepair",
        label = "合并修理",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    -- {
    --     name = "largeboat",
    --     label = "大船",
    --     options =
    --     {
    --         {description = "OFF", data = false, hover = "OFF"},
    --         {description = "ON", data = true, hover = "ON"},
    --     },
    --     default = false,
    -- },
    {
        name = "farmer",
        label = "农场(有问题，别开)",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "dart",
        label = "吹箭增强",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "noentrancebat",
        label = "去掉洞口蝙蝠",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "mutelucy",
        label = "路西斧静音",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    },
    {
        name = "mutebee",
        label = "蜜蜂静音",
        options =
        {
            {description = "OFF", data = false, hover = "OFF"},
            {description = "ON", data = true, hover = "ON"},
        },
        default = false,
    }
}