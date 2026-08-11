--!strict

local discord = require("@self/../luau_packages/discord")
local builders = require("@self/../luau_packages/builders")
local chat = require("@self/chat")

local env = require("@self/../.env")

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

chat.setup(bot)

bot.onAllShardsReady:listenOnce(function()
	print(`Bot '{bot.user.username}' is online!`)
	local result = bot.application:createSlashCommandAsync(chat.chatCommand):await()

	if result:isErr() then
		warn("Failed to register command:", result:unwrapErr())
		return
	end

	print("Registered command:", result:unwrapOk().name)
end)

bot:connectAsync():await()
