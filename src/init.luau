local discord = require("@self/../luau_packages/discord")
local classes = require("@self/../luau_packages/classes")
local builders = require("@self/../luau_packages/builders")

local env = require("@self/../.env")

local prompt = require("@self/deepseek/prompt")

local DISCORD_BOT_INTENTS = builders.intents
	.new({
		"Guilds",
		"GuildMessages",
		"MessageContent",
	})
	:build()

local bot = discord.bot.new({
	token = env.DISCORD_BOT_TOKEN,
	intents = DISCORD_BOT_INTENTS,
	reconnect = true,
})

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

bot.onAllShardsReady:listenOnce(function()
	print(`Bot '{bot.user.username}' is online!`)
	local result = bot.application:createSlashCommandAsync(chatCommand):await()

	if result:isErr() then
		warn("Failed to register command:", result:unwrapErr())
		return
	end

	print("Registered command:", result:unwrapOk().name)
end)

bot.onCommandInteraction:listen(function(interaction: classes.TypesCommand)
	if interaction.data.name ~= "chat" then
		return
	end

	local input = interaction:getOption("input").value
	interaction:deferAsync():await()
	local response = prompt(input, interaction.channelId)

	interaction:messageAsync(builders.message.message.new():setContent(response):build()):await()
end)

bot:connectAsync():await()
