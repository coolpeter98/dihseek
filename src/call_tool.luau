local get_tools = require("./get_tools")

local function call_tool(tool: string, args: {})
    local tool_table = get_tools(false, tool)
    local tool_function = tool_table[1]["run"]

    local result = tool_function(args)
    return result
end

return call_tool
