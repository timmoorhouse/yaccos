
local oo = require("oo")
local bt = require("bt")
local nt = require("nt")

local Attack = oo.class("bt.Attack", bt.Behaviour)

function Attack.new(dir, self, klass)
    self = self or {}
    Attack.super.new(self, klass or Attack)
    self._dir = dir or nt.direction.forward
    return self
end

function Attack._update(self, pad)
	nt.attack(self._dir)
	nt.suck(self._dir)
	return bt.Status.success
	--if nt.attack(self._dir) then
	--	return bt.Status.success
	--else
	--	return bt.Status.failure
	--end
end

return Attack
