
local oo = require("oo")
local bt = require("bt")

local Retry = oo.class("bt.Retry", bt.Composite)

function Retry.new(b, limit, self, klass)
    self = self or {}
    Retry.super.new({b}, self, klass or Retry)
    self._limit = limit
    return self
end

function Retry.onIinitialize(self)
	self._attempts = 0
end

function Retry._update(self, pad)
	local s = self._children:front():tick(pad)
	if s == bt.Status.failure then
		self._attempts = (self._attempts or 0) + 1
		if not self._limit or self._attempts < self._limit then
			print("Retrying ...")
			s = bt.Status.running
		end
	end
	return s
end

return Retry
