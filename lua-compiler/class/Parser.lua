-- The Parser takes tokens provided from FileTokeniser and generates an Abstract Program Model (APM).
--
-- It is a handcrafted recursive decent parser. Each of the `parse` methods is able to construct
-- a specific kind of node in the APM (e.g. a function), which it does by eating nodes and generating
-- APM nodes accordingly. `parse` methods call other `parse` methods recursively, allowing for a complex
-- APM to be constructed.

local Node = require "class.Node"
local Reference = require "class.Reference"

---@class Parser
---@field tokeniser FileTokeniser
---@field program_model Node
---
---@field eat fun(self: Parser, kind?: string) : Token
---@field peek fun(self: Parser, kind: string) : boolean
---
---@field create_scope fun(self: Parser, parent?: Node) : Node
---@field add_statement_to_scope fun(self: Parser, scope: Node, stmt: Node)
---
---@field parse_program fun(self: Parser)
---@field peek_function_declaration fun(self: Parser) : boolean
---@field parse_function_declaration fun(self: Parser, scope: Node) : Node
---@field peek_statement fun(self: Parser) : boolean
---@field parse_statement fun(self: Parser, scope: Node) : Node
---@field peek_expression fun(self: Parser) : boolean
---@field parse_expression fun(self: Parser) : Node

local _Parser = {}
_Parser.__index = _Parser

---@param tokeniser FileTokeniser
---@return Parser
local function Parser(tokeniser)
    return setmetatable({
        tokeniser = tokeniser,
        program_model = nil
    }, _Parser)
end

-- CORE METHODS

---@param self Parser
---@param kind? string
---@return Token
function _Parser:eat(kind)
    local token = self.tokeniser:eat()
    if kind and token.kind ~= kind then
        error(("Parsing error: Expected %s but got %s in %s at %s:%s"):format(
            kind,
            token.kind,
            token.file,
            token.line,
            token.column
        ), 2)
    end
    return token
end

---@param self Parser
---@param kind string
---@return boolean
function _Parser:peek(kind)
    return self.tokeniser:peek(kind)
end

-- SCOPE UTILITY METHODS

---@param self Parser
---@param parent? Node
---@return Node
function _Parser:create_scope(parent)
    local scope = Node("SCOPE")
    if parent then
        scope.parent = Reference(parent)
    end
    scope.statements = {}
    scope.lookup_table = {}
    return scope
end

---@param self Parser
---@param scope Node
---@param stmt Node
function _Parser:add_statement_to_scope(scope, stmt)
    table.insert(scope.statements, stmt)
end

-- PARSE AND PEEK METHODS

---@param self Parser
function _Parser:parse_program()
    local program = Node("PROGRAM")
    self.program_model = program
    program.scope = self:create_scope()

    program.scope.lookup_table.print = Node("FUNCTION")

    local stmt = self:parse_statement(program.scope)
    self:add_statement_to_scope(program.scope, stmt)
end

---@param self Parser
---@return boolean
function _Parser:peek_function_declaration()
    return self:peek("KEY_FUNCT")
end

---@param self Parser
---@param scope Node
---@return Node
function _Parser:parse_function_declaration(scope)
    local funct = Node("FUNCTION")
    funct.scope = self:create_scope(scope)

    self:eat("KEY_FUNCT")
    funct.identity = self:eat("IDENTITY")

    self:eat("BRACKET_L")
    -- TODO: Parse arguments
    self:eat("BRACKET_R")

    while self:peek_statement() do
        local stmt = self:parse_statement(funct.scope)
        self:add_statement_to_scope(funct.scope, stmt)
    end

    self:eat("KEY_END")

    local declaration = Node("DECLARATION")
    declaration.subject = funct
    return declaration
end

---@param self Parser
---@return boolean
function _Parser:peek_statement()
    return self:peek_expression()
        or self:peek_function_declaration()
end

---@param self Parser
---@param scope Node
---@return Node
function _Parser:parse_statement(scope)
    if self:peek_function_declaration() then return self:parse_function_declaration(scope) end
    if self:peek_expression() then return self:parse_expression() end

    local token = self:eat()
    error(("Parsing error: Expected statement in %s at %s:%s (got %s)"):format(
        token.file,
        token.line,
        token.column,
        token.kind
    ))
end

---@param self Parser
---@return boolean
function _Parser:peek_expression()
    return self:peek("IDENTITY") or self:peek("STRING_LITERAL")
end

---@param self Parser
---@return Node
function _Parser:parse_expression()
    if self:peek("IDENTITY") then
        local call = Node("CALL")
        call.identity = self:eat("IDENTITY")
        call.arguments = {}

        self:eat("BRACKET_L")
        if self:peek_expression() then
            local end_of_arguments = false
            repeat
                table.insert(call.arguments, self:parse_expression())
                if self:peek("COMMA") then
                    self:eat("COMMA")
                else
                    end_of_arguments = true
                end
            until end_of_arguments
        end
        self:eat("BRACKET_R")

        return call

    elseif self:peek("STRING_LITERAL") then
        local literal = Node("LITERAL")
        literal.value = self:eat("STRING_LITERAL").value
        return literal

    end

    local token = self:eat()
    error(("Parsing error: Expected expression in %s at %s:%s (got %s)"):format(
        token.file,
        token.line,
        token.column,
        token.kind
    ))
end

return Parser
