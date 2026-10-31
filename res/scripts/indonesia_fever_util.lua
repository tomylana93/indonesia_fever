-- Shared helpers for plain Lua data and exact base-game resource filtering.
local util = {}

function util.copy(value)
	if type(value) ~= "table" then return value end
	local result = {}
	for key, item in pairs(value) do result[key] = util.copy(item) end
	return result
end

function util.equal(a, b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a == b end
	for key, value in pairs(a) do if not util.equal(value, b[key]) then return false end end
	for key in pairs(b) do if a[key] == nil then return false end end
	return true
end

function util.baseGameFilter(prefix, filenames)
	local allowed = {}
	for _, filename in ipairs(filenames) do allowed[filename] = true end
	return function(filename)
		if filename:sub(1, #prefix) ~= prefix then return true end
		return allowed[filename:match("([^/]+)$")] == true
	end
end

return util
