local vec2 = require "vec2"
local maputil = require "maputil"
local desertassetsgen = require "terrain/desertassetsgen"
local desertlayers = require "terrain/desertlayers"
local layersutil = require "terrain/layersutil"
local rivermapgenutil = require "terrain/rivermapgenutil"
local mapgenutil = require "terrain/mapgenutil"

function data() 
return {
	climate = "dry.clima.lua",
	order = 1,
	name = _("Desert"),
	params = {
		{
			key = "canyon",
			name = _("Canyons"),
			values = { "", "", "", "", "" },
			defaultIndex = 2,
			uiType = "SLIDER",
		},
		{
			key = "mesa",
			name = _("Mesas"),
			values = { "", "", "", "", "" },
			defaultIndex = 2,
			uiType = "SLIDER",
		},
		{
			key = "ridge",
			name = _("Ridges"),
			values = { "", "", "", "", "" },
			defaultIndex = 2,
			uiType = "SLIDER",
		},
		{
			key = "water",
			name = _("Water"),
			values = { "", "", "", "", "" },
			defaultIndex = 2,
			uiType = "SLIDER",
		},
		{
			key = "forest",
			name = _("Forest"),
			values = { "", "", "", "", "", "", "", },
			defaultIndex = 3,
			uiType = "SLIDER",
		},
	},
	updateFn = function(params)
		local result = { 
			parallelFactor = 32,
			heightmapLayer = "HM",
			layers = layersutil.Layer.new(),
		}

		-- #################
		-- #### CONFIG
		local canyon = params.canyon / 4 + 0.2
		local mesa = params.mesa / 4 * 0.3 + 0.8
		local ridge = params.ridge / 4 * 1.5 + 0.2
		local water = params.water / 4 + 0.4
		local humidity = params.forest / 7
		local noWater = params.water == 0

		local sameSeed = math.random(1, 100000000)
		local canyonMapSizeX = math.max(math.ceil(params.mapSizeX / 1000 * 2), 2)
		local canyonMapSizeY = math.max(math.ceil(params.mapSizeY / 1000 * 2), 2)
		local canyonMapScale = { 1 / (params.mapSizeX / 1000 * 2 / 6), 1 / (params.mapSizeY / 1000 * 2 / 6) }
		local canyonDataMap = maputil.MakePerlin(
			canyonMapSizeX, canyonMapSizeY, canyonMapScale,
			{ params.mapSizeX / (canyonMapSizeX - 1), params.mapSizeY / (canyonMapSizeY - 1) }
		)
		math.randomseed(sameSeed) -- reset seed to match EU generator

		local canyonProbLow =  math.map(canyon, 0, 1, 0.7, -0.3) -- , 0.7, -0.3)
		local canyonProbHigh =  math.map(canyon, 0, 1, 1.2, 0.2) -- , 1.1, 0.1)
		
		local canyonDistance = 2000
		local ridgeCutoffFactor = 200
		local addDunes = true
		local dunesStrength = 8
		
		local canyonConfig = {
			canyonWidthScaling = 0.30, 
			canyonDistanceOffset = -15,
			canyonHeightScaling = 0.16,
			canyonProbLow = canyonProbLow,
			canyonProbHigh = canyonProbHigh,
			canyonness = canyon
		}
		
		local riverConfig = {
			depthScale = 2.2,
			maxOrder = 2,
			curvature = 0.3,
			segmentLength = 2800,
			bounds = params.bounds,
			baseProbability = water * water * 2,
			minDist = water > 0.5 and 2 or 3,
		}
		
		local rivers = {}
		
		if not noWater then
			local start = mapgenutil.FindGoodRiverStart(params.bounds)
			
			local startLength = 120000
			mapgenutil.MakeRivers(rivers, riverConfig, startLength, start.pos, start.angle)
		
			local getCanyoness = function(position) 
				local currentNPosition = vec2.componentwiseDiv(vec2.sub(position, params.bounds.min), vec2.sub(params.bounds.max, params.bounds.min))
				local X = math.floor(currentNPosition.x * canyonDataMap.size[1])
				local Y = math.floor(currentNPosition.y * canyonDataMap.size[2])
				local I = Y * canyonDataMap.size[1] + X
				return canyonDataMap.data[I + 1] == nil and 0 or math.mapClamp(canyonDataMap.data[I + 1], canyonProbLow, canyonProbHigh, 0, 1)
			end
			
			local getWidthMultiplier = function(position) 
				return math.mapClamp(getCanyoness(position), 0, 1, 1.6, 0.5)
			end
			
			local getLakePropability = function(pos)
				if getCanyoness(pos) > 0.2 then return 0 end
				return (1 - getCanyoness(pos) * 1.0)
			end
			
			local subdivideConfig = {
				nSegments = 6,
			}
			local lakeConfig = {
				probability = getLakePropability,
				makeProfile = function(s)
					s = (1 - s*s) + 1
					local s1 = math.pow(s, 0.4) * math.randf(0.6, 1.1)
					local s2 = math.pow(s, 0.4) * math.randf(0.6, 1.1)
					return vec2.new(s1 * water * 180, s2 * water * 180), s * 50
				end,
				endProbability = function(lakeSize) 
					return math.clamp(math.mapClamp(lakeSize, 4, 10, 1.0, 0.0) + water / 8, .0, 1.0)
				end,
				startProbability = function()
					return math.clamp(0.6 + water / 8, .0, 1.0)
				end
			}
			local curvesConfig = {
				baseStrength = 2,
				getCurviness = function(position) return math.mapClamp(getCanyoness(position), 0, 1, 0.1, 1.0) end,
				--getCurviness = function(position) return 1.0 end,
				getWidthMultiplier = getWidthMultiplier
			}
			
			rivermapgenutil.Subdivide(rivers, subdivideConfig)
			rivermapgenutil.MakeLakes(rivers, lakeConfig)
			rivermapgenutil.MakeCurves(rivers, curvesConfig)
			rivermapgenutil.AdjustFeeders(rivers, adjustConfig)
			maputil.Convert(rivers)
			-- maputil.PrintRiver(rivers) 
		end
		
		local ridgesConfig = {
			bounds = params.bounds,
			strengthMap = canyonDataMap,
			probabilityLow = 0.4 + 0.6 * ridge, 
			probabilityHigh = 0.5 + 0.6 * ridge, 
			minHeight = 0 + 120 * ridge,
			maxHeight = 85 + 120 * ridge,
		}
		local valleys = mapgenutil.MakeManyValleys()
		local ridges = mapgenutil.MakeRidges(ridgesConfig)
	
		local initialSeeds = {}
		local count = 0
		for i = 0, mesa * 60 do
			local x = math.random(0, params.mapSizeX - 1)
			local y = math.random(0, params.mapSizeY - 1)
			local X = math.floor(x / params.mapSizeX * canyonDataMap.size[1])
			local Y = math.floor(y / params.mapSizeY * canyonDataMap.size[2])
			if canyonDataMap.data[Y * canyonDataMap.size[1] +  X + 1] < 0 then
				initialSeeds[#initialSeeds + 1] = {x, y}
				count = count + 1
			end
			if count > mesa * 40 then break end
		end
		
		local mesaConfig = {
			initialSeeds = initialSeeds,
			mesaness = mesa, 
			height = 100,
		}
		
		-- #################
		-- #### PREPARE
		local mkTemp = layersutil.TempMaker.new()
		local mesaMap = mkTemp:Get()
		local canyonMap = mkTemp:Get()
		local distanceMap = mkTemp:Get()
		
		-- #################
		-- #### RIVER LAYER
		result.layers:Constant(result.heightmapLayer, 0.01)
		
		if #rivers > 0 then
			local t1 = mkTemp:Get()
			result.layers:River(result.heightmapLayer, rivers)
			
			result.layers:Map(result.heightmapLayer, t1, {-1,1}, {1,-1}, false)
			result.layers:Distance(t1, t1)
			
			result.layers:Pwlerp(t1, t1, {0, 0.2, 5, 20, 30, 40, 50, 100, 150, 155, 170}, {0.1, 0.1, -0.5, -3, -7, -15, -20, -35, -60, -62, -64})
			result.layers:Gauss(t1, result.heightmapLayer, 9, 5)
			mkTemp:Restore(t1)
		end
		
		-- #################
		-- #### CANYON LAYER
		result.layers:Distance(result.heightmapLayer, distanceMap)
		
		result.layers:Data(canyonMap, canyonDataMap, "BICUBIC")
		
		result.layers:Map(canyonMap, canyonMap, {canyonProbLow, canyonProbHigh}, {0, 1}, true)
		
		result.layers:Herp(canyonMap, canyonMap, {0, 1})
		
		-- Add noise away from river
		local addNoise = true
		if addNoise then
			local noiseTemp = mkTemp:Get()
			local cutoff = mkTemp:Get()
			result.layers:RidgedNoise(noiseTemp, { frequency = 1 / 3000, octaves = 6, lacunarity = 1.4, gain = 5.4})
			result.layers:Map(distanceMap, cutoff, {200, 400}, {0, 0.14}, true) -- {0, 0.54}
			result.layers:Mul(noiseTemp, cutoff, noiseTemp)
			result.layers:Add(noiseTemp, canyonMap, canyonMap)
			noiseTemp = mkTemp:Restore(noiseTemp)
			cutoff = mkTemp:Restore(cutoff)
		end
		
		local cutoff = mkTemp:Get()
		result.layers:Map(distanceMap, cutoff, {0, canyonDistance}, {1, 0}, true)
		
		local t1 = mkTemp:Get()
		result.layers:Gauss(cutoff, t1, 3)
		
		result.layers:Herp(t1, cutoff, {0, 1})
		t1 = mkTemp:Restore(t1)
		
		result.layers:Mul(cutoff, canyonMap, canyonMap)
		result.layers:Map(canyonMap, cutoff, {1, 0})
		
		if canyon ~= 0 then
			result.layers:PushColor("#1456FF")
			desertlayers.MakeCanyonLayer(result.layers, mkTemp, canyonConfig, canyonMap, distanceMap, result.heightmapLayer)
			result.layers:PopColor()
		end
		
		-- #################
		-- #### RIDGES LAYER
		--- BEGIN ADD AND BLEND RIDGES ---
		local t1 = mkTemp:Get()
		result.layers:Ridge(t1, {
			valleys = valleys.points,
			ridges = ridges,
			noiseStrength = 10
		})
		
		local t2 = mkTemp:Get()
		result.layers:Map(distanceMap, t2, {50, 1500}, {0, 1}, true)
		
		result.layers:Herp(t2, t2, {0, 1})
		
		local ridgesMap = mkTemp:Get()
		result.layers:Mul(t1, t2, ridgesMap)
		result.layers:Add(ridgesMap, result.heightmapLayer, result.heightmapLayer)
		t1 = mkTemp:Restore(t1)
		t2 = mkTemp:Restore(t2)
		
		-- #################
		-- #### MESA LAYER
		-- Inputs for mesa layer
		local whiteNoiseMap = mkTemp:Get()
		result.layers:WhiteNoise(whiteNoiseMap, 0.416 - mesa * mesa * mesa * 0.007)
		
		-- Prepare cutout for layer
		result.layers:Add(ridgesMap, canyonMap, canyonMap)
		canyonMap = mkTemp:Restore(canyonMap)
		
		local t1 = mkTemp:Get()
		result.layers:Map(ridgesMap, t1, {-1, 0}, {10, 9}, false)
		
		result.layers:Distance(t1, t1)
		
		result.layers:Map(t1, t1, {0, ridgeCutoffFactor}, {0, 1}, true)
		
		result.layers:Herp(t1, t1)
		local canyonCutoffMap = mkTemp:Get()
		result.layers:Copy(cutoff, canyonCutoffMap)
		result.layers:Mul(t1, cutoff, cutoff)
		t1 = mkTemp:Restore(t1)
		
		result.layers:PushColor("#5614FF")
		local mesaCutout = mkTemp:Get()
		desertlayers.MakeMesaLayer(result.layers, mkTemp, mesaConfig, cutoff, distanceMap, whiteNoiseMap, mesaCutout, mesaMap)
		result.layers:PopColor()
		whiteNoiseMap = mkTemp:Restore(whiteNoiseMap)
		cutoff = mkTemp:Restore(cutoff)
		
		local ridgesAndMesaMap = mkTemp:Get()
		result.layers:Copy(mesaMap, ridgesAndMesaMap)
		
		local negativeMap = mkTemp:Get()
		result.layers:Constant(negativeMap, 0)
		result.layers:Mask(result.heightmapLayer, result.heightmapLayer, negativeMap, 0, "LESS")
		result.layers:Compare(mesaMap, result.heightmapLayer, result.heightmapLayer, "MAX")
		result.layers:Add(negativeMap, result.heightmapLayer, result.heightmapLayer)
		negativeMap = mkTemp:Restore(negativeMap)
		
		result.layers:Add(ridgesAndMesaMap, ridgesMap, ridgesAndMesaMap)

		-- #################
		-- #### DUNES LAYER
		if addDunes then
			local t1 = mkTemp:Get()
			result.layers:GradientNoise(t1, {
				octaves = 3, frequency = 1 / 300,
				lacunarity = 0.3, gain = 0.4, warp = 2.6
			})
			result.layers:Map(t1, t1, {0, 1}, {0, dunesStrength}, true)
			result.layers:Mad(t1, mesaCutout, result.heightmapLayer)
			mkTemp:Restore(t1)
		end
		
		-- #################
		-- #### ASSETS LAYER
		local assetConfig = {
			noWater = humidity <= 0,
			humidity = humidity,
		}
		
		result.layers:PushColor("#007777")
		result.forestMap, result.treesMapping, result.assetsMap, result.assetsMapping = desertassetsgen.Make(
			result.layers, mkTemp, assetConfig, result.heightmapLayer, ridgesAndMesaMap, mesaMap, ridgesMap, canyonCutoffMap, distanceMap
		)
		ridgesMap = mkTemp:Restore(ridgesMap)
		result.layers:PopColor()
		mesaCutout = mkTemp:Restore(mesaCutout)
		
		-- #################
		-- #### CLEANUP
		mesaMap = mkTemp:Restore(mesaMap)
		ridgesAndMesaMap = mkTemp:Restore(ridgesAndMesaMap)
		distanceMap = mkTemp:Restore(distanceMap)
		
		mkTemp:Restore(result.forestMap)
		mkTemp:Restore(result.assetsMap)
		mkTemp:Finish()
		-- maputil.PrintGraph(result)
		
		return result
	end
}

end
