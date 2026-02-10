local data = {}

data.Make = function(layers, config, mkTemp, heightMap, ridgesMap, distanceMap)

	-- #################
	-- #### PARAMS
	-- Tree types
	local conifer = 1
	local shrub = 2
	local hills = 3
	local broadleaf = 4
	local river = 5
	local plains = 6
	local anyTree = 255
	
	local treesMapping = {
		[hills] = "hills",
		[conifer] = "conifer",
		[shrub] = "shrub",
		[broadleaf] = "broadleaf",
		[river] = "river",
		[plains] = "plains",
		[anyTree] = "single",
	}
	
	local assetsMapping = {
		[1] = "granite",
	}		

	-- #################
	-- #### CONFIG
	local noWater = config.water == 0
	
	-- LEVEL 1: Plain trees seed density (DISABLED)
	local seedDensity = 0
	local permeability = 0
	local permeabilityVariance = 0
	local plainTreeVals = {0}
	local plainTreeTypes = { 0, 0}

	-- LEVEL 2: River trees
	-- Distances
	local treeBaseDistanceFromRiver = 10 
	local treeDistanceFromRiver = 40 
	local treeMinDistanceFromRiver = 2 
	-- Densities and composition
	local riverTreeVals = {0.6}
	local riverTreeTypes = { river, 0}

	-- LEVEL 3: Hill trees
	-- Densities and composition
	local hillTreeVals = { 0.75 }
	local hillTreeTypes = { 0, hills}
	-- Heights
	local hillsHighLimit = 130 

	-- LEVEL 4: Ridge trees (conifers)
	-- Densities
	local maxSlope = 0.8 -- also for hills
	local coniferDitheringCutoff = 0.6
	-- Heights
	local coniferLimit = 120 
	local coniferTransitionLow = 30 
	local coniferTransitionHigh = 80 
	
	-- #################
	-- #### NO WATER GENERATION
	if config.humidity == -1 then
		local forestMap = mkTemp:Get()
		local rocksMap = mkTemp:Get()
		layers:Constant(forestMap, 0)
		layers:Constant(rocksMap, -1)
		return forestMap, treesMapping, rocksMap, assetsMapping
	end
	
	-- #################
	-- #### PREPARE DITHERING 
	local ditheringMap = mkTemp:Get()
	local ditheringMap2 = mkTemp:Get()
	layers:Dithering(ditheringMap, "LOCAL")
	layers:Dithering(ditheringMap2, "LOCAL"):SetSeed(math.random())
	
	-- #################
	-- #### FOREST INITIALIZATION
	local forestMap = mkTemp:Get()
	layers:Constant(forestMap, 0)
	
	local tempMap = mkTemp:Get()
	local probabilityMap = mkTemp:Get()

	-- SLOPE CUTOFF
	layers:Grad(heightMap, tempMap, 2)
	local slopeCutoffMap = mkTemp:Get()
	layers:Pwconst(tempMap, slopeCutoffMap, {maxSlope}, {1, 0})

	-- #################
	-- #### LEVEL 3 : Hill Trees
	-- Cutoff from above and below
	layers:Pwlerp(ridgesMap, tempMap,
		{config.hillsLowLimit - 10, config.hillsLowLimit, config.hillsLowLimit + config.hillsLowTransition, config.hillsLowLimit + config.hillsLowTransition + 60},
		{0, 0, 1, 1}
	)
	layers:Pwconst(heightMap, probabilityMap, {hillsHighLimit}, {1, 0})
	layers:Mul(probabilityMap, tempMap, tempMap)
	
	-- Slope cutoff
	layers:Mul(slopeCutoffMap, tempMap, probabilityMap)
	
	-- Content for mask
	layers:Compare(probabilityMap, ditheringMap2, probabilityMap)
	
	layers:Pwconst(ditheringMap, tempMap, hillTreeVals, hillTreeTypes)
	layers:Mul(tempMap, probabilityMap, probabilityMap)
	
	-- Add to forest
	layers:Add(probabilityMap, forestMap, forestMap)
	
	-- #################
	-- #### LEVEL 4 : Mountain Trees
	-- HEIGHT CUTOFF
	layers:Pwlerp(heightMap, tempMap,
		{0, coniferLimit - coniferTransitionLow, coniferLimit, config.treeLimit, config.treeLimit + coniferTransitionHigh, config.treeLimit + coniferTransitionHigh + 20},
		{0, 0, coniferDitheringCutoff, coniferDitheringCutoff, 0, 0}
	)
	layers:Compare(tempMap, ditheringMap2, tempMap)
	
	-- EDGE DETECTIION
	local rocksMap = mkTemp:Get()
	layers:Laplace(ridgesMap, rocksMap)
	
	do
		local temp2Map = mkTemp:Get()
		layers:Pwlerp(ridgesMap, temp2Map, {0, 4, 10, 20}, {0, 0, 1, 1})
		layers:Mul(rocksMap, temp2Map, rocksMap)
		temp2Map = mkTemp:Restore(temp2Map)
	end
	
	layers:Pwconst(rocksMap, rocksMap,
		{-config.ridgeFactor, config.valleyFactor},
		{ conifer, 0, conifer}
	)
	-- BLEND SLOPE, HEIGHT AND RIDGE
	layers:Mul(rocksMap, tempMap, rocksMap)
	
	-- Add to forest
	layers:Add(rocksMap, forestMap, forestMap)
	
	if not noWater then 
		-- LEVEL 2 : river trees
		local yMap = mkTemp:Get()
		layers:GradientNoise(yMap, { octaves = 4, warp = 0.5, lacunarity = 1.4, gain = 2.2})
		
		layers:Map(yMap, yMap, {0, 10}, {0, treeDistanceFromRiver}, true)
		local xMap = mkTemp:Get()
		layers:Pwconst(distanceMap, xMap, {0, treeMinDistanceFromRiver}, {0, 0, 1})
		
		layers:Add(distanceMap, yMap, yMap)
		
		layers:Pwconst(yMap, yMap, {0, treeDistanceFromRiver}, {0, 1, 0})
		layers:Pwconst(ditheringMap, probabilityMap, riverTreeVals, riverTreeTypes)
		
		layers:Mul(xMap, yMap, yMap)
		
		local riverForest = mkTemp:Get()
		layers:Mask(yMap, probabilityMap, riverForest, 0, "GREATER")
		layers:Add(riverForest, forestMap, forestMap)
		
		mkTemp:Restore(riverForest)
		mkTemp:Restore(yMap)
		mkTemp:Restore(xMap)
	end
	
	ditheringMap = mkTemp:Restore(ditheringMap)
	ditheringMap2 = mkTemp:Restore(ditheringMap2)
	probabilityMap = mkTemp:Restore(probabilityMap)
	tempMap = mkTemp:Restore(tempMap)

	-- #################
	-- ####  ROCKS
	layers:Constant(rocksMap, 0)
	
	-- Stones on beach and river banks
	local layerBeach_maxDistance = 12
	local tempRocksMap = mkTemp:Get()
	
	local noise2Map = mkTemp:Get()
	layers:RidgedNoise(noise2Map, { octaves = 3, lacunarity = 10.5, frequency = 1.0 / 400.0, gain = 1.4})
	layers:Map(noise2Map, noise2Map, { 0.4, 0.8 }, { 0, 1}, true)   

	layers:Pwconst(distanceMap, tempRocksMap, {0, layerBeach_maxDistance}, {1, 1, 0})
	layers:Mul(noise2Map, tempRocksMap, rocksMap)
	
	noise2Map = mkTemp:Restore(noise2Map)
	tempRocksMap = mkTemp:Restore(tempRocksMap)
	
	layers:Mul(slopeCutoffMap, rocksMap, rocksMap)
	slopeCutoffMap = mkTemp:Restore(slopeCutoffMap)
	
	layers:Pwconst(rocksMap, rocksMap, {0.5}, {0, 1})
	
	return forestMap, treesMapping, rocksMap, assetsMapping
end

return data
