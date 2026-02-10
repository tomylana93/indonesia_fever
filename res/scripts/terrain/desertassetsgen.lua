local data = {}
				
data.Make = function(layers, mkTemp, config, heightMap, ridgesAndMesaMap, mesaMap, ridgesMap, canyonCutoffMap, distanceMap)
	-- PARAMS
	-- Rock types
	local sandstone = 1
	local granite = 2
	local desert_rock = 3
	local savanna_rock = 4
	local hf = 10 -- offset for granite

	local assetsMapping = {
		[sandstone] = "sandstone",
		[granite] = "desert_rock",
		[desert_rock] = "desert_rock",
		[savanna_rock] = "savanna_rock",
		[sandstone + hf] = "granite",
		[granite + hf] = "granite",
		[desert_rock + hf] = "granite",
		[savanna_rock + hf] = "granite",
	}
	-- Tree types
	local forest = 1
	local cactus = 2
	local shrub = 3
	local broadleaf = 4
	local desert = 6
	local savanna = 7
	local canyon_shrub = 8
	local mesa_shrub = 9
	local ridge_shrub = 10
	local anyTree = 255
	
	local treesMapping = {
		[forest] = "forest",
		[cactus] = "cactus",
		[shrub] = "shrub",
		[broadleaf] = "broadleaf",
		[savanna] = "savanna_shrub",
		[desert] = "desert_shrub",
		[canyon_shrub] = "canyon_shrub",
		[mesa_shrub] = "mesa_shrub",
		[ridge_shrub] = "ridge_shrub",
		[anyTree] = "all",
	}
	
	if config.humidity == -1 then
		local forestMap = mkTemp:Get()
		local rocksMap = mkTemp:Get()
		layers:Constant(forestMap, 0)
		layers:Constant(rocksMap, -1)
		return forestMap, treesMapping, rocksMap, assetsMapping
	end
	
	-- Global settings
	local mesaHeightStart = 85
	local mesaHeightEnd = 110
	local ridgeHeightStart = 160
	local ridgeHeightEnd = 190
	
	-- Slopes
	local maxRiverSlope = 0.5
	local maxHillSlope = 0.6
	
	-- Heights
	local hillsLowLimit = 20 
	local hillsHighLimit = 80 
	
	-- LEVEL -1: Scattered trees (DISABLED)
	local scatteredTreesProbability = 0
	
	-- LEVEL 1a and 1b: Plain trees (DISABLED)
	local plainForestBaseDensity = 0
	
	-- LEVEL 0: River trees
	local treeMaxDistanceFromRiver = 100 -- Reduced for Indonesia-style
	local treeMinDistanceFromRiver = 5
	local startPermeability = 0.7
	local maxPermeability = 0.6
	local seedDensity = 0.005 
	local seedDensity2 = 0.004
		
	local riverTree1Dist = {0.5, 0.6}
	local riverTree1Type = {0, cactus, forest}
	local riverTree2Dist = {0.5, 0.6}
	local riverTree2Type = {0, cactus, shrub}
	
	-- LEVEL 2: Hill trees
	local treeHillsLowDensity = 0.75 
	local treeHillsHighDensity = 0.45 
	local treeHillsDist = {0.6, 0.7}
	local treeHillsTypes = {0, cactus, broadleaf}
	
	-- River bank rocks
	local layerRiverBank_maxDistance = 15
	local layerRiverBank_gain = 1.4
	local layerRiverBank_density = 3.5
	
	-- PRECOMPUTATIONS
	local forestMap = mkTemp:Get()
	layers:Constant(forestMap, 0)
	
	local tempMap = mkTemp:Get()
	local slopeMap = mkTemp:Get()
	layers:Grad(heightMap, slopeMap, 2)
	
	local ditheringMap = mkTemp:Get()
	layers:Dithering(ditheringMap, "LOCAL")
	
	-- Slope cutoffs
	local slopeCutoffMap = mkTemp:Get()
	layers:Pwconst(slopeMap, slopeCutoffMap, {maxRiverSlope}, {1, 0})
	local slopeCutoff2Map = mkTemp:Get()
	layers:Pwconst(slopeMap, slopeCutoff2Map, {maxHillSlope}, {1, 0})

	-- #################
	-- #### LEVEL 2 : Hill Trees
	do
		local M = mkTemp:Get()
		layers:RidgedNoise(M, { octaves = 5, frequency = 1.0 / 2200.0, lacunarity = 2.5, gain = 20.0})
		layers:Map(M, M, {0, 1}, {0, 5}, false)
		
		local hillProb = mkTemp:Get()
		layers:Add(ridgesMap, M, hillProb)
		layers:Pwconst(hillProb, hillProb, {hillsLowLimit, hillsHighLimit}, {0, 1, 0})
		
		local densityMap = mkTemp:Get()
		layers:Map(heightMap, densityMap, {hillsLowLimit, hillsHighLimit}, {treeHillsLowDensity, treeHillsHighDensity}, true)
		layers:WhiteNoiseNonuniform(densityMap, densityMap, 0.6)
		
		layers:Mul(slopeCutoff2Map, densityMap, densityMap)
		layers:Mul(hillProb, densityMap, densityMap)
		
		layers:Pwconst(ditheringMap, tempMap, treeHillsDist, treeHillsTypes)
		layers:Mask(densityMap, tempMap, forestMap)
		
		mkTemp:Restore(densityMap)
		mkTemp:Restore(hillProb)
		mkTemp:Restore(M)
	end

	-- #################
	-- #### LEVEL 0: river trees
	if not config.noWater then 
		local xMap = mkTemp:Get()
		local yMap = mkTemp:Get()
		local probabilityMap = mkTemp:Get()
	
		layers:Pwconst(distanceMap, xMap, {treeMinDistanceFromRiver}, {0, 1})
		layers:Mul(xMap, slopeCutoffMap, xMap)
		
		layers:Pwlerp(distanceMap, yMap, {0, 20, treeMaxDistanceFromRiver, treeMaxDistanceFromRiver+20}, {startPermeability, maxPermeability, 0, 0})
		layers:Mul(xMap, yMap, xMap)
		
		layers:WhiteNoiseNonuniform(xMap, xMap)
		layers:Map(xMap, xMap, {0, 1}, {1, 0}, true)
		
		layers:Pwconst(ditheringMap, yMap, {1 - seedDensity}, {0, -1})
	
		layers:Percolation(xMap, yMap, probabilityMap, {
			seedThreshold = -0.5,
			noiseThreshold = 0.5,
			maxCluster = 20000,
		})
		
		local riverTrees = mkTemp:Get()
		layers:Pwconst(ditheringMap, riverTrees, riverTree1Dist, riverTree1Type)
		layers:Mask(probabilityMap, riverTrees, tempMap)
		layers:Add(tempMap, forestMap, forestMap)
		
		mkTemp:Restore(riverTrees)
		mkTemp:Restore(probabilityMap)
		mkTemp:Restore(yMap)
		mkTemp:Restore(xMap)
	end
	
	-- #################
	-- #### ROCKS
	local rocksMap = mkTemp:Get()
	layers:Constant(rocksMap, 0)
	
	local tempRocksMap = mkTemp:Get()
	layers:Map(distanceMap, tempRocksMap, { 0, layerRiverBank_maxDistance }, { layerRiverBank_density, 0}, true)
	
	local noise2Map = mkTemp:Get()
	layers:RidgedNoise(noise2Map, { octaves = 3, lacunarity = 10.5, frequency = 1.0 / 800.0, gain = 1.4})
	layers:Map(noise2Map, noise2Map, { 0.3, 0.8 }, { -1, 1}, true)
	
	layers:Add(tempRocksMap, noise2Map, tempRocksMap)
	layers:Map(distanceMap, noise2Map, { 0, layerRiverBank_maxDistance * 2 }, { 2.0, 0}, true)
	layers:Mul(noise2Map, tempRocksMap, tempRocksMap)
	noise2Map = mkTemp:Restore(noise2Map)
	
	layers:Mul(tempRocksMap, distanceMap, tempRocksMap)
	layers:Pwconst(tempRocksMap, tempRocksMap, {0.5}, {0, 1})
	
	local noise3Map = mkTemp:Get()
	layers:WhiteNoise(noise3Map, 0.2)
	layers:Mul(noise3Map, tempRocksMap, tempRocksMap)
	mkTemp:Restore(noise3Map)
	
	layers:Mul(slopeCutoffMap, tempRocksMap, rocksMap)
	
	-- Height based rock type
	local hfMap = mkTemp:Get()
	layers:Pwconst(ridgesAndMesaMap, hfMap, {120}, {desert_rock, granite})
	layers:Mask(rocksMap, hfMap, rocksMap)
	mkTemp:Restore(hfMap)
	
	-- Cleanup
	mkTemp:Restore(tempRocksMap)
	mkTemp:Restore(slopeCutoff2Map)
	mkTemp:Restore(slopeCutoffMap)
	mkTemp:Restore(ditheringMap)
	mkTemp:Restore(slopeMap)
	mkTemp:Restore(tempMap)
	
	return forestMap, treesMapping, rocksMap, assetsMapping
end

return data
