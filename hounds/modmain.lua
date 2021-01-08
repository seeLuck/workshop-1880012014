local _G = GLOBAL
local print = GLOBAL.print
local TheNet = GLOBAL.TheNet
local _iForest = nil
local HoundTask = nil
local HoundFlag = -1
local secADay = 8 * 60
-----------------------------------------------------------------------------------------------------------------
local houndMode = GetModConfigData("houndMode") or false -- false = use the game's default
local wormMode = GetModConfigData("wormMode") or false -- false = use the game's default
local safeKey = GetModConfigData("safeKey") or 111 -- keyboard 'o'
local DAYS_IN_ADVANCE = houndMode ~= "never" and GetModConfigData("days") or -1
local houndNumber = houndMode and GetModConfigData("houndNumber") or 1 -- 1 = use the game's default
local daysGap = houndMode and GetModConfigData("daysGap") or 1 -- 1 = use the game's default
local wargStrength = houndMode and GetModConfigData("wargStrength") or 1 -- 1 = use the game's default
local wargNumber = houndMode == "customized" and GetModConfigData("wargNumber") or 0
local seasonHound = GetModConfigData("seasonHound") or 0 -- 1 = use the game's default
local wargRealsed = 0
TUNING.WARG_BOSS_STRENGTH = wargStrength

PrefabFiles = 
{
    "warg_boss"
}

-- Hound config
local houndCfg =
{
    base_prefab = "hound",
    winter_prefab = "icehound",
    summer_prefab = "firehound",

    attack_levels =
    {
        intro   = { warnduration = function() return 120 end, numspawns = function() return 2 end },
        light   = { warnduration = function() return 60 end, numspawns = function() return 2 + math.random(2) end },
        med     = { warnduration = function() return 45 end, numspawns = function() return 3 + math.random(3) end },
        heavy   = { warnduration = function() return 30 end, numspawns = function() return 4 + math.random(3) end },
        crazy   = { warnduration = function() return 30 end, numspawns = function() return 10 * houndNumber end },
    },

    attack_delays =
    {
        rare        = function() return TUNING.TOTAL_DAY_TIME * 6, math.random() * TUNING.TOTAL_DAY_TIME * 7 end,
        occasional  = function() return TUNING.TOTAL_DAY_TIME * 4, math.random() * TUNING.TOTAL_DAY_TIME * 7 end,
        frequent    = function() return TUNING.TOTAL_DAY_TIME * 6, TUNING.TOTAL_DAY_TIME * daysGap end,
    },

    warning_speech = "ANNOUNCE_HOUNDS",

    --Key = time, Value = sound prefab
    warning_sound_thresholds =
    {
        { time = 30, sound = "LVL4" },
        { time = 60, sound = "LVL3" },
        { time = 90, sound = "LVL2" },
        { time = 500, sound = "LVL3" },
    },
}

if wargNumber == 0 then
    wargStrength = 1
end

if seasonHound == 0 then
    houndCfg.winter_prefab = "hound"
    houndCfg.summer_prefab = "hound"
end

if wargStrength == 4 and wargNumber > 1 then
    wargNumber = 1
end

if houndMode == "customized" then
    AddPrefabPostInit("hound", function(inst)
        inst:RemoveComponent("sanityaura")
    end)
end

AddPrefabPostInit("forest", function(inst)
    _iForest = inst
    if inst.components.hounded then
        if houndMode == "customized" then
            inst.components.hounded:SetSpawnData(houndCfg)
            inst.components.hounded:SpawnModeHeavy()
        elseif houndMode == "never" then
            inst.components.hounded:SpawnModeNever()
        end
    end
end)

-- Set the spawn mode for the cave attacks
AddPrefabPostInit("cave", function(inst)
    if wormMode == "never" then
        if inst.components.hounded then
            inst.components.hounded:SpawnModeNever()
        end
    end
end)

local function AttackString(timeToAttack)
    if timeToAttack == 0 then
        return 'Hounds Attack: Today!'
    elseif timeToAttack == 1 then
        return 'Hounds Attack: 1 day left'
    end
    return 'Hounds Attack: ' .. timeToAttack  .. ' days left'
end

local function EraseHound()
    if wargNumber > 0 then
        for _,v in pairs(GLOBAL.Ents) do
            if v.prefab == "hound" or v.prefab == "warg_boss" then
                v:Remove()
            end
        end
    else
        for _,v in pairs(GLOBAL.Ents) do
            if v.prefab == "hound" then
                v:Remove()
            end
        end
    end
    local _timeToAttack = _G.TheWorld.components.hounded:GetTimeToAttack()
    wargRealsed = wargNumber
    if _timeToAttack > 0 then
        HoundFlag = -1
        if HoundTask ~= nil then
            HoundTask:Cancel()
            HoundTask = nil
        end
        wargRealsed = 0
        _G.TheNet:Announce("Erasing finished. Good luck next time!")
        local timeToAttack = math.floor(_timeToAttack / 480)
        _G.TheNet:Announce(AttackString(timeToAttack))
    end
end

local function EraseCtrl(player)
    if not player.Network:IsServerAdmin() or houndMode ~= "customized" then
        return
    end
    HoundFlag = -HoundFlag
    if HoundFlag == 1 then
        if HoundTask == nil then
            _G.TheNet:Announce("Erasing hounds...")
            HoundTask = _iForest:DoPeriodicTask(.4, EraseHound)
        else
            _G.TheNet:Announce("Erasing is in progress...")
        end
    end
