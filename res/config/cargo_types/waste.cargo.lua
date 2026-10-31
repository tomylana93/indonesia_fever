function data()
return 
	{ 
		id = "WASTE", 
		name = _("Waste"), 
		weight = 250.0,
		order = 19,
		levelModels = { 
			MEDIUM4x1 = "industry/cargo/level/waste_level_4x1.mdl", 
			MEDIUM2x1 = "industry/cargo/level/waste_level_2x1.mdl"
		},
		discreteModels = { 
			SMALL = "industry/cargo/waste_small.mdl", 
			BIG = "industry/cargo/waste_big.mdl"
		},
	}
end
