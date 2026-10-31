function data()
return 
	{ 
		id = "COMMERCIAL_GOODS", 
		name = _("Consumer Goods"), 
		weight = 2500.0,
		order = 18,
		discreteModels = {
			SMALL = "industry/cargo/commercial_goods_small.mdl",
			BIG = "industry/cargo/commercial_goods_big.mdl"
		},
		townInput = {
			"COMMERCIAL",
		},
	}
end
