function data()
return 
	{ 
		id = "TIN_ORE", name = _("Tin ore"), weight = 2600.0,
		order = 4,
		levelModels = { 
			MEDIUM4x1 = "industry/cargo/level/iron_ore_level_4x1.mdl", 
			MEDIUM2x1 = "industry/cargo/level/iron_ore_level_2x1.mdl"
		},
		discreteModels = { 
			SMALL = "industry/cargo/iron_ore_small.mdl", 
			BIG = "industry/cargo/iron_ore_big.mdl"
		},
	}
end
