function data()
return {
	laneConfig = {
		{ forward = true },
		{ forward = true },
		{ forward = true },
	},
	streetWidth = 3.0,
	sidewalkWidth = 3.0,
	sidewalkHeight = .0,
	yearFrom = 0,
	yearTo = 1945,
	aiLock = false,
	country = true,
	speed = 30.0,
	type = "one way country old small",
	name = _("Small one-way country road"),
	desc = _("One-lane one-way country road with a speed limit of %2%."),
	categories = { "country" },
	materials = {
		streetPaving = {
			name = "street/country_old_small_paving.mtl",
			size = { 8.0, 8.0 }
		},
		streetBorder = {
			name = "",
			size = { 16.0, 2.0 }
		},
		streetLane = {
			name = "street/country_old_small_lane.mtl",
			size = { 8.0, 4.0 }
		},
		streetStripe = {

		},
		streetStripeMedian = {

		},
		streetBus = {

		},
		streetTram = {
			name = "street/old_medium_tram_paving.mtl",
			size = { 2.0, 2.0 }
		},
		streetTramTrack = {
			name = "street/old_medium_tram_track.mtl",
			size = { 2.0, 2.0 }
		},
		junctionBorder = {
			name = "",
			size = { 16.0, 2.0 }
		},
		crossingLane = {
			name = "street/country_old_small_lane.mtl",
			size = { 8.0, 4.0 }
		},
		crossingBus = {
			name = ""
		},
		crossingTram = {
			name = "street/old_medium_tram_paving.mtl",
			size = { 2.0, 2.0 }
		},
		crossingTramTrack = {
			name = "street/old_medium_tram_track.mtl",
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
	cost = 25.0,
	borderGroundTex = "street_border.lua",
	sidewalkFillGroundTex = "country_sidewalk.lua",
}
end
