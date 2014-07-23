
local oo    = require("oo")
--local event = require("event")
local types = require("types")
-- can't require event since we're used by event
local Handler = require("event.Handler")

local HandlerList = oo.class("event.HandlerList")

function HandlerList.new(self, klass)
    self = self or {}
    HandlerList.super.new(self, klass or HandlerList)
	self._handlers = {}
    return self
end

function HandlerList.add(self, ev, handler, ...)
	if not ev then
		error("event missing", 2)
	end
	if not self._handlers[ev] then
		self._handlers[ev] = types.List.new()
	end
	local e = Handler.new(handler, ev, {...})
	self._handlers[ev]:push_front(e)
	return e
end

function HandlerList.remove(self, ev, handler)
	local hl = self._handlers[ev]
	if hl then
		hl:remove_if(function(h)
					     return h._handler == handler
					 end)
		if hl:empty() then
			self._handlers[ev] = nil
		end
	end
end

function HandlerList.handlers(self, ev)
	local hl = self._handlers[ev]
	if hl then
		return hl:size()
	else
		return 0
	end
end

function HandlerList.fire(self, ev, ...)
	local args = {...}
    local hl = self._handlers[ev]
    if os.log and hl then
    	os.log("hl.fire ev="..tostring(ev).." size="..tostring(hl:size()))
    end
	if hl then
		hl:remove_if(function(h)
		             	return not h:fire(ev, unpack(args))
		             end)
	end
	return false
end

return HandlerList
