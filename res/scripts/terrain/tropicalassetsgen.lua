local data = {}

data.Make = function(layers, config, mkTemp, heightMap, ridgesMap, distanceMap)
	-- #################
	-- #### PARAMS
	-- Tree types
	local shrub = 1
	local palm = 2
	local forest = 3
	local broadleaf = 5
	local anyTree = 255

	local treesMapping = {
		[forest] = "forest",
		[palm] = "palm",
		[shrub] = "shrub",
		[broadleaf] = "broadleaf",
		[anyTree] = "all",
	}

	local assetsMapping = {
		[1] = "cracked",
		[2] = "granite",
	}

	-- #################
	-- #### CONFIG (MODIFIED FOR INDONESIA)
	local humidityFactor = math.min(1.0, config.humidity * 2.2)
	local lowlandDensityBase = 0.12 + 0.28 * humidityFactor
	local lowlandForestDist = { 0.9 - 0.45 * humidityFactor }
	-- Heights
	local hillsLowLimit = 10
	local hillsMiddleLimit = 60
	local hillsHighLimit = 180

	-- LEVEL 3: Hill trees
	local maxSlope = 0.5
	local hillDensityBase = 0.2 + 0.45 * humidityFactor

	local hillForestDist = { 0.6 - 0.3 * humidityFactor }
	local hillForestTypes = { 0, forest }

	-- #################
	-- #### NO WATER
	if config.humidity == 0 then
		local forestMap = mkTemp:Get()
		local rocksMap = mkTemp:Get()
		layers:Constant(forestMap, 0)
		layers:Constant(rocksMap, -1)
		return forestMap, treesMapping, rocksMap, assetsMapping
	end

	-- #################
	-- #### FOREST INITIALIZATION
	local forestMap = mkTemp:Get()
	layers:Constant(forestMap, 0)

	local tempMap = mkTemp:Get()
	local probabilityMap = mkTemp:Get()
	local ditheringMap = mkTemp:Get()
	layers:Dithering(ditheringMap, "LOCAL")

	-- SLOPE CUTOFF
	local slopeMap = mkTemp:Get()
	layers:Grad(heightMap, slopeMap, 2)
	local slopeMaskMap = mkTemp:Get()
	layers:Pwconst(slopeMap, slopeMaskMap, {maxSlope}, {1, 0})

	-- #################
	-- #### LEVEL 1 : Lowland Trees
	layers:Pwlerp(heightMap, probabilityMap,
		{0, hillsLowLimit, hillsMiddleLimit, hillsMiddleLimit + 30},
		{lowlandDensityBase, lowlandDensityBase, 0, 0}
	)

	local lowlandWaterMask = mkTemp:Get()
	if config.noWater then
		layers:Constant(lowlandWaterMask, 1)
	else
		layers:Pwlerp(distanceMap, lowlandWaterMask,
			{0, 6, 30, 120},
			{0, 0.55 + 0.35 * humidityFactor, 1, 0}
		)
	end

	layers:Mul(lowlandWaterMask, probabilityMap, probabilityMap)
	lowlandWaterMask = mkTemp:Restore(lowlandWaterMask)
	layers:WhiteNoiseNonuniform(probabilityMap, probabilityMap)

	do
		local xtMap = mkTemp:Get()
		layers:Mul(slopeMaskMap, probabilityMap, xtMap)
		layers:Pwconst(ditheringMap, tempMap, lowlandForestDist, hillForestTypes)
		layers:Mask(xtMap, tempMap, forestMap)
		xtMap = mkTemp:Restore(xtMap)
	end

	-- #################
	-- #### LEVEL 3 : Hill Trees (ONLY TREES IN MOUNTAINS)
	layers:Pwlerp(heightMap, probabilityMap,
		{0, hillsMiddleLimit, hillsHighLimit, hillsHighLimit + 40},
		{hillDensityBase, hillDensityBase, 0, 0}
	)

	local ridgesMask = mkTemp:Get()
	layers:Pwlerp(ridgesMap, ridgesMask,
		{0, hillsLowLimit, hillsMiddleLimit, hillsMiddleLimit + 40},
		{0, 0, 1, 1}
	)

	layers:Mul(ridgesMask, probabilityMap, probabilityMap)
	layers:WhiteNoiseNonuniform(probabilityMap, probabilityMap)

	do
		local xtMap = mkTemp:Get()
		layers:Mul(slopeMaskMap, probabilityMap, xtMap)
		layers:Pwconst(ditheringMap, probabilityMap, hillForestDist, hillForestTypes)
		layers:Mask(xtMap, probabilityMap, forestMap)
		xtMap = mkTemp:Restore(xtMap)
	end

	-- #################
	-- #### ROCKS
	local rocksMap = mkTemp:Get()
	layers:Constant(rocksMap, 0)

	local layerBeach_maxDistance = 15
	local tmpRocksMap = mkTemp:Get()
	layers:Map(distanceMap, tmpRocksMap, { 0, layerBeach_maxDistance }, { 3.3, 0}, true)

	local tmpNoise2Map = mkTemp:Get()
	layers:RidgedNoise(tmpNoise2Map, { octaves = 3, lacunarity = 10.5, frequency = 1.0 / 500.0, gain = 1.4})
	layers:Map(tmpNoise2Map, tmpNoise2Map, { 0.4, 0.8 }, { -1, 1}, true)

	layers:Add(tmpRocksMap, tmpNoise2Map, tmpRocksMap)
	layers:Map(distanceMap, tmpNoise2Map, { 0, layerBeach_maxDistance * 2 }, { 2.0, 0}, true)
	layers:Mul(tmpNoise2Map, tmpRocksMap, tmpRocksMap)
	tmpNoise2Map = mkTemp:Restore(tmpNoise2Map)

	local tmpNoise3Map = mkTemp:Get()
	layers:WhiteNoise(tmpNoise3Map, 0.2)
	layers:Mul(tmpNoise3Map, tmpRocksMap, tmpRocksMap)

	-- Only place rocks where land is flat enough
	layers:Mul(slopeMaskMap, tmpRocksMap, rocksMap)

	layers:Pwconst(rocksMap, rocksMap, {0.5}, {0, 2}) -- 2 = granite

	-- Cleanup
	mkTemp:Restore(tmpRocksMap)
	mkTemp:Restore(tmpNoise3Map)
	mkTemp:Restore(ridgesMask)
	mkTemp:Restore(slopeMaskMap)
	mkTemp:Restore(slopeMap)
	mkTemp:Restore(ditheringMap)
	mkTemp:Restore(probabilityMap)
	mkTemp:Restore(tempMap)

	return forestMap, treesMapping, rocksMap, assetsMapping
end

return data
