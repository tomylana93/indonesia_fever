function data()
return 
	{ 
		id = "TRANSIT_GOODS", 
		name = _("Transit goods"), 
		weight = 2500.0,
		order = 50,
		discreteModels = {
			SMALL = "industry/cargo/transit_goods_small.mdl",
			BIG = "industry/cargo/transit_goods_big.mdl"
		},
	}
end
