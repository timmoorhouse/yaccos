
local oo = require("oo")

local Mount = oo.class("vfs.Mount")

function Mount.new(dev, mp, self, klass)
    self = self or {}
    Mount.super.new(self, klass or Mount)
    self._dev    = dev
    self._mp     = mp
    return self
end

function Mount.device(self)
	return self._dev
end

function Mount.mountPoint(self)
	return self._mp
end

return Mount
