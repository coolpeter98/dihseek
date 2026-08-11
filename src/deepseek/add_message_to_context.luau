--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local contexts = "src/deepseek/contexts/"

if not fs.isDir(contexts) then
	fs.writeDir(contexts)
end

type role = "system" | "user" | "assistant"

type message = {
	role: role,
	content: string,
}

local function add_message_to_context(role: role, message: string, channel_id)
	local context_file_location = `{contexts}/{channel_id}.json`
	local messages: { message } = {}
	if fs.isFile(context_file_location) then
		messages = serde.decode("json", fs.readFile(context_file_location))
	end
	local formatted_message = {
		role = role,
		content = message,
	}

	local new_file_contents
	table.insert(messages, formatted_message)
	fs.writeFile(context_file_location, serde.encode("json", messages))

	return context_file_location
end

return add_message_to_context
