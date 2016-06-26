

function findFirst(t, elem)
    if t ~= nil then
        for i, v in ipairs(t) do
            if v == elem then return i end
        end
    end
    print('LOG: findFirst didn\'t find anything')
    return -1
end

function contains(t, elem)
    return findFirst(t, elem) ~= -1
end

function removeFirst(t, elem)
    local i = findFirst(t, elem)
    if i ~= -1 then table.remove(t, i) end
end


-- from: https://github.com/stevedonovan/Microlight
-- O(n)
function ifilter(t,pred,...)
    local res,k = setmetatable({},getmetatable(t)), 1
    pred = pred or true
    for i = 1,#t do
        if pred(t[i],...) then
            res[k] = t[i]
            k = k + 1
        end
    end
    return res
end


function clamp(val, lower, upper)
    return math.min(math.max(val, lower), upper)
end

function printf(fmt, ...)
    return print(fmt:format(...))
end

function lerp(a, b, ratio)
	return a + (b-a)*ratio
end

-- from http://lua-users.org/wiki/TableUtils
function table.val_to_str(v, maxLevel)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v,"[^'\"]",""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v,'"', '\\"') .. '"'
    else
        return "table" == type(v) and table.tostring(v, maxLevel-1) or
            tostring(v)
    end
end

function table.key_to_str(k, maxLevel)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. table.val_to_str(k, maxLevel) .. "]"
    end
end

function table.tostring(tbl, maxLevel)
    maxLevel = maxLevel or math.huge
    if maxLevel <= 0 then return '(' .. tostring(tbl) .. ')' end
    if not tbl then return tostring(tbl) end

    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, table.val_to_str(v, maxLevel))
        done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[k] then
            table.insert(result,
                table.key_to_str(k, maxLevel) .. "=" .. table.val_to_str(v, maxLevel))
        end
    end
    return "{" .. table.concat(result, ", ") .. "}"
end
