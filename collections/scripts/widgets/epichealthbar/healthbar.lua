local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Widget = require "widgets/widget"

local THEMES = require "widgets/epichealthbar/themes"

local MUSTTAGS = { "epic", "_health", "_combat" }
local NOTAGS = { "INLIMBO", "player", "flight", "sleeping" }

local function onboss(self, boss, oldboss)
	if boss ~= nil and boss ~= oldboss then
		if oldboss ~= nil then
			self:DoFlick()
		end
		 
		self.name:SetString(boss:GetBasicDisplayName())
		
		local theme = THEMES[WORLD_SPECIAL_EVENT] and THEMES[WORLD_SPECIAL_EVENT][boss.prefab] or THEMES.none[boss.prefab] or THEMES.none.generic
		self.blood:SetTint(theme[1], theme[2], theme[3], 0.8)
	end
end

local function oncurrenthealth(self, currenthealth, oldcurrenthealth)
	if currenthealth ~= oldcurrenthealth then
		self.currenthealth_text:SetString(math.floor(currenthealth + 0.5))
		self.currenthealth_text:SetPosition(self.currenthealth_text.pt.x + self.currenthealth_text:GetRegionSize() * 0.5, self.currenthealth_text.pt.y, self.currenthealth_text.pt.z)
	end
end

local function onmaxhealth(self, maxhealth, oldmaxhealth)
	if maxhealth ~= oldmaxhealth then
		self.maxhealth_text:SetString(math.floor(maxhealth + 0.5))
		self.maxhealth_text:SetPosition(self.maxhealth_text.pt.x + self.maxhealth_text:GetRegionSize() * -0.5, self.maxhealth_text.pt.y, self.maxhealth_text.pt.z)
			
		if maxhealth >= 10000 then
			self.flames:Show()
		else
			self.flames:Hide()
		end
	end
end

local function onpercent(self, percent, oldpercent)
	if percent ~= oldpercent then
		self.percent_text:SetString(subfmt("[{percent}%]", { percent = math.floor(percent * 100 + 0.5) }))
		
		local width = self.width * percent
		for i, v in ipairs({ "blood_bg", "blood" }) do
			self[v]:ScaleToSize(width, self.height)	
			self[v]:SetPosition((width - self.width) / 2, 0, 0)
		end
		width = self.width * (1 - percent)
		self.blood_empty:ScaleToSize(width, self.height)	
		self.blood_empty:SetPosition((self.width - width) / 2, 0, 0)
	end
end

local function HasPlayerTarget(inst)
	local target = inst.replica.combat and inst.replica.combat:GetTarget()
	return target ~= nil and target:HasTag("player") or not inst:HasTag("locomotor")
end

local function HasHealthData(inst)
	return Waffles.Valid(inst) and inst.epichealthbar ~= nil and inst.replica.health ~= nil and not inst.replica.health:IsDead()
end

local function FindBoss(inst)
	return HasHealthData(inst) and HasPlayerTarget(inst)
end

local function ValidateBoss(inst)
	if HasHealthData(inst) then
		for i, v in ipairs(NOTAGS) do
			if inst:HasTag(v) then
				if v ~= "sleeping" or not HasPlayerTarget(inst) then
					return false
				end
			end
		end
		return true
	end
	return false
end

local function OnPerformAction(self, owner)
	if owner:HasTag("attack") and HasHealthData(owner.replica.combat:GetTarget()) then
		self:StartUpdating()
	end
end

local function OnAttacked(self, owner, data)
	if data ~= nil and (data.isattackedbydanger or HasHealthData(data.attacker)) then
		self:StartUpdating()
	end
end

local function OnTriggeredEvent(self, owner, data)
	self:StartUpdating()
end

local function PullEventAnnouncer(owner, y)
	local eventannouncer = Waffles.Return(owner, "HUD/eventannouncer")
	if eventannouncer ~= nil then
		eventannouncer:MoveTo(eventannouncer:GetPosition(), { x = 0, y = y or 0, z = 0 }, 0.5)
	end
end

