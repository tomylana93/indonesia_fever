local towns = require "iif_towns"
local industries = require "iif_industries"

local state = { industryTowns = {}, townsCargoNeeds = {}, industryInitialized = true }
local nextTime = 0
local constructionIds, constructionIndex

local function onIndustry(constr)
	if not constr or not industries.isOwned(constr.fileName) or not constr.simBuildings then return end
	for _, id in ipairs(constr.simBuildings) do
		local building = game.interface.getEntity(id)
		if building and (building.level or 0) >= 3 and building.itemsConsumed
			and (building.itemsConsumed._sum or 0) >= 2000 then
			towns.createTownAtPlant(constr, state)
		end
	end
end

local function scanIndustries()
	if not constructionIds then
		constructionIds = game.interface.getEntities({ radius = 1e100 }, { type = "CONSTRUCTION" }) or {}
		constructionIndex = 1
	end
	local last = math.min(constructionIndex + 49, #constructionIds)
	for i = constructionIndex, last do onIndustry(game.interface.getEntity(constructionIds[i])) end
	constructionIndex = last + 1
	if constructionIndex > #constructionIds then constructionIds = nil end
end

function data()
	return {
		update = function()
			local time = game.interface.getGameTime().time
			if time < nextTime then return end
			nextTime = time + 10
			if game.config._IIF_TownSpawning == 1 then scanIndustries() end
			if not game.config._IIF_TownTuning then towns.updateTownGoods(state) end
		end,
		guiUpdate = function() end,
		save = function() return state end,
		load = function(saved)
			towns.reset()
			towns.reset()
			state = type(saved) == "table" and saved or {}
			state.industryTowns = state.industryTowns or {}
			state.townsCargoNeeds = state.townsCargoNeeds or {}
			-- No automatic upgradeConstruction: it used to remove seeds and rebuild
			-- every industry's layout (including industries belonging to other mods).
			state.industryInitialized = true
			nextTime, constructionIds, constructionIndex = 0, nil, nil
		end,
	}
end
