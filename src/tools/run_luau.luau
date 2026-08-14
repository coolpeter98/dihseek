local luau = require("@lune/luau")

local prints: {{any}} = {}

local allowed_requires = {
    "@lune/task",
    "@lune/serde",
    "@lune/net",
    "@lune/crypto",
    "@lune/regex",
}

local run_luau = {}

run_luau.info = {
    name = "run_luau",
    alias = "Run Luau",
    description = [[
        Runs Luau in the Lune environment.
        You can only require paths in this whitelist:
        ]]
        .. table.concat(allowed_requires) ..
        [[
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
    prints = {}

    -- Thank you DarkenedRing for helping me with this.
    local fn = luau.load(args.code, {
        environment = {
            print = function(...: any): ()
                table.insert(prints, {...})
            end,
            require = function(requiree: string): ()
                if table.find(allowed_requires, requiree) then
                    return require(requiree)
                else
                    return `Requiring {requiree} is blacklisted`
                end
            end
        }
    })

    local ran = fn()

    --aka "if there were any print statements"
    local stringified_prints = nil
    if prints[1] then
        local stringified_prints = ""

        for i, print_statements in ipairs(prints) do
            stringified_prints = stringified_prints .. `Print statement {i}:`
            for _, print_statement in prints[i] do
                stringified_prints = stringified_prints .. tostring(print_statement) .. ",\n"
            end
        end
    end

    local formatted_result = `The function returned {ran or "nothing"}\nThe function printed these: {stringified_prints or "nothing"}`
    print(formatted_result)

    return formatted_result
end

return run_luau
