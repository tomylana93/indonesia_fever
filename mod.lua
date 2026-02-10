function data()
	return {
		info = {
			minorVersion = 0,
			severityAdd = "WARNING",
			severityRemove = "CRITICAL",
			name = _("mod_name"),
			description = _("mod_desc"),
			authors = {
				{
					name = "tomylana93",
					role = "CREATOR",
				},
			},
			tags = { "script mod", "indonesia" },
			params = {
				{
					key = "historical_tram_electrification",
					name = _("param_historical_tram"),
					tooltip = _("tooltip_historical_tram"),
					values = { _("param_val_default"), _("param_val_historical_tram") },
					defaultIndex = 1,
				},
				{
					key = "historical_track_electrification",
					name = _("param_historical_track"),
					tooltip = _("tooltip_historical_track"),
					values = { _("param_val_default"), _("param_val_historical_track") },
					defaultIndex = 1,
				},
				{
					key = "historical_bus_line",
					name = _("param_historical_bus"),
					tooltip = _("tooltip_historical_bus"),
					values = { _("param_val_default"), _("param_val_historical_bus") },
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
			},
			visible = true,
		},
		options = {
			nameList = { { "indonesia", _("indonesia") } },
		},
	runFn = function(settings, modParams)
		game.config.earnAchievementsWithMods = true
		game.config.industryButton = true

		local params = modParams[getCurrentModId()]
		
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
					addFileFilter("model/animal", function(fileName, data)
						return false
					end)
				end

				-- Load vehicle filter script if Indonesian (Historical) is selected
				if params.vehicle_set == 1 then
					local vehicleFilter = require "vehicle_filter"
					if vehicleFilter and vehicleFilter.data then
						vehicleFilter.data().runFn(settings, modParams)
					end
				end
			end
		end,
		postRunFn = function(settings, modParams)
			-- Post-initialization logic here
		end,
	}
end
