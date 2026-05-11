function data()
return {
	numLanes = 4,
	streetWidth = 16.0,
	sidewalkWidth = 4.0,
	sidewalkHeight = .00,
	yearFrom = 0,
	yearTo = 1945,
	aiLock = false,
	country = true,
	speed = 70.0,
	type = "country old large",
	name = _("Large country road"),
	desc = _("Four-lane road with a speed limit of %2%."),
	categories = { "country" },
	borderGroundTex = "street_border.lua",
	sidewalkFillGroundTex = "country_sidewalk.lua",
	materials = {
		streetPaving = {
			name = "street/country_old_medium_paving.mtl"
		},
		streetBorder = {
			name = "",
			size = { 24, 0.520 }
		},
		streetLane = {
			name = "street/country_old_large_lane.mtl",
			size = { 32.0, 4.0 }
		},
		streetStripe = {

		},
		streetStripeMedian = {
			name = "",
		},
		streetTram = {
			name = "street/old_medium_tram_paving.mtl",
			size = { 2.0, 2.0 }
		},
		streetTramTrack = {
			name = "street/old_medium_tram_track.mtl",
			size = { 2.0, 2.0 }
		},
		streetBus = {
			name = "",
		},
		crossingLane = {
			name = "street/country_old_large_lane.mtl",
			size = { 32.0, 4.0 }
		},
		crossingBus = {
			name = "",
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
			name = "",
			size = { 20, 3.6 }
		},
		sidewalkBorderOuter = {
			name = "street/country_old_medium_sidewalk_border_outer.mtl",
			size = { 8.0, 4.0 }
		},
		sidewalkCurb = {
		},
		sidewalkWall = {
		}
	},
	cost = 75.0,
}
end
