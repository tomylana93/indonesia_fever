function data()
return 
	{ 
		id = "FODDER", 
		
		name = _("Fodder"), weight = 600.0,
		order = 6,
		levelModels = { 
			MEDIUM4x1 = "industry/cargo/level/fodder_level_4x1.mdl", 
			MEDIUM2x1 = "industry/cargo/level/fodder_level_2x1.mdl"
		},
		discreteModels = {
			SMALL = "industry/cargo/fodder_small.mdl",
			BIG = "industry/cargo/fodder_big.mdl"
		},
	}
end
