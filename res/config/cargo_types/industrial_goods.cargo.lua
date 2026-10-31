function data()
return 
	{ 
		id = "INDUSTRIAL_GOODS", 
		name = _("Industrial Materials"), 
		weight = 3500.0,
		order = 18,
		discreteModels = {
			SMALL = "industry/cargo/industrial_goods_small.mdl",
			BIG = "industry/cargo/industrial_goods_big.mdl"
		},
		townInput = {
			"INDUSTRIAL",
		},
	}
end