local EpicHealthbar = Class(Widget, function(self, owner)
	Widget._ctor(self, "EpicHealthbar")
	self.owner = owner
	
	self.scale = 0.94
	self.flick_scale = self.scale + 0.05
	self:SetScale(self.scale)
	
	self:SetPosition(0, 39.5 * self.scale, 0)
	self:SetClickable(false)

	self.width = 475
	self.height = 28
	
	self.blood_bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
	self.blood_bg:ScaleToSize(self.width, self.height)
	self.blood_bg:SetTint(1, 1, 1, 0.55)
	self.blood_bg:SetBlendMode(1)
	
	self.blood = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
	self.blood:ScaleToSize(self.width, self.height)
	self.blood:SetBlendMode(1)
	
	self.flames = self:AddChild(Widget("flames"))
	for i = 1, 4 do
		local flame = self.flames:AddChild(UIAnim())		
		flame:SetScale(0.11)
		flame:SetPosition(180 + -101 * i, 58, 0)
		
		local anim = flame:GetAnimState()
		anim:SetBank("fire_over")
		anim:SetBuild("fire_over")
		anim:HideSymbol("fire_over01")
		anim:PlayAnimation("anim", true)
		anim:SetMultColour(0, 0, 0, 0.25)
	end
	self.flames:Hide()

	self.blood_empty = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))
	self.blood_empty:ScaleToSize(self.width, self.height)
	self.blood_empty:SetTint(1, 1, 1, 0.55)
	self.blood_empty:SetBlendMode(1)
	
	self.frame = self:AddChild(Image("images/ui/boss_hb.xml", "boss_hb.tex"))
	self.frame:SetPosition(-1, -8.2, 0)
	
	self.name = self:AddChild(Text(TALKINGFONT, 28))
	self.name:SetHAlign(ANCHOR_MIDDLE)

	self.percent_text = self:AddChild(Text(TALKINGFONT, 20))
	self.percent_text:SetHAlign(ANCHOR_MIDDLE)
	self.percent_text:SetPosition(0, -28, 0)
	
	self.currenthealth_text = self:AddChild(Text(TALKINGFONT, 20))
	self.currenthealth_text:SetHAlign(ANCHOR_LEFT)
	self.currenthealth_text:SetPosition(-231.2, -1.2, 0)
	self.currenthealth_text.pt = self.currenthealth_text:GetPosition()
	
	self.maxhealth_text = self:AddChild(Text(TALKINGFONT, 20))
	self.maxhealth_text:SetHAlign(ANCHOR_RIGHT)
	self.maxhealth_text:SetPosition(232.6, -1.2, 0)
	self.maxhealth_text.pt = self.maxhealth_text:GetPosition()
	
	self:Hide()
		
	self.inst:ListenForEvent("performaction", function(...) OnPerformAction(self, ...) end, owner)
	self.inst:ListenForEvent("attacked", function(...) OnAttacked(self, ...) end, owner)
	self.inst:ListenForEvent("triggeredevent", function(...) OnTriggeredEvent(self, ...) end, owner)
end,
{
	boss = onboss,
	currenthealth = oncurrenthealth,
	maxhealth = onmaxhealth,
	percent = onpercent,
})

function EpicHealthbar:Appear()
	if not self.expanded then
		self.expanded = true
		self:Show()
		self:MoveTo(self:GetPosition(), { x = 0, y = -35.5 * self.scale, z = 0 }, 0.5)
		PullEventAnnouncer(self.owner, -55)
	end
end

function EpicHealthbar:Disappear()
	if self.expanded then
		self.expanded = false
		self:MoveTo(self:GetPosition(), { x = 0, y = 39.5 * self.scale, z = 0 }, 0.5, function() if not self.expanded then self:Hide() end end)
		PullEventAnnouncer(self.owner)
		
		if not HasHealthData(self.boss) then
			self.currenthealth = 0
			self.percent = 0
		end
		self.boss = nil
	end
end

function EpicHealthbar:DoFlick()
	if self.expanded then
		self:ScaleTo(self.scale, self.flick_scale, 0.1, function() self:ScaleTo(self.flick_scale, self.scale, 0.1) end)
	end
end

function EpicHealthbar:OnUpdate(dt)
	local boss = FindEntity(self.owner, TUNING.EPICHEALTHBAR_SEARCH_DIST, FindBoss, MUSTTAGS, NOTAGS)
	if boss ~= nil then
		self.boss = boss
		self.time = GetTime()
	end
		
	if not ValidateBoss(self.boss)
		or self.owner:HasTag("playerghost")
		or not self.owner:IsNear(self.boss, TUNING.EPICHEALTHBAR_SEARCH_DIST + 10)
		or GetTime() - self.time >= TUNING.EPICHEALTHBAR_TIMEOUT then
		
		self:Disappear()
	else
		self:Appear()
		
		self.currenthealth = self.boss.epichealthbar.currenthealth
		self.maxhealth = self.boss.epichealthbar.maxhealth
		self.percent = self.currenthealth / self.maxhealth
	end
end

EpicHealthbar.OnHide = EpicHealthbar.StopUpdating

return EpicHealthbar