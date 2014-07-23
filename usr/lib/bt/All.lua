
local oo = require("oo")
local bt = require("bt")

local All = oo.class("bt.All", bt.Composite)

function All.new(children, self, klass)
    self = self or {}
    All.super.new(children, self, klass or All)
    return self
end

function All._update(self, pad)
	for b in self._children:iterator() do
		local s = b:tick(pad)
		if s ~= bt.Status.success then
			return s
		end
	end
	return bt.Status.success
end

return All
