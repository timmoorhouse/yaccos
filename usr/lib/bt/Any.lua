
local oo = require("oo")
local bt = require("bt")

local Any = oo.class("bt.Any", bt.Composite)

function Any.new(children, self, klass)
    self = self or {}
    Any.super.new(children, self, klass or Any)
    return self
end

function Any._update(self, pad)
	for b in self._children:iterator() do
		local s = b:tick(pad)
		if s ~= bt.Status.failure then
			return s
		end
	end
	return bt.Status.failure
end

return Any
