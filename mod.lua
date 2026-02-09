function data()
return {
	info = {
		minorVersion = 0,
		severityAdd = "WARNING",
		severityRemove = "CRITICAL",
		name = _("mod_name"),
		description = _("mod_desc"),
		authors = {
			{
				name = "tomylana93",
				role = "CREATOR",
			},
		},
		tags = { "script mod", "indonesia" },
		visible = true,
	},
	options = {
	},
	runFn = function (settings, modParams)
		-- Initialization logic here
	end,
	postRunFn = function (settings, modParams)
		-- Post-initialization logic here
	end,
}
end
