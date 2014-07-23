
local oo = require("oo")
local bt = require("bt")

local Selector = oo.class("bt.Selector", bt.Composite)

function Selector.new(children, self, klass)
    self = self or {}
    Selector.super.new(children, self, klass or Selector)
    return self
end

function Selector._update(self, pad)
	while self._current <= self._children:size() do
		local s = self._children:element(self._current):tick(pad)
		if s ~= bt.Status.failure then
			return s
		end
		self._current = self._current + 1
	end
	return bt.Status.failure
end

return Selector
