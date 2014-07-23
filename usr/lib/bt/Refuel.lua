
local oo  = require("oo")
local bt  = require("bt")
local nt  = require("nt")
local log = require("log")
local net = require("net")
local tb  = require("bt.tb")

local Refuel = oo.class("bt.Refuel", bt.Behaviour)

function Refuel.new(home, dest, self, klass)
    self = self or {}
    Refuel.super.new(self, klass or Refuel)
    self._home = home
    self._dest = dest
    return self
end

function Refuel.onActivate(self)
    net.syslog.log("Refueling")
    write("Inv:")
    for s = 1,16 do
        write(" "..tostring(nt.getItemCount(s)))
    end
    write("\n")
end

function Refuel._update(self, pad)
    local slot = 1
    while true do
        if self._dest then
            if hasFuel(pad, self._dest, self._home) then
                return bt.Status.success
            end
        else
            if tb.hasFuel(pad, self._home) then
                return bt.Status.success
            end
        end
        if slot > 16 then
            break
        end
        nt.select(slot)
        log.debug("slot="..tostring(slot).." items="..nt.getItemCount(slot))
        --self:debug("trying to refuel from slot "..tostring(slot))
        if nt.refuel(1) then
            log.debug("refueled to "..tostring(nt.getFuelLevel()))
        else
            slot = slot + 1
        end
    end
    return bt.Status.failure
end

return Refuel
