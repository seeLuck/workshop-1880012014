local language = GetModConfigData("Language")
local toggle_key = GetModConfigData("key")
local lastest_recipe_key = GetModConfigData("last_recipe_key")
local laggy_mode = GetModConfigData("laggy_mode")
local laggy_mode_key = GetModConfigData("laggy_mode_key")

local laggy_mode_on = laggy_mode == "on" and true or false

local _G = GLOBAL
local require = _G.require
local cooking = require("cooking")
local Sleep = _G.Sleep
local TheInput = _G.TheInput
local SendRPCToServer = _G.SendRPCToServer
local RPC = _G.RPC
local ACTIONS = _G.ACTIONS
local BufferedAction = _G.BufferedAction
local ThePlayer

local SLEEP_TIME = 0.05

local cookingthread
local harvestingthread
local harvestinglist = {}

local lastest_recipe = nil

--from action queue reborn--

local function InGame()
    return ThePlayer and ThePlayer.HUD and not ThePlayer.HUD:HasInputFocus()
end

--from action queue reborn--

local function Say(string)
    if not _G.ThePlayer then return end
    _G.ThePlayer.components.talker:Say(string)
end

chinese_string = {}
chinese_string["no_backpack"] = "未装备背包"
chinese_string["start"] = "自动做饭:开启"
chinese_string["stop"] = "自动做饭:关闭"
chinese_string["not_valid_items"] = "物品有误"
chinese_string["no_masterchef"] = "没有大厨标签"
chinese_string["no_portablespicer"] = "未找到调料站"
chinese_string["no_cookpot"] = "未找到烹饪锅"
chinese_string["cant_move_out_items"] = "无法从烹饪锅中移出物品"
chinese_string["harvest_only"] = "材料已用完，进入收获模式"
chinese_string["harvest_only_endless"] = "无尽收获模式启动"
chinese_string["last_recipe"] = "烹饪上个配方"
chinese_string["laggy_mode_on"] = "自动做饭:高延迟模式开启"
chinese_string["laggy_mode_off"] = "自动做饭:高延迟模式关闭"

english_string = {}
english_string["no_backpack"] = "Haven't backpack"
english_string["start"] = "Auto Cooking : On"
english_string["stop"] = "Auto Cooking : Off"
english_string["not_valid_items"] = "Wrong items"
english_string["no_masterchef"] = "Haven't masterchef tag"
english_string["no_portablespicer"] = "Didn't find portablespicer"
english_string["no_cookpot"] = "Didn't find cookpot"
english_string["cant_move_out_items"] = "Can't move out item from cookpot"
english_string["harvest_only"] = "Material run out,harvest mode on"
english_string["harvest_only_endless"] = "Endless harvest mode on"
english_string["last_recipe"] = "Cooking lastest recipe"
english_string["laggy_mode_on"] = "Auto Cooking : Laggy Mode On"
english_string["laggy_mode_off"] = "Auto Cooking : Laggy Mode Off"

local function GetString(type)
    if language == "Chinese" then
        return chinese_string[type]
    elseif language == "English" then
        return english_string[type]
    end
end

local function FormatItemList(items)
    local itemlist = {}
    local amount = 0
    for i,v in ipairs(items) do
        if not itemlist[v.prefab] then
            for ii,vv in ipairs(items) do
                if v.prefab == vv.prefab then
                    amount = amount + 1
                end
            end
            itemlist[v.prefab] = amount
            amount = 0
        end
    end
    return itemlist
end

--from action queue reborn--

local function IsValidEntity(ent)
    return ent and ent.Transform and ent:IsValid() and not ent:HasTag("INLIMBO")
end

--from action queue reborn--

--local function GetAction(target,pos)
--    if IsValidEntity(target) then
--        local pos = pos or target:GetPosition()
--        local playeractionpicker = ThePlayer.components.playeractionpicker
--        local act = playeractionpicker:GetLeftClickActions(pos, target)
--        return act and act[1]
--    else
--        return false
--    end
--end

local function CanRummageOrHarvest(target,pos)
    if IsValidEntity(target) then
        local pos = pos or target:GetPosition()
        local playeractionpicker = ThePlayer.components.playeractionpicker
        local actions = playeractionpicker:GetLeftClickActions(pos, target)
        for _,act in ipairs(actions) do
            if act.action == ACTIONS.RUMMAGE or act.action == ACTIONS.HARVEST then
                return act
            --elseif act.action == ACTIONS.STORE then
            --    return BufferedAction(ThePlayer,target,ACTIONS.RUMMAGE,nil,pos)
            end
        end
        return false
    else
        return false
    end
