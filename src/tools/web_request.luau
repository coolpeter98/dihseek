--!strict

local net = require("@lune/net")

local web_request = {}

type request_methods = "GET" | "HEAD" | "POST" | "PUT" | "DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH"

web_request.info = {
    alias = "Web Request",
    description = [[
        Returns the current time in EEST.
        Arguments (asterisk * means required):
            - *Method: "GET" | "HEAD" | "POST" | "PUT" | "DELETE" | "CONNECT" | "OPTIONS" | "TRACE" | "PATCH"
            - *URL: string
            - Headers: string
            - Body: string
    ]],
}

function web_request.run(method: request_methods, url: string, headers: string?, body: string?)

    -- the type checker errors here, but this code is completely valid
    -- it's taken verbatim from the Lune docs.
	local response = net.request({
        method = method,
		url = url,
		headers = headers,
		body = body,
	})
	if response.statusCode == 200 then
		return response.body
	else
		return response.statusCode
	end
end

return web_request
