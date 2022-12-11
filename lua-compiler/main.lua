local tojson = require "lib.json"
local FileTokeniser = require "class.FileTokeniser"

local file_path = arg[1] or "../tests/hello-world.statue"
local tokeniser = FileTokeniser(file_path)

tokeniser:skip_whitespace()

local tokens = {}
repeat
    local token = tokeniser:eat()
    table.insert(tokens, token)
until token.kind == "END_OF_FILE"

print(tojson(tokens))
