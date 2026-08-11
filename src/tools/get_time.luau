--!strict

local get_time = {}

get_time.info = {
	name = "get_time",
	alias = "Get current time",
	description = [[
		Returns the current time in EEST.
	]],
}

get_time.parameters = {
	type = "object",
	properties = {},
}

-- TODO actually format this as a proper date instead of just the clock
function get_time.run() : number
	return os.clock()
end

return get_time
