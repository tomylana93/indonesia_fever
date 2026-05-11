function data()
return {
	numLanes = 2,
	streetWidth = 8.0,
	sidewalkWidth = 4.0,
	sidewalkHeight = .3,
	yearFrom = 0,
	yearTo = 1945,
	aiLock = false,
	country = false,
	speed = 50.0,
	type = "old medium",
	name = _("Medium street"),
	desc = _("Two-lane street with a speed limit of %2%."),
	categories = { "urban" },
	borderGroundTex = "street_border.lua",
	materials = {
		streetPaving = {
			name = "street/old_medium_paving.mtl",
			size = { 12.0, 12.0 }
		},
		streetBorder = {
			name = "street/old_medium_border.mtl",
			size = {8,0.8}
		},
		streetLane = {

			name = "street/old_medium_lane.mtl",
			size = { 12.0, 3.0 }

		},
		streetStripe = {

		},
		streetStripeMedian = {
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
		},
		crossingLane = {
			name = "street/old_medium_lane.mtl",
			size = { 12.0, 3.0 }
		},
		crossingBus = {
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
			name = "street/old_medium_crosswalk.mtl",
			size = { 2.5, 2.5 }
		},
		sidewalkPaving = {
			name = "street/old_medium_sidewalk.mtl",
			size = {5.0,5.0}
		},
		sidewalkLane = {

		},
		sidewalkBorderInner = {
			name = "street/old_medium_sidewalk_border_inner.mtl",
			size = { 8.0, 1.2 }
		},
		sidewalkBorderOuter = {
			name = "street/old_medium_sidewalk_border_outer.mtl",
			size = { 3.0, 0.6 }
		},
		sidewalkCurb = {
			name = "street/old_medium_sidewalk_curb.mtl",
			size = {8.0,.3}
		},
		sidewalkWall = {
			name = "street/old_medium_sidewalk_wall.mtl",
			size = {.3,.3}
		}
	},
	assets = {
		{
			name = "street/street_asset_mix/fireplug_eu_a.mdl",
			offset = 10.0,
			distance = 50.0,
			prob = 0.5,
			offsetOrth = 0.4,
			randRot = false,
			oneSideOnly = false,
			alignToElevation = false,
			avoidFaceEdges = false,
		},
		Lamp = {
			name = "street/street_light_eu_a.mdl",
			offset = 6.0,
			distance = 12.0,
			prob = 1.0,
			offsetOrth = 3.4,
			randRot = false,
			oneSideOnly = false,
			alignToElevation = false,
			avoidFaceEdges = false,
			placeOnBridge = true,
		},
		{
			name = "street/street_asset_mix/mailbox_eu_a.mdl",
			offset = 12,
			distance = 40.0,
			prob = 0.3,
			offsetOrth = 0.2,
			randRot = false,
			oneSideOnly = true,
			alignToElevation = false,
			avoidFaceEdges = false,
		},
		{
			name = "street/street_asset_mix/trash_standing_a.mdl",
			offset = 20,
			distance = 50.0,
			prob = 0.5,
			offsetOrth = 2.8,
			randRot = false,
			oneSideOnly = false,
			alignToElevation = false,
			avoidFaceEdges = false,
		},
		{
			name = "asset/tree_bed_old.mdl",
			offset = 15.0,
			distance = 22.0,
			prob = 1.0,
			offsetOrth = 2.89,
			randRot = false,
			oneSideOnly = false,
			alignToElevation = true,
			avoidFaceEdges = true,
		},
		{
			name = "tree/lombardy_poplar.mdl",
			offset = 15.0,
			distance = 22.0,
			prob = 1.0,
			offsetOrth = 2.8,
			randRot = true,
			oneSideOnly = false,
			alignToElevation = false,
			avoidFaceEdges = true,
		},

	},
	cost = 40.0,
}
end
