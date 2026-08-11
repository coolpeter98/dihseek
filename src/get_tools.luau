local fs = require("@lune/fs")
local tools = "src/tools"

local function get_tools(format_for_api: boolean) : {}
    local all_tools = {}

    for i, file in fs.readDir(tools) do

        if file == "README.txt" then
            continue
        end

        -- strip luau file extension
        local file = string.split(file, ".")[1]

        local tool = require(`./tools/{file}`)

        if format_for_api then
            local formatted_tool = {
                type = "function",
                ["function"] = {
                    name = tool.info.name,
                    description = tool.info.description,
                    parameters = tool.parameters
                }
            }
            table.insert(all_tools, formatted_tool)
        else
            table.insert(all_tools, tool)
        end
    end

    return all_tools
end

return get_tools
