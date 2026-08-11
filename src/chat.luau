local classes = require("../luau_packages/classes")
local builders = require("../luau_packages/builders")

local prompt = require("./deepseek/prompt")

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

		print(response[1], response[2])
		interaction:messageAsync(builders.message.message.new():setContent(`{response[1]} 
Tool call(s): {response[2].name}`):build()):await()
	end)
end

return { chatCommand = chatCommand, setup = listener }
