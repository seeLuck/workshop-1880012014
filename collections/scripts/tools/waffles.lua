_G = GLOBAL

local isnative = {}
for k in pairs(env) do
	isnative[k] = true
end
local function StealGlobalReferences()		
	for k, v in pairs(_G) do
		if not isnative[k] then
			env[k] = v
		end
	end
end
StealGlobalReferences()
AddPrefabPostInit("world", StealGlobalReferences)

--------------------------------------------------------------------------
--[[ Waffles ]]
--------------------------------------------------------------------------

Waffles = {}

local MEMORY = {}
setmetatable(MEMORY, { __mode = "v" })

local function getmemkey(...)
	local key = ""
	for i,v in ipairs(arg) do
		key = key .. "[" .. tostring(v) .. "]"
	end
	return key
end

local function cutpath(path_string)
	local path = {}
	for sub in path_string:gmatch("([^/]+)") do
		local num = tonumber(sub)	
		table.insert(path, num or sub)
	end
	return path
end

Waffles =
{	
	Memory =
	{		
		Load = function(...)	
			return MEMORY[getmemkey(...)]
		end,
		
		Save = function(value, ...)	
			MEMORY[getmemkey(...)] = value
		end,
	},
			
	Valid = function(inst)
		return type(inst) == "table" and inst:IsValid()
	end,
	
	Return = function(root, path)
		local t = root
		for i, v in ipairs(cutpath(path)) do
			if type(t) ~= "table" then
				return
			end
			t = t[v]
		end
		return t
	end,
					
	GetPath = function(root, path)		
		local t = root
		for i, v in ipairs(cutpath(path)) do
			if type(t[v]) ~= "table" then
				t[v] = { GENERIC = t[v] }
			end
			t = t[v]
		end
		return t
	end,
		
	Parallel = function(root, key, exp, lowpriority)
		if type(root) ~= "table" then
			return
		end
		
		lowpriority = not not lowpriority
		local old = root[key]
		local fn = old and Waffles.Memory.Load("Parallel", old, exp, lowpriority)
		
		if old == nil or fn ~= nil then
			root[key] = fn or exp
		else
			if lowpriority then
				root[key] = function(...)
					old(...)
					return exp(...)
				end
			else
				root[key] = function(...)
					exp(...)
					return old(...)
				end
			end
			Waffles.Memory.Save(root[key], "Parallel", old, exp, lowpriority)
		end
		
		return root[key]
	end,
}

if rawget(_G, "Waffles") ~= nil then
	for name, data in pairs(Waffles) do
		if type(data) == "table" then
			for subname, subdata in pairs(data) do				
				Waffles.GetPath(_G, "Waffles/" .. name)[subname] = subdata
			end
		else
			_G["Waffles"][name] = data
		end
	end
else
	rawset(_G, "Waffles", Waffles)
end