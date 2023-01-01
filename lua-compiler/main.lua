local compile = require "compile"

local source_file_path = arg[1] or "../tests/samples/hello-world.statue"
compile(source_file_path, true, true)
