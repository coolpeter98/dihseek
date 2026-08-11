--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local DEFAULT_SYSTEM_PROMPT = require("../constants/DEFAULT_SYSTEM_PROMPT")

local add_message_to_context = require("./add_message_to_context")

local function get_context_from_channel_id(channel_id)
	local file = `src/deepseek/contexts/{channel_id}.json`

	if not fs.isFile(file) then
		add_message_to_context("system", DEFAULT_SYSTEM_PROMPT, channel_id)
	end
	return serde.decode("json", fs.readFile(file))
end

return get_context_from_channel_id