end

--from action queue reborn--

local function Wait(time)
    repeat
        Sleep(time or SLEEP_TIME)
    until not (ThePlayer.sg and ThePlayer.sg:HasStateTag("moving")) and not ThePlayer:HasTag("moving")
          and ThePlayer:HasTag("idle") and not ThePlayer.components.playercontroller:IsDoingOrWorking()
    if laggy_mode_on then Sleep(0.3) end
end

local function SendAction(act, target)

    local playercontroller = ThePlayer.components.playercontroller
    if playercontroller.ismastersim then
        ThePlayer.components.combat:SetTarget(nil)
        playercontroller:DoAction(act)
        return
    end

    local pos = ThePlayer:GetPosition()
    SendRPCToServer(RPC.LeftClick, act.action.code, pos.x, pos.z, target)

end

local function SendActionAndWait(act,target,time)
    SendAction(act, target)
    Wait(time)
end

--from action queue reborn--

local function CheckBackpackItems(backpack)

    if backpack.replica.container:GetItemInSlot(1) and backpack.replica.container:GetItemInSlot(2) then
        if (backpack.replica.container:GetItemInSlot(1):HasTag("spice") and 
           backpack.replica.container:GetItemInSlot(2):HasTag("preparedfood") and 
           not backpack.replica.container:GetItemInSlot(2):HasTag("spicedfood")) or
           (backpack.replica.container:GetItemInSlot(2):HasTag("spice") and 
           backpack.replica.container:GetItemInSlot(1):HasTag("preparedfood") and
           not backpack.replica.container:GetItemInSlot(1):HasTag("spicedfood")) then

            local items = {backpack.replica.container:GetItemInSlot(1),backpack.replica.container:GetItemInSlot(2)}

            return items,"AddSpices"
            
        elseif backpack.replica.container:GetItemInSlot(3) and backpack.replica.container:GetItemInSlot(4) then
            local items = {}
            for i = 1, 4 do
                if not cooking.IsCookingIngredient(backpack.replica.container:GetItemInSlot(i).prefab) then
                    return false,false
                end
                table.insert(items,backpack.replica.container:GetItemInSlot(i))
            end

            return items,"AutoCooking"
        end
    end
    return false,false
end

local function CheckInventoryItems()

    if not (ThePlayer and ThePlayer.replica.inventory) then return false,false end 
    local items = ThePlayer.replica.inventory:GetItems()

    local item_list = {}

    local function CheckNext(slot,counter,spiceorfood)

        for k,item in pairs(items) do
            if k == slot + 1 then
                if spiceorfood then
                    if spiceorfood == "spice" then
                        if item:HasTag("preparedfood") and not item:HasTag("spicedfood") then
                            table.insert(item_list,item)
                            return true
                        end
                    elseif spiceorfood == "preparedfood" then
                        if item:HasTag("spice") then
                            table.insert(item_list,item)
                            return true
                        end
                    end
                elseif cooking.IsCookingIngredient(item.prefab) then
                    local counter = counter + 1
                    if counter == 4 then
                        table.insert(item_list,item)
                        return true
                    elseif CheckNext(k,counter) then
                        table.insert(item_list,item)
                        return item_list
                    end
                end
                return false
            end
        end
        return false
    end

    for slot,item in pairs(items) do
        if cooking.IsCookingIngredient(item.prefab) then
            if CheckNext(slot,1) then
                table.insert(item_list,item)
                return item_list,"AutoCooking"
            end
        elseif item:HasTag("spice") then
            if CheckNext(slot,1,"spice") then
                table.insert(item_list,item)
                return item_list,"AddSpices"
            end
        elseif item:HasTag("preparedfood") and not item:HasTag("spicedfood") then
            if CheckNext(slot,1,"preparedfood") then
                table.insert(item_list,item)
                return item_list,"AddSpices"
            end
        end
    end
    return false,false
end

