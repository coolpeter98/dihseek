--!strict

local net = require("@lune/net")
local serde = require("@lune/serde")

local env = require("../../.env")

local get_context_from_channel_id = require("./get_context_from_channel_id")
local add_message_to_context = require("./add_message_to_context")

local function prompt(message: string, channel_id)
	add_message_to_context("user", message, channel_id)
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
		}),
	})
	if response.statusCode == 200 then
		local reply = serde.decode("json", response.body).choices[1].message.content
		add_message_to_context("assistant", reply, channel_id)
		return reply
	else
		return response.statusCode
	end

	return serde.decode("json", response.body).choices[1].message.content
end

return prompt
