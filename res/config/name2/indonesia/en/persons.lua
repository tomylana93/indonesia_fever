local names = require "personnameutil"

function data()
return {
	makeName = function (male)
		local source = names.indonesia.english
		if (male) then
			return source.firstNamesMale[math.random(#source.firstNamesMale)] .. " " .. source.lastNames[math.random(#source.lastNames)]
		else
			return source.firstNamesFemale[math.random(#source.firstNamesFemale)] .. " " .. source.lastNames[math.random(#source.lastNames)]
		end
	end
}
end