end

local function IsDefaultScreen()
    local HUD_IF = _G.ThePlayer and _G.ThePlayer.HUD and not _G.ThePlayer.HUD:HasInputFocus()
    return HUD_IF
end

-- AddSimPostInit(function()
--     if not _G.TheNet:IsDedicated() then
--         _G.TheInput:AddKeyDownHandler(safeKey, function()
--             if not IsDefaultScreen() or not _G.TheWorld:HasTag("forest") then return end
--             SendModRPCToServer(MOD_RPC[modname]["EraseCtrl"])
--         end)
--     end
-- end)

AddModRPCHandler(modname, "EraseCtrl", EraseCtrl)

AddPrefabPostInit("world", function(inst)
    inst:ListenForEvent("cycleschanged", function(inst)
        if _G.TheWorld:HasTag("cave") or not _G.TheWorld.components.hounded then return end
        local _timeToAttack = _G.TheWorld.components.hounded:GetTimeToAttack()
        if _timeToAttack > 0 then wargRealsed = 0 end
        if DAYS_IN_ADVANCE == -1 then return end
        local timeToAttack  =  math.floor(_timeToAttack / 480)
        if timeToAttack <= DAYS_IN_ADVANCE and _G.TheWorld.state.cycles ~= 0 then
            _G.TheNet:Announce(AttackString(timeToAttack))
        end
    end, _G.TheWorld)
end)

local UpvalueHacker = _G.require "tools/upvaluehacker"

AddClassPostConstruct("components/hounded", function(self) 
    local _SummonSpawn = UpvalueHacker.GetUpvalue(self.OnUpdate, "ReleaseSpawn", "SummonSpawn")
    local _targetableplayers = UpvalueHacker.GetUpvalue(self.OnUpdate, "ReleaseSpawn", "_targetableplayers")
    local function NoHoles(pt)
        return not _G.TheWorld.Map:IsPointNearHole(pt)
    end
    local function GetSpawnPoint(pt)
        if not _G.TheWorld.Map:IsAboveGroundAtPoint(pt:Get()) then
            pt = _G.FindNearbyLand(pt, 1) or pt
        end
        local offset = _G.FindWalkableOffset(pt, math.random() * 2 * _G.PI, 30, 12, true, true, NoHoles)
        if offset ~= nil then
            offset.x = offset.x + pt.x
            offset.z = offset.z + pt.z
            return offset
        end
    end
    local function SummonSpawn(pt)
        local spawn_pt = GetSpawnPoint(pt)
        if spawn_pt ~= nil then
            local spawn = _G.SpawnPrefab("warg_boss")
            if spawn ~= nil then
                spawn.Physics:Teleport(spawn_pt:Get())
                spawn:FacePoint(pt)
                if spawn.components.spawnfader ~= nil then
                    spawn.components.spawnfader:FadeIn()
                end
                return spawn
            end
        end
    end
    local function ReleaseSpawn(target)	
        if not _targetableplayers[target.GUID] or _targetableplayers[target.GUID] == "land" then
            local spawn = nil
            if wargNumber ~= nil and wargNumber > 0 and wargRealsed < wargNumber then
                spawn = SummonSpawn(target:GetPosition())
                wargRealsed = wargRealsed + 1
            else
                spawn = _SummonSpawn(target:GetPosition())
            end
            if spawn ~= nil then
                spawn.components.combat:SuggestTarget(target)
                return true
            end
        end
        return false
    end
    UpvalueHacker.SetUpvalue(self.OnUpdate, ReleaseSpawn, "ReleaseSpawn")

    local function CalcPlayerAttackSize(player)
        return houndCfg.attack_levels.crazy.numspawns()
    end

    if houndMode == 'customized' then
        UpvalueHacker.SetUpvalue(self.OnUpdate, CalcPlayerAttackSize, "GetWaveAmounts", "CalcPlayerAttackSize")
    end
end)

if houndMode == 'customized' and wargStrength == 4 then
	-- AddClassPostConstruct("components/hunter", function (self)
	-- 	local alternate_beasts = { "spat" }
	-- 	UpvalueHacker.SetUpvalue(self.OnDirtInvestigated, alternate_beasts, "SpawnHuntedBeast", "_alternate_beasts")
    -- end)
    AddComponentPostInit("combat",function(inst)
        if not GLOBAL.TheWorld.ismastersim then
            return
        end
        local oldbonusdamagefn = inst.bonusdamagefn
        inst.bonusdamagefn = function(attacker, target, damage, weapon)
            local bonus = 0
            if oldbonusdamagefn then
                bonus = oldbonusdamagefn(attacker, target, damage, weapon) or 0
            end
            if target.prefab == "warg_boss" and (attacker.prefab == "tentacle" or attacker.prefab == "pigman" or
                attacker.prefab == "spider" or attacker.prefab == "spider_warrior" or attacker.prefab == "bunnyman" or
                attacker.prefab == "eyeturret" or attacker.prefab == "winona_catapult" or attacker.prefab == "trap_teeth") then
                bonus = 1 - damage
            end
            return bonus
        end
    end)
end