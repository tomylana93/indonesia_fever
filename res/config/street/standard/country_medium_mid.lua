function data()
return {
	numLanes = 2,
	streetWidth = 8.0,
	sidewalkWidth = 4.0,
	sidewalkHeight = .00,
	yearFrom = 1945,
	yearTo = 1990,
	aiLock = false,
	country = true,
	speed = 50.0,
	type = "country mid medium",
	name = _("Medium country road"),
	desc = _("Two-lane road with a speed limit of %2%."),
	categories = { "country" },
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
			name = "street/new_medium_lane.mtl",
			size = { 3.0, 3.0 }
		},
		streetStripe = {

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
			name = "street/new_medium_lane.mtl",
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
	borderGroundTex = "street_border.lua",
	sidewalkFillGroundTex = "country_sidewalk.lua",
	cost = 50.0,
}
end
