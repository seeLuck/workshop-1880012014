name = " Worker Turkey"
description = "建造一个特殊的火鸡祭坛来生成一只采摘火鸡帮你采摘、收肉、喂牛。\nBuild a special turkey altar to create a picking turkey to help you pick things, harvest dried meat and feed beefalo."
author = "宵征"
version = "1.6.1"
api_version = 6
api_version_dst = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true 
icon_atlas = "images/modicon.xml"
icon = "modicon.tex"
forumthread = ""
server_filter_tags = {
	"pet",
	"creature",
	"autopick",
}
configuration_options = {
{
    name = "language",
    label = "language",
    options = 
        {
            
            {description = "English", data = 1},
            {description = "中文", data = 2},
        },
        default = 2,
    },
}