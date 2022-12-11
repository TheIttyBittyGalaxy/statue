-- Reference wraps another class and allows it to be accessed just as before. It exists soley
-- for the purpose of serialisation.
--
-- During json serialisation, it causes the referenced value to be serialized as a string
-- not as a json value. This is useful when serialising the Abstract Program Model as JSON, as it
-- allows us to prevent a Node recursively serialising itself.

local _Reference = {}

---@alias Reference table

---@param value any
---@return Reference
local function Reference(value)
    return setmetatable({ referenced_value = value }, _Reference)
end

function _Reference:__index(key)
    return self.referenced_value[key]
end

function _Reference:__newindex(key, value)
    self.referenced_value[key] = value
end

function _Reference:__call(...)
    return self.referenced_value(...)
end

function _Reference:__tostring()
    return "<" .. tostring(self.referenced_value) .. ">"
end

function _Reference:__tojson()
    return tojson(tostring(self))
end

return Reference
