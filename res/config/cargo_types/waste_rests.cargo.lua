function data()
return 
	{ 
		id = "WASTE_RESTS", name = _("Waste rests"), weight = 250.0,
		order = 3,
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
