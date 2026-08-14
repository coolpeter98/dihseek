local luau = require("@lune/luau")

local prints: {{any}} = {}

local run_luau = {}

run_luau.info = {
    name = "run_luau",
    alias = "Run Luau",
    description = [[
        Runs Luau in the Lune environment.
        You can not see any print statements or errors, only the return value of the function you wrote.
    ]],
}

run_luau.parameters = {
    type = "object",
    properties = {
        code = { type = "string" },
    },
    required = { "code" },
}

function run_luau.run(args: {code: string})

    -- Thank you DarkenedRing for helping me with this.
    local fn = luau.load(args.code, {
        environment = {
            print = function(...: any): ()
            table.insert(prints, {...})
            end
        }
    })

    print(fn)
end

return run_luau
