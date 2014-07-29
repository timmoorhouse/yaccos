
local oo    = require("oo")
local types = require("types")
-- can't require event since we're used by event
local Handler = require("event.Handler")

local KeyedEvent = oo.class("event.KeyedEvent")

function KeyedEvent.new(self, klass)
    self = self or {}
    KeyedEvent.super.new(self, klass or KeyedEvent)
	self._handlers = {}
    return self
end

function KeyedEvent.listen(self, key, handler, ...)
	if not key then
		error("key missing", 2)
	end
	if not self._handlers[key] then
		self._handlers[key] = types.List.new()
	end
	local e = Handler.new(handler, {...})
	self._handlers[key]:push_front(e)
	return e
end

function KeyedEvent.ignore(self, key, handler)
	local hl = self._handlers[key]
	if hl then
		hl:remove_if(function(h)
					     return h._handler == handler
					 end)
		if hl:empty() then
			self._handlers[key] = nil
		end
	end
end

function KeyedEvent.handlers(self, key)
	local hl = self._handlers[key]
	if hl then
		return hl:size()
	else
		return 0
	end
end

function KeyedEvent.fire(self, key, ...)
	local args = {...}
    local hl = self._handlers[key]
    --if os.log and hl then
    --	os.log("hl.fire key="..tostring(key).." size="..tostring(hl:size()))
    --end
	if hl then
		hl:remove_if(function(h)
		             	return not h:fire(key, unpack(args))
		             end)
	end
	return false
end

return KeyedEvent
