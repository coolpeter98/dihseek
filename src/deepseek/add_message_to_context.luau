--!strict

local fs = require("@lune/fs")
local serde = require("@lune/serde")

local DEFAULT_SYSTEM_PROMPT = require("../constants/DEFAULT_SYSTEM_PROMPT")

local contexts = "src/deepseek/contexts/"

if not fs.isDir(contexts) then
	fs.writeDir(contexts)
end

type role = "system" | "user" | "assistant" | "tool"

type message = {
	-- role "system" | "user" | "assistant" | "tool"
	role: role,
	content: string,

	--role "tool"
	tool_call_id: string?,

	-- role "assistant"
	tool_calls: {}?,
}

type tool_data = {
	used_tool: boolean,
	name: string,
	results: string,
	id: string,
	args: {},
}

-- channel_id is actually a number, but the goofy library passes it as a string...
local function add_message_to_context(role: role, message: string, channel_id: string, tool_data: tool_data?) : string
	local context_file_location = `{contexts}/{channel_id}.json`
	local messages: { message } = {}
	if fs.isFile(context_file_location) then
		messages = serde.decode("json", fs.readFile(context_file_location))
	else
		messages = {{role = "system", content = DEFAULT_SYSTEM_PROMPT}}
	end

	local formatted_message = {
		role = role,
		content = message,
	}

	--luau lsp false positive type error

	if role == "tool" then
		if not tool_data then
			return "No tool data provided despite the role being 'tool'"
		else
			formatted_message.tool_call_id = tool_data.id
		end
	end

	if role == "assistant" then
		if tool_data and tool_data.used_tool then
			formatted_message.tool_calls = {{
				id = tool_data.id,
				["type"] = "function",
				["function"] = {
					name = tool_data.name,
					arguments = serde.encode("json", tool_data.args),
				}
			}}
		end
	end

	table.insert(messages, formatted_message)
	fs.writeFile(context_file_location, serde.encode("json", messages))

	return context_file_location
end

return add_message_to_context
