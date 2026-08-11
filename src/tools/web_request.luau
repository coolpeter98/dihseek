--!strict

local net = require("@lune/net")

local web_request = {}

type request_methods = "GET" | "HEAD" | "POST" | "PUT" | "DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH"

web_request.info = {
    name = "web_request",
    alias = "Web Request",
    description = [[
        Sends a web request to the specified server.
    ]],
}

web_request.parameters = {
    type = "object",
    properties = {
        method = { type = "string", enum = { "GET", "POST", "PUT", "DELETE", "PATCH" } },
        url = { type = "string" },
        headers = { type = "object", properties = {} },
        body = { type = "string" },
    },
    required = { "method", "url" },
}

function web_request.run(args: {method: request_methods, url: string, headers: string?, body: string?}) : string

    -- the type checker errors here, but this code is completely valid
    -- it's taken verbatim from the Lune docs.

	local response = net.request({
        method = args.method,
		url = args.url,
		headers = args.headers,
		body = args.body,
	})
	if response.statusCode == 200 then
		return response.body
	else
		return `Errored with {response.statusCode}`
	end
end

return web_request
