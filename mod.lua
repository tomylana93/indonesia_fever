local iifCB = require "iif_callbacks"

local callbacksInstalled = false

function data()
	return {
		info = {
			minorVersion = 1,
			severityAdd = "WARNING",
			severityRemove = "CRITICAL",
			name = _("mod_name"),
			description = _("mod_desc"),
			authors = {
				{
					name = "tomylana93",
					role = "CREATOR",
					text = "Indonesia Fever project",
				},
				{
					name = "Yeol the Clumsy",
					role = "CO-CREATOR",
					text = "Original Senseless Industries 2.21a industry system",
					tfnetId = "37578",
				},
				{
					name = "Klorid",
					role = "CO-CREATOR",
					text = "Cargo models and textures",
				},
				{
					name = "jay_",
					role = "CO-CREATOR",
					text = "Cargo models and textures",
				},
			},
			tags = { "script mod", "indonesia", "industry" },
			params = {
				{
					key = "historical_tram_electrification",
					name = _("param_historical_tram"),
					tooltip = _("tooltip_historical_tram"),
					values = { _("param_val_default_tram"), _("param_val_historical_tram") },
					defaultIndex = 1,
				},
				{
					key = "historical_track_electrification",
					name = _("param_historical_track"),
					tooltip = _("tooltip_historical_track"),
					values = { _("param_val_default_track"), _("param_val_historical_track") },
					defaultIndex = 1,
				},
				{
					key = "historical_bus_line",
					name = _("param_historical_bus"),
					tooltip = _("tooltip_historical_bus"),
					values = { _("param_val_default_bus"), _("param_val_historical_bus") },
					defaultIndex = 1,
				},
				{
					key = "vehicle_set",
					name = _("param_vehicle_set"),
					tooltip = _("tooltip_vehicle_set"),
					values = { _("param_val_default"), _("param_val_historical") },
					defaultIndex = 1,
				},
				{
					key = "spawn_animals",
					name = _("param_spawn_animals"),
					tooltip = _("tooltip_spawn_animals"),
					values = { _("On"), _("Off") },
					defaultIndex = 0,
				},
				{
					key = "townspawning",
					name = _("TOWN_SPAWNING"),
					tooltip = _("TOWN_SPAWNING_TOOLTIP"),
					values = { _("No"), _("Yes") },
					defaultIndex = 0,
				},
			},
			visible = true,
		},
		options = {
			nameList = { { "indonesia", _("indonesia") } },
		},
		runFn = function(settings, modParams)
			game.config.earnAchievementsWithMods = true
			game.config.industryButton = true

			local params = modParams and modParams[getCurrentModId()]

			if params then
				if params.historical_tram_electrification == 1 then
					game.config.tramCatenaryYearFrom = 1899
				end
				if params.historical_track_electrification == 1 then
					game.config.trackCatenaryYearFrom = 1925
				end
				if params.historical_bus_line == 1 then
					game.config.busLaneYearFrom = 2004
				end

				-- Animal spawn control
				if params.spawn_animals == 1 then
					addFileFilter("model/animal", function(fileName)
						if fileName:match("^res/models/model/animal/") then
							return false
						end
						return true
					end)
				end

				-- Load vehicle filter script if Indonesian (Historical) is selected
				if params.vehicle_set == 1 then
					local vehicleFilter = require "vehicle_filter"
					if vehicleFilter and vehicleFilter.data then
						vehicleFilter.data().runFn(settings, modParams)
					end
				end

				game.config._IIF_TownSpawning = params.townspawning or 0
			else
				game.config._IIF_TownSpawning = 0
			end

			if not callbacksInstalled then
				if iifCB.constructionCallback and iifCB.vehicleCallback then
					addModifier("loadModel", iifCB.vehicleCallback)
					addModifier("loadConstruction", iifCB.constructionCallback)
					callbacksInstalled = true
				else
					print("Indonesia Fever ERROR: callbacks are not reachable")
				end
			end
		end,
		postRunFn = function(settings, modParams)
			-- Disable the town cargo mechanism when the "Town Tuning" mod is present.
			game.config._IIF_TownTuning = nil
			for key1, value1 in pairs(modParams or {}) do
				if type(value1) == "table" then
					for key2, value2 in pairs(value1) do
						if key2 == "fasterTownDevelopInterval" then
							game.config._IIF_TownTuning = 1
							print("Indonesia Fever: Town Tuning mod found, town cargo mechanism disabled")
						end
					end
				end
			end
		end,
	}
end
