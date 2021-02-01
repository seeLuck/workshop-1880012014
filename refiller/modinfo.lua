name = "Refillable Bucket(Fixed)"
description =   "You are now able to refill your Bucket-o-poop! \n\n" ..
                "You can refill it with every natural item that could also fertilize."
author = "雪绕风飞"
version = "1.0.3"

forumthread = ""

dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = true
all_clients_require_mod = true
client_only_mod = false
api_version = 10

icon_atlas = "modicon.xml"
icon = "modicon.tex"

priority = 1

configuration_options =
{
    {
        name = "consumption",
        label = "Consumption",
        options =
        {
            {description = "Normal", data = false, hover = "Keep game balance"},
            {description = "Less", data = true, hover = "Easy to refill the bucket"},
        },
        default = false,
    }
}