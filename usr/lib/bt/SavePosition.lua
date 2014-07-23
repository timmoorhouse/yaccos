
local oo  = require("oo")
local bt  = require("bt")
local log = require("log")
local nt  = require("nt")

local SavePosition = oo.class("bt.SavePosition", bt.Behaviour)

function SavePosition.new(tag, self, klass)
    self = self or {}
    SavePosition.super.new(self, klass or SavePosition)
    self._tag = tag
    return self
end

function SavePosition._update(self, pad)
    pad[self._tag] = {
        pos    = nt.pos("rel"),
        facing = nt.facing("rel"),
        cs     = "rel",
    }
    log.debug("saved position "..self._tag)
    return bt.Status.success
end

return SavePosition
