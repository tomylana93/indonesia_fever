local iif_util = { }

local function tprint(tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		local formatting = string.rep("  ", indent) .. tostring(k) .. ": "
		if type(v) == "table" then
			print(formatting)
			tprint(v, indent + 1)
		else
			print(formatting .. tostring(v))
		end
	end
end

function iif_util.dmp(data)
	if data == nil then return end
	if commonapi and commonapi.dmp then
		commonapi.dmp(data)
	elseif type(data) == "table" then
		tprint(data)
	else
		print(data)
	end
end

return iif_util
