
local oo = require("oo")

--[[
	State information shared by all behaviours in the tree.
]]

local Pad = oo.class("bt.Pad")

function Pad.new(self, klass)
    self = self or {}
    Pad.super.new(self, klass or Pad)
    return self
end

return Pad
