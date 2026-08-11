local get_tools = require("./get_tools")
local call_tool = require("./call_tool")

print(get_tools(false, "get_time")[1]["run"])
print(call_tool("get_time", {}))
