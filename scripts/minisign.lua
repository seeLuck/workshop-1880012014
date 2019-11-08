--You have to learn to draw by yourself
PrefabFiles = {
	"birdcage",
}
Assets = {}
local showbundle = false
GLOBAL.TUNING.HUAMINISIGN = true
local function gugu(inst)
	if inst:HasTag("burnt") or inst:HasTag("nohuaminisign") then  --of course not 
		return
	end
	local pt = GLOBAL.Vector3(inst.Transform:GetWorldPosition())
    inst.huafx = GLOBAL.SpawnPrefab("huaminisign")
    inst.huafx.entity:SetParent(inst.entity)
	inst.huafx.huachest = inst
end
local inventoryItemAtlasLookup = {}

local function GetAtlas(imagename)
	local atlas = inventoryItemAtlasLookup[imagename]
	if atlas then
		return atlas
	end
	local base_atlas = "images/inventoryimages1.xml"
	atlas = GLOBAL.TheSim:AtlasContains(base_atlas, imagename) and base_atlas or "images/inventoryimages2.xml"
	inventoryItemAtlasLookup[imagename] = atlas
	return atlas
end
AddClassPostConstruct( "components/inventoryitem_replica", function(self, inst)
	local old_SetAtlas = self.SetAtlas
	function self:SetAtlas(atlasname)
		if old_SetAtlas	~= nil then
			old_SetAtlas(self,atlasname)
		end
		self._huastrings = atlasname ~= nil and GLOBAL.resolvefilepath(atlasname) or ""
	end

	function self:GetHuaAtlas()
		return self._huastrings ~= nil and
			self._huastrings ~= "" and
			self._huastrings or
			self:GetAtlas()	
	end
end)

local function bugu(inst)
	if inst.huafx ~= nil and  inst.components.container~= nil then
		local container = inst.components.container
		for i = 1, container:GetNumSlots() do
			local item = container:GetItemInSlot(i)
			if item ~= nil and item.replica.inventoryitem ~= nil  then
				local image = item.replica.inventoryitem:GetImage()
				local  build  = item.replica.inventoryitem:GetHuaAtlas()
				--for bundle
				if showbundle and item.components.unwrappable ~= nil and item.components.unwrappable.itemdata then
					for i, v in ipairs(item.components.unwrappable.itemdata) do
						if  v  then
							image = v.prefab..".tex"
							build =  GetAtlas(image)
							break
						end
					end
				end
				inst.huafx.AnimState:OverrideSymbol("SWAP_SIGN", build, image)
				break
			end
			if i == container:GetNumSlots() and item == nil then
				inst.huafx.AnimState:ClearOverrideSymbol("SWAP_SIGN")
			end
		end
	end
end
local function onsave(inst, data)
	inst.old_Save(inst, data)
	if inst:HasTag("nohuaminisign") then
		data.nohuaminisign = true
	end
end

local function onload(inst, data)
	inst.old_Load(inst, data)
	if data ~= nil and data.nohuaminisign then
		inst:AddTag("nohuaminisign")
	end
end

local function draw(inst)

    if not GLOBAL.TheWorld.ismastersim then
        return inst
    end
	
	inst:ListenForEvent("onclose", bugu)
	inst:DoTaskInTime(0.1,function (inst) --load or build
		gugu(inst)
		bugu(inst)
	end)
	if inst.components.burnable ~= nil then  --remove the fx after burnt
		local onburnt = inst.components.burnable.onburnt or nil 
		inst.components.burnable.onburnt = function()
			if onburnt ~= nil then
				onburnt(inst)
			end
			if inst.huafx ~= nil then 
				inst.huafx:Remove()
				inst.huafx = nil
			end
		end
	end
	
	if inst.prefab == "treasurechest"  and GLOBAL.TUNING.HUAMINISIGN  == true then
		inst.old_Save = inst.OnSave 
		inst.OnSave = onsave
		inst.old_Load = inst.OnLoad
		inst.OnLoad = onload
	end
end

AddPrefabPostInit("treasurechest", draw)
AddPrefabPostInit("dragonflychest", draw)

function PrintTable( tbl ,maxlevel, level)

	if tbl then
		local msg = ""
		level = level or 1
		maxlevel = maxlevel or 2
		if level > maxlevel then
			return 
		end
		local indent_str = ""
		for i = 1, level do
		indent_str = indent_str.."--"
		end
		indent_str = indent_str.."->"
		if level == 1 then
		end
		for k,v in pairs(tbl) do
			local item_str = string.format("%s%s = %s", indent_str .. " ",tostring(k), tostring(v))
			if type(v) == "table" then
				PrintTable(v,maxlevel, level + 1)
			end
		end
		if level == 1 then
		end
	else
	end
end


local enabledmods = GLOBAL.ModManager.enabledmods

local thisname = env.modname 

local oldRegisterPrefabs = GLOBAL.ModManager.RegisterPrefabs 

GLOBAL.ModManager.RegisterPrefabs = function(self)
	oldRegisterPrefabs(self)
	
	for i,modname in ipairs(enabledmods) do
		local mod = GLOBAL.ModManager:GetMod(modname)
		if mod.Assets then 
			local modatlas = {}
			local modatlas_build = {}
			for k,v in ipairs (mod.Assets) do
				if v.type == "ATLAS" then 
					table.insert(modatlas,v.file)
				elseif v.type == "ATLAS_BUILD" then 
					table.insert(modatlas_build,v.file)
				end
				
			end
			for k,v in ipairs(modatlas) do
				local notfind = true
				for x,y in ipairs(modatlas_build) do
					if v == y then
						notfind = false
						break
					end
				end
				if notfind then
				v = string.gsub(v,"%.%./mods/[^/]+/","",1)
				table.insert(Assets,Asset("ATLAS_BUILD",v,256))
				end
			end
		end
		
		if mod.Prefabs then
			for n,prefab in pairs(mod.Prefabs) do
				local modatlas = {}
				local modatlas_build = {}
				if prefab.assets then
					for k,v in pairs (prefab.assets) do
						if v.type == "ATLAS" then 
							table.insert(modatlas,v.file)
						elseif v.type == "ATLAS_BUILD" then 
							table.insert(modatlas_build,v.file)
						end
					end
				end
				for k,v in ipairs(modatlas) do
					local notfind = true
					for x,y in ipairs(modatlas_build) do
						if v == y then
							notfind = false
							break
						end
					end
					if notfind then
					v = string.gsub(v,"%.%./mods/[^/]+/","",1)
					table.insert(Assets,Asset("ATLAS_BUILD",v,256))
					end
				end
			end
		end
	end
	GLOBAL.RegisterPrefabs(GLOBAL.Prefab("MOD_SMARTSIGNOTHER",nil,Assets,nil,true))
	GLOBAL.TheSim:LoadPrefabs({"MOD_SMARTSIGNOTHER"})
	table.insert(self.loadedprefabs,"MOD_SMARTSIGNOTHER")
	
end


GLOBAL.TUNING.SMART_SIGN_DRAW_ENABLE = true
GLOBAL.SMART_SIGN_DRAW = draw