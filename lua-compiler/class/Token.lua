-- Tokens are generated during the Parsing step by the FileTokeniser.
-- Every token has:
--     a `kind`  - indicates the semantic meaning of the token.
--     a `value` - the text from the source file that represents the token.
--     information about where the token came from (file path, line, column)

---@class Token
---@field kind string
---@field value string?
---@field file string
---@field pos integer
---@field line integer
---@field column integer

local _Token = {}
_Token.__index = _Token

---@param kind string
---@param value? string
---@param file_path string
---@param pos integer
---@param line integer
---@param column integer
---@return Token
local function Token(kind, value, file_path, pos, line, column)
    return setmetatable({
        kind = kind,
        value = value,
        file_path = file_path,
        pos = pos,
        line = line,
        column = column
    }, _Token)
end

---@param self Token
---@return string
function _Token:__tostring()
    if self.value then
        return ("[%s %s %s:%s]"):format(self.kind, self.value, self.line, self.column)
    end
    return ("[%s %s:%s]"):format(self.kind, self.line, self.column)
end

---@param self Token
---@return string
function _Token:__tojson()
    return tojson(tostring(self))
end

return Token
