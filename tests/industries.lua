package.path = 'res/scripts/?.lua;' .. GAME_RES .. '/scripts/?.lua;' .. package.path
_ = function(value) return value end
-- Game-provided iterator; actual industryutil/constructionutil run unchanged.
orderedPairs = function(values)
	local keys = {}
	for key in pairs(values) do keys[#keys + 1] = key end
	table.sort(keys)
	local i = 0
	return function() i = i + 1; local key = keys[i]; if key then return key, values[key] end end
end
randomSeedFix = math.randomseed
local failures, checks = 0, 0
local function check(name, fn)
	checks = checks + 1
	local ok, err = pcall(fn)
	print((ok and 'PASS ' or 'FAIL ') .. name .. (ok and '' or ': ' .. tostring(err)))
	if not ok then failures = failures + 1 end
end
local function readData(path)
	local env = setmetatable({}, { __index = _G })
	assert(loadfile(path, 't', env))()
	return env.data()
end
check('all Lua and asset data parse', function()
	for _, path in ipairs(SYNTAX_FILES) do assert(loadfile(path), path) end
end)
check('animal option changes density without filtering models', function()
	local oldGame, oldId, oldFilter, oldModifier = game, getCurrentModId, addFileFilter, addModifier
	local ok, err = pcall(function()
		getCurrentModId = function() return 'indonesia_fever' end
		addFileFilter = function() error('animal option must not filter resource files') end
		addModifier = function() end
		for _, option in ipairs({ 0, 1, 'missing', 'no-mod-params' }) do
			game = { config = { animal = { populationDensityMultiplier = 2.5, useLocalSpawning = true } } }
			local mod = readData('mod.lua')
			local params = {
				indonesia_fever = option == 'missing' and {} or { spawn_animals = option },
			}
			if option == 'no-mod-params' then params = nil end
			mod.runFn({}, params)
			assert(game.config.animal.populationDensityMultiplier == (option == 1 and 0 or 2.5))
			assert(game.config.animal.useLocalSpawning == true)
		end
	end)
	game, getCurrentModId, addFileFilter, addModifier = oldGame, oldId, oldFilter, oldModifier
	assert(ok, err)
end)
check('historical vehicle filters keep exact names and allow other mods', function()
	local oldFilter = addFileFilter
	local filters = {}
	addFileFilter = function(kind, fn) filters[kind] = fn end
	local ok, err = pcall(function() require('indonesia_fever_vehicle_filter').install() end)
	addFileFilter = oldFilter
	assert(ok, err)
	for _, case in ipairs({
		{ kind = 'model/vehicle', prefix = 'res/models/model/vehicle/', name = 'horse_cart_as_1850.mdl' },
		{ kind = 'multipleUnit', prefix = 'res/config/multiple_unit/', name = 'ice1.lua' },
	}) do
		local filter = assert(filters[case.kind])
		assert(filter(case.prefix .. case.name))
		assert(not filter(case.prefix .. 'unlisted_' .. case.name))
		assert(not filter(case.prefix .. case.name .. '.bak'))
		assert(filter('mods/another_mod/' .. case.prefix .. 'unlisted.mdl'))
	end
end)
check('shared table helpers isolate nested changes and compare full contents', function()
	local util = require 'indonesia_fever_util'
	local original = { nested = { value = 7 }, enabled = false }
	local copied = util.copy(original)
	assert(util.equal(original, copied))
	copied.nested.value = 8
	assert(original.nested.value == 7 and not util.equal(original, copied))
	assert(not util.equal({}, { enabled = false }))
	assert(not util.equal(1, '1'))
end)
check('all mod option labels exist in both languages', function()
	local labels = readData('strings.lua')
	for _, param in ipairs(readData('mod.lua').info.params) do
		for _, locale in ipairs({ 'en', 'id' }) do
			assert(labels[locale][param.name], param.name)
			assert(labels[locale][param.tooltip], param.tooltip)
			for _, value in ipairs(param.values) do assert(labels[locale][value], value) end
		end
	end
end)
local catalog = {}
check('all industries load with installed industryutil', function()
	for _, path in ipairs(INDUSTRY_FILES) do
		local con = readData(path)
		local result = con.updateFn({ seed = 42, paramX = 0, paramY = 0, state = { groups = {} } })
		catalog[path:match('([^/]+)%.con$')] = { con = con, result = result }
		assert(result.rule and result.stocks and #result.models > 0, path)
	end
end)
local cb = require 'indonesia_fever_callbacks'
check('foreign industry is unchanged', function()
	local con = { type = 'INDUSTRY', updateFn = function() return { rule = { capacity = 100 } } end }
	local original = con.updateFn
	cb.constructionCallback('res/construction/industry/foreign_test.con', con)
	assert(con.updateFn == original, 'global callback rewrites another mod industry')
end)
check('modern compartmentsList supports ore and preserves load configuration', function()
	local config = { cargoEntries = { { type = 'IRON_ORE', capacity = 40, cargoBay = { childId = 2 } } }, toHide = { 'cover' } }
	local vehicle = { metadata = { transportVehicle = { carrier = 'RAIL', compartmentsList = { { loadConfigs = { config } } } } } }
	cb.vehicleCallback('res/models/model/vehicle/waggon/test.mdl', vehicle)
	local found = false
	for _, conf in ipairs(vehicle.metadata.transportVehicle.compartmentsList[1].loadConfigs) do
		if conf.cargoEntries[1].type == 'TIN_ORE' then
			found = true
			assert(conf.cargoEntries[1].capacity == 40 and conf.toHide[1] == 'cover')
		end
	end
	assert(found, 'modern vehicle cannot carry Indonesian ore')
end)
check('town building updates are deterministic without mutating params', function()
	local con = { type = 'TOWN_BUILDING', townBuildingParams = { landUseType = 'RESIDENTIAL' }, updateFn = function() return {} end }
	cb.constructionCallback('res/construction/building/test.con', con)
	local params = { seed = 40, capacity = 40, cargoTypes = { 'FOOD' } }
	local first = con.updateFn(params)
	for i = 1, 100 do
		local nextResult = con.updateFn(params)
		assert((first.rule and first.rule.output.UNSORTED_MAIL) == (nextResult.rule and nextResult.rule.output.UNSORTED_MAIL), 'town production changes on rebuild')
	end
	assert(#params.cargoTypes == 1 and params.cargoTypes[1] == 'FOOD', 'callback mutated game params')
end)
check('viable industry recipes for every year 1850-2030', function()
	assert(next(catalog), 'catalog not loaded')
	for year = 1850, 2030 do
		local active, reachable = {}, { MAIL = true, UNSORTED_MAIL = true, WASTE = true }
		for name, item in pairs(catalog) do
			local a = item.con.availability or {}
			if year >= (a.yearFrom or 1850) and ((a.yearTo or 0) == 0 or year < a.yearTo) then active[name] = item end
		end
		local changed = true
		while changed do
			changed = false
			for _, item in pairs(active) do
				for _, recipe in ipairs(item.result.rule.input) do
					local valid = true
					for i, amount in ipairs(recipe) do
						if amount > 0 and not reachable[item.result.stocks[i].cargoType] then valid = false end
					end
					if valid then
						for cargo in pairs(item.result.rule.output) do
							if not reachable[cargo] then reachable[cargo], changed = true, true end
						end
					end
				end
			end
		end
		for name, item in pairs(active) do
			local viable = false
			for _, recipe in ipairs(item.result.rule.input) do
				local valid = true
				for i, amount in ipairs(recipe) do
					if amount > 0 and not reachable[item.result.stocks[i].cargoType] then valid = false end
				end
				viable = viable or valid
			end
			assert(viable, year .. ' ' .. name .. ' has no reachable input recipe')
		end
	end
end)
check('Indonesian resource chains have customers', function()
	for _, cargo in ipairs({ 'TIN', 'NICKEL', 'CPO', 'FIBER', 'BRICKS', 'WASTE_RESTS' }) do
		local found = false
		for _, item in pairs(catalog) do
			for _, stock in ipairs(item.result.stocks) do if stock.cargoType == cargo then found = true end end
		end
		assert(found, cargo .. ' has no customer')
	end
end)
check('palm plantation starts with commercial cultivation in 1911', function()
	assert(catalog.palm_plantation.con.availability.yearFrom == 1911)
end)
check('all outputs can reach a town or disposal/export sink in each era', function()
	for year = 1850, 2030 do
		local active, reachable, desired = {}, { MAIL = true, UNSORTED_MAIL = true, WASTE = true }, { COMMERCIAL_GOODS = true, INDUSTRIAL_GOODS = true, MAIL = true }
		for cargo, from in pairs({ MECHANIZED_GOODS = 1900, CARS = 1910, GOODS = 1950, IT_GOODS = 1980, DEVICES = 2000 }) do
			if year >= from then desired[cargo] = true end
		end
		for name, item in pairs(catalog) do
			local a = item.con.availability or {}
			if year >= (a.yearFrom or 1850) and ((a.yearTo or 0) == 0 or year < a.yearTo) then active[name] = item end
		end
		local function feasible(item, recipe)
			for i, amount in ipairs(recipe) do
				if amount > 0 and not reachable[item.result.stocks[i].cargoType] then return false end
			end
			return true
		end
		local changed = true
		while changed do
			changed = false
			for _, item in pairs(active) do
				for _, recipe in ipairs(item.result.rule.input) do
					if feasible(item, recipe) then
						for cargo in pairs(item.result.rule.output) do
							if not reachable[cargo] then reachable[cargo], changed = true, true end
						end
					end
				end
			end
		end
		changed = true
		while changed do
			changed = false
			for _, item in pairs(active) do
				local useful = next(item.result.rule.output) == nil
				for cargo in pairs(item.result.rule.output) do useful = useful or desired[cargo] end
				if useful then
					for _, recipe in ipairs(item.result.rule.input) do
						if feasible(item, recipe) then
							for i, amount in ipairs(recipe) do
								local cargo = item.result.stocks[i].cargoType
								if amount > 0 and not desired[cargo] then desired[cargo], changed = true, true end
							end
						end
					end
				end
			end
		end
		for name, item in pairs(active) do
			for cargo in pairs(item.result.rule.output) do assert(desired[cargo], year .. ' ' .. name .. ': stranded ' .. cargo) end
		end
	end
end)
check('all production levels use valid cargo recipes and stock storage', function()
	local known = {}
	for _, path in ipairs(CARGO_FILES) do
		local cargo = readData(path)
		assert(not known[cargo.id], 'duplicate cargo ' .. cargo.id)
		known[cargo.id] = true
	end
	local levels, missingGround = 0, {}
	for _, path in ipairs(INDUSTRY_FILES) do
		local con = cb.constructionCallback(path, readData(path))
		for level = 0, #con.params[1].values - 1 do
			levels = levels + 1
			local result = con.updateFn({ productionLevel = level, seed = 42, paramX = 0, paramY = 0, state = { groups = {} } })
			assert(result.cost > 0 and result.bulldozeCost > 0 and result.rule.capacity > 0, path)
			assert(#result.stocks <= 5, path .. ' exceeds stock limit')
			for _, stock in ipairs(result.stocks) do assert(known[stock.cargoType], path .. ' unknown stock ' .. stock.cargoType) end
			for _, recipe in ipairs(result.rule.input) do
				assert(#recipe == #result.stocks, path .. ' recipe size mismatch')
				for _, amount in ipairs(recipe) do assert(amount >= 0 and amount % 1 == 0, path) end
			end
			for cargo, amount in pairs(result.rule.output) do assert(known[cargo] and amount > 0, path .. ' unknown output ' .. cargo) end
			for _, stock in ipairs(result.stocks) do assert(#stock.edges > 0 or (stock.moreCapacity or 0) > 0, path .. ' missing stock capacity for ' .. stock.cargoType) end
			for _, face in ipairs(result.groundFaces) do
				for _, mode in ipairs(face.modes or {}) do
					if mode.key then
						local name = 'config/ground_texture/' .. mode.key
						local file = io.open('res/' .. name, 'r') or io.open(GAME_RES .. '/' .. name, 'r')
						if file then file:close() else missingGround[name] = true end
					end
				end
			end
		end
	end
	local missing = {}
	for name in pairs(missingGround) do missing[#missing + 1] = name end
	table.sort(missing)
	assert(#missing == 0, 'missing ground textures: ' .. table.concat(missing, ', '))
	print('  validated ' .. #INDUSTRY_FILES .. ' industries / ' .. levels .. ' levels / ' .. #CARGO_FILES .. ' cargo types')
end)
check('both languages cover all industry labels and descriptions', function()
	local labels = readData('strings.lua')
	for name, item in pairs(catalog) do
		for _, locale in ipairs({ 'en', 'id' }) do
			assert(labels[locale][item.con.description.name], locale .. ' missing ' .. name .. ' name')
			assert(labels[locale][item.con.description.description], locale .. ' missing ' .. name .. ' description')
		end
	end
	assert(labels.en.mod_name == 'Indonesia Fever')
end)
check('legacy and modern vehicle alternatives are idempotent and compartment-local', function()
	for _, modern in ipairs({ false, true }) do
		local first = { { type = 'STEEL', capacity = 12, cargoBay = { childId = 7 } } }
		local second = { { type = 'PASSENGERS', capacity = 60 } }
		local vehicle = { metadata = { availability = { yearFrom = 1850 }, transportVehicle = { carrier = 'RAIL' } } }
		local configs
		if modern then
			vehicle.metadata.transportVehicle.compartmentsList = { { loadConfigs = { { cargoEntries = first, toHide = { 'roof' } } } }, { loadConfigs = { { cargoEntries = second } } } }
			configs = vehicle.metadata.transportVehicle.compartmentsList[1].loadConfigs
		else
			vehicle.metadata.transportVehicle.compartments = { { first }, { second } }
			configs = vehicle.metadata.transportVehicle.compartments[1]
		end
		cb.vehicleCallback('res/models/model/vehicle/waggon/test.mdl', vehicle)
		local count = #configs
		cb.vehicleCallback('res/models/model/vehicle/waggon/test.mdl', vehicle)
		assert(#configs == count and count == 5)
		assert(vehicle.metadata.availability.yearFrom == 1850)
		for _, config in ipairs(configs) do
			local entry = modern and config.cargoEntries[1] or config[1]
			assert(entry.capacity == 12 and entry.cargoBay.childId == 7)
		end
		if modern then assert(#vehicle.metadata.transportVehicle.compartmentsList[2].loadConfigs == 1)
		else assert(#vehicle.metadata.transportVehicle.compartments[2] == 1) end
	end
end)
local townModule = require 'indonesia_fever_towns'
local function townFixture(year, population, success)
	local ids, byId = {}, {}
	for _, path in ipairs(CARGO_FILES) do local cargo = readData(path); ids[#ids + 1] = cargo.id; byId[cargo.id] = cargo end
	local recorded = {}
	game = { config = {}, interface = {
		getCargoTypes = function() return ids end,
		getCargoType = function(id) return byId[id] end,
		getGameTime = function() return { time = 100, date = { year = year } } end,
		getTowns = function() return { 42 } end,
		getEntity = function() return { position = { 100000, 100000 } } end,
	} }
	api = { engine = { system = { townBuildingSystem = { getLandUsePersonCapacities = function() return { population, population, population } end } } },
		cmd = { make = { instantlyUpdateTownCargoNeeds = function(id, needs) return { id = id, needs = needs } end },
			sendCommand = function(command, callback) recorded[#recorded + 1] = command; callback(nil, success) end },
	}
	townModule.reset()
	return recorded
end
check('town cargo is dense and respects year gates and small towns', function()
	for _, year in ipairs({ 1850, 1900, 1910, 1950, 1980, 2000, 2030 }) do
		local commands = townFixture(year, 2000, true)
		local state = {}
		townModule.updateTownGoods(state)
		assert(#commands == 1 and state.townsCargoNeeds[42])
		local seen, total = {}, 0
		for _, district in ipairs(commands[1].needs) do
			local count = 0
			for key, id in pairs(district) do
				count = count + 1
				assert(key >= 1 and type(id) == 'number' and not seen[id])
				seen[id] = true
			end
			assert(count == #district, 'sparse cargo array')
			total = total + count
		end
		local expected = 2 + (year >= 1900 and 1 or 0) + (year >= 1910 and 1 or 0) + (year >= 1950 and 1 or 0) + (year >= 1980 and 1 or 0) + (year >= 2000 and 1 or 0)
		assert(total == expected, 'wrong era cargo count: ' .. year)
		townModule.updateTownGoods(state)
		assert(#commands == 1, 'unchanged needs resubmitted')
	end
	local commands = townFixture(1850, 10, true)
	townModule.updateTownGoods({})
	assert(#commands[1].needs[2] == 1 and #commands[1].needs[3] == 1, 'small towns have no demand')
end)
check('failed town commands retry and only successful commands persist', function()
	local commands = townFixture(2000, 2000, false)
	local state = {}
	townModule.updateTownGoods(state)
	assert(state.townsCargoNeeds[42] == nil)
	townModule.updateTownGoods(state)
	assert(#commands == 2, 'failed command was cached')
end)
check('save load never rebuilds industries and disabled spawning avoids scans', function()
	townFixture(1850, 100, true)
	game.interface.upgradeConstruction = function() error('unsafe industry rebuild') end
	game.interface.getEntities = function() error('unnecessary construction scan') end
	local script = readData('res/config/game_script/indonesia_fever_industry.lua')
	script.load({ industryInitialized = false, industryTowns = { 100 } })
	script.update()
	local saved = script.save()
	assert(saved.industryInitialized and saved.industryTowns[1] == 100 and saved.townsCargoNeeds[42])
end)
check('industrial town spawning has a hard cap and waits for command success', function()
	townFixture(2000, 100, true)
	local count = 0
	api.type = { TownInfo = { new = function() return {} end }, Vec2f = { new = function(x, y) return { x, y } end } }
	api.cmd.make.createTowns = function(info) return info end
	api.cmd.sendCommand = function(_, callback) count = count + 1; callback(nil, true) end
	local state = {}
	for id = 1, 5 do
		state.nextTownAttempt = 0
		townModule.createTownAtPlant({ id = id, position = { 0, 0 }, fileName = 'industry/steel_mill.con' }, state)
	end
	assert(count == 3 and state.industryTownCount == 3)
	townModule.reset()
end)
if failures > 0 then error(failures .. '/' .. checks .. ' checks failed') end
print(checks .. ' check groups passed (offline Lua; in-game smoke test still required)')
