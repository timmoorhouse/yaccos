
--[[
    Mine in a quarry pattern until we hit something we can't dig

    TODO:
    - discard cobblestone
    - go down 3 levels at a time and use digUp, digDown and dig

]]

local oo     = require("oo")
local bt     = require("bt")
local nt     = require("nt")
local net    = require("net")
local facing = require("facing")

local Dig = oo.class("bt.Dig", bt.Behaviour)

function Dig.new(size, self, klass)
    self = self or {}
    Dig.super.new(self, klass or Dig)
    self.size  = size
    return self
end

function Dig.log(self, msg)
    log.debug(msg)
    --print(msg)
end

function Dig._update(self, pad)
    --print("dig.update fuel="..tostring(nt.getFuelLevel()).." bedrock="..tostring(pad.bedrock))

    local rp = nt.pos("rel")

    -- +x == east
    -- +z == south
    -- +y == up

    local at_s      = (rp.z >= 0)
    local at_n      = (rp.z <= -(self.size-1))
    local at_w      = (rp.x <= 0)
    local at_e      = (rp.x >= (self.size-1))
    local even_y    = ((rp.y % 2) == 0)
    local odd_y     = not even_y
    local even_size = ((self.size % 2) == 0)
    local odd_size  = not even_size

    -- Pattern NE:
    --
    --    +-+
    --    | | ^
    --    | | |
    --    | +-+

    -- Pattern NW:
    --
    --      +-+
    --    ^ | |
    --    | | |
    --    +-+ |

    -- Pattern SW:
    --
    --    +-+ |
    --    | | |
    --    \/| |
    --      +-+

    -- For even sizes, starting in SW corner, use:
    --     NE (ends in SE corner),
    --     NW (ends in SW corner),
    --     repeat

    -- For odd sizes, starting in SW corner, use:
    --     NE (ends in NE corner),
    --     SW (ends in SW corner),
    --     repeat

    if ((even_y and even_size and at_s and at_e) or
        (even_y and odd_size and at_n and at_e) or
        (odd_y and at_s and at_w)) then
       -- Finished level
       --net.syslog.log("completed level "..tostring(rp.y))
       self:log("FINISHED LEVEL "..tostring(rp.y))
       return self:tryDown(pad)
    end

    local even_row -- first row is even
    if even_y then
        even_row = ((rp.x % 2) == 0)
    else
        even_row = (((self.size - rp.x - 1) % 2) == 0)
    end

    local row_goes_n = ((even_y and even_row) or
		                (odd_y and even_size and even_row) or
		                (odd_y and odd_size and not even_row))

    if (row_goes_n and at_n) or (not row_goes_n and at_s) then
        -- At end of intermediate row
        if even_y then
	        nt.face(facing.east, "rel")
        else
	        nt.face(facing.west, "rel")
        end
        return self:tryForward(pad)
    end

    -- In middle of row
    if row_goes_n then
        nt.face(facing.north, "rel")
    else
        nt.face(facing.south, "rel")
    end
    return self:tryForward(pad)
end

function Dig.tryDigAttack(self, pad, dir)
    if nt.detect(dir) then
        if not nt.dig(dir) then
            self:log("DIG FAILED "..dir)
            pad.bedrock = true
            return bt.Status.success
        end
    else
        nt.attack(dir)
    end
    return bt.Status.running
end

function Dig.tryForward(self, pad)
    if not nt.forward() then
        self:tryDigAttack(pad, "forward")
        if not nt.forward() then
            self:log("FORWARD FAILED")
            pad.bedrock = true
            return bt.Status.success
        end
    end
    return bt.Status.running
end

function Dig.tryDown(self, pad)
    if not nt.down() then
        self:log("DOWN FAILED")
        return self:tryDigAttack(pad, "down")
    else
        self:log("down ok????")
    end
    local msg = "descended to "..tostring(nt.pos("rel").y)
    net.syslog.log(msg)
    print(msg)
    return bt.Status.running
end

return Dig
