local classes = require("../luau_packages/classes")
local builders = require("../luau_packages/builders")

local prompt = require("./deepseek/prompt")
local call_tool = require("./call_tool")

local chatCommand = builders.interaction.interaction
	.new()
	:setName("chat")
	:setDescription("Chat with DeepSeek")
	:setType("ChatInput")
	:addIntegrationType("GuildInstall")
	:addIntegrationType("UserInstall")
	:addContext("Guild")
	:addContext("BotDM")
	:addContext("PrivateChannel")
	:addOption(
		builders.interaction.option
			.new()
			:setType("String")
			:setName("input")
			:setDescription("Your message to DeepSeek")
			:setRequired(true)
			:build()
	)
	:build()

function listener(bot)
	bot.onCommandInteraction:listen(function(interaction: classes.TypesCommand)
		if interaction.data.name ~= "chat" then
			return
		end

		local input = interaction:getOption("input").value
		interaction:deferAsync():await()
		local response = prompt(input, interaction.channelId)

		-- catch any error ourselves because the default error handler is broken...
		local success, err = pcall(function()
			if response["used_tool"] then
				tool_results = call_tool(response["tool_name"], response["tool_arguments"] or {})
				interaction:messageAsync(builders.message.message.new():setContent(`{response["reply"]} \nTool call(s): {response["tool_name"]}\nTool results: {tool_results}`):build()):await()
				return
			end
			interaction:messageAsync(builders.message.message.new():setContent(`{response["reply"]}`):build()):await()
		end)
		print(success, err)
	end)
end

return { chatCommand = chatCommand, setup = listener }
