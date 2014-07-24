
local oo  = require("oo")
local vfs = require("vfs")

local Temp = oo.class("vfs.Temp", vfs.Mount)

function Temp.new(dev, mp, self, klass)
    self = self or {}
    Temp.super.new(dev, mp, self, klass or Temp)
    return self
end

return Temp
