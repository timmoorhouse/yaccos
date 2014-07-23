
local oo = require("oo")
local bt = require("bt")

local Condition = oo.class("bt.Condition", bt.Behaviour)

function Condition.new(f, self, klass)
    self = self or {}
    Condition.super.new(self, klass or Condition)
    self._f = f
    return self
end

function Condition._update(self, pad)
	if self._f(pad) then
		return bt.Status.success
	else
		return bt.Status.failure
	end
end

return Condition
