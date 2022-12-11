-- Short library that will take any seralisable lua value and convert it into a json string.
--
-- Tables are converted to arrays if their length is greater than 0, or an object if not.
-- Tables may also specify a `__tojson` metamethod, which will override the default behaviour
-- for that table.

local function json_object(tbl, indent)
    indent = indent + 1
    local fields = {}
    local field_count = 0
    local expand = false

    for k, v in pairs(tbl) do
        table.insert(fields, ('"%s": %s'):format(k, tojson(v, indent)))
        if type(v) == "table" then
            expand = true
        end
        field_count = field_count + 1
    end

    table.sort(fields)

    if field_count == 0 then
        return "{}"

    elseif expand or field_count > 4 then
        local dent = ("\t"):rep(indent)
        local sep = ",\n" .. dent
        return "{\n" .. dent .. table.concat(fields, sep) .. "\n" .. ("\t"):rep(indent - 1) .. "}"

    else
        return "{ " .. table.concat(fields, ", ") .. " }"

    end
end

local function json_array(tbl, indent)
    indent = indent + 1
    local fields = {}
    local expand = #tbl > 4

    for _, v in ipairs(tbl) do
        table.insert(fields, tojson(v, indent))
        if type(v) == "table" then
            expand = true
        end
    end

    if expand then
        local dent = ("\t"):rep(indent)
        local sep = ",\n" .. dent
        return "[\n" .. dent .. table.concat(fields, sep) .. "\n" .. ("\t"):rep(indent - 1) .. "]"

    else
        return "[" .. table.concat(fields, ", ") .. "]"

    end
end

---@diagnostic disable-next-line: lowercase-global
function tojson(value, indent)
    indent = indent or 0

    if type(value) == "nil" then
        return "null"

    elseif type(value) == "boolean" or type(value) == "number" then
        return tostring(value)

    elseif type(value) == "string" then
        return string.format('%q', value)

    elseif type(value) == "table" then
        local json
        if getmetatable(value) and getmetatable(value).__tojson then
            json = getmetatable(value).__tojson(value, indent)
        elseif #value == 0 then
            json = json_object(value, indent)
        else
            json = json_array(value, indent)
        end
        if indent == 0 then
            return json .. "\n"
        else
            return json
        end
    end

    error(string.format("Cannot JSONify %s data", type(value)))
end

return tojson
