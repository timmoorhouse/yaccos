
local facing = {
    south = 0,
    west  = 1,
    north = 2,
    east  = 3,
}

function facing.tostring(f)
    if f == facing.north then
        return "north"
    elseif f == facing.east then
        return "east"
    elseif f == facing.south then
        return "south"
    elseif f == facing.west then
        return "west"
    else
        return "???"
    end
end

function facing.unit(f)
    if f == facing.north then
        return vector.new(0, 0, -1)
    elseif f == facing.east then
        return vector.new(1, 0, 0)
    elseif f == facing.south then
        return vector.new(0, 0, 1)
    elseif f == facing.west then
        return vector.new(-1, 0, 0)
    else
        -- unknown
        return vector.new(0, 0, 0)
    end
end

function facing.dir(v)
    if v.x < 0 then
        return facing.west
    elseif v.x > 0 then
        return facing.east
    elseif v.z < 0 then
        return facing.north
    elseif v.z > 0 then
        return facing.south
    else
        return nil
    end
end

function facing.right(f)
    if f then
        return (f + 1) % 4
    end
    return nil
end

function facing.opposite(f)
    if f then
        return (f + 2) % 4
    end
    return nil
end

function facing.left(f)
    if f then
        return (f + 3) % 4
    end
    return nil
end

return facing
