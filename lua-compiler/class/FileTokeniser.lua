-- The file tokeniser takes a source file, reads it's content, and then converts that content into Tokens.
-- The important methods are:
--     `eat()` will generate the next token and then advance past it
--     `peek(kind)` will return true if the next token is the kind specificed

local Statue = require "Statue"
local Token = require "class.Token"

---@class FileTokeniser
---@field file_path string
---@field content string
---@field position integer
---@field line integer
---@field column integer
---
---@field match fun(self: FileTokeniser, pattern: string) : string?
---@field peek fun(self: FileTokeniser, kind: string) : boolean
---@field skip_whitespace fun()
---@field eat fun() : Token
---@field eat_string_literal fun() : Token
---@field eat_number_literal fun() : Token

local _FileTokeniser = {}
_FileTokeniser.__index = _FileTokeniser

---@param file_path string
---@return FileTokeniser
local function FileTokeniser(file_path)
    local file = io.open(file_path, "r")
    if not file then
        error("Internal error: Cannot read file '" .. file_path .. "'")
    end
    local content = file:read("a")
    file:close()

    return setmetatable({
        file_path = file_path,
        content = content,
        position = 1,
        line = 1,
        column = 1
    }, _FileTokeniser)
end

---@param self FileTokeniser
---@param pattern string
---@return string?
function _FileTokeniser:match(pattern)
    return self.content:match("^" .. pattern, self.position)
end

---@param self FileTokeniser
---@param kind string
---@return boolean
function _FileTokeniser:peek(kind)
    if kind == "END_OF_FILE" then
        return self.position > self.content:len()
    end

    if kind == "STRING_LITERAL" then
        return self:match('"') ~= nil
    end

    if kind == "NUMBER_LITERAL" then
        return self:match('%d') ~= nil
    end

    for _, info in pairs(Statue.token_pattern) do
        local pattern_kind, pattern = info[1], info[2]
        if self:match(pattern) then
            return pattern_kind == kind
        elseif pattern_kind == kind then
            return false
        end
    end

    error(("Internal error: Attempt to peek for unknown token kind '%s'"):format(kind))
end

---@param self FileTokeniser
function _FileTokeniser:skip_whitespace()
    local match
    while self:match("%s") or self:match("//") do
        match = self:match("[ \t]*")
        if match then -- Skip spaces and tabs
            local len = match:len()
            self.position = self.position + len
            self.column = self.column + len
        end

        match = self:match("//[^\n]*") -- Skip comments
        if match then
            local len = match:len()
            self.position = self.position + len
            self.column = self.column + len
        end

        match = self:match("\n+") -- Skip newlines
        if match then
            local len = match:len()
            self.position = self.position + len
            self.line = self.line + len
            self.column = 1
        end
    end
end

---@param self FileTokeniser
---@return Token
function _FileTokeniser:eat()
    if self.position > self.content:len() then
        return Token("END_OF_FILE", nil, self.file_path, self.position, self.line, self.column)
    end

    if self:match('"') then
        return self:eat_string_literal()
    end

    if self:match("%d") then
        return self:eat_number_literal()
    end

    for _, info in pairs(Statue.token_pattern) do
        local kind, pattern = info[1], info[2]
        local match = self:match(pattern)
        if match then
            local token = Token(kind, match, self.file_path, self.position, self.line, self.column)

            local len = match:len()
            self.position = self.position + len
            self.column = self.column + len
            self:skip_whitespace()

            return token
        end
    end

    local match = self:match(".")
    error(("Syntax error: Unrecognised syntax '%s' in %s on line %s:%s"):format(
        match,
        self.file_path,
        self.line,
        self.column
    ))
end

---@param self FileTokeniser
---@return Token
function _FileTokeniser:eat_string_literal()
    local match = self:match('"')

    if not match then
        error(("Syntax error: Expected number literal in %s on line %s:%s"):format(
            self.file_path,
            self.line,
            self.column
        ))
    end

    local p = self.position + 1

    repeat
        local c = self.content:sub(p, p)
        local is_escaped = c == '\\'
        match = match .. c
        p = p + 1
    until c == '"' and not is_escaped

    local token = Token("STRING_LITERAL", match, self.file_path, self.position, self.line, self.column)

    local len = match:len()
    self.position = self.position + len
    self.column = self.column + len
    self:skip_whitespace()

    return token
end

---@param self FileTokeniser
---@return Token
function _FileTokeniser:eat_number_literal()
    local match = self:match("%d+")

    if not match then
        error(("Syntax error: Expected number literal in %s on line %s:%s"):format(
            self.file_path,
            self.line,
            self.column
        ))
    end

    local token = Token("NUMBER_LITERAL", match, self.file_path, self.position, self.line, self.column)

    local len = match:len()
    self.position = self.position + len
    self.column = self.column + len

    local decimcal_match = self:match("%.%d+")
    if decimcal_match then
        token.value = token.value .. decimcal_match
        local len = decimcal_match:len()
        self.position = self.position + len
        self.column = self.column + len
    end

    self:skip_whitespace()

    return token
end

return FileTokeniser
