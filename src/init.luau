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

bot.onMessage:listen(function(message: classes.Message)
	local success, err = pcall(function()
		prompt(message, message.channelId)
	end)
	if not success then print(err) end
end)

bot.onAllShardsReady:listenOnce(function()
	print(`Bot '{bot.user.username}' is online!`)
end)

bot:connectAsync():await()
