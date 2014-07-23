
local oo  = require("oo")
local bt  = require("bt")
local log = require("log")

--[[
	Base class for all behaviours
]]

local Behaviour = oo.class("bt.Behaviour")

function Behaviour.new(self, klass)
    self = self or {}
    Behaviour.super.new(self, klass or Behaviour)
    self._status = bt.Status.invalid
    return self
end

function Behaviour.path(self)
	if self._parent then
		return self._parent:path().."/"..tostring(self)
	else
		return tostring(self)
	end
end

function Behaviour.reset(self)
	self._status = bt.Status.invalid
end

function Behaviour.status(self)
	return self._status
end

function Behaviour.isTerminated(self)
	return self._status == bt.Status.success or self._status == bt.Status.failure or self._status == bt.Status.aborted
end

function Behaviour.isRunning(self)
	return self._status == bt.Status.running
end

function Behaviour.tick(self, pad)
	if self._status ~= bt.Status.running then
		self:_onInitialize()
	end
	--log.debug("update "..self:path())
	self._status = self:_update(pad)
	log.debug("update "..self:path().."="..tostring(self._status))
	if self._status ~= bt.Status.running then
		self:_onTerminate()
	end
	return self._status
end

-- Must be provided by subclasses
function Behaviour._update(self, pad)
	return bt.Status.failure
end

-- May be provided by subclasses
function Behaviour._onInitialize(self)
end

-- May be provided by subclasses
function Behaviour._onTerminate(self)
end

function Behaviour.abort(self)
	if self:isRunning() then
		self._status = bt.Status.aborted
		self:_onTerminate()
	end
end

return Behaviour
