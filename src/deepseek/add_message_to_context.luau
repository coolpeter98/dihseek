local fs = require("@lune/fs")
local serde = require("@lune/serde")

local contexts = "src/deepseek/contexts/"

type role = "system" | "user" | "assistant"

type message = {
    role: role,
    content: string
}

local function add_message_to_context(role: role, message: string, channel_id)
    local context_file_location = `{contexts}/{channel_id}.json`
    local context_file_contents = fs.readFile(context_file_location) or ""

    local formatted_message = {
        role = role,
        content = message
    }

    local decoded_file_contents = serde.decode("json", context_file_contents)

    local new_file_contents
    local encoded_new_file_contents = serde.encode("json", new_file_contents)

    fs.writeFile(context_file_location, encoded_new_file_contents)

    return context_file_contents
end

return add_message_to_context
