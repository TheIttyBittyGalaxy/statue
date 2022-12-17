local tojson = require "lib.json"
local FileTokeniser = require "class.FileTokeniser"
local Parser = require "class.Parser"
local Checker = require "class.Checker"

local function save(json, name)
    local file = io.open(("local/%s.json"):format(name), "w")
    if file then
        file:write(tojson(json))
        file:close()
    end
end

local file_path = arg[1] or "../tests/hello-world.statue"

-- Parser
local tokeniser = FileTokeniser(file_path)
local parser = Parser(tokeniser)
tokeniser:skip_whitespace()
parser:parseProgram()
save(parser.program_model, "parser")

-- Checker
local checker = Checker(parser.program_model)
checker:checkProgram()
save(checker.program_model, "checker")
