local tojson = require "lib.json"
local FileTokeniser = require "class.FileTokeniser"
local Parser = require "class.Parser"
local Checker = require "class.Checker"
local Generator = require "class.Generator"

local function save(json, name)
    local file = io.open(("local/%s.json"):format(name), "w")
    if file then
        file:write(tojson(json))
        file:close()
    end
end

local source_file_path = arg[1] or "../tests/hello-world.statue"
local output_file_path = "local/generator.cpp"

-- Parser
local tokeniser = FileTokeniser(source_file_path)
local parser = Parser(tokeniser)
tokeniser:skip_whitespace()
parser:parse_program()
save(parser.program_model, "parser")

-- Checker
local checker = Checker(parser.program_model)
checker:check_program()
save(checker.program_model, "checker")

-- Generator
local generator = Generator(parser.program_model, output_file_path)
generator:generate_program()

-- Build
local build_success = os.execute(('g++ "%s" -o local/built'):format(output_file_path))
if build_success then
    os.execute("cd local && built")
else
    error("Build error: C++ code could not build correctly")
end
