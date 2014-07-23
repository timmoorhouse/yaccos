
local oo    = require("oo")
local bt    = require("bt")
local event = require("event")
local nt    = require("nt") -- TODO
local log   = require("log")
local tb    = require("bt.tb") -- TODO

local Agent = oo.class("bt.Agent", bt.Sequence)

function Agent.new(children, self, klass)
    self = self or {}
    Agent.super.new(children, self, klass or Agent)
    self._pad = bt.Pad.new()
    return self
end

function Agent.onIdle(self, ev)
    local sp=""
    for slot=1,16 do
        sp=sp.." "..tostring(slot)..":"..nt.getItemCount(slot)
    end
    log.debug("----")
    log.debug("br="..tostring(self._pad.bedrock)..
              " fuel="..nt.getFuelLevel()..
              " pos="..tostring(nt.pos("rel"))..
              " f="..tostring(nt.facing("rel"))..
              " hs="..tostring(tb.hasSpace())..
              " hf="..tostring(tb.hasFuel(self._pad, "home"))..
              sp)

    local s = self:tick(self._pad)
    --print("agent status="..s)
    if s ~= bt.Status.running then
        os.queueEvent(event.quit)
        return false
    end
    return true
end

-- TODO: parameter to enable UI?
-- TODO: parameter to decide whether to keep running after all goals complete?
function Agent.run(self)
    event.listen(event.idle, Agent.onIdle, self)
    -- TODO: startup script to resume??
    event.loop()
end

return Agent
