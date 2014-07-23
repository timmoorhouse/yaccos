
local oo = require("oo")
local bt = require("bt")

local Sequence = oo.class("bt.Sequence", bt.Composite)

function Sequence.new(children, self, klass)
    self = self or {}
    Sequence.super.new(children, self, klass or Sequence)
    return self
end

function Sequence._update(self, pad)
	while self._current <= self._children:size() do
		--print("seq c="..tostring(self._current).." size="..tostring(self._children:size()))
		--local c = self._children:element(self._current)
		local s = self._children:element(self._current):tick(pad)
		if s ~= bt.Status.success then
			return s
		end
		self._current = self._current + 1
	end
	return bt.Status.success
end

return Sequence
