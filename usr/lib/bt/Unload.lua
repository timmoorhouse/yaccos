
local oo = require("oo")
local bt = require("bt")
local nt = require("nt")

local Unload = oo.class("bt.Unload", bt.Behaviour)

function Unload.new(dir, self, klass)
    self = self or {}
    Unload.super.new(self, klass or Unload)
    self._dir = dir or nt.direction.forward
    return self
end

function Unload._update(self, pad)
    -- TODO: assumes we're pointing toward the chest
    print("Unloading items...")
    for n=1,16 do
        nt.select(n)
        nt.drop(self._dir)
    end
    nt.select(1)
    return bt.Status.success
end

return Unload