local function FindCookpot(type,ismasterchef,actioncheck,cookpots)
    if type == "cookpot" then

        local portablecookpot = _G.FindEntity(ThePlayer,25,function(inst)

            local incookpots = false
            if cookpots then
                for i,v in ipairs(cookpots) do
                    if inst == v then
                        incookpots = true
                        break
                    end
                end
                if not incookpots then return false end
            end

            if actioncheck then
                if not CanRummageOrHarvest(inst) then
                    return false
                end
            end
            return inst and inst.prefab == "portablecookpot"
        end,{"stewer"},{"burnt"})

        local cookpot = _G.FindEntity(ThePlayer,25,function(inst)

            local incookpots = false
            if cookpots then
                for i,v in ipairs(cookpots) do
                    if inst == v then
                        incookpots = true
                        break
                    end
                end
                if not incookpots then return false end
            end

            if actioncheck then
                if not CanRummageOrHarvest(inst) then
                    return false
                end
            end
            return inst and inst.prefab == "cookpot"
        end,{"stewer"},{"burnt"})

        return ismasterchef and portablecookpot and portablecookpot or cookpot
    elseif type == "portablespicer" then

        if not ismasterchef then return end

        local portablespicer = _G.FindEntity(ThePlayer,25,function(inst)

            if actioncheck then
                if not CanRummageOrHarvest(inst) then
                    return false
                end
            end
            return inst and inst.prefab == "portablespicer"
        end,{"stewer"},{"burnt"})

        return portablespicer
    end
end

local function GetItemSlot(item)
    if not ThePlayer and ThePlayer.replica.inventory then return false,false end
    for container,v in pairs(ThePlayer.replica.inventory:GetOpenContainers()) do
        if container and container.replica and container.replica.container and
        (container.prefab ~= "portablespicer" and container.prefab ~= "portablecookpot" and container.prefab ~= "cookpot") then
            local items_container = container.replica.container:GetItems()
            for k,v in pairs(items_container) do
                if v.prefab == item then
                    return container.replica.container,k
                end
            end
        end
    end
    for k,v in pairs(ThePlayer.replica.inventory:GetItems()) do
        if v.prefab == item then
            return ThePlayer.replica.inventory,k
        end
    end
    return false,false
end

local function HaveEnoughItems(items)
    local items = FormatItemList(items)
    if not ThePlayer and ThePlayer.replica.inventory and items then return end
    local itemlist = {}
    local amount = 0
    for container,v in pairs(ThePlayer.replica.inventory:GetOpenContainers()) do
        if container and container.replica and container.replica.container and
        (container.prefab ~= "portablespicer" and container.prefab ~= "portablecookpot" and container.prefab ~= "cookpot") then
            local items_container = container.replica.container:GetItems()
            for item,_ in pairs(items) do
                for k,v in pairs(items_container) do
                    if v.prefab == item then
                        if v.replica.stackable then
                            amount = amount + v.replica.stackable:StackSize()
                        else
                            amount = amount + 1
                        end
                    end
                end
                itemlist[item] = itemlist[item] and itemlist[item] + amount or amount
                amount = 0
            end
        end
    end
    for item,item_amount in pairs(items) do
        for k,v in pairs(ThePlayer.replica.inventory:GetItems()) do
            if v.prefab == item then
                if v.replica.stackable then
                    amount = amount + v.replica.stackable:StackSize()
                else
                    amount = amount + 1
                end
            end
        end
        itemlist[item] = itemlist[item] and itemlist[item] + amount or amount
        amount = 0
        if not (itemlist[item] >= item_amount) then
            return false
        end
    end
    return true
end

local function TakeOutItemsInCooker(cooker)
    --If something's in that cooker,take it out--
    local numslots = cooker and cooker.replica.container and cooker.replica.container._numslots
    if not (type(numslots) == "number") then Say(GetString("cant_move_out_items")) return false end
    for i=1,numslots do
        local done = true
        if cooker.replica.container:GetItemInSlot(i) then
            done = false
            if ThePlayer.replica.inventory:IsFull() then
                for container,v in pairs(ThePlayer.replica.inventory:GetOpenContainers()) do
                    if not container.replica.container:IsFull() and container:HasTag("backpack") then
                        repeat
                            cooker.replica.container:MoveItemFromAllOfSlot(i,container)
                            Sleep(0.05)
                        until not cooker.replica.container:GetItemInSlot(i)
                        done = true
                        break
                    end
                end
            else
                repeat
                    cooker.replica.container:MoveItemFromAllOfSlot(i,ThePlayer)
                    Sleep(0.05)
                until not cooker.replica.container:GetItemInSlot(i)
                done = true
            end
        end
        if not done then 
            Say(GetString("cant_move_out_items"))
            return false
        end
    end
    return true
end

