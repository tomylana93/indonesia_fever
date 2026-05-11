function data()
return {
	numLanes = 2,
	streetWidth = 6.0,
	sidewalkWidth = 3.0,
	sidewalkHeight = .0,
	yearFrom = 1945,
	yearTo = 1990,
	aiLock = false,
	country = true,
	speed = 30.0,
	type = "country mid small",
	name = _("Small country road"),
	desc = _("Two-lane road with a speed limit of %2%."),
	categories = { "country" },
	materials = {
		streetPaving = {
			name = "street/country_new_medium_paving.mtl",
			size = { 8.0, 8.0 }
		},
		streetBorder = {
			name = "street/country_new_small_street_border.mtl",
			size = { 9.0, 0.56 }
		},
		streetLane = {
			name = "street/new_medium_lane.mtl",
			size = { 2.5, 2.5 }
		},
		streetStripe = {

		},
		streetStripeMedian = {

		},
		streetBus = {

		},
		streetTram = {
			name = "street/new_medium_tram_paving.mtl",
			size = { 2.0, 2.0 }
		},
		streetTramTrack = {
			name = "street/new_medium_tram_track.mtl",
			size = { 2.0, 2.0 }
		},
		junctionBorder = {
			name = "street/country_new_small_street_border.mtl",
			size = { 9.0, 0.56 }
		},
		crossingLane = {
			name = "street/new_medium_lane.mtl",
			size = { 2.5, 2.5 }
		},
		crossingBus = {
			name = ""
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
	cost = 25.0,
}
end
