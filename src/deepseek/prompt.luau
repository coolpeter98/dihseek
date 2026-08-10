local net = require("@lune/net")

local env = require("../../.env")

local get_context_from_channel_id = require("./get_context_from_channel_id")
local add_message_to_context = require("./add_message_to_context")

local function prompt(message: string, channel_id)
    local response = net.request({
        url = "https://api.deepseek.com/chat/completions",
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json",
        },
        Authorization = `Bearer {env.DEEPSEEK_API_KEY}`,
        {
            model = "deepseek-v4-flash",
            messages = get_context_from_channel_id(channel_id),
            thinking = { type = "disabled" },
            reasoning_effort = "low",
            stream = true
        }
    })

    if response.statusCode == 200 then
        add_message_to_context("user", message, channel_id)
    else
        return response.statusCode
    end

    return response.body
end

return prompt
