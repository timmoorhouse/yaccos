
local facing = require("facing")
local log    = require("log")

local nt = {

    direction = {
        up      = "up",
        down    = "down",
        forward = "forward",
        back    = "back",
        right   = "right",
        left    = "left",
    }

}

local st = {}

function nt.autoDig(enabled)
    st.auto_dig = enabled
end

function nt.autoAttack(enabled)
    st.auto_attack = enabled
end

function nt.reset()
    st.rel = {
        p = vector.new(0, 0, 0),
        f = facing.north,
    }
    st.abs = nil
    st.debug_enabled = false
end

nt.reset()

nt.getItemCount = turtle.getItemCount
nt.getFuelLevel = turtle.getFuelLevel
nt.refuel       = turtle.refuel
nt.select       = turtle.select
-- TODO: function slots(self)

function nt.debug(p, ...)
    if p then
        if type(p) == "boolean" then
	    st.debug_enabled = p
        elseif st.debug_enabled then
	    print(p, ...)
        end
    else
        print("enabling debug ...")
        st.debug_enabled = true
    end
end

local function dump()
    if st.abs then
        nt.debug("... abs pos=", st.abs.p, " facing=", facing.tostring(st.abs.f))
    end
    nt.debug("... rel pos=", st.rel.p, " facing=", facing.tostring(st.rel.f))
end

function nt.pos(system, p)
    system = system or "abs"
    local c
    if system == "abs" then
        if p and not st.abs then
	        st.abs = {}
        end
        c = st.abs
    else
        c = st.rel
    end
    if p then
        c.p = p
    elseif not c then
        -- must be absolute in this case
        local x, y, z = gps.locate(3)
        if z ~= nil then
	        st.abs = {
	            p = vector.new(x, y, z),
	        }
	        c = st.abs
        end
    end
    if c then
        return c.p
    else
        return nil
    end
end

function nt.facing(system, f)
    system = system or "abs"
    local c
    if system == "abs" then
        if f and not st.abs then
	        st.abs = {}
        end
        c = st.abs
    else
        c = st.rel
    end
    if f then
        c.f = f
    end
    if c then
        return c.f
    else
        return nil
    end
end

function nt.abs()
    return pos("abs"), nt.facing("abs")
end

function nt.rel()
    return pos("rel"), nt.facing("rel")
end

function nt.turnLeft()
    local r = turtle.turnLeft()
    if r then
        if st.abs and st.abs.f then
	        nt.facing("abs", facing.left(nt.facing("abs")))
        end
        nt.facing("rel", facing.left(nt.facing("rel")))
    end
    dump()
    return r
end

function nt.turnRight()
    local r = turtle.turnRight()
    if r then
        if st.abs and st.abs.f then
	        nt.facing("abs", facing.right(nt.facing("abs")))
        end
        nt.facing("rel", facing.right(nt.facing("rel")))
    end
    dump()
    return r
end

function nt.forward()
    local p = nt.pos("abs")
    local r = turtle.forward()
    if r then
        if nt.facing("abs") then
	        nt.pos("abs", p + facing.unit(nt.facing("abs")))
        else
	        st.abs = nil
	        local np = nt.pos("abs")
	        if np then
	            nt.facing("abs", facing.dir(np-p))
	        end
        end
        nt.pos("rel", nt.pos("rel") + facing.unit(nt.facing("rel")))
    end
    dump()
    return r
end

function nt.back()
    local p = nt.pos("abs")
    local r = turtle.back()
    if r then
        if facing("abs") then
	        nt.pos("abs", p - facing.unit(nt.facing("abs")))
        else
	        st.abs = nil
            local np = nt.pos("abs")
	        if np then
	            nt.facing(facing.dir(p-np))
	        end
        end
        nt.pos("rel", nt.pos("rel") - facing.unit(nt.facing("rel")))
    end
    dump()
    return r
end

function nt.up()
    local r = turtle.up()
    if r then
        local p = nt.pos("abs")
        if p then
	        nt.pos("abs", vector.new(p.x, p.y+1, p.z))
        end
        p = nt.pos("rel")
        nt.pos("rel", vector.new(p.x, p.y+1, p.z))
    end
    dump()
    return r
end

function nt.down()
    local r = turtle.down()
    log.debug("turtle.down -> "..tostring(r))
    if r then
        local p = nt.pos("abs")
        if p then
	        nt.pos("abs", vector.new(p.x, p.y-1, p.z))
        end
        p = nt.pos("rel")
        nt.pos("rel", vector.new(p.x, p.y-1, p.z))
    end
    dump()
    return r
end

for i,v in ipairs({ "drop",
                    "dig",
                    "detect",
                    "suck",
                    "attack",
                  }) do
    nt[v] =
        function(dir, ...)
            if not dir or dir == nt.direction.forward then
                return turtle[v](...)
            elseif dir == nt.direction.up then
                return turtle[v.."Up"](...)
            elseif dir == nt.direction.down then
                return turtle[v.."Down"](...)
             else
                error("invalid direction "..dir, 3)
            end
        end
end

function nt.move(dir)
    if not dir or dir == nt.direction.forward then
        return nt.forward()
    elseif dir == nt.direction.up then
        return nt.up()
    elseif dir == nt.direction.down then
        return nt.down()
    elseif dir == nt.direction.back then
        return nt.back()
    else
        error("invalid direction "..dir, 2)
    end
end

local function orientationManouevre()
    -- TODO: return to original position
    for i = 1,10 do
        for j = 1,4 do
	        if nt.forward() then
	            return
	        end
	        if not nt.turnRight() then
	            -- Failed ... should never happen here
	            return
	        end
        end
        if not nt.up() then
	        break
        end
    end
end

local function determineOrientation()
    if nt.facing("abs") then
        return true
    end
    orientationManouevre()
    if not nt.facing("abs") then
        error("could not determine orientation")
    end
    return false
end

function nt.face(f, system)
    system = system or "abs"
    if system == "abs" then
        if not determineOrientation() then
	        return false
        end
    end
    if facing.left(nt.facing(system)) == f then
        return nt.turnLeft()
    else
        while nt.facing(system) ~= f do
	        if not nt.turnRight() then
	            return false
	        end
        end
        return true
    end
end

return nt
