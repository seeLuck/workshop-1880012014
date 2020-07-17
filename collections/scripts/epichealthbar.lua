modimport "scripts/tools/waffles"

table.insert(Waffles.GetPath(env, "Assets"), Asset("ATLAS", "images/hud/epichealthbar.xml"))

TUNING.EPICHEALTHBAR =
{
	COMBAT_TIMEOUT = 10,
	TRIGGER_DIST = 20,
	THEMES =
	{
		DEFAULT =
		{		
			GENERIC =			{ 0.90, 0.05, 0.05 },
			DEERCLOPS =			{ 0.31, 0.45, 0.62 },
			BEARGER =			{ 0.07, 0.07, 0.07 },
			MOOSE =				{ 0.31, 0.18, 0.31 },
			DRAGONFLY =			{ 0.20, 0.00, 0.00 },											   
			ANTLION =			{ 0.80, 0.47, 0.13 },
			TOADSTOOL =			{ 0.18, 0.03, 0.33 },
			TOADSTOOL_DARK =	{ 0.91, 0.85, 0.24 },
			BEEQUEEN =			{ 0.80, 0.47, 0.13 },
			KLAUS =				{ 0.90, 0.05, 0.05 },											   
			MINOTAUR =			{ 0.55, 0.52, 0.49 },
			STALKER =			{ 0.28, 0.24, 0.55 },
			STALKER_ATRIUM =	{ 0.90, 0.05, 0.05 },
			STALKER_FOREST =	{ 0.34, 0.49, 0.23 },											   
			SPIDERQUEEN =		{ 0.93, 0.66, 0.72 },
			LEIF =				{ 0.14, 0.36, 0.25 },
			LEIF_SPARSE =		{ 0.14, 0.36, 0.25 },
			SHADOW_ROOK =		{ 0.07, 0.07, 0.07 },
			SHADOW_KNIGHT =		{ 0.07, 0.07, 0.07 },
			SHADOW_BISHOP =		{ 0.07, 0.07, 0.07 },
			MALBATROSS =		{ 68 / 255, 90 / 255, 137 / 255 },
			CRABKING =			{ 239 / 255, 237 / 255, 140 / 255 },
		},                                         
											
		WINTERS_FEAST =                            
		{                                          
			DEERCLOPS =			{ 0.69, 0.23, 0.21 },
			BEARGER =			{ 0.85, 0.87, 0.69 },
			MOOSE =				{ 0.34, 0.23, 0.18 },
			DRAGONFLY =			{ 0.90, 0.71, 0.15 },
		},
	},
}

local NETVAR_EXCEPTIONS =
{
	toadstool_dark = net_uint,
	crabking = net_uint,
}

local NO_EPIC_PRISTINE =
{
	shadow_knight = true,
	shadow_bishop = true,
	shadow_rook = true,
	crabking = true,
}

local function OnEnterEpicCombat(inst)
	if inst._parent ~= nil then
		inst._parent:PushEvent("enterepiccombat")
	end
end

AddPrefabPostInit("player_classified", function(inst)
	inst.epiccombat = net_event(inst.GUID, "epiccombat")
	inst:ListenForEvent("epiccombat", OnEnterEpicCombat)
end)

local EpicHealthbar = require "widgets/epichealthbar"
AddClassPostConstruct("widgets/controls", function(self)
	self.epichealthbar = self.top_root:AddChild(EpicHealthbar(self.owner))
end)

local function OnCurrentHealthDirty(inst)
    inst.epichealthbar.currenthealth = inst.epichealthbar_currenthealth:value()
end

local function OnMaxHealthDirty(inst)
    inst.epichealthbar.maxhealth = inst.epichealthbar_maxhealth:value()
end

local function OnHealthDelta(inst)
	if inst.components.health ~= nil then
       	inst.epichealthbar_currenthealth:set(inst.components.health.currenthealth)
       	inst.epichealthbar_maxhealth:set(inst.components.health.maxhealth)
   	end
end

local function OnTargetPlayer(inst)
	local target = inst.components.combat and inst.components.combat.target
	if target ~= nil and target:HasTag("player") then
		for i, v in ipairs(AllPlayers) do
			if v.player_classified ~= nil then
				v.player_classified.epiccombat:push()
			end
		end
	end
end

local function AddEpicHealthbarNetvars(inst)
	if inst.epichealthbar_currenthealth ~= nil then
		return
	end
	
	local netvar = NETVAR_EXCEPTIONS[inst.prefab] or net_ushortint
    inst.epichealthbar_currenthealth = netvar(inst.GUID, "epichealthbar_currenthealth", "epichealthbar_currenthealth_dirty")
    inst.epichealthbar_maxhealth = netvar(inst.GUID, "epichealthbar_maxhealth", "epichealthbar_maxhealth_dirty")
    
   	if not TheNet:IsDedicated() then
       	inst.epichealthbar = { currenthealth = 0, maxhealth = 0 }
		inst:ListenForEvent("epichealthbar_currenthealth_dirty", OnCurrentHealthDirty)
       	inst:ListenForEvent("epichealthbar_maxhealth_dirty", OnMaxHealthDirty)		
   	end
		
   	if not TheWorld.ismastersim then
       	return
   	end

	inst:ListenForEvent("healthdelta", OnHealthDelta)
	inst:ListenForEvent("newcombattarget", OnTargetPlayer)
	inst:ListenForEvent("entitywake", OnTargetPlayer)	
	OnHealthDelta(inst)
	OnTargetPlayer(inst)
end

Waffles.Parallel(require "components/health_replica", "_ctor", function(self, inst)
	if inst:HasTag("epic") then
		if inst.prefab == nil then
			inst:DoTaskInTime(0, AddEpicHealthbarNetvars)
		else
			AddEpicHealthbarNetvars(inst)
		end
	end
end)

for k in pairs(NO_EPIC_PRISTINE) do
	AddPrefabPostInit(k, AddEpicHealthbarNetvars)
end