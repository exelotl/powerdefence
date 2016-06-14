
-- vector from a to b
function vecTo(ax, ay, bx, by)
    return bx-ax, by-ay
end


function normVec(x, y)
    local mag = math.sqrt(x^2+y^2)
    return x/mag, y/mag
end

-- gets the normalised direction vector from a to b
function directionTo(ax, ay, bx, by)
    return normVec(vecTo(ax, ay, bx, by))
end


function angleTo(ax, ay, bx, by)
    local x, y = vecTo(ax, ay, bx, by)
    return math.atan2(y, x)
end


function fromPolar(mag, dir)
    return mag*math.cos(dir), mag*math.sin(dir)
end
