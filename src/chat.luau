--!strict

local classes = require("../luau_packages/classes")
local builders = require("../luau_packages/builders")
local datetime = require("@lune/datetime")
local task = require("@lune/task")
local datetime = require("@lune/datetime")

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
		-- spawn it in a new thread to make it asynchronous (so multiple Bluds can prompt at once)
		task.spawn(function()
			if interaction.data.name ~= "chat" then
				return
			end

			-- discord does ts differently depending on
			-- if the user is running a command in a
			-- server or a DM. Goofy.

			local userid
			local username
			local displayname

			if interaction.member then
				userid = interaction.member.id
				username = interaction.member.username
				displayname = interaction.member.globalName
			else
				userid = interaction.user.id
				username = interaction.user.username
				displayname = interaction.user.globalName
			end

			local input = interaction:getOption("input").value

			interaction:deferAsync():await()

			-- catch any error ourselves because the default error handler is broken...
			local success, err = pcall(function()

			local discord_message = builders.message.message.new()
				local response = prompt(`[USER ID: {userid}] {displayname} (@{username}) at {datetime.now():formatUniversalTime("%Y-%m-%d %H:%M:%S UTC")}: {input}`, interaction.channelId)

				local formatted_input = '```\n'..input..'\n```'

				local discord_message_text = ""

				while response["used_tool"] do
					discord_message_text = discord_message_text .. `-# Used tool: {response.tool_name}\n`

					interaction:messageAsync(discord_message:setContent(string.sub(discord_message_text, 1, 1999), "…"):build()):await()

					response = prompt(nil, interaction.channelId)

					discord_message_text = discord_message_text .. `{response["reply"]}\n`

					interaction:messageAsync(discord_message:setContent(string.sub(discord_message_text, 1, 1999), "…"):build()):await()
				end

				if discord_message_text == "" then
					discord_message_text = formatted_input .. `{response["reply"]}`
				end

				interaction:messageAsync(discord_message:setContent(string.sub(discord_message_text, 1, 1999), "…"):build()):await()
			end)
			if not success then
				print(success, err)
			end
		end)
	end)
end

return { chatCommand = chatCommand, setup = listener }
