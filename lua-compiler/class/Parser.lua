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
---@field createScope fun(self: Parser, parent?: Node) : Node
---
---@field parseProgram fun(self: Parser)
---@field parseFunction fun(self: Parser, scope: Node) : Node
---@field peekStatement fun(self: Parser) : boolean
---@field parseStatement fun(self: Parser, scope: Node) : Node
---@field peekExpression fun(self: Parser) : boolean
---@field parseExpression fun(self: Parser) : Node

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

-- APM UTILITY METHODS

---@param self Parser
---@param parent? Node
---@return Node
function _Parser:createScope(parent)
    local scope = Node("SCOPE")
    if parent then
        scope.parent = Reference(parent)
    end
    scope.statements = {}
    scope.functions = {}
    return scope
end

-- PARSE AND PEEK METHODS

---@param self Parser
function _Parser:parseProgram()
    local program = Node("PROGRAM")
    self.program_model = program
    program.scope = self:createScope()
    table.insert(program.scope.functions, self:parseFunction(program.scope))
end

---@param self Parser
---@param scope Node
---@return Node
function _Parser:parseFunction(scope)
    local funct = Node("FUNCTION")
    funct.scope = self:createScope(scope)

    self:eat("KEY_FUNCT")
    funct.identity = self:eat("IDENTITY")

    self:eat("BRACKET_L")
    -- TODO: Parse arguments
    self:eat("BRACKET_R")

    while self:peekStatement() do
        table.insert(funct.scope.statements, self:parseStatement(funct.scope))
    end

    self:eat("KEY_END")

    return funct
end

---@param self Parser
---@return boolean
function _Parser:peekStatement()
    return self:peekExpression()
end

---@param self Parser
---@param scope Node
---@return Node
function _Parser:parseStatement(scope)
    if self:peekExpression() then return self:parseExpression() end

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
function _Parser:peekExpression()
    return self:peek("IDENTITY") or self:peek("STRING_LITERAL")
end

---@param self Parser
---@return Node
function _Parser:parseExpression()
    if self:peek("IDENTITY") then
        local call = Node("CALL")
        call.identity = self:eat("IDENTITY")
        call.arguments = {}

        self:eat("BRACKET_L")
        if self:peekExpression() then
            local end_of_arguments = false
            repeat
                table.insert(call.arguments, self:parseExpression())
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
