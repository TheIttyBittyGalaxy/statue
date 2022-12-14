-- The Checker walks the Abstract Program Model (APM) and verifies if it is semantically correct.
--
-- It walks the model via recursive decent. It is during the checking stage that we declare and
-- resolve identities, and also perform set checking (Statue's equivelent of type checking).

local Node = require "class.Node"
local Reference = require "class.Reference"

---@class Checker
---@field program_model Node
---
---@field internal_verify fun(self: Checker, node: Node, kind: string)
---
---@field declare fun(self: Checker, scope: Node, node: Node)
---@field fetch fun(self: Checker, scope: Node, identity: string) : Reference
---
---@field check_program fun(self: Checker)
---@field check_declarative_scope fun(self: Checker, scope: Node)
---@field check_imperitive_scope fun(self: Checker, scope: Node)
---@field check_declaration fun(self: Checker, declaration: Node)
---@field check_function fun(self: Checker, funct: Node)
---@field check_statement fun(self: Checker, scope: Node, stmt: Node)
---@field check_expression fun(self: Checker, scope: Node, expr: Node)
---@field check_call fun(self: Checker, scope: Node, expr: Node)

local _Checker = {}
_Checker.__index = _Checker

---@param program_model Node
---@return Checker
local function Checker(program_model)
    return setmetatable({
        program_model = program_model,
    }, _Checker)
end

-- VERIFY NODE KIND

---@param self Checker
---@param node Node
---@param kind string
function _Checker:internal_verify(node, kind)
    if node.kind ~= kind then
        error(("Internal error: %s node was expected, got %s"):format(kind, node.kind), 2)
    end
end

-- DECLARE AND FETCH IN SCOPE

---@param self Checker
---@param scope Node
---@param node Node
function _Checker:declare(scope, node)
    self:internal_verify(node, "FUNCTION")
    local identity = node.identity.value
    if scope.lookup_table[identity] then
        error(("Cannot declare %s '%s' in this scope, as '%s' already exists."):format(node.kind, identity, identity))
    end
    scope.lookup_table[identity] = Reference(node)
end

---@param self Checker
---@param scope Node
---@param identity string
---@return Reference
function _Checker:fetch(scope, identity)
    local feteched = scope.lookup_table[identity]
    if feteched then
        return Reference(feteched)
    end

    if scope.parent then
        return self:fetch(scope.parent, identity)
    end

    error(("Program error: '%s' does not exist in this scope"):format(identity))
end

-- CHECK METHODS

---@param self Checker
function _Checker:check_program()
    self:internal_verify(self.program_model, "PROGRAM")

    self:check_declarative_scope(self.program_model.scope)

    local main = self.program_model.scope.lookup_table.main
    if not main or main.kind ~= "FUNCTION" then
        error("Program error: Every Statue program must have a 'main' function. This is where your program will start")
    end
end

---@param self Checker
---@param scope Node
function _Checker:check_declarative_scope(scope)
    self:internal_verify(scope, "SCOPE")

    -- In a declarative scope, we declare everything in the scope in the scope's
    -- look up table _before_ checking the scope's contents. This way, it is possible
    -- to declare nodes in any order and stil have them all be visible to one another.
    for _, stmt in ipairs(scope.statements) do
        if stmt.kind == "DECLARATION" then
            self:declare(scope, stmt.subject)
        end
    end

    for _, stmt in ipairs(scope.statements) do
        self:check_statement(scope, stmt)
    end
end

---@param self Checker
---@param scope Node
function _Checker:check_imperitive_scope(scope)
    self:internal_verify(scope, "SCOPE")

    for _, stmt in ipairs(scope.statements) do
        self:check_statement(scope, stmt)
    end
end

---@param self Checker
---@param declaration Node
function _Checker:check_declaration(declaration)
    self:internal_verify(declaration, "DECLARATION")

    -- FIXME: Correctly check subject when it is not a function
    self:check_function(declaration.subject)
end

---@param self Checker
---@param funct Node
function _Checker:check_function(funct)
    self:internal_verify(funct, "FUNCTION")

    self:check_imperitive_scope(funct.scope)

    -- TODO: Check function parameters and returns
end

---@param self Checker
---@param scope Node
---@param stmt Node
function _Checker:check_statement(scope, stmt)
    -- FIXME: Verify node kind node before continuing

    if stmt.kind == "DECLARATION" then return self:check_declaration(stmt) end

    -- FIXME: Check if the statement is an expression node before attempting to check it as an expression
    self:check_expression(scope, stmt)
end

---@param self Checker
---@param scope Node
---@param expr Node
function _Checker:check_expression(scope, expr)
    -- FIXME: Verify node kind node before continuing

    if expr.kind == "CALL" then return self:check_call(scope, expr) end
    error(("Internal error: Cannot check %s expression (or statement)"):format(expr.kind))
end

---@param self Checker
---@param scope Node
---@param call Node
function _Checker:check_call(scope, call)
    self:internal_verify(call, "CALL")

    call.funct = self:fetch(scope, call.identity.value)

    -- TODO: Verify that arguments are valid.
end

return Checker
