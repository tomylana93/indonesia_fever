function data()
return 
	{ 
		id = "GRAIN", 
		
		name = _("Crops"), weight = 600.0,
		order = 6,
		levelModels = { 
			MEDIUM4x1 = "industry/cargo/level/grain_level_4x1.mdl", 
			MEDIUM2x1 = "industry/cargo/level/grain_level_2x1.mdl"
		},
		discreteModels = {
			SMALL = "industry/cargo/grain_small.mdl",
			BIG = "industry/cargo/grain_big.mdl"
		},
	}
end
