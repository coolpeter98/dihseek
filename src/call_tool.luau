local get_tools = require("./get_tools")

local function call_tool(tool: string, args: {})
    local tool_table = get_tools(false, tool)
    local tool_function = tool_table[1]["run"]

    local success, err = pcall(function()
        result = tool_function(args)
    end)

    if err then
        return `Tool call returned an error: {err}`
    else
        return result
    end
end

return call_tool
