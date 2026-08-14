--!strict

local fs = require("@lune/fs")
local tools = "src/tools"

local function get_tools(format_for_api: boolean, single_tool: string?) : {}
    local all_tools = {}

    for i, file in fs.readDir(tools) do

        -- strip luau file extension
        local stripped_file = string.split(file, ".")[1]

        local tool = require(`./tools/{stripped_file}`)

        if tool.info.name ~= single_tool and single_tool ~= nil then
            continue
        end

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
