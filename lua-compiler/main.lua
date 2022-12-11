local FileTokeniser = require "class.FileTokeniser"

local file_path = arg[1] or "../tests/hello-world.statue"
local tokeniser = FileTokeniser(file_path)

tokeniser:skip_whitespace()
repeat
    local token = tokeniser:eat()
    print(token)
until token.kind == "END_OF_FILE"
