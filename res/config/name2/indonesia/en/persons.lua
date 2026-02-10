local names = require "personnameutil"

local firstNamesMale = names.indonesia.english.firstNamesMale
local firstNamesFemale = names.indonesia.english.firstNamesFemale
local lastNames = names.indonesia.english.lastNames

function data()
	return {
		makeName = function(male)
			if (male) then
				return firstNamesMale[math.random(#firstNamesMale)] .. " " .. lastNames[math.random(#lastNames)]
			else
				return firstNamesFemale[math.random(#firstNamesFemale)] .. " " .. lastNames[math.random(#lastNames)]
			end
		end
	}
end
