-- Nodes are generated during the parsing step by the Parser.
-- They are combined together to create the Abstract Program Model.

---@alias Node table

local _Node = {}
_Node.next_id = 0

---@param kind string
---@return Node
local function Node(kind)
    _Node.next_id = _Node.next_id + 1
    return setmetatable({
        id = _Node.next_id,
        kind = kind,
    }, _Node)
end

---@param self Node
---@return string
function _Node:__tostring()
    return ("%s#%s"):format(self.kind, self.id)
end

---@param self Node
---@param indent integer
---@return string
function _Node:__tojson(indent)
    indent = indent + 1
    local fields = {}

    for k, v in pairs(self) do
        if k ~= "kind" and k ~= "id" then
            table.insert(fields, ('"%s": %s'):format(k, tojson(v, indent)))
        end
    end

    table.sort(fields)
    table.insert(fields, 1, ('"node": "%s"'):format(tostring(self)))

    local dent = ("\t"):rep(indent)
    local sep = ",\n" .. dent
    return "{\n" .. dent .. table.concat(fields, sep) .. "\n" .. ("\t"):rep(indent - 1) .. "}"
end

return Node
