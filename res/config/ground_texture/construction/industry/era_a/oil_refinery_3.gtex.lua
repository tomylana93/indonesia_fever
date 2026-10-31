-- Reuse the stock refinery surface for the additional production level.
local tu = require "texutil"

function data()
return {
	texture = tu.makeMaterialIndexTexture("res/textures/terrain/material/construction/industry/era_a/oil_refinery_2.tga", "CLAMP_TO_EDGE", "CLAMP_TO_EDGE"),
	texSize = { 140, 121.1 },
	materialIndexMap = {
		[1] = "dirt.lua",
		[2] = "shared/asphalt_01.lua",
		[3] = "shared/asphalt_02.lua",
		[4] = "shared/asphalt_03.lua",
		[5] = "shared/grass_cutted_02.lua",
		[6] = "shared/gravel_03.lua",
		[7] = "shared/gravel_04.lua",
		[8] = "shared/water_dirty.lua",
	},
	priority = 20,
}
end
