local util = require "indonesia_fever_util"
local industries = require "indonesia_fever_industries"
local callbacks = {}

local function bucket(fileName, seed, salt)
	local hash = (tonumber(seed) or 0) % 104729
	for i = 1, #fileName do hash = (hash * 31 + fileName:byte(i)) % 104729 end
	return (hash + salt * 7919) % 100
end

function callbacks.constructionCallback(fileName, data)
	if type(data) ~= "table" or type(data.updateFn) ~= "function" then return data end
	local original = data.updateFn
	if data.type == "TOWN_BUILDING" then
		data.updateFn = function(params)
			-- Never alter the engine's parameter table or reseed the shared RNG.
			local config = game and game.config or {}
			if config._IndonesiaFever_TownTuning then return original(params) end
			local adjusted = util.copy(params)
			local cargoTypes = adjusted.cargoTypes or {}
			local residential = data.townBuildingParams and data.townBuildingParams.landUseType == "RESIDENTIAL"
			if residential and bucket(fileName, params.seed, 1) < 33 then
				local found = false
				for _, cargo in ipairs(cargoTypes) do if cargo == "MAIL" then found = true end end
				if not found then cargoTypes[#cargoTypes + 1] = "MAIL" end
			end
			adjusted.cargoTypes = cargoTypes
			local result = original(adjusted)
			local capacity = math.ceil((params.capacity or 0) / 4)
			if not result or capacity <= 0 or #cargoTypes == 0 then return result end
			-- Respect another town mod's production rules.
			if result.rule and next(result.rule.output or {}) then return result end
			local inputs, stocks = {}, {}
			for i, cargo in ipairs(cargoTypes) do
				local input = {}
				for j = 1, #cargoTypes do input[j] = i == j and 1 or 0 end
				inputs[i] = input
				stocks[i] = { cargoType = cargo, type = "RECEIVING", edges = {}, moreCapacity = capacity * 100 }
			end
			local output = {}
			if residential and bucket(fileName, params.seed, 2) < 33 then
				output.UNSORTED_MAIL = 1
			elseif bucket(fileName, params.seed, 3) < 33 then
				output.WASTE = 1
			end
			result.stocks = stocks
			result.rule = { input = inputs, output = output, capacity = capacity, consumptionFactor = 1.2 }
			return result
		end
	elseif data.type == "INDUSTRY" and industries.isOwned(fileName) then
		data.updateFn = function(params)
			local result = original(params)
			if not result or not result.rule then return result end
			local capacity = result.rule.capacity or 0
			-- Reused stock layouts have fewer visible piles than some recipes.
			-- Give indoor inputs real storage rather than a zero-capacity stock.
			for index, stock in ipairs(result.stocks or {}) do
				if not stock.edges or #stock.edges == 0 then
					local amount = 1
					for _, recipe in ipairs(result.rule.input or {}) do amount = math.max(amount, recipe[index] or 0) end
					stock.moreCapacity = math.max(stock.moreCapacity or 0, capacity * amount * 2)
				end
			end
			local customs = fileName:match("/customs%.con$") ~= nil
			result.personCapacity = result.personCapacity or {
				type = customs and "RESIDENTIAL" or "INDUSTRIAL",
				capacity = math.max(1, math.ceil(capacity / 10)),
			}
			local raw = #((result.rule.input or {})[1] or {}) == 0
			result.cost = math.floor((750000 + capacity * 7500) * (raw and 1.5 or 1))
			result.bulldozeCost = math.floor(result.cost * 0.1)
			result.maintenanceCost = math.floor(result.cost * 0.0001)
			return result
		end
	end
	return data
end

-- Cargo families inherit existing space, loading visuals and capacity. Alternatives
-- share a compartment: this does not add simultaneous payload or change vehicle dates.
local families = {
	GOODS = { "COMMERCIAL_GOODS", "INDUSTRIAL_GOODS", "WOOL", "TEXTILES", "DEVICES", "UNSORTED_MAIL", "MAIL", "PAPER", "FIBER", "SYNTHETIC_FIBER", "LEATHER", "TIRES", "TRANSIT_GOODS", "CANS", "CEMENT", "APPLIANCES", "ELECTRONICS", "IT_GOODS", "MECHANIZED_GOODS", "MULTIMEDIA", "COMPUTERS" },
	IRON_ORE = { "BAUXITE", "COPPER_ORE", "NICKEL_ORE", "TIN_ORE", "CLAY", "WASTE", "WASTE_RESTS", "SAND", "LIMESTONE" },
	GRAIN = { "FODDER" },
	FOOD = { "FISH", "MEAT", "MILK", "LIVESTOCK" },
	PLASTIC = { "RUBBER" },
	CONSTRUCTION_MATERIALS = { "BRICKS", "GLASS", "CONCRETE", "CEMENT" },
	STEEL = { "COPPER", "ALUMINIUM", "NICKEL", "TIN" },
	OIL = { "CPO", "CRUDE" },
	FUEL = { "CPO", "CRUDE" },
	CRUDE = { "CPO" },
	MWCARS = { "CARS" },
	DDC = { "CEMENT" },
	DDRABFALL = { "WASTE", "WASTE_RESTS" },
	ABFALL = { "WASTE", "WASTE_RESTS" },
}

local function extend(configs, modern)
	local present, originals = {}, #configs
	for _, config in ipairs(configs) do
		for _, entry in ipairs(modern and config.cargoEntries or config) do
			if entry.type then present[entry.type:upper()] = true end
		end
	end
	for i = 1, originals do
		local entries = modern and configs[i].cargoEntries or configs[i]
		-- Multiple entries may represent a fixed mixed load. Leave those intact.
		if #entries == 1 then
			local entry = entries[1]
			local alternatives = families[(entry.type or ""):upper()] or {}
			for _, cargo in ipairs(alternatives) do
				if not present[cargo] and (entry.capacity or 0) > 0 then
					local alternative = util.copy(configs[i])
					local target = modern and alternative.cargoEntries or alternative
					target[1].type = cargo
					configs[#configs + 1], present[cargo] = alternative, true
				end
			end
		end
	end
end

function callbacks.vehicleCallback(fileName, data)
	if type(data) ~= "table" then return data end
	local vehicle = data.metadata and data.metadata.transportVehicle
	if not vehicle then return data end
	for _, compartment in ipairs(vehicle.compartments or {}) do extend(compartment, false) end
	for _, compartment in ipairs(vehicle.compartmentsList or {}) do
		if compartment.loadConfigs then extend(compartment.loadConfigs, true) end
	end
	return data
end

return callbacks