local function StopCooking()
    Say(GetString("stop"))
    if cookingthread then
        cookingthread:SetList(nil)
    end
    if harvestingthread then
        harvestingthread:SetList(nil)
    end
    cookingthread = nil
    harvestingthread = nil
end

local function HarvestOnly(endless)

    if endless then
        Say(GetString("harvest_only_endless"))
    else
        Say(GetString("harvest_only"))
    end

    harvestingthread = ThePlayer:StartThread(function()

        while ThePlayer:IsValid() do

            local cooker
            if endless then
                cooker = _G.FindEntity(ThePlayer,25,function(inst)

                    local act = CanRummageOrHarvest(inst)
                    if not (act and act.action == ACTIONS.HARVEST) then
                        return false
                    end

                    return inst and (inst.prefab == "portablespicer" or inst.prefab == "cookpot" or inst.prefab == "portablecookpot")
                end,{"stewer"},{"burnt"})
            else
                local type
                local done_num = 0
                for i,cooker in ipairs(harvestinglist) do
                    if not cooker then
                        table.remove(harvestinglist,i)
                    else
                        local act = CanRummageOrHarvest(cooker)
                        if act and act.action == ACTIONS.RUMMAGE then
                            done_num = done_num + 1
                        end
                        type = cooker.prefab
                    end
                end
                if done_num == #harvestinglist then StopCooking() return end
                if not type then StopCooking() return end

                cooker = _G.FindEntity(ThePlayer,25,function(inst)

                    local incookpots = false
                    if harvestinglist then
                        for i,v in ipairs(harvestinglist) do
                            if inst == v then
                                incookpots = true
                                break
                            end
                        end
                        if not incookpots then return false end
                    end

                    local act = CanRummageOrHarvest(inst)
                    if not (act and act.action == ACTIONS.HARVEST) then
                        return false
                    end

                    return inst and inst.prefab == type

                end,{"stewer"},{"burnt"})
            end

            if cooker then
                local act = CanRummageOrHarvest(cooker)
                if act and act.action == ACTIONS.HARVEST then
                    while CanRummageOrHarvest(cooker) and CanRummageOrHarvest(cooker).action == ACTIONS.HARVEST do
                        SendActionAndWait(act,cooker)
                    end
                else
                    Sleep(0.05)
                end
            else
                Sleep(0.05)
            end 
        end
    end)
end

local function FillCooker(cooker,items,backpack)
    repeat
        for i,v in ipairs(items) do
            local backpack_slot
            if backpack and backpack.replica.container then
                if cooker.prefab == "portablespicer" then
                    backpack_slot = backpack.replica.container:GetItemInSlot(1) and backpack.replica.container:GetItemInSlot(1).prefab == v.prefab and 1 or backpack.replica.container:GetItemInSlot(2) and backpack.replica.container:GetItemInSlot(2).prefab == v.prefab and 2
                else
                    backpack_slot = backpack.replica.container:GetItemInSlot(i) and backpack.replica.container:GetItemInSlot(i).prefab == v.prefab and i
                end
            end

            if backpack_slot then
                if cooker.prefab == "portablespicer" then
                    backpack.replica.container:MoveItemFromAllOfSlot(backpack_slot,cooker)
                else
                    while not cooker.replica.container:GetItemInSlot(i) do
                        if not (backpack and backpack.replica.container) then break end
                        backpack.replica.container:MoveItemFromAllOfSlot(backpack_slot,cooker)
                        Sleep(0.05)
                    end
                end
            else
                local container,slot = GetItemSlot(v.prefab)
                if container then
                    if cooker.prefab == "portablespicer" then
                        container:MoveItemFromAllOfSlot(slot,cooker)
                    else
                        while not cooker.replica.container:GetItemInSlot(i) do
                            container:MoveItemFromAllOfSlot(slot,cooker)
                            Sleep(0.05)
                        end
                    end
                end
            end
        end
        Sleep(0.05)
    until cooker.replica.container:IsFull()
end

