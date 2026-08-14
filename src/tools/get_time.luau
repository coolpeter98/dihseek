--!strict

local datetime = require("@lune/datetime")

local get_time = {}

get_time.info = {
	name = "get_time",
	alias = "Get current time",
	description = [[
		Returns the current time in UTC.
	]],
}

get_time.parameters = {
	type = "object",
	properties = {},
}

function get_time.run() : string
	return datetime.now():formatUniversalTime("%Y-%m-%d %H:%M:%S UTC")
end

return get_time
