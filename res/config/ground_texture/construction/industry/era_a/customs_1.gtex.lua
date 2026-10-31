local tu = require "texutil"

function data()
return {
	texture = tu.makeMaterialIndexTexture("res/textures/terrain/material/construction/industry/customs_1.tga", "CLAMP_TO_EDGE", "CLAMP_TO_EDGE"),
		
	texSize = { 100, 100 },
	materialIndexMap = {
		[1] = "grass_alpine.lua",
		[2] = "grass_brown.lua",
		[3] = "grass_dark_green.lua",
		[4] = "shared/grass_cutted_02.lua",
	},


	priority = 20,
}
end