local function AutoCooking(backpack,items,cookpots)

    cookingthread = ThePlayer:StartThread(function()

        while ThePlayer:IsValid() do

            if not HaveEnoughItems(items) then
                HarvestOnly()
                return
            end

            local cooker = FindCookpot(cookpots and "cookpot" or "portablespicer",true,true,cookpots)
            if not cooker then
                repeat
                    Sleep(0.05)
                    cooker = FindCookpot(cookpots and "cookpot" or "portablespicer",true,true,cookpots)
                until cooker
            end
            --local pos = portablespicer:GetPosition()

            local act = CanRummageOrHarvest(cooker)

            if act then
                if act.action == ACTIONS.RUMMAGE then

                    if not HaveEnoughItems(items) then
                        HarvestOnly()
                        return
                    end

                    while not cooker.replica.container:IsOpenedBy(ThePlayer) do
                        SendActionAndWait(act,cooker)
                    end

                    if not HaveEnoughItems(items) then
                        HarvestOnly()
                        return
                    end

                    if not TakeOutItemsInCooker(cooker) then return end

                    FillCooker(cooker,items,backpack)
                    repeat
                        SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.COOK.code, cooker, ACTIONS.COOK.mod_name)
                        Sleep(0.05)
                    until not CanRummageOrHarvest(cooker) or CanRummageOrHarvest(cooker).action ~= ACTIONS.RUMMAGE

                    table.insert(harvestinglist,cooker)

                elseif act.action == ACTIONS.HARVEST then
                    while CanRummageOrHarvest(cooker) and CanRummageOrHarvest(cooker).action == ACTIONS.HARVEST do
                        SendActionAndWait(act,cooker)
                    end

                    for i,v in ipairs(harvestinglist) do
                        if cooker == v then
                            table.remove(harvestinglist,i)
                            break
                        end
                    end

                else
                    Sleep(0.05)
                end
            end
        end
    end)
end

local function fn()

    if not InGame() then return end
    if ThePlayer:HasTag("playerghost") then return end

    if cookingthread or harvestingthread then StopCooking() return end

    local backpack = _G.EQUIPSLOTS.BACK or _G.EQUIPSLOTS.BODY
    local backpack = ThePlayer.replica.inventory:GetEquippedItem(backpack)
    --if not (backpack and backpack.replica.container) then Say(GetString("no_backpack")) return end

    local items
    local type
    if backpack and backpack.replica.container then
        items,type = CheckBackpackItems(backpack)
        if not items then 
            items,type = CheckInventoryItems()
        end
    else
        items,type = CheckInventoryItems()
    end
    if not items then 
        --Say(GetString("not_valid_items"))
        items,type = CheckInventoryItems()
        if not items then HarvestOnly(true) return end
    end

    Say(GetString("start"))

    if type == "AddSpices" then
        if ThePlayer:HasTag("masterchef") then
            if not FindCookpot("portablespicer",true) then
                Say(GetString("no_portablespicer"))
                return false
            end
            lastest_recipe = items
            AutoCooking(backpack,items)
            return true
        else
            Say(GetString("no_masterchef"))
            return false
        end
    elseif type == "AutoCooking" then

        local cookpot = FindCookpot("cookpot",ThePlayer:HasTag("masterchef"))
        local cookingtime = 0
        if cookpot then
            local items_prefab = {}
            for i,v in ipairs(items) do
                items_prefab[i] = items[i].prefab
            end
            local food,cookingtime = cooking.CalculateRecipe(cookpot.prefab,items_prefab)
            if cookpot.prefab == "portablecookpot" then
                cookingtime = TUNING.BASE_COOK_TIME * cookingtime * TUNING.PORTABLE_COOK_POT_TIME_MULTIPLIER
            else
                cookingtime = TUNING.BASE_COOK_TIME * cookingtime
            end
            local cookpot_num = math.ceil(cookingtime / 2.5)
            local cookpots = {}
            local firstcookpot = cookpot
            table.insert(cookpots,firstcookpot)
            local cookpot
            for i=1,cookpot_num do
                cookpot = _G.FindEntity(firstcookpot,25,function(inst)
                    for i,v in ipairs(cookpots) do
                        if inst == v then
                            return false
                        end
                    end
                    return inst.prefab == firstcookpot.prefab
                end,{"stewer"},{"burnt"})
                if cookpot then
                    table.insert(cookpots,cookpot)
                else
                    break
                end
            end
            lastest_recipe = items
            AutoCooking(backpack,items,cookpots)
            return true
        else
            Say(GetString("no_cookpot"))
            return false
        end 
    end

end

--from action queue reborn--

local interrupt_controls = {}
for control = _G.CONTROL_ATTACK, _G.CONTROL_MOVE_RIGHT do
    interrupt_controls[control] = true
end

