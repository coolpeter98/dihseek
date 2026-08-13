
local net = require("@lune/net")
local serde = require("@lune/serde")
local task = require("@lune/task")

local env = require("../../.env")

local get_context_from_channel_id = require("./get_context_from_channel_id")
local add_message_to_context = require("./add_message_to_context")
local get_tools = require("../get_tools")

-- channel_id is actually a number, but the goofy library passes it as a string...
local function prompt(message: string, channel_id: string) : any
	add_message_to_context("user", message, channel_id)

	-- the type checker errors here, but this code is completely valid
	-- it's taken verbatim from the Lune docs.
	local response = net.request({
		url = "https://api.deepseek.com/chat/completions",
		method = "POST",
		headers = {
			["Content-Type"] = "application/json",
			Authorization = `Bearer {env.DEEPSEEK_API_KEY}`,
		},
		body = serde.encode("json", {
			model = "deepseek-v4-pro",
			messages = get_context_from_channel_id(channel_id),
			thinking = { type = "disabled" },
			reasoning_effort = "low",
			tools = get_tools(true)
		}),
	})
	if response.statusCode == 200 then
		local decoded = serde.decode("json", response.body)

		local reply = decoded.choices[1].message.content

		task.defer(function()
			add_message_to_context("assistant", reply, channel_id)
		end)

		local used_tool = decoded.choices[1].finish_reason == "tool_calls"

		if used_tool then
			tool_call = decoded.choices[1].message.tool_calls[1]["function"] or nil

			return {
				reply = reply,
				used_tool = used_tool,
				tool_name = tool_call.name,
				tool_arguments = serde.decode("json", tool_call.arguments),
			}
		end

		-- didn't use any tools so just return the reply
		return {
			reply = reply,
		}
	else
		return `Error: {response.statusCode}`
	end
end

return prompt
