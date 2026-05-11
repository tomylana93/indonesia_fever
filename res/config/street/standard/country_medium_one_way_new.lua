function data()
return {
	laneConfig = {
		{ forward = true },
		{ forward = true },
		{ forward = true },
		{ forward = true },
	},
	streetWidth = 8.0,
	sidewalkWidth = 4.0,
	sidewalkHeight = .00,
	yearFrom = 1990,
	yearTo = 0,
	aiLock = true,
	country = true,
	speed = 50.0,
	type = "one way country new medium",
	name = _("Medium highway"),
	desc = _("Two-lane one-way road with a speed limit of %2%."),
	categories = { "highway" },
	materials = {
		streetPaving = {
			name = "street/country_new_medium_paving.mtl",
			size = { 8.0, 8.0 }
		},
		streetBorder = {
			name = "street/country_new_large_border.mtl",
			size = { 24, 0.459 }
		},
		junctionBorder = {
			name = "street/country_new_large_border.mtl",
			size = { 24, 0.459 }
		},
		streetLane = {
			name = "street/country_new_medium_lane.mtl",
			size = { 3.0, 3.0 }
		},
		streetArrow = {
			name = "street/default_arrows.mtl",
			size = { 6.0, 3.0 }
		},
		streetStripe = {
			name = "street/country_new_medium_stripes.mtl",
			size = { 32.0, .5 }
		},
		streetStripeMedian = {
			name = "street/country_new_medium_stripes.mtl",
			size = { 32.0, .5 }
		},
		streetTram = {
			name = "street/new_medium_tram_paving.mtl",
			size = { 2.0, 2.0 }
		},
		streetTramTrack = {
			name = "street/new_medium_tram_track.mtl",
			size = { 2.0, 2.0 }
		},
		streetBus = {
			name = "street/new_medium_bus.mtl",
			size = { 12, 2.7 }
		},
		crossingLane = {
			name = "street/country_new_medium_lane.mtl",
			size = { 3.0, 3.0 }
		},
		crossingBus = {
			name = "",
		},
		crossingTram = {
			name = "street/new_medium_tram_paving.mtl",
			size = { 2.0, 2.0 }
		},
		crossingTramTrack = {
			name = "street/new_medium_tram_track.mtl",
			size = { 2.0, 2.0 }
		},
		crossingCrosswalk = {
			name = ""
		},
		sidewalkPaving = {
			name = ""
		},
		sidewalkLane = {
		},
		sidewalkBorderInner = {
		},
		sidewalkBorderOuter = {

		},
		sidewalkCurb = {
		},
		sidewalkWall = {
		}
	},
	cost = 50.0,
	borderGroundTex = "street_border.lua",
	sidewalkFillGroundTex = "country_sidewalk.lua",
}
end
