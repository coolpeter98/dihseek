--!strict

local get_tools = require("./get_tools")

local function call_tool(tool: string, args: {})
    local tool_table = get_tools(false, tool)
    local tool_function = tool_table[1]["run"]

    local result

    local success, err = pcall(function()
        result = tostring(tool_function(args))
    end)

    if not success then
        return `Tool call returned an error: {err}`
    end

    if result == nil then
        return "Tool returned nil"
    end

    return result
end

return call_tool
