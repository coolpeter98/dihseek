local get_time = {}

get_time.info = {
	alias = "Get current time",
	description = [[
		Returns the current time in EEST.
	]],
}

function get_time.run()
	return os.clock()
end

return get_time
