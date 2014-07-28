
local oo    = require("oo")
local types = require("types")
-- can't require event since we're used by event
local Handler = require("event.Handler")

local Event = oo.class("event.Event")

function Event.new(self, klass)
    self = self or {}
    Event.super.new(self, klass or Event)
	self._handlers = types.List.new()
    return self
end

function Event.listen(self, handler, ...)
	if not ev then
		error("event missing", 2)
	end
	local e = Handler.new(handler, ev, {...})
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
