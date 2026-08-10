local fs = require("@lune/fs")

local constants = "../constants"

local DEFAULT_SYSTEM_PROMPT = require(`{constants}/DEFAULT_SYSTEM_PROMPT`)

local add_message_to_context = require("./add_message_to_context")

local function get_context_from_channel_id(channel_id)
    local file = `./contexts/{channel_id}.json`

    if not fs.isFile(file) then
        return fs.readFile(add_message_to_context("system", DEFAULT_SYSTEM_PROMPT, channel_id))
    end
    return file
end

return get_context_from_channel_id
