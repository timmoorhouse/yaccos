
local oo    = require("oo")
local types = require("types")
local event = require("event")

local Event = oo.class("event.Event")

function Event.new(self, klass)
    self = self or {}
    Event.super.new(self, klass or Event)
	self._handlers = types.List.new()
    return self
end

function Event.listen(self, handler, ...)
	local e = event.Handler.new(handler, {...})
	self._handlers:push_front(e)
	return e
end

function Event.ignore(self, handler)
	self._handlers:remove_if(function(h) return h._handler == handler end)
end

function Event.handlers(self, ev)
	return self._handlers:size()
end

function Event.fire(self, ...)
	local args = {...}
	self._handlers:remove_if(function(h)
		             	         return not h:fire(ev, unpack(args))
		                     end)
	return false
end

return Event
