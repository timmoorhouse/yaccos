
local oo   = require("oo")
local mdm  = require("mdm")
local net  = require("net")
local task = require("task")

-- Based on standard gps program, should work using it as a client

local Server = oo.class("net.gps.Server", task.Daemon)

function Server.new(self, klass)
    self = self or {}
    Server.super.new(self, klass or Server)
    return self
end

local function onMessage(self, sch, rch, msg, side, distance)
    if msg == "PING" then
        peripheral.call(side, "transmit", rch, sch, {self.x,self.y,self.z})
    end
    return true
end

function Server.status(self)
    return mdm.handlers(gps.CHANNEL_GPS) > 0
end

function Server.start(self, ...)

    local args = {...}

    -- Determine position
    if #args >= 3 then

        -- Position is manually specified
        self.x = tonumber(args[1])
        self.y = tonumber(args[2])
        self.z = tonumber(args[3])
        if self.x == nil or self.y == nil or self.z == nil then
            error("invalid position")
        end

    else

        -- Position is to be determined using locate
        self.x, self.y, self.z = gps.locate(2, true)
        if self.x == nil then
            error("could not determine position using GPS network")
        end

    end

    net.syslog.log("Server started for ("..self.x..","..self.y..","..self.z..")")

    mdm.listen(gps.CHANNEL_GPS, onMessage, self)

end

function Server.stop(self)
    mdm.ignore(gps.CHANNEL_GPS, onMessage)
end

return Server
