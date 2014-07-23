
local oo     = require("oo")
local bt     = require("bt")
local nt     = require("nt")
local log    = require("log")
local facing = require("facing")

local Go = oo.class("bt.Go", bt.Behaviour)

function Go.new(tag, self, klass)
    self = self or {}
    Go.super.new(self, klass or Go)
    self._tag = tag
    return self
end

function Go._move(self, pad, dir)
    log.debug("move "..dir)
    if pad.auto_refuel and nt.getFuelLevel() == 0 then
        for n=1,16 do
            nt.select(n)
            if nt.refuel(1) then
                break
            end
        end
    end
    local try = true
    local r = false
    while try do
        r = nt.move(dir)
        try = false
        if not r then
            log.debug(" failed")
            local p = nt.pos("rel")
            --print("pos=("..tostring(p.x)..","..tostring(p.y)..","..tostring(p.z)..") fuel="..tostring(nt.getFuelLevel()))
            if nt.detect(dir) then
                if pad.auto_dig then
                    if nt.dig(dir) then
                        try = true
                    end
                end
            else
                if pad.auto_attack then
                    if nt.attack(dir) then
                        try = true
                    end
                end
            end
        end
    end
    --write("\n")
    return r
end

function Go._step_xz(self, pad, dp, axis, system)
    local t = vector.new(0, 0, 0)
    t[axis] = dp[axis]
    if not nt.face(facing.dir(t), system) then
        return false
    end
    return self:_move(pad, "forward")
end

function Go._update(self, pad)
    log.debug("going towards "..self._tag.." fuel="..tostring(nt.getFuelLevel()).." "..tostring(nt.pos("rel")))
    local dest = pad[self._tag]
    local p = nt.pos(dest.cs)
    if not p then
        error("could not determine position")
    end
    local dp = dest.pos-p
    --write("dp="..tostring(dp))

    if dp.y > 0 and self:_move(pad, "up") then
        return bt.Status.running
    end

    if dp.x ~= 0 and self:_step_xz(pad, dp, "x", dest.cs) then
        return bt.Status.running
    end

    if dp.z ~= 0 and self:_step_xz(pad, dp, "z", dest.cs) then
        return bt.Status.running
    end

    -- Try climbing over an obstacle
    if (dp.x ~= 0 or dp.z ~= 0) and dp.y > -10 and self:_move(pad, "up") then
        return bt.Status.running
    end

    if dp.y < 0 and self:_move(pad, "down") then
        return bt.Status.running
    end

    if dp:length() < 0.5 and nt.face(dest.facing, dest.cs) then
        return bt.Status.success
    end

    log.debug("go.update: at end")
    return bt.Status.failure
end

return Go
