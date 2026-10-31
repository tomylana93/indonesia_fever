local util = require "indonesia_fever_util"
local industries = require "indonesia_fever_industries"
local towns = {}
local pending = {}
local cursor = 1

local demands = {
	{ cargo = "COMMERCIAL_GOODS", district = 2, year = 1850, population = 0 },
	{ cargo = "INDUSTRIAL_GOODS", district = 3, year = 1850, population = 0 },
	{ cargo = "MECHANIZED_GOODS", district = 3, year = 1900, population = 200 },
	{ cargo = "CARS", district = 2, year = 1910, population = 400 },
	{ cargo = "GOODS", district = 2, year = 1950, population = 800 },
	{ cargo = "IT_GOODS", district = 3, year = 1980, population = 1200 },
	{ cargo = "DEVICES", district = 2, year = 2000, population = 1000 },
}

local function cargoIndices()
	local result = {}
	for index, id in ipairs(game.interface.getCargoTypes()) do
		local cargo = game.interface.getCargoType(id)
		if cargo then result[cargo.id] = index - 1 end
	end
	return result
end

local function needsFor(population, year, indices, previous)
	local result = { {}, {}, {} }
	local existing = {}
	for _, district in ipairs(previous or {}) do
		for _, cargo in ipairs(district) do existing[cargo] = true end
	end
	for _, demand in ipairs(demands) do
		local id = indices[demand.cargo]
		local threshold = demand.population + (existing[id] and -25 or 25)
		if id ~= nil and year >= demand.year and (demand.population == 0 or population > threshold) then
			local district = result[demand.district]
			district[#district + 1] = id
		end
	end
	return result
end

function towns.updateTownGoods(state)
	if not state then return end
	local indices = cargoIndices()
	if indices.COMMERCIAL_GOODS == nil or indices.INDUSTRIAL_GOODS == nil then return end
	state.townsCargoNeeds = state.townsCargoNeeds or {}
	local ids = game.interface.getTowns()
	local year = game.interface.getGameTime().date.year
	-- Bounded work per tick; every town is visited over successive calls.
	for _ = 1, math.min(20, #ids) do
		if cursor > #ids then cursor = 1 end
		local id = ids[cursor]
		cursor = cursor + 1
		local capacities = api.engine.system.townBuildingSystem.getLandUsePersonCapacities(id)
		if capacities and #capacities >= 3 and not pending[id] then
			local population = (capacities[1] + capacities[2] + capacities[3]) / 3
			local desired = needsFor(population, year, indices, state.townsCargoNeeds[id])
			if not util.equal(desired, state.townsCargoNeeds[id]) then
				pending[id] = true
				api.cmd.sendCommand(api.cmd.make.instantlyUpdateTownCargoNeeds(id, desired), function(_, success)
					pending[id] = nil
					-- Failed commands remain retryable. Never persist an unapplied demand.
					if success then state.townsCargoNeeds[id] = desired end
				end)
			end
		end
	end
end

local pendingTown = false
function towns.createTownAtPlant(constr, state)
	if not state or not constr or not constr.id or not constr.position or not industries.isOwned(constr.fileName) then return end
	state.industryTowns = state.industryTowns or {}
	-- The old list can contain attempted towns; count it conservatively on migration.
	state.industryTownCount = state.industryTownCount or #state.industryTowns
	if pendingTown or state.industryTownCount >= 3 then return end
	for _, id in ipairs(state.industryTowns) do if id == constr.id then return end end
	local time = game.interface.getGameTime().time
	if time < (state.nextTownAttempt or 0) then return end
	local x, y = constr.position[1] + 600, constr.position[2] + 600
	for _, id in ipairs(game.interface.getTowns()) do
		local town = game.interface.getEntity(id)
		if town and town.position then
			local dx, dy = x - town.position[1], y - town.position[2]
			if dx * dx + dy * dy < 2000 * 2000 then return end
		end
	end
	local info = api.type.TownInfo.new()
	info.name = ""
	info.position = api.type.Vec2f.new(x, y)
	info.initialLandUseCapacities = { 25, 25, 25 }
	pendingTown = true
	state.nextTownAttempt = time + 3600
	api.cmd.sendCommand(api.cmd.make.createTowns({ info }), function(_, success)
		pendingTown = false
		if success then
			state.industryTowns[#state.industryTowns + 1] = constr.id
			state.industryTownCount = state.industryTownCount + 1
		end
	end)
end

function towns.reset()
	pending, pendingTown, cursor = {}, false, 1
end

function towns.reset()
	pending, pendingTown, cursor = {}, false, 1
end

return towns
