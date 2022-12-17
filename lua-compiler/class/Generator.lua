-- The Generator walks the Abstract Program Model (APM) and generates C++ code.
--
-- It walks the model via recursive decent. At this point the program should be fully
-- verified, and so the sole goal of the Generator is to produce efficient and syntaxically
-- valid C++ code.

local Node = require "class.Node"

---@class Generator
---@field program_model Node
---@field file_path string
---@field file any
---@field indent integer
---@field new_line boolean
---
---@field internal_verify fun(self: Generator, node: Node, kind: string)
---
---@field write fun(self: Generator, ...: string|number)
---@field print fun(self: Generator, ...: string|number)
---@field open_block fun(self: Generator)
---@field close_block fun(self: Generator)
---
---@field generate_program fun(self: Generator)
---@field generate_declarative_scope fun(self: Generator, scope: Node)
---@field generate_imperitive_scope fun(self: Generator, scope: Node)
---@field generate_declaration fun(self: Generator, declaration: Node)
---@field generate_function_declaration fun(self: Generator, funct: Node)
---@field generate_function_definition fun(self: Generator, funct: Node)
---@field generate_statement fun(self: Generator, stmt: Node)
---@field generate_expression fun(self: Generator, expr: Node)
---@field generate_call fun(self: Generator, expr: Node)
---@field generate_literal fun(self: Generator, expr: Node)

local _Generator = {}
_Generator.__index = _Generator

---@param program_model Node
---@return Generator
local function Generator(program_model, file_path)
    return setmetatable({
        program_model = program_model,
        file_path = file_path,
    }, _Generator)
end

-- VERIFY NODE KIND

---@param self Generator
---@param node Node
---@param kind string
function _Generator:internal_verify(node, kind)
    if node.kind ~= kind then
        error(("Internal error: %s node was expected, got %s"):format(kind, node.kind), 2)
    end
end

-- WRITE UTILITY

function _Generator:write(...)
    if self.new_line then
        self.file:write("\n")
        if self.indent > 0 then
            self.file:write(("\t"):rep(self.indent))
        end
        self.new_line = false
    end
    for _, v in ipairs({ ... }) do
        self.file:write(tostring(v))
    end
end

function _Generator:print(...)
    self:write(...)
    self.new_line = true
end

function _Generator:open_block()
    self.indent = self.indent + 1
    if self.indent > 0 then
        self:print("{")
    end
end

function _Generator:close_block()
    self.indent = self.indent - 1
    if self.indent > -1 then
        self:print("}")
    end
end

-- GENERATE METHODS

---@param self Generator
function _Generator:generate_program()
    self:internal_verify(self.program_model, "PROGRAM")

    self.file = io.open(self.file_path, "w")
    if not self.file then
        error(("Generation error: Could not open file '%s'"):format(self.file_path))
    end

    self.indent = -1
    self.new_line = false

    self:write([[
#include <string>
#include <iostream>

void print(std::string str) {
    std::cout << str << std::endl;
}

]]   )
    self:generate_declarative_scope(self.program_model.scope)

    self.file:close()
end

---@param self Generator
---@param scope Node
function _Generator:generate_declarative_scope(scope)
    self:internal_verify(scope, "SCOPE")

    self:open_block()

    local function_declarations_present = false
    for _, stmt in ipairs(scope.statements) do
        if stmt.kind == "DECLARATION" and stmt.subject.kind == "FUNCTION" then
            self:generate_function_declaration(stmt.subject)
            self:print(";")
            function_declarations_present = true
        end
    end

    if function_declarations_present then
        self:print()
    end

    for _, stmt in ipairs(scope.statements) do
        self:generate_statement(stmt)
    end

    self:close_block()
end

---@param self Generator
---@param scope Node
function _Generator:generate_imperitive_scope(scope)
    self:internal_verify(scope, "SCOPE")

    self:open_block()
    for _, stmt in ipairs(scope.statements) do
        self:generate_statement(stmt)
    end
    self:close_block()
end

---@param self Generator
---@param funct Node
function _Generator:generate_function_declaration(funct)
    self:internal_verify(funct, "FUNCTION")

    -- TODO: Generate function returns

    -- FIXME: This is a hack. Find a better way of addressing the main function special case
    -- (e.g. having the C++ main function call to the main function defined in the Statue code)
    if funct.identity.value == "main" then
        self:write("int ")
    else
        self:write("void ")
    end

    -- TODO: Generate function parameters
    self:write(funct.identity.value, "()")
end

---@param self Generator
---@param funct Node
function _Generator:generate_function_definition(funct)
    self:internal_verify(funct, "FUNCTION")

    self:generate_function_declaration(funct)
    self:write(" ")
    self:generate_imperitive_scope(funct.scope)
end

---@param self Generator
---@param stmt Node
function _Generator:generate_statement(stmt)
    -- FIXME: Verify node kind node before continuing

    if stmt.kind == "DECLARATION" then return self:generate_function_definition(stmt.subject) end
    -- FIXME: Generate non-function declarations

    -- FIXME: Check if the statement is an expression node before attempting to generate it as an expression
    self:generate_expression(stmt)
    self:print(";")
end

---@param self Generator
---@param expr Node
function _Generator:generate_expression(expr)
    -- FIXME: Verify node kind node before continuing

    if expr.kind == "CALL" then return self:generate_call(expr) end
    if expr.kind == "LITERAL" then return self:generate_literal(expr) end
    error(("Internal error: Cannot generate %s expression (or statement)"):format(expr.kind))
end

---@param self Generator
---@param call Node
function _Generator:generate_call(call)
    self:internal_verify(call, "CALL")

    --FIXME: Generate correct identity
    self:write(call.funct.identity.value)

    self:write("(")
    for i, arg in ipairs(call.arguments) do
        if i > 1 then
            self:write(", ")
        end
        self:generate_expression(arg)
    end
    self:write(")")
end

---@param self Generator
---@param literal Node
function _Generator:generate_literal(literal)
    self:internal_verify(literal, "LITERAL")
    self:write(tostring(literal.value))
end

return Generator
