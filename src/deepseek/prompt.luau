
local net = require("@lune/net")
local serde = require("@lune/serde")

local env = require("../../.env")

local get_context_from_channel_id = require("./get_context_from_channel_id")
local add_message_to_context = require("./add_message_to_context")
local get_tools = require("../get_tools")
local call_tool = require("../call_tool")

-- channel_id is actually a number, but the goofy library passes it as a string...
local function prompt(message: string | nil, channel_id: string) : any
	if message then
		add_message_to_context("user", message, channel_id)
	end

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
			thinking = { type = "enabled" },
			reasoning_effort = "high",
			tools = get_tools(true)
		}),
	})
	if response.statusCode == 200 then
		local decoded = serde.decode("json", response.body)

		local reply = decoded.choices[1].message.content

		local tool_data = {}

		tool_data.used_tool = decoded.choices[1].finish_reason == "tool_calls"

		if tool_data.used_tool then
			local tool_call = decoded.choices[1].message.tool_calls[1]["function"] or nil
-- 			print(decoded.choices[1].message.tool_calls)

			tool_data = {
				used_tool 	= true,
				name 		= tool_call.name,
				results 	= call_tool(tool_call.name, serde.decode("json", tool_call.arguments) or {}),
				id 			= decoded.choices[1].message.tool_calls[1].id,
				args 		= serde.decode("json", tool_call.arguments)
			}

			add_message_to_context("assistant", reply, channel_id, tool_data)
			add_message_to_context("tool", tool_data.results, channel_id, tool_data)

			print(
				reply,
				tool_data.used_tool,
				tool_data.name,
				tool_data.args,
				tool_data.id,
				tool_data.results
			)

			return {
				reply 			= reply,
				used_tool 		= tool_data.used_tool,
				tool_name 		= tool_data.name,
				tool_args 		= tool_data.args,
				tool_id 		= tool_data.id,
				tool_results 	= tool_data.results
			}
		end

	add_message_to_context("assistant", reply, channel_id, nil)

	-- didn't use any tools so just return the reply

		return {
			reply = reply,
		}
	else
		return `Error: {response.statusCode}`
	end
end

return prompt
