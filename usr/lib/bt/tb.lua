
local oo     = require("oo")
local bt     = require("bt")
local log    = require("log")
local nt     = require("nt")
local facing = require("facing")

local tb = {}

-- A collection of common turtle behaviours

local function fuel(v)
    -- Fuel needed to traverse vector
    return math.abs(v.x) + math.abs(v.y) + math.abs(v.z)
end

function tb.hasFuel(pad, ...)

    if nt.getFuelLevel() == "unlimited" then
        return true
    end

    local needed = 2
    local p
    local route={...}
    for i,tag in ipairs(route) do
        if pad[tag] then
            if not p then
                p = nt.pos(pad[tag].cs)
            end
            local next = pad[tag].pos
            needed = needed + fuel(next - p)
            p = next
        end
    end
    return nt.getFuelLevel() >= needed
end

function tb.hasSpace()
    for n=1,16 do
        if nt.getItemCount(n) == 0 then
            return true
        end
    end
    return false
end

function tb.isAt(pad, tag)
    -- Can't compare equality since vector doesn't define the operation
    local d = pad[tag].pos - nt.pos(pad[tag].cs)
    return d:length() < 0.5
end

function tb.isEmpty()
    for n=1,16 do
       if nt.getItemCount(n) > 0 then
           return false
       end
    end
    return true
end

return tb