AddComponentPostInit("playercontroller", function(self, inst)
    if inst ~= _G.ThePlayer then return end
    ThePlayer = _G.ThePlayer
    local mouse_controls = {[_G.CONTROL_PRIMARY] = true, [_G.CONTROL_SECONDARY] = true}

    local PlayerControllerOnControl = self.OnControl
    self.OnControl = function(self, control, down)
        local mouse_control = mouse_controls[control]
        local interrupt_control = interrupt_controls[control]
        if interrupt_control or mouse_control and not TheInput:GetHUDEntityUnderMouse() then
            if down and (cookingthread or harvestingthread) and InGame() then
                StopCooking()
            end
        end
        PlayerControllerOnControl(self, control, down)
    end
end)

--from action queue reborn--

if GetModConfigData("last_recipe_mode") == "last" then

    local changelist = {"cookpot","portablecookpot","portablespicer"}

    for i,v in ipairs(changelist) do

        AddPrefabPostInit(v, function(inst)

            local Old_widget_fn
            local function widget_fn(inst)
                local items = inst.replica.container and inst.replica.container:GetItems()
                if items and type(items) == "table" then
                    lastest_recipe = {}
                    for slot,item in pairs(items) do
                        table.insert(lastest_recipe,item)
                    end
                end
                Old_widget_fn(inst)
            end
        
            if not _G.TheWorld.ismastersim then
                inst.OnEntityReplicated = function(inst)
                    if inst.replica.container then
                        Old_widget_fn = inst.replica.container.widget.buttoninfo.fn
                        inst.replica.container.widget.buttoninfo.fn = widget_fn
                    end
                end
                return inst
            end

        	local container = inst.components.container
            --_G.removesetter(container, "itemtestfn")
            Old_widget_fn = container.widget.buttoninfo.fn
            container.widget.buttoninfo.fn = widget_fn
        	if inst.replica.container ~= nil then inst.replica.container.widget.buttoninfo.fn = widget_fn end
        	--_G.makereadonly(container, "itemtestfn")

        end)

    end

end


toggle_key = _G[toggle_key]
lastest_recipe_key = _G[lastest_recipe_key]
laggy_mode_key = _G[laggy_mode_key]
TheInput:AddKeyUpHandler(toggle_key,fn)
TheInput:AddKeyUpHandler(lastest_recipe_key,function()

    if not lastest_recipe then return end
    if cookingthread or harvestingthread then return end

    if not InGame() then return end
    if ThePlayer:HasTag("playerghost") then return end
    
    if not HaveEnoughItems(lastest_recipe) then return end

    Say(GetString("last_recipe"))
    if #lastest_recipe == 2 then
        if ThePlayer:HasTag("masterchef") then
            if not FindCookpot("portablespicer",true) then
                Say(GetString("no_portablespicer"))
            end
            AutoCooking(nil,lastest_recipe)
        else
            Say(GetString("no_masterchef"))
        end
    else
        local cookpot = FindCookpot("cookpot",ThePlayer:HasTag("masterchef"))
        local cookingtime = 0
        if cookpot then
            local items_prefab = {}
            for i,v in ipairs(lastest_recipe) do
                items_prefab[i] = lastest_recipe[i].prefab
            end
            local food,cookingtime = cooking.CalculateRecipe(cookpot.prefab,items_prefab)
            if cookpot.prefab == "portablecookpot" then
                cookingtime = TUNING.BASE_COOK_TIME * cookingtime * TUNING.PORTABLE_COOK_POT_TIME_MULTIPLIER
            else
                cookingtime = TUNING.BASE_COOK_TIME * cookingtime
            end
            local cookpot_num = math.ceil(cookingtime / 2.5)
            local cookpots = {}
            local firstcookpot = cookpot
            table.insert(cookpots,firstcookpot)
            local cookpot
            for i=1,cookpot_num do
                cookpot = _G.FindEntity(firstcookpot,25,function(inst)
                    for i,v in ipairs(cookpots) do
                        if inst == v then
                            return false
                        end
                    end
                    return inst.prefab == firstcookpot.prefab
                end,{"stewer"},{"burnt"})
                if cookpot then
                    table.insert(cookpots,cookpot)
                else
                    break
                end
            end
            AutoCooking(nil,lastest_recipe,cookpots)
        else
            Say(GetString("no_cookpot"))
        end
    end
end)
if laggy_mode == "in_game" then
    TheInput:AddKeyUpHandler(laggy_mode_key,function()
        if not InGame() then return end
        laggy_mode_on = not laggy_mode_on
        Say(GetString(laggy_mode_on and "laggy_mode_on" or "laggy_mode_off"))
    end)
end